;MULTIPLIES A STORED NUMBER BY AN INPUT NUMBER BY ADDING SEVERAL TIMES
;MADE BY DAVID SILVA APANGO
		LIST P=16F84A
		INCLUDE "P16f84A.INC"
		
;;;;;;;;DEFINITIONS

MULTIPLICAND	EQU 0CH
MULTIPLIER		EQU 0DH
RESULT 			EQU 0EH
CYCLES 			EQU 0FH


RESET
		ORG 00H
		GOTO START

		ORG 08H

START	BSF		STATUS,RP0		;SELECT BANK1
		MOVLW	B'00000111'		;FIRST THREE PINS AS INPUTS
		MOVWF	TRISA
		MOVLW	B'00000000'		;PORTB AS OUTPUT
		MOVWF	TRISB
		BCF		STATUS,RP0		;SELECT BANK0

;;;;;;;;LOAD VARIABLES

LOOP	MOVLW	B'00000000'     ;START IN ZEROS 
		MOVWF	MULTIPLICAND
		MOVWF	MULTIPLIER
		MOVWF	CYCLES
		MOVF	PORTA,0			;MOVE PORTA TO W
		MOVWF	MULTIPLICAND	;MOVE W TO MULTIPLICAND
		MOVLW	.2
		MOVWF	MULTIPLIER		;MOVER W A MULTIPLIER
		MOVWF	CYCLES			;MOVER W A CYCLES
		MOVF	MULTIPLICAND,0	;MOVER MULTIPLICAND A W
		DECFSZ	CYCLES,1		;PARA NO MULTIPLICAR INNECESARIAMENTE UNA VEZ MAS.
		BTFSS	CYCLES,7
		CALL	REPEAT
		CALL	ZERO
		GOTO	LOOP


REPEAT	ADDWF	MULTIPLICAND,0	;SUMAR CYCLES CON W Y DAR RESULT EN W
		DECFSZ	CYCLES,1
		GOTO	REPEAT
		MOVWF	RESULT			;MOVER DE W A RESULT
 		MOVWF	PORTB			;MOVER DE W A PUERTO B
		BCF		STATUS,Z		
		RETURN

ZERO  	MOVLW	.0
		MOVWF	PORTB
		MOVWF	RESULT
		GOTO	RET
		BCF		STATUS,Z
RET		RETURN

END