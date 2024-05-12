
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';

import '../models/models.dart';

class DatabaseHelper{
  static const _databaseName = 'MyRecipes.db'; 
  static const _databaseVersion = 1;
  static const recipeTable = 'Recipe';
  static const recipeId = 'recipeId';
  static const ingredientTable = 'Ingredient';
  static const ingredientId = 'ingredientId';

  static late BriteDatabase _streamDatabase;
  
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = 
  DatabaseHelper._privateConstructor();

  static var lock = Lock();
  static Database? _database;

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $recipeTable (
          $recipeId INTEGER PRIMARY KEY,
          label TEXT,
          image TEXT,
          url TEXT,
          calories TEXT,
          totalWeight REAL,
          totalTime REAL
        ) 
    ''');
    await db.execute('''
        CREATE TABLE $ingredientTable (
          $ingredientId INTERGER PRIMARY KEY,
          $recipeId INTERGER,
          name TEXT,
          weight REAL
        )
    ''');
  }
  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    final documentsDirectory = 
    await getApplicationDocumentsDirectory();

    final path = join(
      documentsDirectory.path, 
      _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    await lock.synchronized(() async {
      if(_database == null) {
        _database = await _initDatabase();
        _streamDatabase = BriteDatabase(_database!);
      }
    });
    return _database!;
  }

  Future<BriteDatabase> get streamDatabase async{
    database;
    return _streamDatabase;
  }

  List<Recipe> parseRecipes(List<Map<String, dynamic>> recipeList) {
    final recipes = <Recipe>[];

    for (final recipeMap in recipeList){
       recipes.add(Recipe.fromJson(recipeMap)) ;
    }

    return recipes;
  }

  List<Ingredient> parseIngredients(List<Map<String, dynamic>> ingredientList){
    final ingredients = <Ingredient>[];

    for(final ingredientMap in ingredientList){
        ingredients.add(Ingredient.fromJson(ingredientMap));
    }

    return ingredients;
  }

  Future<List<Recipe>> findAllRecipes() async {
    final db = await instance.streamDatabase;
    final recipeList = await db.query(recipeTable);
    final recipes = parseRecipes(recipeList);

    return recipes;
  }

  Stream<List<Recipe>> watchAllRecipes() async* {
    final db = await instance.streamDatabase;
    yield* db
      .createQuery(recipeTable)
      .mapToList((row) => Recipe.fromJson(row));
  }

  Stream<List<Ingredient>> watchAllIngredients() async* {
    final db = await instance.streamDatabase;
    yield* db
      .createQuery(ingredientTable)
      .mapToList((row) => Ingredient.fromJson(row));
  }

  Future<Recipe> findRecipeById(int id) async{
    final db = await instance.streamDatabase;
    final recipeList = await db.query(
      recipeTable,
      where: 'id=$id'
    );
    
    final recipes = parseRecipes(recipeList);
    return recipes.first;
  }

  Future<List<Ingredient>> findAllIngredients() async {
    final db = await instance.streamDatabase;
    final ingredientList = await db.query(ingredientTable);
    final ingredients = parseIngredients(ingredientList);

    return ingredients;
  }

  Future<List<Ingredient>> findRecipeIngredients(int recipeId) async {
    final db = await instance.streamDatabase;

    final ingredientList = await db.query(
      ingredientTable,
      where: 'recipeId=$recipeId'
    );
    final ingredients = parseIngredients(ingredientList);

    return ingredients;
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.streamDatabase;
    return db.insert(
      table, 
      row
    );
  }

  Future<int> insertRecipe(Recipe recipe) async {
    return insert(
      recipeTable,
      recipe.toJson()
    );
  }

  Future<int> insertIngredients(Ingredient ingredient) async {
    return insert(
      ingredientTable, 
      ingredient.toJson()
    );
  }

  Future<int> _delete(String table, String columnId, int id) async {
    final db = await instance.streamDatabase;

    return db.delete(
      table,
      where: '$columnId= ?', 
      whereArgs: [id]
    );
  }

  Future<int> deleteRecipe(Recipe recipe) async {
    if(recipe.id != null) {
      return _delete(
        recipeTable, 
        recipeId, 
        recipe.id!);
    }

    return Future.value(-1);
  }

  Future<int> deleteIngredient(Ingredient ingredient) async {
    if(ingredient.id != null){
      return _delete(
        ingredientTable, 
        ingredientId, 
        ingredient.id!);
    }

    return Future.value(-1);
  }

 Future<void> deleteIngredients(List<Ingredient> ingredients) async {
    for(final ingredient in ingredients){
      if(ingredient.id != null) {
        _delete(
        ingredientTable, 
        ingredientId, 
        ingredient.id!);
      }
    }

    return Future.value();
 }

 Future<int> deleteRecipeIngredients(int id) async {
    final db = await instance.streamDatabase;
    
    return db.delete(
      ingredientTable, 
      where: 'recipeId=?',
      whereArgs: [id]
    );
 }

 void close(){
  _streamDatabase.close();
 }
}