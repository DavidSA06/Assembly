		LIST P=16F877A
		INCLUDE "P16F877A.INC"
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF

CONTADOR				EQU 0CH
ANS1					EQU					20H								;INICIALIZACION DE VARIABLES
CONSTANTE				EQU					21H
CONSTANTE2				EQU					22H
VALORL					EQU					23H


RESET

						ORG					00H
						GOTO				INICIO

						ORG					08H

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACION DE ENTRADAS DEL PIC

INICIO					BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						BCF					STATUS,RP1
						MOVLW				B'00000001'
						MOVWF				TRISA							;PIN DE RA0 COMO ENTRADA PARA CONVERSOR
						MOVLW				B'00000000'
						MOVWF				TRISB							;PINES DE B COMO COMO SALIDAS PARA LED

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACIÓN DEL PUERTO SERIAL

						MOVLW				B'10000000'
						MOVWF				TRISC
						MOVLW				D'25'							;9600  BAUDIOS
						;MOVLW				D'12'							;19200 BAUDIOS
						MOVWF				SPBRG							;BAUDIOS Fosc/(K*(X+1)) X=SPBRG
						BCF					TXSTA,TX9						;TRANSMISION A 8 BITS
						BCF					TXSTA,SYNC						;USART MODO ASINCRONO 
						BSF					TXSTA,BRGH						;BAUDIOS RATE HIGH SPEED K=16
						BSF					TXSTA,TXEN						;TRANSMISION HABILITADA

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACIÓN DEL CONVERSOR, ETC.

						MOVLW				B'11000111'
						MOVWF				OPTION_REG						;PORTB PULL-UP HABILITADO (SOLO PARA PROGRAMAR)
						BCF					STATUS,RP0
						BCF					STATUS,RP1						;CAMBIO A BANCO 0
						CLRF				INTCON							;INTERRUPCIONES DESHABILITADOS
						BSF					RCSTA,SPEN						;PUERTO SERIAL HABILITADO
						BCF					RCSTA,RX9						;RECEPCION A 8 BITS
						BSF					RCSTA,CREN						;RECIBIMIENTO CONTINUO HABILITADO
						MOVLW 				B'01000001'						;TOSC/32,CANAL 0,CONVERSION NO ACTIVA,CONVERSOR ENCENDIDO
						MOVWF				ADCON0
						BSF					STATUS, RP0						;CAMBIO A BANCO 1
						MOVLW				B'10000000'						;ADRESL, PINES A/A/A/A, 6 BITS VACIOS EN ADRESH
						MOVWF				ADCON1
						BCF					STATUS,RP0						;CAMBIO A BANCO 0

;;;;;;;;;;;;;;;;;;;;;;;;RECEPCION DE DATOS

RCN						BTFSS				PIR1,RCIF						;BANDERA DE RECEPCION ?
						GOTO				RCN
						MOVF				RCREG,W							;REGISTRO DE RECEPCION DE USART
						MOVWF				ANS1							;MOVER A LA CONSTANTE ANS1
						BCF					PIR1,RCIF						;BAJAR LA BANDERA DE RECEPCION

;;;;;;;;;;;;;;;;;;;;;;;;CONVERSION DE DATOS

						BCF					ADCON0,3						;SELECCION DE CANAL 0
						BCF					ADCON0,4
						BCF					ADCON0,5

						BSF					ADCON0,ADON						;ACTIVAR EL MODULO DE CONVERSION
						NOP					
						NOP
						NOP
						NOP
						BSF					ADCON0,GO_DONE					;CONVERSION EN CURSO
ESPERA0					BTFSC				ADCON0,GO_DONE					;ESPERAR AL FINAL DE LA CONVERSION
						GOTO				ESPERA0
						BCF					ADCON0,ADON						;DESACTIVAR EL MODULO DE CONVERSION	
						BCF					PIR1,ADIF						;BAJAR LA BANDERA DE CONVERSION

;;;;;;;;;;;;;;;;;;;;;;;;EXTRACCION DE DATOS MENOS SIGNIFICATIVOS

						BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						MOVFW				ADRESL							;OBTENER LOS 8 BITS MENOS SIGNIFICATIVOS Y DEJARLOS EN EL REGISTRO W
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						MOVWF				VALORL							;ESCRIBIR LOS 8 BITS MENOS SIGNIFICATIVOS EN EL LA CONSTANTE VALORL
;						MOVWF				PORTB							;MOSTRAR LOS 8 BITS MENOS SIGNIFICATIVOS EN LOS LEDS

;;;;;;;;;;;;;;;;;;;;;;;;TRANSMISION DE DATOS

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE
						MOVFW				VALORL							;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN10					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN10
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN10
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION			
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO BYTE
						MOVFW				ADRESH							;OBTENER LOS DOS BITS MAS SIGNIFICATICOS
						MOVWF				TXREG							;ENVIAR CONVERSION POR EL PUERTO SERIAL
TXN20					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN20
						BCF					PIR1,TXIF						;BAJAR BANDERA DE TRANSMISION
						;GOTO				RCN								;IR A LA PARTE DE RECEPCION

;;;;;;;;;;;;;;;;;;;;;;;;CONVERSION DE DATOS

						BSF					ADCON0,3						;SELECCION DE CANAL 1
						BCF					ADCON0,4
						BCF					ADCON0,5

						BSF					ADCON0,ADON						;ACTIVAR EL MODULO DE CONVERSION
						NOP					
						NOP
						NOP
						NOP
						BSF					ADCON0,GO_DONE					;CONVERSION EN CURSO
ESPERA1					BTFSC				ADCON0,GO_DONE					;ESPERAR AL FINAL DE LA CONVERSION
						GOTO				ESPERA1
						BCF					ADCON0,ADON						;DESACTIVAR EL MODULO DE CONVERSION	
						BCF					PIR1,ADIF						;BAJAR LA BANDERA DE CONVERSION

;;;;;;;;;;;;;;;;;;;;;;;;EXTRACCION DE DATOS MENOS SIGNIFICATIVOS

						BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						MOVFW				ADRESL							;OBTENER LOS 8 BITS MENOS SIGNIFICATIVOS Y DEJARLOS EN EL REGISTRO W
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						MOVWF				VALORL							;ESCRIBIR LOS 8 BITS MENOS SIGNIFICATIVOS EN EL LA CONSTANTE VALORL
;						MOVWF				PORTB							;MOSTRAR LOS 8 BITS MENOS SIGNIFICATIVOS EN LOS LEDS

;;;;;;;;;;;;;;;;;;;;;;;;TRANSMISION DE DATOS

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE
						MOVFW				VALORL							;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN11					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN11
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN11
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION			
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO BYTE
						MOVFW				ADRESH							;OBTENER LOS DOS BITS MAS SIGNIFICATICOS
						MOVWF				TXREG							;ENVIAR CONVERSION POR EL PUERTO SERIAL
TXN21					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN21

						BCF					PIR1,TXIF						;BAJAR BANDERA DE TRANSMISION
						;GOTO				RCN								;IR A LA PARTE DE RECEPCION

;;;;;;;;;;;;;;;;;;;;;;;;CONVERSION DE DATOS

						BCF					ADCON0,3						;SELECCION DE CANAL 2
						BSF					ADCON0,4
						BCF					ADCON0,5

						BSF					ADCON0,ADON						;ACTIVAR EL MODULO DE CONVERSION
						NOP					
						NOP
						NOP
						NOP
						BSF					ADCON0,GO_DONE					;CONVERSION EN CURSO
ESPERA2					BTFSC				ADCON0,GO_DONE					;ESPERAR AL FINAL DE LA CONVERSION
						GOTO				ESPERA2
						BCF					ADCON0,ADON						;DESACTIVAR EL MODULO DE CONVERSION	
						BCF					PIR1,ADIF						;BAJAR LA BANDERA DE CONVERSION

;;;;;;;;;;;;;;;;;;;;;;;;EXTRACCION DE DATOS MENOS SIGNIFICATIVOS

						BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						MOVFW				ADRESL							;OBTENER LOS 8 BITS MENOS SIGNIFICATIVOS Y DEJARLOS EN EL REGISTRO W
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						MOVWF				VALORL							;ESCRIBIR LOS 8 BITS MENOS SIGNIFICATIVOS EN EL LA CONSTANTE VALORL
;						MOVWF				PORTB							;MOSTRAR LOS 8 BITS MENOS SIGNIFICATIVOS EN LOS LEDS

;;;;;;;;;;;;;;;;;;;;;;;;TRANSMISION DE DATOS

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE
						MOVFW				VALORL							;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN12					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN12
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN12
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION			
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO BYTE
						MOVFW				ADRESH							;OBTENER LOS DOS BITS MAS SIGNIFICATICOS
						MOVWF				TXREG							;ENVIAR CONVERSION POR EL PUERTO SERIAL
TXN22					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN22
						BCF					PIR1,TXIF						;BAJAR BANDERA DE TRANSMISION
						;GOTO				RCN								;IR A LA PARTE DE RECEPCION


;;;;;;;;;;;;;;;;;;;;;;;;CONVERSION DE DATOS

						BSF					ADCON0,3						;SELECCION DE CANAL 3
						BSF					ADCON0,4
						BCF					ADCON0,5

						BSF					ADCON0,ADON						;ACTIVAR EL MODULO DE CONVERSION
						NOP					
						NOP
						NOP
						NOP
						BSF					ADCON0,GO_DONE					;CONVERSION EN CURSO
ESPERA3					BTFSC				ADCON0,GO_DONE					;ESPERAR AL FINAL DE LA CONVERSION
						GOTO				ESPERA3
						BCF					ADCON0,ADON						;DESACTIVAR EL MODULO DE CONVERSION	
						BCF					PIR1,ADIF						;BAJAR LA BANDERA DE CONVERSION

;;;;;;;;;;;;;;;;;;;;;;;;EXTRACCION DE DATOS MENOS SIGNIFICATIVOS

						BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						MOVFW				ADRESL							;OBTENER LOS 8 BITS MENOS SIGNIFICATIVOS Y DEJARLOS EN EL REGISTRO W
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						MOVWF				VALORL							;ESCRIBIR LOS 8 BITS MENOS SIGNIFICATIVOS EN EL LA CONSTANTE VALORL
						MOVWF				PORTB							;MOSTRAR LOS 8 BITS MENOS SIGNIFICATIVOS EN LOS LEDS

;;;;;;;;;;;;;;;;;;;;;;;;TRANSMISION DE DATOS

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE
						MOVFW				VALORL							;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN13					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN13
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN13
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION			
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO BYTE
						MOVFW				ADRESH							;OBTENER LOS DOS BITS MAS SIGNIFICATICOS
						MOVWF				TXREG							;ENVIAR CONVERSION POR EL PUERTO SERIAL
TXN23					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN23
						BCF					PIR1,TXIF						;BAJAR BANDERA DE TRANSMISION
						GOTO				RCN								;IR A LA PARTE DE RECEPCION

		
						END


