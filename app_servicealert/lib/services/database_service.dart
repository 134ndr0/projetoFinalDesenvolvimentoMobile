// Arquivo: lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/service_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('services.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Criação da tabela com a coluna deviceUuid
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        isFavorite INTEGER NOT NULL,
        deviceUuid TEXT NOT NULL
      )
    ''');
  }

  // Salva um novo serviço no banco
  Future<int> insertService(ServiceModel service) async {
    final db = await instance.database;
    return await db.insert('services', service.toMap());    
  }

  // Busca apenas os serviços vinculados ao UUID deste dispositivo
  Future<List<ServiceModel>> getServicesByUuid(String uuid) async {
    final db = await instance.database;
    
    final result = await db.query(
      'services',
      where: 'deviceUuid = ?',
      whereArgs: [uuid],
    );

    return result.map((json) => ServiceModel.fromMap(json)).toList();
  }

  // Atualiza o status de favorito no banco
  Future<int> updateService(ServiceModel service) async {
    final db = await instance.database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await instance.database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}