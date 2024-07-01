import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper{

  static Future<void> createTables(sql.Database database)async{
    await database.execute(
        '''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
          '''
    );
  }

  static Future<sql.Database> db() async{
    return sql.openDatabase(
      'db_test.sql',
      version: 1,
      onCreate: (sql.Database database, int version)async{
        print("..creating table..");
        await createTables(database);
      }
    );
  }

  static Future<int> createItem(String? title, String? description)async{
    final db = await SqlHelper.db();

    final data = {'title': title, 'description' : description};
    final id = await db.insert('items', data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems()async{
    final db = await SqlHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(id) async{
    final db = await SqlHelper.db();
    return db.query('item', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String description)async{

    final db = await SqlHelper.db();
    final data = {
      'title' : title,
      'description' : description,
      'createdAt' : DateTime.now().toString()
    };
    final result = await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async{
    final db = await SqlHelper.db();
    try{
      await db.delete('items', where: "id = ?", whereArgs: [id]);
    }catch(err){
      debugPrint("Something went Wrong when deleting an item : $err");
    }
  }
}