import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safespine/services/models.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  late Database _db;

  static const String formTable = 'forms';
  static const String answerTable = 'answers';

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await _onCreateForms(db, version);
    await _onCreateAnswers(db, version);
  }

// answers
  Future _onCreateAnswers(Database db, int version) async {
    await db.execute('''
          CREATE TABLE answers (
            formID TEXT NOT NULL,
            questionID TEXT NOT NULL,
            response TEXT NOT NULL,
            PRIMARY KEY(formID, questionID)
          )
          ''');
  }

  Future _onCreateForms(Database db, int version) async {
    await db.execute('''
          CREATE TABLE forms (
            id TEXT NOT NULL PRIMARY KEY,
            dateCompleted INTEGER,
            dateReceived INTEGER,
            dateStarted INTEGER,
            form_type TEXT NOT NULL,
            hospital TEXT NOT NULL,
            title TEXT NOT NULL,
            user TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  Future<Form?> retrieveForm(String id) async {
    final Map<String, dynamic>? metadata = await getMetadata(id);

    if (metadata == null) {
      return null;
    }

    final Map<String, String> answers = await getAnswers(id);

    final Form form = Form.fromMap(metadata);
    form.answers = answers;

    return form;
  }

  Future<int> saveForm(Form form) async {
    final List<Map<String, String>> answers = form.answersToMap();

    for (var answer in answers) {
      if (await answerExistsWith(form.id, answer['questionID']!)) {
        updateAnswer(answer);
      } else {
        insertAnswer(answer);
      }
    }

    if (await formExistsWith(form.id)) {
      return await update(form);
    } else {
      return await insert(form);
    }
  }

  Future<int> saveAnswer(Map<String, String> answer) async {
    final formID = answer['formID']!;
    final questionID = answer['questionID']!;
    if (await answerExistsWith(formID, questionID)) {
      return await updateAnswer(answer);
    } else {
      return await insertAnswer(answer);
    }
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Form row) async {
    return await _db.insert(formTable, row.metadataToMap());
  }

  Future<int> insertAnswer(Map<String, String> answer) async {
    return await _db.insert(answerTable, answer);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllForms() async {
    return await _db.query(formTable);
  }

  Future<List<Map<String, dynamic>>> queryAllAnswers() async {
    return await _db.query(answerTable);
  }

  Future<bool> formExistsWith(String id) async {
    return (await getMetadata(id)) != null;
  }

  Future<Map<String, dynamic>?> getMetadata(String id) async {
    final results = await _db.query(formTable,
        columns: ["id"], where: 'id = ?', whereArgs: [id]);
    return results.first;
  }

  Future<Map<String, String>> getAnswers(String id) async {
    final results = await _db.query(answerTable,
        columns: ["questionID", "response"],
        where: 'formID = ?',
        whereArgs: [id]);
    final Map<String, String> answers = {};
    for (var item in results) {
      final String questionID = item['questionID'] as String;
      answers[questionID] = item['response'] as String;
    }
    return answers;
  }

  Future<bool> answerExistsWith(String formID, String questionID) async {
    final results = await _db.query(answerTable,
        columns: ["response"],
        where: 'formID = ? AND questionID = ?',
        whereArgs: [formID, questionID]);
    return results.isNotEmpty;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryFormRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $formTable');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> queryAnswersRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $answerTable');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Form row) async {
    String id = row.id;
    return await _db.update(
      formTable,
      row.metadataToMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateAnswer(Map<String, String> answer) async {
    String formID = answer['formID']!;
    String questionID = answer['questionID']!;

    return await _db.update(
      answerTable,
      answer,
      where: 'formID = ? AND questionID = ?',
      whereArgs: [formID, questionID],
    );
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> deleteForm(String id) async {
    await _db.delete(
      answerTable,
      where: 'formID = ?',
      whereArgs: [id],
    );

    return await _db.delete(
      formTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAnswer(String formID, String questionID) async {
    return await _db.delete(
      answerTable,
      where: 'formID = ? AND questionID = ?',
      whereArgs: [formID, questionID],
    );
  }
}
