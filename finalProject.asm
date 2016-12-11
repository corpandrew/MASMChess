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
      
      buffer db 4 DUP(0)
      target Byte 2 DUP(0)
      inputX Byte ?
      inputY Byte ?
      piece Byte ?
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

            cmp BYTE PTR [ebx], 42 ; star in ASCII is 42
            jne normalPrint
            push ecx
            Invoke SetTextColor, white, green ; make space green
            pop ecx
            mov eax, ' '
            
            normalPrint:
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

    mov ecx, 8 ; loop count
    mov bl, 97 ; ascii val of char to write

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
ret
    
  DrawBoard ENDP

GetInput PROC
    ; Receives: offset of buffer in edx
    ; Received: length of buffer in ecx
    
    mWrite "Please enter in a piece (P/R/B/Q/N) and a coodinate point using a-h for x and 1-8 for y (ex: Pa3): "
    
    call ReadString
    mov bytecount, ax
    
    ;Invoke Read, 0
    ;Invoke Read, 1
    
    mov al, buffer[0]
    cmp al, 'P'
    je validpiece
    cmp al, 'R'
    je validpiece
    cmp al, 'B'
    je validpiece
    cmp al, 'Q'
    je validpiece
    cmp al, 'N'
    je validpiece

    mWriteLn "The piece you speicified is invalid! Please reenter a valid string: "
    Call GetInput
    ret

    validpiece:
    mov piece, al


    mov al, buffer[1]
    sub al, 'a'
    add al, 1
    
    cmp al, 1 ; if less than 1, its invalid
    jl OutOfBounds
    cmp al, 8
    jg OutOfBounds
    
    mov inputX, al
    mov al, buffer[2]
    sub al, 30h

    cmp al, 1 ; if less than 1, its invalid
    jl OutOfBounds
    cmp al, 8
    jg OutOfBounds
    
    mov inputY, al


    cmp inputX, 5
    je KingXEqual
    jmp Done

    KingXEqual:
        cmp inputY, 4
        je KingSpace
        jmp Done

    OutOfBounds:
        mWriteLn "Invalid input! Please reenter a valid coordinate: "
        Call GetInput
	  ret
    KingSpace: ; Need to do this, but almost there
        mWriteLn "The King is on this space; you are not allowed to move your piece here. Please reenter a valid coordinate: "
        Call GetInput
	  ret
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

IsValid PROC x: BYTE, y: BYTE
    sub x, 1

    cmp x, -1
    je invalid
    jl invalid
    cmp x, 8
    je invalid
    jg invalid

    cmp y, -1
    je invalid
    jl invalid
    cmp y, 9
    je invalid
    jg invalid

    mov ecx, OFFSET tiles
    ; x + (8 * y)
    mov eax, 0
    mov al, 8
    mov bl, 8
    sub bl, y
    mul bl
    add al, x
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
    mov eax, 1
    ret
    spotInvalid:
        mov eax, 0
        ret
        
CheckSpot ENDP

CheckLine PROC startX: BYTE, startY: BYTE, addx: BYTE, yadd: BYTE
    mov ecx, 8
    mov ebx, 0
    mov edx, 0
    mov bh, addx
    mov dh, yadd
    LineLoop:
        add startX, bh
        add startY, dh
        push ebx
        push edx
        Invoke CheckSpot, startX, startY
        pop edx
        pop ebx
        cmp eax, 0
        je endloop
        Loop LineLoop
        
    endloop:
       ret
        
CheckLine ENDP 

CalcValidMovesKnight PROC x: BYTE, y: BYTE
    ; X+2 Y+1
    add x, 2
    add y, 1
    Invoke CheckSpot, x, y

    ; X+2 Y-1
    sub y, 2 ; Y + 1 -> Y - 1
    Invoke CheckSpot, x, y

    ; X+1 Y-2
    sub x, 1 ; X + 2 -> X + 1
    sub y, 1 ; Y - 1 -> Y - 2
    Invoke CheckSpot, x, y

    ; X-1 Y-2
    sub x, 2 ; X + 1 -> X - 1
    Invoke CheckSpot, x, y

    ; X-2 Y-1
    sub x, 1 ; X - 1 -> X - 2
    add y, 1 ; Y - 2 -> Y - 1
    Invoke CheckSpot, x, y

    ; X-2 Y+1
    add y, 2 ; Y - 1 -> Y + 1
    Invoke CheckSpot, x, y

    ; X-1 Y+2
    add x, 1 ; X - 2 -> X - 1
    add y, 1 ; Y + 1 -> Y + 2
    Invoke CheckSpot, x, y

    ; X+1 Y+2
    add x, 2 ; X - 1 -> X + 1
    Invoke CheckSpot, x, y

    ; X+0 Y+0
    sub x, 1 ; X + 1 -> X
    sub y, 2 ; Y + 2 -> Y

    ret
CalcValidMovesKnight ENDP

CalcValidMovesQueen PROC x: BYTE, y: BYTE
    Invoke CheckLine, x, y, 1, 0
    Invoke CheckLine, x, y, -1, 0
    Invoke CheckLine, x, y, 0, -1
    Invoke CheckLine, x, y, 1, 1
    Invoke CheckLine, x, y, -1, 1
    Invoke CheckLine, x, y, 1, -1
    Invoke CheckLine, x, y, -1, -1
    ret
CalcValidMovesQueen ENDP

CalcValidMovesBishop PROC x: BYTE, y: BYTE
    Invoke CheckLine, x, y, 1, 1
    Invoke CheckLine, x, y, 1, -1
    Invoke CheckLine, x, y, -1, -1
    Invoke CheckLine, x, y, -1, 1
    ret
CalcValidMovesBishop ENDP

CalcValidMovesRook PROC x: BYTE, y: BYTE
    Invoke CheckLine, x, y, -1, 0
    Invoke CheckLine, x, y, 0, -1
    Invoke CheckLine, x, y, 1, 0
    Invoke CheckLine, x, y, 0, 1
    ret
CalcValidMovesRook ENDP

CalcValidMovesPawn PROC x: BYTE, y: BYTE

    cmp y, 2
    je Move2

    ;cmp y, 8
    ;je MoveDown
    
    add y, 1
    Invoke CheckSpot, x, y
    ret
    
    Move2:
        add y, 1
        Invoke CheckSpot, x, y
        add y, 1
        Invoke CheckSpot, x, y
        ret    
CalcValidMovesPawn ENDP

ResetTiles PROC; this resets all the pieces on the board to default. Including King
    mov ecx, 63
    mov esi, 0

    ResetToSpaceLoop:
        mov tiles[esi], ' '
        inc esi
    Loop ResetToSpaceLoop

    Invoke MovePiece, 5, 4, 'K'

    ret
  ResetTiles ENDP

  Start:
  main PROC
    Invoke MovePiece, 5, 4, 'K'
    ; This is for putting the king in the right space.
    Continue:
        mov edx, offset buffer
        mov ecx, SIZEOF buffer
        Call GetInput

        cmp piece, 'P'
        je pawn
        cmp piece, 'R'
        je rook
        cmp piece, 'B'
        je bishop
        cmp piece, 'Q'
        je queen
        cmp piece, 'N'
        je knight


        pawn:
            Invoke MovePiece, inputX, inputY, 'P'
            Invoke CalcValidMovesPawn, inputX, inputY
            jmp draw
        rook:
            Invoke MovePiece, inputX, inputY, 'R'
            Invoke CalcValidMovesRook, inputX, inputY
            jmp draw
        bishop:
            Invoke MovePiece, inputX, inputY, 'B'
            Invoke CalcValidMovesBishop, inputX, inputY
            jmp draw
        queen:
            Invoke MovePiece, inputX, inputY, 'Q'
            Invoke CalcValidMovesQueen, inputX, inputY
            jmp draw
        knight:
            Invoke MovePiece, inputX, inputY, 'N'
            Invoke CalcValidMovesKnight, inputX, inputY
            jmp draw

        draw:
            Call DrawBoard
            Call ResetTiles
            jmp Continue
        
    inkey

 INVOKE ExitProcess, 0
  main ENDP
END main 