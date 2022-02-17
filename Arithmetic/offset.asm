org 100h

mov al,var1         ;check value of var1 by moving it to al

mov bx,offset var1  ;get address of var1 in bx

mov b.[bx],44h      ;modify the contents of var1

mov al,var1         ;check value of var1 by moving it to al

ret

var1 db 22h

end