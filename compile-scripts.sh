gcc -o tflite_test tflite.c -ltensorflowlite_c -I/usr/local

gcc -shared -o libtflite_embedder.so -fPIC tflite_embedder.c -I/usr/local -ltensorflowlite_c

gcc -o tflite_so tflite_so.c -L./c_embedder -ltflite_embedder -I/usr/local

gcc -o tflite_so tflite_so.c -I./c_embedder -L/usr/local/lib -ltensorflowlite_c -L./c_embedder -ltflite_embedder -Wl,-rpath,/usr/local/lib -Wl,-rpath,./c_embedder

gcc -o tflite_so tflite_so.c -I/usr/local -ltensorflowlite_c -ltflite_embedder -Wl,-rpath,/usr/local/lib -Wl,-rpath