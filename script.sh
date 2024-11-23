#!/bin/bash

clear;
rm db.json;
dart compile exe bin/hashing_vector_search.dart -o program;
clear;
./program train;