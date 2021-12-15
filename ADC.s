;#include <xc.inc>
;
;global  ADC_Setup, ADC_Read
;    
;PSECT udata_acs_ovr,space=1,ovrld,class=COMRAM
;    
;LCD_hex_tmp:	ds 1
; 
;RESL1:    ds 1	    ;reserve one byte of memory
;RESL2:    ds 1
;RESH1:    ds 1
;RESH2:    ds 1
;VALL1:    ds 1
;VALL2:    ds 1
;VALH1:    ds 1
;VALH2:    ds 1
;psect	adc_code, class=CODE
;    
;ADC_Setup:
;	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
;	movlb	0x0f
;	bsf	ANSEL0	    ; set AN0 to analog
;	movlb	0x00
;	movlw   0x01	    ; select AN0 for measurement
;	movwf   ADCON0, A   ; and turn ADC on
;	movlw   0x30	    ; Select 4.096V positive reference
;	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
;	movlw   0xF6	    ; Right justified output
;	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
;	return
;
;ADC_Read:
;	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
;;	call HEX_Convert
;adc_loop:
;	btfsc   GO	    ; check to see if finished
;	bra	adc_loop
;	return

    
;HEX_Convert:
;    movf    ADRESL, W,A
;    movwf    VALL1, A
;    movf    ADRESL, W,A
;    movwf    VALL2, A
;    movf    ADRESH, W,A
;    movwf    VALH1, A
;    movf    ADRESH, W,A
;    movwf    VALH2, A
;    
;    andlw   0xF0    ;using the lowest 4 bits first
;    movf    VALL1, W,A ;VAL1 stored in W
;    mulwf   VALL2    ;multiplying lowest bits from VAL1*VAL2
;    movff   PRODH, RESL2	;result stored in sfr PRODH:PRODL
;    movff   PRODL, RESL1
;    
;    ;Multiplying high by high
;    andlw   0x0F    ;using the highest 4 bits first
;    movf    VALH1, W,A
;    mulwf   VALH2   ;multiplying highest bits VAL1*VAL2
;    movff   PRODH, RESH1
;    movff   PRODL, RESH2
;    
;    ;Multiplying low by high
;    movf    VALL1, W,A
;    mulwf   VALH2   ;multiplying VALL1*VALH2
;    ;summing cross products
;    movf    PRODL, W,A	;moving multiplication result of VALL1*VALH2 from file register to W
;    addwf   RESL1, F	;add low result from both multiplications (low*high) + (low*low)
;    movf    PRODH, W,A	
;    addwf   RESH2, F	;add high result from both multiplications (low*high) + (high*high)
;    clrf    WREG	;clearing working register 
;    addwfc  RESH1, F	;adding W+carry bit to F
;    
;    ;Multiplying high by low
;    movf    VALH1, W,A	
;    mulwf   VALL2   ;multiplying VALH1*VALL2
;    ;summing cross products
;    movf    PRODL, W,A
;    addwf   RESL1, F	;add high result from both multiplications (high*low) + (low*low)
;    movf    PRODH, W,A
;    addwf  RESH2, F	;add high result from both multiplications (low*high) + (high*high)
;    clrf    WREG	;clearing working register 
;    addwfc  RESH1, F	;adding W+carry to F
;    return
	

end

