import 'dart:async';
import 'dart:math';

import 'package:hashing_vector_search/src/db_utils/db_utils.dart';
import 'package:hashing_vector_search/src/document.dart';

class QueryDbUtils extends DbUtils {
  FutureOr<List<Document>> query(String query, {int? k}) async {
    List<Document> data = loadDb();
    return kNearestNeighbors(
        documents: data, target: (await hashUtils.hashText(query)).first, k: k);
  }

  /// Finds the k closest vectors to a target vector using k-NN.
  ///
  /// [vectors]: List of vectors where each vector is a List<num>.
  /// [target]: The target vector to compare against.
  /// [k]: The number of closest vectors to find.
  ///
  /// Returns a List of the k closest vectors (sorted by distance).
  List<Document> kNearestNeighbors({
    required List<Document> documents,
    required List<num> target,
    int? k,
  }) {
    k ??= documents.length;
    if (k <= 0 || k > documents.length) {
      throw ArgumentError(
          'k must be between 1 and the size of the vector list. k = $k, documents.length = ${documents.length}');
    }

    // Calculate distances between the target vector and each vector in the list.
    List<MapEntry<Document, num>> distances = documents.map((vector) {
      num distance = _euclideanDistance(vector.vector, target);
      return MapEntry(vector, distance);
    }).toList();

    // Sort vectors by their distance from the target vector.
    distances.sort((a, b) => a.value.compareTo(b.value));

    // Return the k closest vectors.
    return distances.take(k).map((entry) => entry.key).toList();
  }

  /// Calculates the Euclidean distance between two vectors.
  num _euclideanDistance(List<num> a, List<num> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same dimensions.');
    }

    return sqrt(
      a
          .asMap()
          .entries
          .map((entry) => pow(entry.value - b[entry.key], 2))
          .reduce((sum, value) => sum + value),
    );
  }
}
