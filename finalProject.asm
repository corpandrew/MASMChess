INCLUDE \masm32\include\masm32rt.inc  ; for using inkey
INCLUDE \masm32\include\Irvine32.inc
INCLUDE \masm32\include\textcolors.asm
INCLUDE \masm32\include\Macros.inc
INCLUDELIB \masm32\lib\Irvine32.lib

.486
.STACK 1000h

ExitProcess PROTO, DwErrorCode:DWORD

.DATA
	
	tiles Byte 64 DUP ('K'); this is the 'piece' that is on the tile
                             ; defaults to have a space on it.
	
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

  Start:
  main PROC
    Call DrawBoard
    inkey

 INVOKE ExitProcess, 0
  main ENDP
END main 