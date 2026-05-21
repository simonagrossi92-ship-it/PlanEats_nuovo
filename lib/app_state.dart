import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';
import 'services/product_database_service.dart';
import 'storage/local_store.dart';
import 'utils/dates.dart';
import 'utils/price_helper.dart';

class AppState extends ChangeNotifier {
  AppState({LocalStore? store, Uuid? uuid})
      : _store = store ?? LocalStore(),
        _uuid = uuid ?? const Uuid();

  final LocalStore _store;
  final Uuid _uuid;

  bool _ready = false;
  bool get isReady => _ready;

  PlanEatsData _data = PlanEatsData.empty();
  PlanEatsData get data => _data;

  Future<void> init() async {
    _data = await _store.load();

    // Carica i prodotti dal file system
    await loadProductsFromFileSystem();

    _ready = true;
    notifyListeners();
  }

  Future<void> loadProductsFromFileSystem() async {
    try {
      final fileProducts =
          await ProductDatabaseService.instance.loadAllProducts();

      // Aggiungi solo i prodotti non presenti nel sistema interno
      for (final product in fileProducts) {
        final key = product.name.toLowerCase().trim();
        if (!_data.customProducts.containsKey(key)) {
          _data.customProducts[key] = product;
        }
      }

      await _persist();
    } catch (e) {
      // Non fallire se il caricamento non riesce
      if (kDebugMode) {
        print('Errore caricamento prodotti da file: $e');
      }
    }
  }

  Future<void> _persist() async {
    await _store.save(_data);
  }

  // --- Ricette ---
  Recipe? recipeById(String id) {
    for (final r in _data.recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<String> upsertRecipe({
    String? id,
    required String title,
    required List<Ingredient> ingredients,
    String? note,
    RecipeCategory? category,
  }) async {
    final rid = (id == null || id.isEmpty) ? _uuid.v4() : id;
    final recipe = Recipe(
        id: rid,
        title: title,
        ingredients: ingredients,
        note: note,
        category: category);
    final idx = _data.recipes.indexWhere((r) => r.id == rid);
    if (idx >= 0) {
      _data.recipes[idx] = recipe;
    } else {
      _data.recipes.add(recipe);
    }
    await _persist();
    notifyListeners();
    return rid;
  }

  Future<void> deleteRecipe(String id) async {
    _data.recipes.removeWhere((r) => r.id == id);
    // Rimuove eventuali riferimenti nel piano pasti
    _data.weekPlans.forEach((day, meals) {
      for (final entry in meals.entries) {
        final m = entry.value;
        if (m.recipeId == id) {
          meals[entry.key] =
              MealEntry(items: [MealItem(customTitle: m.customTitle)]);
        }
      }
    });
    await _persist();
    notifyListeners();
  }

  Future<void> deleteAllCustomRecipes() async {
    // Ottieni gli ID delle ricette personalizzate prima di eliminarle
    final customRecipeIds = _data.recipes.map((r) => r.id).toList();

    // Elimina tutte le ricette personalizzate
    _data.recipes.clear();

    // Rimuovi tutti i riferimenti nel piano pasti
    _data.weekPlans.forEach((day, meals) {
      for (final entry in meals.entries) {
        final mealEntry = entry.value;
        final updatedItems = mealEntry.items.map((item) {
          if (item.recipeId != null &&
              customRecipeIds.contains(item.recipeId)) {
            // Converti in voce personalizzata mantenendo titolo e numero persone
            return MealItem(
              customTitle: item.displayTitle(),
              numberOfServings: item.numberOfServings,
            );
          }
          return item;
        }).toList();
        meals[entry.key] = MealEntry(items: updatedItems);
      }
    });

    await _persist();
    notifyListeners();
  }

  Future<void> generateShoppingList() async {
    try {
      final now = DateTime.now();
      final days = weekDays(now);
      final startOfWeek = weekStartMonday(days.first);
      final weekKey = isoDate(startOfWeek);

      // La mappa generatedShoppingList è sempre inizializzata nel costruttore

      final recipes = {for (final r in _data.recipes) r.id: r};
      final ingredients = <String, Ingredient>{};

      // Estrai gli ingredienti dalle ricette del menu
      for (final day in days) {
        for (final mealType in MealType.values) {
          final entry = mealEntry(day, mealType);
          if (entry == null || entry.isEmpty) continue;

          // Processa tutti i piatti del pasto
          for (final mealItem in entry.items) {
            final recipeId = mealItem.recipeId;
            if (recipeId == null || recipeId.isEmpty) continue;

            final recipe = recipes[recipeId];
            if (recipe == null) continue;

            // Aggiungi gli ingredienti della ricetta moltiplicati per il numero di persone
            for (final ingredient in recipe.ingredients) {
              try {
                final name = ingredient.name.toLowerCase().trim();
                if (name.isEmpty) continue;

                final categoryName = ingredient.category.name;
                final key = '$name|$categoryName';

                // Moltiplica la quantità per il numero di persone
                final multipliedQuantity = ingredient.quantity != null
                    ? ingredient.quantity! * mealItem.numberOfServings
                    : null;

                final multipliedIngredient = Ingredient(
                  name: ingredient.name,
                  category: ingredient.category,
                  quantity: multipliedQuantity,
                  unit: ingredient.unit,
                  note: ingredient.note,
                );

                // Se l'ingrediente esiste già, somma le quantità
                if (ingredients.containsKey(key)) {
                  final existing = ingredients[key]!;
                  if (existing.quantity != null &&
                      multipliedQuantity != null &&
                      existing.unit == multipliedIngredient.unit) {
                    ingredients[key] = Ingredient(
                      name: existing.name,
                      category: existing.category,
                      quantity: existing.quantity! + multipliedQuantity,
                      unit: existing.unit,
                      note: existing.note,
                    );
                  }
                } else {
                  ingredients[key] = multipliedIngredient;
                }
              } catch (e) {
                // Ignora ingredienti con problemi e continua
                continue;
              }
            }
          }
        }
      }

      // Salva la lista generata
      _data.generatedShoppingList[weekKey] = ingredients.values.toList();
      await _persist();
      notifyListeners();
    } catch (e) {
      // Rilancia l'eccezione con più contesto
      throw Exception(
          'Errore durante la generazione della lista della spesa: $e');
    }
  }

  // --- Piano pasti (per giorno) ---
  Map<String, MealEntry> mealsForDay(DateTime day) {
    final key = isoDate(day);
    return _data.weekPlans[key] ?? <String, MealEntry>{};
  }

  MealEntry? mealEntry(DateTime day, MealType type) {
    final meals = mealsForDay(day);
    return meals[type.name];
  }

  Future<void> setMealEntry(
      DateTime day, MealType type, MealEntry? entry) async {
    final dayKey = isoDate(day);
    final meals = Map<String, MealEntry>.from(
        _data.weekPlans[dayKey] ?? <String, MealEntry>{});
    if (entry == null || entry.isEmpty) {
      meals.remove(type.name);
    } else {
      meals[type.name] = entry;
    }
    if (meals.isEmpty) {
      _data.weekPlans.remove(dayKey);
    } else {
      _data.weekPlans[dayKey] = meals;
    }
    await _persist();
    notifyListeners();
  }

  // --- Spesa / Checkbox ---
  String _weekKey(DateTime anyDayInWeek) =>
      isoDate(weekStartMonday(anyDayInWeek));

  bool isShoppingChecked(
      {required DateTime anyDayInWeek, required String itemKey}) {
    final wk = _weekKey(anyDayInWeek);
    return _data.shoppingChecks[wk]?[itemKey] == true;
  }

  Future<void> setShoppingChecked({
    required DateTime anyDayInWeek,
    required String itemKey,
    required bool checked,
  }) async {
    final wk = _weekKey(anyDayInWeek);
    final current =
        Map<String, bool>.from(_data.shoppingChecks[wk] ?? <String, bool>{});
    current[itemKey] = checked;
    _data.shoppingChecks[wk] = current;
    await _persist();
    notifyListeners();
  }

  Future<void> resetShoppingChecks(DateTime anyDayInWeek) async {
    final wk = _weekKey(anyDayInWeek);
    _data.shoppingChecks.remove(wk);
    _data.extraShoppingItems
        .remove(wk); // Rimuove anche gli extra quando si resetta

    // Forza anche il reset della lista generata per questa settimana
    _data.generatedShoppingList.remove(wk);

    await _persist();
    notifyListeners();
  }

  Future<void> addExtraShoppingItem(
      DateTime anyDayInWeek, Ingredient item) async {
    final wk = _weekKey(anyDayInWeek);
    final current =
        List<Ingredient>.from(_data.extraShoppingItems[wk] ?? <Ingredient>[]);
    current.add(item);
    _data.extraShoppingItems[wk] = current;
    await _persist();
    notifyListeners();
  }

  Future<void> removeExtraShoppingItem(DateTime anyDayInWeek, int index) async {
    final wk = _weekKey(anyDayInWeek);
    final current =
        List<Ingredient>.from(_data.extraShoppingItems[wk] ?? <Ingredient>[]);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      _data.extraShoppingItems[wk] = current;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> updateExtraShoppingItem(
      DateTime anyDayInWeek, int index, Ingredient newItem) async {
    final wk = _weekKey(anyDayInWeek);
    final current =
        List<Ingredient>.from(_data.extraShoppingItems[wk] ?? <Ingredient>[]);
    if (index >= 0 && index < current.length) {
      current[index] = newItem;
      _data.extraShoppingItems[wk] = current;
      await _persist();
      notifyListeners();
    }
  }

  // --- Prodotti Personalizzati ---
  Future<void> saveCustomProduct(CustomProduct product) async {
    final key = product.name.toLowerCase().trim();

    // Salva nel sistema interno
    _data.customProducts[key] = product;
    await _persist();

    // Salva nel file system
    try {
      await ProductDatabaseService.instance.saveProduct(product);
    } catch (e) {
      // Non fallare se il salvataggio file non riesce
      if (kDebugMode) {
        print('Errore salvataggio file prodotto: $e');
      }
    }

    notifyListeners();
  }

  CustomProduct? getCustomProduct(String name) {
    final key = name.toLowerCase().trim();
    return _data.customProducts[key];
  }

  List<CustomProduct> getAllCustomProducts() {
    return _data.customProducts.values.toList();
  }

  Future<void> deleteCustomProduct(String name) async {
    final key = name.toLowerCase().trim();
    _data.customProducts.remove(key);

    // Elimina dal file system
    try {
      await ProductDatabaseService.instance.deleteProduct(name);
    } catch (e) {
      // Non fallire se l'eliminazione file non riesce
      if (kDebugMode) {
        print('Errore eliminazione file prodotto: $e');
      }
    }

    await _persist();
    notifyListeners();
  }

  // Cerca un prodotto sia nel sistema interno che nel file system
  Future<CustomProduct?> findProductAnywhere(String name) async {
    final key = name.toLowerCase().trim();

    // Prima cerca nel sistema interno
    if (_data.customProducts.containsKey(key)) {
      return _data.customProducts[key];
    }

    // Poi cerca nel file system
    try {
      return await ProductDatabaseService.instance.findProduct(name);
    } catch (e) {
      return null;
    }
  }

  // --- Gestione Spese Storiche ---
  Future<void> addExpense(ExpenseRecord expense) async {
    _data.expenseRecords.add(expense);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteExpense(ExpenseRecord expense) async {
    _data.expenseRecords.removeWhere((record) =>
        record.dateTime.isAtSameMomentAs(expense.dateTime) &&
        record.amount == expense.amount);
    await _persist();
    notifyListeners();
  }

  List<ExpenseRecord> getExpensesSortedByDate() {
    final expenses = List<ExpenseRecord>.from(_data.expenseRecords);
    expenses.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return expenses;
  }

  double getTotalExpenses() {
    return _data.expenseRecords
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // --- Gestione Budget Mensili ---
  Future<void> setMonthlyBudget(MonthlyBudget budget) async {
    _data.monthlyBudgets[budget.monthKey] = budget;
    await _persist();
    notifyListeners();
  }

  // --- Conversione spesa archiviata in spese ---
  Future<void> convertArchivedShoppingToExpenses(
      List<Ingredient> ingredients) async {
    // Raggruppa gli ingredienti per categoria di spesa
    final categoryTotals = <ExpenseCategory, double>{};

    for (final ingredient in ingredients) {
      final expenseCategory =
          mapIngredientToExpenseCategory(ingredient.category);

      // Calcola il prezzo dell'ingrediente cercando nei custom products
      double price = 0.0;
      final customProduct = _data.customProducts[ingredient.name];
      if (customProduct != null) {
        if (ingredient.quantity != null) {
          price = ingredient.quantity! * customProduct.price;
        } else {
          price = customProduct.price;
        }
      }

      // Se non c'è prezzo, usa un prezzo predefinito (es. 1.0)
      if (price == 0.0) {
        price = 1.0;
      }

      categoryTotals[expenseCategory] =
          (categoryTotals[expenseCategory] ?? 0.0) + price;
    }

    // Crea ExpenseRecord per ogni categoria
    final now = DateTime.now();
    print('Creando ${categoryTotals.length} spese da ingredienti archiviati');
    for (final entry in categoryTotals.entries) {
      if (entry.value > 0) {
        final expense = ExpenseRecord(
          amount: entry.value,
          dateTime: now,
          note: 'Da lista spesa archiviata',
          category: entry.key,
        );
        print('Aggiungendo spesa: ${entry.key} - €${entry.value}');
        await addExpense(expense);
      }
    }
    print('Spese totali dopo conversione: ${_data.expenseRecords.length}');
  }

  // --- Conversione importi per reparto in spese ---
  Future<void> convertCategoryAmountsToExpenses(
      Map<IngredientCategory, double> categoryAmounts) async {
    final now = DateTime.now();
    print(
        'Creando spese da importi scontrino per ${categoryAmounts.length} reparti');

    for (final entry in categoryAmounts.entries) {
      if (entry.value > 0) {
        final expenseCategory = mapIngredientToExpenseCategory(entry.key);
        final expense = ExpenseRecord(
          amount: entry.value,
          dateTime: now,
          note: 'Da scontrino - ${ingredientCategoryLabel(entry.key)}',
          category: expenseCategory,
        );
        print(
            'Aggiungendo spesa: ${expenseCategory} - €${entry.value} (da ${entry.key})');
        await addExpense(expense);
      }
    }
    print(
        'Spese totali dopo conversione scontrino: ${_data.expenseRecords.length}');
  }

  MonthlyBudget? getMonthlyBudget(int year, int month) {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    return _data.monthlyBudgets[key];
  }

  List<MonthlyBudget> getAllBudgets() {
    final budgets = _data.monthlyBudgets.values.toList();
    budgets.sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return bDate.compareTo(aDate); // Ordine decrescente
    });
    return budgets;
  }

  Future<void> deleteMonthlyBudget(int year, int month) async {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    _data.monthlyBudgets.remove(key);
    await _persist();
    notifyListeners();
  }

  double getExpensesForMonth(int year, int month) {
    return _data.expenseRecords
        .where((expense) =>
            expense.dateTime.year == year && expense.dateTime.month == month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  BudgetStatus getBudgetStatus(int year, int month) {
    final budget = getMonthlyBudget(year, month);
    if (budget == null) return BudgetStatus.verde;

    final currentSpending = getExpensesForMonth(year, month);
    return budget.getStatus(currentSpending);
  }

  double getBudgetPercentageUsed(int year, int month) {
    final budget = getMonthlyBudget(year, month);
    if (budget == null) return 0.0;

    final currentSpending = getExpensesForMonth(year, month);
    return budget.getPercentageUsed(currentSpending);
  }

  double getBudgetRemaining(int year, int month) {
    final budget = getMonthlyBudget(year, month);
    if (budget == null) return 0.0;

    final currentSpending = getExpensesForMonth(year, month);
    return budget.getRemainingAmount(currentSpending);
  }

  // --- Archivio prodotti ---
  Future<void> archiveCheckedItems(DateTime anyDayInWeek) async {
    final wk = _weekKey(anyDayInWeek);
    final checkedItems = _data.shoppingChecks[wk] ?? <String, bool>{};

    if (checkedItems.isEmpty) return;

    // Ottieni tutti gli item della shopping list per questa settimana
    final items = _buildShoppingItemsForArchiving(anyDayInWeek);

    // Filtra solo gli item spuntati
    final itemsToArchive =
        items.where((item) => checkedItems[item.key] == true).toList();

    // Crea ArchivedItem per ogni elemento spuntato
    for (final item in itemsToArchive) {
      final archivedItem = ArchivedItem(
        id: _uuid.v4(),
        name: item.name,
        category: item.category,
        archivedDate: DateTime.now(),
        quantity: item.quantity,
        unit: item.unit,
        estimatedPrice: item.estimatedPrice,
        note: item.note,
      );
      _data.archivedItems.add(archivedItem);
    }

    // Rimuovi completamente gli item spuntati dalla lista
    // Per i prodotti dalle ricette, rimuoviamo solo le spunte
    // Per i prodotti extra, rimuoviamo completamente gli ingredienti

    // Prima rimuoviamo gli extra shopping items spuntati
    final extraItems = _data.extraShoppingItems[wk] ?? <Ingredient>[];
    final remainingExtraItems = <Ingredient>[];

    for (int i = 0; i < extraItems.length; i++) {
      final extra = extraItems[i];
      final norm = extra.name.trim().toLowerCase();
      final unit = (extra.unit ?? '').trim().toLowerCase();
      final key = '${extra.category.name}|$norm|$unit';

      // Se questo extra non è spuntato, lo manteniamo
      if (!(checkedItems[key] == true)) {
        remainingExtraItems.add(extra);
      }
    }

    _data.extraShoppingItems[wk] = remainingExtraItems;

    // Rimuoviamo le spunte per tutti gli item (sia da ricette che extra)
    final newChecks = <String, bool>{};
    for (final entry in checkedItems.entries) {
      if (entry.value != true) {
        newChecks[entry.key] = entry.value;
      }
    }
    _data.shoppingChecks[wk] = newChecks;

    await _persist();
    notifyListeners();
  }

  List<ArchivedItem> getArchivedItems() {
    // Ordina per data decrescente (più recenti prima)
    final sorted = List<ArchivedItem>.from(_data.archivedItems);
    sorted.sort((a, b) => b.archivedDate.compareTo(a.archivedDate));
    return sorted;
  }

  Future<void> deleteArchivedItem(String id) async {
    _data.archivedItems.removeWhere((item) => item.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> clearAllArchivedItems() async {
    _data.archivedItems.clear();
    await _persist();
    notifyListeners();
  }

  // Helper method per costruire gli items per l'archiviazione
  List<_ArchivableShoppingItem> _buildShoppingItemsForArchiving(
      DateTime anyDayInWeek) {
    final days = weekDays(anyDayInWeek);
    final recipes = {for (final r in _data.recipes) r.id: r};
    final agg = <String, _ArchivableAgg>{};

    // 1. Dalle ricette del piano
    for (final day in days) {
      for (final t in MealType.values) {
        final entry = mealEntry(day, t);
        final rid = entry?.recipeId;
        if (rid == null || rid.isEmpty) continue;
        final recipe = recipes[rid];
        if (recipe == null) continue;

        for (final ing in recipe.ingredients) {
          _aggregateForArchiving(agg, ing);
        }
      }
    }

    // 2. Dagli extra aggiunti manualmente per questa settimana
    final startOfWeek = weekStartMonday(days.first);
    final extras = _data.extraShoppingItems[isoDate(startOfWeek)] ?? [];
    for (int i = 0; i < extras.length; i++) {
      _aggregateForArchiving(agg, extras[i]);
    }

    final out = <_ArchivableShoppingItem>[];
    for (final entry in agg.entries) {
      final a = entry.value;

      // Calcolo stima prezzo
      final priceEst = estimatePrice(
        a.name,
        a.hasQty ? a.totalQty : 1.0,
        a.unit,
        customProducts: _data.customProducts,
      );

      out.add(_ArchivableShoppingItem(
        key: entry.key,
        name: a.name,
        category: a.category,
        quantity: a.hasQty ? a.totalQty : null,
        unit: a.unit.isEmpty ? null : a.unit,
        estimatedPrice: priceEst.amount,
        note: null,
      ));
    }
    return out;
  }

  void _aggregateForArchiving(Map<String, _ArchivableAgg> agg, Ingredient ing) {
    final name = ing.name.trim();
    if (name.isEmpty) return;
    final norm = name.toLowerCase();
    final unit = (ing.unit ?? '').trim().toLowerCase();
    final key = '${ing.category.name}|$norm|$unit';
    final a = agg.putIfAbsent(
      key,
      () => _ArchivableAgg(name: name, category: ing.category, unit: unit),
    );
    if (ing.quantity != null) {
      a.hasQty = true;
      a.totalQty += ing.quantity!;
    }
  }
}

// Classi helper per l'archiviazione
class _ArchivableShoppingItem {
  _ArchivableShoppingItem({
    required this.key,
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    required this.estimatedPrice,
    this.note,
  });

  final String key;
  final String name;
  final IngredientCategory category;
  final double? quantity;
  final String? unit;
  final double estimatedPrice;
  final String? note;
}

class _ArchivableAgg {
  _ArchivableAgg(
      {required this.name, required this.category, required this.unit});
  final String name;
  final IngredientCategory category;
  final String unit;
  double totalQty = 0;
  bool hasQty = false;
}
