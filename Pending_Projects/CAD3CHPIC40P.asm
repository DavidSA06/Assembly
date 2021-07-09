		LIST P=16F877A
		INCLUDE "P16F877A.INC"
		__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC & _LVP_OFF & _BODEN_OFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;PROGRAMA EDITADO EL 16-02-2020

;PROGRAMA CON:

;-CONVERSOR ANALOGICO-DIGITAL
;-SENALIZADORES DE CONVERSION DE 8 LEDS EN PUERTO D
;-COMUNICACION SERIAL 9600 BAUDIOS
;-LECTURA DE 3 SENSORES ANALOGICOS
;-SIN SUBRUTINAS EN TRANSMISION DE DATOS (PROBLEMAS CON MODULO BLUETOOTH)

;;;;;;;;;;;;;;;;;;;;;;;;EN PROCESO

;INTERRUPCION SENALIZADORA DEL CAMBIO DE VALVULA (TECLA *)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ANS1					EQU					20H								;INICIALIZACION DE VARIABLES
VALORL					EQU					21H
VALORH					EQU					22H
SENSOR0L				EQU					23H
SENSOR0H				EQU					24H
SENSOR1L				EQU					25H
SENSOR1H				EQU					26H
SENSOR2L				EQU					27H
SENSOR2H				EQU					28H
VALVULA					EQU					29H								;UN BIT PARA NOTIFICAR QUE SE HA HECHO UN CAMBIO DE VALVULAS

RESET

						ORG					00H
						GOTO				INICIO

						ORG					04H
						GOTO				INT

						ORG					08H

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACION DE ENTRADAS DEL PIC

INICIO					BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						BCF					STATUS,RP1						;CAMBIO AL BANCO 1
						MOVLW				B'00101111'						;(RA4 NO SIRVE PARA EL CONVERSOR NO CONTIENE UN AN!)
						MOVWF				TRISA							;ENTRADAS PARA SENSORES ANALOGICOS
						MOVLW				B'00000001'						;ENTRADA DE INTERRUPCION RB0 DE PUERTO B DEL TECLADO
						MOVWF				TRISB							;
						MOVLW				B'10000000'						;PIN RC6 SALIDA DEL PUERTO SERIAL (TX)
						MOVWF				TRISC							;PIN RC7 ENTRADA DEL PUERTO SERIAL (RX)
						MOVLW				B'00000000'
						MOVWF				TRISD							;PINES DE PUERTO D COMO COMO SALIDAS PARA LED

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACION DE PULL-UP Y TEMPORIZACION

						MOVLW				B'11000000'						;PULL-UP HABILITADO
						MOVWF				OPTION_REG						;PREESCALADOR 1:8 (NO SE USA TEMPORIZACION), INTERRUMPIR AL SUBIR

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACIÓN DEL PUERTO SERIAL

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

						MOVLW				B'10010000'						;INTERRUPCION GLOBAL HABILITADA (GIE)
						MOVWF				INTCON							;INTERRUPCION RB0 HABILITADA (INTE)

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACIÓN DEL CONVERSOR ANALOGICO-DIGITAL

						MOVLW 				B'10000001'						;TOSC*32,CANAL 0,CONVERSION NO ACTIVA,CONVERSOR ENCENDIDO
						MOVWF				ADCON0
						BSF					STATUS,RP0						;CAMBIO A BANCO 1
						MOVLW				B'10000000'						;ADRESL, TOSC*32, JUSTIFICADO A LA DERECHA 6 BITS VACIOS EN ADRESH
						MOVWF				ADCON1							;AN7 /A/A/A/A/A/A/A/A/ AN0
						BCF					STATUS,RP0						;CAMBIO A BANCO 0

;;;;;;;;;;;;;;;;;;;;;;;;LIMPIEZA DE REGISTROS

						CLRF				PORTB							;LIMPIEZA DEL PUERTOB
						CLRF				PORTD							;REINICIO DE LEDS
						CLRF				VALORL							;REINICIO DE REGISTROS DE MOVIMIENTO DE CONVERSIONES
						CLRF				VALORH

;;;;;;;;;;;;;;;;;;;;;;;;RECEPCION DE DATOS

RCN						BTFSS				PIR1,RCIF						;BANDERA DE RECEPCION ?
						GOTO				RCN
						MOVF				RCREG,W							;REGISTRO DE RECEPCION DE USART
						MOVWF				ANS1							;MOVER A LA CONSTANTE ANS1
						BCF					PIR1,RCIF						;BAJAR LA BANDERA DE RECEPCION (POSIBLEMENTE INNECESARIO)

;;;;;;;;;;;;;;;;;;;;;;;;ETAPA DE CONVERSION

;;;;;;;;;;;;;;;;;;;;;;;;CONVERSION DE DATOS DEL PRIMER SENSOR (GAS)

						BCF					ADCON0,3						;SELECCION DE CANAL 0
						BCF					ADCON0,4
						BCF					ADCON0,5
						CALL				CONVERSION
						MOVFW				VALORL
						MOVWF				SENSOR0L
						MOVFW				VALORH
						MOVWF				SENSOR0H

;;;;;;;;;;;;;;;;;;;;;;;;CONVERSION DE DATOS DEL SEGUNDO SENSOR (HUMEDAD)

						BSF					ADCON0,3						;SELECCION DE CANAL 1
						BCF					ADCON0,4
						BCF					ADCON0,5
						CALL				CONVERSION
						MOVFW				VALORL
						MOVWF				SENSOR1L
						MOVFW				VALORH
						MOVWF				SENSOR1H
						
;;;;;;;;;;;;;;;;;;;;;;;;CONVERSION DE DATOS DEL TERCER SENSOR (TEMPERATURA)

						BTFSS				VALVULA,0						;REVISAR SI HA CAMBIADO A MEZCLA DE GASES
						GOTO				TEMPERATURA						;SI NO USAR LA MEDICION DE SIEMPRE
						BCF					VALVULA,0						;SI SI ENTONCES BAJAR LA BANDERA
						MOVLW				.82								;40CELSIUS=.82
						MOVWF				SENSOR2L						;CAMBIAR LA SENAL A LA PREDETERMINADA
						CLRF				SENSOR2H						;PARA SABER QUE SE HIZO UN CAMBIO DE VALVULA
						GOTO				TRANSMISION						;SALTAR LA MEDICION Y REPORTAR

TEMPERATURA				BCF					VALVULA,0
						BCF					ADCON0,3						;SELECCION DE CANAL 2
						BSF					ADCON0,4
						BCF					ADCON0,5
						CALL				CONVERSION
						MOVFW				VALORL
						MOVWF				SENSOR2L
						MOVFW				VALORH
						MOVWF				SENSOR2H


;;;;;;;;;;;;;;;;;;;;;;;;TRANSMISION DE DATOS

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER SENSOR

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE

TRANSMISION				MOVFW				SENSOR0H						;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN10					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN10
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN10
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION			
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO BYTE

						MOVFW				SENSOR0L						;OBTENER LOS DOS BITS MAS SIGNIFICATICOS
						MOVWF				TXREG							;ENVIAR CONVERSION POR EL PUERTO SERIAL
TXN20					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN20
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN20
						BCF					PIR1,TXIF						;BAJAR BANDERA DE TRANSMISION


;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO SENSOR

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE

						MOVFW				SENSOR1H						;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN11					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN11
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN11
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION			
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO BYTE

						MOVFW				SENSOR1L						;OBTENER LOS DOS BITS MAS SIGNIFICATICOS
						MOVWF				TXREG							;ENVIAR CONVERSION POR EL PUERTO SERIAL
TXN21					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN21
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN21
						BCF					PIR1,TXIF						;BAJAR BANDERA DE TRANSMISION


;;;;;;;;;;;;;;;;;;;;;;;;TERCER SENSOR

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE

						MOVFW				SENSOR2H						;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN12					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN12
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN12
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION			
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO BYTE

						MOVFW				SENSOR2L						;OBTENER LOS DOS BITS MAS SIGNIFICATICOS
						MOVWF				TXREG							;ENVIAR CONVERSION POR EL PUERTO SERIAL
TXN22					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN22
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN22
						BCF					PIR1,TXIF						;BAJAR BANDERA DE TRANSMISION
						GOTO				RCN								;IR A LA PARTE DE RECEPCION


;;;;;;;;;;;;;;;;;;;;;;;;SUBRUTINAS
;;;;;;;;;;;;;;;;;;;;;;;;SUBRUTINA DE CONVERSION DE DATOS

CONVERSION				BSF					ADCON0,ADON						;ACTIVAR EL MODULO DE CONVERSION
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						NOP
						BSF					ADCON0,GO_DONE					;CONVERSION EN CURSO
ESPERA					BTFSC				ADCON0,GO_DONE					;ESPERAR AL FINAL DE LA CONVERSION
						GOTO				ESPERA
						BCF					ADCON0,ADON						;DESACTIVAR EL MODULO DE CONVERSION	
						BCF					PIR1,ADIF						;BAJAR LA BANDERA DE CONVERSION (POSIBLEMENTE INNECESARIO)

;;;;;;;;;;;;;;;;;;;;;;;;EXTRACCION DE DATOS

						BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						MOVFW				ADRESL							;OBTENER LOS 8 BITS MENOS SIGNIFICATIVOS
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						MOVWF				VALORL							;GUARDAR DATOS MENOS SIGNIFICATIVOS
						MOVWF				PORTD							;MOSTRAR CONVERSION EN LOS LEDS
						MOVFW				ADRESH							;OBTENER LOS 2 BITS MAS SIGNIFICATIVOS
						MOVWF				VALORH							;GUARDAR DATOS MAS SIGNIFICATIVOS
						RETURN

;;;;;;;;;;;;;;;;;;;;;;;;RUTINA DE INTERRUPCION

INT						BCF					INTCON,INTF						;BAJAR LA BANDERA DE INTERRUPCION DEL RB0
						BSF					VALVULA,0						;SUBIR BANDERA DE VALVULA DE GAS
;						BTFSC				PORTC,0							;ESTA ENCENDIDO EL LED
;						GOTO				APAGAR							;NO, APAGAR
;						BSF					PORTC,0							;SI, ENCENDER LED
;						GOTO				VOLVER							;TERMINAR INTERRUPCION
;APAGAR					BCF					PORTC,0							;APAGAR LED

VOLVER					RETFIE												;TERMINAR INTERRUPCION
		
						END


