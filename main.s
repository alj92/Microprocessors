    #include <xc.inc>

psect	code, abs

goto start

extrn	sensor_setup, portcsetup, loop
    
psect	code, abs	

start: 
    call    portcsetup
    call    sensor_setup
    call    loop
    
    
       
;Start:	
;    movlw	0x00	;all bits in
;    movwf	TRISD, A ;port D direction Register
;    movff	0x00, PORTD	
;    call	SPI_MasterInit
;    call	SPI_MasterTransmit
;		
;
;SPI_MasterInit:	    ;Set Clock edge to negative
;    bcf CKE2	    ; CKE bit in SSP2STAT
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
;	btfss	SSP2IF	;check interrupt flag to see if data has been sent
;	bra Wait_Transmit
;	bcf SSP2IF  ;clear interrupt flag
;	return
;	

	

