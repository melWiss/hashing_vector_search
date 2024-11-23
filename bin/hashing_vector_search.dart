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
    var jsonEncoder = JsonEncoder.withIndent('  ');
    String query = arguments[1];
    // do the query;
    QueryDbUtils queryDbUtils = QueryDbUtils();
    int k = 10;
    int indexk = arguments.indexOf("k");
    if (indexk != -1) {
      k = int.parse(arguments[indexk + 1]);
    }
    var docs = await queryDbUtils.query(query, k: k);
    List<Map<String, dynamic>> docsObject = docs
        .map<Map<String, dynamic>>(
          (e) => e.toMap(),
        )
        .toList();
    print('The results for: "$query"');
    print(jsonEncoder.convert(docsObject));
  }
}
