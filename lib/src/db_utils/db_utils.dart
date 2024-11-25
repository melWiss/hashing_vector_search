import 'dart:convert';
import 'dart:io';

import 'package:hashing_vector_search/src/document.dart';
import 'package:hashing_vector_search/src/hash_utils/hash_utils.dart';
import 'package:hashing_vector_search/src/hash_utils/tflite_hash_utils.dart';

abstract class DbUtils {
  final File db = File('./db.json');
  final HashUtils hashUtils = TfliteHashUtils();

  String loadDbFile() {
    if (!db.existsSync()) {
      db.createSync(recursive: true);
      db.writeAsStringSync('[]');
    }
    return db.readAsStringSync();
  }

  List<Document> loadDb() {
    String dbString = loadDbFile();
    List<Document> db = (jsonDecode(dbString) as List<dynamic>)
        .map((e) => Document.fromMap(e))
        .toList();
    return db;
  }
}
