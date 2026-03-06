import '../database/database_helper.dart';
import '../models/folder.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE: Insert a new folder into the database
  Future<int> insertFolder(Folder folder) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('folders', folder.toMap());
    } catch (e) {
      print('Error inserting folder: $e');
      rethrow;
    }
  }

  // READ: Get all folders from the database
  Future<List<Folder>> getAllFolders() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'folders',
        orderBy: 'id ASC',
      );
      return List.generate(maps.length, (i) => Folder.fromMap(maps[i]));
    } catch (e) {
      print('Error fetching folders: $e');
      rethrow;
    }
  }

  // READ: Get a single folder by its ID
  Future<Folder?> getFolderById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'folders',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Folder.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error fetching folder by id: $e');
      rethrow;
    }
  }

  // UPDATE: Update an existing folder
  Future<int> updateFolder(Folder folder) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'folders',
        folder.toMap(),
        where: 'id = ?',
        whereArgs: [folder.id],
      );
    } catch (e) {
      print('Error updating folder: $e');
      rethrow;
    }
  }

  // DELETE: Delete a folder by its ID (CASCADE deletes its cards too)
  Future<int> deleteFolder(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'folders',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting folder: $e');
      rethrow;
    }
  }

  // Get the count of cards in a specific folder
  Future<int> getCardCount(int folderId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
        [folderId],
      );
      return result.first['count'] as int;
    } catch (e) {
      print('Error getting card count: $e');
      rethrow;
    }
  }
}
