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
      buffer db 5 DUP(?)
      target db 5 DUP(?)
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

    mWrite "Please enter in a coodinate point using a-h for x and 1-8 for y: "
    mov edx, offset buffer
    mov ecx, SIZEOF buffer
    call ReadString
    mov bytecount, ax
    
    call ReadFirst
    call ReadSecond

mov esi, 0
mov al, target[esi]
mov inputX, al
inc esi
mov al, target[esi]
sub al, 48
mov inputY, al
    
GetInput ENDP


ReadFirst proc
	mov edi, 0
	mov esi, 0
	mov bl, buffer[esi]
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
		mov target[edi], al
		jmp done
	two:
		mov al, 2
		mov target[edi], al
		jmp done
	three:
		mov al, 3
		mov target[edi], al
		jmp done
	four:
		mov al, 4
		mov target[edi], al
		jmp done
	five:
		mov al, 5
		mov target[edi], al
		jmp done
	six:
		mov al, 6
		mov target[edi], al
		jmp done
	seven:
		mov al, 7
		mov target[edi], al
		jmp done
	eight:
		mov al, 8
		mov target[edi], al
		jmp done
	zero:
		mov al, 0
		mov target[edi], al
		jmp done
	done:
		ret

ReadFirst ENDP

ReadSecond proc
    mov esi, 0
    inc esi
    mov bl, 0
    mov bl, buffer[esi]
    mov target[esi], bl
    
    ret

ReadSecond ENDP

MovePiece PROC, x: DWORD, y: DWORD, char: Byte
    mov bh, char
    mov ecx, OFFSET tiles

    sub x, 1

    mov eax, 0
    mov eax, 8
    mul y
    add eax, x
    add ecx, eax
    call DumpRegs
    mov [ecx], bh
    ret
MovePiece ENDP

  Start:
  main PROC
    Invoke MovePiece, 5, 4, 'T'
    ; This is for putting the king in the right space.
    Call GetInput
    mov al, inputY
    CALL WriteInt
    Invoke MovePiece, inputX, al, 'K'
    ;Call DrawBoard
    inkey

 INVOKE ExitProcess, 0
  main ENDP
END main 