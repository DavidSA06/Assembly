; modo manual y autom�tico
;modificado 24/enero/2011
			LIST	 	P=16F877A
		  	include		"p16f877a.inc"
		__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF

NUMERO1		EQU 	20h
POSICION	EQU 	21H
BIT			EQU 	22H
tecla		EQU 	23h
nume1		EQU 	24H
CONTA		EQU		25H
guarda		EQU		26h
cont		EQU		27H
UNIDAD 		EQU		28H
DECENA		EQU		29H
CENTENA		EQU		2AH
BICHO_X10	EQU		2BH
AUX			EQU		2CH
AUX2		EQU		2DH
COCIENTE	EQU		2EH
DECIMAL		EQU		2FH
AUX3		EQU		30H

dato1a		EQU		31H;primer dato (megas)
dato1b		EQU		32H;(kilos)
dato1c		EQU		33H; (centenas)
dato2a		EQU		34H; segundo dato
dato2b		EQU		35H;(kilos)
dato2c		EQU		36H
dato3a		EQU		37H; tercer dato
dato3b		EQU		38H
dato3c		EQU		39h
dato4a		EQU		3AH;cuarto dato
dato4b		EQU		3BH
dato4c		EQU		3CH
dato5a		EQU		3DH;quinto dato
dato5b		EQU		3EH
dato5c		EQU		3FH
dato6a		EQU		40H;sexto dato
dato6b		EQU		41H
dato6c		EQU		42H
dato7a		EQU		43H;septimo dato
dato7b		EQU		44H
dato7c		EQU		45H
dato8a		EQU		46H;octavo dato
dato8b		EQU		47H
dato8c		EQU		48H
dato9a		EQU		49H;noveno dato
dato9b		EQU		4AH
dato9c		EQU		4BH
dato10a		EQU		4CH;decimo dato
dato10b		EQU		4DH
dato10c		EQU		4EH
dato11a		EQU		4FH;onceavo dato
dato11b		EQU		50H
dato11c		EQU		51H
dato12a		EQU		52H;doceavo dato
dato12b		EQU		53H
dato12c		EQU		54H
datoNa		EQU		55h;dato nuevo
datoNb		EQU		56h
datoNc		EQU		57h
vivi		EQU		59h; elige el modo
;definimos las variables
#define		HABILITAR		bsf PORTE,2		; Activa E
#define 	DESHABILITAR	bcf PORTE,2		; Desactiva E
#define 	LEER			bsf PORTE,1		;lectura
#define 	ESCRIBIR		bcf PORTE,1		; escritura
#define 	COMANDO			bcf PORTE,0		; Desactiva RS (modo de comandos)
#define 	DATOS			bsf PORTE,0		; Activa RS (modo de datos)

		org		00h
		goto	inicio
		org		100h
;****************************************************
; CONFIGURACI�N DE LOS PUERTOS
;****************************************************
inicio	bsf		STATUS,RP0;para pasar al banco 1
		movlw	b'00000111'	
		movwf	OPTION_REG			
		clrf	TRISE ;controla la LCD puertos salida E				
		clrf	TRISB; para los datos a la LCD puertos salida B
		movlw	b'01110000';para el teclado puerto D
		movwf	TRISD
		movlw	b'00000000';control de v�lvulas y
		movwf	TRISA; verificaci�n comunicaci�n
		movlw	b'00000110' ;puertos A y E digital
		movwf	ADCON1
		BCF		STATUS,RP0; BANCO 0
;*******************************************************
; INICIALIZACI�N DE LA LCD
;*******************************************************
		call	retardo ;inicializaci�n de la LCD
		COMANDO
		ESCRIBIR
		movlw	b'00000001'	; (CLEAR DISPLAY)	
		call	vea
		movlw	b'00111000'	; (FUNCTION SET)	
		call	vea			
		movlw	b'00001111'	; (DISPLAY ON/OFF CONTROL)
		call	vea		
		movlw	b'00000110'	; (ENTRY MODE SET)	
		call	vea
		movlw	80h
		movwf	POSICION
		call	vea
		clrf	PORTB
		clrf	PORTD

;******************************************************
; MODO MANUAL O AUTOM�TICO
;******************************************************
modo	movlw	.77	;  (caracter: M)
		call	envia; envia caracter a la LCD
		movlw	.97	;  (caracter: A)
		call	envia; envia caracter a la LCD		 		
		movlw	.110 ; (caracter: N)
		call	envia; envia caracter a la LCD
		movlw	.117 ; (caracter: U)
		call	envia; envia caracter a la LCD			
		movlw	.97 ;  (caracter: A)
		call	envia; envia caracter a la LCD			
		movlw	.108;  (caracter: L)
		call	envia; envia caracter a la LCD
		movlw	.49	;  (caracter: 1)
		call	envia; envia caracter a la LCD
		movlw	.32	;  (caracter: )
		call	envia; envia caracter a la LCD	
		movlw	.65	;  (caracter: A)
		call	envia; envia caracter a la LCD		 		
		movlw	.117; (caracter: U)
		call	envia; envia caracter a la LCD
		movlw	.116 ;  (caracter: T)
		call	envia; envia caracter a la LCD			
		movlw	.111 ;  (caracter: O)
		call	envia; envia caracter a la LCD			
		movlw	.52	;  (caracter: 4)
		call	envia; envia caracter a la LCD

ciclo1	movlw	b'11111110'
		movwf	PORTD
		call	pulse1
		movlw	b'11111101'
		movwf	PORTD
		call	pulse1
		movlw	b'11111011'
		movwf	PORTD
		CALL	pulse1
		movlw	b'11110111'
		movwf	PORTD
		call	pulse1
		goto	ciclo1

pulse1	call	suelta
		call	suelta
		movf	PORTD,W
		MOVWF	tecla
		btfss	tecla,4 
		goto 	colu11
		btfss	tecla,6 
		goto 	nada
		btfss	tecla,5 
		goto 	nada
nada	return

colu11	btfss	tecla,2
		goto	manual
		btfss	tecla,0
		goto	auto
		goto	ciclo1

manual	movlw	.1
		movwf	vivi
		call	borra
		goto	flujo
gusa	movlw	.65	;  (caracter:a )
		call	envia; envia caracter a la LCD
		movlw	.105;  (caracter: i)
		call	envia; envia caracter a la LCD		 		
		movlw	.114 ; (caracter: r)
		call	envia; envia caracter a la LCD
		movlw	.101 ; (caracter: e)
		call	envia; envia caracter a la LCD			
		movlw	.50 ;  (caracter: 2)
		call	envia; envia caracter a la LCD			
		movlw	.32;  (caracter: )
		call	envia; envia caracter a la LCD
		movlw	.71	;  (caracter: g)
		call	envia; envia caracter a la LCD
		movlw	.97	;  (caracter: a)
		call	envia; envia caracter a la LCD	
		movlw	.115;  (caracter: s)
		call	envia; envia caracter a la LCD		 		
		movlw	.53; (caracter: 5)
		call	envia; envia caracter a la LCD

ciclo1_1	movlw	b'11111110'
			movwf	PORTD
			call	pulse1_1
			movlw	b'11111101'
			movwf	PORTD
			call	pulse1_1
			movlw	b'11111011'
			movwf	PORTD
			CALL	pulse1_1
			movlw	b'11110111'
			movwf	PORTD
			call	pulse1_1
			goto	ciclo1_1

pulse1_1	call	suelta
			call	suelta
			movf	PORTD,W
			MOVWF	tecla
			btfss	tecla,4 
			goto 	nada1
			btfss	tecla,6 
			goto 	colu22
			btfss	tecla,5 
			goto 	nada1
nada1		return

colu22		btfss	tecla,2
			goto	aire
			btfss	tecla,0
			goto	gas
			goto	pulse1_1

gas		bsf		PORTA,2; Motor2 prende
		bcf		PORTA,3;Motor1 apaga
		call	borra; borra la pantalla LCD
		movlw	.73	; (caracter:i )
		call	envia;envia caracter a la LCD
		movlw	.78; (caracter: n)
		call	envia;envia caracter a la LCD		 		
		movlw	.89 ;(caracter: y)
		call	envia;envia caracter a la LCD
		movlw	.69 ;(caracter: e)
		call	envia;envia caracter a la LCD			
		movlw	.67 ; (caracter:c)
		call	envia;envia caracter a la LCD			
		movlw	.84; (caracter: t)
		call	envia;envia caracter a la LCD
		movlw	.65	; (caracter: a)
		call	envia;envia caracter a la LCD
		movlw	.78	; (caracter: n)
		call	envia;envia caracter a la LCD	
		movlw	.68;  (caracter: d)
		call	envia;envia caracter a la LCD		 		
		movlw	.79; (caracter: o)
		call	envia;envia caracter a la LCD
		GOTO	CAMBIO

aire	call	borra; borra la pantalla LCD
		bcf		PORTA,2; Motor2 apaga
		bsf		PORTA,3;Motor1 	prende
		movlw	.68	;  (caracter: D)
		call	envia; envia caracter a la LCD
		movlw	.69;  (caracter: E)
		call	envia; envia caracter a la LCD		 		
		movlw	.80 ; (caracter: P)
		call	envia; envia caracter a la LCD
		movlw	.85 ; (caracter: U)
		call	envia; envia caracter a la LCD			
		movlw	.82 ;  (caracter:R)
		call	envia; envia caracter a la LCD			
		movlw	.65;  (caracter: A)
		call	envia; envia caracter a la LCD
		movlw	.78	;  (caracter: N)
		call	envia; envia caracter a la LCD
		movlw	.68	;  (caracter: D)
		call	envia; envia caracter a la LCD	
		movlw	.79;  (caracter: O)
		call	envia; envia caracter a la LCD
		 		
CAMBIO	movlw	.99	;  (caracter:c )
		call	envia; envia caracter a la LCD
		movlw	.97;  (caracter:a)
		call	envia; envia caracter a la LCD		 		
		movlw	.109 ; (caracter:m)
		call	envia; envia caracter a la LCD
		movlw	.98 ; (caracter:b)
		call	envia; envia caracter a la LCD			
		movlw	.105 ;(caracter:i)
		call	envia;envia caracter a la LCD			
		movlw	.111; (caracter:o)
		call	envia;envia caracter a la LCD
		movlw	.51	; (caracter:3)
		call	envia;envia caracter a la LCD
		movlw	.32	; (caracter: )
		call	envia;envia caracter a la LCD	
		movlw	.70;  (caracter:f)
		call	envia;envia caracter a la LCD	
		movlw	.76	; (caracter:l)
		call	envia;envia caracter a la LCD
		movlw	.85;  (caracter:u)
		call	envia;envia caracter a la LCD		 		
		movlw	.74 ; (caracter:j)
		call	envia;envia caracter a la LCD
		movlw	.79 ; (caracter:o)
		call	envia;envia caracter a la LCD			
		movlw	.54 ; (caracter:6)
		call	envia;envia caracter a la LCD	

ciclo_3	movlw	b'11111110'
		movwf	PORTD
		call	pulse_3
		movlw	b'11111101'
		movwf	PORTD
		call	pulse_3
		movlw	b'11111011'
		movwf	PORTD
		CALL	pulse_3
		movlw	b'11110111'
		movwf	PORTD
		call	pulse_3
		goto	ciclo_3

pulse_3	call	suelta
		call	suelta
		movf	PORTD,W
		MOVWF	tecla
		btfss	tecla,4 
		goto 	nada3
		btfss	tecla,6 
		goto 	nada3
		btfss	tecla,5 
		goto 	colu33
nada3	return

colu33	btfss	tecla,2
		goto	camb
		btfss	tecla,0
		goto	flujo	

camb	btfss	PORTA,3
		GOTO	aire	
		GOTO	gas

auto	clrf	vivi
		movlw	.0
		movwf	vivi
		bsf		PORTA,3; inyectando aire
		BcF		PORTA,2; inyectando gas 
		call	borra

;*******************************************************
; FLUJO Y CONVERSI�N
;*******************************************************

flujo	movlw	.70	;  (caracter: F)
		call	envia; envia caracter a la LCD
		movlw	.76	;  (caracter: L)
		call	envia; envia caracter a la LCD		 		
		movlw	.85	 ; (caracter: U)
		call	envia; envia caracter a la LCD
		movlw	.74 ;  (caracter: J)
		call	envia; envia caracter a la LCD			
		movlw	.79 ;  (caracter: O)
		call	envia; envia caracter a la LCD			
		movlw	.32	;  (caracter:  )
		call	envia; envia caracter a la LCD
		CLRF	AUX2
		CLRF	COCIENTE
		CLRF	DECIMAL

		MOVLW	.3
		MOVWF	BICHO_X10
		GOTO	TECLADO
SEGUIR	DECFSZ	BICHO_X10
		GOTO	ROTA_1
		GOTO	CONV_DE
			
ROTA_1	MOVF	DECENA,W
		MOVWF	CENTENA
		MOVF	UNIDAD,W
		MOVWF	DECENA
TECLADO
ciclo	movlw	b'11111110'
		movwf	PORTD
		call	pulse
		movlw	b'11111101'
		movwf	PORTD
		call	pulse
		movlw	b'11111011'
		movwf	PORTD
		CALL	pulse
		movlw	b'11110111'
		movwf	PORTD
		call	pulse
		goto	ciclo
	
pulse	movf	PORTD,W
		MOVWF	tecla
		call	suelta
		btfss	tecla,4 
		goto 	colu1
		btfss	tecla,6
		goto	colu2
		btfss	tecla,5
		goto 	colu3
		return

colu1	call	suelta
		btfss	tecla,2
		goto	uno
		btfss	tecla,0
		goto	cuatro
		btfss	tecla,1
		goto	siete
		btfss	tecla,3
		goto	flujo

colu2	call	suelta
		btfss	tecla,2
		goto	dos
		btfss	tecla,0
		goto	cinco
		btfss	tecla,1
		goto	ocho
		btfss	tecla,3
		goto	cero

colu3	call	suelta
		btfss	tecla,2
		goto	tres
		btfss	tecla,0
		goto	seis
		btfss	tecla,1
		goto	nueve
		btfss	tecla,3
		goto	flujo

CONV_DE	MOVLW	.10; inicia conversion
		MOVWF	BICHO_X10
		MOVLW	B'00001111'
		ANDWF	DECENA,1
		MOVF	DECENA,W
		MOVWF	AUX
PREG	DECFSZ	BICHO_X10
		GOTO	SUMA
		GOTO	CONV_CE

SUMA	MOVF	AUX,W
		ADDWF	DECENA,1
		GOTO	PREG

CONV_CE	MOVLW	.100						
		MOVWF	BICHO_X10
		MOVLW	B'00001111'
		ANDWF	CENTENA,1
		MOVF	CENTENA,W
		MOVWF	AUX
PREGU	DECFSZ	BICHO_X10
		GOTO	SUMA2
		GOTO	CONV_UN	

SUMA2	MOVF	AUX,W
		ADDWF	CENTENA,1
		BTFSS	STATUS,C
		GOTO	PREGU
		MOVLW	.1
		MOVWF	AUX2
		GOTO	PREGU

CONV_UN	MOVLW	B'00001111'
		ANDWF	UNIDAD,1
		MOVF	DECENA,W
		ADDWF	UNIDAD,0
		ADDWF	CENTENA,1
		BTFSS	STATUS,C
		GOTO	ECUACION
		MOVLW	.1; INDICO QUE ES 256
		MOVWF	AUX2 ;PARA LA DIVISION

ECUACION
		MOVLW	.8; DIVISION
		MOVWF	BICHO_X10
		MOVLW	.121
		ADDWF	CENTENA
		btfss	STATUS,C
		GOTO	DIVI	
		MOVLW	.1
		ADDWF	AUX2
DIVI	rlf		CENTENA
		RLF		AUX2
		MOVLW	.31
		SUBWF	AUX2,0
		BTFSS	STATUS,C
		GOTO	PON	;EL NUMERO ES NEGATIVO
		MOVWF	AUX2;EL NUMERO ES POSITIVO
PON		RLF		COCIENTE; VER SI ARRASTRA EL CARRI
		DECFSZ	BICHO_X10
		GOTO	DIVI
		CLRF	CENTENA
		MOVLW	.10
		MOVWF	BICHO_X10
		MOVF	AUX2,W
		MOVWF	AUX
FRAC	DECFSZ	BICHO_X10
		GOTO	SUMA3
		GOTO	DIVI2
SUMA3	MOVF	AUX,W
		ADDWF	AUX2,1
		BTFSS	STATUS,C
		GOTO	FRAC
		MOVLW	.1
		MOVWF	CENTENA
		GOTO	FRAC			
DIVI2	MOVLW	.8
		MOVWF	BICHO_X10
AQUI	RLF		AUX2
		RLF		CENTENA
		movlw	.31
		subwf	CENTENA,0
		BTFSS	STATUS,C
		GOTO	PON2
		MOVWF	CENTENA
PON2	RLF		DECIMAL
		DECFSZ	BICHO_X10
		GOTO	AQUI		
;CONVERSION DE BINARIO A BCD PARTE TRES
		CLRF	UNIDAD
		CLRF	DECENA
		CLRF	CENTENA
		CLRF	AUX
		CLRF	AUX2
		CLRF	AUX3
		MOVLW	.8; NUMERO DE VECES
		MOVWF	BICHO_X10;QUE SE VA A REPETIR
CONV_BCD	
		RLF		COCIENTE; DEL QUE QUIERO LA CON
		RLF		AUX
		MOVF	AUX,W
		MOVWF	AUX2
YA		DECFSZ	BICHO_X10
		GOTO	AQUI2
		movwf	AUX
		andlw	b'00001111'
		movwf	DECENA
		SWAPF 	AUX, W
		andlw	b'00001111'
		movwf	CENTENA
		movf	DECIMAL,W
		MOVWF	UNIDAD
		CALL	RESTA?
		MOVLW	.48
		ADDWF	UNIDAD
		ADDWF	DECENA
		ADDWF	CENTENA

;***************************************************
; SE HABILITA EL USART
;***************************************************
		
		bsf 	STATUS,RP0      ;BANCO #1
		bcf		STATUS,RP1

     	BCF		TRISC,6; SALIDA
		BSF		TRISC,7;ENTRADA
		MOVLW	b'00100100';se elige el modo asincrono(sync=0)
		movwf	TXSTA; datos de 8 bit y alta velocidad
		movlw	.25
		movwf	SPBRG ; trabaja a una frecuencia de 9.600 baudios
		bsf 	TXSTA,TXEN
		bcf 	STATUS,RP0      ; BANCO #0 
		BCF		STATUS,RP1
		
		bsf  	RCSTA,SPEN    ;ENABLE USART

		clrf	TXREG;borramos el registro
;*************************************************
;ENVIO DE DATOS
;*************************************************
flujo_1	
		movlw	.62;>
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo_2
		movlw	.49; 1
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo_2
		movlw	.82; "R"
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo_2
		btfsc	CENTENA,0
		GOTO	ESA
		btfss	CENTENA,1
		GOTO	ESTA
ESA		MOVF	CENTENA,W
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo_2
ESTA	MOVF	DECENA,W
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo_2
		MOVLW	.46
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo
		MOVF	UNIDAD,W
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo_2
		MOVlW	.48
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		call	tiempo_2
		MOVlW	.13; CR
		movwf	TXREG;comienza la transmision
		CALL	MIRA	
		CALL	borra
		BCF		RCSTA,SPEN; DESHABILITA COM. ASINCRONA
		call	aqui
		btfsc	vivi,0
		goto	gusa
		movlw	.12 ; numero de datos en 1 minuto
		MOVWF	POSICION;
		MOVLW	.2; para el tiempo de 5 segundo
		MOVWF	cont;contador auxiliar para aumentar tiempo
		MOVLW	.8; rango de error 
		MOVWF	BIT
		MOVLW	.12
		MOVWF	NUMERO1
;********************************************
;�QUE MODO SE ESTA UTILIZANDO?
;********************************************
		BTFSC	vivi,0
		goto	CAMBIO
;*******************************************************
; DESHABILITA USART Y HABILITA SPI
;*******************************************************

		bsf 	STATUS,RP0      ;BANCO #1
		BCF		STATUS,RP1
     	BCF		TRISC,6
		BCF		TRISC,7
		clrf	TXSTA; datos de 8 bit y alta velocidad
		bcf 	STATUS,RP0      ; BANCO #0 
		BCF		STATUS,RP1
		bcf  	RCSTA,SPEN    ;DISABLE USART

		BSF		STATUS,RP0; BANCO 1
		BCF		STATUS,RP1
		bcf 	TXSTA,TXEN
		BCF		TRISC,5; SALIDA POR SER esclavo
		BSF		TRISC,4;ENTRADA POR SER esclavo
		BSF		TRISC,3;entrada POR SER esclavo
		movlw	b'01000000';se activa el modo SPI 
		movwf	SSPSTAT
		bcf		STATUS,RP0;regresamos al banco 0
		BCF		STATUS,RP1
		MOVLW	B'00100101'; determina el modo esclavo
		MOVWF	SSPCON;y la frecuencia de oscilaci�n
		CLRF	SSPBUF		

OTRON	BSF		SSPCON,SSPEN;ACTIVA EL MODO SPI 
		MOVLW	.255; DATO SIN SIGNIFICADO
		MOVWF	SSPBUF
		BSF		STATUS,RP0
		BCF		STATUS,RP1
BUCLE	BTFSS	SSPSTAT,BF
		GOTO	BUCLE
		BCF		STATUS,RP0
		MOVWF	datoNa

		BSF		SSPCON,SSPEN;ACTIVA EL MODO SPI 
		MOVLW	.255; DATO SIN SIGNIFICADO
		MOVWF	SSPBUF
		BSF		STATUS,RP0
		BCF		STATUS,RP1
BUCLE1	BTFSS	SSPSTAT,BF
		GOTO	BUCLE1
		BCF		STATUS,RP0
		MOVWF	datoNb

		MOVLW	.255 ; DATO SIN SIGNIFICADO
		MOVWF	SSPBUF
		BSF		STATUS,RP0
		BCF		STATUS,RP1
BUCLE2	BTFSS	SSPSTAT,BF
		GOTO	BUCLE2
		BCF		STATUS,RP0
		MOVWF	datoNc

		BCF		SSPCON,SSPEN;DESACTIVA EL MODO SPI
		decfsz	POSICION;decrementa el contador
		GOTO	REPITE;para tomar un nuevo numero
		GOTO	compara;comparamos el dato nuevo con el dato 1

REPITE	CALL	ROTA
		CALL	TIEMPO;tiempo
		GOTO	OTRON ; recibe otro dato
compara	
		movlw	.67 ;  (caracter: C)
		call	envia; envia caracter a la LCD
		movlw	.79 ;  (caracter: O)
		call	envia; envia caracter a la LCD
		movlw	.80;  (caracter: M)
		call	envia; envia caracter a la LCD
		MOVF	datoNb,W
		movwf	nume1
		COMF	nume1,1
		MOVF	datoNa,W
		movwf	CONTA
		COMF	CONTA,1
 		comf	datoNc,0
		movwf	tecla
		movlw	.1
		addwf	tecla,1
		btfss	STATUS,C
		GOTO	VE
		MOVLW	.1
		ADDWF	nume1,1
VE		BTFSS	STATUS,C
		GOTO	resta
		MOVLW	.1
		ADDWF	CONTA;solo hice el complemento a 2

resta	MOVF	dato1c,W
		ADDWF	tecla,1	
		CALL	PREGUNTA
		MOVF	dato1b,W
		ADDWF	nume1,1	
		CALL	PREGUNTA1
		movf	dato1a,W
		addwf	CONTA,1
		CALL	signo ;explora el bit de signo
		CALL	ROTA ; VA A MOVER LOS DATOS DE LOS REGISTROS 
		MOVF	tecla,W
		SUBWF	BIT,0; para el rango de error
		MOVWF	AUX
		MOVF	AUX,W
		CALL	envia
		CALL	borra
		BTFSS	AUX,7
		goto	menor	; indica que la diferencia es mayor al error
		goto	mayor; indica que esta en el rango de error

PREGUNTA
		BTFSS	STATUS,C; para el acarreo
		return
		MOVLW	.1
		ADDWF	nume1,1
		RETURN

PREGUNTA1	
		BTFSS	STATUS,C;para el acarreo
		return
		MOVLW	.1
		ADDWF	CONTA,1
		RETURN	

signo	btfss	CONTA,7; bit de signo
		RETURN	;bit de signo positivo
		MOVLW	.1	;bit de signo negativo
		COMF	tecla,1
		ADDWF	tecla,1
		comf	nume1,1
		COMF	CONTA,1
		RETURN

mayor	movlw	.77 ;  (caracter: M)
		call	envia; envia caracter a la LCD
		movlw	.65 ;  (caracter: A)
		call	envia; envia caracter a la LCD
		movlw	.89 ;  (caracter: Y)
		call	envia; envia caracter a la LCD
		movlw	.79 ;  (caracter: O)
		call	envia; envia caracter a la LCD
		movlw	.82 ;  (caracter: R)
		call	envia; envia caracter a la LCD
		MOVLW	.1
		MOVWF	POSICION
		movlw	.12
		movwf	NUMERO1
		CALL	TIEMPO
		GOTO	OTRON

menor	movlw	.77 ;  (caracter: M
		call	envia; envia caracter a la LCD
		movlw	.69 ;  (caracter: E)
		call	envia; envia caracter a la LCD
		movlw	.78 ;  (caracter: N)
		call	envia; envia caracter a la LCD
		movlw	.79 ;  (caracter: O)
		call	envia; envia caracter a la LCD
		movlw	.82 ;  (caracter: R)
		call	envia; envia caracter a la LCD
		decfsz	NUMERO1
		GOTO	YO
		incf	cont,1
		BTFSS	cont,2
		GOTO	mastiempo;
		MOVLW	.12
		MOVWF	NUMERO1
		MOVLW	.2
		MOVWF	cont
		movlw	.12
		movwf	POSICION 
		BTFSS	PORTA,0
		GOTO	ACTIVA
		BCF		PORTA,0
VOY_AQUI
		btfss	PORTA,1
		GOTO	ACTIVA2
		bcf		PORTA,1; para el motor 2 " pata 15 del L293"
VOY_ALLA
		CALL	TIEMPO
		GOTO	OTRON

ACTIVA	BSF		PORTA,1
		GOTO	VOY_AQUI
	
ACTIVA2	BSF		PORTA,0; PARA EL MOTOR 1 "pata 10 del L293"
		GOTO	VOY_ALLA
mastiempo
		call	TIEMPO
		MOVLW	.12
		MOVWF	NUMERO1
		movlw	.1
		movwf	POSICION
		goto	OTRON	
YO		CALL	TIEMPO;este si tiene que ir
		MOVLW	.1
		MOVWF	POSICION
		goto	OTRON

	;/*/*/*/*/*/*/*/*/*/* SUBRUTINAS/*/*/*/*/*/*/*/*/*/*/*
AQUI2	movwf	AUX
		addlw	b'00000011'
		movwf	AUX3
		btfss	AUX3,3
		goto	no
		goto	si
no		btfss	AUX3,7
		goto	CONV_BCD
		goto	uno1				
si		movfw	AUX3
		movwf	AUX		
		goto	CONV_BCD
uno1	movfw	AUX2
		movwf	AUX		
		goto	CONV_BCD

aqui	BSF		RCSTA,SPEN ; SE ACTIVA EL USART
		BSF		RCSTA,CREN ; SE HABILITA LA RECEPCION
HOLA	BTFSS	PIR1,RCIF; EXPLORA LA BANDERA 	
		GOTO	HOLA;
		MOVF	RCREG,w; MUEVE EL REGISTRO RCREG A W
		movwf	guarda
		movf	guarda,w
		CALL	envia
		btfss	guarda,0 ;SEA UNO
		goto	aqui
		btfss	guarda,1; SEA CERO
		goto	aqui
		btfsc	guarda,2;sea uno
		goto	aqui
		btfss	guarda,3; sea uno
		goto	aqui
		btfsc	guarda,4; sea cero
		goto	aqui
		btfsc	guarda,5;sea cero
		goto	aqui
		btfss	guarda,6; sea cero
		goto	aqui
		btfsc	guarda,7; sea cero
		return
		call	retardo
		call	borra
		BCF		RCSTA,CREN; SE DESHABILITA LA RECEPCION
		return	

vea		movwf		PORTB	
		call		pulso			
		call		revisa	
		return

borra	COMANDO;borra la pantalla LCD
		ESCRIBIR
		movlw	b'00000001'		
		movwf	PORTB; (CLEAR DISPLAY)
		call	pulso			
		call	revisa
		return
			
MIRA	BTFSS	PIR1,TXIF; EXPLORA LA BANDERA DE TRANSMISION
		GOTO	MIRA
		bcf		PIR1,TXIF; se borra la bandera de transmici�n
		BCF		PIR1,RCIF; SE BORRA LA BANDERA de recepcion	
		BSF		RCSTA,SPEN ; SE ACTIVA EL USART
		return

pulso	HABILITAR; Activa E
		nop	
		DESHABILITAR; Desactiva E
		return

revisa	COMANDO
		LEER; Llama la definici�n LEER
		bsf		STATUS,RP0
		bsf		PORTB,7
		bcf		STATUS,RP0
		HABILITAR; Llama la definici�n HABILITAR
		nop
checa	btfsc	PORTB,7	; Checa la bandera de ocupado (bit 7 del PUERTO B)
		goto	checa
		DESHABILITAR; Llama la definici�n DESHABILITAR
		bsf			STATUS,RP0
		clrf		TRISB
		bcf			STATUS,RP0
		ESCRIBIR; Llama la definici�n ESCRIBIR
		return

retardo	movlw	.2
		movwf	NUMERO1
checa1	movlw	.60 			
		movwf	TMR0		
checa2	btfss	INTCON,T0IF	; Checa la bandera de cero en T0IF, si es 1 (uno)
		goto	checa2
		bcf		INTCON,T0IF	; Pone a cero la bandera del TMR0 (T0IF)
		decfsz	NUMERO1
		goto	checa1
		return

suelta	movlw	.3
		movwf	BIT
checa3	movlw	.200 ;.216			
		movwf	TMR0		
checa4	btfss	INTCON,T0IF	; Checa la bandera de cero en T0IF, si es 1 (uno)
		goto	checa4
		bcf		INTCON,T0IF	; Pone a cero la bandera del TMR0 (T0IF)
		decfsz	BIT
		goto	checa3
		return

tiempo_2	movlw		.216
			movwf		TMR0
CHECA_2		btfss		INTCON,T0IF
			GOTO		CHECA_2
			BCF			INTCON,T0IF
			RETURN
tiempo	movlw	.10
		movwf	BIT
MAS		movlw	.61
		movwf	TMR0
CHECA	btfss	INTCON,T0IF
		GOTO	CHECA
		BCF		INTCON,T0IF
		decfsz	BIT
		goto	MAS
		RETURN

envia	movwf	PORTB
		call	suelta
		CALL	revisa
		DATOS
		CALL	pulso
		call	revisa
		clrf	PORTB
		return

RESTA?	btfsc	CENTENA,1
		RETURN
		BTFSS	CENTENA,0
		GOTO	BLOQUE_0
		BTFSC	DECENA,3
		GOTO	BLOQUE_3
		BTFSC	DECENA,2
		GOTO	BLOQUE_2
		BTFSC	DECENA,1
		GOTO	BLOQUE_2
		BTFSC	DECENA,0
		GOTO	BLOQUE_2
		BTFSC	UNIDAD,3
		GOTO	MIO
		BTFSC	UNIDAD,2
		GOTO	MIO
		BTFSC	UNIDAD,1
		GOTO	MIO
		btfsc	UNIDAD,0
		GOTO	MIO
		GOTO	PROB_3
BLOQUE_0
		BTFSS	DECENA,3
		RETURN
		BTFSC	DECENA,0
		GOTO	ES_9
		BTFSS	UNIDAD,2
		RETURN
MIO		MOVLW	.1
		SUBWF	UNIDAD,1
		RETURN

ES_9	BTFSC	UNIDAD,3
		GOTO	MIO
		BTFSC	UNIDAD,2
		GOTO	MIO
		BTFSC	UNIDAD,1
		GOTO	MIO
		BTFSC	UNIDAD,0
		GOTO	MIO
		GOTO	PROB_2

BLOQUE_3
		BTFSC	DECENA,0
		GOTO	ES_19
		BTFSC	UNIDAD,2
		GOTO	MIO
		BTFSC	UNIDAD,1
		GOTO	MIO_2
		GOTO	PROB

MIO_2	MOVLW	.2
		SUBWF	UNIDAD,1
		RETURN

ES_19	BTFSC	UNIDAD,3
		RETURN
		BTFSC	UNIDAD,2
		GOTO	MIO
		BTFSC	UNIDAD,1
		GOTO	MIO
		GOTO	PROB_2

BLOQUE_2
		BTFSC	UNIDAD,3
		GOTO	MIO_2
		BTFSC	UNIDAD,2
		GOTO	MIO_2
		BTFSC	UNIDAD,1
		GOTO	MIO_2
PROB	MOVLW	.1
		SUBWF	DECENA,1
		MOVLW	.10
		ADDWF	UNIDAD,1
		MOVLW	.2
		SUBWF	UNIDAD,1
		RETURN

PROB_2	MOVLW	.1
		SUBWF	DECENA,1
		MOVLW	.10
		ADDWF	UNIDAD,1
		MOVLW	.1
		SUBWF	UNIDAD,1
		RETURN

PROB_3	MOVLW	.1
		SUBWF	CENTENA,1
		MOVLW	.10
		ADDWF	DECENA,1
		MOVLW	.1
		SUBWF	DECENA,1
		MOVLW	.10
		ADDWF	UNIDAD,1
		MOVLW	.1
		SUBWF	UNIDAD,1
		RETURN

cero	movlw	b'00110000'
		goto	segir
uno		movlw	b'00110001'
		goto	segir
dos		movlw	b'00110010'
		goto	segir
tres	movlw	b'00110011'
		goto 	segir
cuatro	movlw	b'00110100'
		goto	segir
cinco	movlw	b'00110101'
		goto	segir
seis	movlw	b'00110110'
		goto	segir
siete	movlw	b'00110111'
		goto	segir	
ocho	movlw	b'00111000'
		goto	segir
nueve	movlw	b'00111001'

segir	movwf	UNIDAD
		CALL	envia
		goto	SEGUIR
		 
ROTA	MOVf	dato2a,w
		movwf	dato1a
		MOVf	dato2b,w
		movwf	dato1b	
		MOVf	dato2c,w
		movwf	dato1c

		MOVf	dato3a,w
		movwf	dato2a
		MOVf	dato3b,w
		movwf	dato2b	
		MOVf	dato3c,w
		movwf	dato2c

		MOVf	dato4a,w
		movwf	dato3a
		MOVf	dato4b,w
		movwf	dato3b	
		MOVf	dato4c,w
		movwf	dato3c

		MOVf	dato5a,w
		movwf	dato4a
		MOVf	dato5b,w
		movwf	dato4b	
		MOVf	dato5c,w
		movwf	dato4c

		MOVf	dato6a,w
		movwf	dato5a
		MOVf	dato6b,w
		movwf	dato5b	
		MOVf	dato6c,w
		movwf	dato5c

		MOVf	dato7a,w
		movwf	dato6a
		MOVf	dato7b,w
		movwf	dato6b	
		MOVf	dato7c,w
		movwf	dato6c

		MOVf	dato8a,w
		movwf	dato7a
		MOVf	dato8b,w
		movwf	dato7b	
		MOVf	dato8c,w
		movwf	dato7c

		MOVf	dato9a,w
		movwf	dato8a
		MOVf	dato9b,w
		movwf	dato8b	
		MOVf	dato9c,w
		movwf	dato8c

		MOVf	dato10a,w
		movwf	dato9a
		MOVf	dato10b,w
		movwf	dato9b	
		MOVf	dato10c,w
		movwf	dato9c

		MOVf	dato11a,w
		movwf	dato10a
		MOVf	dato11b,w
		movwf	dato10b	
		MOVf	dato11c,w
		movwf	dato10c

		MOVf	dato12a,w
		movwf	dato11a
		MOVf	dato12b,w
		movwf	dato11b	
		MOVf	dato12c,w
		movwf	dato11c

		MOVf	datoNa,w
		movwf	dato12a
		MOVf	datoNb,w
		movwf	dato12b	
		MOVf	datoNc,w
		movwf	dato12c	
		RETURN

;esplo	BSF		STATUS,RP0;pasamos al banco uno
;EXPLO	BTFSS	SSPSTAT,BF;exploramos el buffer
;		GOTO 	EXPLO
;		BCF		STATUS,RP0;pasamos al banco cero
;		MOVF	SSPBUF,w;movemos el dato recibido a W
	;	BCF		SSPCON,WCOL
;		return

TIEMPO	MOVF	cont,W
		MOVWF	AUX2
AQUI3	DECFSZ	AUX2
		GOTO	AQUII
		RETURN
AQUII	MOVLW	.74; 5 SEGUNDOS
		movwf	guarda
MIRA0	MOVLW	.0; 
		MOVWF	TMR0
MIRA2	BTFSS	INTCON,T0IF
		GOTO	MIRA2
		BCF		INTCON,T0IF
		DECFSZ	guarda
		GOTO	MIRA0
		GOTO	AQUI3

		END