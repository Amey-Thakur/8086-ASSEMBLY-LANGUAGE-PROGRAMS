ORG 100H

MOV AL,1
MOV BL,2

CALL M2
CALL M2
CALL M2
CALL M2

RET             ;return to operating system

M2 PROC
    MUL BL      ;AX = AL*BL
    RET
M2 ENDP

END