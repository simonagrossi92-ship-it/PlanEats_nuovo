import '../models.dart';

class PredefinedRecipes {
  static List<Recipe> getRecipes() {
    return [
      // Antipasti
      Recipe(
        id: 'bruschetta_001',
        title: 'Bruschetta Classica',
        category: RecipeCategory.antipasti,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Pane',
              category: IngredientCategory.panetteria,
              quantity: 2,
              unit: 'fette'),
          Ingredient(
              name: 'Burro',
              category: IngredientCategory.latticini,
              quantity: 20,
              unit: 'g'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
          Ingredient(
              name: 'Pepe',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Tostare il pane e condirlo con burro e sale',
      ),
      Recipe(
        id: 'bruschetta_002',
        title: 'Bruschetta con Pomodoro',
        category: RecipeCategory.antipasti,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Pane',
              category: IngredientCategory.panetteria,
              quantity: 2,
              unit: 'fette'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'medio'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
          Ingredient(
              name: 'Origano',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'pizzico'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
          Ingredient(
              name: 'Pepe',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Tagliare il pomodoro e condirlo con gli altri ingredienti',
      ),
      Recipe(
        id: 'bruschetta_003',
        title: 'Bruschetta con Funghi',
        category: RecipeCategory.antipasti,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Pane',
              category: IngredientCategory.panetteria,
              quantity: 2,
              unit: 'fette'),
          Ingredient(
              name: 'Funghi',
              category: IngredientCategory.ortofrutta,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
          Ingredient(
              name: 'Prezzemolo',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Saltare i funghi e condirli con aglio e prezzemolo',
      ),
      Recipe(
        id: 'bruschetta_004',
        title: 'Bruschetta con Olive',
        category: RecipeCategory.antipasti,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Pane',
              category: IngredientCategory.panetteria,
              quantity: 2,
              unit: 'fette'),
          Ingredient(
              name: 'Olive',
              category: IngredientCategory.ortofrutta,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Capperi',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaino'),
          Ingredient(
              name: 'Acciughe',
              category: IngredientCategory.pesce,
              quantity: 2,
              unit: 'filetti'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Pepe',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Preparare un trito di olive e capperi',
      ),
      Recipe(
        id: 'bruschetta_005',
        title: 'Bruschetta con Paté',
        category: RecipeCategory.antipasti,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Pane',
              category: IngredientCategory.panetteria,
              quantity: 2,
              unit: 'fette'),
          Ingredient(
              name: 'Paté',
              category: IngredientCategory.carne,
              quantity: 30,
              unit: 'g'),
          Ingredient(
              name: 'Cipolla',
              category: IngredientCategory.ortofrutta,
              quantity: 0.25,
              unit: 'media'),
          Ingredient(
              name: 'Erba Cipollina',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaino'),
        ],
        note: 'Spalmare il paté e guarnire con erba cipollina',
      ),

      // Primi
      Recipe(
        id: 'pasta_001',
        title: 'Spaghetti al Pomodoro',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Spaghetti',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Basilico',
              category: IngredientCategory.ortofrutta,
              quantity: 5,
              unit: 'foglie'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Cuocere la pasta e condire con pomodoro fresco',
      ),
      Recipe(
        id: 'pasta_002',
        title: 'Carbonara',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Spaghetti',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Guanciale',
              category: IngredientCategory.carne,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Uova',
              category: IngredientCategory.latticini,
              quantity: 1,
              unit: 'uovo'),
          Ingredient(
              name: 'Pecorino',
              category: IngredientCategory.latticini,
              quantity: 30,
              unit: 'g'),
          Ingredient(
              name: 'Pepe Nero',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'pizzichi'),
        ],
        note: 'Cuocere la pasta e preparare il sugo con guanciale e uova',
      ),
      Recipe(
        id: 'pasta_003',
        title: 'Pasta al Forno',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Rigatoni',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Ragù',
              category: IngredientCategory.carne,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Mozzarella',
              category: IngredientCategory.latticini,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Parmigiano',
              category: IngredientCategory.latticini,
              quantity: 20,
              unit: 'g'),
          Ingredient(
              name: 'Basilico',
              category: IngredientCategory.ortofrutta,
              quantity: 3,
              unit: 'foglie'),
        ],
        note: 'Condire i rigatoni e cuocere in forno con ragù e mozzarella',
      ),
      Recipe(
        id: 'pasta_004',
        title: 'Pesto alla Genovese',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Trenette',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Basilico',
              category: IngredientCategory.ortofrutta,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Pinoli',
              category: IngredientCategory.altro,
              quantity: 15,
              unit: 'g'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 2,
              unit: 'spicchi'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 3,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Pecorino',
              category: IngredientCategory.latticini,
              quantity: 30,
              unit: 'g'),
        ],
        note: 'Preparare il pesto con basilico, pinoli e aglio',
      ),
      Recipe(
        id: 'pasta_005',
        title: 'Amatriciana',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Bucatini',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Guanciale',
              category: IngredientCategory.carne,
              quantity: 60,
              unit: 'g'),
          Ingredient(
              name: 'Vino Rosso',
              category: IngredientCategory.bevande,
              quantity: 50,
              unit: 'ml'),
          Ingredient(
              name: 'Peperoncino',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'pezzo'),
          Ingredient(
              name: 'Cipolla',
              category: IngredientCategory.ortofrutta,
              quantity: 0.5,
              unit: 'media'),
        ],
        note: 'Preparare il sugo con guanciale e pomodoro',
      ),
      Recipe(
        id: 'pasta_006',
        title: 'Cacio e Pepe',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Spaghetti',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Pecorino',
              category: IngredientCategory.latticini,
              quantity: 40,
              unit: 'g'),
          Ingredient(
              name: 'Pepe Nero',
              category: IngredientCategory.dispensa,
              quantity: 3,
              unit: 'pizzichi'),
        ],
        note: 'Condire la pasta con pecorino e pepe nero',
      ),
      Recipe(
        id: 'pasta_007',
        title: 'Pasta con le Sarde',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Spaghetti',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Sarde',
              category: IngredientCategory.pesce,
              quantity: 150,
              unit: 'g'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Uva passa',
              category: IngredientCategory.altro,
              quantity: 20,
              unit: 'g'),
          Ingredient(
              name: 'Pinoli',
              category: IngredientCategory.altro,
              quantity: 10,
              unit: 'g'),
          Ingredient(
              name: 'Finocchietto',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'ciuffo'),
        ],
        note: 'Saltare le sarde e condire con pomodoro fresco',
      ),
      Recipe(
        id: 'pasta_008',
        title: 'Pasta e Fagioli',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Fagioli',
              category: IngredientCategory.ortofrutta,
              quantity: 150,
              unit: 'g'),
          Ingredient(
              name: 'Pancetta',
              category: IngredientCategory.carne,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Rosmarino',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'rametto'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
        ],
        note: 'Cuocere i fagioli con pancetta e rosmarino',
      ),
      Recipe(
        id: 'pasta_009',
        title: 'Pasta alla Norma',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Lasagne',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Ragù',
              category: IngredientCategory.carne,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Besciamella',
              category: IngredientCategory.latticini,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Mozzarella',
              category: IngredientCategory.latticini,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Parmigiano',
              category: IngredientCategory.latticini,
              quantity: 20,
              unit: 'g'),
        ],
        note: 'Preparare le lasagne con ragù e besciamella',
      ),
      Recipe(
        id: 'pasta_010',
        title: 'Pasta con le Vongole',
        category: RecipeCategory.primi,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Spaghetti',
              category: IngredientCategory.panetteria,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Vongole',
              category: IngredientCategory.pesce,
              quantity: 300,
              unit: 'g'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 2,
              unit: 'spicchi'),
          Ingredient(
              name: 'Prezzemolo',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Vino Bianco',
              category: IngredientCategory.bevande,
              quantity: 50,
              unit: 'ml'),
          Ingredient(
              name: 'Peperoncino',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'pezzo'),
        ],
        note: 'Cuocere le vongole con aglio e prezzemolo',
      ),

      // Secondi di Carne
      Recipe(
        id: 'carne_001',
        title: 'Pollo al Forno',
        ingredients: [
          Ingredient(
              name: 'Pollo',
              category: IngredientCategory.carne,
              quantity: 500,
              unit: 'g'),
          Ingredient(
              name: 'Patate',
              category: IngredientCategory.ortofrutta,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Cipolla',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'media'),
          Ingredient(
              name: 'Carote',
              category: IngredientCategory.ortofrutta,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Rosmarino',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'rametto'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Marinare il pollo e cuocere in forno con patate e verdure',
      ),
      Recipe(
        id: 'carne_007',
        title: 'Coniglio in Umido',
        category: RecipeCategory.secondiCarne,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Coniglio',
              category: IngredientCategory.carne,
              quantity: 300,
              unit: 'g'),
          Ingredient(
              name: 'Olive',
              category: IngredientCategory.ortofrutta,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 150,
              unit: 'g'),
          Ingredient(
              name: 'Cipolla',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'media'),
          Ingredient(
              name: 'Vino Rosso',
              category: IngredientCategory.bevande,
              quantity: 50,
              unit: 'ml'),
        ],
        note: 'Cuocere il coniglio con olive e pomodoro',
      ),
      Recipe(
        id: 'carne_008',
        title: 'Salsiccia alla Griglia',
        category: RecipeCategory.secondiCarne,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Salsiccia',
              category: IngredientCategory.carne,
              quantity: 150,
              unit: 'g'),
          Ingredient(
              name: 'Peperoni',
              category: IngredientCategory.ortofrutta,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Cipolla',
              category: IngredientCategory.ortofrutta,
              quantity: 0.5,
              unit: 'media'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'cucchiaio'),
        ],
        note: 'Grigliare la salsiccia con peperoni e cipolla',
      ),
      Recipe(
        id: 'pesce_001',
        title: 'Salmone al Vapore',
        category: RecipeCategory.secondiPesce,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Salmone',
              category: IngredientCategory.pesce,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Limone',
              category: IngredientCategory.ortofrutta,
              quantity: 0.5,
              unit: 'unito'),
          Ingredient(
              name: 'Aneto',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Cuocere il salmone al vapore con erbe aromatiche',
      ),
      Recipe(
        id: 'pesce_002',
        title: 'Orata al Forno',
        category: RecipeCategory.secondiPesce,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Orata',
              category: IngredientCategory.pesce,
              quantity: 300,
              unit: 'g'),
          Ingredient(
              name: 'Patate',
              category: IngredientCategory.ortofrutta,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Olive',
              category: IngredientCategory.ortofrutta,
              quantity: 30,
              unit: 'g'),
          Ingredient(
              name: 'Limone',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'unito'),
          Ingredient(
              name: 'Prezzemolo',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Capperi',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaino'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
        ],
        note: 'Cuocere l\'orata con patate e olive',
      ),
      Recipe(
        id: 'pesce_003',
        title: 'Spigola alla Griglia',
        category: RecipeCategory.secondiPesce,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Spigola',
              category: IngredientCategory.pesce,
              quantity: 250,
              unit: 'g'),
          Ingredient(
              name: 'Limone',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'unito'),
          Ingredient(
              name: 'Prezzemolo',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Grigliare la spigola con limone e prezzemolo',
      ),
      Recipe(
        id: 'pesce_004',
        title: 'Tonno in Padella',
        category: RecipeCategory.secondiPesce,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Tonno',
              category: IngredientCategory.pesce,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Cipolla',
              category: IngredientCategory.ortofrutta,
              quantity: 0.5,
              unit: 'media'),
          Ingredient(
              name: 'Capperi',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaino'),
          Ingredient(
              name: 'Olive',
              category: IngredientCategory.ortofrutta,
              quantity: 20,
              unit: 'g'),
          Ingredient(
              name: 'Vino Bianco',
              category: IngredientCategory.bevande,
              quantity: 50,
              unit: 'ml'),
        ],
        note: 'Cuocere il tonno con capperi e olive',
      ),
      Recipe(
        id: 'pesce_005',
        title: 'Baccalà alla Napoletana',
        category: RecipeCategory.secondiPesce,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Baccalà',
              category: IngredientCategory.pesce,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 150,
              unit: 'g'),
          Ingredient(
              name: 'Olive',
              category: IngredientCategory.ortofrutta,
              quantity: 30,
              unit: 'g'),
          Ingredient(
              name: 'Capperi',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaino'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
        ],
        note: 'Preparare il baccalà con pomodoro e olive',
      ),
      Recipe(
        id: 'pesce_006',
        title: 'Polpo con Patate',
        category: RecipeCategory.secondiPesce,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Polpo',
              category: IngredientCategory.pesce,
              quantity: 250,
              unit: 'g'),
          Ingredient(
              name: 'Patate',
              category: IngredientCategory.ortofrutta,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Prezzemolo',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Limone',
              category: IngredientCategory.ortofrutta,
              quantity: 0.5,
              unit: 'unito'),
        ],
        note: 'Cuocere il polpo con patate e prezzemolo',
      ),

      // Contorni
      Recipe(
        id: 'contorno_001',
        title: 'Insalata di Verdure',
        category: RecipeCategory.contorni,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Carote',
              category: IngredientCategory.ortofrutta,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Sedano',
              category: IngredientCategory.ortofrutta,
              quantity: 30,
              unit: 'g'),
          Ingredient(
              name: 'Peperoni',
              category: IngredientCategory.ortofrutta,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Cetrioli',
              category: IngredientCategory.ortofrutta,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Aceto',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'cucchiaio'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Tagliare le verdure a julienne e marinare con olio e aceto',
      ),
      Recipe(
        id: 'contorno_002',
        title: 'Patate al Forno',
        category: RecipeCategory.contorni,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Patate',
              category: IngredientCategory.ortofrutta,
              quantity: 250,
              unit: 'g'),
          Ingredient(
              name: 'Rosmarino',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaino'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Burro',
              category: IngredientCategory.latticini,
              quantity: 20,
              unit: 'g'),
          Ingredient(
              name: 'Sale',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'pizzico'),
        ],
        note: 'Cuocere le patate in forno con rosmarino e burro',
      ),
      Recipe(
        id: 'contorno_003',
        title: 'Carciofi alla Griglia',
        category: RecipeCategory.contorni,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Carciofi',
              category: IngredientCategory.ortofrutta,
              quantity: 2,
              unit: 'medi'),
          Ingredient(
              name: 'Limone',
              category: IngredientCategory.ortofrutta,
              quantity: 0.5,
              unit: 'unito'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
          Ingredient(
              name: 'Aglio',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'spicchio'),
          Ingredient(
              name: 'Prezzemolo',
              category: IngredientCategory.ortofrutta,
              quantity: 1,
              unit: 'cucchiaio'),
        ],
        note: 'Grigliare i carciofi con limone e prezzemolo',
      ),
      Recipe(
        id: 'contorno_004',
        title: 'Melanzane alla Parmigiana',
        category: RecipeCategory.contorni,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Melanzane',
              category: IngredientCategory.ortofrutta,
              quantity: 300,
              unit: 'g'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Mozzarella',
              category: IngredientCategory.latticini,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Parmigiano',
              category: IngredientCategory.latticini,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Basilico',
              category: IngredientCategory.ortofrutta,
              quantity: 5,
              unit: 'foglie'),
          Ingredient(
              name: 'Olio',
              category: IngredientCategory.dispensa,
              quantity: 2,
              unit: 'cucchiai'),
        ],
        note: 'Preparare le melanzane con mozzarella e pomodoro',
      ),
      Recipe(
        id: 'contorno_005',
        title: 'Zucchine Ripiene',
        category: RecipeCategory.contorni,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Zucchine',
              category: IngredientCategory.ortofrutta,
              quantity: 2,
              unit: 'medie'),
          Ingredient(
              name: 'Carne Macinata',
              category: IngredientCategory.carne,
              quantity: 150,
              unit: 'g'),
          Ingredient(
              name: 'Mozzarella',
              category: IngredientCategory.latticini,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Pomodoro',
              category: IngredientCategory.ortofrutta,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Basilico',
              category: IngredientCategory.ortofrutta,
              quantity: 3,
              unit: 'foglie'),
        ],
        note: 'Ripieni le zucchine con carne e mozzarella',
      ),
      Recipe(
        id: 'contorno_006',
        title: 'Fagiolata di Verdure',
        ingredients: [
          Ingredient(name: 'Fagioli', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Patate', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Carote', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Cipolla', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Sedano', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Pancetta', category: IngredientCategory.carne),
        ],
        note: 'Preparare fagiolata con pancetta e verdure',
      ),
      Recipe(
        id: 'contorno_007',
        title: 'Peperoni Ripieni',
        ingredients: [
          Ingredient(name: 'Peperoni', category: IngredientCategory.ortofrutta),
          Ingredient(
              name: 'Carne Macinata', category: IngredientCategory.carne),
          Ingredient(name: 'Uova', category: IngredientCategory.latticini),
          Ingredient(
              name: 'Pangrattato', category: IngredientCategory.panetteria),
          Ingredient(
              name: 'Parmigiano', category: IngredientCategory.latticini),
        ],
        note: 'Ripieni i peperoni con carne e formaggio',
      ),
      Recipe(
        id: 'contorno_008',
        title: 'Cavolfiore al Forno',
        ingredients: [
          Ingredient(
              name: 'Cavolfiore', category: IngredientCategory.ortofrutta),
          Ingredient(
              name: 'Besciamella', category: IngredientCategory.latticini),
          Ingredient(
              name: 'Parmigiano', category: IngredientCategory.latticini),
          Ingredient(
              name: 'Pangrattato', category: IngredientCategory.panetteria),
          Ingredient(name: 'Burro', category: IngredientCategory.latticini),
        ],
        note: 'Cuocere il cavolfiore con besciamella e pangrattato',
      ),

      // Dolci
      Recipe(
        id: 'dolce_001',
        title: 'Tiramisù',
        category: RecipeCategory.dolci,
        servingType: ServingType.torta,
        ingredients: [
          Ingredient(
              name: 'Savoiardi',
              category: IngredientCategory.panetteria,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Caffè',
              category: IngredientCategory.bevande,
              quantity: 200,
              unit: 'ml'),
          Ingredient(
              name: 'Mascarpone',
              category: IngredientCategory.latticini,
              quantity: 250,
              unit: 'g'),
          Ingredient(
              name: 'Uova',
              category: IngredientCategory.latticini,
              quantity: 3,
              unit: 'uova'),
          Ingredient(
              name: 'Zucchero',
              category: IngredientCategory.dispensa,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Cacao',
              category: IngredientCategory.dispensa,
              quantity: 20,
              unit: 'g'),
        ],
        note: 'Preparare il tiramisù con savoiardi e cacao',
      ),
      Recipe(
        id: 'dolce_002',
        title: 'Panna Cotta',
        category: RecipeCategory.dolci,
        servingType: ServingType.porzioni,
        ingredients: [
          Ingredient(
              name: 'Panna',
              category: IngredientCategory.latticini,
              quantity: 250,
              unit: 'ml'),
          Ingredient(
              name: 'Gelatina',
              category: IngredientCategory.dispensa,
              quantity: 6,
              unit: 'g'),
          Ingredient(
              name: 'Zucchero',
              category: IngredientCategory.dispensa,
              quantity: 50,
              unit: 'g'),
          Ingredient(
              name: 'Vaniglia',
              category: IngredientCategory.dispensa,
              quantity: 1,
              unit: 'bustina'),
        ],
        note: 'Preparare la panna cotta con gelatina e vaniglia',
      ),
      Recipe(
        id: 'dolce_003',
        title: 'Biscotti al Burro',
        category: RecipeCategory.dolci,
        servingType: ServingType.persone,
        ingredients: [
          Ingredient(
              name: 'Farina',
              category: IngredientCategory.panetteria,
              quantity: 200,
              unit: 'g'),
          Ingredient(
              name: 'Burro',
              category: IngredientCategory.latticini,
              quantity: 100,
              unit: 'g'),
          Ingredient(
              name: 'Zucchero',
              category: IngredientCategory.dispensa,
              quantity: 80,
              unit: 'g'),
          Ingredient(
              name: 'Uova',
              category: IngredientCategory.latticini,
              quantity: 1,
              unit: 'uovo'),
          Ingredient(
              name: 'Lievito',
              category: IngredientCategory.dispensa,
              quantity: 8,
              unit: 'g'),
        ],
        note:
            'Impastare farina, burro, zucchero e uova, aggiungere lievito e cuocere',
      ),
      Recipe(
        id: 'dolce_004',
        title: 'Crostata di Frutta',
        ingredients: [
          Ingredient(name: 'Farina', category: IngredientCategory.panetteria),
          Ingredient(name: 'Burro', category: IngredientCategory.latticini),
          Ingredient(name: 'Zucchero', category: IngredientCategory.dispensa),
          Ingredient(name: 'Uova', category: IngredientCategory.latticini),
          Ingredient(
              name: 'Frutta Fresca', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Gelatina', category: IngredientCategory.altro),
        ],
        note: 'Preparare crostata con frutta di stagione',
      ),
      Recipe(
        id: 'dolce_005',
        title: 'Torta al Cioccolato',
        ingredients: [
          Ingredient(name: 'Farina', category: IngredientCategory.panetteria),
          Ingredient(name: 'Cioccolato', category: IngredientCategory.dispensa),
          Ingredient(name: 'Zucchero', category: IngredientCategory.dispensa),
          Ingredient(name: 'Uova', category: IngredientCategory.latticini),
          Ingredient(name: 'Burro', category: IngredientCategory.latticini),
          Ingredient(name: 'Lievito', category: IngredientCategory.dispensa),
        ],
        note: 'Preparare torta al cioccolato morbida',
      ),
      Recipe(
        id: 'dolce_006',
        title: 'Muffin ai Mirtilli',
        ingredients: [
          Ingredient(name: 'Farina', category: IngredientCategory.panetteria),
          Ingredient(name: 'Zucchero', category: IngredientCategory.dispensa),
          Ingredient(name: 'Uova', category: IngredientCategory.latticini),
          Ingredient(name: 'Mirtilli', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Burro', category: IngredientCategory.latticini),
          Ingredient(name: 'Lievito', category: IngredientCategory.dispensa),
        ],
        note: 'Preparare muffin con mirtilli freschi',
      ),
      Recipe(
        id: 'dolce_007',
        title: 'Cheesecake',
        ingredients: [
          Ingredient(name: 'Biscotti', category: IngredientCategory.panetteria),
          Ingredient(
              name: 'Formaggio Fresco', category: IngredientCategory.latticini),
          Ingredient(name: 'Zucchero', category: IngredientCategory.dispensa),
          Ingredient(name: 'Uova', category: IngredientCategory.latticini),
          Ingredient(name: 'Panna', category: IngredientCategory.latticini),
          Ingredient(name: 'Gelatina', category: IngredientCategory.altro),
        ],
        note: 'Preparare cheesecake con base di biscotti',
      ),
      Recipe(
        id: 'dolce_008',
        title: 'Panna Cotta al Caffè',
        ingredients: [
          Ingredient(name: 'Panna', category: IngredientCategory.latticini),
          Ingredient(name: 'Zucchero', category: IngredientCategory.dispensa),
          Ingredient(name: 'Caffè', category: IngredientCategory.bevande),
          Ingredient(name: 'Gelatina', category: IngredientCategory.altro),
          Ingredient(name: 'Cioccolato', category: IngredientCategory.dispensa),
        ],
        note: 'Preparare panna cotta con sapore di caffè',
      ),
      Recipe(
        id: 'dolce_009',
        title: 'Torta di Mele',
        ingredients: [
          Ingredient(name: 'Farina', category: IngredientCategory.panetteria),
          Ingredient(name: 'Mele', category: IngredientCategory.ortofrutta),
          Ingredient(name: 'Zucchero', category: IngredientCategory.dispensa),
          Ingredient(name: 'Uova', category: IngredientCategory.latticini),
          Ingredient(name: 'Burro', category: IngredientCategory.latticini),
          Ingredient(name: 'Lievito', category: IngredientCategory.dispensa),
          Ingredient(name: 'Cannella', category: IngredientCategory.dispensa),
        ],
        note: 'Preparare torta di mele con cannella',
      ),
      Recipe(
        id: 'dolce_010',
        title: 'Biscotti al Cioccolato',
        ingredients: [
          Ingredient(name: 'Farina', category: IngredientCategory.panetteria),
          Ingredient(name: 'Cioccolato', category: IngredientCategory.dispensa),
          Ingredient(name: 'Zucchero', category: IngredientCategory.dispensa),
          Ingredient(name: 'Uova', category: IngredientCategory.latticini),
          Ingredient(name: 'Burro', category: IngredientCategory.latticini),
          Ingredient(name: 'Lievito', category: IngredientCategory.dispensa),
        ],
        note: 'Preparare biscotti con gocce di cioccolato',
      ),
    ];
  }
}
