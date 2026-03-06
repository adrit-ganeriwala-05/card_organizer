import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter for the database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  // Initialize the database file and open it
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Enable foreign key support (required for CASCADE to work)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Create the Folders and Cards tables, then prepopulate data
  Future<void> _createDB(Database db, int version) async {
    // Create Folders table
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create Cards table with foreign key referencing Folders
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT NOT NULL,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    // Prepopulate folders and cards for all 4 suits
    await _prepopulateData(db);
  }

  // Insert all 4 suit folders and their 13 cards each (52 cards total)
  Future<void> _prepopulateData(Database db) async {
    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Define the 4 suits
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];

    // Card names for each suit (13 cards)
    final cardNames = [
      'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10',
      'Jack', 'Queen', 'King'
    ];

    // Mapping for the deckofcardsapi.com image URL codes
    final cardCodes = {
      'Ace': 'A', '2': '2', '3': '3', '4': '4', '5': '5',
      '6': '6', '7': '7', '8': '8', '9': '9', '10': '0',
      'Jack': 'J', 'Queen': 'Q', 'King': 'K'
    };

    // Suit code for URL (first letter)
    final suitCodes = {
      'Hearts': 'H', 'Spades': 'S', 'Diamonds': 'D', 'Clubs': 'C'
    };

    for (final suit in suits) {
      // Insert the folder for this suit
      final folderId = await db.insert('folders', {
        'folder_name': suit,
        'timestamp': timestamp,
      });

      // Insert all 13 cards for this suit
      for (final cardName in cardNames) {
        final code = cardCodes[cardName];
        final suitCode = suitCodes[suit];
        final imageUrl = 'https://deckofcardsapi.com/static/img/$code$suitCode.png';

        await db.insert('cards', {
          'card_name': cardName,
          'suit': suit,
          'image_url': imageUrl,
          'folder_id': folderId,
        });
      }
    }
  }

  // Close the database connection
  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }

  // Debug helper: print all tables and their contents
  Future<void> printDatabaseContents() async {
    final db = await instance.database;

    print('=== FOLDERS ===');
    final folders = await db.query('folders');
    for (var folder in folders) {
      print(folder);
    }

    print('=== CARDS ===');
    final cards = await db.query('cards');
    for (var card in cards) {
      print(card);
    }

    print('Total folders: ${folders.length}');
    print('Total cards: ${cards.length}');
  }
}
