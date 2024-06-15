.8086
.model small
.stack 100h
.data
	msg1 DB "Welcome T-Rex Game ! ",0dh,0ah, 24h
	msg2 DB "Presiona enter para empezar ",0dh,0ah, 24h
	salto db 0dh,0ah,24h

	texto db 255 dup (24h),0dh,0ah,24h
	opcion db "0",0dh,0ah,24h ;guarda la opcion del usuario
	cantidad db 0
	caracter db "0",0dh,0ah,24h ;corresponde al caracter de finalizacion
	nroAscii db "000",0dh,0ah,24h
	precios db 150,100,65,90,30  ;vector de precios
	nombres db "leche","agua","galletas","jugo","papas"


.code
	extrn inicioJuego:proc
	extrn clearScreen:proc
	extrn ocultarCursor:proc
	extrn carga:proc

	main proc
    	mov ax, @data 
    	mov ds, ax

		bienvenida:
			call clearScreen
			call inicioJuego

			lea bx, caracter
			mov si, 2
			mov al, 0dh
			call carga

			cmp caracter, 0dh
			jmp inicio
		jmp bienvenida

		inicio:

			lea bx, msg2
			int 21h
			
		jmp inicio

   		fin:
    		mov ax, 4c00h
    		int 21h
	main endp
end