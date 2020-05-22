TITLE gcd.asm
; Program description: finds the gcd of 2 numbers and determines if the gcd is prime
; Author: Muhammad Hussain
; Creation date: 11/26/19

INCLUDE Irvine32.inc

ClearRegs proto
ClearArray proto, 
	ArrAd:dword
DisplayMenu proto,
	menOff:dword
DoTheSieve proto,
	arrayPtr:dword
GetN proto,
	baseOff:dword
GetGCD proto,
	var1off:dword,
	var2off:dword,
	gcdAdoff:dword 
GetGCDPrime proto,
	gcdPoff:dword,
	gcdVal:word,
	PArrayOff:dword
PrintInfo proto,
	base1:word,
	base2:word,
	pgcd:word,
	pgcdp:byte

.data

	primeArray word 1001 DUP(0h), 0

	menuOption byte 0

	gcdBase1 word 0
	gcdBase2 word 0

	gcd word 0
	gcdprime byte 0

.code
main proc

	; clear registers 
	INVOKE ClearRegs

	; make an array of numbers
	INVOKE ClearArray, offset primeArray

	; sieve the array
	INVOKE DoTheSieve, offset primeArray

; Menu
MenuL: 
	call crlf
	INVOKE DisplayMenu, offset menuOption

opt1:
	cmp menuOption, 1
	jne opt2
	; get 2 numbers from user, get the gcd, determine if prime, print gcd and primeTF

	; get 2 numbers from user
	invoke GetN, offset gcdBase1
	invoke GetN, offset gcdBase2

	; get the gcd
	invoke GetGCD, offset gcdBase1, offset gcdBase2, offset gcd

	; determine if prime
	invoke GetGCDPrime, offset gcdprime, gcd, offset primeArray

	; print gcd and primeTF
	invoke PrintInfo, gcdBase1, gcdBase2, gcd, gcdprime

	jmp MenuL


opt2:

exit
main endp










COMMENT @
Prints info in the format from the specs
recieves:
gcdBase1 
gcdBase2 
gcd word 
gcdprime 
returns:
nothing, but prints to the screen
requires:
eax and edx registers
@
PrintInfo proc,
	base1:word,
	base2:word,
	pgcd:word,
	pgcdp:byte
	; from main: 
	;gcdBase1 word 0
	;gcdBase2 word 0
	;gcd word 0
	;gcdprime byte 0
.data
	p1 byte "Number 1, Number 2, GCD, Prime? ", 0
	p2 byte "------------------------------- ", 0
	p3 byte "       ", 0
	p4 byte " ", 0

	p5 byte "Yes", 0
	p6 byte "No", 0

.code
	
	; start writing all the pre-baked stuff

	mov edx, offset p1
	call writestring
	call crlf

	mov edx, offset p2
	call writestring
	call crlf

	; end start writing all the pre-baked stuff

	movzx eax, base1 ; write the fist user number
	call writedec

	mov edx, offset p3 ; spacer
	call writestring

	movzx eax, base2 ; write the second user number
	call writedec

	mov edx, offset p3
	call writestring

	movzx eax, pgcd ; write the gcd
	call writedec

	mov edx, offset p4
	call writestring

	; based on if the gcd is prime, print yes/no

	cmp pgcdp,1d
	je PrintPrime

	mov edx, offset p6
	call writestring

	ret 7

PrintPrime:

	mov edx, offset p5
	call writestring

	ret 7
PrintInfo endp

















COMMENT @
Determines if gcd is prime
recieves:
gcd prime? offset
value of gcd
offset for prime array
returns:
a 1 (true) or 0 (false) using the offset for prime?
requires:
esi, ecx, ebx, eax registers
@
GetGCDPrime proc,
	gcdPoff:dword,
	gcdVal:word,
	PArrayOff:dword
.data

.code

	; save the gcd in bx
	mov ebx, 0d
	mov bx, gcdVal

	; zero is not prime
	cmp bx, 0
	je NotPrime

	; start esi on the prime array offset
	mov esi, PArrayOff
	; give ecx enough runs to go through the prime array
	mov ecx, 0d
	mov ecx, 1001d

GPLoop:
	; look for the gcd in the prime array
	cmp word ptr [esi], bx
	je TruePrime
	add esi, 2
	loop GPLoop
	
NotPrime: 

	; if not prime, set the tracker to 0
	mov eax, 0d
	mov ecx, gcdPoff
	mov byte ptr [ecx], al
	ret 10

TruePrime:

	; if prime, set the tracker to 1
	mov eax, 1d
	mov ecx, gcdPoff
	mov byte ptr [ecx], al
	ret 10
GetGCDPrime endp












COMMENT @
Clears registers
Recieves:
nothing
Returns:
nothing
requires:
nothing
@
ClearRegs proc
.data
.code
	mov eax,0
	mov ebx,0
	mov ecx,0
	mov edx,0
	mov esi,0
	ret
ClearRegs endp








COMMENT @
Determines the gcd of 2 numbers
recieves:
the offset of the first base number
the offset of the first second number
the offset for the gdc holding variable in main
returns:
the gcd using the offset of the gdc holding variable in main
requires:
eax, ecx, edx, ebx registers
@
GetGCD proc,
	var1off:dword,
	var2off:dword,
	gcdAdoff:dword 
.data
	var1 word ?
	var2 word ?
	gcdAd dword ?

	currentCGD word ?

.code
	; save values locally
	mov eax, gcdAdoff
	mov gcdAd, eax

	mov ecx, var1off
	mov ax, word ptr [ecx]
	mov var1, ax

	mov edx, var2off
	mov ax, word ptr [edx]
	mov var2, ax

	; clear current gcd
	mov currentCGD, 0d

	; check for zeros or equal
	cmp var1, 0d
	je ZeroCase1
	cmp var2, 0d
	je ZeroCase2
	movzx ebx, var2
	cmp var1, bx
	je ZeroCase1

	invoke ClearRegs

	mov ebx, 0d
	mov ecx, 1001d
gcdLoop:
	mov eax, 0d ; clear regs
	mov edx, 0d

	inc bx ; check the next number

	; if we've hit one of the base numbers, escape
	cmp var1, bx
	jb escgcdLoop
	cmp var2, bx
	jb escgcdLoop

	; check if the current value of bx divides var1
	mov ax, var1
	div bx
	cmp dx, 0d
	jne gcdLoop

	mov eax, 0d
	mov edx, 0d

	; check if the current value of bx divides var2
	mov ax, var2
	div bx
	cmp dx, 0d
	jne gcdLoop

	; if it divides both, bx is the new current gcd
	mov currentCGD, bx
	loop gcdLoop
escgcdLoop:
	
	; save the current gcd
	mov eax, 0d
	mov ax, currentCGD
	mov ecx, gcdAd
	mov word ptr [ecx], ax
	ret 12

ZeroCase1:
	; the gcd is one of the two numbers
	mov eax, 0d
	mov ax, var2
	mov ecx, gcdAd
	mov word ptr [ecx], ax
	ret 12

ZeroCase2:
	; the gcd is one of the two numbers
	mov eax, 0d
	mov ax, var1
	mov ecx, gcdAd
	mov word ptr [ecx], ax
	ret 12
GetGCD endp













COMMENT @
Gets a base number for determining gcd
recieves:
the offset of the number
returns:
the user input using the offset given
requires:
eax, edx, ebx registers
@
GetN proc,
	baseOff:dword
.data
	GNprompt byte "Please enter a number (0 to 1000) to find the gcd of: ", 0

.code

TryAgain:
	mov edx, offset GNprompt ; print prompt
	call writestring

	mov eax, 0
	call readdec ; get user input

	cmp eax, 1000d ; check for invalid input
	ja TryAgain

ZeroAccept:
	
	; save input
	mov ebx, baseOff
	mov word Ptr [ebx], ax
	call crlf
	
	ret 4
GetN endp













COMMENT @
Takes out non-primes from the prime array
recieves:
starting address for prime array
returns:
alters prime array
requires:
eax, esi registers
@
; sieve
DoTheSieve proc,
	arrayPtr:dword
.data

	mult dword 2d
	count dword 0d

.code

	; start the multiplier at 2
	mov mult, 2d

StaOuter:

	
	mov eax, 0
	mov eax, mult
	
	; move 2xmullt into count
	mov count, eax
	add count, eax

StaInner:
	
	mov esi, arrayPtr ; move esi to array offset
	add esi, count ; add 2xcount
	add esi, count

	mov word ptr [esi], 0d ; move zero into this place

	add count, eax ; add eax (mult) into count

	cmp count, 1000d ; escape once array is transversed
	ja EndInner

	jmp StaInner

EndInner:
	
	inc mult ; increase mult

	cmp mult, 500d ; once we're up to 500, we can quit
	ja EndOuter

	jmp StaOuter

EndOuter:

	ret 4
DoTheSieve endp












COMMENT @
Displays menu
recieves:
offset for menu option holder in main
returns:
user input using given offset
requires:
edx, ebx, eax registers
@
; display menu
DisplayMenu proc,
	menOff:dword
.data
	menu1 byte "Hi here are some options: ", 0Ah, 0Dh, 
				"1: Find the gcd of 2 numbers, determine if gcd is prime.", 0Ah, 0Dh, 
				"2: Exit", 0Ah, 0Dh, 
				"Plz enter 1 or 2: ", 0
	
.code
	mov edx, offset menu1 ; show menu
	call writestring
	call crlf

	call readdec ; get input

	mov ebx, menOff ; save input
	mov byte ptr [ebx], al


	ret 4
DisplayMenu endp



COMMENT @
Creates a base array which we'll sieve later
recieves:
starting address for prime array
returns:
alters prime array
requires:
eax, ebx, ecx, registers
@
ClearArray proc,
	ArrAd:dword
.data

.code
	mov ebx, ArrAd ; move offset into ebx

	mov ax, 0d
	mov ecx, 1001d ; 0 to 1000
ClearLoop:
	mov word ptr [ebx], ax ; mov ax into this spot
	inc ax 
	add ebx, 2 ; move to the next spot
	loop ClearLoop

	ret 4
ClearArray endp


end main