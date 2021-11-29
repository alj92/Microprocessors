Data:
    ;Multiplyig low by low
   ; db	    1234, 0x02
   movlw    0x12
   movwf    VALL1, A
   movlw    0x15
   movwf    VALL2, A
   movlw    0x34
   movwf    VALH1, A
   movlw    0x20
   movwf    VALH2, A
   
    
HEX_Convert:
    andlw   0xF0    ;using the lowest 4 bits first
    movf    VALL1, W,A ;VAL1 stored in W
    mulwf   VALL2    ;multiplying lowest bits from VAL1*VAL2
    movff   PRODH, RESL2	;result stored in sfr PRODH:PRODL
    movff   PRODL, RESL1
    
    ;Multiplying high by high
    andlw   0x0F    ;using the highest 4 bits first
    movf    VALH1, W,A
    mulwf   VALH2   ;multiplying highest bits VAL1*VAL2
    movff   PRODH, RESH1
    movff   PRODL, RESH2
    
    ;Multiplying low by high
    movf    VALL1, W,A
    mulwf   VALH2   ;multiplying VALL1*VALH2
    ;summing cross products
    movf    PRODL, W,A	;moving multiplication result of VALL1*VALH2 from file register to W
    addwf   RESL1, F	;add low result from both multiplications (low*high) + (low*low)
    movf    PRODH, W,A	
    addwf   RESH2, F	;add high result from both multiplications (low*high) + (high*high)
    clrf    WREG	;clearing working register 
    addwfc  RESH1, F	;adding W+carry bit to F
    
    ;Multiplying high by low
    movf    VALH1, W,A	
    mulwf   VALL2   ;multiplying VALH1*VALL2
    ;summing cross products
    movf    PRODL, W,A
    addwf   RESL1, F	;add high result from both multiplications (high*low) + (low*low)
    movf    PRODH, W,A
    addwf  RESH2, F	;add high result from both multiplications (low*high) + (high*high)
    clrf    WREG	;clearing working register 
    addwfc  RESH1, F	;adding W+carry to F
    return
	

end


