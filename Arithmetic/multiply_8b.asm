data segment
    var1 db 0EDH
    var2 db 99H
    res dw ?
data ends          

assume cs:code,ds:data

code segment
    start: mov ax,data
           mov ds,ax
           
           mov al,var1
           mov bl,var2
           mul bl
           mov res,ax
           mov ah,4ch
           int 21h
           code ends
end start