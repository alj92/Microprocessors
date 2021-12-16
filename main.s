 #include <xc.inc>

 global	datain1, datain2
 
psect data   

test_data:
	db	'T', 'e', 's', 't';, 0x0a		
	counterl EQU 4  
	align	2 
 

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

extrn UART_Setup, UART_Transmit_Message		    ; external uart subroutines
extrn LCD_Setup, LCD_Write_Message, LCD_Write_Instruction   ; external LCD subroutines
;extrn ADC_Setup, ADC_Read				    ; external ADC subroutines   					    ; external timer subroutine
extrn  BPM, goodmessage, restmessage, adjustmessage		    ;, data_value,   external function to write the BPM= and the message on the LCD      BPM,
extrn IC_INIT, IC_write, IC_READ, Addreg, Datareg
;extrn HexDec_Convert

 
psect code, abs   
rst:     
	org 0x0
	goto  setup

           ; ******* Programme FLASH read Setup Code ***********************
	  
setup:     bcf     CFGS		    ; point to Flash program memory 
           bsf     EEPGD	    ; access Flash program memory
	   clrf	   datain1
	   call	   clear
	   call    LCD_Setup	    ; setup LCD: PORTB
	   call	   IC_INIT
	   call	    UART_Setup

;;;;;;;;;;;;;;;;; Configure the Heart rate click;;;;;;;;;;;;;;;;;;;;;;;;;;;
	   movlw    0x06	;set mode register address =>define which mode on the heart rate click we are using
	   movwf    Addreg,A
	   movlw    0x02	;configure mode  HRC
	   movwf    Datareg,A
	   call	    IC_write	
;;	   movlw    0x06	;set mode register address =>define which mode on the heart rate click we are using
;;	   movwf    Addreg,A
;;	   call	    IC_READ
	   
	   movlw    0x07	;reg SPO2 configuration
	   movwf    Addreg,A
	   movlw    0x00	;configure the SPO2 so we want everything to be 0
	   movwf    Datareg,A
	   call	    IC_write
;;	   movlw    0x07	;set mode register address =>define which mode on the heart rate click we are using
;;	   movwf    Addreg,A
;;	   call	    IC_READ
	
	   movlw    0x09	;LED configuration reg
	   movwf    Addreg,A
	   movlw    0x0F	;corresponds to 27.1mA + only for IR
	   movwf    Datareg,A
	   call	    IC_write
;	   movlw    0x09	;set mode register address =>define which mode on the heart rate click we are using
;	   movwf    Addreg,A
;	   call	    IC_READ
	   
;	   movlw    0x05	;check the interrupt status
;	   movwf    Addreg,A
;	   call	    IC_READ
	   
;	   goto checkread
	
	   
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set the pointers to 0x00;;;;;;;;;;;;;;;;;;;;;;
	   
	   movlw    0x02	;FIFO write pointer
	   movwf    Addreg,A
	   movlw    0x00	;corresponds to 27.1mA + only for IR
	   movwf    Datareg,A
	   call	    IC_write
	   
	   movlw    0x03	;Over flow counter
	   movwf    Addreg,A
	   movlw    0x00	;corresponds to 27.1mA + only for IR
	   movwf    Datareg,A
	   call	    IC_write
	   
	   movlw    0x04	;FIFO read pointer
	   movwf    Addreg,A
	   movlw    0x00	;corresponds to 27.1mA + only for IR
	   movwf    Datareg,A
	   call	    IC_write
	   goto	    read_loop
	  
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Read the data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	   
	   ;;;;;;;;;;;;;;;;Collecting data to datain1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	 
;	   movlw    0x00	;Interrupt status
;	   movwf    Addreg,A
;	   call	    IC_READ
;	   movff    Datareg, Interruptbit
;
;	   movlw    0xA1
;	   CPFSEQ   Interruptbit, A
;	   goto	    $-8
	   
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
;	   
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
	   
	   ;;;;;;;;;;;;;;;;Collecting data to datain2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	 
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
;	   
;	   movlw    0x05	;FIFO data register adresss
;	   movwf    Addreg,A
;	   call	    IC_READ
;	   movff    Datareg, datain2+1
	   
	   ;;;;;;;;;;;;;;;;Setting up PORTH as LED data output;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	   
	   
	   movlw    0x00
	   movwf    TRISH
	   movff    datain1, PORTH
	   
	   

write_data_to_message_data:
        lfsr	2, message_data	 
	movff   datain1, POSTINC2
	movlw	1
	lfsr	    2, message_data
	call	UART_Transmit_Message
	
	movff   datain2, POSTINC2
	movlw	1
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

 
;table_read:				;to read test_data	
;	lfsr	0, message_data		; Load FSR0 with address in RAM	
;	movlw	datain1			; address of data
; 	movwf	TBLPTRU, A		; upper bits to TBLPTRU
;	movlw	high(datain1)		; address of data
;	movwf	TBLPTRH, A		; high byte to TBLPTRH
;	movlw	low(datain1)		; address of data
;	movwf	TBLPTRL, A		; llow byte to TBLPTRL
;	
;	movlw	1			; length of bytes to read
;	movwf 	counter, A	
;
;
;loop_table_read:
;        tblrd*+			; move one byte to TABLAT, increment TBLPRT
;	movff	    TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
;;	movff	    TABLAT, PORTG
;	
;	decfsz	    counter, A		; count counter down to zero
;	bra	    loop_table_read		; loop until finished
