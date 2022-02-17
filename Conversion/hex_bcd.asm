;ALP for conversion of 16-bit HEX number into its equivalent BCD number.


DATA SEGMENT
    HEX DW 0FFFFH
    BCD DW 5 DUP(0)
DATA ENDS   

ASSUME CS:CODE,DS:DATA  

CODE SEGMENT 
    
START: MOV AX,DATA        ;intialize data
       MOV DS,AX
       
       LEA SI,BCD
       MOV AX,HEX
       
       MOV CX,2710H
       CALL SUB1
       
       MOV CX,03E8H
       CALL SUB1
       
       MOV CX,0064H
       CALL SUB1
       
       MOV CX,000AH
       CALL SUB1
       
       MOV [SI],AL
       
       MOV AH,4CH
       INT 21H

  SUB1 PROC NEAR
       MOV BH,0FFH
   X1: INC BH
       SUB AX,CX
       JNC X1
       ADD AX,CX
       MOV [SI] ,BH
       INC SI
       RET
       SUB1 ENDP

CODE ENDS
END START
