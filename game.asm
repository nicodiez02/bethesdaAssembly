.8086
.model small
.stack 100h
.data
	msg1 DB "Welcome T-Rex Game ! ",0dh,0ah, 24h
	msg2 DB "Presiona enter para empezar ",0dh,0ah, 24h
	msg3 DB "Presione Esc para volver al menu principal",0dh,0ah, 24h
	menu db "<< Menu >>",0dh,0ah
    	 db"<1> Iniciar",0dh,0ah
   		 db"<2> Ver puntuacion",0dh,0ah
		 db"<3> Salir", 0dh, 0ah, 24h


	salto db 0dh,0ah,24h

	texto db 255 dup (24h),0dh,0ah,24h
	opcion db "0",0dh,0ah,24h ;guarda la opcion del usuario
	cantidad db 0
	caracter db "0",0dh,0ah,24h ;corresponde al caracter de finalizacion
	nroAscii db "000",0dh,0ah,24h
	precios db 150,100,65,90,30  ;vector de precios
	nombres db "leche","agua","galletas","jugo","papas"
	opcionInv db "Opcion incorrecta",0dh,0ah,24h


.code
	extrn inicioJuego:proc
	extrn clearScreen:proc
	extrn ocultarCursor:proc
	extrn carga:proc
	extrn capturarTeclaTeclado:proc

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
    		mov al, 0dh
    		call carga

			cmp opcion, 31h ;'2'
    		je opcion2
		    jne invalido

		
		opcion2:
			lea bx, msg1
			int 81

			lea bx, msg3
			int 81

			salirOpcion2:
				call capturarTeclaTeclado	
				cmp ah, 01h
				je inicio
		jmp salirOpcion2

		invalido:
			lea bx, opcionInv
			int 81

			lea bx, msg3
			int 81

			salirOpcionInvalida:
				call capturarTeclaTeclado	
				cmp ah, 01h
				je inicio
		jmp salirOpcionInvalida










		juego:
		jmp juego


   		fin:
    		mov ax, 4c00h
    		int 21h
	main endp
end