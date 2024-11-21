import 'dart:convert';
import 'dart:io';

import 'package:hashing_vector_search/hashing_vector_search.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('either use "train" or "query" commands');
  } else if (arguments[0] == 'train') {
    TrainDbUtils trainDbUtils = TrainDbUtils(dataset: Directory('./files'));
    trainDbUtils.train();
  } else if (arguments[0] == 'query') {
    String query = arguments[1];
    // do the query;
    QueryDbUtils queryDbUtils = QueryDbUtils();
    var result = queryDbUtils.query(query, k: 8).map((e) => e.path,);
    print('The result is: ${jsonEncode(result.toSet().toList())}');
  }
}
