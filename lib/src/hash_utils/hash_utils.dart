import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:hashing_vector_search/src/constants.dart';
import 'package:hashing_vector_search/src/document.dart';

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

  FutureOr<List<Document>> hashText(String input, {String? path}) async {
    var h = input.toLowerCase();
    h = h.replaceAll(r'[^a-zA-Z]', ' ');
    List<String> tokens = h.split(' ');
    List<Document> docs = [];
    List<num> vector = [];
    for (var element in tokens) {
      if (vector.length >= kVectorSpaceDimension) {
        docs.add(
          Document(
            path: path,
            vector: vector.toList(),
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
        ),
      );
    }
    return docs;
  }
}
