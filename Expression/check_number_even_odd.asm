; check whether a number is even or odd
data segment
msg1 db 10,13,'enter number here :- $'
msg2 db 10,13,'entered value is even$'
msg3 db 10,13,'entered value is odd$'
data ends
display macro msg
mov ah,9
lea dx,msg
int 21h
endm
code segment
assume cs:code,ds:data
start:
mov ax,data
mov ds,ax
display msg1
mov ah,1
int 21h
mov ah,0
check: mov dl,2
div dl
cmp ah,0
jne odd
even:
display msg2
jmp done
odd:
display msg3
done:
mov ah,4ch
int 21h
code ends
end start