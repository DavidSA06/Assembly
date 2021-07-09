;CHANGE THE PWM WITH A POTENTIOMETER
;MADE BY DAVID SILVA APANGO
		LIST P=16F877A
		INCLUDE "P16F877A.INC"
		__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF

;;;;;;;;DEFINITIONS

TOSC	EQU					20H								;

RESET
		ORG					00H
		GOTO				START

		ORG					08H

;;;;;;;;PIC CONFIGURATION

START	BSF		CCP1CON, CCP1X	;CONFIGURING...
		BSF		CCP1CON, CCP1Y	;...PULSE WIDTH
		BSF		STATUS, RP0		;SELECT BANK1
		MOVLW 	B'11111111'
		MOVWF	TRISA			;PORTA AS INPUT
		MOVLW	B'00000000'
		MOVWF	TRISC			;PORTC AS OUTPUT
		MOVLW	B'01100110'		;128:1 PRESCALER,NO WDT,INCREMENT FROM LOW TO HIGH,PULL-UPS ENABLED
		MOVWF	OPTION_REG		;PIN T0CKI TRANSITION, NTERRUPTION AT HIGH RB0
		MOVLW	B'10000000'
		MOVWF	PR2				;TMR2 PRESCALER
		BCF		STATUS,RP0		;SELECT BANK0
		MOVLW	B'10000001'		;TOSC*32,CHANNEL 0,CONVERSION DISABLED,CONVERTER TURNED ON
		MOVWF	ADCON0
		BSF		STATUS, RP0
		MOVLW	B'00000000'		;ADRESL, PINS A/A/A/A
		MOVWF	ADCON1
		BCF		STATUS,RP0
		MOVLW	B'10000000'
		MOVWF	T2CON			;CONFIGURE TIMER2
		BSF		CCP1CON, CCP1M2	;CONFIGURE...
		BSF		CCP1CON, CCP1M3	;PWM MODE

;;;;;;;;PROGRAM START

CYCLE	BSF		ADCON0,ADON		;ACTIVATE CONVERTER
		NOP
		NOP
		NOP
		NOP
		BSF		ADCON0,GO_DONE	
WAIT	BTFSC	ADCON0,GO_DONE
		GOTO	WAIT
		BCF		PIR1,ADIF		;CLEAR CONVERSION FLAG
		MOVF	ADRESH,0		;PASS CONVERTER DATA... 
		MOVWF	CCPR1L			;TO PWM
		GOTO	CYCLE

		END