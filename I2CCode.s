#include <xc.inc>

global	IC_INIT, IC_write, IC_READ, Addreg, Datareg

    
psect	udata_acs
    
IC_DATA:   	ds 1	; create one byte to put data from the sensor (BUF register)
IC_ADDRESS:   	ds 1    ; create one byte to choose the register to write or read from the sensor (BUF register)
dataT:	 	ds 1	; create one byte to put data from the BUF to  SSP1BUF
LCD_ms: 	ds 1	; reserve 1 byte for ms counter   
LCD_l: 		ds 1	; reserve 1 byte for variable LCD_cnt_l
LCD_h: 		ds 1	; reserve 1 byte for variable LCD_cnt_h

Addreg: ds 1
Datareg: ds 1
delay_count: ds 1
    
    
psect	I2C_code, class=CODE


IC_INIT:
;    bsf	 TRISC, PORTC_RC3_POSN, A 	; pin RC3= serial clock SCLx
;    bsf	 TRISC, PORTC_RC4_POSN, A 	; pin RC4=serial data SDAx
     movlb   	 15			    	; access bank 15 of the SFR
 ;   clrf    	 ANSEL0		    		; Disable Analog functionality of PORTC

;PORT C setup
    banksel	ANCON0
    clrf	ANCON0				; setting port to digital
    banksel	TRISC
    movlw	00011000			;set RC3 and RC4
    movwf	TRISC
    bsf	        TRISC, PORTC_RC3_POSN, A 	; pin RC3= serial clock SCLx
    bsf		TRISC, PORTC_RC4_POSN, A 	;  pin RC4=serial data SDAx
;    banksel	LATC
   ; setf	LATC


;initialise I2C Master
    
    banksel	SSP1CON1
    clrf	SSP1CON1		    	;In SSP1CON1
    bsf		SSPM3		    	   	;I2C master mode <3:0> 1000
    bsf		SSPEN		   		;enable SDA and SCL ports
    
    
;slew rate control
    banksel SSP1STAT
    clrf    SSP1STAT
    
    banksel	SSP1ADD			 ;setting Baud rate
    movlw   0x27		    	 ;Fosc = 16MHz ; Fclock = 400kHz use 100 ; SSP1ADD = (Fosc / (Fclock * 4)) -1
    movwf   SSP1ADD
   
    
    
    return

    
IC_write:
    banksel SSP1CON2    
    bsf	    SEN		    		; Start condition 
    btfss   SSP1IF		   	;SSPxIF is set by hardware on completion of the Start (in PIR1)
    bra	    $-2
    bcf	    SSP1IF		   	;Clear SSP1IF

   
    
    banksel SSP1BUF    
    movlw   0xAE		   	;Send the write control byte to the EEPROM
    movwf   SSP1BUF
    btfsc   ACKSTAT		    	;ACK (acknowledgment) bit from slave device to write into ACKSTAT bit of the SSPxCON2 register   
    bra	    $-2			   
    
    btfss   SSP1IF		    	;Interrupt generated at the end of the ninth clock cycle by setting the SSPxIF bit (in PIR1) 
    bra	    $-2			    
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1)
    

    
    movff   Addreg, SSP1BUF, A	    	;Load SSPxBUF with slave address to transmit
    banksel SSP1CON2    
    btfsc   ACKSTAT		   	;Shift in the ACK bit from slave and writes its value into the ACKSTAT bit of the SSP1CON2   
    bra	    $-2			    
				    
    btfss   SSP1IF		    	;Interrupt generated 
    bra	    $-2			    
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1)
    

    movff   Datareg, SSP1BUF, A	    	;Load the SSPxBUF with eight bits of data
    banksel SSP1CON2    
    btfsc   ACKSTAT		    	;Shift in the ACK bit from slave and write its value into the ACKSTAT bit of the SSP1CON2 
    bra	    $-2			    	
    
    btfss   SSP1IF		    	;Interrupt generated 
    bra	    $-2			    
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1)

    banksel SSP1CON2
    bsf	    RSEN		   	;Restart condition   
				    		
				    
;    btfss   SSP1IF		    	;Interrupt is generated once the Stop/Restart condition is complete
;    bra	    $-2
;    bcf	    SSP1IF		;Clear SSP1IF (in PIR1)
;     
  
    
;    movlw   0x02
;    movwf   delay_count
;    call    delay
    
    return

IC_READ:    
    banksel SSP1CON2    
    bsf	    SEN		    		;Start condition
    btfss   SSP1IF		    	;SSPxIF is set by hardware on completion of the Start (in PIR1)
    bra	    $-2
    bcf	    SSP1IF		   	;Clear SSP1IF (in PIR1)

   
    
    banksel SSP1BUF    
    movlw   0xAE		    	;Send the slave address in write mode to EEPROM
    movwf   SSP1BUF, A
    btfsc   ACKSTAT		    	;Shift in the ACK bit from slave and write its value into the ACKSTAT bit of the SSP1CON2
    bra	    $-2			    
    
    btfss   SSP1IF		    	;Interrupt generated at the end of the ninth clock cycle by setting the SSPxIF bit
    bra	    $-2			    
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1)
    

    
    movff   Addreg, SSP1BUF,A	    	;Load the SSPxBUF with the slave address to transmit    
    banksel SSP1CON2    
    btfsc   ACKSTAT		    	;Shift in the ACK bit from slave and write its value into the ACKSTAT bit of the SSP1CON2
    bra	    $-2			    
    
    btfss   SSP1IF		    	;Interrupt generated at the end of the ninth clock cycle by setting the SSPxIF bit
    bra	    $-2			    
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1) 
    
;    movlw   0x02
;    movwf   delay_count
;    call    delay
    
    banksel SSP1CON2    
    bsf	    SEN			    	;Generate a Restart condition by setting the SEN bit of the SSPxCON2 register 
    btfss   SSP1IF		    	;SSPxIF is set by hardware on completion of the Restart
    bra	    $-2
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1)
    
   

    banksel SSP1BUF
    movlw   0xAF		    	;Send the slave address in write mode to the EEPROM
    movwf   SSP1BUF, A
    banksel SSP1CON2    
    BTFSC   ACKSTAT		    	;Shift in the ACK bit from slave and write its value into the ACKSTAT bit of the SSP1CON2
    bra	    $-2			    	
    
    BTFSS   SSP1IF		    	;Interrupt generated at the end of the ninth clock cycle by setting the SSPxIF bit
    bra	    $-2			    
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1) 
    
    
    banksel SSP1CON2    
    bsf	    RCEN		    	;Set the RCEN bit (receive enable bit) of SSPxCON2 register
				    		    
    btfss   SSP1IF		    	;After the 8th falling edge of SCLx, SSPxIF and BF are set (in PIR1) 
    bra	    $-2
    bcf	    SSP1IF		    	;Clear SSP1IF (in PIR1)
    movff   SSP1BUF, Datareg	    	;Read the received byte from SSP1BUF

    
    banksel SSP1CON2
    bsf	    ACKDT	    		;Master sets ACK value sent to slave in SSP1CON2 (non acknowledge byte)
    bsf	    ACKEN	    		;ACKDT bit of the SSP1CON2 register which initiates the ACK by setting the ACKEN bit 
				    				    
    banksel SSP1CON2    
    btfss   SSP1IF	    		;Masters ACK is clocked out to the slave and SSP1IF is set
    bra	    $-2
    bcf	    SSP1IF	    		;Clear SSP1IF (in PIR1) 
    
    
    banksel SSP1CON2    
    bsf	    RSEN	
    
    return
    
