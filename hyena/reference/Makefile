CC = g++
CFLAGS = -std=c++11

DEPS = api.h hyena.h crypto_aead.h
OBJ = gift-128.o encrypt.o generate_vectors.o

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

generate_vectors: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	@rm generate_vectors *.o

