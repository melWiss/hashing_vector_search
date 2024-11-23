import 'dart:convert';
import 'dart:io';

import 'package:hashing_vector_search/hashing_vector_search.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('either use "train" or "query" commands');
  } else if (arguments[0] == 'train') {
    TrainDbUtils trainDbUtils = TrainDbUtils(dataset: Directory('./files'));
    await trainDbUtils.train();
  } else if (arguments[0] == 'query') {
    String query = arguments[1];
    // do the query;
    QueryDbUtils queryDbUtils = QueryDbUtils();
    var docs = await queryDbUtils.query(query, k: 5);
    var paths = docs.map((e) => e.path);
    // var vectors = docs.map((e) => e.vector);
    print('The result paths is: ${jsonEncode(paths.toSet().toList())}');
    // print('The result vectors is: ${jsonEncode(vectors.toSet().toList())}');
  }
}
