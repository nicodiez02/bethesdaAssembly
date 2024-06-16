.8086
.model small
.stack 100h
.data

	mensaje1 db "Esta es la opcion uno",0dh,0ah,24h
	mensaje2 db "Con que caracter finaliza la carga?",0dh,0ah,24h
	mensaje3 db "Presione Esc para salir",0dh,0ah,24h
	mensaje4 db "A continuacion ingrese su nick con tres caracteres maximo:",0dh,0ah,24h
	menu db "<< Menu >>",0dh,0ah
	db"<1> Iniciar juego",0dh,0ah
	db"<2> Ver puntuacion",0dh,0ah
	db"<3> Salir",0dh,0ah,24h

	opcionInv db "Opcion incorrecta",0dh,0ah,24h
	salto db 0dh,0ah, 24h

	nickname db 255 dup (24h),0dh,0ah,24h
	opcion db "0",0dh,0ah,24h
	cantidad db 0
	caracter db "0",0dh,0ah,24h
	nroAscii db "000",0dh,0ah,24h

.code
    extrn clearScreen:proc
    extrn inicioJuego:proc
    extrn capturarTeclaTeclado:proc
    extrn carga:proc
main proc
    mov ax, @data 
    mov ds, ax 

   	call clearScreen
	call inicioJuego

	bienvenida:
		call capturarTeclaTeclado
		cmp al, 20h
		je inicio
		
		cmp al, 1Bh
		je fin

	jmp bienvenida
	inicio:

		call clearScreen
		lea bx, menu
		int 81h

		lea bx, opcion ;Lee el ascii de la opcion pulsada
		mov cx, 3
		mov al, 0dh
    	call carga
		call clearScreen

		cmp opcion, '1'
    	je opcion1

		cmp opcion, '2'
    	je opcion2

		cmp opcion, '3'
    	je fin

		jmp invalido

		opcion1:
			lea bx, mensaje4
			int 81h

			lea bx, nickname
			mov al, 0dh
			call carga

			lea bx, nickname
			int 81h
		
		jmp esperarPorSalida

		opcion2:
			lea bx, mensaje1
			int 81h

			lea bx, mensaje3
			int 81h
		jmp esperarPorSalida


		invalido:
			lea bx, opcionInv
			int 81h

			lea bx, mensaje3
			int 81h
		jmp esperarPorSalida

		esperarPorSalida: ;Funcion para volver al menu principal despúes de entrar a alguna opcion
				call capturarTeclaTeclado	
				cmp ah, 01h
				je inicio
		jmp esperarPorSalida

		juego:
		jmp juego

	fin:
		mov ax, 4c00h
		int 21h
main endp
end