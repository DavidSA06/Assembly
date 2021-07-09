;captura numeros por medio del teclado, los muestra por pa LCD 
; y los manda a la PC por medio de la comunicación serial asincrona
; la cual envia datos al pic y el lo muestra por la LCD
			LIST	 	P=16F877A
		  	include		"p16f877a.inc"

NUMERO1		EQU 	20h
POSICION	EQU 	21H
BIT			EQU 	22H
tecla		EQU 	23h
nume1		EQU 	24H
CONTA		EQU		25H
guarda		EQU		26h
cont		EQU		27H


;definimos las variables
#define		HABILITAR		bsf PORTE,2		; Activa E
#define 	DESHABILITAR	bcf PORTE,2		; Desactiva E
#define 	LEER			bsf PORTE,1		;lectura
#define 	ESCRIBIR		bcf PORTE,1		; escritura
#define 	COMANDO			bcf PORTE,0		; Desactiva RS (modo de comandos)
#define 	DATOS			bsf PORTE,0		; Activa RS (modo de datos)

			org				00h

			goto			inicio
	
			org				08h
inicio
			bsf				STATUS,RP0;para pasar al banco 1
			movlw			b'00000111' ; b'00000111'	
			movwf			OPTION_REG			
			clrf			TRISE ; para la LCD puertos salida E				
			clrf			TRISD; para la LCD puertos salida D
			movlw			b'01110000' ;  para el teclado puerto B 
			movwf			TRISB
			movlw			b'10111111';RC7-entrada, RC6-salida
			movwf			TRISC ; puerta C comunicacion serial asincrona
			MOVLW			b'00100100';b'00100000'; 	se elige el modo asincrono (sync=0)
			movwf			TXSTA; datos de 8 bit y alta velocidad
			movlw			.25;.77
			movwf			SPBRG ; trabaja a una frecuencia de 9.600 baudios
			movlw			b'00000110' ;digital
			movwf			ADCON1
			bcf				STATUS,RP0
			clrf			RCREG
			clrf			TXREG

;INICIALIZACION DE LA LCD
			call	 		retardo
			COMANDO
			ESCRIBIR
			movlw			b'00000001'		
			movwf			PORTD	; (CLEAR DISPLAY)
			call			pulso			
			call			revisa			
			movlw			b'00111000'		
			movwf			PORTD	; (FUNCTION SET)
			call			pulso			
			call			revisa			
			movlw			b'00001111'	
			movwf			PORTD	; (DISPLAY ON/OFF CONTROL)
			call			pulso			
			call			revisa		
			movlw			b'00000110'		
			movwf			PORTD	; (ENTRY MODE SET)
			call			pulso			
			call			revisa
			movlw			80h
			movwf			POSICION
			movwf			PORTD
			call			pulso
			call			revisa
			clrf			PORTD
			clrf			PORTB

ALLA		MOVLW			.4
			MOVWF			 CONTA

			movlw			.86	; (caracter: V)
			movwf			PORTD
			call			suelta
			CALL			revisa
			DATOS
			CALL			pulso
			call			suelta
			movlw			.65	; (caracter: A)
			movwf			PORTD
			call			suelta
			CALL			revisa			
			DATOS
			CALL			pulso		 		
			movlw			.76	 ; (caracter: L)
			movwf			PORTD
			call	 		suelta
			CALL			revisa	
			DATOS
			CALL			pulso
			movlw			.79 ; (caracter: O)
			movwf			PORTD
			call			suelta
			CALL			revisa			
			DATOS
			CALL			pulso			
			movlw			.82 ;(caracter: R)
			movwf			PORTD
			call			suelta
			CALL			revisa
			DATOS
			CALL			pulso			
			movlw			.32	;(caracter:  )
			movwf			PORTD
			call			suelta	
			CALL			revisa			
			DATOS
			CALL			pulso

ciclo		movlw			b'11111110'
			movwf			PORTB
			call			pulse
			movlw			b'11111101'
			movwf			PORTB
			call			pulse
			movlw			b'11111011'
			movwf			PORTB
			CALL			pulse
			movlw			b'11110111'
			movwf			PORTB
			call			pulse
			goto			ciclo
	
pulse		movf			PORTB,W
			MOVWF			tecla
			call			suelta
			btfss			tecla,4 
			goto 			colu1
			btfss			tecla,6
			goto		 	colu2
			btfss			tecla,5
			goto 			colu3
			return

colu1		call			suelta
			btfss			tecla,2
			goto			uno
			btfss			tecla,0
			goto			cuatro
			btfss			tecla,1
			goto			siete
			btfss			tecla,3
			goto			punto
colu2		call			suelta
			btfss			tecla,2
			goto			dos
			btfss			tecla,0
			goto			cinco
			btfss			tecla,1
			goto			ocho
			btfss			tecla,3
			goto			cero
colu3		call			suelta
			btfss			tecla,2
			goto			tres
			btfss			tecla,0
			goto			seis
			btfss			tecla,1
			goto			nueve
			btfss			tecla,3
			goto			gato
;/*/*/*/*/* INICIO NUMERACION */*/*/*/*/*/*
cero		movlw			.48	;	b'00110000'
			goto			segir
uno			movlw			.49	;b'00110001'
			goto			segir
dos			movlw			b'00110010'
			goto			segir
tres		movlw			b'00110011'
			goto 			segir
cuatro		movlw			b'00110100'
			goto			segir
cinco		movlw			b'00110101'
			goto			segir
seis		movlw			b'00110110'
			goto			segir
siete		movlw			b'00110111'
			goto			segir	
ocho		movlw			b'00111000'
			goto			segir
nueve		movlw			b'00111001'
			goto			segir
gato		movlw			.83;b'00100011'
			goto			segir	
punto		movlw			.46
			goto			segir     ;*/*/*/* FIN NUMERACION

segir		movwf			nume1
			movwf			PORTD	
			call			suelta
			call			revisa
			DATOS
			call			pulso
			call			revisa
			clrf			PORTD
			goto			TRANS

pulso		HABILITAR; Activa E
			nop	
			DESHABILITAR; Desactiva E
			return

revisa		COMANDO
			LEER; Llama la definición LEER
			bsf				STATUS,RP0
			bsf				PORTD,7
			bcf				STATUS,RP0
			HABILITAR; Llama la definición HABILITAR
			nop
checa		btfsc			PORTD,7	; Checa la bandera de ocupado (bit 7 del PUERTO B)
			goto			checa
			DESHABILITAR; Llama la definición DESHABILITAR
			bsf				STATUS,RP0
			clrf			PORTD
			bcf				STATUS,RP0
			ESCRIBIR; Llama la definición ESCRIBIR
			return

retardo		movlw			.2
			movwf			NUMERO1
checa1		movlw			.60 			
			movwf			TMR0		
checa2		btfss			INTCON,T0IF	; Checa la bandera de cero en T0IF, si es 1 (uno)
			goto			checa2
			bcf				INTCON,T0IF	; Pone a cero la bandera del TMR0 (T0IF)
			decfsz			NUMERO1
			goto			checa1
			return
suelta	;*/*/*/*/*/ retardo suelta tecla
			movlw			.3
			movwf			BIT
checa3
			movlw			.200 ;.216			
			movwf			TMR0		
checa4		btfss			INTCON,T0IF	; Checa la bandera de cero en T0IF, si es 1 (uno)
			goto			checa4
			bcf				INTCON,T0IF	; Pone a cero la bandera del TMR0 (T0IF)
			decfsz			BIT
			goto			checa3
			return
; TRANSMISIÒN
TRANS		BSF				RCSTA,SPEN ; HABILITACION DEL PUERTO SERIAL modo asincrono
			DECFSZ			CONTA
			GOTO			NUME
			GOTO			coma
NUME	
			movf			nume1,w; se mueve a txreg el dato a transmitir el primer numero
			movwf			TXREG;comienza la transmision
			CALL			MIRA
			goto			ciclo
coma		
			movf			nume1,w; se mueve a txreg el dato a transmitir el primer numero
			movwf			TXREG;comienza la transmision
			CALL			MIRA
			movlw			.82; se mueve a txreg el dato a transmitir el R
			movwf			TXREG;comienza la transmision
			CALL			MIRA
			movlw			.13; se mueve a txreg el dato a transmitir el CR
			movwf			TXREG;comienza la transmision
			CALL			MIRA
			clrf			TXREG
			call			suelta
			call			retardo
			call			retardo
			COMANDO;borra la pantalla LCD
			ESCRIBIR
			movlw			b'00000001'		
			movwf			PORTD			; (CLEAR DISPLAY)
			call			pulso			
			call			revisa
			goto			recep

;PARA RECIBIR DATO

recep	
aqui		BSF				RCSTA,SPEN ; SE ACTIVA EL USART
			BSF				RCSTA,CREN ; SE HABILITA LA RECEPCION
HOLA		BTFSS			PIR1,RCIF; EXPLORA LA BANDERA 	
			GOTO			HOLA;
			MOVF			RCREG,w; MUEVE EL REGISTRO RCREG A W
			movwf			guarda
			CALL			EXPLORA; explora si ya termino con un CR
			movf			guarda,w
			movwf			PORTD	
			call			suelta
			call			revisa
			DATOS
			call			pulso
			call			revisa
			clrf			PORTD
			goto			recep

EXPLORA		btfss			guarda,0 ;SEA UNO
			return;tiempo
			btfsc			guarda,1; SEA CERO
			return;tiempo
			btfss			guarda,2;sea uno
			return;tiempo
			btfss			guarda,3; sea uno
			return;tiempo
			btfsc			guarda,4; sea cero
			return;tiempo
			btfsc			guarda,5;sea cero
			return;tiempo
			btfsc			guarda,6; sea cero
			return;tiempo
			btfsc			guarda,7; sea cero
			return;tiempo

miau		call		retardo; borrar pantalla LCD
			call		retardo
			COMANDO
			ESCRIBIR
			movlw		b'00000001'		
			movwf		PORTD			; (CLEAR DISPLAY)
			call		pulso			
			call		revisa		
			BCF			RCSTA,CREN; SE DESHABILITA LA RECEPCION
			goto		ALLA

MIRA		BTFSS		PIR1,TXIF; EXPLORA LA BANDERA DE TRANSMISION
			GOTO		MIRA
			bcf			PIR1,TXIF; se borra la bandera de transmición
			BCF			PIR1,RCIF; SE BORRA LA BANDERA de recepcion	
			BSF			RCSTA,SPEN ; SE ACTIVA EL USART
			return

			END