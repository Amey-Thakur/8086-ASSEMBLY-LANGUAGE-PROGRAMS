data segment
	num1 dw 12345
	num2 dw ?
	arry db 10 dup (0)
	temp dw ?
	msg1 db 10,13,'stored number in memory is : $'
	msg2 db 10,13,'reverse number is : $'
	res db 10 dup ('$')
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
		mov ax,num1
		lea si,res
		call hex2dec
		lea dx,res
		mov ah,9
		int 21h
		lea si,arry
		mov ax,num1
	reve:
		mov dx,0
		mov bx,10
		div bx
		mov arry[si],dl
		mov temp,ax
		mov ax,dx
		inc si
		mov ax,temp
		cmp temp,0
		jg reve
		lea di,arry
	last:
		inc di
		cmp arry[di],0
		jg last
		dec di
		mov al,arry[di]
		mov ah,0
		mov num2,ax
		mov cx,10
	conv:
		dec di
		mov al,arry[di]
		mov ah,0
		mul cx
		add num2,ax
		mov ax,cx
		mov bx,10
		mul bx
		mov cx,ax
		cmp arry[di],0
		jg conv
		display msg2
		mov ax,num2
		lea si,res
		call hex2dec
		lea dx,res
		mov ah,9
		int 21h
		mov ah,4ch
		int 21h
		code ends
		hex2dec proc near
		mov cx,0
		mov bx,10
	loop1: 
		mov dx,0
		div bx
		add dl,30h
		push dx
		inc cx
		cmp ax,9
		jg loop1
		add al,30h
		mov [si],al
	loop2: 
		pop ax
		inc si
		mov [si],al
		loop loop2
		ret
		hex2dec endp
end start