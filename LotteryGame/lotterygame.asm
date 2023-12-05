include Irvine32.inc

.data

	msg byte "				 Lives Remaining: ",0
	mainMsg byte "Enter a number b/w 1 and 69: ",0
	outOfBounds byte "Your number is out offset bounds please input anumber in range.",0
	secMsg byte "Enter a number b/w 1 and 26: ",0
	lessMsg byte "Oh! The number is less then your guess",0
	equalMsg byte "WOW! Your guess is correct the number is: ",0
	greaterMsg byte "Oh! The number is greater then your guess",0
	allEqualMsg byte "WOW! You guesssed all the numbers correct the last number was: ",0

	random dword ?
	newRandom dword ?
	life dword 0
	remaining dword 10

.code
main proc
	;call for randomized number
	call Randomize

	;reminder for abi to fix offset so it ranges 1-69
	mov eax, 69

	call RandomRange
	mov random, eax
	mov newRandom, 0

	;this shows answer for testing
	call writedec

	;line break
	call crlf

	Start:
		
	
	;Prompts to guess first number with every guess until they match.
	;Then will jump t second loop for the next number to guess
	;Goal is to guess all number under the life count
	FirstNum:
		;Write out the lives remaining
		mov edx, offset msg
		call writestring
		
		mov eax, life
		cmp eax, 10
		mov remaining, 10
		sub remaining, eax
		mov eax, remaining
		
		call writedec
		call crlf
		call crlf


		mov edx, offset mainMsg
		call writestring

		call readdec
		call crlf

		;Check bounds of guessed number
		cmp eax,1
		jl boundsError
		cmp eax, 69
		jg boundsError
		
		;check equality and give hint
		inc life
		cmp eax, random
		jl less
		je equal
		jg greater
		
	;Jump to next number to guesss
	Next:
		mov eax,0
		call Randomize

		mov eax, 26

		call RandomRange
		mov random, eax
		mov newRandom, eax

		call writedec

		call crlf

		jmp LastNum
	
	;Jumps to last number to guess 
	;Prompts user to keep guessing until they get a match or run out of lives
	LastNum:
		mov edx, offset msg
		call writestring

		mov eax, life
		cmp eax, 10
		mov remaining, 10
		sub remaining, eax
		mov eax, remaining
		
		call writedec

		call crlf
		call crlf

		mov edx, offset secMsg
		call writestring

		call readdec
		call crlf

		;Check bounds of guessed number
		cmp eax,0
		jl boundsError
		cmp eax, 26
		jg boundsError

		inc life
	
		cmp eax, random
		jl lessLast
		je equalLast
		jg greaterLast

	Loop LastNum


	;checking for if the number guessed is less or greater than original
	;name with suffix -Last is final number
	less:
		mov edx, offset greaterMsg
		call writestring

		call crlf
		call crlf
		call crlf

		mov eax, life

		cmp eax, 10

		je quit
		jl FirstNum

	lessLast:
		mov edx, offset greaterMsg
		call writestring

		call crlf
		call crlf
		call crlf

		mov eax, life

		cmp eax, 10
		
		je quit
		jl LastNum

	equal:
		mov edx, offset equalMsg
		call writestring

		mov edx, random
		call writedec

		call crlf
		call crlf
		
		dec life
		

		jmp Next

	equalLast:
		mov edx, offset allEqualMsg
		call writestring

		mov edx, random
		call writedec

		call crlf
		call crlf

		jmp quit

	greater:
		mov edx, offset lessMsg
		call writestring

		call crlf
		call crlf
		call crlf

		mov eax, life

		cmp eax, 10
		
		je quit
		jl FirstNum

	greaterLast:
		mov edx, offset lessMsg
		call writestring

		call crlf
		call crlf
		call crlf

		mov eax, life

		cmp eax, 10
		
		je quit
		jl LastNum

	
	boundsError:
		mov edx, offset outOfBounds
		call writestring

		;dec life
		call crlf
		mov eax,random
		cmp eax, newRandom
		je LastNum

		jmp Start

	quit:
		
	
exit
main endp
end main

