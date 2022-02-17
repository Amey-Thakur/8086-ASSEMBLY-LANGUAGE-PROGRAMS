ORG 100H

CALL M1

MOV AX,2

RET         ;return to operating system

M1 PROC
MOV BX,5
RET         ;return to caller
M1 ENDP

END