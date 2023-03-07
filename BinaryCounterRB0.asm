;COUNTS IN BINARY USING LEDS IN PORTB EACH TIME RBO IS SET
;MADE BY DAVID SILVA APANGO
		LIST P=16F84A
		INCLUDE "P16F84A.INC"

		;DEFINITIONS

COUNTER		EQU 0CH

RESET
		ORG		00H
		GOTO	START
		
		ORG		04H					;INTERRUPTION
		GOTO	INT

		ORG		08H

;;;;;;;;PIC CONFIGURATION

START	BSF		STATUS,RP0		;SELECT BANK1
		MOVLW	B'00000111'
		MOVWF	OPTION_REG		;MAXIMUM PRESCALER RATE
		MOVLW	B'00000001'
		MOVWF	TRISB			;PIN0 OF PORTB AS INPUT, THE REST AS OUTPUTS
		MOVLW	B'00000000'
		MOVWF	TRISA			;PORTA AS OUTPUT
		BCF		STATUS,RP0		;SELECT BANK0
		MOVLW	B'10010000'
		MOVWF	INTCON			;ENABLE INTERRUPTIONS; ENABLE INTE
		MOVLW	B'00000000'
		MOVWF	PORTB			;PORTB STARTS IN ZERO
		MOVLW	.20
		MOVWF	COUNTER			;LOAD COUNTER (20)
		MOVLW	.59
		MOVWF	TMR0			;LOAD TMR0 (59)


SIGNAL	BTFSS	INTCON,T0IF		;IS TMR0 SET?
		GOTO	SIGNAL			;NO, WAIT
		BCF		INTCON,T0IF		;YES
		DECFSZ	COUNTER,1		;DECREMENT COUNTER
		GOTO	LOAD			;COUNTER,1 IS SET
		MOVLW	.20				;COUNTER,1 IS CLEAR
		MOVWF	COUNTER			;LOAD COUNTER (20)
		INCF	PORTB,1			;INCREMENT PORTB, RESULT IN PORTB
LOAD	MOVLW	.59
		MOVWF	TMR0			;LOAD TMR0 (59)
		GOTO	SIGNAL

INT		BCF		INTCON,INTF		;CLEAR INTERRUPTION FLAG
		BTFSS	PORTA,0			;IS PIN0 ON?
		GOTO	ON				;NO
		BCF		PORTA,0			;YES, TURN OFF LED
		GOTO	RET

ON		BSF		PORTA,0			;TURN ON LED
		GOTO	RET

RET		RETFIE					;END THE INTERRUPTION

		END