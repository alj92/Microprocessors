#include <xc.inc>
    
    
global	  timer_setup
    
psect	udata_acs
    
counter:    ds 1	    ;reserve one byte of memory
    
psect	timer_code,class=CODE

initiate:
        movlb   15    ;move literal to low nibble in BSR (Bit Scan Reverse)
        clrf	ANSELB, A		; setup PORTB
        clrf    TRISB, A               	; setup PORTB as output
        clrf    LATB, A                	; clearing existing data in PORTB
	movlw	b10100000		; set 500kHz oscillator
	movwf	OSCCON, A		; oscillator control register
        movlw   b00000001        	; 1s Timer - prescaler = 2, 1:2 prescale value
;        movlw   b00000100        	; 15s Timer - prescaler = 32, 1:32 prescale value
        movwf   T0CON, A		; timer control register
        
; Setting up MF-INTOSC 500kHz oscillator - check default?
; Using OSCCON: OSCILLATOR CONTROL REGISTER
; Setting bit 6-4
; 010 = MF-INTOSC output frequency is used (500 kHz)
; 001 = MF-INTOSC/2 output frequency is used (250 kHz)
; 000 = LF-INTOSC output frequency is used (31.25 kHz)
	
	
;1s Timer
;Using 500kHz oscillator MF-INTOSC
;Prescale = 2
;Equation to calculate timer count value: Timer = 4 * Tosc * (8/16bits_max_value - TMR0value)*(Prescaler)
;  1s = 4 * (1/500kHz) * (65536 - TMR0value) * (2)
;  max_count-timer_count = 65536 - 62500
;  Count in Hexadecimal = 3036 = 0x0BDC
;  High byte = TMR0H = 0x0B
;  Low byte = TMR0L = 0xDC

 Timer_1s:
        movlw   0x0B                ; load hexadecimal count value 0x0BDC to count 3036
        movwf   TMR0H, A            ; high byte
        movlw   0xDC
        movwf   TMR0L, A               ; low byte
        bsf     T0CON, TMR0ON, A       ; gives 1s time

; 15s Timer
; Using 500kHz oscillator MF-INTOSC
; Prescale = 32
;Equation to calculate timer count value:
;  15s = 4 * (1/500kHz) * (65536 - TMR0value) * (32)
;  max_count-timer_count = 65536 - 58594
;  Count in Hexadecimal = 6942 = 0x1B1E
;  High byte = TMR0H = 0x1B
;  Low byte = TMR0L = 0x1E

 Timer_15s:
        movlw   0x1B                ; load hexadecimal count value 0x1B1E to count 6943
        movwf   TMR0H, A               ; high byte
        movlw   0x1E                ; 
        movwf   TMR0L, A               ; low byte
        bsf     T0CON, TMR0ON       ; gives 15s time
	

; Checking if timer is done - RB0 LED turns on

check_led:
        btfss   INTCON, TMR0IF      ; loop to check byte until timer0 overflows - count reached
        goto    check_led
        bcf     T0CON, TMR0ON       ; turns timer off when finished
        btg     LATB, RB0           ; toggles bit 7 LED - turns on when timer finished
        bcf     INTCON, TMR0IF      ; clears timer 'overflow flag'
        goto    Timer_1s       ; to restart timer

END


