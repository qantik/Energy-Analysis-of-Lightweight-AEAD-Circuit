CC = g++
CFLAGS=-std=c++11
DEPS = api.h encrypt.h gift128.h
OBJ = generate_vectors.o encrypt.o gift128.o

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

generate_vectors: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm generate_vectors *.o

