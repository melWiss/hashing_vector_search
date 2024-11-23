import 'dart:convert';

import 'package:collection/collection.dart';

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