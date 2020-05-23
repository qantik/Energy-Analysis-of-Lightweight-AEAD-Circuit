CC = g++
CFLAGS=-std=c++0x

DEPS = api.h gift128.h sundae.h
OBJ = generate_vectors_new.o gift128.o sundae.o

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

generate_vectors: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm generate_vectors *.o

