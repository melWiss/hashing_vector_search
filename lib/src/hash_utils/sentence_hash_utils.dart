import 'dart:async';

import 'package:hashing_vector_search/src/constants.dart';
import 'package:hashing_vector_search/src/document.dart';
import 'package:hashing_vector_search/src/hash_utils/hash_utils.dart';

class SentenceHashUtils extends HashUtils {
  @override
  FutureOr<List<Document>> hashText(String input, {String? path}) async {
    var h = input.toLowerCase();
    List<String> sentences = h.split(RegExp(r'''[^\w\s,'"]|\n'''));
    sentences.removeWhere((element) => element == "");
    List<Document> docs = [];
    for (var sentence in sentences) {
      sentence = sentence.trim();
      List<String> tokens = sentence.split(' ');
      List<num> vector = [];
      for (var element in tokens) {
        if (vector.length >= kVectorSpaceDimension) {
          docs.add(
            Document(
              path: path,
              vector: vector.toList(),
              sentence: sentence,
            ),
          );
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
        docs.add(
          Document(
            path: path,
            vector: vector.toList(),
            sentence: sentence,
          ),
        );
      }
    }
    return docs.toSet().toList();
  }
}
