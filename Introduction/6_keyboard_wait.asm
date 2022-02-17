org 100h

main proc near
    mov ah,0h
    int 16h
    
    mov ax,4c00h
    int 21h
endp
end main

ret