.model small 
.stack
.data
.code

Mov ax, @data 
Mov ds, ax
mov cx, 0000h 
Mov cl, 05h
Mov al, 00h 
Mov bl, 01h
Mov si, 0000h ;store the first value 0 in 0000h f(0) = 0 
Mov [si], al
Inc si
Mov [si], bl ;store the second value 1 in 0001h f(1) = 1

Up: add al, bl ;add the two values f(n) = f(n-2) + f(n-1) for n>1 Inc si
Mov [si], al ;store the third value in memory
Xchg al, bl ; exchange the values for adding to generate series Loop up
Int 21h 
End