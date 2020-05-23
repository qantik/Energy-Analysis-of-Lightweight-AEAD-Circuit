#include <inttypes.h>


//int crypto_aead_encrypt(
//	unsigned char *c, unsigned long long *clen,
//	const unsigned char *m, unsigned long long mlen,
//	const unsigned char *ad, unsigned long long adlen,
//	const unsigned char *nsec,
//	const unsigned char *npub,
//	const unsigned char *k
//);

int crypto_aead_encrypt(
	uint8_t *ct, uint64_t *ctlen,
	uint8_t *pt, uint64_t ptlen,
	uint8_t *ad, uint64_t adlen,
	uint8_t *nsec,
	uint8_t *npub,
	uint8_t *k
);

//int crypto_aead_decrypt(
//	unsigned char *m, unsigned long long *mlen,
//	unsigned char *nsec,
//	const unsigned char *c, unsigned long long clen,
//	const unsigned char *ad, unsigned long long adlen,
//	const unsigned char *npub,
//	const unsigned char *k
//);
