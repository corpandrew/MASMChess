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
      target Byte 2 DUP(0)
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
    ;Call Clrscr
    Call Crlf
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

    Invoke SetTextColor, lightGray, black ; set the number text to be the correct color
    ret
    
  DrawBoard ENDP

GetInput PROC
    ; Receives: offset of buffer in edx
    ; Received: length of buffer in ecx
    
    mWrite "Please enter in a coodinate point using a-h for x and 1-8 for y: "
    
    call ReadString
    mov bytecount, ax
    
    ;Invoke Read, 0
    ;Invoke Read, 1

    mov al, buffer[0]
    sub al, 'a'
    add al, 1
    
    cmp al, 1 ; if less than 1, its invalid
    jl OutOfBounds
    cmp al, 8
    jg OutOfBounds
    
    mov inputX, al
	
    mov al, buffer[1]
    sub al, 30h

    cmp al, 1 ; if less than 1, its invalid
    jl OutOfBounds
    cmp al, 8
    jg OutOfBounds
    
    mov inputY, al

    cmp inputX, 5
    je KingXEqual

    KingXEqual:
        cmp inputY, 4
        je KingSpace
    jmp Done

    OutOfBounds:
        mWriteLn "Invalid Input, Try Again!"
        inkey
        ; Thought this would work, go back over this. Call GetInput
        Invoke ExitProcess, 0
    KingSpace: ; Need to do this, but almost there
        mWriteLn "The King is on this space, cant move to this one. Try Again!"
        inkey
        ; Thought this would work, go back over this. Call GetInput
        Invoke ExitProcess, 0
    Done:
        ret
    
GetInput ENDP

MovePiece PROC, x: Byte, y: Byte, char: Byte
    mov bh, char
    mov ecx, OFFSET tiles

    mov eax, 0
    sub x, 1
    mov al, 8
    mov bl, 8
    sub bl, y
    mul bl
    add al, x
    add ecx, eax
    mov [ecx], bh
    ret
MovePiece ENDP

ResetTiles PROC; this resets all the pieces on the board to default. Including King
    mov ecx, 63
    mov esi, 0

    ResetToSpaceLoop:
        mov tiles[esi], ' '
        inc esi
    Loop ResetToSpaceLoop

    Invoke MovePiece, 5, 4, 'T'

    ret
  ResetTiles ENDP

  Start:
  main PROC
    Invoke MovePiece, 5, 4, 'T'
    ; This is for putting the king in the right space.
    Continue:
        mov edx, offset buffer
        mov ecx, SIZEOF buffer
        Call GetInput
        Invoke MovePiece, inputX, inputY, 'K'
        Call DrawBoard
        Call ResetTiles
        jmp Continue
        
    inkey

 INVOKE ExitProcess, 0
  main ENDP
END main 