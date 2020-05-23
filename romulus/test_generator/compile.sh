#!/bin/sh

cd out
gcc -c  ../encrypt.c ../skinny_reference.c 
gcc -o main.exe ../main.c ./*.o
