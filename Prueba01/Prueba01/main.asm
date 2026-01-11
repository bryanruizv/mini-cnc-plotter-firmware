; --- Configuración inicial ---
.include "m328Pdef.inc"
.DEF temp = r16
.DEF contador_pasos = r17
.DEF retardo1 = r18
.DEF retardo2 = r19
.DEF retardo3 = r20

.ORG 0x0000
    rjmp RESET

RESET:
    ; Configurar Puertos (Salidas para motores)
    ldi temp, 0xFF
    out DDRB, temp  ; Puerto B (Motor 1)
    out DDRD, temp  ; Puerto D (Motor 2)

; =========================================================
; TRADUCCIÓN DEL VOID LOOP()
; =========================================================
LOOP_PRINCIPAL:

    ; --- 1. motor1.step(256, FORWARD) ---
    ldi contador_pasos, 0 ; 0 en un registro de 8 bits = 256 iteraciones al decrementar
LOOP_M1_FWD:
    call PASO_MOTOR1_ADELANTE
    call DELAY_VELOCIDAD   ; Controla las RPM
    dec contador_pasos
    brne LOOP_M1_FWD

    ; --- 2. motor2.step(256, FORWARD) ---
    ldi contador_pasos, 0 
LOOP_M2_FWD:
    call PASO_MOTOR2_ADELANTE
    call DELAY_VELOCIDAD
    dec contador_pasos
    brne LOOP_M2_FWD

    ; --- 3. delay(500) ---
    call DELAY_MEDIO_SEGUNDO

    ; --- 4. motor1.step(256, BACKWARD) ---
    ldi contador_pasos, 0 
LOOP_M1_BCK:
    call PASO_MOTOR1_ATRAS
    call DELAY_VELOCIDAD
    dec contador_pasos
    brne LOOP_M1_BCK

    ; --- 5. motor2.step(256, BACKWARD) ---
    ldi contador_pasos, 0 
LOOP_M2_BCK:
    call PASO_MOTOR2_ATRAS
    call DELAY_VELOCIDAD
    dec contador_pasos
    brne LOOP_M2_BCK

    ; --- 6. delay(500) ---
    call DELAY_MEDIO_SEGUNDO

    rjmp LOOP_PRINCIPAL


; =========================================================
; SUBRUTINAS (Lo que la librería AFMotor hace por ti)
; =========================================================

PASO_MOTOR1_ADELANTE:
    ; Secuencia simple de 4 pasos (Bipolar) en Puerto B
    ; Esto se puede mejorar con tablas, pero así es visual:
    ldi temp, 0b00001001 ; Paso 1
    out PORTB, temp
    call DELAY_CORTO
    ldi temp, 0b00001100 ; Paso 2
    out PORTB, temp
    call DELAY_CORTO
    ldi temp, 0b00000110 ; Paso 3
    out PORTB, temp
    call DELAY_CORTO
    ldi temp, 0b00000011 ; Paso 4
    out PORTB, temp
    call DELAY_CORTO
    ret

PASO_MOTOR1_ATRAS:
    ; Secuencia inversa
    ldi temp, 0b00000011 ; Paso 4
    out PORTB, temp
    call DELAY_CORTO
    ldi temp, 0b00000110 ; Paso 3
    out PORTB, temp
    call DELAY_CORTO
    ldi temp, 0b00001100 ; Paso 2
    out PORTB, temp
    call DELAY_CORTO
    ldi temp, 0b00001001 ; Paso 1
    out PORTB, temp
    call DELAY_CORTO
    ret

; (Repetir lógica similar para MOTOR2 en PORTD...)
PASO_MOTOR2_ADELANTE:
    ret ; (Abreviaremos aquí por espacio)
PASO_MOTOR2_ATRAS:
    ret

; --- Retardos ---
DELAY_VELOCIDAD:
    ; Retardo pequeño para definir la velocidad de giro
    ldi retardo1, 50 
d_v: dec retardo1
    brne d_v
    ret

DELAY_CORTO:
    ; Pequeña pausa entre bobinas
    ldi retardo1, 200
d_c: dec retardo1
    brne d_c
    ret

DELAY_MEDIO_SEGUNDO:
    ; Retardo largo (aprox 500ms)
    ldi retardo3, 20
loop_ext:
    ldi retardo2, 255
loop_mid:
    ldi retardo1, 255
loop_int:
    dec retardo1
    brne loop_int
    dec retardo2
    brne loop_mid
    dec retardo3
    brne loop_ext
    ret