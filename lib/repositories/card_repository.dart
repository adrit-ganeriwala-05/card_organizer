import '../database/database_helper.dart';
import '../models/card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE: Insert a new card into the database
  Future<int> insertCard(PlayingCard card) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('cards', card.toMap());
    } catch (e) {
      print('Error inserting card: $e');
      rethrow;
    }
  }

  // READ: Get all cards belonging to a specific folder
  Future<List<PlayingCard>> getCardsByFolderId(int folderId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cards',
        where: 'folder_id = ?',
        whereArgs: [folderId],
        orderBy: 'id ASC',
      );
      return List.generate(maps.length, (i) => PlayingCard.fromMap(maps[i]));
    } catch (e) {
      print('Error fetching cards: $e');
      rethrow;
    }
  }

  // READ: Get a single card by its ID
  Future<PlayingCard?> getCardById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cards',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return PlayingCard.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error fetching card by id: $e');
      rethrow;
    }
  }

  // READ: Get all cards from every folder
  Future<List<PlayingCard>> getAllCards() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cards',
        orderBy: 'folder_id ASC, id ASC',
      );
      return List.generate(maps.length, (i) => PlayingCard.fromMap(maps[i]));
    } catch (e) {
      print('Error fetching all cards: $e');
      rethrow;
    }
  }

  // UPDATE: Update an existing card
  Future<int> updateCard(PlayingCard card) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'cards',
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    } catch (e) {
      print('Error updating card: $e');
      rethrow;
    }
  }

  // DELETE: Delete a card by its ID
  Future<int> deleteCard(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'cards',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting card: $e');
      rethrow;
    }
  }

  // Search cards by name across all folders
  Future<List<PlayingCard>> searchCardsByName(String query) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cards',
        where: 'card_name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'card_name ASC',
      );
      return List.generate(maps.length, (i) => PlayingCard.fromMap(maps[i]));
    } catch (e) {
      print('Error searching cards: $e');
      rethrow;
    }
  }
}
