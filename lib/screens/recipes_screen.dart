import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/predefined_recipes.dart';
import '../models.dart';
import '../utils/dates.dart';
import 'recipe_editor.dart';

Future<int> importPredefinedRecipes({
  required AppState state,
  required Set<RecipeCategory> categories,
}) async {
  if (categories.isEmpty) return 0;

  final predefinedRecipes = PredefinedRecipes.getRecipes();
  final expectedIds = <String>{};

  for (final recipe in predefinedRecipes) {
    final category = getRecipeCategory(recipe);
    if (!categories.contains(category)) continue;
    expectedIds.add(recipe.id);
    await state.upsertRecipe(
      id: recipe.id,
      title: recipe.title,
      ingredients: recipe.ingredients,
      note: recipe.note,
      category: category,
    );
  }

  final presentIds = state.data.recipes.map((r) => r.id).toSet();
  final missing = expectedIds.difference(presentIds);
  if (missing.isNotEmpty) {
    throw StateError('Import incompleto: ${missing.length} ricette mancanti');
  }

  return expectedIds.length;
}

IconData getCategoryIcon(RecipeCategory category) {
  switch (category) {
    case RecipeCategory.antipasti:
      return Icons.tapas;
    case RecipeCategory.primi:
      return Icons.restaurant;
    case RecipeCategory.secondiCarne:
      return Icons.lunch_dining;
    case RecipeCategory.secondiPesce:
      return Icons.set_meal;
    case RecipeCategory.contorni:
      return Icons.eco;
    case RecipeCategory.dolci:
      return Icons.cake;
    case RecipeCategory.altre:
      return Icons.more_horiz;
  }
}

RecipeCategory getRecipeCategory(Recipe recipe) {
  // Se la ricetta ha una categoria impostata, usala
  if (recipe.category != null) {
    return recipe.category!;
  }

  // Altrimenti, usa la logica basata sul titolo per le ricette predefinite
  final title = recipe.title.toLowerCase();
  final id = recipe.id.toLowerCase();

  if (id.contains('bruschetta') ||
      title.contains('bruschetta') ||
      id.startsWith('bruschetta_') ||
      title.contains('antipasto')) {
    return RecipeCategory.antipasti;
  }
  if (id.contains('pasta_') ||
      title.contains('pasta') ||
      title.contains('spaghetti') ||
      title.contains('risotto') ||
      title.contains('lasagne') ||
      title.contains('trenette')) {
    return RecipeCategory.primi;
  }
  if (id.contains('carne_') ||
      title.contains('pollo') ||
      title.contains('bistecca') ||
      title.contains('manzo') ||
      title.contains('maiale') ||
      title.contains('vitello') ||
      title.contains('coniglio') ||
      title.contains('salsiccia')) {
    return RecipeCategory.secondiCarne;
  }
  if (id.contains('pesce_') ||
      title.contains('salmone') ||
      title.contains('orata') ||
      title.contains('spigola') ||
      title.contains('tonno') ||
      title.contains('baccalà') ||
      title.contains('polpo') ||
      title.contains('vongole')) {
    return RecipeCategory.secondiPesce;
  }
  if (id.contains('contorno_') ||
      title.contains('insalata') ||
      title.contains('patate') ||
      title.contains('verdure') ||
      title.contains('carciofi') ||
      title.contains('melanzane') ||
      title.contains('zucchine') ||
      title.contains('peperoni')) {
    return RecipeCategory.contorni;
  }
  if (id.contains('dolce_') ||
      title.contains('tiramisù') ||
      title.contains('panna') ||
      title.contains('biscotto') ||
      title.contains('torta') ||
      title.contains('crostata') ||
      title.contains('cheesecake') ||
      title.contains('muffin')) {
    return RecipeCategory.dolci;
  }

  return RecipeCategory.altre;
}

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key, required this.state, this.pickMode = false});
  final AppState state;
  final bool pickMode;

  @override
  Widget build(BuildContext context) {
    final recipes = pickMode
        ? (() {
            final byId = <String, Recipe>{};
            for (final r in PredefinedRecipes.getRecipes()) {
              byId[r.id] = r;
            }
            for (final r in state.data.recipes) {
              byId[r.id] = r;
            }
            return byId.values.toList();
          })()
        : [...state.data.recipes];

    // Raggruppa le ricette per categoria
    final groupedRecipes = <RecipeCategory, List<Recipe>>{};
    for (final recipe in recipes) {
      final category = getRecipeCategory(recipe);
      groupedRecipes.putIfAbsent(category, () => []).add(recipe);
    }

    // Ordina le ricette all'interno di ogni categoria
    for (final category in groupedRecipes.keys) {
      groupedRecipes[category]!.sort((a, b) => a.title.compareTo(b.title));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pickMode ? 'Scegli ricetta' : 'Ricettario'),
        actions: pickMode
            ? null
            : [
                IconButton(
                  onPressed: () => _showAddRecipesDialog(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'Aggiungi 60 ricette predefinite',
                ),
              ],
      ),
      body: recipes.isEmpty
          ? Center(
              child: Text(pickMode
                  ? 'Nessuna ricetta nel ricettario.'
                  : 'Nessuna ricetta. Premi + per aggiungerne una.'))
          : ListView(
              children: RecipeCategory.values.map((category) {
                final categoryRecipes = groupedRecipes[category] ?? [];
                if (categoryRecipes.isEmpty) return const SizedBox.shrink();

                return _RecipeCategorySection(
                  category: category,
                  recipes: categoryRecipes,
                  state: state,
                  pickMode: pickMode,
                  onPick: pickMode
                      ? (recipe) async {
                          final alreadyInBook = state.data.recipes
                              .any((r) => r.id == recipe.id);
                          if (!alreadyInBook) {
                            await state.upsertRecipe(
                              id: recipe.id,
                              title: recipe.title,
                              ingredients: recipe.ingredients,
                              note: recipe.note,
                              category: recipe.category ?? getRecipeCategory(recipe),
                            );
                          }
                          if (context.mounted) {
                            Navigator.pop(context, recipe.id);
                          }
                        }
                      : null,
                  onAddToMenu: pickMode
                      ? null
                      : (recipe) => _showAddToMenuDialog(context, recipe),
                );
              }).toList(),
            ),
      floatingActionButton: pickMode
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RecipeEditorScreen(state: state)),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showAddRecipesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Ricette Predefinite'),
        content: const Text(
          'Vuoi aggiungere 60 ricette predefinite divise per portate alla tua scheda?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
              _addPredefinedRecipesToSchedule(context);
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  void _showAddToMenuDialog(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => _AddToMenuDialog(state: state, recipe: recipe),
    );
  }

  void _addPredefinedRecipesToSchedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SelectCategoriesDialog(state: state),
    );
  }

  void _showDeleteAllRecipesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ELIMINA TUTTE LE RICETTE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stai per eliminare tutte le ricette personalizzate!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
                'Sono presenti ${state.data.recipes.length} ricette personalizzate.'),
            const SizedBox(height: 8),
            const Text(
              'Questa azione è IRREVERSIBILE e:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('• Eliminerà tutte le ricette personalizzate'),
            const Text('• Convertirà i piatti nel menu in voci personalizzate'),
            const Text('• Le ricette predefinite NON saranno eliminate'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await state.deleteAllCustomRecipes();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Tutte le ricette personalizzate sono state eliminate'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Elimina Tutto'),
          ),
        ],
      ),
    );
  }
}

class _RecipeCategorySection extends StatelessWidget {
  const _RecipeCategorySection({
    required this.category,
    required this.recipes,
    required this.state,
    required this.pickMode,
    required this.onPick,
    required this.onAddToMenu,
  });

  final RecipeCategory category;
  final List<Recipe> recipes;
  final AppState state;
  final bool pickMode;
  final Future<void> Function(Recipe)? onPick;
  final Function(Recipe)? onAddToMenu;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading:
          Icon(getCategoryIcon(category), color: _getCategoryColor(category)),
      title: Text(
        category.displayName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text('${recipes.length} ricette'),
      backgroundColor: _getCategoryBackgroundColor(category),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: recipes
          .map((recipe) => _RecipeTile(
                recipe: recipe,
                state: state,
                pickMode: pickMode,
                onPick: onPick,
                onAddToMenu:
                    onAddToMenu == null ? null : () => onAddToMenu!(recipe),
              ))
          .toList(),
    );
  }

  Color _getCategoryColor(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.antipasti:
        return Colors.orange;
      case RecipeCategory.primi:
        return Colors.blue;
      case RecipeCategory.secondiCarne:
        return Colors.red;
      case RecipeCategory.secondiPesce:
        return Colors.teal;
      case RecipeCategory.contorni:
        return Colors.green;
      case RecipeCategory.dolci:
        return Colors.purple;
      case RecipeCategory.altre:
        return Colors.grey;
    }
  }

  Color _getCategoryBackgroundColor(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.antipasti:
        return Colors.orange.withValues(alpha: 0.1);
      case RecipeCategory.primi:
        return Colors.blue.withValues(alpha: 0.1);
      case RecipeCategory.secondiCarne:
        return Colors.red.withValues(alpha: 0.1);
      case RecipeCategory.secondiPesce:
        return Colors.teal.withValues(alpha: 0.1);
      case RecipeCategory.contorni:
        return Colors.green.withValues(alpha: 0.1);
      case RecipeCategory.dolci:
        return Colors.purple.withValues(alpha: 0.1);
      case RecipeCategory.altre:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({
    required this.recipe,
    required this.state,
    required this.pickMode,
    required this.onPick,
    required this.onAddToMenu,
  });

  final Recipe recipe;
  final AppState state;
  final bool pickMode;
  final Future<void> Function(Recipe)? onPick;
  final VoidCallback? onAddToMenu;

  @override
  Widget build(BuildContext context) {
    if (pickMode) {
      return ListTile(
        contentPadding: const EdgeInsets.only(left: 72, right: 16),
        title: Text(recipe.title),
        subtitle: Text('${recipe.ingredients.length} ingredienti'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async => await onPick?.call(recipe),
      );
    }

    return Dismissible(
      key: ValueKey(recipe.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.delete,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminare ricetta?'),
                content: Text('Vuoi eliminare "${recipe.title}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annulla')),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Elimina'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => state.deleteRecipe(recipe.id),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 72, right: 16),
        title: Text(recipe.title),
        subtitle: Text('${recipe.ingredients.length} ingredienti'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
              tooltip: 'Aggiungi al menu',
              onPressed: onAddToMenu,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              tooltip: 'Elimina ricetta',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminare ricetta?'),
                        content: Text('Vuoi eliminare "${recipe.title}"?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annulla')),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Elimina'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (confirmed) {
                  state.deleteRecipe(recipe.id);
                }
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeEditorScreen(state: state, recipe: recipe),
            ),
          );
        },
      ),
    );
  }
}

class _SelectCategoriesDialog extends StatefulWidget {
  const _SelectCategoriesDialog({required this.state});
  final AppState state;

  @override
  State<_SelectCategoriesDialog> createState() =>
      _SelectCategoriesDialogState();
}

class _SelectCategoriesDialogState extends State<_SelectCategoriesDialog> {
  final Map<RecipeCategory, bool> _selectedCategories = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inizializza tutte le categorie come selezionate
    for (final category in RecipeCategory.values) {
      _selectedCategories[category] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleziona Categorie da Importare'),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scegli quali categorie di ricette predefinite vuoi aggiungere al tuo ricettario:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ...RecipeCategory.values.map((category) {
                  return CheckboxListTile(
                    title: Text(category.displayName),
                    secondary: Icon(getCategoryIcon(category)),
                    value: _selectedCategories[category] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategories[category] = value ?? false;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed:
              _isLoading ? null : () => _importSelectedCategories(context),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Importa Selezionate'),
        ),
      ],
    );
  }

  void _importSelectedCategories(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final selected = _selectedCategories.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toSet();

    try {
      if (selected.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seleziona almeno una categoria'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final importedCount = await importPredefinedRecipes(
        state: widget.state,
        categories: selected,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$importedCount ricette predefinite aggiunte al ricettario!'),
            backgroundColor: const Color(0xFF8BA888),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'importazione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _AddToMenuDialog extends StatefulWidget {
  const _AddToMenuDialog({required this.state, required this.recipe});
  final AppState state;
  final Recipe recipe;

  @override
  State<_AddToMenuDialog> createState() => _AddToMenuDialogState();
}

class _AddToMenuDialogState extends State<_AddToMenuDialog> {
  DateTime? selectedDay;
  MealType? selectedMeal;
  int numberOfServings = 1;
  bool addToExisting = false;

  @override
  Widget build(BuildContext context) {
    final days = weekDays(DateTime.now());

    return AlertDialog(
      title: Text('Aggiungi "${widget.recipe.title}" al menu'),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Seleziona giorno e pasto:'),
              const SizedBox(height: 8),

              // Selezione giorno
              const Text('Giorno:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: days.map((day) {
                  final isSelected = selectedDay != null &&
                      selectedDay!.day == day.day &&
                      selectedDay!.month == day.month &&
                      selectedDay!.year == day.year;
                  return FilterChip(
                    label: Text(weekdayShortLabel(day)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedDay = selected ? day : null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Selezione pasto
              const Text('Pasto:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: MealType.values.map((meal) {
                  final isSelected = selectedMeal == meal;
                  return FilterChip(
                    label: Text(mealTypeLabel(meal)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedMeal = selected ? meal : null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Modalità di aggiunta
              const Text('Modalità:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Sostituisci'),
                    icon: Icon(Icons.refresh),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Aggiungi'),
                    icon: Icon(Icons.add_circle),
                  ),
                ],
                selected: {addToExisting},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    addToExisting = selection.first;
                  });
                },
              ),

              const SizedBox(height: 8),

              // Numero di persone
              const Text('Persone:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextFormField(
                      initialValue: numberOfServings.toString(),
                      decoration: const InputDecoration(
                        labelText: 'N°',
                        hintText: '2',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final value = int.tryParse(v);
                        if (value != null && value > 0) {
                          setState(() => numberOfServings = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: (selectedDay == null || selectedMeal == null)
              ? null
              : () async {
                  final currentEntry =
                      widget.state.mealEntry(selectedDay!, selectedMeal!);
                  List<MealItem> items;

                  if (addToExisting &&
                      currentEntry != null &&
                      !currentEntry.isEmpty) {
                    items = [
                      ...currentEntry.items,
                      MealItem(
                        recipeId: widget.recipe.id,
                        numberOfServings: numberOfServings,
                      )
                    ];
                  } else {
                    items = [
                      MealItem(
                        recipeId: widget.recipe.id,
                        numberOfServings: numberOfServings,
                      )
                    ];
                  }

                  await widget.state.setMealEntry(
                    selectedDay!,
                    selectedMeal!,
                    MealEntry(items: items),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    final actionText =
                        addToExisting ? 'aggiunto come portata' : 'aggiunto';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${widget.recipe.title}" $actionText a ${mealTypeLabel(selectedMeal!)} di ${weekdayShortLabel(selectedDay!)}',
                        ),
                        backgroundColor: const Color(0xFF8BA888),
                      ),
                    );
                  }
                },
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}
