;linear search
.8086
.stack 100h

.data
a db 01h ,02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h, 10h
element db 05h ;element to be searched in the array a

.code
            mov cx,10
            lea bx,a
            mov si,0
            mov dx,0
label1:     mov al,[bx+si]
            cmp al,element 
            je equal
            inc si
            loop label1

not_equal:  mov dl,00h 
            jmp exit

equal:      mov dl,0ffh 

exit:       end