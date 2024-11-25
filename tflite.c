#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tensorflow/lite/c/c_api.h>

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

int main() {
    // Load the TFLite model
    const char *model_path = "embedding_model_snli.tflite";
    TfLiteModel *model = TfLiteModelCreateFromFile(model_path);
    if (!model) {
        fprintf(stderr, "Failed to load model: %s\n", model_path);
        return 1;
    }

    // Create the TensorFlow Lite interpreter
    TfLiteInterpreterOptions *options = TfLiteInterpreterOptionsCreate();
    TfLiteInterpreter *interpreter = TfLiteInterpreterCreate(model, options);
    if (!interpreter) {
        fprintf(stderr, "Failed to create interpreter\n");
        TfLiteModelDelete(model);
        return 1;
    }

    // Allocate tensors
    if (TfLiteInterpreterAllocateTensors(interpreter) != kTfLiteOk) {
        fprintf(stderr, "Failed to allocate tensors\n");
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return 1;
    }

    // Get input tensor
    TfLiteTensor *input_tensor = TfLiteInterpreterGetInputTensor(interpreter, 0);
    if (!input_tensor) {
        fprintf(stderr, "Failed to get input tensor\n");
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return 1;
    }

    // Prompt user for input text
    const int max_len = 20;
    char input_text[256];
    printf("Enter text to generate embeddings (max 255 characters): ");
    if (!fgets(input_text, sizeof(input_text), stdin)) {
        fprintf(stderr, "Failed to read input\n");
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return 1;
    }

    // Remove newline character if present
    input_text[strcspn(input_text, "\n")] = '\0';

    // Prepare input data
    int tokenized_input[max_len];
    simple_tokenizer(input_text, tokenized_input, max_len);

    if (TfLiteTensorCopyFromBuffer(input_tensor, tokenized_input, sizeof(tokenized_input)) != kTfLiteOk) {
        fprintf(stderr, "Failed to copy input data to tensor\n");
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return 1;
    }

    // Run inference
    if (TfLiteInterpreterInvoke(interpreter) != kTfLiteOk) {
        fprintf(stderr, "Failed to invoke the interpreter\n");
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return 1;
    }

    // Get output tensor
    TfLiteTensor *output_tensor = TfLiteInterpreterGetOutputTensor(interpreter, 0);
    if (!output_tensor) {
        fprintf(stderr, "Failed to get output tensor\n");
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return 1;
    }

    // Get and print output data
    int output_size = TfLiteTensorByteSize(output_tensor) / sizeof(float);
    float *output_data = malloc(output_size * sizeof(float));
    if (TfLiteTensorCopyToBuffer(output_tensor, output_data, output_size * sizeof(float)) != kTfLiteOk) {
        fprintf(stderr, "Failed to copy output data from tensor\n");
        free(output_data);
        TfLiteInterpreterDelete(interpreter);
        TfLiteModelDelete(model);
        return 1;
    }

    printf("Output embedding vector(%d):\n", output_size);
    for (int i = 0; i < output_size; i++) {
        printf("%f ", output_data[i]);
    }
    printf("\n");

    // Clean up
    free(output_data);
    TfLiteInterpreterDelete(interpreter);
    TfLiteModelDelete(model);

    return 0;
}
