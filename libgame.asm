.8086
.model small
.stack 100h

.data

	dataDivMul db 100,10,1 ;100 10 1    
    salto db 0dh,0ah, 24h               ;salto de linea para las impresiones
    ok db 0                             ;variable para carga
    modo db 0; 0, TEXTO                 ;variable para carga y checkCaracter
    caracteres db ("0123456789ABCDEF")  ;variable para carga
    vecMul db 128,64,32,16,8,4,2,1      ;variable para binToReg
    sumoBin db 0                        ;variable para binToReg 
	msg1 DB "Bienvenido a Adivina la Inflacion ! ",0dh,0ah, 24h
    msg2 DB "Presiona enter para empezar ",0dh,0ah, 24h

.code

public inicioJuego
public clearScreen
public ocultarCursor
public carga

inicioJuego proc

    push bx

    lea bx, msg1
    int 81h

    lea bx, salto
    int 81h
    
    lea bx, msg2
    int 81h


    pop bx

	ret
inicioJuego endp

clearScreen PROC
	mov AH, 00
	mov AL, 03
	int 10H 
	ret
clearScreen ENDP


ocultarCursor proc

    ;https://stackoverflow.com/questions/59667339/assembly-x86-hiding-cursor
    mov cx, 2607h
    int 10h

ocultarCursor endp

carga proc
; Llena una variable con caracteres ASCII, termina la carga con un carácter de finalización en AL.
; Recibe offset en BX, y carácter de finalización en AL
; Recibe por SI límite de caracteres

        push bx
        push dx
        push ax

        mov dl, al         ; DL contiene el carácter de finalización
        xor dh, dh         ; DH se limpia por si acaso

cargaTexto:
        mov al, [bx]      ; Carga el byte apuntado por BX en AL
        cmp al, dh        ; Compara con DH (para verificar si es el fin del string)
        je finCarga       ; Si es 0 (fin de string), termina la carga

        cmp bx, si        ; Compara BX con SI (límite de caracteres)
        jae finCarga      ; Si BX >= SI, termina la carga

        mov ah, 1
        int 21h           ; Muestra el carácter en pantalla

        cmp al, dl        ; Compara con el carácter de finalización
        je finCarga       ; Si es igual al carácter de finalización, termina la carga
        
        mov [bx], al      ; Guarda el carácter en la posición actual de BX
        inc bx            ; Avanza al siguiente byte

        jmp cargaTexto    ; Repite el ciclo de carga

finCarga:
        pop ax
        pop dx
        pop bx
        ret
carga endp


end