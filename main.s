	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw 	0x0
	movwf	TRISB, A	    ; Port C all outputs
	bra 	test
loop:
	movff 	0x06, PORTB
	incf 	0x06, W, A
test:
	