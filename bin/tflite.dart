import 'package:hashing_vector_search/src/tflite_embedder/tflite_embedder.dart';

void main(List<String> args) {
  TfliteEmbedder embedder = TfliteEmbedder();
  print(embedder.getEmbeddings(args.first));
}