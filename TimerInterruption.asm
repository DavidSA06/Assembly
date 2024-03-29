;TIMER0 PROGRAM WITH INTERRUPTION
;MADE BY DAVID SILVA APANGO
		LIST P=16F84A
		INCLUDE "P16F84A.INC"

;;;;;;;;DEFINITIONS

COUNTER		EQU 0CH

RESET
		ORG		00H
		GOTO	START

		ORG		04H				;INTERRUPTION
		GOTO	INT

		ORG		08H

;;;;;;;;PIC CONFIGURATION

START	BSF		STATUS,RP0		;SELECT BANK1
   		MOVLW	B'10000111'
		MOVWF	OPTION_REG		;ENABLE PULL-UPS, MAXIMUM PRESCALER RATE
		MOVLW	B'00000000'
		MOVWF	TRISA			;PORTA AS OUTPUTS
		BCF		STATUS,RP0		;SELECT BANK0
		MOVLW	B'10100000'
		MOVWF	INTCON			;ENABLE INTERUPTIONS;ENABLE T0IF

;;;;;;;;LOAD VARIABLES

		MOVLW	.20
		MOVWF	COUNTER			;LOAD COUNTER (20)
		MOVLW	.59
		MOVWF	TMR0			;LOAD TMR0 (59)

;;;;;;;;PROGRAM START

LOOP	GOTO   LOOP


INT		BCF		INTCON,T0IF		;CLEAR T0IF
		DECFSZ	COUNTER,1
		GOTO	LOAD			
		MOVLW	.20
		MOVWF	COUNTER			;LOAD COUNTER (20)
		BTFSC	PORTA,0			;IS THE LED TURNED OFF?
		GOTO	OFF				;NO, TURN ON
		BSF		PORTA,0			;YES, TURN OFF
		GOTO	LOAD
OFF		BCF		PORTA,0			;TURN OFF LED

LOAD	MOVLW	.59
		MOVWF	TMR0			;TMR0 A 59

RET		RETFIE					;END INTERRUPTION
					
		END
