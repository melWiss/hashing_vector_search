import 'dart:async';

import 'package:hashing_vector_search/src/hash_utils/hash_utils.dart';
import 'package:murmur3/murmur3.dart';

class MurMur3HashUtils extends HashUtils {
  @override
  FutureOr<num> hashWord(String input) {
    var h = input.toLowerCase();
    h = h.replaceAll(r'[^a-zA-Z]', '');
    return murmur3a(h);
  }
}