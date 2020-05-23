
#include<stdio.h>
#include<stdlib.h>
int main() {

	FILE *in = fopen("randomness_source", "w");
    srand(0); // seed randomness source
    
    int i,j;
    
	
	for(j=0; j<100000; j++) { // the more the merrier
	    for(i =0; i<16; i++) printf("%02X", (unsigned char) rand());
	    printf("\n");	}
}
