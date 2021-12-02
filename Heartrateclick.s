#include <xc.inc>

global	  sensor_setup
psect	sensor_code,class=CODE

 
sensor_setup: 
    bsf	    TRISC, PORTC_RC3_POSN, PORTC_RC4_POSN, A ; pin RC3= serial clock SCLx
    bsf	    TRISC, PORTC_RC4_POSN, A ;  pin RC4=serial data SDAx
    bsf   SSPxCON2, 0x00, 0x01 ;  SEN = 1, setting the SEN in the SSPxCON2, start condition
    movlw   0b1010111 ; slave address
    movwf   SSPxBUF ; loading slave address in register
    ;clrf    SSPxIF  ; clear file in PIR register??
    btfss   SSPxCON2, 0x06 ; check the ACKSTAT bit in the SSPxCON2 register
    movff   SSPxSR, SSPxBUF	;load the register address in the SSPxBUF register (maybe)
    bsf	    SSPxCON2, 0x02, 0x01 ;PEN = 1, setting the PEN in the SSPxCON2, end condition
    
    return
    
portdsetup:
    clrf    PORTC   ;initialize PORTC by clearing output data latches
    clrf    LATD    ;alternate method to clear output data latches
    movlw   OCFh    ;value used to initialize data direction
    movwf   TRISC   ;set RC<3:0> as inputs, RC<5:4> as outputs, RC<7:6> as inputs
    
    return

