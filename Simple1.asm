	#include p18f87k22.inc
	
psect	code, abs
counter:
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start:
	movlw 	0x0
	movwf	TRISB, A	    ; Port C all outputs
	bra 	test
	
loop:	movff 	0x06, PORTB
	incf 	0x06, W, A
	call delay
	
	
test: 	movwf	0x06, A	    ; Test for end of loop condition
	movlw 	0x63
	cpfsgt 	0x06, A
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start
	
delay: decfsz 0x06, A
       bra delay
       
	end
