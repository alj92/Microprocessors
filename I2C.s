
#include <xc.inc>

global	IC_INIT, IC_write, IC_READ

    
psect	udata_acs
    
IC_DATA:   ds	1   ;create one byte to put data from the sensor (BUF register_
IC_ADDRESS:   ds	1   
dataT:	 ds	1   ; create one byte to put data from the BUF to  SSP1BUF
LCD_cnt_ms: ds 1    ; reserve 1 byte for ms counter   
LCD_cnt_l: ds 1	    ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h: ds 1	    ; reserve 1 byte for variable LCD_cnt_h

psect	I2C_code, class=CODE


IC_INIT:
    bsf	    TRISC, PORTC_RC3_POSN, A ; pin RC3= serial clock SCLx
    bsf	    TRISC, PORTC_RC4_POSN, A ;  pin RC4=serial data SDAx
    movlb   15	;access bank 15 of the SFR
 ;   clrf    ANSEL0	;Disable Analog functionality of PORTC
    
    clrf    SSP1CON1		    ;In SSP1CON1
    bsf	    SSPM3		    ;Master mode is enabled by setting and clearing the
    bcf	    SSPM2		    ;appropriate SSPxM bits in the SSPxCON1 register 
    bcf	    SSPM1
    bcf	    SSPM0
    
    bsf	    SSPEN		    ; and by setting the SSPxEN bit
    
    bsf	    SCL1		    ;In Master mode, the SCLx, in TRISC   
    bsf	    SDA1		    ;and SDAx lines are set as inputs
    
    movlw   0x18		    ;Fosc = 400kHz ; SSP1ADD = (Fosc / (4*Fclock)) - 1 
    movwf   SSP1ADD
    return
    
IC_write:
    bsf	    SEN			    ;  SEN = 1, setting the SEN in the SSPxCON2, start condition, SSP2CON2
    
    btfss   SSP1IF		    ; btfss = skip if bit is set, SSPxIF is set by hardware when Start   PIR1, 
    bra	    $-2			    ; branch to previous line
    bcf	    SSP1IF		    ; clear SSPxIF,  in PIR1
    
    
    movlw   10100000		    ; slave address [they put B'10100000] Send write control byte to EEPROM
    movwf   SSP1BUF		    ; loading slave address in register
    btfsc   ACKSTAT		    ; check the ACKSTAT bit in the SSPxCON2 register -> skip if clear,   in SSP1CON2
    bra	    $-2
    btfss   SSP1IF		    ; interrupt and clock, in PIR1
    bra	    $-2
    bcf	    SSP1IF		    ; SSPxIF is cleared, in PIR1
    
    
    movff   0b1010111, SSP1BUF	    ; slave address 
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    in SSP1CON2
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end    , in PIR1
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared    , in PIR1

    
    movff   IC_DATA, SSP1BUF	    ;The user loads the SSPxBUF with eight bits of data.
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    in SSP1CON2
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.			    
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end      , in PIR1
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared    , in PIR1

    
    bsf	   PEN			    ;The user generates a Stop or Restart condition     SSP1CON2, 
				    ;by setting the PEN or RSEN bits of the SSPxCON2 register.		    
    btfss   SSP1IF		    ;Interrupt is generated once the Stop/Restart condition is complete.   , in PIR1
    bra	    $-2
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.   , in PIR1
    
    
    call    TEN_delay_ms
    call    TEN_delay_ms
    
    return

IC_READ:    
    bsf	    RSEN		    ;The user generates a Start condition by setting the SEN bit of the SSPxCON2 register.  in SSP1CON2
    btfss   SSP1IF		    ;SSPxIF is set by hardware on completion of the Start.   , in PIR1
    bra	    $-2
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.   , in PIR1

   
    
    movlw   10100000		    ;Send the write control byte to the EEPROM
    movwf   SSP1BUF
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end     PIR1, 
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.    PIR1, 
    

    movff   IC_ADDRESS, SSP1BUF    ;The user loads the SSPxBUF with the slave address to transmit
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end    PIR1, 
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.      PIR1, 
    
    
    
    
    bsf	    RSEN		    ;The user generates a Restart condition by setting the SEN bit of the SSPxCON2 register.    SSP1CON2, 
    btfss   SSP1IF		    ;SSPxIF is set by hardware on completion of the Restart.    PIR1, 
    bra	    $-2
    bcf	    SSP1IF		    ;SSPxIF is cleared by software      PIR1, 
     
    
    
    movlw   10100001		    ;Send the read control byte to the EEPROM
    MOVWF   SSP1BUF
    BTFSC   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from      SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    BTFSS   SSP1IF		    ;The MSSPx module generates an interrupt at the end    PIR1,
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.    PIR1, 

    

    
    bsf	    RCEN		    ;User sets the RCEN bit of the SSPxCON2 register    SSP1CON2, 
				    ;and the Master clocks in a byte from the slave.	    
    btfss   SSP1IF		    ;After the 8th falling edge of SCLx, SSPxIF and BF are set.   PIR1, 
    bra	    $-2
    bcf	    SSP1IF		    ;Master clears SSPxIF    PIR1, 
    movff   SSP1BUF, IC_DATA		    ;and reads the received byte from SSPxUF    SSP1BUF, 

    
    
    
    bsf	    ACKDT	    ;Master sets ACK value sent to slave in     SSP1CON2, 
    bsf	    ACKEN	    ;ACKDT bit of the SSPxCON2 register and     SSP1CON2, 
				    ;initiates the ACK by setting the ACKEN bit			    
    btfss   SSP1IF	    ;Masters ACK is clocked out to the slave and SSPxIF is set.     PIR1, 
    bra	    $-2
    bcf	    SSP1IF	    ;User clears SSPxIF.    PIR1, 
    
    
    return
									
TEN_delay_ms:    ; delay given in ms in W
    movwf   LCD_cnt_ms, A

lcdlp2: 
    movlw   250    ; 1 ms delay
    call    LCD_delay_x4us 
    decfsz  LCD_cnt_ms, A
    bra	    lcdlp2
    return

    
LCD_delay_x4us:    ; delay given in chunks of 4 microsecond in W
	movwf LCD_cnt_l, A ; now need to multiply by 16
	swapf   LCD_cnt_l, F, A ; swap nibbles
	movlw 0x0f    
	andwf LCD_cnt_l, W, A ; move low nibble to W
	movwf LCD_cnt_h, A ; then to LCD_cnt_h
	movlw 0xf0    
	andwf LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call TEN_delay_ms
	return
