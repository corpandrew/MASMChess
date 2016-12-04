INCLUDE \masm32\include\masm32rt.inc  ; for using inkey
INCLUDE \masm32\include\Irvine32.inc
INCLUDE \masm32\include\textcolors.asm
INCLUDE \masm32\include\Macros.inc
INCLUDELIB \masm32\lib\Irvine32.lib

.486
.STACK 1000h

ExitProcess PROTO, DwErrorCode:DWORD

.DATA
	Tile STRUCT
		X WORD ?
		Y WORD ?
		bgColor Byte ?; background color of the tile
		piece Byte ' '; if no piece then its nothing, else its a letter
	Tile ENDS
	
	tiles Tile 64 DUP (<>)

	
.CODE

  GetColor PROC, rowIndex: DWORD, colIndex: DWORD
    mov eax, rowIndex
    add eax, colIndex

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
        ret
    
  GetColor ENDP

  DrawBoard PROC
  
    mov bl, 65; ascii val of char to write
    mov ecx, 8; loop count

    mov al, ' '
    Call WriteChar
    
    DrawLettersLoop:

        mov al, bl; put the char into al example:('A')
        Call WriteChar; write the letter
        inc bl
        
        dec ecx
        cmp ecx, 0
        jne DrawLettersLoop
        
    Call Crlf

    mov eax, 56; current line number to write
    mov ecx, 8

    mov esi, 1; current index from left to right on line
    
    DrawCoordsLoop:
    
        Call WriteChar
		push eax
		push ecx
        InnerLoop:
			Invoke GetColor, ecx, esi
			Invoke SetTextColor, black, eax
			
			mov eax, ' '
			Call WriteChar
			
            inc esi
            cmp esi, 8
            jne InnerLoop
        
        Call Crlf; tentative
        
		pop eax
        dec eax

		pop ecx
        dec ecx
        cmp ecx, 0
        jne DrawCoordsLoop
		
    ret
    
  DrawBoard ENDP

  Start:
  main PROC
     INVOKE SetTextColor, black, white
     ;mov eax, 'H'
    ; CALL WriteChar
    Call DrawBoard
    ;mov eax, 231
    ;Call WriteInt
    
    ;mov eax, white + (blue * 16)
    ;Call SetTextColor
    
    ;mov eax, 231
    ;Call WriteInt

    inkey
   INVOKE ExitProcess, 0
  main ENDP
END main 