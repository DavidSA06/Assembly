			LIST		P=16F877
			INCLUDE		"P16F877.inc"

TEMP1		EQU 20H
numero		EQU	21h
corri1		EQU 22H
corri2		EQU	23h
corri3		EQU	24h
corri4		EQU 25h
miau		EQU 26h
miau2		EQU 27h
miau3		EQU 28h
miau4		EQU 29h
unidad		EQU 2Ah
decena		EQU 2Bh
centena		EQU 2Ch

#define		HABILITAR		bsf PORTE,2		; Activa E
#define 	DESHABILITAR	bcf PORTE,2		; Desactiva E
#define 	LEER			bsf PORTE,1		;lectura
#define 	ESCRIBIR		bcf PORTE,1		; escritura
#define 	COMANDO			bcf PORTE,0		; Desactiva RS (modo de comandos)
#define 	DATOS			bsf PORTE,0		; Activa RS (modo de datos)

			ORG		00h
			GOTO	INICIO

			org		08h

INICIO
			bsf		STATUS,RP0;para pasar al banco1
			movlw	b'00000000' ; b'00000111'	
			movwf	OPTION_REG
			movlw	b'00000000'			
			movwf	TRISE ; configuro la puerta E  y D como salida				
			movlw	b'00000000'
			movwf	TRISD
			MOVLW	b'00000001'; PUERTA A COMO ENTRADA y salida 
			movwf	TRISA
			bcf		STATUS,RP0 ;REGRESO AL BANCO 0
;INICIALIZACION
			call 	retardo

			COMANDO
			ESCRIBIR
			movlw	b'00000001'		
			movwf	PORTD			; (CLEAR DISPLAY)
			call	pulso			
			call	revisa			
			movlw	b'00111000'		
			movwf	PORTD			; (FUNCTION SET)
			call	pulso			
			call	revisa			
			movlw	b'00001111'	
			movwf	PORTD			; (DISPLAY ON/OFF CONTROL)
			call	pulso			
			call	revisa		
			movlw	b'00000110'		
			movwf	PORTD			; (ENTRY MODE SET)
			call	pulso			
			call	revisa
				; para la conversion
ciclo		bsf		STATUS,RP0; BANCO 1
			MOVLW	b'10001110'; SOLO ACIVA EL CANAL AN0
			movwf	ADCON1
			bcf		STATUS,RP0 ;BANCO CERO
			MOVLW	B'10000000' ;ELEGIR Fosc/32 Y CONVERTIR SOLO AN0
			MOVWF	ADCON0
			BCF		PIR1,ADIF
			BSF		ADCON0,0 ; ENCIENDE EL ADC
			CALL	RETARDO
			BSF		ADCON0,GO ; EMPIEZA LA CONVERSIÒN

HOLA		BTFSC	ADCON0,2; EXPLORA SI YA TERMINO LA CONVERSIÒN
			GOTO	HOLA
			BCF		ADCON0,0
			clrf	unidad
			clrf	decena
			clrf	centena
			clrf	miau
			clrf	miau2
			clrf	miau3
			clrf	miau4
			clrf	corri1
			clrf	corri2
			clrf	corri3
			movlw	.8
			MOVWF	numero
			BSF		STATUS,RP0
			MOVF	ADRESL,w ; 8 BITS LSB
			BCF		STATUS,RP0
			MOVWF	corri1
aqui		rlf		corri1
			rlf		corri2
			rlf		corri3
			movfw	corri3
			movwf	miau4
			movfw	corri2
			movwf	miau3
			decfsz	numero
			goto	aqui2
			goto	alla
			goto 	ciclo
		
RETARDO ;retardo 10MICROs
			MOVLW	.245
			MOVWF	TMR0
HOLA1		BTFSS	INTCON,T0IF
			goto	HOLA1
			BCF		INTCON,T0IF
			return
pulso		HABILITAR			; Activa E
			nop					
			DESHABILITAR		; Desactiva E
			return	
revisa
			COMANDO
			LEER					; Llama la definición LEER
			bsf		STATUS,RP0		
			bsf		PORTD,7			
			bcf		STATUS,RP0		
			HABILITAR				; Llama la definición HABILITAR
			nop						
checa
			btfsc	PORTD,7			; Checa la bandera de ocupado (bit 7 del PUERTO B)
			goto	checa			
			DESHABILITAR			; Llama la definición DESHABILITAR
			bsf		STATUS,RP0		
			clrf	PORTD			
			bcf		STATUS,RP0		
			ESCRIBIR				; Llama la definición ESCRIBIR
			return			
retardo ; este es para el retardo de la LCD
			movlw	.2
			movwf	TEMP1
checa1		movlw	.60 			
			movwf	TMR0		

checa2		btfss	INTCON,T0IF		; Checa la bandera de cero en T0IF, si es 1 (uno)
			goto	checa2			
			bcf		INTCON,T0IF		; Pone a cero la bandera del TMR0 (T0IF)
			decfsz	TEMP1
			goto	checa1
			return	
;numero que mando a la LCD
alla		movwf	corri2
			andlw	b'00001111'
			addlw	b'00110000'
			movwf	unidad
			SWAPF 	corri2, W
			andlw	b'00001111'
			addlw	b'00110000'
			movwf	decena
			movfw	corri3
			andlw	b'00001111'
			addlw	b'00110000'
			movwf	centena
			call	despliega
			goto	ciclo

aqui2		movfw	corri2; pregunto por la unidad
			andlw	b'00001111'
			addlw	b'00000011' 
			movwf	miau2
			btfss	miau2,3
			goto	cero
			goto	uno

cero		swapf	corri2,w; invierto los valores DECENA
			andlw	b'00001111'; borro los 4 MBS
			addlw	b'00000011';sumo 3
			movwf	miau; guardo en miau
			btfss	miau,3 ;exploro la pata3
			goto	cero0 ; es cero
			goto	cero1; es uno

uno			swapf	corri2,w ;pregunto por la decena
			andlw	b'00001111'
			addlw	b'00000011'
			movwf	miau
			btfss	miau,3
			goto	uno0
			goto	uno1

cero0		movfw	corri3 ; PREGUNTO POR LA CENTENA
			andlw	b'00001111'
			addlw	b'00000011' 
			movwf	miau4
			btfss	miau4,3
			goto	aqui 
			goto	cero01
				
cero1		movfw	corri3 ; pregunto por la centena
			andlw	b'00001111'
			addlw	b'00000011' 
			movwf	miau4
			btfss	miau4,3
			goto	cero10
			goto	cero11

uno0		movfw	corri3 ; pregunto por la centena
			andlw	b'00001111'
			addlw	b'00000011' 
			movwf	miau4
			btfss	miau4,3
			goto	uno00
			goto	uno01

uno1		movfw	corri3 ; pregunto por la centena
			andlw	b'00001111'
			addlw	b'00000011' 
			movwf	miau4
			btfss	miau4,3
			goto	uno10
			goto	uno11;

cero10	
			swapf	miau; 0 unidad, 1 decena, 0 centena
			movfw	miau3
			andlw	b'00001111'
			addwf	miau,w
			movwf	corri2
			goto	aqui

cero11		swapf	miau,w; 0 unidad, 1 decena, 1 centena
			movfw	miau3
			andlw	b'00001111'
			addwf	miau,w
			movwf	corri2
			movfw	miau4
			movwf	corri3
			goto	aqui

uno00		movfw	miau3; 1 unidad, 0 decena, 0 centena
			andlw	b'11110000'
			addwf	miau2,w
			movwf	corri2
			goto	aqui

uno01		movfw	miau3; 1 unidad, 0 decena, 1 centena
			andlw	b'11110000'
			addwf	miau2,w
			movwf	corri2
			movfw	miau4
			movwf	corri3
			goto	aqui

uno10		swapf	miau,w; 1 unidad, 1 decena, 0 centena
			addwf	miau2,w
			movwf	corri2
			goto	aqui

uno11		swapf	miau,w; 1 unidad, 1 decena, 1 centena
			addwf	miau2,w
			movwf	corri2
			movfw	miau4
			movwf	corri3
			goto	aqui

cero01		movfw	miau4
			movwf	corri3
			goto	aqui

despliega	
			movfw	unidad
			movwf	PORTD
			call	revisa
			DATOS
			call	pulso
			call	revisa
			MOVFW	decena
			movwf	PORTD
			call	revisa
			DATOS
			call	pulso
			call	revisa
			MOVFW	centena
			movwf	PORTD
			call	revisa
			DATOS
			call	pulso
			call	revisa
			return

			end