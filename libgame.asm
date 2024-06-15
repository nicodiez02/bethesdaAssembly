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
public capturarTeclaTeclado

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

capturarTeclaTeclado proc
        ;Deja en AH el codigo de la tecla presionada
        ;Deja en AL el codigo ASCII de la tecla presionada
    	mov ah, 00h      
    	int 16h          

capturarTeclaTeclado endp


ocultarCursor proc

    ;https://stackoverflow.com/questions/59667339/assembly-x86-hiding-cursor
    mov cx, 2607h
    int 10h

ocultarCursor endp

carga proc
        push bx ; PROFILAXIS
        push dx
        push ax

        ;mov bx, dx ; CARGO EL OFFSET EN BX
        mov dl, al ; MUEVO EL CARACTER DE FINALIZACIÖN A DL
        xor dh, dh 
 cargaTexto:
        mov ah, 1
        int 21h
        cmp al, dl
        je finCarga 
        mov [bx], al 
        inc bx
 jmp cargaTexto
 finCarga:
        pop ax
        pop dx
        pop bx
 ret
carga endp

end