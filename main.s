 #include <xc.inc>

 psect code, abs

 goto start

 
extrn sensor_setup, portcsetup, loop, sensorread
extrn UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn LCD_Setup, LCD_Write_Message ; external LCD subroutines
extrn ADC_Setup, ADC_Read               ; external ADC subroutines   
extrn initiate              ; external timer subroutine

psect udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine


psect udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect data   
           ; ******* myTable, data in programme memory, and its length *****

myTable:
        db      'K','e','e','p',' ','G','o','i','n','g','!',0x0a
                                                     ; message, plus carriage return
           myTable_l   EQU  12      ; length of data
           align  2

myTable2:
	db            'T','a','k','e',' ','A',' ','B','r','e','a','k','!',0x0a
                                          ; message, plus carriage return
           myTable_2   EQU  13      ; length of data
           align  2

myTable3:
	db            'R','e','a','d','j','u','s','t',' ','W','a','t','c','h',0x0a
                                          ; message, plus carriage return
           myTable_3   EQU  14      ; length of data
           align  2

psect code, abs   
rst:     org 0x0
goto  setup

           ; ******* Programme FLASH read Setup Code ***********************
setup:          bcf     CFGS ; point to Flash program memory 
           bsf     EEPGD         ; access Flash program memory
	   call initiate
	   call     UART_Setup         ; setup UART
           call     LCD_Setup  ; setup UART
           call     ADC_Setup ; setup ADC
           call    portcsetup
           call    sensor_setup
           call    loop
           call    sensorread
	   goto  start   
   

start:
           lfsr     0, myArray ; Load FSR0 with address in RAM    
           ; put if loop here to change the code depending on the frequency !!
           movlw         low highword(myTable)          ; address of data in PM
           movwf         TBLPTRU, A           ; load upper bits to TBLPTRU
           movlw         high(myTable)      ; address of data in PM
           movwf         TBLPTRH, A           ; load high byte to TBLPTRH
           movlw         low(myTable)       ; address of data in PM
           movwf         TBLPTRL, A            ; load low byte to TBLPTRL
           movlw         myTable_l   ; bytes to read
           movwf         counter, A             ; our counter register
 
;loop:	   tblrd*+                             ; one byte from PM to TABLAT, increment TBLPRT
;           movff TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0   
;           decfsz          counter, A             ; count down to zero
;           bra    loop             ; keep going until finished
;           movlw         myTable_l   ; output message to UART
;           lfsr     2, myArray
;           call     UART_Transmit_Message
;           movlw         myTable_l-1          ; output message to LCD
;                                          ; don't send the final carriage return to LCD
;           lfsr     2, myArray
;           call     LCD_Write_Message

   

 
;         ; ******* Main programme ****************************************

 

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

 
