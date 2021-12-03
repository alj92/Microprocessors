#include <xc.inc>

global  ADC_Setup, ADC_Read
    
PSECT udata_acs_ovr,space=1,ovrld,class=COMRAM
    
;LCD_hex_tmp:	ds 1
 
RESL1:    ds 1	    ;reserve one byte of memory
RESL2:    ds 1
RESH1:    ds 1
RESH2:    ds 1
VALL1:    ds 1
VALL2:    ds 1
VALH1:    ds 1
VALH2:    ds 1
psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISF, PORTF_RF0_POSN, A  ; pin RF0==AN0 input
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
;	call HEX_Convert
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

end


