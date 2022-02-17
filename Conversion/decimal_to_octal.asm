;Code for Program to Convert Decimal number to Octal number in Assembly Language
prnstr macro msg
        mov ah, 09h
        lea dx, msg
        int 21h
        endm

data segment
        buf1 db "Enter a decimal number : $"
        buf2 db 0ah, "Invalid Decimal Number...$"
        buf3 db 0ah, "Equivalent octal number is : $"
        buf4 db 6
             db 0
             db 6 dup(0)
        multiplier db 0ah
data ends

code segment
        assume cs:code, ds:data
start :
        mov ax, data
        mov ds, ax
        mov es, ax

        prnstr buf1

        mov ah, 0ah
        lea dx, buf4
        int 21h

        mov si, offset buf4 + 2
        mov cl, byte ptr [si-1]
        mov ch, 00h
subtract :
        mov al, byte ptr [si]
        cmp al, 30h
        jnb cont1
        prnstr buf2
        jmp stop
cont1 :
        cmp al, 3ah
        jb cont2
        prnstr buf2
        jmp stop
cont2 :
        sub al, 30h
        mov byte ptr [si], al

        inc si
        loop subtract

        mov si, offset buf4 + 2
        mov cl, byte ptr [si-1]
        mov ch, 00h
        mov ax, 0000h
calc :
        mul multiplier
        mov bl, byte ptr [si]
        mov bh, 00h
        add ax, bx
        inc si
        loop calc

        mov si, offset buf4 + 2
        mov bx, ax
        mov dx, 0000h
        mov ax, 8000h
convert :
        mov cx, 0000h
conv :
        cmp bx, ax
        jb cont3
        sub bx, ax
        inc cx
        jmp conv
cont3 :
        add cl, 30h
        mov byte ptr [si], cl
        inc si
        mov cx, 0008h
        div cx
        cmp ax, 0000h
        jnz convert

        mov byte ptr [si], '$'
        prnstr buf3
        prnstr buf4+2
stop :
        mov ax, 4c00h
        int 21h
code ends
        end star
