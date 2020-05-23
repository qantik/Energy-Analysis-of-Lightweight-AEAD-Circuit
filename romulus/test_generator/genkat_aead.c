#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>
#include <string.h>

#include "crypto_aead.h"
#include "api.h"

#define KAT_SUCCESS          0
#define KAT_FILE_OPEN_ERROR -1
#define KAT_DATA_ERROR      -3
#define KAT_CRYPTO_FAILURE  -4

#define MAX_FILE_NAME				256
#define MAX_MESSAGE_LENGTH			32
#define MAX_ASSOCIATED_DATA_LENGTH	32

void init_buffer(unsigned char *buffer, unsigned long long numbytes);

void fprint_bstr(FILE *fp, const char *label, const unsigned char *data, unsigned long long length);

int generate_test_vectors();

int main()
{
	int ret = generate_test_vectors();

	if (ret != KAT_SUCCESS) {
		fprintf(stderr, "test vector generation failed with code %d\n", ret);
	}

	return ret;
}

int generate_test_vectors()
{
	FILE                *fp;
	char                fileName[MAX_FILE_NAME];
	unsigned char       key[CRYPTO_KEYBYTES];
	unsigned char		nonce[CRYPTO_NPUBBYTES];
	unsigned char       msg[MAX_MESSAGE_LENGTH];
	unsigned char       msg2[MAX_MESSAGE_LENGTH];
	unsigned char		ad[MAX_ASSOCIATED_DATA_LENGTH];
	unsigned char		ct[MAX_MESSAGE_LENGTH + CRYPTO_ABYTES];
	unsigned long long  clen, mlen2;
	int                 count = 1;
	int                 func_ret, ret_val = KAT_SUCCESS;

	init_buffer(key, sizeof(key));
	init_buffer(nonce, sizeof(nonce));
	init_buffer(msg, sizeof(msg));
	init_buffer(ad, sizeof(ad));

	sprintf(fileName, "LWC_AEAD_KAT_%d_%d.txt", (CRYPTO_KEYBYTES * 8), (CRYPTO_NPUBBYTES * 8));

	if ((fp = fopen(fileName, "w")) == NULL) {
		fprintf(stderr, "Couldn't open <%s> for write\n", fileName);
		return KAT_FILE_OPEN_ERROR;
	}

	for (unsigned long long mlen = 0; (mlen <= MAX_MESSAGE_LENGTH) && (ret_val == KAT_SUCCESS); mlen++) {
	  //for (unsigned long long mlen = 0; (mlen <= 32) && (ret_val == KAT_SUCCESS); mlen++) {
	  for (unsigned long long adlen = 0; adlen <= MAX_ASSOCIATED_DATA_LENGTH; adlen++) {
	    //for (unsigned long long adlen = 0; adlen <= 32; adlen++) {

	    printf("%0d\n", (int)clen);

			fprintf(fp, "Count = %d\n", count++);
			printf("Count = %d\n", count - 1);

			fprint_bstr(fp, "Key = ", key, CRYPTO_KEYBYTES);

			fprint_bstr(fp, "Nonce = ", nonce, CRYPTO_NPUBBYTES);

			fprint_bstr(fp, "PT = ", msg, mlen);

			fprint_bstr(fp, "AD = ", ad, adlen);

			if ((func_ret = crypto_aead_encrypt(ct, &clen, msg, mlen, ad, adlen, NULL, nonce, key)) != 0) {
				fprintf(fp, "crypto_aead_encrypt returned <%d>\n", func_ret);
				ret_val = KAT_CRYPTO_FAILURE;
				break;
			}
			
			fprint_bstr(fp, "CT = ", ct, clen);

			fprintf(fp, "\n");

			 if ((func_ret = crypto_aead_decrypt(msg2, &mlen2, NULL, ct, clen, ad, adlen, nonce, key)) != 0) { 
			 	fprintf(fp, "crypto_aead_decrypt returned <%d>\n", func_ret); 
			 	ret_val = KAT_CRYPTO_FAILURE; 
			 	break; 
			 } 

			 if (mlen != mlen2) { 
			 	fprintf(fp, "crypto_aead_decrypt returned bad 'mlen': Got <%llu>, expected <%llu>\n", mlen2, mlen); 
			 	ret_val = KAT_CRYPTO_FAILURE; 
			 	break; 
			 } 

			 if (memcmp(msg, msg2, mlen)) { 
			 	fprintf(fp, "crypto_aead_decrypt did not recover the plaintext\n"); 
			 	ret_val = KAT_CRYPTO_FAILURE; 
			 	break; 
			 } 
		}
	}

	fclose(fp);

	return ret_val;
}


void fprint_bstr(FILE *fp, const char *label, const unsigned char *data, unsigned long long length)
{    
    fprintf(fp, "%s", label);
        
	for (unsigned long long i = 0; i < length; i++)
		fprintf(fp, "%02X", data[i]);
	    
    fprintf(fp, "\n");
}

void init_buffer(unsigned char *buffer, unsigned long long numbytes)
{
	for (unsigned long long i = 0; i < numbytes; i++)
		buffer[i] = (unsigned char)i;
}
