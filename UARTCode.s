
#include <xc.inc>
    
global  UART_Setup, UART_Transmit_Message

psect	udata_acs	    ; reserve data space in access ram
UART_counter: ds    1	    ; reserve 1 byte for variable UART_counter

psect	uart_code,class=CODE
UART_Setup:
;8-bit/Asynchronous
;SYNC=0
;BRG16=0
;BRGH=0
;Baud Rate using FOSC/[64 (n + 1)]	where FOSC = 64MHz
;    banksel	OSCCON
;    clrf	OSCCON
;    movlw	01111011
;    movwf	OSCCON,A

    banksel	RCSTA1
    clrf	RCSTA1
    bsf		SPEN				; enable
    banksel	TXSTA1
    bcf		SYNC				; asynchronous mode =0
    bsf		BRGH				; slow speed from high baud rate selection
    bsf		TXEN				; enable transmit
    banksel	BAUDCON1
    bcf		BRG16				; 8-bit generator only when =0
    movlw	34				; gives 9600 Baud rate (actually 9615) - baud rate 115200
    movwf	SPBRG1, A   			; set baud rate - register controls baud rate
    banksel	TRISC
    bsf		TRISC, PORTC_TX1_POSN, A	; TX1 pin is output on RC6 pin
						; must set TRISC6 to 1
    return

UART_Transmit_Message:				; Message stored at FSR2, length stored in W
    movwf   UART_counter, A
    
    
UART_Loop_message:
    movf    POSTINC2, W, A
    call    UART_Transmit_Byte
    decfsz  UART_counter, A
    bra	    UART_Loop_message
    return

UART_Transmit_Byte:				; Transmits byte stored in W
    btfss   TX1IF				; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte
    movwf   TXREG1, A
    return

end


