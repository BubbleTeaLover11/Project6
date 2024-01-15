TITLE Proj6_chenwill     (Proj6_chenwill.asm)

; Author:	William Chen
; Last Modified:	12.5.2023
; OSU email address: chenwill@oregonstate.edu
; Course number/section:	400  CS271 Section 1
; Project Number:	Project 6                Due Date:	12.10.2023
; Description:
; This project takes 10 numbers. Numbers are then converted form string form via Irvine32's ReadString.
; These numbers are then validated to see if they fall within a SDWORD range, and if they don't then a valid number
; must be entered by converting it back into a integer. This is done until 10 valid numbers are reached. The 10 numbers are also 
; stored in another array, in which they must then be back-displayed via converting an integer to a string and displayed using WriteString.
; The array's truncated average and sum is also displayed.

INCLUDE Irvine32.inc
; ---------------------------------------------------------------------------------	
; Name: mDisplayString
;
; Prints out string passed into it
;
; Preconditions: 
; Cannot use EDX
;
; Receives: 
; String			=	Array Address
;
; returns: 
; Print to Terminal Screen
; ---------------------------------------------------------------------------------
mDisplayString MACRO String
	push	EDX
	mov		EDX, String
	call	WriteString
	pop		EDX
ENDM

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Grabs user input for a string passed into it
;
; Preconditions: Called upon by ReadVal and EDX & ECX not used
;
; Receives:
; prompt			=	Array Address
; stringAddress		=	Array Address
; stringLen			=	Integer
;
; returns: 
; stringAddress
; stringLen
; ---------------------------------------------------------------------------------
mGetString MACRO prompt, stringAddress, stringLen
;Grab user string, returns string and stringlen
	push	EDX
	push	ECX
	push	EAX
	mov		EDX, prompt
	mDisplayString EDX
	mov		EDX, stringAddress	;Contains address
	mov		ECX, 33				;Unsure what to make buffer
	call	ReadString
	mov		stringLen, EAX
	pop		EAX
	pop		ECX
	pop		EDX
ENDM

.data
;Prompts
intro			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
author			BYTE	"Written by: William Chen", 0 
prompt1			BYTE	"Please provide 10 signed decimal integers.", 0
prompt2			BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value. ", 0
signPrompt		BYTE	"Please enter an signed number: ",0
errorMsg		BYTE	"ERROR: You did not enter a signed number or your number was too big.", 0
comma			BYTE	", ", 0
enterPrompt		BYTE	"You entered the following numbers:", 0
sumPrompt		BYTE	"The sum of these numbers is: ", 0
avgPrompt		BYTE	"The truncated average is: ", 0
byeStmnt		BYTE	"Thanks for playing!", 0

;Data
negative		DWORD	0
numCheck		DWORD	33 DUP(?)
num				SDWORD	?
numArray		SDWORD	10 DUP(?)
arrayIdx1		DWORD	0		;Used to loop through the 1st instruction 10 times
arrayIdx2		DWORD	0		;Used to loop through the 2nd instruction 10 times
numSum			SDWORD	?
numAvg			SDWORD	?
zero			DWORD	0
errorBool		DWORD	1		


.code 
main PROC
; ---------------------------------------------------------------------------------
;Main Procedural calls, does what the description intends to do
;Grabs ten integers from user input
;Displays error if not int
;Converts input from int to string
;Finds sum, then uses sum to find average
;Numbers are reconverted from integer to string and displayed
;Sum and Average are also converted integer to string and displayed
; ---------------------------------------------------------------------------------
	_Intro:
	push	OFFSET prompt2
	push	OFFSET prompt1
	push	OFFSET author
	push	OFFSET intro
	call	Introduction
	call	CrLf
	mov		ECX, 10

	_TenInts:
	;Grabs 10 Integers
	mov		EAX, ECX
	push	OFFSET numArray		
	push	OFFSET signPrompt	
	push	arrayIdx1			;Iterates through making string to int
	push	OFFSET errorMsg
	call	ReadVal
	cmp		ECX, EAX
	jg		_LoopFix
	inc		arrayIdx1
	loop	_TenInts
	mov		ECX, 10
	mov		EAX, OFFSET	enterPrompt
	call	CrLf
	mDisplayString EAX
	call	CrLf
	jmp		_PrintNums

	_LoopFix:
	;Loops back without incrementing arrayIdx
	loop	_TenInts

	_PrintNums:
	;Prints 10 Nums
	push	OFFSET numArray
	push	arrayIdx2			;Iterates through making int a string
	call	WriteVal			;0's and negative
	cmp		ECX, 1
	je		_SumAvg
	mov		EAX, OFFSET comma
	mDisplayString EAX
	inc		arrayIdx2
	loop	_PrintNums

	_SumAvg:
	;Calculates Sum and Average & Prints them out
	call	CrLf
	mov		EAX, OFFSET sumPrompt
	mDisplayString EAX
	push	OFFSET numArray
	call	Sum 
	call	CrLf
	mov		EAX, OFFSET avgPrompt
	mDisplayString EAX
	push	OFFSET numArray
	call	Average

	_Farewell:
	;Says Farewell
	call	CrLf
	call	CrLf
	mov		EAX, OFFSET byeStmnt 
	mDisplayString EAX
	INVOKE	ExitProcess, 0		;exit to operating system
	exit
main ENDP

; ---------------------------------------------------------------------------------
; Name: Introduction
;
; Introduction shows the introduction to be printed
;
; Preconditions: N/A
;
; Postconditions: N/A
;
; Receives: 
; [EBP + 8]			=	Array Address
; [EBP + 12]		=	Array Address
; [EBP + 16]		=	Array Address
; [EBP + 20]		=	Array Address
; 
; Returns: 
; Prints onto screen
; ---------------------------------------------------------------------------------
Introduction PROC
; ---------------------------------------------------------------------------------
; Grabs introduction via prompts
; Calls mDisplayString to display all strings
; ---------------------------------------------------------------------------------
	push	EBP
	mov		EBP, ESP
	pushad
	mDisplayString [EBP + 8]
	call	CrLf
	mDisplayString [EBP + 12]
	call	CrLf
	call	CrLf
	mDisplayString [EBP + 16]
	mDisplayString [EBP + 20]
	call	CrLf
	popad
	pop		EBP
	RET		16
Introduction ENDP

; ---------------------------------------------------------------------------------
; Name: Sum
;
; Sum finds the value of all the values in an array
; 
; Preconditions: Array is a SDWORD type
;
; Postconditions: N/A
;
; Receives:
; [EBP + 8]			=	Array Address
;
; Returns: none
; ---------------------------------------------------------------------------------
Sum PROC USES EAX EBX EDX EDI 
; ---------------------------------------------------------------------------------
; Sets the beginning of the array then adds it up to the EAX array
; EAX starts at 0 and iteratively adds EDI values
; If a value is negative, we negate the value then subtract it from the total
; ---------------------------------------------------------------------------------
LOCAL	negBool:DWORD, cumSum:SDWORD
	mov		EDI, [EBP + 8]
	push	ECX
	mov		ECX, 10
	mov		cumSum, 0

	_Cummulative:
	;Finds starting Index
	mov		EBX, [EDI]
	cmp		EBX, 0
	jg		_Add
	jl		_Sub

	_Sub:
	;Subtracts numbers if negative
	neg		EBX					;Sets EBX to negative
	sub		cumSum, EBX			;Subtracts it from EAX to store
	js		_SetNeg
	add		EDI, 4
	loop	_Cummulative
	jmp		_NegCheck

	_Add:
	;Adds number if positive
	add		cumSum, EBX
	jns		_ClearNeg
	add		EDI, 4
	loop	_Cummulative
	jmp		_NegCheck

	_SetNeg:
	;Negative Boolean setting
	mov		negBool, 1
	add		EDI, 4
	loop	_Cummulative
	jmp		_NegCheck

	_ClearNeg:
	;Clearing Negative Boolean Setting
	mov		negBool, 0
	add		EDI, 4
	loop	_Cummulative

	_NegCheck:
	;Checks negative Boolean
	mov		EBX, negbool
	cmp		EBX, 1				

	_Return:
	;Returns
	lea		EAX, cumSum
	push	EAX
	push	0
	call	WriteVal
	pop		ECX
	RET		4

Sum ENDP

; ---------------------------------------------------------------------------------
; Name: Average
;
; Averages from a given sum passed by value from main from the sum procedure
;
; Preconditions: Array is a SDWORD type
;
; Postconditions: N/A
;
; Receives:
; [EBP + 8]			=	Array Address
;
; Returns: N/A
; ---------------------------------------------------------------------------------
Average PROC USES EAX EBX EDX EDI
; ---------------------------------------------------------------------------------
; Gets numsum and does signed integer division by 10
; ---------------------------------------------------------------------------------
LOCAL	negBool:DWORD, cumSum:SDWORD, avgNum:SDWORD
	mov		EDI, [EBP + 8]
	push	ECX
	mov		ECX, 10
	mov		cumSum, 0

	_Cummulative:
	;Finds starting Index
	mov		EBX, [EDI]
	cmp		EBX, 0
	jg		_Add
	jl		_Sub

	_Sub:
	;Subtracts numbers if negative
	neg		EBX					;Sets EBX to negative
	sub		cumSum, EBX			;Subtracts it from EAX to store
	js		_SetNeg
	add		EDI, 4
	loop	_Cummulative
	jmp		_NegCheck

	_Add:
	;Adds number if positive
	add		cumSum, EBX
	jns		_ClearNeg
	add		EDI, 4
	loop	_Cummulative
	jmp		_NegCheck

	_SetNeg:
	;Negative Boolean setting
	mov		negBool, 1
	add		EDI, 4
	loop	_Cummulative
	jmp		_NegCheck

	_ClearNeg:
	;Clearing Negative Boolean Setting
	mov		negBool, 0
	add		EDI, 4
	loop	_Cummulative

	_NegCheck:
	;Checks negative Boolean
	mov		EBX, negbool	

	_Return:
	;Returns
	mov		EAX, cumSum
	mov		EBX, 10
	mov		EDX, 0
	cdq
	idiv	EBX
	mov		avgNum, EAX
	lea		EAX, avgNum
	push	EAX
	push	0
	call	WriteVal
	pop		ECX
	RET		4
Average ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; ReadVal invokes mGetString with passed in parameters
;
; Preconditions: N/A
;
; Postconditions: N/A
;
; Receives: Stack needs to contain error prompt, signprompt, count, numArray in that order from bottom to top of stack
; [EBP + 8]				=	32 Bit Signed Int
; [EBP + 16]			=	Array Address
; [EBP + 32]			=	Array Address
;
; Returns: N/A
; ---------------------------------------------------------------------------------
ReadVal PROC USES EAX EBX EDX ESI
; ---------------------------------------------------------------------------------
;Initializes negval, tempNum, len, inputNum as locals
;Gets a numerical string via mGetString
;Checks bit by bit to see if it is valid
;	if every bit is valid, overflow flag is checked
;	If bit is invalid, returns a bool value of 0 in EBX
;	if overflow is ok, then number gets passed to valid input to be checked whether it is negative
;	if it isn't negative then it gets passed onto EAX
;	if it is negative, then EAX is turned negative
;local negVal sets a boolean which at the end negates the value entered
;local tempnum holds a number to be added
;local len holds the len of the string passed in via mGetString
;local inputNum holds the numbe rinputted
; ---------------------------------------------------------------------------------
LOCAL	negVal:DWORD, tempNum:SDWORD, len:DWORD, inputNum[12]:BYTE
	mov		negVal, 0
	push	EBX
	lea		EAX, inputNum
	mov		len, 0
	mGetString	[EBP + 16], EAX, len
	lea		ESI, inputNum
	push	ECX
	mov		tempNum, 0
	mov		ECX, len
	mov		EAX, 0

	_IterativeLoop:
	CLD
	LODSB	
	cmp		AL, 48
	jl		_Maybe
	cmp		AL, 57
	jg		_Maybe
	sub		AL, 48
	mov		EBX, 10
	push	ECX						;Stores Loop counter
	dec		ECX
	cmp		ECX, 0
	je		_ValidReturn

	_Power10:
	mul		EBX
	jo		_Invalid
	loop	_Power10
	add		tempNum, EAX				
	mov		EAX, 0					;Sets EAX so that AL can be passed into it without worry
	pop		ECX
	jo		_Invalid				;Checks overflow flag
	loop	_IterativeLoop
	
	_Maybe:
	cmp		AL, 45					;Checks for + and - signs
	je		_Negative
	cmp		AL, 43
	je		_Positive
	jmp		_InvalidSign

	_Negative:
	cmp		ECX, len
	jne		_Invalid
	mov		negVal, 1				;Set Negative val to true
	loop	_IterativeLoop

	_Positive:
	cmp		len, 1
	je		_InvalidSign
	loop	_IterativeLoop

	_ValidReturn:
	pop		ECX
	add		tempNum, EAX
	jo		_Invalid	
	mov		EAX, tempNum
	cmp		negVal, 1				;Negative boolval to be used at the end
	je		_Negation
	push	[EBP + 20]
	push	[EBP + 12]
	push	tempNum
	call	StoreInt				;Stores Integer at array at index
	pop		ECX
	pop		EBX
	RET		16	
	
	_Negation:		
	neg		EAX						;Negates EAX
	mov		tempNum, EAX
	mov		negVal, 0
	pop		ECX
	push	[EBP + 20]
	push	[EBP + 12]
	push	tempNum
	call	StoreInt				;Stores Integer at array at index
	pop		EBX
	RET		16

	_InvalidSign:
	pop		ECX
	inc		ECX
	pop		EBX
	mDisplayString	[EBP + 8]
	call	CrLf
	RET		16

	_Invalid:
	pop		ECX
	pop		ECX						;Need to pop ECX twice from Power10 Loop and from stack
	inc		ECX
	pop		EBX
	mDisplayString	[EBP + 8]
	call	CrLf
	RET		16
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; WriteVal converts a number (IntType) to a displayed number (StringType)
;
; Preconditions: Array is SDWORD type
;
; Postconditions: N/A
;
; Receives: 
; [EBP + 8]				=	Array Address or Number Address
; [EBP + 12]			=	Integer
; 
; Returns: Prints to terminal number
; ---------------------------------------------------------------------------------
WriteVal PROC USES EAX EBX EDX ESI EDI
; ---------------------------------------------------------------------------------
;Clears out outString as it contains random numbers when initialized
;Acquires index ot be moved via Index loop
;Passed in number is sequentialily divided by 10 in EAX reg
;While EAX != 0
;	Divide by 10
;	Store Remainder in AL
;	Add Al + 48 to get the number
;	Store string in outString
;After, string is checked if its negative and if it is then, a (-) is added at the end
;String is reversed and then pritned
;Local tempString used to hold string from adding
;Local index adds to EDI index
;local negVal sets a boolean val where a (-) is added or not
;local outString is what is reversed and set to be printed
;local counter provides how many times the string is to be used
; ---------------------------------------------------------------------------------
LOCAL	tempString[11]:BYTE, index:DWORD, negVal:DWORD, outString[11]:BYTE, counter:DWORD
	push	ECX
	mov		ECX, 11
	lea		EDI, outString

	_outStringFormat:
	mov		AL, 0
	STOSB
	loop	_outStringFormat
	mov		EDI, [EBP + 12]
	mov		ECX, [EBP + 8]
	cmp		ECX, 0
	mov		index, 0
	mov		counter, 0			;Holds the value to counter to find the length of tempstring
	je		_NumCheck

	_IndexLoop:
	add		index, 4
	loop	_IndexLoop

	_NumCheck:
	CLD							;Set flag to go forwrad
	add		EDI, index			;Goes to approriate index
	mov		EAX, [EDI]
	cmp		EAX, 0 
	lea		EDI, tempString		;Change EDI address
	jl		_Negative			;Sets negative
	mov		EBX, 10
	jmp		_DoWhile

	_Negative:
	mov		negVal, 1			;True negative val
	neg		EAX
	lea		EDI, tempString		;Change EDI address

	_DoWhile:
	inc		counter
	mov		EDX, 0
	mov		EBX, 10

	_Divide:
	div		EBX					
	push	EAX
	mov		EAX, 0
	add		EDX, 48
	mov		EAX, EDX
	STOSB						;Moves from AL to tempstring
	pop		EAX		
	cmp		EAX, 0				;If quotient is not 0, then keep dividing
	je		_NegCheck
	jmp		_DoWhile

	_NegCheck:
	cmp		negval, 1
	jne		_Print
	inc		counter
	mov		EAX, 0
	mov		AL,	45
	STOSB

	_Print:
	mov		ECX, counter
	lea		ESI, tempString
	add		ESI, ECX
	dec		ESI
	lea		EDI, outString

	_revLoop:					;Reverses string
	STD
	LODSB
	CLD
	STOSB
	loop	_revLoop

	_Display:
	lea		EAX, outString
	mDisplayString EAX 
	pop		ECX
	RET		8
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: StoreInt
;
; StoreInt stores integers in the Array passed through it
;
; Preconditions: Array is SDWORD type, called as procedure
;
; Postconditions: N/A
;
; Receives:
; [EBP + 8]				=	Integer
; [EBP + 12]			=	Integer
; [EBP + 16]			=	Array Address
;
; Returns: N/A
; ---------------------------------------------------------------------------------
StoreInt PROC
; ---------------------------------------------------------------------------------
;StoreInt Proc moves an array and an index
;Index gets looped to get to the correct direction of the array
;Number is then stored from previous EAX reg from ReadVal call
; ---------------------------------------------------------------------------------
	push	EBP
	mov		EBP, ESP
	pushad
	mov		EAX, [EBP + 8]
	mov		ECX, [EBP + 12]
	mov		EDI, [EBP + 16]
	cmp		ECX, 0				;Store at 0 idx, not need ot go through loop
	je		_Store
	mov		EDX, 0

	_IndexLoop:
	add		EDX, 4						
	loop	_IndexLoop
	add		EDI, EDX

	_Store:
	mov		[EDI], EAX
	popad
	pop		EBP
	RET		12					;3 Dwords Passed on, clear 8
StoreInt ENDP
END MAIN