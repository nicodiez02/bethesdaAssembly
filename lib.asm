.8086
.model small
.stack 100h

.data

	dataDivMul db 100,10,1 ;100 10 1
       salto db 0dh,0ah, 24h ;salto de linea para las impresiones
       ok               db 0                  ;variable para carga
       modo             db 0; 0, TEXTO           ;variable para carga y checkCaracter
                            ; 1, DEC
                            ; 2, HEX
                            ; 3, BIN
       caracteres       db ("0123456789ABCDEF")  ;variable para carga
       vecMul db 128,64,32,16,8,4,2,1  ;variable para binToReg
       sumoBin db 0                    ;variable para binToReg 

.code

public carga
public contarCaracteres
public regToAscii
public imprimir
public contarCaracterEsp
public contarNumeros
public limpiarVariables
public reinicioCarga
public limpiaPantalla
public cifrar
public checkCaracter
public regtoHex
public asciitodec
public regtobin
public binToReg
public asciitoReg
public encuentra


;---------------------------------------------------------
;Llena una variable con caracteres ascii, termina la carga con caracter de finalizacion en AL.
;Recibe offset en BX, y caracter de finalizacion en AL
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
;---------------------------------------------------------
; RECIBE EL OFFSET DE VARIABLE DESDE DX, DEVUELVE EN DL EL RESULTADO
contarCaracteres proc
       push bx

       mov bx, dx ; cargo el offset de la variable en [bx]
       xor dx, dx ; Limpio para usar dl
contar:
       cmp byte ptr [bx], 24h
       je finContar
       inc dl
       inc bx
jmp contar 
finContar:
       mov dh, 0 ; Limpio dh por las dudas

       pop bx
 ret
contarCaracteres endp

;---------------------------------------------------------

; RECIBE EL OFFSET DE VARIABLE DESDE DX, DEVUELVE EN DL EL RESULTADO
contarNumeros proc
       push bx

       mov bx, dx ; cargo el offset de la variable en [bx]
       xor dx, dx ; Limpio para usar dl
contarNum:
       cmp [bx], byte ptr 24h
       je finContarNum
       cmp [bx], byte ptr 30h
       jae casiNum
       jne sigo

sigo:
       inc bx
jmp contarNum


casiNum:
	cmp [bx], byte ptr 39h
       jbe esNum
       jne sigo
esNum:
       inc dl
       inc bx
     jmp contarNum

finContarNum:
       mov dh, 0 ; Limpio dh por las dudas

       pop bx
       ret
contarNumeros endp
;---------------------------------------------------------
; RECIBE EL OFFSET DE VARIABLE DESDE DX, 
; Y EL CARACTER A CONTAR EN AL
; DEVUELVE EN DL EL RESULTADO
contarCaracterEsp proc
       push bx
       push ax

       mov bx, dx ; cargo el offset de la variable en [bx]
       xor dx, dx ; Limpio para usar dl
       xor ah,ah
recorro:
       cmp [bx], byte ptr 24h
       je finContarCar
       cmp [bx], al
       je contarCar
       inc bx
jmp recorro 

contarCar:
      inc dl
      inc bx
      jmp recorro
finContarCar:
       mov dh, 0 ; Limpio dh por las dudas

       pop ax
       pop bx
 ret
contarCaracterEsp endp
;---------------------------------------------------------
;RECIBE EN DL UN NRO DE UN BYTE
;Y DEVUELVE EN UN OFFSET BX (DIRECCIÓN)
;UNA VARIABLE CON 3 ASCII LLENA
regToAscii proc
        push ax
        push dx
        push cx
        push si
        push bx

        xor si,si
        xor ax, ax
        mov al, dl ;MUEVO EL NUMERO(reg) A al PARA HACER LA DIVISION

        mov cx, 3
 rta: ;("Reg.To.Ascii" = rta)
        mov dl, dataDivMul[si] ; [si] -> dataDivMul
        div dl 
        add [bx],al     ; Se suma porque [bx] es "000", o sea: 30h, 30h, 30h
        xchg al, ah     ;INTERCAMBIA VALORES
        xor ah, ah 
        inc bx 
        inc si
 loop rta
        
        pop bx
        pop si
        pop cx
        pop dx
        pop ax
 
        ret
regToAscii endp
;---------------------------------------------------------

imprimir proc  ;Recibe el offset en BX
       ;printeo

       push bp
       mov bp, sp
       push dx
       push ax

       mov ah,9
       mov dx, offset salto
       int 21h

       mov dx, ss:[bp+4]
       mov ah,9
       int 21h


       pop ax
       pop dx
       pop bp
       ret 2

imprimir endp

;---------------------------------------------------------
; RECIBE EL OFFSET DE LA VARIABLE A LIMPIAR EN BX Y
; EN [CL] EL NUMERO DE TIPO DE VARIABLE
; [1] DECIMAL [2] HEX [3] BIN [4] TEXTO
limpiarVariables proc
       push cx 
       push bx


       cmp cl, 1
       je VarAscii
       cmp cl, 2
       je VarHex
       cmp cl, 3
       je VarBin
       cmp cl, 4
       je VarText

       VarAscii:
              mov cx, 3   
        limpiarNroAscii:
              mov [bx], byte ptr 30h
              inc bx
        loop limpiarNroAscii
        jmp finLimpiar

       VarHex:
              mov cx, 2
        limpiarNroHex:
              mov [bx], byte ptr 30h
              inc bx
        loop limpiarNroHex
        jmp finLimpiar

       VarBin:
              mov cx, 8
        limpiarNroBin:
              mov [bx], byte ptr 30h
              inc bx
        loop limpiarNroBin
       jmp finLimpiar

       VarText:

        limpiarTexto:
              cmp [bx], byte ptr 24h
              jmp finLimpiar
              mov [bx], byte ptr 24h ;en cada posicion va metiendo signos $
              inc bx
        loop limpiarTexto
       jmp finLimpiar

       finLimpiar:
              mov cx, 0

              pop bx 
              pop cx
              ; pop bp
              ret ;2
limpiarVariables endp
;---------------------------------------------------------

reinicioCarga proc 
       ;reinicio variables de tipo texto
       ;en el DH recibe el caracter de finalizacion

              push bp
              mov bp, sp
              push cx
              push si
              push dx

              mov si, ss:[bp+4]

              mov cl, dl ;copia el 255 al cl para el bucle
       cargaX:
              mov byte ptr[si], dh ;copia el signo $ en cada posicion
              inc si
       loop cargaX
              
              pop dx 
              pop si 
              pop cx 
              pop bp 

              ret 2 ;va ret 2 ya que le estoy pasando como parametro via stack 2byte de datos, estoy pusheando bx en este caso, por lo tanto retornare 2byte
              ;Por lo tanto, el número que acompaña a RET debe coincidir con la cantidad de bytes que se han agregado a la pila para los parámetros. Si has empujado un solo registro de 16 bits (push si, por ejemplo), se necesita RET 2 para quitar esos 2 bytes de la pila. Si se han empujado múltiples registros o más bytes, entonces el número en RET debe ser ajustado en consecuencia para limpiar adecuadamente la pila.
              
       reinicioCarga endp

;---------------------------------------------------------
limpiaPantalla proc 
              
       push ax

       mov ah, 0fh   ;obtiene el modo de video actual y la página activa
       int 10h       ;En AL contendrá el número del modo de video actual y BH contendrá el número de la página activa.
       
       mov ah, 0     ;Cargo el 0 en AH, esto llamara a la funcion 00h que establece el modo de video. La funciion 00h establece el modo de video actual y limpia pantalla.
       int 10h

       pop ax

       ret 

limpiaPantalla endp


;---------------------------------------------------------

cifrar proc
       ;OJO con este que tiene que recibir 3 pusheos antes
       ;recibe por stack offsets  texto    , textoCif y cantidad 
       ; ss:[bp+8]
       ; ss:[bp+6]
       ; ss:[bp+4] 
       ; suma al contenido de cantidad al caracter en texto
       ; y guarda en textoCif

       push bp
       mov bp, sp
       push bx
       push si 
       push ax

       mov bx, ss:[bp+8]
       mov si, ss:[bp+4]
       mov al, byte ptr [si]
       mov si, ss:[bp+6]

       cifrando:
              cmp byte ptr[bx], 24h
              je finCifrado
              mov ah, [bx]
              add ah, al 
              mov [si],ah 
              inc si
              inc bx

       jmp cifrando

       finCifrado:
              pop ax
              pop si
              pop bx
              pop bp
              ret 6
       cifrar endp

;---------------------------------------------------------


checkCaracter proc ;funcion que verifica si el caracter recibido es decimal, o hexa o binario
       ;RECIBE EN AL UN CARACTER y DEPENDIENDO DEL VALOR DE LA VARIBLE
       ;MODO CHEQUEA SI ES CORRECTO EL MISMO 

                     push cx 
                     push si

                     mov ok, 0

                     cmp modo, 0 
                     je finCheckCaracter
                     cmp modo, 1  ;Si modo es 1, la función verifica si el carácter está en el rango decimal (0-9)
                     je esDec
                     cmp modo, 2  ;Si modo es 2, la función verifica si el carácter está en el rango hexadecimal (0-9, A-F).
                     je esHex
                     cmp modo, 3 ;Si modo es 3, la función verifica si el carácter está en el rango binario (0-1).
                     je esBin
              esDec:
                     mov si, 0
                     mov cx, 10 ;limite hasta donde recorrera al vector caracteres
              checkDec:     
                     cmp al, caracteres[si]
                     je encontre
                     inc si
              loop checkDec
                     mov al, 3
                     jmp finCheckCaracter

              esHex:
                     mov si, 0
                     mov cx, 16
              checkHex:     
                     cmp al, caracteres[si]
                     je encontre
                     inc si
              loop checkHex
                     mov al, 3
                     jmp finCheckCaracter
              esBin:
                     mov si, 0
                     mov cx, 2
              checkBin:     
                     cmp al, caracteres[si]
                     je encontre
                     inc si
              loop checkBin
                     mov al, 3
                     jmp finCheckCaracter

              encontre:
                     mov ok, 1
                     jmp finCheckCaracter

       finCheckCaracter:
              pop si
              pop cx

              ret
       checkCaracter endp


;---------------------------------------------------------

regtoHex proc  ;recibe el offset en BX y recibe en DL la cantidad
              ;recibe en BX el offset de una variable de 2 bytes, y el numero a convertir por DL no mayor a 255
              push ax
              push dx

              add bx,1
              xor ax,ax
              mov al, dl
              mov dl, 16
              div dl
              cmp ah, 9
              ja esLetra
              add [bx],ah

       prox:
              xor ah,ah
              dec bx
           div dl
           cmp ah, 9
              ja esLetra2    
              add [bx],ah
              jmp finRegHex

              esLetra:
                     mov [bx], ah
                     add byte ptr [bx], 55
              jmp prox
              esLetra2:
                     mov [bx], ah
                     add  byte ptr[bx], 55


       finRegHex:
               pop dx
               pop ax

               ret
       regtoHex endp


;---------------------------------------------------------

asciitodec proc ;Es un asciitoreg que no utiliza loop
       ;RECIBE EN BX EL OFFSET DE UNA VARIABLE DE 3 DIGITOS ASCII Y DEVUELVE EN CX LA CANTIDAD NUMERICA

               push ax
               push bx
               push dx

               mov cx, 0
               sub byte ptr [bx], 30h ;30h
               mov al, [bx]  ;0
               mov dl, 100
               mul dl 
               add cx, ax 

               inc bx
               sub byte ptr [bx], 30h
               mov al, [bx]
               mov dl,10
               mul dl
               add cx,ax

               inc bx
               sub byte ptr [bx], 30h
               add cl, [bx]

               pop dx
               pop bx
               pop ax

               ret
       asciitodec endp

;---------------------------------------------------------
regtobin proc
       ;recibe en DX un numero en hexa, y en BX una variable de 8 ceros

              push bp
              mov bp, sp

              push dx
              push cx
              push bx

              mov bx, ss:[bp+4]
              mov cx, 8

              shiftea:
                     shl dl, 1
                     jc esUno
                     mov byte ptr [bx],30h
                     jmp incre

              esUno:
                     mov byte ptr [bx], 31h
              
              incre:
              inc bx
              loop shiftea

              pop bx
              pop cx
              pop dx
              pop bp
              ret 2
regtobin endp

;---------------------------------------------------------

binToReg proc
       ;recibe un binario por BX y lo cambia a ascii y guarda el resultado en CL

              push ax
              push dx
              push bx

              xor di, di
              mov cx,8
       aca:
              mov al, byte ptr[bx] ;muevo a AL el primer ascii binario a multiplicar
              sub al, 30h ;le resto 30h al "1" o "0"
              mov dl,  vecMul [di] ;muevo a DL el primer 128 para hacer la multiplicacion
              mul dl
              add sumoBin, al
              inc bx
              inc di
       loop aca
              
              mov ch, 0
              mov cl, sumoBin
              pop bx
              pop dx
              pop ax
              ret

       binToReg endp

;---------------------------------------------------------
asciitoReg proc
       ;como asciitodec pero sin loop - 
       ;recibe un valor decimal por BX y emite un ascii por CL

              push bx
              ;push cx 
              push ax 

              xor si,si
              xor cx, cx
       proceso:                                          
              mov ah, 0                          
              mov al, byte ptr[bx]        
              sub al, 30h                               
              mov dl, dataDivMul[si]  
              mul dl                             
              add cl, al                         
                                                        ;
              inc bx
              inc si                             
              cmp si,3 

              je finProceso        
       jmp proceso                 

       finProceso:
              
              pop ax
              ;pop cx 
              pop bx

              ret 2
       asciitoReg endp
;---------------------------------------------------------

encuentra proc ;esta funcion recibe un offset en DX con el texto a analizar, una letra a buscar en AL (no es offset), y la posicion va en DX. Devuelve la posicion en AH
    ;CARACTER       ss:[bp+4]
    ;OF POS         ss:[bp+6]
    ;OF TEXTO       ss:[bp+8]

        push bp
        mov bp, sp
        push bx
        push ax
        push si 

        mov bx, ss:[bp+8]
        mov si, ss:[bp+6]
        mov ax, ss:[bp+4]

        xor ah, ah 

procEncuentro:
        cmp [bx], byte ptr 24h    ; 003f ; 2
        je finEncuentra
        cmp [bx], al
        je encontrado
        inc ah 
        inc bx
    jmp procEncuentro

encontrado:
        inc ah
        mov [si], byte ptr ah ; CANTIDAD
        jmp final   

finEncuentra:   
        mov [si], byte ptr 255; DEVUELVO CODIGO DE ERROR NO ENCONTRO
final:
        pop si
        pop ax
        pop bx
        pop bp
        ret 6
    encuentra endp


;---------------------------------------------------------

cuentaVoc proc
              ;ESTA FUNCION RECIBE EN BX, EL OFFSET DE UNA VARIABLE Y DEVUELVE EN OTRA VARIABLE (offset en DX) LA CANTIDAD DE CADA VOCAL SIENDO
              ; v[0] cantidad de A, v[1] cantidad de E y asi sucesivamente
              ; LA VARIABLE DEBE TERMINAR CON 24h
              push bx
              push si

              mov si, dx
arribaCu: cmp byte ptr [bx], 24h
                je finCu
                cmp byte ptr [bx], 'A'
                je cuentaA
                cmp byte ptr [bx], 'E'
                je cuentaE
                cmp byte ptr [bx], 'I'
                je cuentaI
                cmp byte ptr [bx], 'O'
                je cuentaO
                cmp byte ptr [bx], 'U'
                je cuentaU
                cmp byte ptr [bx], 'a'
                je cuentaA
                cmp byte ptr [bx], 'e'
                je cuentaE
                cmp byte ptr [bx], 'i'
                je cuentaI
                cmp byte ptr [bx], 'o'
                je cuentaO
                cmp byte ptr [bx], 'u'
                je cuentaU
vuelveCu: inc bx
                jmp arribaCu

cuentaA:
              inc byte ptr si[0]
              jmp vuelveCu
cuentaE:
              inc byte ptr si[1]
              jmp vuelveCu
cuentaI:
              inc byte ptr si[2]
              jmp vuelveCu
cuentaO:
              inc byte ptr si[3]
              jmp vuelveCu         
cuentaU:
              inc byte ptr si[4]
              jmp vuelveCu
finCu:
              pop si
              pop bx
              ret
       cuentaVoc endp

;---------------------------------------------------------
;ej multiplicacion:
;mov al, 5   ; Primer número
;push ax     ; Empujar primer número a la pila

;mov al, 3   ; Segundo número
;push ax     ; Empujar segundo número a la pila

multiplica_numeros proc

    push bp
    mov bp, sp      ; Establecer el puntero de pila base

    mov al, [bp+4]  ; Cargar el primer número
    mov bl, [bp+6]  ; Cargar el segundo número

    mul bl          ; Multiplicar AL por BL (resultado en AX)

    mov [bp+4], al  ; Guardar el resultado de la multiplicación

    pop bp
    ret 4           ; Limpiar los parámetros y retornar
multiplica_numeros endp

;---------------------------------------------------------
;ej suma:
;mov al, 5      ; Primer número (5)
;push ax        ; Empujar el primer número

;mov al, 10     ; Segundo número (10)
;push ax        ; Empujar el segundo número

suma_numeros proc
    push bp
    mov bp, sp      ; Establecer el puntero de pila base

    mov al, [bp+4]  ; Cargar el primer número
    mov bl, [bp+6]  ; Cargar el segundo número

    add al, bl      ; Sumar los dos números

    mov [bp+4], al  ; Guardar el resultado de la suma

    pop bp
    ret 4           ; Limpiar los parámetros y retornar
suma_numeros endp

end