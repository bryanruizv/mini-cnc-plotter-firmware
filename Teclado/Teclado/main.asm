.include "m328Pdef.inc"

; Configuración de velocidad (9600 baudios a 16MHz)
.equ F_CPU = 16000000
.equ BAUD = 9600
.equ UBRR_VAL = (F_CPU/(16*BAUD))-1

.cseg
.org 0x00
    rjmp RESET

RESET:
    ; 1. Inicializar Stack Pointer
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    ; 2. Configurar UART (Transmisor)
    ldi r16, high(UBRR_VAL)
    sts UBRR0H, r16
    ldi r16, low(UBRR_VAL)
    sts UBRR0L, r16
    
    ldi r16, (1<<TXEN0) ; Habilitar Transmisor
    sts UCSR0B, r16
    
    ldi r16, (1<<UCSZ01)|(1<<UCSZ00) ; 8 bits de datos, 1 stop bit
    sts UCSR0C, r16

    ; 3. Configurar Puertos para Teclado
    ; Configurar PB0-PB3 como SALIDAS (Filas)
    ldi r16, 0b00001111 
    out DDRB, r16       ; DDR en 1 = Salida

    ; Configurar PD4-PD7 como ENTRADAS con PULL-UP (Columnas)
    cbi DDRD, 4         ; Aseguramos que sea entrada (0)
    cbi DDRD, 5
    cbi DDRD, 6
    cbi DDRD, 7
    
    ldi r16, 0b11110000 ; Escribir 1 en el Puerto de entrada...
    out PORTD, r16      ; ...activa las resistencias Pull-Up internas

MAIN_LOOP:
    rcall TECLADO_SCAN  ; Rutina que devuelve tecla en R24
    tst r24             ; ¿Se presionó algo? (0 = nada)
    breq MAIN_LOOP      ; Si es 0, repetir

    rcall UART_SEND     ; Enviar el valor de R24
    rcall DELAY_ANTIREBOTE
    rjmp MAIN_LOOP

UART_SEND:
    ; Esperar a que el buffer esté vacío
    lds r17, UCSR0A
    sbrs r17, UDRE0
    rjmp UART_SEND
    ; Enviar dato
    sts UDR0, r24
    ret

;-----------------------------------------------------------
; Subrutina: TECLADO_SCAN

;-----------------------------------------------------------
TECLADO_SCAN:
    ldi r24, 0          ; Limpiamos R24 (asumimos que no hay tecla)

    ; --- ESCANEO FILA 1 (PB0 = 0) ---
    ldi r16, 0b11111110 ; Poner PB0 en LOW, resto HIGH
    out PORTB, r16
    nop                 ; Pequeña pausa para estabilidad
    nop
    ; revisar Columnas (PD4-PD7)
    sbis PIND, 4        ; ¿PD4 es LOW? (Tecla '1')
    ldi r24, '1'
    sbis PIND, 5        ; ¿PD5 es LOW? (Tecla '2')
    ldi r24, '2'
    sbis PIND, 6        ; ¿PD6 es LOW? (Tecla '3')
    ldi r24, '3'
    sbis PIND, 7        ; ¿PD7 es LOW? (Tecla 'A')
    ldi r24, 'A'
    tst r24             ; ¿Encontramos algo?
    brne FIN_SCAN       ; Si R24 != 0, terminamos y retornamos

    ; --- ESCANEO FILA 2 (PB1 = 0) ---
    ldi r16, 0b11111101 ; Poner PB1 en LOW
    out PORTB, r16
    nop
    nop
    sbis PIND, 4        ; (Tecla '4')
    ldi r24, '4'
    sbis PIND, 5        ; (Tecla '5')
    ldi r24, '5'
    sbis PIND, 6        ; (Tecla '6')
    ldi r24, '6'
    sbis PIND, 7        ; (Tecla 'B')
    ldi r24, 'B'
    tst r24
    brne FIN_SCAN

    ; --- ESCANEO FILA 3 (PB2 = 0) ---
    ldi r16, 0b11111011 ; Poner PB2 en LOW
    out PORTB, r16
    nop
    nop
    sbis PIND, 4        ; (Tecla '7')
    ldi r24, '7'
    sbis PIND, 5        ; (Tecla '8')
    ldi r24, '8'
    sbis PIND, 6        ; (Tecla '9')
    ldi r24, '9'
    sbis PIND, 7        ; (Tecla 'C')
    ldi r24, 'C'
    tst r24
    brne FIN_SCAN

    ; --- ESCANEO FILA 4 (PB3 = 0) ---
    ldi r16, 0b11110111 ; Poner PB3 en LOW
    out PORTB, r16
    nop
    nop
    sbis PIND, 4        ; (Tecla '*')
    ldi r24, '*'
    sbis PIND, 5        ; (Tecla '0')
    ldi r24, '0'
    sbis PIND, 6        ; (Tecla '#')
    ldi r24, '#'
    sbis PIND, 7        ; (Tecla 'D')
    ldi r24, 'D'

FIN_SCAN:
    ; Restaurar filas a HIGH (reposo)
    ldi r16, 0b00001111 
    out PORTB, r16
    ret

;-----------------------------------------------------------
; Subrutina: DELAY_ANTIREBOTE
; Propósito: Generar una pausa de aprox 20ms a 16MHz
;-----------------------------------------------------------
DELAY_ANTIREBOTE:
    ldi  r20, 64     ; Contador externo (Ajusta este valor para cambiar la duración)
Lazo1:
    ldi  r21, 255    ; Contador medio
Lazo2:
    ldi  r22, 255    ; Contador interno
Lazo3:
    dec  r22         ; Restar 1
    brne Lazo3       ; Si no es 0, repetir
    dec  r21
    brne Lazo2       ; Si no es 0, repetir lazo medio
    dec  r20
    brne Lazo1       ; Si no es 0, repetir lazo externo
    ret