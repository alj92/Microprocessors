#include <xc.inc>
    
    
global	  initiate
    
psect	udata_acs
    
#include <xc.inc>
    
    
global	  initiate
    
psect	udata_acs
    
counter:    ds 1	    ;reserve one byte of memory
    
psect	timer_code,class=CODE

initiate:
	bsf	TRISD, PORTD_RD0_POSN, A  ; pin RD0==AN0 input
	movlb   15    ;move literal to low nibble in BSR (Bit Scan Reverse)
        bsf	ANSEL0		; setup PORTB
        clrf    TRISD, A               	; setup PORTB as output
        clrf    LATD, A                	; clearing existing data in PORTB
	movlw	10100011		; set 500kHz oscillator
	movwf	OSCCON, A		; oscillator control register
        movlw   00000000        	; 1s Timer - prescaler = 2, 1:2 prescale value
 ;       movlw   00000100        	; 15s Timer - prescaler = 32, 1:32 prescale value
        movwf   T0CON, A		; timer control register
	
	movlw	0x0f
	movwf	TRISH A			; set PORTH as input
	clrf	PORTH,A			;clear data
	goto	start_button
	
start_button:
	btfsc	RH0   ;check bit0 on PORT H RH0 - set=button pressed / clear=wait until pressed
	goto	Timer_1s
	goto	start_button
        
; Setting up MF-INTOSC 500kHz oscillator - check default?
; Using OSCCON: OSCILLATOR CONTROL REGISTER
; Setting bit 6-4
; 010 = MF-INTOSC output frequency is used (500 kHz)
; 001 = MF-INTOSC/2 output frequency is used (250 kHz)
; 000 = LF-INTOSC output frequency is used (31.25 kHz)
	
	
;1s Timer
;Using 500kHz oscillator MF-INTOSC
;Prescale = 2
;Equation to calculate timer count value: Timer = 4/Tosc * (16bit - TMR0value)*(Prescaler)
;  1s = (4/500kHz) * (65536 - TMR0value) * (2)
;  max_count-timer_count = 65536 - 34286
;  Count in Hexadecimal = 31250 = 0x7A12
;  High byte = TMR0H = 0x7A
;  Low byte = TMR0L = 0x12

 Timer_1s:
        movlw   0x7A               ; load hexadecimal count value 0x0BDC to count 3036
        movwf   TMR0H, A            ; high byte
        movlw   0x12
        movwf   TMR0L, A               ; low byte
        bsf     TMR0ON       ; gives 1s time

; 15s Timer
; Using 500kHz oscillator MF-INTOSC
; Prescale = 32
;Equation to calculate timer count value:
;  15s = (4/500kHz) * (65536 - TMR0value) * (32)
;  max_count-timer_count = 65536 - 6942
;  Count in Hexadecimal = 58594 = 0xE4E2
;  High byte = TMR0H = 0xE4
;  Low byte = TMR0L = 0xE2

; Timer_15s:
;        movlw   0xE4                ; load hexadecimal count value 0x1B1E to count 6943
;        movwf   TMR0H, A               ; high byte
;        movlw   0xE2                 
;        movwf   TMR0L, A               ; low byte
;        bsf     TMR0ON       ; gives 15s time
	

; Checking if timer is done - RB0 LED turns on

check_led:
        btfss   TMR0IF      ; loop to check byte until timer0 overflows - count reached
        goto    check_led
        bcf     TMR0ON       ; turns timer off when finished
        btg     RD0           ; bit0 on LED - turns on when timer finished
        bcf     TMR0IF      ; clears timer 'overflow flag'
        goto    Timer_1s       ; to restart timer
	

;check_ADC:
;    btfsc   ADCON0,GO   ;check if conversion finished
;    bra	    check_ADC	;if not finished - return to check_ADC
;    movf ADRESH,0,0	;if finished - use value

end
