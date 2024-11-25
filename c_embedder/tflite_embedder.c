#include "tflite_embedder.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Tokenizer to convert text into hashed tokens
void simple_tokenizer(const char *text, int *output, int max_len) {
    int i = 0;
    const char *word = text;

    while (*word != '\0' && i < max_len) {
        unsigned int hash = 0;
        for (int j = 0; word[j] != ' ' && word[j] != '\0'; j++) {
            hash = hash * 31 + word[j];
        }

        output[i] = hash % 10000; // Hash value
        i++;
        while (*word != ' ' && *word != '\0') word++; // Move to next word
        if (*word == ' ') word++;                     // Skip space
    }

    for (; i < max_len; i++) output[i] = 0; // Pad with zeros
}

// Function to load the model
TfLiteInterpreter* load_model(const char* model_path) {
    TfLiteModel *model = TfLiteModelCreateFromFile(model_path);
    if (!model) {
        fprintf(stderr, "Failed to load model: %s\n", model_path);
        return NULL;
    }

    TfLiteInterpreterOptions *options = TfLiteInterpreterOptionsCreate();
    TfLiteInterpreter *interpreter = TfLiteInterpreterCreate(model, options);
    if (!interpreter) {
        fprintf(stderr, "Failed to create interpreter\n");
        TfLiteModelDelete(model);
        return NULL;
    }

    if (TfLiteInterpreterAllocateTensors(interpreter) != kTfLiteOk) {
        fprintf(stderr, "Failed to allocate tensors\n");
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return NULL;
    }

    return interpreter;
}

// Function to get embeddings from text, now returns a pointer to the output data
float* get_embeddings(TfLiteInterpreter *interpreter, const char *input_text, int max_len) {
    // Prepare input data
    int tokenized_input[max_len];
    simple_tokenizer(input_text, tokenized_input, max_len);

    // Get input tensor
    TfLiteTensor *input_tensor = TfLiteInterpreterGetInputTensor(interpreter, 0);
    if (!input_tensor) {
        fprintf(stderr, "Failed to get input tensor\n");
        return NULL;
    }

    if (TfLiteTensorCopyFromBuffer(input_tensor, tokenized_input, sizeof(tokenized_input)) != kTfLiteOk) {
        fprintf(stderr, "Failed to copy input data to tensor\n");
        return NULL;
    }

    // Run inference
    if (TfLiteInterpreterInvoke(interpreter) != kTfLiteOk) {
        fprintf(stderr, "Failed to invoke the interpreter\n");
        return NULL;
    }

    // Get output tensor
    TfLiteTensor *output_tensor = TfLiteInterpreterGetOutputTensor(interpreter, 0);
    if (!output_tensor) {
        fprintf(stderr, "Failed to get output tensor\n");
        return NULL;
    }

    // Get output size and allocate memory for the output data
    int output_size = TfLiteTensorByteSize(output_tensor) / sizeof(float);
    float *output_data = (float *)malloc(output_size * sizeof(float));
    if (TfLiteTensorCopyToBuffer(output_tensor, output_data, output_size * sizeof(float)) != kTfLiteOk) {
        fprintf(stderr, "Failed to copy output data from tensor\n");
        free(output_data);
        return NULL;
    }

    return output_data; // Return the output embedding vector
}
