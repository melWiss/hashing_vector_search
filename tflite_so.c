#include <stdio.h>
#include <stdlib.h>
#include <string.h> // Include this header for strcspn
// #include "c_embedder/tflite_embedder.h"
#include <c_embedder/tflite_embedder.h>

int main() {
    const char *model_path = "embedding_model_snli.tflite";
    TfLiteInterpreter *interpreter = load_model(model_path);
    if (!interpreter) {
        return 1;
    }

    // Prompt user for input text
    const int max_len = 20;
    char input_text[256];
    printf("Enter text to generate embeddings (max 255 characters): ");
    if (!fgets(input_text, sizeof(input_text), stdin)) {
        fprintf(stderr, "Failed to read input\n");
        return 1;
    }

    // Remove newline character using strcspn
    input_text[strcspn(input_text, "\n")] = '\0';  // Remove newline

    // Get output embeddings
    float *output_data = get_embeddings(interpreter, input_text, max_len);

    if (output_data != NULL) {
        // Print the output embedding vector
        int output_size = 16; // You should know the output size in advance
        printf("Output embedding vector(%d):\n", output_size);
        for (int i = 0; i < output_size; i++) {
            printf("%f ", output_data[i]);
        }
        printf("\n");

        // Clean up the allocated memory
        free(output_data);
    }

    // Clean up
    TfLiteInterpreterDelete(interpreter);
    return 0;
}
