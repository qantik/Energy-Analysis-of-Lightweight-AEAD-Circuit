#include<stdio.h>
#include <stdlib.h>
#include<time.h>
#include "api.h"
#include "crypto_aead.h"
#define TEST_NUMBER 0

void random_aead_gen(unsigned char *c,	
    unsigned char *m, unsigned long long *mlen,
	unsigned char *ad, unsigned long long *adlen,
	unsigned char *npub,
	unsigned char *k, unsigned char *incomplete_ad, unsigned char*incomplete_m, int j ) {

    int i;
    do {
        *mlen = (unsigned long long) rand()%5;
        *adlen = (unsigned long long) rand()%5;    
    } while (*adlen + *mlen == 0);
    //*adlen = 1;
    //*mlen = 1;

    *incomplete_ad = rand()%2 == 0 ? 0x00 : 0x01;
    *incomplete_m = rand()%2 == 0 ? 0x00 : 0x01;

    //printf("mlen = %d\n", (int) *mlen);
    //printf("adlen = %d\n", (int) *adlen);
    for(i=0; i<16; i++) npub[i] = rand() % 256;
    for(i=0; i<16; i++) k[i] = rand() % 256;
    for(i=0; i<16*(*mlen); i++) m[i] = rand() % 256;
    for(i=0; i<16*(*adlen); i++) ad[i] = rand() % 256;
    
	unsigned long long m_len = (*mlen) * 16;
	unsigned long long ad_len = (*adlen) * 16;
    unsigned long long clen;
    // make ad half-complete
    if (*incomplete_ad == 0x01 && *adlen >0) {
    	for(i=16*(*adlen - 1) + 8; i<16*(*adlen); i++) ad[i] = 0x00;
    	ad[16*(*adlen)-1]= 0x08; // this is romulus padding for 8 bytes
		ad_len -= 8;
	}
	if (*incomplete_m == 0x01 && *mlen >0) {
		for(i=16*(*mlen - 1) + 8; i<16*(*mlen); i++) m[i] = 0x00;
		m[16*(*mlen)-1] = 0x08;
		m_len -= 8;
	}
    

    int res = 0;
    if (j >= TEST_NUMBER) {
        printf("\n\n=====================starting a new encryption below=====================\n%d\n", j); 
        crypto_aead_encrypt(c, &clen, m, m_len, ad, ad_len, NULL, npub, k);
        printf("\n\n");

        // process it for testbench
        if (*incomplete_m == 0x01 && *mlen >0) {
        for (i=0; i<16; i++)
            c[clen+7-i] = c[clen-1-i];
        }        
    }


    //int res = paef_encrypt(c, m, m_len, ad, ad_len, npub, k);
    //for(i=16*(*adlen + *mlen -1) + 8; i<16*(*adlen + *mlen); i++) c[i] = 0x00;
    //for(i=0;i<128;i++) printf("%02X", c[i]); printf("\n");
    if (res == -1) exit(1);
}


void save_aead(FILE *in, FILE* out,
    unsigned char *c, unsigned char *m, unsigned long long *mlen,
	unsigned char *ad, unsigned long long *adlen,
	unsigned char *npub,
	unsigned char *k, unsigned char* incomplete_ad, unsigned char* incomplete_m) {
	unsigned int i,j;
	//forkEncrypt(C0, C1, PT, tweakey, (enum encrypt_selector) ENC_BOTH);
	fprintf(in, "%d\n", (int) *adlen);
	fprintf(in, "%d\n", (int) *mlen);
	fprintf(in, "%d\n", (int) *incomplete_ad);
	fprintf(in, "%d\n", (int) *incomplete_m);
	for(i=0;i<16;i++) fprintf(in, "%02X", npub[i]); fprintf(in, "\n");
	for(i=0;i<16;i++) fprintf(in, "%02X", k[i]); fprintf(in, "\n");
	for(j=0;j<*adlen;j++) { for(i=16*j;i<16*(j+1);i++) fprintf(in, "%02X", ad[i]); fprintf(in, "\n"); }
	for(j=0;j<*mlen;j++) { for(i=16*j;i<16*(j+1);i++) fprintf(in, "%02X", m[i]); fprintf(in, "\n"); }
	
	for(j=0;j<(*mlen)+1;j++) { for(i=16*j;i<16*(j+1);i++) fprintf(out, "%02X", c[i]); fprintf(out, "\n"); }

}

int main() {

	FILE *in0 = fopen("test_vectors/in_aead", "w");
	//FILE *in1 = fopen("test_vectors/in_both", "w");
	//FILE *out0 = fopen("test_vectors/out_paef_swapped", "w");
	FILE *out1 = fopen("test_vectors/out_aead", "w");
    
    unsigned char m[64]; // so we can accommodate 4 block
    unsigned char c[160]; // 8 blocks at most
    unsigned char k[16];
    unsigned char ad[64];
    unsigned char npub[16]; 
    
    unsigned long long mlen, adlen;
    
    unsigned char tweakey[48];
    unsigned char incomplete_ad, incomplete_m;
    int i,j;
   	
	for(j=0; j<15; j++) {
	    random_aead_gen(c, m, &mlen, ad, &adlen, npub, k, &incomplete_ad, &incomplete_m, j);
        if (j >= TEST_NUMBER) {
            save_aead(in0, out1, c, m, &mlen, ad, &adlen, npub, k, &incomplete_ad, &incomplete_m);
            }
	}
	
		
	
	fclose(in0);
	//fclose(in1);
	fclose(out1);
	//fclose(out1);        
    
}
