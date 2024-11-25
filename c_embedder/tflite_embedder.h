#ifndef TFLITE_EMBEDDER_H
#define TFLITE_EMBEDDER_H

#include <tensorflow/lite/c/c_api.h>

// Tokenizer to convert text into hashed tokens
void simple_tokenizer(const char *text, int *output, int max_len);

// Function to load the model
TfLiteInterpreter* load_model(const char* model_path);

// Function to get embeddings from text, now returns a pointer to the output data
float* get_embeddings(TfLiteInterpreter *interpreter, const char *input_text, int max_len);

#endif // TFLITE_EMBEDDER_H
