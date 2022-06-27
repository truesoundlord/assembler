;SECTION .data
;Variables initialisées ou constantes

SECTION .data

; SECTION .bss
; Block Starting Symbol
; Variables statiques ou non initialisées qui sont censées
; changer pendant l'exécution du programme

	quotient	db 0
	reste			db 0
	dividande	db 89
	diviseur	db 88
	precision	db 23				; precision x+1 chiffres après la virgule

	partieentiere dw 0

SECTION .bss

; Programme principal
; https://www.tutorialspoint.com/assembly_programming/assembly_arithmetic_instructions.htm

SECTION .text



global _start

_start:
	
	mov al,[dividande]
	mov bl,[diviseur]

	div bl									; ah va contenir le reste et al va contenir la partie entière (mode byte)

	mov BYTE [quotient],al	
	mov BYTE [reste],ah
	add BYTE [quotient],48		; 48 est le code ASCII de 0

	cmp BYTE [quotient],9			; si la valeur est supérieure à 9
	
	; sinon on affiche la partie entière
	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H
	
	cmp BYTE [reste],0
	jz fin									; si la division est terminée...
	; sinon

	mov BYTE [quotient],','		; afficher la "virgule"

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H

diviser:
	; une fois la virgule affichée multiplier le reste par 10

	mov BYTE bl,[reste]
	mov al,10
	mul bl								; multiplier bl par al
	
	mov bl,[diviseur]
	div bl								; diviser al par bl
	
	mov BYTE [quotient],al	
	mov BYTE [reste],ah
	add BYTE [quotient],48

	; afficher la valeur

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H
	
	cmp BYTE [reste],0
	jz fin								; si la division est terminée...
	dec BYTE [precision]
	jz arrondir						; certaines division sont cycliques et il faut s'arrêter à un moment donné
	jmp diviser						; sinon...

arrondir:
	
	mov BYTE bl,[reste]
	mov al,10
	mul bl
	
	mov bl,[diviseur]
	div bl
	
	mov BYTE [quotient],al	; dernier nombre après la virgule...		
	add BYTE [quotient],48
	
	; effectuer la division suivante et si la valeur >5 on "arrondi" (on ajoute 1)

	mov BYTE bl,[reste]
	mov al,10
	mul bl
	
	mov bl,[diviseur]
	div bl
	
	; faut-il arrondir en fonction de cette dernière division ?
	
	cmp BYTE bl,5
	jbe lastdigit					; si plus petit ou égal à 5 on l'affiche tel quel
	add BYTE [quotient],1		; si plus grand que 5 on "arrondi"
	
lastdigit:

	; afficher le dernier nombre arrondi ou non
	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H

	
	

fin:
	mov BYTE [quotient],10	

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H

	mov eax,1
	mov ebx,0
	int 80H
