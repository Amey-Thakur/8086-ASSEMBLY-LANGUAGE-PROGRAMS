.data
    arr DB 50,51,52,53,54,55,56,57,48

.code
Main Proc
    mov cx, 9
    lea si, arr

l1:
    mov dl, [si]
    mov ah, 2
    int 21h
    inc si
    loop l1