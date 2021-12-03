#include <xc.inc>

global	  sensor_setup, portcsetup, loop

psect	udata_acs
    
dataR:   ds	1 ;create one byte to put data from the sensor (BUF register_
dataT:	ds	1 ; create one byte to put data from the BUF to  SSP1BUF
    
psect	sensor_code,class=CODE

sensor_setup: 
    bsf	    TRISC, PORTC_RC3_POSN, A ; pin RC3= serial clock SCLx
    bsf	    TRISC, PORTC_RC4_POSN, A ;  pin RC4=serial data SDAx
    bsf	    SEN ;  SEN = 1, setting the SEN in the SSPxCON2, start condition, SSP2CON2,
    movlw   0b1010111 ; slave address
    movwf   SSP1BUF ; loading slave address in register
    ;clrf    SSPxIF  ; clear file in PIR register??
    btfss   SSP1CON2, 0x06 ; check the ACKSTAT bit in the SSPxCON2 register
    movwf   SSP1BUF, A	;load the register address in the SSPxBUF register (maybe)
    bsf	    PEN ;PEN = 1, setting the PEN in the SSPxCON2, end condition, SSP2CON2
    
    return
    
portcsetup:
    clrf    PORTC   ;initialize PORTC by clearing output data latches
    clrf    LATD    ;alternate method to clear output data latches
    movlw   0CFh    ;value used to initialize data direction
    movwf   TRISC   ;set RC<3:0> as inputs, RC<5:4> as outputs, RC<7:6> as inputs
    
    return

loop:
    btfss   BF    ;has data been received (transmit conplete?), SSP1STAT, 
    bra	    loop
    movf    SSP1BUF, W ; WREG reg = contents of SSP1BUF
    movwf   dataR ;save in user RAM
    movf    dataT, W ; W reg = contents of dataT
    movwf   SSP1BUF ;  nez data to xmit
    