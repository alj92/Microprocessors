#include <xc.inc>

global  ADC_Setup, ADC_Read    
    
psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
	call HEX_Convert
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return
	
HEX_Convert:
    ;Multiplyig low by low
    andlw   0xF0    ;using the lowest 4 bits first
    movf    VALL1, W ;VAL1 stored in W
    mulwf   VALL2    ;multiplying lowest bits from VAL1*VAL2
    movff   PRODH, RESL2	;result stored in sfr PRODH:PRODL
    movff   PRODL, RESL1
    
    ;Multiplying high by high
    andlw   0x0F    ;using the highest 4 bits first
    movf    VALH1, W
    mulwf   VALH2   ;multiplying highest bits VAL1*VAL2
    movff   PRODH, RESH1
    movff   PRODL, RESH2
    
    ;Multiplying low by high
    movf    VALL1, W	
    mulwf   VALH2   ;multiplying VALL1*VALH2
    ;summing cross products
    movf    PRODL, W	;moving multiplication result of VALL1*VALH2 from file register to W
    addwf   RESL1, F	;add low result from both multiplications (low*high) + (low*low)
    movf    PRODH, W	
    addwf   RESH2, F	;add high result from both multiplications (low*high) + (high*high)
    clrf    WREG	;clearing working register 
    addwfc  RESH1, F	;adding W+carry bit to F
    
    ;Multiplying high by low
    movf    VALH1, W	
    mulwf   VALL2   ;multiplying VALH1*VALL2
    ;summing cross products
    movf    PRODL, W
    addwf   RESL1, F	;add high result from both multiplications (high*low) + (low*low)
    movf    PRODH, W
    addwf  RESH2, F	;add high result from both multiplications (low*high) + (high*high)
    clrf    WREG	;clearing working register 
    addwfc  RESH1, F	;adding W+carry to F
    return
	

end