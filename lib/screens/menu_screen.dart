import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../utils/dates.dart';
import 'recipe_editor.dart';
import 'recipes_screen.dart';

Color getMealColor(BuildContext context, MealType type) {
  switch (type) {
    case MealType.colazione:
      return const Color(0xFFFFD54F); // Amber 300
    case MealType.pranzo:
      return const Color(0xFF81D4FA); // Light Blue 200
    case MealType.cena:
      return const Color(0xFF9FA8DA); // Indigo 200
    case MealType.snack:
      return Colors.black87; // Nero per pasti opzionali/snack
  }
}

Color getMealSurfaceColor(BuildContext context, MealType type) {
  switch (type) {
    case MealType.colazione:
    case MealType.pranzo:
    case MealType.cena:
      return Colors.white;
    case MealType.snack:
      return Colors.white; // Anche lo snack bianco come gli altri
  }
}

Color getMealOnColor(BuildContext context, MealType type) {
  switch (type) {
    case MealType.colazione:
      return const Color(0xFF5D4037); // Brown 800
    case MealType.pranzo:
      return const Color(0xFF01579B); // Light Blue 900
    case MealType.cena:
      return const Color(0xFF1A237E); // Indigo 900
    case MealType.snack:
      return Colors.white; // Testo bianco su sfondo nero per l'icona snack
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.state});
  final AppState state;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final List<DateTime> _days;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _days = weekDays(DateTime.now());
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateShoppingList(BuildContext context) async {
    // Estrai gli ingredienti da tutte le ricette del menu settimanale
    final days = weekDays(DateTime.now());
    final recipes = {for (final r in widget.state.data.recipes) r.id: r};
    final allIngredients = <String, Ingredient>{};

    // Raccogli tutti gli ingredienti dalle ricette del menu
    for (final day in days) {
      for (final mealType in MealType.values) {
        final entry = widget.state.mealEntry(day, mealType);
        if (entry == null || entry.isEmpty) continue;

        for (final item in entry.items) {
          final recipeId = item.recipeId;
          if (recipeId == null || recipeId.isEmpty) continue;

          final recipe = recipes[recipeId];
          if (recipe == null) continue;

          // Aggiungi gli ingredienti della ricetta moltiplicati per le persone
          for (final ingredient in recipe.ingredients) {
            final key =
                '${ingredient.name.toLowerCase().trim()}|${ingredient.category.name}';

            // Moltiplica la quantità per il numero di persone
            final multipliedQuantity = ingredient.quantity != null
                ? ingredient.quantity! * item.numberOfServings
                : null;

            final multipliedIngredient = Ingredient(
              name: ingredient.name,
              category: ingredient.category,
              quantity: multipliedQuantity,
              unit: ingredient.unit,
              note: ingredient.note,
            );

            // Se l'ingrediente esiste già, somma le quantità
            if (allIngredients.containsKey(key)) {
              final existing = allIngredients[key]!;
              if (existing.quantity != null &&
                  multipliedQuantity != null &&
                  existing.unit == multipliedIngredient.unit) {
                allIngredients[key] = Ingredient(
                  name: existing.name,
                  category: existing.category,
                  quantity: existing.quantity! + multipliedQuantity,
                  unit: existing.unit,
                  note: existing.note,
                );
              }
            } else {
              allIngredients[key] = multipliedIngredient;
            }
          }
        }
      }
    }

    if (allIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Nessuna ricetta nel menu settimanale. Aggiungi prima delle ricette al menu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Converti in lista e ordina per categoria e nome
    final ingredientList = allIngredients.values.toList()
      ..sort((a, b) {
        final catCompare = a.category.index.compareTo(b.category.index);
        if (catCompare != 0) return catCompare;
        return a.name.compareTo(b.name);
      });

    // Mostra dialog di conferma con il riepilogo
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Genera Lista della Spesa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Trovati ${ingredientList.length} ingredienti unici dalle ricette del menu:'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ingredientList
                          .map((ingredient) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(
                                            ingredient.category),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ingredient.name,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    if (ingredient.quantity != null)
                                      Text(
                                        '${ingredient.quantity}${ingredient.unit ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8BA888),
                ),
                child: const Text('Genera Lista'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      try {
        await widget.state.generateShoppingList();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Lista della spesa generata! Vai alla scheda "Spesa" per vederla.'),
              backgroundColor: Color(0xFF8BA888),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante la generazione: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getCategoryColor(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.ortofrutta:
        return Colors.green;
      case IngredientCategory.carne:
        return Colors.red;
      case IngredientCategory.pesce:
        return Colors.blue;
      case IngredientCategory.latticini:
        return Colors.orange;
      case IngredientCategory.panetteria:
        return Colors.brown;
      case IngredientCategory.surgelati:
        return Colors.cyan;
      case IngredientCategory.dispensa:
        return Colors.amber;
      case IngredientCategory.bevande:
        return Colors.purple;
      case IngredientCategory.prodottiAnimali:
        return Colors.teal;
      case IngredientCategory.curaCasa:
        return Colors.lime;
      case IngredientCategory.igienePersonale:
        return Colors.pink;
      case IngredientCategory.altro:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _days.map((d) => Tab(text: weekdayShortLabel(d))).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days
            .map((d) => _DayMenuView(state: widget.state, day: d))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateShoppingList(context),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: const Text('Genera Lista Spesa'),
        backgroundColor: const Color(0xFF8BA888),
      ),
    );
  }
}

class _DayMenuView extends StatelessWidget {
  const _DayMenuView({required this.state, required this.day});
  final AppState state;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final snack = state.mealEntry(day, MealType.snack);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _MealCard(
            state: state,
            day: day,
            type: MealType.colazione,
            icon: Icons.wb_sunny_outlined),
        _MealCard(
            state: state,
            day: day,
            type: MealType.pranzo,
            icon: Icons.restaurant_outlined),
        _MealCard(
            state: state,
            day: day,
            type: MealType.cena,
            icon: Icons.nightlight_outlined),
        if (snack != null && !snack.isEmpty)
          _MealCard(
              state: state,
              day: day,
              type: MealType.snack,
              icon: Icons.local_cafe_outlined)
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: OutlinedButton.icon(
              onPressed: () => _openMealPicker(context,
                  state: state, day: day, type: MealType.snack),
              icon: const Icon(Icons.add, color: Colors.black87),
              label: const Text(
                'Aggiungi snack (opzionale)',
                style: TextStyle(color: Colors.black87),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black26),
              ),
            ),
          ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.state,
    required this.day,
    required this.type,
    required this.icon,
  });

  final AppState state;
  final DateTime day;
  final MealType type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final entry = state.mealEntry(day, type);
    final hasValue = entry != null && !entry.isEmpty;

    // Ottieni tutti i titoli dei piatti
    final recipes = {for (final r in state.data.recipes) r.id: r};
    final titles = hasValue
        ? entry.displayTitles(recipes: recipes)
        : ['Nessuna selezione'];

    // Usa il primo titolo come titolo principale
    final title = titles.isNotEmpty ? titles.first : 'Nessuna selezione';

    final surfaceColor = getMealSurfaceColor(context, type);
    final accentColor = getMealColor(context, type);
    final onAccentColor = getMealOnColor(context, type);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: surfaceColor,
      elevation: 4, // Aggiunta ombreggiatura
      shadowColor: Colors.black.withValues(alpha: 0.2), // Colore ombra leggero
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Angoli più arrotondati
        side: BorderSide(
          color: hasValue
              ? accentColor.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            20, 20, 20, 20), // Padding interno maggiore
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centrato verticalmente
          children: [
            Container(
              width: 64, // Dimensione cerchio maggiore
              height: 64,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32, // Icona più grande
                color: onAccentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mealTypeLabel(type),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onAccentColor.withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(height: 10), // Aumentato spazio da 6 a 10
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: hasValue
                              ? Colors.black87
                              : Theme.of(context).colorScheme.outline,
                          fontWeight: hasValue ? FontWeight.w500 : null,
                        ),
                  ),
                  // Mostra tutti i piatti se ce ne sono più di uno
                  if (hasValue && titles.length > 1) ...[
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: titles
                          .skip(1)
                          .map(
                            (additionalTitle) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '• $additionalTitle',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              onPressed: () =>
                  _openMealPicker(context, state: state, day: day, type: type),
              icon: Icon(hasValue ? Icons.edit_outlined : Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.3),
                foregroundColor: onAccentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MealPickAction { ricettario, nuovaRicetta, testo }

enum _MealAddMode { sostituisci, aggiungi }

int _lastNumberOfPeople = 1;

Future<void> _openMealPicker(
  BuildContext context, {
  required AppState state,
  required DateTime day,
  required MealType type,
}) async {
  final action = await showModalBottomSheet<_MealPickAction>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Ricettario'),
              subtitle: const Text('Scegli una ricetta esistente'),
              onTap: () => Navigator.pop(context, _MealPickAction.ricettario),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Aggiungi nuova ricetta'),
              subtitle: const Text('Crea una ricetta e aggiungila al pasto'),
              onTap: () => Navigator.pop(context, _MealPickAction.nuovaRicetta),
            ),
            if (type == MealType.snack)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Scrivi manualmente'),
                subtitle: const Text('Inserisci un testo (es. Yogurt)'),
                onTap: () => Navigator.pop(context, _MealPickAction.testo),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (action == null) return;

  try {
    String? recipeId;
    String? customTitle;

    switch (action) {
      case _MealPickAction.ricettario:
        if (state.data.recipes.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Il ricettario è vuoto. Crea prima una ricetta.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        recipeId = await Navigator.push<String?>(
          context,
          MaterialPageRoute(
            builder: (_) => RecipesScreen(state: state, pickMode: true),
          ),
        );
        break;
      case _MealPickAction.nuovaRicetta:
        recipeId = await Navigator.push<String?>(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeEditorScreen(state: state),
          ),
        );
        break;
      case _MealPickAction.testo:
        customTitle = await _askSnackText(context);
        break;
    }

    if ((recipeId == null || recipeId.isEmpty) &&
        (customTitle == null || customTitle.trim().isEmpty)) {
      return;
    }

    final currentEntry = state.mealEntry(day, type);
    final hasExisting = currentEntry != null && !currentEntry.isEmpty;

    _MealAddMode mode = _MealAddMode.sostituisci;
    if (hasExisting) {
      final pickedMode = await showDialog<_MealAddMode?>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${mealTypeLabel(type)} già compilato'),
            content: const Text('Vuoi sostituire o aggiungere come portata?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, _MealAddMode.sostituisci),
                child: const Text('Sostituisci'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, _MealAddMode.aggiungi),
                child: const Text('Aggiungi'),
              ),
            ],
          );
        },
      );
      if (pickedMode == null) return;
      mode = pickedMode;
    }

    final servings = await _askNumberOfPeople(
      context,
      initialValue: _lastNumberOfPeople,
    );
    if (servings == null) return;
    _lastNumberOfPeople = servings;

    final newItem = MealItem(
      recipeId: recipeId,
      customTitle: customTitle?.trim(),
      numberOfServings: servings,
    );

    final items = mode == _MealAddMode.aggiungi && hasExisting
        ? [...currentEntry!.items, newItem]
        : [newItem];

    await state.setMealEntry(
      day,
      type,
      MealEntry(
        items: items,
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ricetta aggiunta a ${mealTypeLabel(type)}'),
          backgroundColor: const Color(0xFF8BA888),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<String?> _askSnackText(BuildContext context) async {
  final ctrl = TextEditingController();
  final result = await showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Nome snack'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Testo',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(context, v);
            },
            child: const Text('Conferma'),
          ),
        ],
      );
    },
  );
  ctrl.dispose();
  return result;
}

Future<int?> _askNumberOfPeople(
  BuildContext context, {
  required int initialValue,
}) async {
  final ctrl = TextEditingController(text: initialValue.toString());
  final result = await showDialog<int?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Numero di persone'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Persone',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(ctrl.text.trim());
              if (value == null || value <= 0) return;
              Navigator.pop(context, value);
            },
            child: const Text('Conferma'),
          ),
        ],
      );
    },
  );
  ctrl.dispose();
  return result;
}

Future<void> _openMealEditor(
  BuildContext context, {
  required AppState state,
  required DateTime day,
  required MealType type,
}) async {
  try {
    final recipes = state.data.recipes;
    final current = state.mealEntry(day, type);

    // Verifica che le ricette siano caricate correttamente
    if (recipes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Nessuna ricetta disponibile. Aggiungi prima delle ricette nel ricettario.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Inizializza la lista di piatti correnti
    List<MealItem> currentItems = current?.items ?? [];

    // Se non ci sono piatti, crea una lista con un elemento vuoto per l'editing
    if (currentItems.isEmpty) {
      currentItems = [MealItem(numberOfServings: 1)];
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${mealTypeLabel(type)} • ${weekdayShortLabel(day)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: getMealOnColor(context, type),
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Lista delle portate correnti
                  ...currentItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isRecipe = item.recipeId != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header della portata
                          Row(
                            children: [
                              Text(
                                'Portata ${index + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              if (currentItems.length > 1)
                                IconButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      currentItems.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  iconSize: 20,
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Selezione ricetta o testo personalizzato
                          if (isRecipe) ...[
                            if (recipes.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    const Text('Nessuna ricetta disponibile'),
                              )
                            else
                              DropdownButtonFormField<String>(
                                initialValue: item.recipeId,
                                decoration: const InputDecoration(
                                  labelText: 'Seleziona ricetta',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: recipes
                                    .map((r) => DropdownMenuItem<String>(
                                          value: r.id,
                                          child: Text(r.title,
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  setSheetState(() {
                                    currentItems[index] = MealItem(
                                      recipeId: v,
                                      numberOfServings: item.numberOfServings,
                                    );
                                  });
                                },
                              ),
                          ] else ...[
                            TextFormField(
                              initialValue: item.customTitle,
                              decoration: const InputDecoration(
                                labelText: 'Nome portata',
                                hintText: 'Es. Insalata',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (v) {
                                setSheetState(() {
                                  currentItems[index] = MealItem(
                                    customTitle: v.trim(),
                                    numberOfServings: item.numberOfServings,
                                  );
                                });
                              },
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Numero di persone per questa portata
                          Row(
                            children: [
                              const Icon(Icons.people, size: 14),
                              const SizedBox(width: 2),
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      item.numberOfServings.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'N°',
                                    hintText: '2',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final value = int.tryParse(v);
                                    if (value != null && value > 0) {
                                      setSheetState(() {
                                        currentItems[index] = MealItem(
                                          recipeId: item.recipeId,
                                          customTitle: item.customTitle,
                                          numberOfServings: value,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  // Pulsante per aggiungere nuova portata
                  TextButton.icon(
                    onPressed: () {
                      setSheetState(() {
                        currentItems.add(MealItem(numberOfServings: 1));
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi portata'),
                    style: TextButton.styleFrom(
                      foregroundColor: getMealColor(context, type),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      TextButton(
                        onPressed: (current == null || current.isEmpty)
                            ? null
                            : () async {
                                await state.setMealEntry(day, type, null);
                                if (context.mounted) Navigator.pop(context);
                              },
                        child: const Text('Rimuovi tutto'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () async {
                          // Rimuovi le portate vuote
                          final validItems = currentItems
                              .where((item) => !item.isEmpty)
                              .toList();

                          if (validItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Aggiungi almeno una portata valida'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final entry = MealEntry(items: validItems);
                          await state.setMealEntry(day, type, entry);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Salva'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'apertura dell\'editor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
