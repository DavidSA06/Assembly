;COUNTS IN HEXADECIMAL USING A LED MATRIX
;MADE BY DAVID SILVA APANGO
		LIST P=16F84A
		INCLUDE "P16F84A.INC"

;;;;;;;;DEFINITIONS

COUNTER		EQU 0CH				;TIMER0 CYCLES
FLAG		EQU 0DH				;COUNT DOWN
MATRIX		EQU 0EH				;UP COUNT
ROW			EQU 0FH				;ROW COUNTING [1,7]


RESET
		ORG 00H
		GOTO START

		ORG 04H
		GOTO INT

		ORG 08H

;;;;;;;;PIC CONFIGURATION

START	BSF		STATUS,RP0		;SELECT BANK1
   		MOVLW	B'00000111'
		MOVWF	OPTION_REG		;MAXIMUM PRESCALER RATE
		MOVLW	B'00000000'
		MOVWF	TRISB			;PORTB AS OUTPUT
		MOVLW	B'00000000'
		MOVWF	TRISA			;PORTA AS OUTPUT
		BCF		STATUS,RP0		;SELECT BANK0
		MOVLW	B'10100000'
		MOVWF	INTCON			;ENABLE INTERRUPTIONS, ENABLE T0IE
		MOVLW	B'00000000'
		MOVWF	PORTB			;PORTB STARTS IN ZERO

;;;;;;;;LOAD VARIABLES

		MOVLW	.6
		MOVWF	ROW				;LOAD ROW (6)
LOAD	MOVLW   .16
		MOVWF   FLAG	    	;LOAD FLAG (16)
		MOVLW   .0
		MOVWF   MATRIX			;MATRIX STARTS IN ZERO

;;;;;;;;PROGRAM START

COUNT	CALL    DELAY
		MOVF    MATRIX,0		;MOVE MATRIX TO W
		CALL    TABLE			;GO TO TABLE
		MOVWF   PORTB			;PRINT IN PORTB
		INCF    MATRIX,1
		DECFSZ  FLAG,1		    ;WAIT FLAG RAISING
		GOTO    COUNT			;NEXT NUMBER
		GOTO    LOAD			;RESTART


DELAY	MOVLW   .100
		MOVWF   COUNTER			;LOAD COUNTER (100)
TIMER	MOVLW   .39
		MOVWF   TMR0			;LOAD COUNTER (39) ~10MS
SIGNAL	BTFSS   INTCON,T0IF		;IS T0IF SET
		GOTO    SIGNAL          ;NO, WAIT
		BCF     INTCON,T0IF		;CLEAR T0IF
		DECFSZ  COUNTER,1
		GOTO    TIMER			;LOAD TMR0
		RETURN



TABLE	ADDWF   PCL,F			;MAKE A COMPUTED GOTO
		GOTO    ZERO			;0
		GOTO    ONE			    ;1
		GOTO    TWO			    ;2
		GOTO    THREE			;3
		GOTO    FOUR			;4
		GOTO    FIVE			;5
		GOTO    SIX	    		;6
		GOTO    SEVEN			;7
		GOTO    EIGHT			;8
		GOTO    NINE			;9
		GOTO    A				;A
		GOTO    BE				;B
		GOTO    C				;C
		GOTO    D				;D
		GOTO    E				;E
		GOTO    F				;F

ZERO	MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00001110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00001110'

ONE		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00000100'
		RETLW   B'00001100'
		RETLW   B'00010100'
		RETLW   B'00000100'
		RETLW   B'00000100'
		RETLW   B'00000100'
		RETLW   B'00011111'

TWO		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00011111'
		RETLW   B'00000001'
		RETLW   B'00000001'
		RETLW   B'00011111'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00011111'

THREE	MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00001110'
		RETLW   B'00010001'
		RETLW   B'00000001'
		RETLW   B'00001110'
		RETLW   B'00000001'
		RETLW   B'00010001'
		RETLW   B'00001110'

FOUR	MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00011111'
		RETLW   B'00000001'
		RETLW   B'00000001'
		RETLW   B'00000001'

FIVE	MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00011111'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00011110'
		RETLW   B'00000001'
		RETLW   B'00010001'
		RETLW   B'00001110'

SIX     MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00001110'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00011110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00001110'

SEVEN	MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00011111'
		RETLW   B'00000001'
		RETLW   B'00000001'
		RETLW   B'00000111'
		RETLW   B'00000001'
		RETLW   B'00000001'
		RETLW   B'00000001'

EIGHT	MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00001110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00001110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00001110'

NINE	MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00001110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00001111'
		RETLW   B'00000001'
		RETLW   B'00010001'
		RETLW   B'00001110'

A		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00001110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00011111'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'

BE		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00011110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00011110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00011110'

C		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00001110'
		RETLW   B'00010001'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00010001'
		RETLW   B'00001110'

D		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00011110'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00010001'
		RETLW   B'00011110'

E		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00011111'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00011110'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00011111'

F		MOVF    ROW,0
		ADDWF   PCL,1			;MAKE A COMPUTED GOTO
		RETLW   B'00011111'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00011110'
		RETLW   B'00010000'
		RETLW   B'00010000'
		RETLW   B'00010000'

INT 	DECFSZ ROW,1
		GOTO RET			;NO
		MOVLW .6
		MOVWF ROW			;LOAD ROW (6)

RET		RETFIE

		END