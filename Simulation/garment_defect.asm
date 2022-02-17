;Design and Emulate a smart automation system for a garment manufacturing unit with
;the following requirements:-
; To detect all possible defects.
; To remove the defective pieces.
; To provide comprehensive inventory report.

data segment
    num1 db ?
    num2 db ?
    line DB 1h,2h,3h,4h,5h,6h,7h,8h,9h,0h;
    MSG1 DB 10,13,"Threshold 1: $"
    MSG2 DB 10,13,"Threshold 2: $"
    MSG3 DB 10,13,"Defect detected $"
    MSG4 DB 10,13,"Defect removed $"
    MSG5 DB 10,13,"Good clothes: $"
    MSG6 DB 10,13,"Bad clothes: $" 
    good db ?
    bad db ?
data ends
 
code segment
assume cs:code, ds:data
start: mov ax, data
       mov ds, ax         
       mov cx, 0bh         ;set up loop counter
       
       mov good,0Ah
       mov bad,0000H

       lea dx,msg1         ;load and display message 1
       mov ah,9h
       int 21h
       
       mov ah,1h           ;read character from console
       int 21h
       sub al,30h          ;convert from ASCII to BCD
       mov num1,al         ;store number as num1

       lea dx,msg2         ;load and display message 2
       mov ah,9h            
       int 21h
       
       mov ah,1h           ;read character from console
       int 21h
       sub al,30h          ;convert from ASCII to BCD
       mov num2,al         ;store number as num2

up:    mov al,byte ptr[SI] ;compare next
       cmp al,num1
       jl dft
       cmp al,num2          
       jl dft
       jmp nxt
       
dft:   lea dx,msg3         ;load and display message 3
       mov ah,9h
       int 21h
       
       mov [si],0000H      ;remove defect
       inc bad
       
       lea dx,msg4         ;load and display message 4
       mov ah,9h
       int 21h
       
       jmp nxt 
       
nxt:   inc si              ;point to next grade
       dec cx
       jnz up
       
       lea dx,msg5         ;load and display message 5
       mov ah,9h
       int 21h
              
       xor ax,ax
       mov al,bad
       sub good,al
       add good,30h        ;ASCII adjust before displaying
       mov dl,good
       mov ah,2h           ;display it
       int 21h
       
       lea dx,msg6         ;load and display message 6
       mov ah,9h
       int 21h
       
       add bad,30h         ;ASCII adjust before displaying
       mov dl,bad
       mov ah,2h           ;display it
       int 21h
       
       hlt
       
code ends
end start