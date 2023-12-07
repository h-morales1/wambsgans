import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

/*
    Class handles data transactions with local
    sql db

    Schema is defined below
 */

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    content TEXT
    )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'entries.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createEntry(String title, String? content) async {
    final db = await SQLHelper.db(); // fetch  db

    final data = {'title': title, 'content': content}; // what will be inserted
    final id = await db.insert('entries', data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  /*
    Get multiple entries
   */
  static Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await SQLHelper.db();
    return db.query('entries', orderBy: "id");
  }

  /*
    Get only one entry
   */
  static Future<List<Map<String, dynamic>>> getEntry(int id) async {
    final db = await SQLHelper.db();
    return db.query('entries', where: "id = ?", whereArgs: [id], limit: 1);
  }

  /*
    Update an entry based on its id
   */
 static Future<int> updateEntry(
     int id, String title, String? content
     ) async {

    final db = await SQLHelper.db();

    // what will be saved
    final data = {
      'title': title,
      'content': content
    };

    // update db
    final result = await db.update('entries', data, where: "id = ?", whereArgs: [id]);
    return result;
 }

 /*
  Delete an entry based on its id
  */
 static Future<void> deleteEntry(int id) async {
   final db = await SQLHelper.db();

   try {
     await db.delete("entries", where: "id = ?", whereArgs: [id]);
   } catch (err) {
     debugPrint("Error attempting to delete an item: $err");
   }
 }

}