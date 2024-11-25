import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:hashing_vector_search/src/tflite_embedder/tflite_embedder_bindings.dart';

class TfliteEmbedder {
  final TFLiteEmbedderBindings bindings = TFLiteEmbedderBindings(
      DynamicLibrary.open('c_embedder/libtflite_embedder.so'));

  List<double> getEmbeddings(String text) {
    String model = 'embedding_model_snli.tflite';
    Pointer<Char> modelPointer = calloc.allocate(model.length);
    Pointer<Char> textPointer = calloc.allocate(text.length);
    for (var i = 0; i < model.length; i++) {
      modelPointer[i] = model.codeUnitAt(i);
    }
    for (var i = 0; i < text.length; i++) {
      textPointer[i] = text.codeUnitAt(i);
    }
    Pointer<Float> embeddings = bindings.get_embeddings(
      bindings.load_model(modelPointer),
      textPointer,
      20,
    );

    return embeddings.asTypedList(16).toList();
  }
}
