;SECTION .data
;Variables initialisées ou constantes

SECTION .data

	quotient	dw 0
	reste			dw 0

	dividande	dw 0
	diviseur	dw 0
	precision	dw 15				; precision x+1 chiffres après la virgule

	rangpartent	dw 0
	displayme		dw 0

	strDividande	db	0,0,0,0,0,0,0,0,0
	szDividande		equ $-strDividande

	Err_001		db	"Usage: ./asmdivision <16 bits number dividend> <16 bits number divisor>",10,0 
	szErr_001	equ	$-Err_001
	Err_002		db "Error: division by zero !!",10,0
	szErr_002 equ $-Err_002

; SECTION .bss
; Block Starting Symbol
; Variables statiques ou non initialisées qui sont censées
; changer pendant l'exécution du programme

SECTION .bss

; Programme principal
; https://www.tutorialspoint.com/assembly_programming/assembly_arithmetic_instructions.htm
; Assembly Language Step by Step -- page 424

MAXARGS		equ		3
ArgCount	resd	1
ArgPtrs		resq	3
Caractere	resb	1

SECTION .text

global _start

_start:
	
	; new: get command line arguments
	; page 433

	nop
	
	; ecx devrait contenir le nombre d'arguments
	
	pop rcx
	cmp rcx,MAXARGS
	ja fin
	cmp rcx,1
	jz ErrorNoParams
	
	mov DWORD [ArgCount],ecx
	xor edx,edx
	
recupererarguments:

	pop rsi
	
	mov rdi,ArgPtrs
											
	; rsi contient la chaîne que l'on va copier

	push rdx
	push rcx

	xor rcx,rcx
	xor r8,r8									; r8 contiendra la taille de chaque paramètre
	cld

copierdatas:

	lodsb											; va charger un byte de rsi et le mettre dans al
	stosb											; on va mettre le caractère de al dans ArgPtrs[edx]
	
	inc r8

	cmp al,0	
	jne copierdatas						; tant que '\0' pas trouvé on continue...

	; afficher le paramètre (debug)

	push rax
	push rbx
	push rcx
	push rdx

	mov ax,4
	mov bx,1
	mov ecx,ArgPtrs
	mov rdx,r8
	int 80H

	mov BYTE [Caractere],10
	mov ax,4
	mov bx,1
	mov ecx,Caractere
	mov rdx,1
	int 80H

	pop rdx
	pop rcx
	pop rbx
	pop rax

	; fin du debug

	pop rcx
	pop rdx
	
	dec r8										; ne pas envisager le '\0'
	dec r8										; sinon on va dépasser le rang effectif
	
	mov r12,r8								; pour pouvoir gérer tous les digits il faut garder une trace du nombre de rangs (r8 sera modifié)
	mov rsi,ArgPtrs						;	lodsb
	mov rdi,strDividande			; stosb

	push rdx
	push rcx
	push r12

	; il faut s'assurer que r8 soit supérieur à 1 sinon ça va foirer !!!
	
	cmp r8,1
	jb unseuldigit
	jmp preparetocopy
	
unseuldigit:

	cmp edx,1
	je unseuldigitdividande
	ja unseuldigitdiviseur
	jmp continuer

preparetocopy:

	cmp edx,1									; ridicule mais bon
	je copierDividande
	jmp continuer

copierDividande:
	; on devrait avoir la taille (on a pas touché à r8) donc il est possible de convertir

	nop												; le débugger me casse les couilles
	xor rax,rax
	lodsb											; al devrait contenir le digit représentant le rang le plus élevé
	stosb											; al sera recopié dans szDividande
	
	xor rbx,rbx
	sub al,48
	
	mov r9,rax								; sauvegarder le nombre
	mov al,1				
	mov bx,10									; BASE 10
	
multiplierrang_dividande:

	; multiplier par le nombre de rangs
	mul bx
	dec r8
	cmp r8,0
	ja multiplierrang_dividande
	
	; al contient le rang
	; R9 contient le nombre
	
	mov rbx,rax
	mov rax,r9
	mul bx										; multiplier R9*rax (1000*1 100*7 10*6)
	
	; r10 va recevoir le résultat de la multiplication
	add r10,rax
	
	mov r8,r12								
	dec r8	
	dec r12										; à chaque fois le nombre de rangs doit diminuer
	
	cmp r12,0									; traiter les unités ?	
	ja copierDividande

unseuldigitdividande:	
	
	; pas sûr (en fait si ^^)	
	xor eax,eax
	lodsb
	stosb
	sub al,48									; passer de l'ASCII (48 à 57) à notre système décimal (0 à 9)
	add r10,rax								; on ajoute les unités
	
	; nous avons le dividande
	mov r13,r10
	mov al,0
	stosb											; ajouter le '\0'

continuer:

	xor r8,r8
	xor r9,r9
	xor r10,r10
	
	pop r12
	pop rcx
	pop rdx

	inc edx
	
	cmp edx,ecx
	jb recupererarguments

	mov rsi,ArgPtrs						; remetre RSI sur la bonne position
	mov r8,r12								; récupérer la taille de la chaîne
	
copierDiviseur:	

	nop												; le débugger me casse les couilles
	xor rax,rax
	lodsb											; al devrait contenir le digit représentant le rang le plus élevé
	
	xor rbx,rbx
	sub al,48
	
	mov r9,rax								; sauvegarder le nombre
	mov al,1				
	mov bx,10									; BASE 10

multiplierrang_diviseur:

	; multiplier par le nombre de rangs
	mul bx
	dec r8
	cmp r8,0
	ja multiplierrang_diviseur
	
	; al contient le rang
	; R9 contient le nombre
	
	mov rbx,rax
	mov rax,r9
	mul bx										; multiplier R9*rax (1000*1 100*7 10*6)
	
	; r10 va recevoir le résultat de la multiplication
	add r10,rax
	
	mov r8,r12								
	dec r8	
	dec r12										; à chaque fois le nombre de rangs doit diminuer
	
	cmp r12,0									; traiter les unités ?	
	ja copierDiviseur

unseuldigitdiviseur:	
	
	; pas sûr (en fait si ^^)	
	xor eax,eax
	lodsb
	sub al,48
	add r10,rax								; on ajoute les unités
	
	; nous avons le diviseur
	mov r14,r10

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	
preparetodivide:	
	
	mov rax,r13
	mov rbx,r14 

	mov WORD [dividande],ax
	mov WORD [diviseur],bx

	cmp BYTE [diviseur],0			; éviter que le diviseur soit à 0
	je ErrorDivZ

	cmp BYTE [diviseur],1			; recopier le dividande
	ja demonstration

	mov ax,4
	mov bx,1
	mov ecx,strDividande
	mov rdx,szDividande
	int 80H
	
	jmp fin

demonstration:

	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
			
	mov ax,[dividande]
	mov bx,[diviseur]	

	div bx	; ah va contenir le reste et al va contenir la partie entière (mode byte)
					; mode WORD
					; ax partie entière 
					; dx reste de la division

	mov [quotient],ax					
	mov [reste],dx
	mov bx,10									; on se prépare à déterminer le rang...
	mov ax,10

	cmp WORD [quotient],9
	mov dx,0									; pour éviter les FPE ???
	ja	determinerrang				; si le quotient occupe plus d'un caractère il faut effectuer l'affichage de l'unité pour chaque rang
	jbe afficherdigit					; sinon

; en assembleur on ne peut pas afficher par exemple 1200 d'un "seul coup"
; comme en C avec la fonction printf()...
; nous pourrions bien sûr invoquer printf() à partir de l'assembleur
; mais je ne maîtrise pas du tout la technique

; nous allons donc devoir afficher les caractères formant la partie entière
; un par un

determinerrang:
	mul bx										; ax contient le résultat
	cmp WORD ax,[quotient]
	mov WORD [rangpartent],ax
	jbe determinerrang

	; ici nous devrions obtenir le rang de la partie entière... à une puissance près

	div bx
	mov WORD [rangpartent],ax
	
	; ici nous avons le rang correct

	mov WORD ax,[quotient]
	mov WORD bx,[rangpartent]
	div bx										; à partir d'ici nous devrions pouvoir afficher les caractères...

diminuerrang:	
	mov WORD [displayme],ax
	
	mov ax,4
	mov bx,1
	add WORD [displayme],48
	mov ecx,displayme									
	push dx										; sauvegarder le reste de la division
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
	cmp WORD [rangpartent],1	; cas du 10000/2 (tant que le rang n'est pas 1 -- ou 10^0 -- on doit afficher les 0)
	jnz diminuerrang

afficherdigit:
	
	mov WORD dx,[reste]
	push dx										; dans le cas de la partie entière d'un seul digit, le reste de la division se trouve dans 'reste'
	add WORD [quotient],48

	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1
	int 80H

	pop dx
	cmp dx,0
	ja afficherpartiedecimale	; si il y a un reste il faut afficher la partie décimale
	
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
	cmp WORD dx,0							; ceci au cas où nous venions du "bloc" 'diminuerrang'
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
	jbe lastdigit							; si plus petit ou égal à 5 on l'affiche tel quel
	add WORD [quotient],1			; si plus grand que 5 on "arrondi"
	cmp WORD [quotient],9			
	jbe lastdigit
	mov WORD [quotient],9			; tant pis
	
lastdigit:

	; afficher le dernier nombre arrondi ou non
	mov ax,4
	mov bx,1
	mov ecx,quotient
	mov dx,1	
	int 80H	
 
	jmp fin

ErrorNoParams:
	mov ax,4
	mov bx,1
	mov ecx,Err_001
	mov dx,szErr_001

	int 80H

	jmp fin

ErrorDivZ:
	mov ax,4
	mov bx,1
	mov ecx,Err_002
	mov dx,szErr_002

	int 80H

	jmp fin
