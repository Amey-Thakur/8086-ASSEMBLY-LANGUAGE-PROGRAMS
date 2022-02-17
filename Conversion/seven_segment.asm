;ALP for conversion BCD number 7-Segment


DATA SEGMENT
    TABLE DB 7EH, 30H, 60H, 79H, 33H, 5BH, 5FH, 70H, 7FH, 73H         ; look up table for translating
    A DB 09H,01H,06H                                                  ; 7 - segment numbers to be translated
    B DB ?
DATA ENDS

CODE SEGMENT

ASSUME CS:CODE,DS:DATA
    START: MOV AX,DATA
           MOV DS,AX
           MOV ES,AX
           LEA BX,TABLE    ; load address of look up table into bx
           LEA SI,A
           LEA DI,B
           MOV CX,03H      ; 3 numbers to be translated
           CLD

       X1: MOV AL,[SI]     ; load string into AL register
           CMP AL,09H
           JA X2           ; exit if number is over 9 
                           
           XLAT                                    
           MOV [DI],AX     ; stores string into B
           INC DI
           INC SI
           LOOP X1
       
       X2: MOV AH,4CH
           INT 21H
CODE ENDS
END START