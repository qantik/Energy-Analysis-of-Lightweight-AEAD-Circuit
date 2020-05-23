#include <iostream>
#include <algorithm>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "api.h"
#include "gift128.h"
#include "sundae.h"

void random_bytes(const size_t n, uint8_t *dest) {
    for (int i = 0; i < n; i++) {
    	dest[i] = rand();		
    }
    return;
}

void pad(uint8_t *input, const size_t in_len, uint8_t *output, const size_t out_len) {
    for (int i = 0; i < in_len; i++) {
	output[i] = input[i];
    }
    if (in_len % 16 != 0) {
	output[in_len] = 0x80;
	for (int i =in_len+1; i < out_len; i++) {
		output[i] = 0;
	}
    }
    return; 
}

void output(int index, size_t ad_bytes, size_t msg_bytes, int partial_ad, int partial_msg,
            uint8_t key[16], uint8_t *ad, uint8_t *msg, uint8_t *cipher) {

    size_t ad_blocks = (ad_bytes / 16);
    size_t msg_blocks = (msg_bytes / 16);

    printf("%d %d %d %d %d\n", index, ad_blocks, msg_blocks, partial_ad, partial_msg);
    
    for (int i = 0; i < 16; i++) {
    	printf("%02X", key[i]);
    }
    putchar('\n');

   for (int b = 0; b < ad_blocks; b++) {
        for (int i = b*16; i < (b+1)*16; i++) {
            printf("%02X", ad[i]);
        }
        putchar('\n');
    }

    for (int b = 0; b < msg_blocks; b++) {
        for (int i = b*16; i < (b+1)*16; i++) {
            printf("%02X", msg[i]);
        }
        putchar('\n');
    }

    for (int i = 0; i < 16; i++) {
    	printf("%02X", cipher[i]);
    }
    putchar('\n');
    
    for (int b = 0; b < msg_blocks; b++) {
        for (int i = b*16; i < (b+1)*16; i++) {
            printf("%02X", msg[i]);
        }
        putchar(' ');
        for (int i = b*16; i < (b+1)*16; i++) {
            printf("%02X", cipher[i+16]);
        }
        putchar('\n');
    }
}

int main(int argc, char **argv) {
  srand (time(NULL));

  //uint8_t k[16] = {0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf};
  //uint8_t n[16] = {0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf};
  ////uint8_t k[16] = {0xf, 0xe, 0xd, 0xc, 0xb, 0xa, 0x9, 0x8, 0x7, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1, 0x0};
  ////uint8_t n[16] = {0xf, 0xe, 0xd, 0xc, 0xb, 0xa, 0x9, 0x8, 0x7, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1, 0x0};
  //uint8_t ad[16] = {0x0, 0x1, 0x2, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
  //uint8_t msg[16] = {0x0, 0x1, 0x2, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
  //uint8_t ad[16] = {0};
  ////uint8_t msg[16] = {0xf, 0xe, 0xd, 0xc, 0xb, 0xa, 0x9, 0x8, 0x7, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1, 0x0};
  //uint8_t msg[16] = {0};

  //std::reverse(std::begin(k), std::end(k));
  //std::reverse(std::begin(n), std::end(n));
  //std::reverse(std::begin(ad), std::end(ad));
  //std::reverse(std::begin(msg), std::end(msg));

  //uint8_t c[32] = {0};

  //cofb_encrypt(c, k, n, ad, 3, msg, 3);
  ////////giftb128(msg, k, c);

  //for (int i = 0; i < 16; i++) {
  //  printf("%02X", c[i]);
  //}
  //putchar('\n');
  //for (int i = 16; i < 32; i++) {
  //  printf("%02X", c[i]);
  //}
  //putchar('\n');
  //
  //uint8_t vec[16]; 
  //for (int i = 0; i < 1000; i++) {
  //      random_bytes(16, vec);
  //      for (int j = 0; j < 16; j++) {
  //      	printf("%02X", vec[j]);
  //      }
  //      putchar('\n');
  //}

  //argv++;
  //int n = atoi(argv[0]);
  //int num_ad = atoi(argv[1]);
  //int num_msg = atoi(argv[2]);

  //size_t ad_size = 16*num_ad;
  //size_t msg_size = 16*num_msg;
  //size_t cipher_size = msg_size+16;
  
  for (int i = 0; i < 1000; i++) {
      uint8_t key[16]; random_bytes(16, key); 
      uint8_t nonce_bytes = 12;//rand() % 2 == 1 ? 12 : 0;

      uint8_t nonce[nonce_bytes]; random_bytes(12, nonce);
        
      uint16_t ad_bytes      = 4;//nonce_bytes == 0 ? 0 : rand() % 49;
      uint16_t ad_full_bytes = nonce_bytes + ad_bytes;
      uint16_t msg_bytes     = 16;//rand() % 49;
      
      //printf("%d %d\n", ad_bytes, msg_bytes);
  	
      uint8_t ad[ad_bytes]; random_bytes(ad_bytes, ad);
      uint8_t msg[msg_bytes]; random_bytes(msg_bytes, msg);

      //printf("nonce ad msg  ");
      //for (int j = 0; j < nonce_bytes; j++) {
      //  printf("%02X", nonce[j]);
      //}
      //putchar('\n');
      //for (int j = 0; j < ad_bytes; j++) {
      //  printf("%02X", ad[j]);
      //}
      //putchar('\n');
      //for (int j = 0; j < msg_bytes; j++) {
      //  printf("%02X", msg[j]);
      //}
      //putchar('\n');

      int partial_ad  = (ad_full_bytes % 16 == 0) ? 0 : 1;
      int partial_msg = (msg_bytes  % 16 == 0) ? 0 : 1;

      uint16_t ad_size  = partial_ad ? (ad_full_bytes + (16 - (ad_full_bytes % 16))) : ad_full_bytes;
      uint16_t msg_size = partial_msg ? (msg_bytes + (16 - (msg_bytes % 16))) : msg_bytes;
      
      //printf("%d %d\n", ad_size, msg_size);
 
      // Combine nonce and ad. 
      uint8_t ad_pad_tmp[ad_full_bytes];
      for (int j = 0; j < nonce_bytes; j++) {
          ad_pad_tmp[j] = nonce[j];
      }
      for (int j = 0; j < ad_bytes; j++) {
          ad_pad_tmp[nonce_bytes+j] = ad[j];
      }
      uint8_t ad_pad[ad_size];
      
      //printf("ad pad ");
      //for (int j = 0; j < ad_full_bytes; j++) {
      //  printf("%02X", ad_pad_tmp[j]);
      //}
      //putchar('\n');
      pad(ad_pad_tmp, ad_full_bytes, ad_pad, ad_size);	
      
      //printf("ad pad ");
      //for (int j = 0; j < ad_size; j++) {
      //  printf("%02X", ad_pad[j]);
      //}
      //putchar('\n');
      
      
      uint8_t msg_pad[msg_size]; pad(msg, msg_bytes, msg_pad, msg_size);	
  
      uint8_t cipher[16 + msg_size];
      memset(cipher, 0, 16+msg_size);
  
      sundae_enc(nonce, nonce_bytes, ad, ad_bytes, msg, msg_bytes, key, cipher, 0);
      //printf("============\n");
      //for (int j = msg_size; j < msg_size+16; j++) {
      //  printf("%02X", cipher[j]);
      //}
      //putchar('\n');
      output(i, ad_size, msg_size, partial_ad, partial_msg, key, ad_pad, msg_pad, cipher);
  }

  return 0;
}
