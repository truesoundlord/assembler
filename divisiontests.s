;SECTION .data
;Variables initialisées ou constantes

SECTION .data

	quotient	dw 0
	reste		dw 0

	dividande	dw 65000
	diviseur	dw 5
	precision	dw 15				; precision x+1 chiffres après la virgule

	rangpartent	dw 0
	displayme	dw 0

; SECTION .bss
; Block Starting Symbol
; Variables statiques ou non initialisées qui sont censées
; changer pendant l'exécution du programme

SECTION .bss

; Programme principal
; https://www.tutorialspoint.com/assembly_programming/assembly_arithmetic_instructions.htm

SECTION .text

global _start

_start:
	
	mov dx,0				
	mov ax,[dividande]
	mov bx,[diviseur]

	div bx	; ah va contenir le reste et al va contenir la partie entière (mode byte)
			; mode WORD
			; ax partie entière 
			; dx reste de la division

	mov [quotient],ax					
	mov [reste],dx
	mov bx,10						; on se prépare à déterminer le rang...
	mov ax,10

	cmp WORD [quotient],9
	mov dx,0						; pour éviter les FPE ???
	ja	determinerrang				; si le quotient occupe plus d'un caractère il faut effectuer l'affichage de l'unité pour chaque rang
	jbe afficherdigit				; sinon

; en assembleur on ne peut pas afficher par exemple 1200 d'un "seul coup"
; comme en C avec la fonction printf()...
; nous pourrions bien sûr invoquer printf() à partir de l'assembleur
; mais je ne maîtrise pas du tout la technique

; nous allons donc devoir afficher les caractères formant la partie entière
; un par un

determinerrang:
	mul bx							; ax contient le résultat
	cmp WORD ax,[quotient]
	mov WORD [rangpartent],ax
	jbe determinerrang

	; ici nous devrions obtenir le rang de la partie entière... à une puissance près

	div bx
	mov WORD [rangpartent],ax
	
	; ici nous avons le rang correct

	mov WORD ax,[quotient]
	mov WORD bx,[rangpartent]
	div bx							; à partir d'ici nous devrions pouvoir afficher les caractères...

diminuerrang:	
	mov WORD [displayme],ax
	
	mov ax,4
	mov bx,1
	add WORD [displayme],48
	mov ecx,displayme									
	push dx							; sauvegarder le reste de la division
	mov dx,1
	int 80H
	pop dx

	sub WORD [displayme],48
	mov ax,[displayme]
	mov bx,[rangpartent]
	mul bx
	sub WORD [quotient],ax
	
	; ici nous devons diviser le rang par 10

	mov ax,[rangpartent]
	mov bx,10
	div bx

	mov [rangpartent],ax
	mov WORD ax,[quotient]
	mov WORD bx,[rangpartent]
	cmp WORD bx,0
	jz afficherpartiedecimale
	div bx
	
	cmp WORD [quotient],0
	jnz diminuerrang
	cmp WORD [rangpartent],1		; cas du 10000/2 (tant que le rang n'est pas 1 ou 10^0 on doit afficher les 0)
	jnz diminuerrang

afficherdigit:
	
	mov WORD dx,[reste]
	push dx							; dans le cas de la partie entière d'un seul digit, le reste de la division se trouve dans 'reste'
	add WORD [quotient],48

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1
	int 80H

	pop dx
	cmp dx,0
	ja afficherpartiedecimale		;	si il y a un reste il faut afficher la partie décimale
	je fin							; sinon on peut arrêter le traitement

fin:
	
	mov WORD [displayme],10

	mov ax,4
	mov bx,1
	mov ecx,displayme
	mov dx,1	
	int 80H

	mov eax,1
	mov ebx,0
	int 80H

afficherpartiedecimale:
	cmp WORD dx,0					; ceci au cas où nous venions du "bloc" 'diminuerrang'
	jz fin

	mov WORD [displayme],','
	
	mov ax,4
	mov bx,1
	mov ecx,displayme
	mov dx,1	
	int 80H

afficherdecimales:

	mov bx,[reste]
	mov ax,10
	mul bx											

	mov bx,[diviseur]
	div bx

	mov [quotient],ax
	mov [reste],dx
	
	add wORD [quotient],48

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1
	int 80H

	cmp WORD [reste],0
	jz fin
	dec WORD [precision]
	jz arrondir
	jmp afficherdecimales

arrondir:
	mov WORD bx,[reste]
	mov ax,10
	mul bx

	mov bx,[diviseur]
	div bx

	mov [quotient],ax
	add WORD [quotient],48

	; effectuer la division suivante et si la valeur >5 on "arrondi" (on ajoute 1)

	mov bx,[reste]
	mov ax,10
	mul bx
	
	mov bx,[diviseur]
	div bx
	
	; faut-il arrondir en fonction de cette dernière division ?
	
	cmp WORD bx,5
	jbe lastdigit					; si plus petit ou égal à 5 on l'affiche tel quel
	add WORD [quotient],1			; si plus grand que 5 on "arrondi"
	
lastdigit:

	; afficher le dernier nombre arrondi ou non
	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H	
 
	jmp fin
	
