;multiply two 16-bit unsigned numbers stored at Memory locations 45,000H and
;45,002H. Store the result at 45,004H and 45,006H

CODE SEGMENT
    assume cs:code
    
    mov ax,4000H
    mov ds,ax
    
    mov ax,[5000H]
    mov bx,[5002H]
    
    mul bx          ;multiplies ax with bx
    
    mov [5004H],ax  ;stores result in ax and dx
    mov [5006H],dx
    
    hlt
CODE ENDS