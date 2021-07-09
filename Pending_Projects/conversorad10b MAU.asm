LIST P=16F877A
INCLUDE "P16F877A.INC"
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF
;DEFINICIONES DE INSTRUCCIONES

#DEFINE ENABLE		BSF 	PORTD,2			;ACTIVA E
#DEFINE DISABLE 	BCF 	PORTD,2			;DESACTIVA E
#DEFINE LEER		BSF 	PORTD,1			;MODO RD
#DEFINE ESCRIBIR	BCF 	PORTD,1			;MODO WR
#DEFINE ONCOMM		BSF 	PORTD,0			;MODO DATOS
#DEFINE OFFCOMM		BCF 	PORTD,0			;MODO COMANDO

CONSTANTE 			EQU 20H					;OCHO BITS MENOS SIGNIFICATIVOS (ADRESL)
CONSTANTE2			EQU 21H					;DOS BITS MAS SIGNIFICATIVOS (ADRESH)
ITERACIONES			EQU 22H
DECUNI				EQU 23H					;REGISTRO DE DECENAS Y UNIDADES
MILCEN				EQU 24H					;REGISTRO DE MILLARES Y CENTENAS
SUMA3				EQU 25H					;00000011
SUMA4				EQU 26H					;00000100
SUMA48				EQU 27H					;00110000
SUMA
DECUNIP				EQU 28H			;
MILCENP				EQU 29H			;

CONTADOR			EQU 	30H				;CONTEO DE TEMPORIZACION

RESET

					ORG 	00H
					GOTO 	INICIO


					ORG 	08H

;;;;;;;;;;;;;;;;;;;;RETARDOS

RETARDO2			MOVLW 	.248
					MOVWF 	TMR0			;CARGAR 248 AL TMR0
SENAL2				BTFSS 	INTCON,T0IF		;REVISAR LA BANDERA DE INTERRUPCION
					GOTO 	SENAL2
					BCF 	INTCON,T0IF		;BAJAR LA BANDERA DE INTERRUPCION
					RETURN

RETARDO10			MOVLW 	.216
					MOVWF 	TMR0			;CARGAR 216 AL TMR0
SENAL10				BTFSS 	INTCON,T0IF		;REVISAR LA BANDERA DE INTERRUPCION
					GOTO 	SENAL10
					BCF 	INTCON,T0IF		;BAJAR LA BANDERA DE INTERRUPCION
					RETURN

RETARDO40			MOVLW 	.99
					MOVWF 	TMR0			;CARGAR 99 AL TMR0
SENAL40				BTFSS 	INTCON,T0IF		;REVISAR LA BANDERA DE INTERRUPCION
					GOTO 	SENAL40
					BCF 	INTCON,T0IF		;BAJAR LA BANDERA DE INTERRUPCION
					RETURN

;					CALL 	RETARDO250

;RETARDO250			MOVLW 	.5				;250 MILISEGUNDOS
;					MOVWF 	CONTADOR		;5 CICLOS DE CONTEO
;TEMPORIZADOR		MOVLW 	.61				;50 MILISEGUNDOS
;					MOVWF 	TMR0			;CARGAR 61 AL TMR0

;SENAL50			BTFSS 	INTCON,T0IF		;REVISAR LA BANDERA DE INTERRUPCION
;					GOTO 	SENAL
;					BCF 	INTCON,T0IF		;BAJAR LA BANDERA DE INTERRUPCION
;					DECFSZ 	CONTADOR		;DECREMENTAR CONTADOR
;					GOTO 	TEMPORIZADOR
;					RETURN

;;;;;;;;;;;;;;;;;;;;SE�AL DE ACTIVACION PARA LA LCD
;revisa				COMANDO
;					LEER; Llama la definici�n LEER
;					bsf			STATUS,RP0
;					bsf			PORTD,7
;					bcf			STATUS,RP0
;					HABILITAR; Llama la definici�n HABILITAR
;					nop
;checa				btfsc		PORTD,7	; Checa la bandera de ocupado (bit 7 del PUERTO B)
;					goto		checa
;					DESHABILITAR; Llama la definici�n DESHABILITAR
;					bsf			STATUS,RP0
;					clrf		PORTD
;					bcf			STATUS,RP0
;					ESCRIBIR; Llama la definici�n ESCRIBIR
;					return

;;;;;;;;;;;;;;;;;;;;SE�AL DE ACTIVACION PARA LA LCD

LCD_E				ENABLE					;MANDAR UN PULSO A LA SENAL DE ACTIVACION
					NOP
					DISABLE
					RETURN

;;;;;;;;;;;;;;;;;;;;INSTRUCCIONES A LA LCD

CLRD				MOVLW 	B'00000001'		;LIMPIAR EL DISPLAY
					MOVWF 	PORTB
					CALL 	LCD_E
					CALL 	RETARDO2
					RETURN

FUNCTNSET			MOVLW 	B'00110000'		;BUS DE 8 BITS, PRESENTACION EN UNA LINEA, CARACTER DE 5X7
					MOVWF 	PORTB
					CALL 	LCD_E
					CALL 	RETARDO40
					RETURN	

DISPON				MOVLW 	B'00001111'		;LA PANTALLA Y EL CURSOR ESTAN ENCENDIDOS, EL CURSOR PARPADEA
					MOVWF 	PORTB
					CALL 	LCD_E
					CALL 	RETARDO40
					RETURN

DISPOFF				MOVLW 	B'00001100'		;EL CURSOR ESTA APAGADOS
					MOVWF 	PORTB
					CALL 	LCD_E
					CALL 	RETARDO40
					RETURN

EMDSTD				MOVLW 	B'00000110'		;EL CURSOR SE DESPLAZA POR CADA DATO A LA DERECHA
					MOVWF 	PORTB
					CALL 	LCD_E
					CALL 	RETARDO40
					RETURN

HOME				MOVLW 	B'00000010'		;POSICIONAR EL CURSOR EN CERO
					MOVWF 	PORTB
					CALL 	LCD_E
					CALL 	RETARDO2
					RETURN

EMDSTI				MOVLW 	B'00000100'		;EL CURSOR SE DESPLAZA POR CADA DATO A LA IZQUIERDA
					MOVWF 	PORTB
					CALL 	LCD_E
					CALL 	RETARDO40
					RETURN


;;;;;;;;;;;;;;;;;;;;RUTINAS RECOMENDADAS DEL LIBRO

LCD_BUSY			LEER
					BSF 	STATUS,RP0		;CAMBIO A BANCO 1
					MOVLW 	H'FF'
					MOVWF 	TRISB			;PUERTO B COMO ENTRADA
					BCF 	STATUS,RP0		;CAMBIO A BANCO 0
					ENABLE					;ACTIVA E
					NOP
L_BUSY				BTFSC 	PORTB,7			;CHECA EL BIT DE BUSY
					GOTO 	L_BUSY
					DISABLE					;DESACTIVA E
					BSF 	STATUS,RP0		;CAMBIO A BANCO 1
					CLRF 	TRISB			;PUERTO B COMO SALIDA
					BCF 	STATUS,RP0		;CAMBIO AL BANCO 0
					ESCRIBIR
					RETURN

;;;;;;;;;;;;;;;;;;;;MENSAJE HOLA

HOLA;				MOVLW 	B'00000000'		;LIMPIAR EL DISPLAY
;					MOVWF 	PORTB

					MOVLW 	H'AB'			;KO
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'DD'			;N
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'6C'			;NI
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'1C'			;CHI
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'DC'			;WA
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					RETURN

;;;;;;;;;;;;;;;;;;;;NUMERO DE ITERACIONES PARA XS3

DIEZ				MOVLW .9
					MOVWF ITERACIONES
					GOTO CORRIMIENTO3

NUEVE				MOVLW .8
					MOVWF ITERACIONES
					GOTO CORRIMIENTO2

OCHO				MOVLW .7
					MOVWF ITERACIONES
					GOTO CORRIMIENTO

SIETE				MOVLW .6
					MOVWF ITERACIONES
					RLF CONSTANTE
					GOTO CORRIMIENTO

SEIS				MOVLW .5
					MOVWF ITERACIONES
					RLF CONSTANTE
					RLF CONSTANTE
					GOTO CORRIMIENTO

CINCO				MOVLW .4
					MOVWF ITERACIONES
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					GOTO CORRIMIENTO

CUATRO				MOVLW .3
					MOVWF ITERACIONES
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					GOTO CORRIMIENTO

TRES				MOVLW .2
					MOVWF ITERACIONES
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					GOTO CORRIMIENTO

DOS					MOVLW .1
					MOVWF ITERACIONES
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					GOTO CORRIMIENTO

UNO					MOVLW .0
					MOVWF ITERACIONES
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					RLF CONSTANTE
					GOTO CORRIMIENTO

CERO				GOTO CORRIMIENTO

;;;;;;;;;;;;;;;;;;;;RUTINA PARA IMPRIMIR UN NUMERO [1,1023]X0.00488V

NUMERO				MOVLW	DECUNI			;COMENZAR CON LAS UNIDADES
					BSF		W,4				;ENVIAR A LCD [UNIDADES,3]={0,9}
					BSF		W,5
					BCF		W,6
					BCF		W,7
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW	DECUNI			;SEGUIR CON LAS DECENAS
					RRF		W,0				;ROTAR HASTA QUE LAS DECENAS SEAN LOS BITS DE MENOS PESO
					RRF		W,0
					RRF		W,0
					RRF		W,0
					BSF		W,4				;ENVIAR A LCD [DECENAS,3]={0,90,10}
					BSF		W,5
					BCF		W,6
					BCF		W,7
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW	MILCEN			;SEGUIR CON LAS CENTENAS
					BSF		W,4				;ENVIAR A LCD [CENTENAS,3]={0,900,100}
					BSF		W,5
					BCF		W,6
					BCF		W,7
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW	MILCEN			;SEGUIR CON LOS MILLARES
					RRF		W,0				;ROTAR HASTA QUE LOS MILLARES SEAN LOS BITS DE MENOS PESO
					RRF		W,0
					RRF		W,0
					RRF		W,0
					BSF		W,4				;ENVIAR A LCD [MILLARES,3]={0,9000,1000}
					BSF		W,5
					BCF		W,6
					BCF		W,7
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'85'			;X
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'30'			;0
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'2E'			;.
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'30'			;0
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'30'			;0
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'34'			;4
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E

					MOVLW 	H'34'			;4
					OFFCOMM
					MOVWF 	PORTB
					CALL 	LCD_BUSY
					ONCOMM
					CALL 	LCD_E


INICIO				;BANKSEL TRISA
					BSF 	STATUS, RP0		;CAMBIO AL BANCO 1
					MOVLW 	B'00000001'
					MOVWF 	TRISA			;PINES DE RA0 COMO ENTRADA PARA CONVERSOR SALIDAS PARA LCD
					MOVLW 	B'00000000'
					MOVWF 	TRISB			;PINES DE B COMIENZAN COMO SALIDAS PARA LCD
;					MOVLW 	B'01000000'
;					MOVWF 	TRISC			;PIN C6 COMO ENTRADA, C7 COMO SALIDA PARA COMUNICACION
					MOVLW 	B'00000000'
					MOVWF 	TRISD			;PINES DE D COMO SALIDAS PARA LCD
					MOVLW 	B'00000111'
					MOVWF 	OPTION_REG		;VALOR DEL PRESCALADOR 256
					



					MOVLW		D'25'		;9600  BAUDIOS
					MOVWF		SPBRG		;BAUDIOS Fosc/(K*(X+1)) X=SPBRG
					BCF			TXSTA,TX9	;TRANSMISION A 8 BITS
					BCF			TXSTA,SYNC	;USART MODO ASINCRONO 
					BSF			TXSTA,BRGH	;BAUDIOS RATE HIGH SPEED K=16
					BSF			TXSTA,TXEN	;TRANSMISION HABILITADA
					;MOVLW		B'10000000'
					;MOVWF		OPTION_REG	;PORTB PULL-UP HABILITADO (SOLO PARA PROGRAMAR)
					BCF			STATUS,RP0
					BCF			STATUS,RP1	;BANCO 0
					CLRF		INTCON		;INTERRUPCIONES DESHABILITADOS
					BSF			RCSTA,SPEN	;PUERTO SERIAL HABILITADO
					BCF			RCSTA,RX9	;RECEPCION A 8 BITS
					BSF			RCSTA,CREN	;RECEPCION CONTINUA





;					BCF		TXSTA,SYNC		;MODO ASINCRONO DE USART
;					BSF		PIE1,TXIE		;HABILITAR INTERRUPCION POR TRANSMISION
;					BSF		TXSTA,TX9		;HABILITAR EL NOVENO BIT DE COMUNICACION
;					BCF		TXSTA,BRGH		;VELOCIDAD BAJA DE TRANSMISION
;					MOVLW	.155			;VALOR DE LA CONSTANTE X= 155 E=.16%
;					MOVWF	SPBRG
					;BANKSEL	ADCON0
					;BCF		STATUS,RP0		;CAMBIO AL BANCO 0
;					BSF RCSTA,SPEN			;PUERTOS SERIALES HABILITADOS

;;;;;;;;;;;;;;;;;;;CONVERSOR ANALOGICO-DIGITAL

					MOVLW 	B'10000001'		;TOSC*32,CANAL 0,CONVERSION NO ACTIVA,CONVERSOR ENCENDIDO
					MOVWF 	ADCON0
					BSF		STATUS, RP0		;CAMBIO AL BANCO 1
					MOVLW	B'00000001'		;ADRESL, PINES A/A/A/A, 6 BITS VACIOS EN ADRESH
					MOVWF	ADCON1
					BCF		STATUS,RP0		;CAMBIO AL BANCO 0
CICLO				BSF		ADCON0,ADON		;ACTIVAR EL MODULO DE CONVERSION
					NOP					
					NOP
					NOP
					NOP
					BSF		ADCON0,GO_DONE	;CONVERSION EN CURSO
ESPERA				BTFSC	ADCON0,GO_DONE	;ESPERAR AL FINAL DE LA CONVERSION
					GOTO	ESPERA
					BCF		ADCON0,ADON		;DESACTIVAR EL MODULO DE CONVERSION	
					BCF		PIR1,ADIF		;BAJAR LA BANDERA DE CONVERSION
;;;;;;;;;;;;;;;;;;;;XS3
					BSF 	STATUS,RP0		;CAMBIAR AL BANCO 1
					MOVFW	ADRESL
					BCF		STATUS,RP0		;CAMBIAR AL BANCO 0
					MOVWF	CONSTANTE		;MOVER ADRESL A CONSTANTE BAJA
					MOVFW	ADRESH
					MOVWF	CONSTANTE2		;MOVER ADRESH A CONSTANTE ALTA
					CLRF	DECUNI			;COMENZAR REGISTROS DECIMALES EN CEROS
					CLRF	MILCEN
					BCF		STATUS,C		;CARRY COMIENZA EN CERO


					BTFSC	CONSTANTE2,1	;BIT BINARIO MAS SIGNIFICATIVO
					GOTO	DIEZ
					BTFSC	CONSTANTE2,0
					GOTO	NUEVE
					BTFSC	CONSTANTE,7
					GOTO	OCHO
					BTFSC	CONSTANTE,6
					GOTO	SIETE
					BTFSC	CONSTANTE,5
					GOTO	CINCO
					BTFSC	CONSTANTE,4
					GOTO	CUATRO
					BTFSC	CONSTANTE,3
					GOTO	TRES
					BTFSC	CONSTANTE,2
					GOTO	DOS
					BTFSC	CONSTANTE,1
					GOTO	UNO
					BTFSC	CONSTANTE,0
					GOTO	CERO

CORRIMIENTO3		BTFSC	CONSTANTE2,0	;10?
					BSF		DECUNI,0		;11
					BSF		DECUNI,1		;10
					RLF		DECUNI			;CORRER REGISTROS HACIA LA IZQUIERDA
					GOTO	CORRIMIENTO		;HACER CORRIMIENTO DEL BYTE MENOS SIGNIFICATIVO

CORRIMIENTO2		BSF		DECUNI,0		;01

CORRIMIENTO			RLF		CONSTANTE
					RLF		DECUNI
					RLF		MILCEN
PRUEBAU				MOVFW	DECUNI			;PRUEBA UNIDADES MENORES A 5
					ADDLW	B'00000011'		;SON LAS UNIDADES MAYORES A 4?
					MOVWF	DECUNIP			;MOVER RESULTADO A REGISTRO DE PRUEBA
					BTFSS	DECUNIP,3
					GOTO	PRUEBAD			;NO, SIGUIENTE PRUEBA
					MOVFW	DECUNI			;SI, SUMAR 3
					ADDLW	B'00000011'		;ERROR
					MOVWF	DECUNI
PRUEBAD				MOVFW	DECUNI			;PRUEBA DECENAS MENORES A 5
					ADDLW	B'00110000'		;SON LAS DECENAS MAYORES A 4?
					MOVWF	DECUNIP			;MOVER RESULTADO A REGISTRO DE PRUEBA
					BTFSS	DECUNIP,7
					GOTO	PRUEBAC			;NO, SIGUIENTE PRUEBA
					MOVFW	DECUNI			;SI, SUMAR 3
					ADDLW	B'00110000'
					MOVWF	DECUNI
PRUEBAC				MOVFW	MILCEN			;PRUEBA CENTENAS MENORES A 5
					ADDLW	B'00000011'		;SON LAS CENTENAS MAYORES A 4?
					MOVWF	MILCENP			;MOVER RESULTADO A REGISTRO DE PRUEBA
					BTFSS	MILCENP,3
					GOTO	PRUEBAM			;NO, SIGUIENTE PRUEBA
					MOVWF	MILCEN			;SI, SUMAR 3
					ADDLW	B'00000011'
					MOVWF	MILCEN
PRUEBAM				MOVFW	MILCEN			;PRUEBA CENTENAS MENORES A 5
					ADDLW	B'00110000'		;SON LOS MILLARES MAYORES A 4?
					MOVWF	MILCENP			;MOVER RESULTADO A REGISTRO DE PRUEBA
					BTFSS	MILCENP,3
					GOTO	DECREMENTO		;NO, TERMINA PRUEBA
					MOVWF	MILCEN			;SI, SUMAR 3
					ADDLW	B'00110000'
					MOVWF	MILCEN
DECREMENTO			DECFSZ	ITERACIONES
					GOTO	CORRIMIENTO
					RLF		CONSTANTE
					RLF		DECUNI
					RLF		MILCEN









;					BSF TXSTA,TXEN			;HABILITAR TRANSMISION
;					BSF STATUS,RP0			;CAMBIAR AL BANCO 1
;					MOVFW ADRESL
;					BCF STATUS,RP0			;CAMBIAR AL BANCO 0
;					MOVWF TXREG
;					BTFSC ADRESH,0			;EL NOVENO BIT ES CERO?
;					GOTO SI9
;					GOTO NO9
;SI9				BSF TXSTA,TX9D			;SI
;					GOTO SALTO
;NO9				BCF TXSTA,TX9D			;NO


					CALL 	RETARDO10		;TIEMPO DE ESPERA PARA LA LCD 20 ms
					CALL 	RETARDO10
					CALL 	CLRD
					CALL 	FUNCTNSET
					CALL 	DISPON
					CALL 	EMDSTD
;					CALL 	HOME
					CALL	DISPOFF
					CALL 	HOLA
					CALL	NUMERO

					MOVF	CONSTANTE,W
					MOVWF	TXREG
TXN1					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
					GOTO				TXN1
					BTFSS				PIR1,TXIF
					GOTO				TXN1
					BCF					PIR1,TXIF

					MOVF	CONSTANTE2,W
					MOVWF	TXREG
TXN2					BTFSS				PIR1,TXIF						;BANDERA DE TRANSMISION ?
					GOTO				TXN2
					BTFSS				PIR1,TXIF
					GOTO				TXN2
					BCF					PIR1,TXIF



;BUCLE				GOTO 	BUCLE

SALTO				GOTO CICLO

					END
