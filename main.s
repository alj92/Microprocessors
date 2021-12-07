 #include <xc.inc>

 psect code, abs

 
extrn sensor_setup, portcsetup, loopsensor, sensorread	    ; external heart rate click
;extrn UART_Setup, UART_Transmit_Message		    ; external uart subroutines
extrn LCD_Setup, LCD_Write_Message, LCD_Write_Instruction   ; external LCD subroutines
extrn ADC_Setup, ADC_Read				    ; external ADC subroutines   
extrn initiate						    ; external timer subroutine
extrn BPM, goodmessage, restmessage, adjustmessage	    ; external function to write the BPM= and the message on the LCD
extrn I2C_INIT, I2C_write, I2C_READ
 
 
psect code, abs   
rst:     
	org 0x0
	goto  setup

           ; ******* Programme FLASH read Setup Code ***********************
	  
setup:     bcf     CFGS ; point to Flash program memory 
           bsf     EEPGD         ; access Flash program memory
	   call	   initiate
           call    LCD_Setup	    ; setup LCD: PORTB
	   call	   clear
;          call    ADC_Setup	    ; setup ADC: PORTE
           call    portcsetup	    ; clear everything PORTC
           call    sensor_setup	    ; setup heart rate click: PORTC
	   call	   sensorread
	   goto	   start 
    
	   ;********* Main Programme *************
	   
start:
    
        call	   BPM
	
	;call print my BPM

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
	

clear:
	movlw	00000001B
	call	LCD_Write_Instruction
	return

 

;measure_loop:

;         call     ADC_Read

;         movf ADRESH, W, A

;         call     HEX_Convert

;         call     LCD_Write_Hex

;         movf ADRESL, W, A

;         call     LCD_Write_Hex

;         goto  measure_loop                ; goto current line in code

;        

;         ; a delay subroutine if you need one, times around loop in delay_count

;delay:         decfsz          delay_count, A     ; decrement until zero

;         bra    delay

;         return

;

;         end    rst

      

;Start:         

;    movlw    0x00  ;all bits in

;    movwf   TRISD, A ;port D direction Register

;    movff     0x00, PORTD        

;    call          SPI_MasterInit

;    call          SPI_MasterTransmit

;                   

;

;SPI_MasterInit:       ;Set Clock edge to negative

;    bcf CKE2     ; CKE bit in SSP2STAT

;    ; MSSP enable; CKP = 1, SPI master, clock = Fosc / 64 (1MHz)

;    movlw   (SSP2CON1_SSPEN_MASK) | (SSP2CON1_CKP_MASK) | (SSP2CON1_SSPM1_MASK)

;    movwf  SSP2CON1, A

;    ; SDO2 output ;  SCK2 output

;    bcf TRISD, PORTD_SDO2_POSN, A  ; SDO2 output

;    bcf TRISD, PORTD_SCK2_POSN, A  ; SDK2 output

;    return

;   

;SPI_MasterTransmit: ;Start transmission of data (held in W)

;    movwf SSP2BUF, A  ;write data to output buffer

;  

; Wait_Transmit:   ;Wait for transmission to complete

;         btfss  SSP2IF          ;check interrupt flag to see if data has been sent

;         bra Wait_Transmit

;         bcf SSP2IF  ;clear interrupt flag

;         return

;        

 
