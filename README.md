# Mini CNC Plotter Funcional (Low-Level Control)

Este proyecto consiste en el diseño y construcción de una máquina CNC de pequeña escala utilizando hardware reciclado de unidades de DVD, controlada mediante programación de bajo nivel para la ejecución de trayectorias predefinidas.

## 🚀 Funcionalidades Clave
- **Interfaz de Usuario:** Selección de figuras geométricas mediante un **teclado matricial 4x4**.
- **Control Eje Z:** Implementación de un servomotor para el levantamiento y apoyo preciso de la pluma (pen up/down).
- **Cinemática X-Y:** Control de motores paso a paso bipolares extraídos de lectoras de DVD para el movimiento en el plano.
- **Memoria Interna:** Almacenamiento de coordenadas de figuras complejas en la memoria del microcontrolador.

## 🛠️ Especificaciones Técnicas
- **Microcontroladores:** ATmega328P (Arquitectura AVR) y PSoC.
- **Lenguajes:** - **Assembler:** Optimización de rutinas de tiempo para el control de los motores.
  - **C++:** Lógica de control de usuario y gestión del teclado.
- **Drivers de Potencia:** Integrados **L293D** para el manejo de corrientes de los motores paso a paso.
- **Comunicación:** Escaneo por interrupciones/polling del teclado matricial para una respuesta inmediata.

## 📂 Estructura del Firmware
- `/src/assembler`: Rutinas de control de pasos (Full-step/Half-step).
- `/src/drivers`: Control del servomotor mediante PWM para el eje Z.
- `/src/logic`: Mapeo de teclas a trayectorias específicas almacenadas en arreglos.

## ⚙️ Operación
1. El sistema inicia en estado de espera.
2. El usuario selecciona un número en el **teclado matricial** (ej. '1' para cuadrado, '2' para triángulo).
3. El microcontrolador procesa el comando, posiciona el eje Z (baja la pluma) y ejecuta la secuencia de pasos en X e Y.
4. Al finalizar, el servomotor levanta la pluma y regresa al origen (Home).
