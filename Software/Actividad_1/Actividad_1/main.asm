;
; Actividad_1.asm
;
; Created: 27/09/2026 04:29:40 p. m.
; Author : karla
;

; Generador de Frecuencias (100 KHz, 500 KHz, 1 MHz, 2MHz)
; Entradas: PB3 y PB4 
; Salida: PB5
; 
.cseg
.org 0x00    

.def temp = r16
.def counter = r17
.def multiplier = r18

setup:
    ; Inicia Stack
    ldi temp, high(RAMEND) 
    out SPH, temp
    ldi temp, low(RAMEND) 
    out SPL, temp

    ; PB3, PB4 entrada y PB5 salida
    ldi temp, 0b0010_0000  
    out DDRB, temp
    ldi temp, 0b0001_1000  
    out PORTB, temp

start:
    in temp, PINB
    andi temp, 0b0001_1000 
    cpi temp, 0x00         ; Si es 00 -> 100 kHz
    breq freq1
    cpi temp, 0x08         ; Si es 01 -> 500 kHz
    breq freq2
    cpi temp, 0x10         ; Si es 10 -> 1 MHz
    breq freq3
	cpi temp, 0x18         ; Si es 11 -> 2 MHz
    breq freq4
    
    rjmp start             ; 

; FRECUENCIA 1: 100 KHz

freq1:
    ldi counter, 20        
    rcall on_off
    jmp start

; FRECUENCIAS 2(500KHz) y 3(1MHz)
freq2:
    sbi PINB, 5            ;Conmuta salida
    ldi counter, 2         

delay_freq2:
    dec counter            
    brne delay_freq2       ; Loop toma 5 ciclos
    in temp, PINB          ; Lee el puerto
    andi temp, 0x18         
    cpi temp, 0x08          
    brne exit_freq         ; Si cambió la entrada, gasta 2 ciclos y sale. Si no, gasta 1 ciclo.
    rjmp freq2_ajuste      ; Salto de retardo estructural

freq2_ajuste:
    rjmp freq2             ; Regresa (Total: 16 ciclos = 500 KHz)

freq3:
    sbi PINB, 5            ; Conmuta salida
    in temp, PINB          ; Lee el puerto
    andi temp, 0x18        ; 
    cpi temp, 0x10         ; 
    brne exit_freq         ; Si cambió la entrada, gasta 2 ciclos y sale. Si no, gasta 1 ciclo.
    rjmp freq3             ; Regresa (Total : 8 ciclos = 1 MHz)

freq4:
    sbi PINB, 5            ; Conmuta 1
    in temp, PINB          ; Lee pines
    brne exit_freq         ; 
    sbi PINB, 5            ; Conmuta 2
    andi temp, 0x18        ; Enmascara
    breq exit_freq           
    sbi PINB, 5            ; Conmuta 3
    cpi temp, 0x18         ; Compara con 11
    brne exit_freq         
    sbi PINB, 5            ; Conmuta 4
    breq freq4             ; Si sigue en 11, repite el bloque
    
    rjmp start             ; Si cambió la entrada, sale

; subrutina de salida 
exit_freq:
    rjmp start             

on_off:
    sbi PORTB, 5           
    rcall delay            
    cbi PORTB, 5           
    rcall delay            
    ret

delay:
    push multiplier
    mov multiplier, counter
c1: 
    dec multiplier
    brne c1
    pop multiplier
    ret