;ALP for conversion of 16-bit BCD number into its equivalent HEX number.


DATA SEGMENT
    BCD DB 06H,05H,05H,03H,05H
    HEX DW ?
DATA ENDS

ASSUME CS:CODE,DS:DATA

CODE SEGMENT
START: MOV AX,DATA
       MOV DS,AX
       MOV CL,05H
       MOV BP,000AH
       MOV AX,2710H
       PUSH AX
       MOV DI,0000H
       MOV SI, OFFSET BCD
       
X:     MOV BL,[SI]
       MUL BX
       ADD DI,AX
       POP AX
       DIV BP
       PUSH AX
       INC SI
       LOOP X
       MOV HEX,DI
       
       MOV AH,4CH
       INT 21H
CODE ENDS
END START