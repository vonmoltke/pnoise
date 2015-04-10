#!/bin/bash
gcc -std=c99 -march=native -msse3 -mfpmath=sse -O3 -o bin_test_c_gcc test.c -lm
clang -std=c99 -march=native -msse3 -mfpmath=sse -O3 -o bin_test_c_clang test.c -lm
dmd -ofbin_test_d_dmd -O -boundscheck=off -inline -release test.d
gdc -Ofast -o bin_test_d_gdc test.d -frelease -finline -march=native -fno-bounds-check
gccgo -O3 -g -o bin_test_go_gccgo test.go
go build -o bin_test_go_gc test.go
mcs -out:bin_test_cs test.cs
javac test.java
