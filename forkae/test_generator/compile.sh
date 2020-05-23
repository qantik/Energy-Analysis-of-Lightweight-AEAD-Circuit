#!/bin/sh

cd out
gcc -c ../helpers.c ../skinny_round.c ../forkskinny.c ../paef.c 
gcc -o main.exe ../main.c ./*.o
