 #include <xc.inc>

 global	datain1, datain2
 
psect	udata_acs
    datain1:	    ds	    1
    datain2:	    ds	    1
    datain3:	    ds	    1
    datain4:	    ds	    1
    Interruptbit:   ds	    1
    counter:	    ds	    1
    
psect  udata_bank4 
    message_data:   ds	    0x80    

    
psect code, abs

extrn UART_Setup, UART_Transmit_Message			    ; external uart subroutines
extrn LCD_Setup, LCD_Write_Message, LCD_Write_Instruction   ; external LCD subroutines
;extrn ADC_Setup, ADC_Read				    ; external ADC subroutines   					    
extrn  BPM, goodmessage, restmessage, adjustmessage	    ;external function to write the BPM= and the message on the LCD  
extrn IC_INIT, IC_write, IC_READ, Addreg, Datareg
;extrn HexDec_Convert

 
psect code, abs   
rst:     
	org 0x0
	goto  setup

; ************ Programme FLASH and read Setup Coded ***********************
	  
setup:     bcf     CFGS		    ; point to Flash program memory 
           bsf     EEPGD	    ; access Flash program memory
	   call	   clear	    ; clear the LCD screen
	   call    LCD_Setup	    ; setup LCD: PORTB
	   call	   IC_INIT	    ; Initialise the I2C
	   call	    UART_Setup	    ; UART Set up

;************* Configure the Heart rate click ***********************
	   
	   movlw    0x06	;register address to set the mode of the Heart Rate Click
	   movwf    Addreg,A
	   movlw    0x02	;configure the sensor on the heart rate mode 
	   movwf    Datareg,A
	   call	    IC_write	
;	   movlw    0x06	;check the value in the register by reading it back
;	   movwf    Addreg,A
;	   call	    IC_READ
	   
	   movlw    0x07	;register address for the SPO2 mode configuration
	   movwf    Addreg,A
	   movlw    0x00	;set this register to 0 as unused
	   movwf    Datareg,A
	   call	    IC_write
;	   movlw    0x07	;check the value in the register by reading it back
;	   movwf    Addreg,A
;	   call	    IC_READ
	
	   movlw    0x09	;register address for the LED configuration
	   movwf    Addreg,A
	   movlw    0x0F	;Set the LED for the IR only (corresponds to 50mA)
	   movwf    Datareg,A
	   call	    IC_write
;	   movlw    0x09	;check the value in the register by reading it back
;	   movwf    Addreg,A
;	   call	    IC_READ
	   
;	   movlw    0x05	;Read the interrupt status: when read, all the interrupts are cleared so it gives back 0x00
;	   movwf    Addreg,A
;	   call	    IC_READ
	   
	   
;************* Set the pointers to 0x00 *************
	   
	   movlw    0x02	;FIFO write pointer
	   movwf    Addreg,A
	   movlw    0x00	;Clear the register
	   movwf    Datareg,A
	   call	    IC_write
	   
	   movlw    0x03	;Over flow counter
	   movwf    Addreg,A
	   movlw    0x00	;Clear the register
	   movwf    Datareg,A
	   call	    IC_write
	   
	   movlw    0x04	;FIFO read pointer
	   movwf    Addreg,A
	   movlw    0x00	;Clear the register
	   movwf    Datareg,A
	   call	    IC_write
	   goto	    read_loop
	  
;************* Read the data *************
	   
read_loop:	   
	   movlw    0x05	;FIFO data register adresss
	   movwf    Addreg,A
	   call	    IC_READ
	   movff    Datareg, datain1
	   
	   movlw    0x05	;FIFO data register adresss
	   movwf    Addreg,A
	   call	    IC_READ
	   movff    Datareg, datain2
	   
	   movlw    0x05	;FIFO data register adresss
	   movwf    Addreg,A
	   call	    IC_READ
	   movff    Datareg, datain3
	   
	   movlw    0x05	;FIFO data register adresss
	   movwf    Addreg,A
	   call	    IC_READ
	   movff    Datareg, datain4
	   
	   call	    write_data_to_message_data
	   bra	    read_loop
	   
;read_loop1:	   
;	   movlw    0x05	;FIFO data register adresss
;	   movwf    Addreg,A
;	   call	    IC_READ
;	   movff    Datareg, datain2
;	   
;	   movlw    0x05	;FIFO data register adresss
;	   movwf    Addreg,A
;	   call	    IC_READ
;	   movff    Datareg, datain2+1
;	   
;	   movlw    0x05	;FIFO data register adresss
;	   movwf    Addreg,A
;	   call	    IC_READ
;	   movff    Datareg, datain2+1
;	   
;	   movlw    0x05	;FIFO data register adresss
;	   movwf    Addreg,A
;	   call	    IC_READ
;	   movff    Datareg, datain2+1
	   
;	   movlw    0x04	;FIFO read pointer
;	   movwf    Addreg,A
;	   movlw    0x01	;corresponds to 27.1mA + only for IR
;	   movwf    Datareg,A
;	   call	    IC_write
	   
	   
	   
;************* Setting up PORTH as LED data output for tests*************
	   movlw    0x00
	   movwf    TRISH
	   movff    datain1, PORTH
	   
	   
;************* Sending the data to be used with Python via UART *************

write_data_to_message_data:
        lfsr	    2, message_data	 
	movff	    datain1, POSTINC2
	movlw	    1
	lfsr	    2, message_data
	call	    UART_Transmit_Message
	
	movff	    datain2, POSTINC2
	movlw	    1
	lfsr	    2, message_data
	call	    UART_Transmit_Message
	return
	
	
; ******* Display Message LCD ****************************************

	    
start:
	call	    BPM
	
	;***** if statements to choose the correct message (using dummy frequency)**********
	
	movlw	   150		    ;dummy frequency
	movwf	   0x06, A	    ;registry
	movlw	   30		    ;minf to compare-> need to readjust
	CPFSLT	   0x06		    ;skips if frequency smaller than 30
	call	   good_break_fork  ;goes there if frequency bigger than 30
	movlw	   30		    
	CPFSGT	   0x06		    ;skips if frequency bigger than 30
	call	   adjustmessage    ;should display adjust if frequency smaller than 30
	
	goto	    $   

good_break_fork:
	movlw	    200		    ; maxf to compare -> need to take a break
	CPFSLT	    0x06	    ; skips if frequency smaller than 200
	call	    restmessage	    ;should display if frequency is bigger than 200
	movlw	    200		    
	CPFSLT	    0x06	    ;should skip if value smaller than 200 -> go to call message
	return
	
	call	   goodmessage
	return
	

clear:				; function to clear the LCD
	movlw	00000001B
	call	LCD_Write_Instruction
	return


		
   

