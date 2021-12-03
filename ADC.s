#include <xc.inc>

global  ADC_Setup, ADC_Read
    
PSECT udata_acs_ovr,space=1,ovrld,class=COMRAM
    
;LCD_hex_tmp:	ds 1
 
;RESL1:    ds 1	    ;reserve one byte of memory

psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISF, PORTE_RE0_POSN, A  ; pin RF0==AN0 input
	movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x00	    ; 0: single channel measurement
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output ?????
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


