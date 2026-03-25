/*
3.5e Database Companion
Copyright (C) 2026 Daniel Bender

-----------------------------------------------------------------------
AI DISCLOSURE: 
This file was developed with the assistance of Gemini Code Assist. 
AI-generated logic and boilerplate have been reviewed, refined, and 
verified by the human author for accuracy and project integration.
-----------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
*/
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/rule.dart'; // Assuming you have this model

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dnd_companion_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
      CREATE TABLE rules (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        book_name TEXT
      )
    ''');


    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ref_id INTEGER NOT NULL, -- The ID of the spell/item/feat
        type TEXT NOT NULL,      -- 'spell', 'item', 'feat', 'rule'
        name TEXT NOT NULL,      -- Cached name for display
        subtitle TEXT            -- Cached subtitle (e.g. 'Evocation', 'Weapon')
      )
    ''');
    

    await db.execute('''
      CREATE TABLE character_cache (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        data_json TEXT NOT NULL, -- Full JSON from API
        last_updated INTEGER NOT NULL
      )
    ''');
  }


  
  Future<void> cacheRules(List<Rule> rules) async {
    final db = await instance.database;
    final batch = db.batch();

    batch.delete('rules');

    for (var rule in rules) {
      batch.insert('rules', {
        'id': rule.id,
        'name': rule.name,
        'category': rule.category,
        'description': rule.description,
        'book_name': rule.bookName,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> searchRulesLocal(String query) async {
    final db = await instance.database;
    return await db.query(
      'rules',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }



  Future<void> toggleFavorite(int refId, String type, String name, String? subtitle) async {
    final db = await instance.database;
    final exists = await db.query(
      'favorites', 
      where: 'ref_id = ? AND type = ?', 
      whereArgs: [refId, type]
    );

    if (exists.isNotEmpty) {
      await db.delete('favorites', where: 'ref_id = ? AND type = ?', whereArgs: [refId, type]);
    } else {
      await db.insert('favorites', {
        'ref_id': refId,
        'type': type,
        'name': name,
        'subtitle': subtitle
      });
    }
  }
  
  Future<bool> isFavorite(int refId, String type) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites', 
      where: 'ref_id = ? AND type = ?', 
      whereArgs: [refId, type]
    );
    return result.isNotEmpty;
  }
}
