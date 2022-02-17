;program to create a simple multiplication procedure
org 100h

mov al,1h
mov bl,2h

call m2
call m2
call m2
call m2

ret         ;return to the operating system

m2 proc
mul bl      ;ax = al*bl
ret         ;return to caller
m2 endp

end