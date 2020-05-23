CC = gcc
CFLAGS=-std=c99
DEPS = skinny_aead.h skinny_reference.h
OBJ = generate_vectors.o skinny_aead.o skinny_reference.o

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

generate_vectors: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm generate_vectors *.o

