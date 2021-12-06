#include <xc.inc>

global  BPM, goodmessage, restmessage, adjustmessage
extrn LCD_Setup, LCD_Write_Message, LCD_Write_Instruction   ; external LCD subroutines

psect udata_bank4   ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect data   
           ; ******* myTable, data in programme memory, and its length *****

myTable:
        db      'K','e','e','p',' ','G','o','i','n','g','!',0x0a
						; message, plus carriage return
           myTable_0   EQU  11			; length of data
           align  2

myTable2:
	db            'T','a','k','e',' ','A',' ','B','r','e','a','k','!',0x0a
					    ; message, plus carriage return
           myTable_2   EQU  13		    ; length of data
           align  2

myTable3:
	db            'R','e','a','d','j','u','s','t',' ','W','a','t','c','h',0x0a
					    ; message, plus carriage return
           myTable_3   EQU  14		    ; length of data
           align  2
	  
myTable4:
	db            'B','P','M','=',0x0a
					    ; message, plus carriage return
           myTable_4   EQU  4		    ; length of data
           align  2
	   
psect udata_acs	    ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	message_code,class=CODE


BPM: 
	   lfsr		 0, myArray		; Load FSR0 with address in RAM    
           ; put if loop here to change the code depending on the frequency !!
           movlw         low highword(myTable4)  ; address of data in PM
           movwf         TBLPTRU, A		; load upper bits to TBLPTRU
           movlw         high(myTable4)		; address of data in PM
           movwf         TBLPTRH, A		; load high byte to TBLPTRH
           movlw         low(myTable4)		; address of data in PM
           movwf         TBLPTRL, A		; load low byte to TBLPTRL
           movlw         myTable_4		; bytes to read
           movwf         counter, A             ; our counter register
 
BPMloop:
	   tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
           movff	   TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0   
           decfsz          counter, A           ; count down to zero
           bra		   BPMloop			; keep going until finished
           movlw	   myTable_4		; output message to UART
;           lfsr		   2, myArray
;           call		   UART_Transmit_Message
	   
	   movlw	   10000000B	; position address instruction -> to write on the first line
	   call		   LCD_Write_Instruction

           movlw	   myTable_4		; output message to LCD
						; don't send the final carriage return to LCD
           lfsr		   2, myArray
           call		   LCD_Write_Message
	   return

	
	
goodmessage:	

	   lfsr		 0, myArray		; Load FSR0 with address in RAM 
	   movlw         low highword(myTable)  ; address of data in PM
           movwf         TBLPTRU, A		; load upper bits to TBLPTRU
           movlw         high(myTable)		; address of data in PM
           movwf         TBLPTRH, A		; load high byte to TBLPTRH
           movlw         low(myTable)		; address of data in PM
           movwf         TBLPTRL, A		; load low byte to TBLPTRL
           movlw         myTable_0		; bytes to read
           movwf         counter, A             ; our counter register
goodloop:	
	    
	   tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
           movff	   TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0   
           decfsz          counter, A           ; count down to zero
           bra		   goodloop			; keep going until finished
           movlw	   myTable_0		; output message to UART
;           lfsr		   2, myArray
;           call		   UART_Transmit_Message
	   
	   movlw	   11000000B	; position address instruction -> to write on the second line
	   call		   LCD_Write_Instruction

           movlw	   myTable_0		; output message to LCD
						; don't send the final carriage return to LCD
           lfsr		   2, myArray
           call		   LCD_Write_Message
	   return
	   
restmessage:	

	   lfsr		 0, myArray		; Load FSR0 with address in RAM 
	   movlw         low highword(myTable2)  ; address of data in PM
           movwf         TBLPTRU, A		; load upper bits to TBLPTRU
           movlw         high(myTable2)		; address of data in PM
           movwf         TBLPTRH, A		; load high byte to TBLPTRH
           movlw         low(myTable2)		; address of data in PM
           movwf         TBLPTRL, A		; load low byte to TBLPTRL
           movlw         myTable_2		; bytes to read
           movwf         counter, A             ; our counter register
restloop:	
	    
	   tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
           movff	   TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0   
           decfsz          counter, A           ; count down to zero
           bra		   restloop			; keep going until finished
           movlw	   myTable_2		; output message to UART
	   
	   movlw	   11000000B	; position address instruction -> to write on the second line
	   call		   LCD_Write_Instruction

           movlw	   myTable_2		; output message to LCD
						; don't send the final carriage return to LCD
           lfsr		   2, myArray
           call		   LCD_Write_Message
	   return

adjustmessage:	

	   lfsr		 0, myArray		; Load FSR0 with address in RAM 
	   movlw         low highword(myTable3)  ; address of data in PM
           movwf         TBLPTRU, A		; load upper bits to TBLPTRU
           movlw         high(myTable3)		; address of data in PM
           movwf         TBLPTRH, A		; load high byte to TBLPTRH
           movlw         low(myTable3)		; address of data in PM
           movwf         TBLPTRL, A		; load low byte to TBLPTRL
           movlw         myTable_3	; bytes to read
           movwf         counter, A             ; our counter register
adjustloop:	
	    
	   tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
           movff	   TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0   
           decfsz          counter, A           ; count down to zero
           bra		   adjustloop			; keep going until finished
           movlw	   myTable_3		; output message to UART
;           lfsr		   2, myArray
;           call		   UART_Transmit_Message
	   
	   movlw	   11000000B	; position address instruction -> to write on the second line
	   call		   LCD_Write_Instruction

           movlw	   myTable_3	; output message to LCD
						; don't send the final carriage return to LCD
           lfsr		   2, myArray
           call		   LCD_Write_Message
	   return
	
	   end