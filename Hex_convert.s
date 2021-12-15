;#include <xc.inc>
;    
;global HexDec_Convert
;extrn	datain1
;    
;psect	udata_acs   ; reserve data space in access ram
;ARG1H:	ds  1    ; kH 
;ARG1L:	ds  1	 ; kL
;	
;ARG2H:	ds  1	 ; value H
;ARG2L:	ds  1	 ; value L
;
;RES3:	ds  1	; final output 3
;RES2:	ds  1	; final output 2
;RES1:	ds  1	; final output 1
;RES0:	ds  1	; final output 0
;    
;OUT3:	ds  1	; decimal in hex output 3
;OUT2:	ds  1	; decimal in hex output 2
;OUT1:	ds  1	; decimal in hex output 1
;OUT0:	ds  1	; decimal in hex output 0   
;    
;psect code
;    
;HexDec_Convert:
;
;	movlw	0x01
;	movwf	ARG1L, A
;	movlw	0x00
;	movwf	ARG1H, A
;	
;	; voltage lower
;	movf	ADRESL, W, A
;	movwf	ARG2L, A
;	; voltage higher
;	movf	ADRESH, W, A
;	movwf	ARG2H, A
;	
;	call	MUL16x16
;	movff	RES3, OUT3, A
;	clrf	RES3, A
;	
;	; decimal 10 lower
;	movlw	0x0A
;	movwf	ARG1L, A
;	
;	; RES2, RES1, RES0 -> ARG1H, ARG2H, ARG2L
;	
;	; residue RES2 -> ARG1H
;	movf	RES2, W, A
;	movwf	ARG1H, A
;	; residue RES1 -> ARG2H
;	movf	RES1, W, A
;	movwf	ARG2H, A
;	; residue RES0 -> ARG2L
;	movf	RES0,W, A
;	movwf	ARG2L, A
;	
;	call	MUL8x24
;	
;	; residue higher
;	movf	RES1, W, A
;	movwf	ARG2H, A
;	call	MUL16x16
;	movff	RES2, OUT1, A
;	clrf	RES2, A
;	; residue lower
;	movf	RES0, W, A
;	movwf	ARG2L, A
;	
;	; residue higher
;	movf	RES1, W, A
;	movwf	ARG2H, A
;	
;	call	MUL16x16
;	movff	RES2, OUT0, A
;	clrf	RES2, A
;	
;	rlncf	OUT3, A
;	rlncf	OUT3, A
;	rlncf	OUT3, A
;	rlncf	OUT3, W, A
;	addwf	OUT2, W, A
;	movwf	ADRESH, A
;	
;	rlncf	OUT1, A
;	rlncf	OUT1, A
;	rlncf	OUT1, A
;	rlncf	OUT1, W, A
;	addwf	OUT0, W, A
;	movwf	ADRESL, A	
;	
;	return
;	
;MUL16x16:
;	; multiplication
;	
;	MOVF	ARG1L, W, A
;	MULWF	ARG2L, A	; ARG1L * ARG2L->
;			; PRODH:PRODL
;	MOVFF	PRODH, RES1 ;
;	MOVFF	PRODL, RES0 ;
;    ;
;	MOVF	ARG1H, W, A
;	MULWF	 ARG2H, A ; ARG1H * ARG2H->
;		    ; PRODH:PRODL
;	MOVFF	PRODH, RES3 ;
;	MOVFF	PRODL, RES2 ;
;    ;
;	MOVF	ARG1L, W, A
;	MULWF	ARG2H, A ; ARG1L * ARG2H->
;		    ; PRODH:PRODL
;	MOVF	PRODL, W, A ;
;	ADDWF	RES1, F, A ; Add cross
;	MOVF	PRODH, W, A ; products
;	ADDWFC	RES2, F, A ;
;	CLRF	WREG, A ;
;	ADDWFC	RES3, F, A ;
;    ;
;	MOVF	ARG1H, W, A ;
;	MULWF	ARG2L, A ; ARG1H * ARG2L->
;		    ; PRODH:PRODL
;	MOVF	PRODL, W, A ;
;	ADDWF	RES1, F, A ; Add cross
;	MOVF	PRODH, W, A ; products
;	ADDWFC	RES2, F, A ;
;	CLRF	WREG, A ;
;	ADDWFC	RES3, F, A ;
;	
;	return 
;
;
;	
;MUL8x24:
;	; ARG1L = 8bit number 
;	; ARG1H, ARG2H, ARG2L => 24bit number (highest, high, low)
;	; We have RES3, RES2, RES1, RES0 to play with 
;	; multiplication
;	CLRF	RES3, A
;	CLRF	RES2, A
;	CLRF	RES1, A
;	CLRF	RES0, A
;	BCF	3, 0, A
;	
;	MOVF	ARG1L, W, A
;	MULWF	ARG2L, A	; ARG1L * ARG2L->
;			; PRODH:PRODL
;	MOVFF	PRODH, RES1 ;
;	MOVFF	PRODL, RES0 ;
;	
;	MOVF	ARG1L, W, A
;	MULWF	ARG2H, A ; ARG1L * ARG1H->
;;		    ; PRODH:PRODL
;;	
;	MOVF	PRODL, W, A
;	ADDWF	RES1, A
;	BTFSC	3, 0, A
;	INCF	RES2, A
;	
;	MOVF	PRODH, W, A
;	ADDWF	RES2, A
;	
;	MOVF	ARG1L, W, A
;	MULWF	ARG1H, A
;	MOVF	PRODL, W, A
;	ADDWF	RES2, A
;	BTFSC	3, 0, A
;	INCF	RES3, A
;	MOVF	PRODH, W, A
;	ADDWF	RES3, A
;	
;	return 
;
