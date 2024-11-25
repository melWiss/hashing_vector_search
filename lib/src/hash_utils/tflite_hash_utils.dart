import 'dart:async';

import 'package:hashing_vector_search/hashing_vector_search.dart';
import 'package:hashing_vector_search/src/tflite_embedder/tflite_embedder.dart';

class TfliteHashUtils extends HashUtils {
  final TfliteEmbedder embedder = TfliteEmbedder();
  @Deprecated('Use the hashText instead.')
  @override
  FutureOr<num> hashWord(String input) {
    return super.hashWord(input);
  }

  @override
  FutureOr<List<Document>> hashText(String input, {String? path}) {
    var h = input.toLowerCase();
    List<String> sentences = h.split(RegExp(r'''[^\w\s,'"]|\n'''));
    sentences.removeWhere((element) => element == "");
    List<Document> docs = [];
    for (var sentence in sentences) {
      sentence = sentence.trim();
      List<String> tokens = sentence.split(' ');
      List<String> words = [];
      for (var element in tokens) {
        if (words.length >= kVectorSpaceDimension) {
          docs.add(
            Document(
              path: path,
              vector: embedder.getEmbeddings(words.join(' ')),
              sentence: sentence,
            ),
          );
          words.clear();
        }
        words.add(element);
      }
      docs.add(
        Document(
          path: path,
          vector: embedder.getEmbeddings(words.join(' ')),
          sentence: sentence,
        ),
      );
    }
    return docs.toSet().toList();
  }
}
