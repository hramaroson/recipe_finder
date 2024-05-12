
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper{
  static const _databaseName = 'MyRecipes.db'; 
  static const _databaseVersion = 1;
  static const _recipeTable = 'Recipe';
  static const _recipeId = 'recipeId';
  static const _ingredientTable = 'Ingredient';
  static const _ingredientId = 'ingredientID';

  static late BriteDatabase _streamDatabase;
  
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = 
  DatabaseHelper._privateConstructor();

  static var lock = Lock();
  static Database? _database;

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $_recipeTable (
          $_recipeId INTEGER PRIMARY KEY,
          label TEXT,
          image TEXT,
          url TEXT,
          calories TEXT,
          totalWeight REAL,
          totalTime REAL
        ) 
    ''');
    await db.execute('''
        CREATE TABLE $_ingredientTable (
          $_ingredientId INTERGER PRIMARY KEY,
          $_recipeId INTERGER,
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
}