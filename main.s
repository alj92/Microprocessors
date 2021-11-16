#include <xc.inc>

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	banksel	PADCFG1 
	bsf	REPU 	; set the pull-ups to on for PORTE
	banksel	0
	clrf	LATE	; write 0s to the LATE register
		
row: 	movlw	00001111B	; configuer PORTE 4-7 as outputs and PORTE 0-3 as inputs
	movwf	TRISE		; setting the inputs
	movlw	0x0
	movwf	PORTE
	
		