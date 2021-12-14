#include <xc.inc>

global	IC_INIT, IC_write, IC_READ, Addreg, Datareg

    
psect	udata_acs
    
IC_DATA:   ds	1	;create one byte to put data from the sensor (BUF register)
IC_ADDRESS:   ds	1   
dataT:	 ds	1	; create one byte to put data from the BUF to  SSP1BUF
LCD_ms: ds 1		; reserve 1 byte for ms counter   
LCD_l: ds 1		; reserve 1 byte for variable LCD_cnt_l
LCD_h: ds 1		; reserve 1 byte for variable LCD_cnt_h

Addreg: ds 1
Datareg: ds 1
delay_count: ds 1
    
    
psect	I2C_code, class=CODE


IC_INIT:
;    bsf	    TRISC, PORTC_RC3_POSN, A ; pin RC3= serial clock SCLx
;    bsf	    TRISC, PORTC_RC4_POSN, A ;  pin RC4=serial data SDAx
    movlb   15			    ;access bank 15 of the SFR
 ;   clrf    ANSEL0		    ;Disable Analog functionality of PORTC

;PORT C setup
    banksel	ANCON0
    clrf	ANCON0			; setting port to digital
    banksel	TRISC
    movlw	00011000		;set RC3 and RC4
    movwf	TRISC
    bsf	        TRISC, PORTC_RC3_POSN, A ; pin RC3= serial clock SCLx
    bsf		TRISC, PORTC_RC4_POSN, A ;  pin RC4=serial data SDAx
;    banksel	LATC
   ; setf	LATC


;initialise I2C Master
    
    banksel	SSP1CON1
    clrf	SSP1CON1		    ;In SSP1CON1
    bsf		SSPM3		    ;I2C master mode <3:0> 1000
    bsf		SSPEN		    ; enable SDA and SCL ports
    
    
;slew rate control
    banksel SSP1STAT
    clrf    SSP1STAT
    
    banksel	SSP1ADD			    ;setting Baud rate
    movlw   0x27		    ;Fosc = 16MHz ; Fclock = 400kHz use 100 ; SSP1ADD = ((Fosc / Fclock) / 4) -1;   value given in the data sheet Heart Rate Click
    movwf   SSP1ADD
   
    
    
    return

    
IC_write:
    banksel SSP1CON2    
    bsf	    SEN		    ;The user generates a Start condition by setting the SEN bit of the SSPxCON2 register.  in SSP1CON2
    btfss   SSP1IF		    ;SSPxIF is set by hardware on completion of the Start.   , in PIR1
    bra	    $-2
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.   , in PIR1

   
    
    banksel SSP1BUF    
    movlw   0xAE		    ;Send the write control byte to the EEPROM
    movwf   SSP1BUF
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end     PIR1, 
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.    PIR1, 
    

    
    movff   Addreg, SSP1BUF, A	    ;The user loads the SSPxBUF with the slave address to transmit    ICAddress
    banksel SSP1CON2    
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end    PIR1, 
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.      PIR1, 
    

    movff   Datareg, SSP1BUF, A	    ;The user loads the SSPxBUF with eight bits of data. ICData
    banksel SSP1CON2    
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    in SSP1CON2
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.			        
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end      , in PIR1
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared    , in PIR1

    banksel SSP1CON2
    bsf	    RSEN				    ;The user generates a Stop or Restart condition     SSP1CON2, 
				    ;by setting the PEN or RSEN bits of the SSPxCON2 register.		    
;    btfss   SSP1IF		    ;Interrupt is generated once the Stop/Restart condition is complete.   , in PIR1
;    bra	    $-2
;    bcf	    SSP1IF		    ;SSPxIF is cleared by software.   , in PIR1
;     
  
    
;    movlw   0x02
;    movwf   delay_count
;    call    delay
    
    return

IC_READ:    
    banksel SSP1CON2    
    bsf	    SEN		    ;The user generates a Start condition by setting the SEN bit of the SSPxCON2 register.  in SSP1CON2
    btfss   SSP1IF		    ;SSPxIF is set by hardware on completion of the Start.   , in PIR1
    bra	    $-2
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.   , in PIR1

   
    
    banksel SSP1BUF    
    movlw   0xAE		    ;Send the write control byte to the EEPROM
    movwf   SSP1BUF, A
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end     PIR1, 
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.    PIR1, 
    

    
    movff   Addreg, SSP1BUF,A	    ;The user loads the SSPxBUF with the slave address to transmit    ICAddress
    banksel SSP1CON2    
    btfsc   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from    SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    btfss   SSP1IF		    ;The MSSPx module generates an interrupt at the end    PIR1, 
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.      PIR1, 
    
;    movlw   0x02
;    movwf   delay_count
;    call    delay
    
    banksel SSP1CON2    
    bsf	    SEN			    ;The user generates a Restart condition by setting the SEN bit of the SSPxCON2 register.    SSP1CON2,  
    btfss   SSP1IF		    ;SSPxIF is set by hardware on completion of the Restart.    PIR1, 
    bra	    $-2
    bcf	    SSP1IF		    ;SSPxIF is cleared by software      PIR1, 
    
   

    banksel SSP1BUF
    movlw   0xAF		    ;Send the read control byte to the EEPROM
    movwf   SSP1BUF, A
    banksel SSP1CON2    
    BTFSC   ACKSTAT		    ;The MSSPx module shifts in the ACK bit from      SSP1CON2, 
    bra	    $-2			    ;the slave device and writes its value into the
				    ;ACKSTAT bit of the SSPxCON2 register.
    BTFSS   SSP1IF		    ;The MSSPx module generates an interrupt at the end    PIR1,
    bra	    $-2			    ;of the ninth clock cycle by setting the SSPxIF bit.
    bcf	    SSP1IF		    ;SSPxIF is cleared by software.    PIR1, 
    
    
    banksel SSP1CON2    
    bsf	    RCEN		    ;User sets the RCEN bit of the SSPxCON2 register    SSP1CON2,   Receive enable bit
				    ;and the Master clocks in a byte from the slave.	    
    btfss   SSP1IF		    ;After the 8th falling edge of SCLx, SSPxIF and BF are set.   PIR1, 
    bra	    $-2
    bcf	    SSP1IF		    ;Master clears SSPxIF    PIR1, 
    movff   SSP1BUF, Datareg	    ;and reads the received byte from SSPxUF    SSP1BUF, 

    
    banksel SSP1CON2
    bsf	    ACKDT	    ;Master sets ACK value sent to slave in SSP1CON2, non acknowledge byte
    bsf	    ACKEN	    ;ACKDT bit of the SSPxCON2 register and SSP1CON2, 
				    ;initiates the ACK by setting the ACKEN bit			    
    banksel SSP1CON2    
    btfss   SSP1IF	    ;Masters ACK is clocked out to the slave and SSPxIF is set.     PIR1, 
    bra	    $-2
    bcf	    SSP1IF	    ;User clears SSPxIF.    PIR1, 
    
    
    banksel SSP1CON2    
    bsf	    RSEN	
    
    return
    
									
;TEN_delay_ms:    ; delay given in ms in W
;    movwf   LCD_ms, A
;
;lcdloop2: 
;    movlw   0    ; 1 ms delay
;    call    LCDdelay_x4us 
;    decfsz  LCD_ms, A
;    bra	    lcdloop2
;    return
;
;    
;LCDdelay_x4us:    ; delay given in chunks of 4 microsecond in W
;	movwf LCD_l, A ; now need to multiply by 16
;	swapf   LCD_l, F, A ; swap nibbles
;	movlw 0x0f    
;	andwf LCD_l, W, A ; move low nibble to W
;	movwf LCD_h, A ; then to LCD_cnt_h
;	movlw 0xf0    
;	andwf LCD_l, F, A ; keep high nibble in LCD_cnt_l
;	call TEN_delay_ms
;	return

LCDdelay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_l, A	; now need to multiply by 16
	swapf   LCD_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_l, W, A ; move low nibble to W
	movwf	LCD_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCDdelay
	return

LCDdelay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp2:	decf 	LCD_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp2		; carry, then loop again
	return			; carry reset so return

	
delay: 
	decfsz	delay_count, A 	; decrement until zero
	bra	delay
	return
