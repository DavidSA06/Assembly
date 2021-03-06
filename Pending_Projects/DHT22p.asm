		LIST P=16F877A
		INCLUDE "P16F877A.INC"
		__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF

ANS1					EQU					30H								;INICIALIZACION DE VARIABLES
REGISTRO1				EQU					31H
REGISTRO2				EQU					32H
REGISTRO3				EQU					33H
REGISTRO4				EQU					34H
REGISTRO5				EQU					35H
CONTADOR				EQU					36H



RESET

						ORG					00H
						GOTO				INICIO

						ORG					08H

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACION DE ENTRADAS DEL PIC

INICIO					BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						BCF					STATUS,RP1						;CAMBIO AL BANCO 1
						MOVLW				B'00000000'
						MOVWF				TRISB							;PINES DE B COMO COMO SALIDAS PARA LED

;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACIÓN DEL PUERTO SERIAL

						MOVLW				B'10000000'
						MOVLW				D'25'							;9600  BAUDIOS
						;MOVLW				D'12'							;19200 BAUDIOS
						MOVWF				SPBRG							;BAUDIOS Fosc/(K*(X+1)) X=SPBRG
						BCF					TXSTA,TX9						;TRANSMISION A 8 BITS
						BCF					TXSTA,SYNC						;USART MODO ASINCRONO 
						BSF					TXSTA,BRGH						;BAUDIOS RATE HIGH SPEED K=16
						BSF					TXSTA,TXEN						;TRANSMISION HABILITADA
						MOVLW				B'00000001'						;
						MOVWF				OPTION_REG						;PORTB PULL-UP HABILITADO PREESCALADOR 1:4
						MOVLW				B'10000110'						
						MOVWF				ADCON1
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						BCF					STATUS,RP1						;CAMBIO AL BANCO 0
						CLRF				INTCON							;INTERRUPCIONES NO HABILITADAS
						BSF					RCSTA,SPEN						;PUERTO SERIAL HABILITADO
						BCF					RCSTA,RX9						;RECEPCION A 8 BITS
						BSF					RCSTA,CREN						;RECIBIMIENTO CONTINUO HABILITADO
						CLRF				PORTB


;;;;;;;;;;;;;;;;;;;;;;;;RECEPCION DE DATOS

RCN						BTFSS				PIR1,RCIF						;BANDERA DE RECEPCION ?
						GOTO				RCN
						BCF					PIR1,RCIF						;BAJAR LA BANDERA DE RECEPCION
						MOVFW				RCREG							;REGISTRO DE RECEPCION DE USART
						MOVWF				ANS1							;MOVER A LA CONSTANTE ANS1


;;;;;;;;;;;;;;;;;;;;;;;;CAMBIAR A RUNNING STATUS (TRANSMISIÓN DEL PIC)

						BCF					INTCON,T0IF						;BAJAR LA BANDERA TMR0IF
						BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						BCF					STATUS,RP1						;CAMBIO AL BANCO 1
						MOVLW				B'00000000'
						MOVWF				TRISA							;PINES DE A COMO SALIDA PARA DHT22
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						BCF					STATUS,RP1						;CAMBIO AL BANCO 0
						BCF					PORTA,0							;ENVIAR SENAL GND AL SENSOR
						MOVLW				.5								;1004us (1000 MINIMO)
						MOVWF				TMR0							;COMIENZA EL CONTEO
						BTFSS				INTCON,T0IF						;REVISAR EL DESBORDAMIENTO
						GOTO				$-1
						BCF					INTCON,T0IF						;BAJAR LA BANDERA T0IF
						BSF					STATUS,RP0						;CAMBIO AL BANCO 1
						BCF					STATUS,RP1						;CAMBIO AL BANCO 1
						MOVLW				B'00000001'
						MOVWF				TRISA							;PIN 0 DE A COMO ENTRADA PARA DHT22
						BCF					STATUS,RP0						;CAMBIO AL BANCO 0
						BCF					STATUS,RP1						;CAMBIO AL BANCO 0
REVISION				BTFSC				PORTA,0							;ESPERAR A LA RESPUESTA BAJA DEL SENSOR POR 20~40 us
						GOTO				REVISION
REVISION80A				BTFSS				PORTA,0							;ESPERAR A LA RESPUESTA ALTA DEL SENSOR POR 80 us
						GOTO				REVISION80A 
REVISION80B				BTFSC				PORTA,0							;ESPERAR EL INICIO DE LA TRANSMISION POR 80 us
						GOTO				REVISION80B




;;;;;;;;;;;;;;;;;;;;;;;;ALMACENAMIENTO DE DATOS

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER REGISTRO

REG1					CLRF				PORTB
						CLRF				REGISTRO1
						MOVLW				.7		
						MOVWF				CONTADOR						;CARGAR CONTADOR DE BITS
CINCUENTA1				BTFSS				PORTA,0							;ESPERAR 50 us
						GOTO				$-1
						BCF					INTCON,T0IF
						MOVLW				.246
						MOVWF				TMR0							;CONTAR 40us (26~28us A 70us)
						BTFSC				PORTA,0
						GOTO				$-1
						BTFSS				INTCON,T0IF						;REVISAR DESBORDAMIENTO
						GOTO				UNO1
						GOTO				CERO1


CERO1					RLF					REGISTRO1,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BCF					REGISTRO1,0						;PONER BIT EN 0
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA1						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG2							;PASAR AL SIGUIENTE REGISTRO

UNO1					RLF					REGISTRO1,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BSF					REGISTRO1,0						;PONER BIT EN 1
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA1						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG2							;PASAR AL SIGUIENTE REGISTRO
;;;;;;;;;;;;;;;;;;;;;;;;SEGUNDO REGISTRO

REG2					CLRF				REGISTRO2
						MOVLW				.7		
						MOVWF				CONTADOR						;CARGAR CONTADOR DE BITS
CINCUENTA2				BTFSS				PORTA,0							;ESPERAR 50 us
						GOTO				$-1
						BCF					INTCON,T0IF
						MOVLW				.246
						MOVWF				TMR0							;CONTAR 40us (26~28us A 70us)
						BTFSC				PORTA,0
						GOTO				$-1
						BTFSS				INTCON,T0IF						;REVISAR DESBORDAMIENTO
						GOTO				UNO2
						GOTO				CERO2


CERO2					RLF					REGISTRO2,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BCF					REGISTRO2,0						;PONER BIT EN 0
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA2						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG3							;PASAR AL SIGUIENTE REGISTRO

UNO2					RLF					REGISTRO2,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BSF					REGISTRO2,0						;PONER BIT EN 1
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA2						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG3							;PASAR AL SIGUIENTE REGISTRO
;;;;;;;;;;;;;;;;;;;;;;;;TERCER REGISTRO

REG3					CLRF				REGISTRO3
						MOVLW				.7		
						MOVWF				CONTADOR						;CARGAR CONTADOR DE BITS
CINCUENTA3				BTFSS				PORTA,0							;ESPERAR 50 us
						GOTO				$-1
						BCF					INTCON,T0IF
						MOVLW				.246
						MOVWF				TMR0							;CONTAR 40us (26~28us A 70us)
						BTFSC				PORTA,0
						GOTO				$-1
						BTFSS				INTCON,T0IF						;REVISAR DESBORDAMIENTO
						GOTO				UNO3
						GOTO				CERO3


CERO3					RLF					REGISTRO3,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BCF					REGISTRO3,0						;PONER BIT EN 0
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA3						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG4							;PASAR AL SIGUIENTE REGISTRO

UNO3					RLF					REGISTRO3,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BSF					REGISTRO3,0						;PONER BIT EN 1
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA3						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG4							;PASAR AL SIGUIENTE REGISTRO
;;;;;;;;;;;;;;;;;;;;;;;;CUARTO REGISTRO

REG4					CLRF				REGISTRO4
						MOVLW				.7		
						MOVWF				CONTADOR						;CARGAR CONTADOR DE BITS
CINCUENTA4				BTFSS				PORTA,0							;ESPERAR 50 us
						GOTO				$-1
						BCF					INTCON,T0IF
						MOVLW				.246
						MOVWF				TMR0							;CONTAR 40us (26~28us A 70us)
						BTFSC				PORTA,0
						GOTO				$-1
						BTFSS				INTCON,T0IF						;REVISAR DESBORDAMIENTO
						GOTO				UNO4
						GOTO				CERO4


CERO4					RLF					REGISTRO4,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BCF					REGISTRO4,0						;PONER BIT EN 0
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA4						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG5							;PASAR AL SIGUIENTE REGISTRO

UNO4					RLF					REGISTRO4,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BSF					REGISTRO4,0						;PONER BIT EN 1
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA4						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				REG5							;PASAR AL SIGUIENTE REGISTRO
;;;;;;;;;;;;;;;;;;;;;;;;QUINTO REGISTRO

REG5					CLRF				REGISTRO5
						MOVLW				.7		
						MOVWF				CONTADOR						;CARGAR CONTADOR DE BITS
CINCUENTA5				BTFSS				PORTA,0							;ESPERAR 50 us
						GOTO				$-1
						BCF					INTCON,T0IF
						MOVLW				.246
						MOVWF				TMR0							;CONTAR 40us (26~28us A 70us)
						BTFSC				PORTA,0
						GOTO				$-1
						BTFSS				INTCON,T0IF						;REVISAR DESBORDAMIENTO
						GOTO				UNO5
						GOTO				CERO5


CERO5					RLF					REGISTRO5,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BCF					REGISTRO5,0						;PONER BIT EN 0
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA5						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				ENVIO							;PASAR AL SIGUIENTE REGISTRO

UNO5					RLF					REGISTRO5,1						;CORRER A LA IZQUIERDA ATRAVES DEL CARRY
						BSF					REGISTRO5,0						;PONER BIT EN 1
						DECFSZ				CONTADOR,1						;DECREMENTAR CONTADOR DE BITS
						GOTO				CINCUENTA5						;LA FORMACION DEL REGISTRO NO HA TERMINADO
						GOTO				ENVIO							;PASAR AL SIGUIENTE REGISTRO




;;;;;;;;;;;;;;;;;;;;;;;;TRANSMISION DE DATOS
;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE


ENVIO					MOVFW				REGISTRO1						;MOVER CONVERSION A W
						MOVWF				PORTB
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN1					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN1
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN1
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION


;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE


						MOVFW				REGISTRO2						;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN2					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN2
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN2
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION


;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE


						MOVFW				REGISTRO3						;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN3					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN3
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN3
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE


						MOVFW				REGISTRO4						;MOVER CONVERSION A W
						MOVWF				PORTB
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN4					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN4
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN4
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION

;;;;;;;;;;;;;;;;;;;;;;;;PRIMER BYTE


						MOVFW				REGISTRO5						;MOVER CONVERSION A W
						MOVWF				TXREG							;ENVIAR CONVERSIÓN POR EL PUERTO SERIAL
TXN5					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN5
						BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
						GOTO				TXN5
						BCF					PIR1,TXIF						;BAJAR LA BANDERA DE TRANSMISION
						GOTO				RCN								;IR A LA PARTE DE RECEPCION DE SENAL DE LA COMPUTADORA.






						MOVWF				TRISC

						END

