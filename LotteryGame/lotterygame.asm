include Irvine32.inc

.data

	msg byte "				 Lives Remaining: ",0
	outOfBounds byte "Your number is out offset bounds please input a number in range.",0
	lessMsg byte "Oh! The number is less than your guess",0
	equalMsg byte "WOW! Your guess is correct the number is: ",0
	greaterMsg byte "Oh! The number is greater than your guess",0
	lostMsg byte "WOW! You lost. Better luck next time!",0

	easyMsg byte "Enter a number b/w 1 and 10: ",0
	medMsg byte "Enter a number b/w 1 and 50: ",0
	hardMsg byte "Enter a number b/w 1 and 100: ",0

	random dword ?
	life dword 0
	remaining dword 10

	difficultyLevel dword 0
    	difficultyPrompt byte "Select Difficulty Level (0 - Easy, 1 - Medium, 2 - Hard): ", 0
   	difficultyInput dword 0

	quitPrompt byte "Would you like to quit? (0 - Restart, 1 - Quit): "
	quitInput dword 0

	upperBound dword 0

	Correct = green			; green text
	DefaultColor = white		; white text
	Incorrect = red			; red text

	difficultyError byte "Please enter a valid difficulty (0 - Easy, 1 - Medium, 2 - Hard): ", 0
	quitError byte "Invalid input. Please only enter (0 - Restart, 1 - Quit): ", 0



.code
main proc

	jmp SetDifficulty

	; First prompt for setting difficulty
	SetDifficulty:
		; Prompts the user to select the difficulty level
		mov edx, offset difficultyPrompt
		call writestring
		call DifficultySetter

	; Sets the difficulty
	DifficultySetter:
		; Reads the difficulty level input
		call readint
		mov difficultyLevel, eax

		cmp difficultyLevel, 0
		jl InvalidDifficulty

		cmp difficultyLevel, 2
		jg InvalidDifficulty
		
		jmp GenerateRandom

	; Bounds error for difficulty
	InvalidDifficulty:
		push eax
		mov eax, Incorrect
		call SetTextColor
		pop eax

		mov edx, offset difficultyError
		call writestring

		mov eax, DefaultColor
		call SetTextColor

		call DifficultySetter
		
		
    SetUpperBound:
		; Sets the upper bound based on difficulty level
        cmp difficultyLevel, 0
        je EasyUpperBound
        cmp difficultyLevel, 1
        je MediumUpperBound
        cmp difficultyLevel, 2
        je HardUpperBound
        ret

	; Easy difficulty, between the range 1 - 10
    EasyUpperBound:
        mov eax, 9
		mov upperBound, eax
		inc upperBound
        ret

	; Medium difficulty, between range 1 - 50
    MediumUpperBound:
        mov eax, 49
		mov upperBound, eax
		inc upperBound
        ret

	; Hard Difficulty, between range 1 - 100
    HardUpperBound:
        mov eax, 99
		mov upperBound, eax
		inc upperBound
        ret

	; Generates the random number for each round of play. 
	GenerateRandom:
		; The only time GenerateRandom is called is when a new round is beginning, thus remaining lives is 10 and total
		; lives removed is 0.
		mov life, 0
		call Randomize
		; set the upper bound for the randomized number
		call SetUpperBound
		; randomrange checks eax and utilizes the stored value as an upperbound for the randomized number
		call RandomRange
		mov random, eax
		; to exclude zero from the randomized number pool, we simply increment the number by 1
		; since we increment the randomized number by 1, the upperbound must also be decreased by 1.
		; for instance, if the number generated is 99 (the upper bound for hard difficulty)
		; the actual number used would be 100, which is the true upper bound (the highest possible 
		; randomized number, 99, plus 1).
		inc random
		jmp GuessNum

	;Prompts to guess first number with every guess until they match.
	;Then will jump t second loop for the next number to guess
	;Goal is to guess all number under the life count

	; Algorithm utilized when user guesses numbers.
	GuessNum: 
		; Shows the answer for testing
		mov eax, random

		call crlf

		; Writes out remaining lives
		mov edx, offset msg
		call writestring
		
		; The value stored in 'life' represents the number of lives already lost throughout the span of the game.
		; When calculating the remaining number of lives, we subtract the number of lives lost from the total
		; number of lives possible, which is 10.
		mov eax, life
		mov remaining, 10
		sub remaining, eax
		mov eax, remaining
		
		; Visually appends the current remaining lives to the end of the message
		call writedec
		call crlf
		call crlf

		; Display prompt for range of numbers to be guessed by the user based on selected difficulty level
		call DisplayMessage

		; Stores user input into eax 
		call readdec
		call crlf

		; Checks bounds of guessed number
		cmp eax,1
		jl boundsError
		cmp eax, upperBound
		jg boundsError
		
		; Checks for equality and give hints
		inc life
		cmp eax, random
		jl less
		je equal
		jg greater

		; If there are remaining lives, continue looping
		cmp remaining, 0
		jg LoopNums

	LoopNums:
		jmp GuessNum

	; For dynamically setting the prompt for the range of numbers for each difficulty level before each user guess
	DisplayMessage:
		cmp difficultyLevel, 0
		je EasyMessage
		cmp difficultyLevel, 1
		je MediumMessage
		cmp difficultyLevel, 2
		je HardMessage
		ret

	EasyMessage:
		mov edx, offset easyMsg
		call writestring
		ret

	MediumMessage:
		mov edx, offset medMsg
		call writestring
		ret

	HardMessage:
		mov edx, offset hardMsg
		call writestring
		ret

	; Handles if the number guessed is less than original 
	less:
		mov edx, offset greaterMsg
		call writestring

		call crlf
		call crlf
		call crlf

		mov eax, life

		cmp eax, 10

		je Lost
		jl GuessNum

	; Handles if the number guessed is equal to the original 
	equal:
		push eax
		mov eax, Correct
		call SetTextColor
		pop eax

		mov edx, offset equalMsg
		call writestring

		mov edx, random
		call writedec

		mov eax, DefaultColor
		call SetTextColor

		call crlf

		; Prompts user if they would like to continue playing by restarting or quit
		mov edx, offset quitPrompt
		call writestring

		call RestartOrQuit

	RestartOrQuit:
		; Reads in user input (0 for Continue, 1 for Quit)
		call readint
		mov quitInput, eax

		cmp quitInput, 0
		jl InvalidQuit

		cmp quitInput, 1
		jg InvalidQuit

		call crlf
		call crlf

		cmp quitInput, 0
		je SetDifficulty

		cmp quitInput, 1
		je quit

	InvalidQuit:
		push eax
		mov eax, Incorrect
		call SetTextColor
		pop eax

		mov edx, offset quitError
		call writestring

		mov eax, DefaultColor
		call SetTextColor

		call RestartOrQuit
		
	; Handles if the number guessed is greater than original 
	greater:
		mov edx, offset lessMsg
		call writestring

		call crlf
		call crlf
		call crlf

		mov eax, life

		cmp eax, 10
		
		je Lost
		jl GuessNum
	
	; Handles if the number guessed is out of bounds
	boundsError:
		push eax
		mov eax, Incorrect
		call SetTextColor
		pop eax

		mov edx, offset outOfBounds
		call writestring

		mov eax, DefaultColor
		call SetTextColor

		call crlf
		mov eax,random

		jmp GuessNum

	; Handles if player loses
	Lost:
		push eax
		mov eax, Incorrect
		call SetTextColor
		pop eax

		mov edx, offset lostMsg
		call writestring

		mov eax, DefaultColor
		call SetTextColor

		call crlf
		call crlf

		; Prompts user to quit or continue
		mov edx, offset quitPrompt
		call writestring

		; Reads in user input (0 for Continue, 1 for Quit)
		call readint
		mov quitInput, eax

		call crlf
		call crlf

		cmp quitInput, 0
		je SetDifficulty

		cmp quitInput, 1
		je quit

	quit:
		
	
exit
main endp
end main
