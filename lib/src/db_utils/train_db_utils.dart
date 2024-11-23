import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hashing_vector_search/src/db_utils/db_utils.dart';
import 'package:hashing_vector_search/src/document.dart';

class TrainDbUtils extends DbUtils {
  final Directory dataset;
  TrainDbUtils({required this.dataset});

  FutureOr<void> train() async {
    List<Document> data = loadDb();
    List<FileSystemEntity> trainFiles = dataset.listSync();
    for (var element in trainFiles) {
      print('TRAINGING ON:: ${element.path}');
      File file = File(element.path);
      List<Document> docs = await hashUtils.hashText(
        file.readAsStringSync(),
        path: element.path,
      );
      data.addAll(docs);
      print('FINISHED TRAINING ON:: ${element.path}');
    }
    writeDb(data);
    print('DONE TRAINGING!!!##k=${data.length}');
  }

  void writeDb(List<Document> data) {
    List<Map<String, dynamic>> dbList = data
        .map(
          (e) => e.toMap(),
        )
        .toList();
    db.writeAsStringSync(jsonEncode(dbList));
  }
}
