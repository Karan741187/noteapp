import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'crud_exceptions.dart';



class NotesService {
  Database? _db;
  
  Future<DatabaseNote> updateNote({required DatabaseNote note,required String text,}) async{
    final db=_getDatabaseOrThrow();
    await getNote(id: note.id);
    
    final updatesCount=await db.update(noteTable, {
      textColumn:text,
      isSyncedWithCloudColumn:0,
    });
    if(updatesCount ==0) throw CouldNotUpdateNote();
    return await getNote(id: note.id);
  }
  
  Future<Iterable<DatabaseNote>> getAllNotes() async{
    final db=_getDatabaseOrThrow();
    final notes=await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));

  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db=_getDatabaseOrThrow();
    final notes=await db.query(noteTable,
    limit: 1,
      where:'id = ?',
      whereArgs: [id],
    );
    if(notes.isEmpty) throw CouldNotFindNote();
    return DatabaseNote.fromRow(notes.first);
  }

  Future<int> deleteAllNotes()async{
    final db=_getDatabaseOrThrow();
    return await db.delete(noteTable);
  }
  
  Future<void> deleteNote({required int id}) async{
    final db=_getDatabaseOrThrow();

    final deleteCount =await db.delete(noteTable,
      where:'id = ?',
      whereArgs:[id],
    );
    if(deleteCount ==0) {
      throw CoulNotDeleteNote();
    }
  }
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
//Make sure owner exists in db with correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw CouldNotFindUser();

    const text = '';
    //create the note
    final noteId = await db.insert(noteTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1});
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);

      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[""] as String;

  @override
  String toString() => 'Person, Id=$id, email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;
  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[""] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID=$id,userId=$userId ,isSyncedWithCloud = $isSyncedWithCloud,text=$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
                                  "id"	INTEGER NOT NULL,
                                  "email"	TEXT NOT NULL UNIQUE,
                                  PRIMARY KEY("id" AUTOINCREMENT)
                                );
                                ''';
const createNoteTable = ''' CREATE TABLE IF NOT EXISTS "note" (
                                "id"	INTEGER NOT NULL COLLATE UTF16CI,
                                "user_id"	INTEGER NOT NULL,
                                "text"	TEXT NOT NULL,
                                "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
                                PRIMARY KEY("id" AUTOINCREMENT),
                                FOREIGN KEY("user_id") REFERENCES "user"("id")
                              );''';