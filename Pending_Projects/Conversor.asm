		LIST P=16F877A
		INCLUDE "P16F877A.INC"
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF

CONTADOR			EQU 0CH

RESET

					ORG 00H
					GOTO INICIO

					ORG 08H

INICIO				BSF STATUS, RP0		;CAMBIO AL BANCO 1
					MOVLW B'00000001'
					MOVWF TRISA			;PIN DE RA0 COMO ENTRADA PARA CONVERSOR
					MOVLW B'00000000'
					MOVWF TRISB			;PINES DE B COMO COMO SALIDAS PARA LED
					MOVLW B'11000111'
					MOVWF OPTION_REG	;VALOR DEL PRESCALADOR 256
					BCF STATUS,RP0		;CAMBIO AL BANCO 0
					MOVLW B'01000001'	;TOSC*32,CANAL 0,CONVERSION NO ACTIVA,CONVERSOR ENCENDIDO
					MOVWF ADCON0
					BSF STATUS, RP0
					MOVLW B'10000001'	;ADRESL, PINES A/A/A/A, 6 BITS VACIOS EN ADRESH
					MOVWF ADCON1
					BCF STATUS,RP0

CICLO				BSF ADCON0,ADON		;ACTIVAR EL MODULO DE CONVERSION
					NOP					
					NOP
					NOP
					NOP
					BSF ADCON0,GO_DONE	;CONVERSION EN CURSO
ESPERA				BTFSC ADCON0,GO_DONE;ESPERAR AL FINAL DE LA CONVERSION
					GOTO ESPERA
					BCF ADCON0,ADON		;DESACTIVAR EL MODULO DE CONVERSION	
					BCF PIR1,ADIF		;BAJAR LA BANDERA DE CONVERSION




					BSF STATUS,RP0		;CAMBIO AL BANCO 1
					MOVFW ADRESL		;OBTENER LOS 8 BITS MENOS SIGNIFICATIVOS
					BCF STATUS,RP0		;CAMBIO AL BANCO 0
					MOVWF PORTB


					GOTO CICLO



				
				END


