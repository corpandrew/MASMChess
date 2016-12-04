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

    ;mov esi, 1; column index
    mov ebx, 1
    
    DrawCoordsLoop:
	   mov esi, 0
	   push ecx
	   push eax
         Invoke SetTextColor, lightGray, black
		 pop eax
         Call WriteChar
		push eax
        InnerLoop:
		Invoke GetColor, ebx

            push ebx
    
            mov ebx, 15
            sub ebx, eax
		Invoke SetTextColor, ebx, eax
            pop ebx
		mov eax, ' '
		Call WriteChar
			
            inc esi
            inc ebx
            cmp esi, 8
            jne InnerLoop
        
        Call Crlf; tentative
        
	  pop eax
	  pop ecx
       
        dec eax
        inc ebx
        dec ecx
        cmp ecx, 0
        jne DrawCoordsLoop
		
    ret
    
  DrawBoard ENDP

  Start:
  main PROC
    Call DrawBoard
    inkey

 INVOKE ExitProcess, 0
  main ENDP
END main 