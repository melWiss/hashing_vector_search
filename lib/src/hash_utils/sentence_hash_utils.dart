import 'dart:async';

import 'package:hashing_vector_search/src/constants.dart';
import 'package:hashing_vector_search/src/hash_utils/hash_utils.dart';
import 'package:murmur3/murmur3.dart';

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