import 'dart:convert';

import 'package:collection/collection.dart';

class Document {
  final String? path;
  final List<num> vector;
  final String? sentence;
  Document({
    this.path,
    required this.vector,
    this.sentence,
  });

  Document copyWith({
    String? path,
    List<num>? vector,
    String? sentence,
  }) {
    return Document(
      path: path ?? this.path,
      vector: vector ?? this.vector,
      sentence: sentence ?? this.sentence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'vector': vector,
      'sentence': sentence,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      path: map['path'],
      vector: List<num>.from(map['vector']),
      sentence: map['sentence'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Document.fromJson(String source) =>
      Document.fromMap(json.decode(source));

  @override
  String toString() =>
      'Document(path: $path, vector: $vector, sentence: $sentence)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Document &&
        other.path == path &&
        listEquals(other.vector, vector) &&
        other.sentence == sentence;
  }

  @override
  int get hashCode => path.hashCode ^ vector.length ^ sentence.hashCode;
}
