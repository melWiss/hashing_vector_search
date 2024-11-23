import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:hashing_vector_search/src/constants.dart';

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