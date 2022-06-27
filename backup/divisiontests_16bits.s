;SECTION .data
;Variables initialisées ou constantes

SECTION .data

; SECTION .bss
; Block Starting Symbol
; Variables statiques ou non initialisées qui sont censées
; changer pendant l'exécution du programme

	quotient	dw 0
	reste			dw 0
	dividande	dw 88
	diviseur	dw 56
	precision	dw 23				; precision x+1 chiffres après la virgule

;	formatstring db "%08d",0

	partieentiere dw 0
	rangpartent		dw 0

SECTION .bss

; Programme principal
; https://www.tutorialspoint.com/assembly_programming/assembly_arithmetic_instructions.htm

SECTION .text


global _start

_start:
	
	mov dx,0
	mov ax,[dividande]
	mov bx,[diviseur]

	div bx										; ah va contenir le reste et al va contenir la partie entière (mode byte)
														; mode WORD
														; ax partie entière 
														; dx reste de la division

	mov [quotient],ax
	mov [reste],dx
	add WORD [quotient],48		; 48 est le code ASCII de 0

	cmp WORD [quotient],48+9	; si la valeur est supérieure à 9
	jbe afficherdigits

	mov bx,0
	mov dx,0

	mov [quotient],ax					; restaurer la valeur originale
	;mov ax,[quotient]				; préparer à la division
	mov bx,10
	mov WORD [rangpartent],0	; nous savons déjà qu'il y aura au deux digits


determinerrang:
	inc WORD [rangpartent]		; ajouter 1 au nombre de rangs
	div bx										; je pense que ax contiendra le rang... je sais pas...
	
	; ax contient le quotient
	; dx contient le reste

	cmp ax,9									; est-ce qu'il faut un rang supplémentaire ?
	ja determinerrang					; oui...
	
	; nous avons le nombre de rangs (digits de la partie entière)

;	mov ax,1									; il faut diviser le quotient par la puissance de 10 correspondant au rang
; mov bx,10

;calculerrangmax:

;	mul bx
;	dec WORD [rangpartent]
;	jnz calculerrangmax

;	mov bx,ax
;	mov ax,[quotient]

;afficherlesdigits:

;	div bx												; on divise le quotient par la puissance de 10 correspondant au rang
	
;	cmp dx,[quotient]							; si le reste est égal au quotient on quitte
;	je afficherdigits							
;	mov WORD [partieentiere],ax		; ax contient le résultat de la division entière
	
	;afficher le digit

;	push bx
;	push dx

;	add WORD [partieentiere],48		

;	mov ax,4
;	mov bx,1
;	mov ecx,partieentiere
;	mov dx,1
;	int 80H

;	pop dx
;	pop bx

;	sub WORD [partieentiere],48		; il ne doit plus être affiché

;	mov ax,[partieentiere]				; exemple: si 4 alors il faut le multiplier par la puissance de 10
;	mul bx
;	mov cx,ax
;	mov ax,[quotient]
;	sub ax,cx											; et le soustraire du quotient

;	mov [quotient],ax							; mettre à jour le quotient
		
;	cmp WORD [quotient],0					
;	jnz afficherlesdigits
;	cmp dx,0
;	jnz afficherlesdigits

					
	
afficherdigits:
	
	;add WORD[quotient],48
	
	; sinon on affiche la partie entière
	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H
	
	cmp WORD [reste],0
	jz fin										; si la division est terminée...
	; sinon

	mov WORD [quotient],','		; afficher la "virgule"

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H

diviser:
	; une fois la virgule affichée multiplier le reste par 10

	mov bx,[reste]
	mov ax,10
	mul bx										; multiplier bl par al
	
	mov bx,[diviseur]
	div bx										; diviser al par bl
	
	mov [quotient],ax
	mov [reste],dx
	add WORD [quotient],48

	; afficher la valeur

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H
	
	cmp WORD [reste],0
	jz fin										; si la division est terminée...
	dec WORD [precision]
	jz arrondir								; certaines division sont cycliques et il faut s'arrêter à un moment donné
	jmp diviser								; sinon...

arrondir:
	
	mov WORD bx,[reste]
	mov ax,10
	mul bx
	
	mov bx,[diviseur]
	div bx
	
	mov [quotient],ax					; dernier nombre après la virgule...		
	add WORD [quotient],48
	
	; effectuer la division suivante et si la valeur >5 on "arrondi" (on ajoute 1)

	mov bx,[reste]
	mov ax,10
	mul bx
	
	mov bx,[diviseur]
	div bx
	
	; faut-il arrondir en fonction de cette dernière division ?
	
	cmp WORD bx,5
	jbe lastdigit							; si plus petit ou égal à 5 on l'affiche tel quel
	add WORD [quotient],1			; si plus grand que 5 on "arrondi"
	
lastdigit:

	; afficher le dernier nombre arrondi ou non
	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H



fin:
	mov WORD [quotient],10	

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H

	mov eax,1
	mov ebx,0
	int 80H
