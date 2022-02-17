;An Assembly program in which a procedure converts Hexadecimal value to print its Decimal form ;on Screen
DATA SEGMENT
     NUM DW 1234H
     RES  DB 10 DUP ('$')
DATA ENDS
CODE SEGMENT
        ASSUME DS:DATA,CS:CODE
START:       
    MOV AX,DATA
    MOV DS,AX
   
    MOV AX,NUM
      
    LEA SI,RES
    CALL HEX2DEC
   
    LEA DX,RES
    MOV AH,9
    INT 21H 
            
    MOV AH,4CH
    INT 21H        
CODE ENDS
HEX2DEC PROC NEAR
    MOV CX,0
    MOV BX,10
   
LOOP1: MOV DX,0
       DIV BX
       ADD DL,30H
       PUSH DX
       INC CX
       CMP AX,9
       JG LOOP1
     
       ADD AL,30H
       MOV [SI],AL
     
LOOP2: POP AX
       INC SI
       MOV [SI],AL
       LOOP LOOP2
       RET
HEX2DEC ENDP           
   
END START
