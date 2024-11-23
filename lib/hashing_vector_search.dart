library hashing_vector_search;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:murmur3/murmur3.dart';

const int kVectorSpaceDimension = 16;

class Document {
  final String path;
  final List<num> vector;
  Document({
    required this.path,
    required this.vector,
  });

  Document copyWith({
    String? path,
    List<num>? vector,
  }) {
    return Document(
      path: path ?? this.path,
      vector: vector ?? this.vector,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'vector': vector,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      path: map['path'] ?? '',
      vector: List<num>.from(map['vector']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Document.fromJson(String source) =>
      Document.fromMap(json.decode(source));

  @override
  String toString() => 'Document(path: $path, vector: $vector)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Document &&
        other.path == path &&
        listEquals(other.vector, vector);
  }

  @override
  int get hashCode => path.hashCode ^ vector.hashCode;
}

class HashUtils {
  FutureOr<num> hashWord(String input) {
    var h = input.toLowerCase();
    h = h.replaceAll(r'[^a-zA-Z]', '');
    SplayTreeSet<String> hset = SplayTreeSet.from(h.split(''));
    num hash = 0;
    int exp = 1;
    for (var element in hset) {
      hash += pow(element.runes.first, exp++);
    }
    return hash;
  }

  FutureOr<List<List<num>>> hashText(String input) async {
    var h = input.toLowerCase();
    h = h.replaceAll(r'[^a-zA-Z]', ' ');
    List<String> tokens = h.split(' ');
    List<List<num>> vectors = [];
    List<num> vector = [];
    for (var element in tokens) {
      if (vector.length >= kVectorSpaceDimension) {
        vectors.add(vector.toList());
        vector.clear();
      }
      vector.add(await hashWord(element));
    }
    if (vector.isNotEmpty && vector.length < kVectorSpaceDimension) {
      while (vector.length < kVectorSpaceDimension) {
        vector.add(0);
      }
    }
    if (vector.length == kVectorSpaceDimension) {
      vectors.add(vector);
    }
    return vectors;
  }
}

class SentenceHashUtils extends HashUtils {
  @override
  FutureOr<num> hashWord(String input) {
    return murmur3a(input);
  }

  @override
  FutureOr<List<List<num>>> hashText(String input) async {
    var h = input.toLowerCase();
    List<String> sentences = h.split(RegExp(r'''[^\w\s,'"]|\n'''));
    sentences.removeWhere((element) => element == "");
    List<List<num>> vectors = [];
    for (var sentence in sentences) {
      List<String> tokens = sentence.split(' ');
      List<num> vector = [];
      for (var element in tokens) {
        if (vector.length >= kVectorSpaceDimension) {
          vectors.add(vector.toList());
          vector.clear();
        }
        vector.add(await hashWord(element));
      }
      if (vector.isNotEmpty && vector.length < kVectorSpaceDimension) {
        while (vector.length < kVectorSpaceDimension) {
          vector.add(0);
        }
      }
      if (vector.length == kVectorSpaceDimension) {
        vectors.add(vector);
      }
    }
    return vectors;
  }
}

class MurMur3HashUtils extends HashUtils {
  @override
  FutureOr<num> hashWord(String input) {
    var h = input.toLowerCase();
    h = h.replaceAll(r'[^a-zA-Z]', '');
    return murmur3a(h);
  }
}

abstract class DbUtils {
  final File db = File('./db.json');
  final HashUtils hashUtils = SentenceHashUtils();

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

class TrainDbUtils extends DbUtils {
  final Directory dataset;
  TrainDbUtils({required this.dataset});

  FutureOr<void> train() async {
    List<Document> data = loadDb();
    List<FileSystemEntity> trainFiles = dataset.listSync();
    for (var element in trainFiles) {
      print('TRAINGING ON:: ${element.path}');
      File file = File(element.path);
      List<List<num>> vectors =
          await hashUtils.hashText(file.readAsStringSync());
      data.addAll(vectors.map(
        (e) => Document(path: element.path, vector: e),
      ));
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

class QueryDbUtils extends DbUtils {
  FutureOr<List<Document>> query(String query, {int? k}) async {
    List<Document> data = loadDb();
    return kNearestNeighbors(
        documents: data, target: (await hashUtils.hashText(query)).first, k: k);
  }

  /// Finds the k closest vectors to a target vector using k-NN.
  ///
  /// [vectors]: List of vectors where each vector is a List<num>.
  /// [target]: The target vector to compare against.
  /// [k]: The number of closest vectors to find.
  ///
  /// Returns a List of the k closest vectors (sorted by distance).
  List<Document> kNearestNeighbors({
    required List<Document> documents,
    required List<num> target,
    int? k,
  }) {
    k ??= documents.length;
    if (k <= 0 || k > documents.length) {
      throw ArgumentError(
          'k must be between 1 and the size of the vector list. k = $k, documents.length = ${documents.length}');
    }

    // Calculate distances between the target vector and each vector in the list.
    List<MapEntry<Document, num>> distances = documents.map((vector) {
      num distance = _euclideanDistance(vector.vector, target);
      return MapEntry(vector, distance);
    }).toList();

    // Sort vectors by their distance from the target vector.
    distances.sort((a, b) => a.value.compareTo(b.value));

    // Return the k closest vectors.
    return distances.take(k).map((entry) => entry.key).toList();
  }

  /// Calculates the Euclidean distance between two vectors.
  num _euclideanDistance(List<num> a, List<num> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same dimensions.');
    }

    return sqrt(
      a
          .asMap()
          .entries
          .map((entry) => pow(entry.value - b[entry.key], 2))
          .reduce((sum, value) => sum + value),
    );
  }
}
