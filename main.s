	#include <xc.inc>
	
psect	code, abs
	
	
delay_count: ds	1
	
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	banksel	PADCFG1 
	bsf	REPU 	; set the pull-ups to on for PORTE
	banksel	0
	clrf	LATE	; write 0s to the LATE register
		
row: 	movlw	0x0F	; configuer PORTE 4-7 as outputs and PORTE 0-3 as inputs
	movwf	TRISE		; setting the inputs
	call	delay		;insert delay
	movlw	0x0
	movwf	PORTE
        movff	PORTE, 010 ;moving value to designated file register
	;use OR command to obtain keypad value and display on PORTF
	;movwf	010,PORTF


column:
	movlw	0xF0	; configuer PORTE 4-7 as inputs and PORTE 0-3 as outputs
	movwf	TRISE		; setting the inputs
	call	delay
	movlw	0x0
	movwf	PORTE
	movff	PORTE,020
	
        goto row

delay: 
    movf	0x06, A
    movlw	0x63
    decfsz	0x06, A
    bra		delay
    
	
	
	end	main
