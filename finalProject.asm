INCLUDE \masm32\include\masm32rt.inc  ; for using inkey
INCLUDE \masm32\include\Irvine32.inc
INCLUDE \masm32\include\textcolors.asm
INCLUDE \masm32\include\Macros.inc
INCLUDELIB \masm32\lib\Irvine32.lib

.486
.STACK 1000h

ExitProcess PROTO, DwErrorCode:DWORD

.DATA
	
	tiles Byte 64 DUP (' '); this is the 'piece' that is on the tile
                             ; defaults to have a space on it.
      buffer db 3 DUP(0)
      target db 3 DUP(0)
      inputX Byte ?
      inputY Byte ?
      bytecount dw ?
      
.CODE

  GetColor PROC, rowIndex: DWORD

    push ebx
    mov ebx, 2
    mov eax, rowIndex
    xor edx, edx
        
    div ebx

    cmp edx, 0
    je SetBlack
    jne SetWhite

    SetBlack:
        mov eax, black
        jmp Return
    SetWhite:
        mov eax, white
        jmp Return
        
    Return:
        pop ebx
        ret
    
  GetColor ENDP

  DrawBoard PROC
    Call Clrscr
    mov bl, 65 ; ascii val of char to write
    mov ecx, 8 ; loop count

    mov al, ' '
    Call WriteChar
    
    DrawLettersLoop:

        mov al, bl ; put the char into al example:('A')
        Call WriteChar ; write the letter
        inc bl
        
        dec ecx
        cmp ecx, 0
        jne DrawLettersLoop
        
    Call Crlf

    mov eax, 56 ; current line number to write
    mov ecx, 0 ; row index
    mov ebx, 1 ; counter for tile pattern
    
    DrawCoordsLoop:
	   mov esi, 0 ; column index
	   push ecx ; preserve ecx value (SetTextColor changes it)
	   push eax ; preserve eax value (SetTextColor changes it)

         Invoke SetTextColor, lightGray, black ; set the number text to be the correct color
         
         pop eax ; restore value
         pop ecx ; restore value
         
         Call WriteChar ; write the row number
         push eax ; preserve eax value to use for next iteration

         InnerLoop:
		Invoke GetColor, ebx ; alternates white and black

            push ebx ; preserve ebx
            
            mov ebx, 15
            push ecx ; preserve ecx value (SetTextColor changes it)
            sub ebx, eax ; inverse color of text to background
		Invoke SetTextColor, ebx, eax ; sets the background color
            
            ; This block gets the character to write from the array
            ; then writes the char to console.
            mov eax, 0
            mov ebx, 0

            ;Does the math to get the correct index
            ; X + (width * Y)
            pop ecx
            mov eax, 8
            mul ecx
            add eax, esi

            mov ebx, OFFSET tiles
            add ebx, eax
            mov eax, [ebx]
            
		Call WriteChar

		pop ebx ; restore ebx

            inc esi ; move to next tile
            inc ebx ; increment overall counter
            cmp esi, 8
            jne InnerLoop ; loop if not at end of row
        
        Call Crlf
        
	  pop eax
       
        dec eax
        inc ebx
        inc ecx
        cmp ecx, 8
        jne DrawCoordsLoop ; loop if not at end of board
        
    ret
    
  DrawBoard ENDP


GetInput PROC
    ; Receives: offset of buffer in edx
    ; Received: length of buffer in ecx
    
    mWrite "Please enter in a coodinate point using a-h for x and 1-8 for y: "
    
    call ReadString
    mov bytecount, ax
    
    call ReadFirst
    call ReadSecond

mov al, target[0]
mov inputX, al
mov al, target[1]
sub al, 30h
mov inputY, al

    
GetInput ENDP


ReadFirst proc
	mov edi, 0
	mov bl, buffer[0]
	cmp bl, 'a'
	je one
	cmp bl, 'b'
	je two
	cmp bl, 'c'
	je three
	cmp bl, 'd'
	je four
	cmp bl, 'e'
	je five
	cmp bl, 'f'
	je six
	cmp bl, 'g'
	je seven
	cmp bl, 'h'
	je eight
	jmp zero
	
	one:
		mov al, 1
		mov target[0], al
		jmp done
	two:
		mov al, 2
		mov target[0], al
		jmp done
	three:
		mov al, 3
		mov target[0], al
		jmp done
	four:
		mov al, 4
		mov target[0], al
		jmp done
	five:
		mov al, 5
		mov target[0], al
		jmp done
	six:
		mov al, 6
		mov target[0], al
		jmp done
	seven:
		mov al, 7
		mov target[0], al
		jmp done
	eight:
		mov al, 8
		mov target[0], al
		jmp done
	zero:
		mov al, 0
		mov target[0], al
		jmp done
	done:
		ret

ReadFirst ENDP

ReadSecond proc
    mov bl, 0
    mov bl, buffer[1]
    mov target[1], bl
    
    ret

ReadSecond ENDP

MovePiece PROC, x: DWORD, y: BYTE, char: Byte
    mov bh, char
    mov ecx, OFFSET tiles

    sub x, 1
    push edx
    mov eax, 8
    mul y
    add eax, x
    add ecx, eax
    pop edx
    call DumpRegs
    mov [ecx], bh
    ret
MovePiece ENDP

IsValid PROC x: DWORD, y: DWORD
    sub x, 1

    cmp x, -1
    je invalid
    jl invalid
    cmp x, 9
    je invalid
    jg invalid

    cmp y, -1
    je invalid
    jl invalid
    cmp y, 9
    je invalid
    jg invalid

    mov ecx, OFFSET tiles
    mov eax, 8
    mul y
    add eax, x
    add ecx, eax
    cmp BYTE PTR [ecx], 32 ; space in ASCII is 32
    jne invalid
    
    mov eax, 0 ; reset value of eax
    mov eax, 1
    ret
    invalid:
        mov eax, 0
        ret
IsValid ENDP

CheckSpot PROC x: BYTE, y: BYTE
    Invoke IsValid, x, y
    cmp eax, 0
    je spotInvalid
    
    Invoke MovePiece, x, y, '*'
    ret
    spotInvalid:
        ret
        
CheckSpot ENDP

CalcValidMoves PROC x: DWORD, y: DWORD
 ; X+2	Y+1
 ; X+2	Y-1
 ; X+1	Y-2
 ; X-1	Y-2
 ; X-2	Y-1
 ; X-2	Y+1
 ; X-1	Y+2
 ; X+1	Y+2
    
    Invoke CheckSpot, x+2, y+1
    ret
CalcValidMoves ENDP
  Start:
  main PROC
    Invoke MovePiece, 5, 4, 'T'
    Invoke CalcValidMoves

    ;Call DrawBoard
    inkey

 INVOKE ExitProcess, 0
  main ENDP
END main 