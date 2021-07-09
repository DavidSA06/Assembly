		LIST P=16F877A
		INCLUDE "P16F877A.INC"
		__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC & _LVP_OFF & _BODEN_OFF

RESET

						ORG					00H
						GOTO				INICIO

						ORG					08H

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACION DE ENTRADAS DEL PIC

INICIO					BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						BCF					STATUS,RP1						;CAMBIO AL BANCO 1
						MOVLW				B'00000000'
						MOVWF				TRISD							;PINES DE PUERTO D COMO COMO SALIDAS PARA LED

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACION DE PULL-UP Y TEMPORIZACION

						MOVLW				B'00000010'						;PULL-UP HABILITADO
						MOVWF				OPTION_REG						;PREESCALADOR 1:8 (NO SE USA TEMPORIZACION)

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACI�N DEL PUERTO SERIAL

						MOVLW				D'129'							;VELOCIDAD 9600  BAUDIOS
						MOVWF				SPBRG							;BAUDIOS Fosc/(K*(X+1)) X=SPBRG
						BCF					TXSTA,TX9						;TRANSMISION A 8 BITS EN VEZ DE 9
						BCF					TXSTA,SYNC						;USART MODO ASINCRONO
						BSF					TXSTA,BRGH						;BAUDIOS RATE HIGH SPEED K=16 (MENOR ERROR A 9600)
						BSF					TXSTA,TXEN						;TRANSMISION HABILITADA
						BCF					STATUS,RP0						;CAMBIO A BANCO 0
						BSF					RCSTA,SPEN						;PUERTO SERIAL HABILITADO
						BCF					RCSTA,RX9						;RECEPCION A 8 BITS
						BSF					RCSTA,CREN						;RECIBIMIENTO CONTINUO HABILITADO

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACION DE INTERRUPCIONES

						CLRF				INTCON							;INTERRUPCIONES DESHABILITADAS

;;;;;;;;;;;;;;;;;;;;;;;;LIMPIEZA DE REGISTROS

						CLRF				PORTD							;REINICIO DE LEDS

;;;;;;;;;;;;;;;;;;;;;;;;RECEPCION DE DATOS

RCN						BTFSS				PIR1,RCIF						;BANDERA DE RECEPCION ?
						GOTO				RCN
						MOVF				RCREG,W							;REGISTRO DE RECEPCION DE USART
						BCF					PIR1,RCIF						;BAJAR LA BANDERA DE RECEPCION (POSIBLEMENTE INNECESARIO)
						INCF				PORTD,1
						GOTO				RCN

		
						END

