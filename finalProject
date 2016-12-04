INCLUDE \masm32\include\masm32rt.inc  ; for using inkey
INCLUDE \masm32\include\Irvine32.inc
INCLUDE \masm32\include\Macros.inc
INCLUDELIB \masm32\lib\Irvine32.lib

.486
.STACK 1000h

ExitProcess PROTO, DwErrorCode:DWORD

.DATA
 Table WORD 8 DUP (8 DUP (?))
    Board STRUCT
        ;coords COORD 8 DUP (8 DUP (COORD <>)); doesnt currently work
        bgColor Byte ?; background color of coord on oard
    Board ENDS
    
.CODE

SetColor PROC, forecolor:dword, backcolor:dword
    
	mov     eax, backcolor
	shl     eax, 4
	add     eax, forecolor
	call    SetTextColor

    ret
    
SetColor ENDP 

WriteColorChar PROC, char:dword, forecolor:dword, backcolor:dword
    
    invoke  SetColor, forecolor, backcolor
    mov     eax, char
    invoke  WriteChar
    ret
    
WriteColorChar endp


  ;GetColor puts the color into eax, 0=black, 15=white
  GetColor PROC, index: DWORD
    mov ebx, 2
    mov eax, index
    xor edx, edx
        
    div ebx

    cmp edx, 0
    je SetBlack
    jne SetWhite

    SetBlack:
        mov eax, black+(black*16)
        jmp Return
    SetWhite:
        mov eax, white+(white*16)
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

        InnerLoop:
            Invoke WriteColorChar, ' ', 3, 15
            
            inc esi
            cmp esi, 8
            jmp InnerLoop
        
        Call Crlf; tentative
        
        dec eax

        dec ecx
        cmp ecx, 0
        jne DrawCoordsLoop
    ret
    
  DrawBoard ENDP

  Start:
  main PROC
    ;Call DrawBoard
    mov eax, 231
    Call WriteInt
    
    mov eax, white + (blue * 16)
    Call SetTextColor
    
    mov eax, 231
    Call WriteInt

    inkey
   INVOKE ExitProcess, 0
  main ENDP
END main 