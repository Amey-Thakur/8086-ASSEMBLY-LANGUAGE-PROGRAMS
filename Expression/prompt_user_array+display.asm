 ;Code for Program that prompts the user to enter an array of size 10 and display it in Assembly Language
 .MODEL SMALL
 .STACK 100H

 .DATA
    PROMPT_1  DB  'Enter the Array elements :',0DH,0AH,'$'
    PROMPT_2  DB  'The Array elements are : $'

    ARRAY   DW  10 DUP(0)                      

 .CODE
   MAIN PROC
     MOV AX, @DATA                ; initialize DS
     MOV DS, AX

     MOV BX, 10                   ; set BX=10

     LEA DX, PROMPT_1             ; load and display the string PROMPT_1
     MOV AH, 9     
     INT 21H

     LEA SI, ARRAY                ; set SI=offset address of ARRAY

     CALL READ_ARRAY              ; call the procedure READ_ARRAY

     LEA DX, PROMPT_2             ; load and display the string PROMPT_2
     MOV AH, 9                    
     INT 21H
 
     LEA SI, ARRAY                ; set SI=offset address of ARRAY

     CALL PRINT_ARRAY             ; call the procedure PRINT_ARRAY

     MOV AH, 4CH                  ; return control to DOS
     INT 21H
   MAIN ENDP

 ;**************************************************************************;
 ;**************************************************************************;
 ;-------------------------  Procedure Definitions  ------------------------;
 ;**************************************************************************;
 ;**************************************************************************;

 ;**************************************************************************;
 ;-----------------------------  READ_ARRAY  -------------------------------;
 ;**************************************************************************;

 READ_ARRAY PROC
   ; this procedure will read the elements for an array
   ; input : SI=offset address of the array
   ;       : BX=size of the array
   ; output : none

   PUSH AX                        ; push AX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK

   MOV CX, BX                     ; set CX=BX

   @READ_ARRAY:                   ; loop label
     CALL INDEC                   ; call the procedure INDEC

     MOV [SI], AX                 ; set [SI]=AX
     ADD SI, 2                    ; set SI=SI+2

     MOV DL, 0AH                  ; line feed
     MOV AH, 2                    ; set output function
     INT 21H                      ; print a character
   LOOP @READ_ARRAY               ; jump to label @READ_ARRAY while CX!=0

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP AX                         ; pop a value from STACK into AX

   RET                            ; return control to the calling procedure
 READ_ARRAY ENDP

 ;**************************************************************************;
 ;-----------------------------  PRINT_ARRAY  ------------------------------;
 ;**************************************************************************;

 PRINT_ARRAY PROC
   ; this procedure will print the elements of a given array
   ; input : SI=offset address of the array
   ;       : BX=size of the array
   ; output : none

   PUSH AX                        ; push AX onto the STACK   
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK

   MOV CX, BX                     ; set CX=BX

   @PRINT_ARRAY:                  ; loop label
     MOV AX, [SI]                 ; set AX=AX+[SI]

     CALL OUTDEC                  ; call the procedure OUTDEC

     MOV AH, 2                    ; set output function
     MOV DL, 20H                  ; set DL=20H
     INT 21H                      ; print a character

     ADD SI, 2                    ; set SI=SI+2
   LOOP @PRINT_ARRAY              ; jump to label @PRINT_ARRAY while CX!=0

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP AX                         ; pop a value from STACK into AX

   RET                            ; return control to the calling procedure
 PRINT_ARRAY ENDP

 ;**************************************************************************;
 ;-------------------------------  INDEC  ----------------------------------;
 ;**************************************************************************;

 INDEC PROC
   ; this procedure will read a number indecimal form    
   ; input : none
   ; output : store binary number in AX

   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK

   JMP @READ                      ; jump to label @READ

   @SKIP_BACKSPACE:               ; jump label
   MOV AH, 2                      ; set output function
   MOV DL, 20H                    ; set DL=' '
   INT 21H                        ; print a character

   @READ:                         ; jump label
   XOR BX, BX                     ; clear BX
   XOR CX, CX                     ; clear CX
   XOR DX, DX                     ; clear DX

   MOV AH, 1                      ; set input function
   INT 21H                        ; read a character

   CMP AL, "-"                    ; compare AL with "-"
   JE @MINUS                      ; jump to label @MINUS if AL="-"

   CMP AL, "+"                    ; compare AL with "+"
   JE @PLUS                       ; jump to label @PLUS if AL="+"

   JMP @SKIP_INPUT                ; jump to label @SKIP_INPUT

   @MINUS:                        ; jump label
   MOV CH, 1                      ; set CH=1
   INC CL                         ; set CL=CL+1
   JMP @INPUT                     ; jump to label @INPUT
   
   @PLUS:                         ; jump label
   MOV CH, 2                      ; set CH=2
   INC CL                         ; set CL=CL+1

   @INPUT:                        ; jump label
     MOV AH, 1                    ; set input function
     INT 21H                      ; read a character

     @SKIP_INPUT:                 ; jump label

     CMP AL, 0DH                  ; compare AL with CR
     JE @END_INPUT                ; jump to label @END_INPUT

     CMP AL, 8H                   ; compare AL with 8H
     JNE @NOT_BACKSPACE           ; jump to label @NOT_BACKSPACE if AL!=8

     CMP CH, 0                    ; compare CH with 0
     JNE @CHECK_REMOVE_MINUS      ; jump to label @CHECK_REMOVE_MINUS if CH!=0

     CMP CL, 0                    ; compare CL with 0
     JE @SKIP_BACKSPACE           ; jump to label @SKIP_BACKSPACE if CL=0
     JMP @MOVE_BACK               ; jump to label @MOVE_BACK

     @CHECK_REMOVE_MINUS:         ; jump label

     CMP CH, 1                    ; compare CH with 1
     JNE @CHECK_REMOVE_PLUS       ; jump to label @CHECK_REMOVE_PLUS if CH!=1

     CMP CL, 1                    ; compare CL with 1
     JE @REMOVE_PLUS_MINUS        ; jump to label @REMOVE_PLUS_MINUS if CL=1

     @CHECK_REMOVE_PLUS:          ; jump label

     CMP CL, 1                    ; compare CL with 1
     JE @REMOVE_PLUS_MINUS        ; jump to label @REMOVE_PLUS_MINUS if CL=1
     JMP @MOVE_BACK               ; jump to label @MOVE_BACK

     @REMOVE_PLUS_MINUS:          ; jump label
       MOV AH, 2                  ; set output function
       MOV DL, 20H                ; set DL=' '
       INT 21H                    ; print a character

       MOV DL, 8H                 ; set DL=8H
       INT 21H                    ; print a character

       JMP @READ                  ; jump to label @READ
                                  
     @MOVE_BACK:                  ; jump label

     MOV AX, BX                   ; set AX=BX
     MOV BX, 10                   ; set BX=10
     DIV BX                       ; set AX=AX/BX

     MOV BX, AX                   ; set BX=AX

     MOV AH, 2                    ; set output function
     MOV DL, 20H                  ; set DL=' '
     INT 21H                      ; print a character

     MOV DL, 8H                   ; set DL=8H
     INT 21H                      ; print a character

     XOR DX, DX                   ; clear DX
     DEC CL                       ; set CL=CL-1

     JMP @INPUT                   ; jump to label @INPUT

     @NOT_BACKSPACE:              ; jump label

     INC CL                       ; set CL=CL+1

     CMP AL, 30H                  ; compare AL with 0
     JL @ERROR                    ; jump to label @ERROR if AL<0

     CMP AL, 39H                  ; compare AL with 9
     JG @ERROR                    ; jump to label @ERROR if AL>9

     AND AX, 000FH                ; convert ascii to decimal code

     PUSH AX                      ; push AX onto the STACK

     MOV AX, 10                   ; set AX=10
     MUL BX                       ; set AX=AX*BX
     MOV BX, AX                   ; set BX=AX

     POP AX                       ; pop a value from STACK into AX

     ADD BX, AX                   ; set BX=AX+BX
     JS @ERROR                    ; jump to label @ERROR if SF=1
   JMP @INPUT                     ; jump to label @INPUT

   @ERROR:                        ; jump label

   MOV AH, 2                      ; set output function
   MOV DL, 7H                     ; set DL=7H
   INT 21H                        ; print a character

   XOR CH, CH                     ; clear CH

   @CLEAR:                        ; jump label
     MOV DL, 8H                   ; set DL=8H
     INT 21H                      ; print a character

     MOV DL, 20H                  ; set DL=' '
     INT 21H                      ; print a character

     MOV DL, 8H                   ; set DL=8H
     INT 21H                      ; print a character
   LOOP @CLEAR                    ; jump to label @CLEAR if CX!=0

   JMP @READ                      ; jump to label @READ

   @END_INPUT:                    ; jump label

   CMP CH, 1                      ; compare CH with 1   
   JNE @EXIT                      ; jump to label @EXIT if CH!=1
   NEG BX                         ; negate BX

   @EXIT:                         ; jump label

   MOV AX, BX                     ; set AX=BX

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX

   RET                            ; return control to the calling procedure
 INDEC ENDP

 ;**************************************************************************;
 ;--------------------------------  OUTDEC  --------------------------------;
 ;**************************************************************************;

 OUTDEC PROC
   ; this procedure will display a decimal number
   ; input : AX
   ; output : none

   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK

   CMP AX, 0                      ; compare AX with 0
   JGE @START                     ; jump to label @START if AX>=0

   PUSH AX                        ; push AX onto the STACK

   MOV AH, 2                      ; set output function
   MOV DL, "-"                    ; set DL='-'
   INT 21H                        ; print the character

   POP AX                         ; pop a value from STACK into AX

   NEG AX                         ; take 2's complement of AX

   @START:                        ; jump label

   XOR CX, CX                     ; clear CX
   MOV BX, 10                     ; set BX=10

   @OUTPUT:                       ; loop label
     XOR DX, DX                   ; clear DX
     DIV BX                       ; divide AX by BX
     PUSH DX                      ; push DX onto the STACK
     INC CX                       ; increment CX
     OR AX, AX                    ; take OR of Ax with AX
   JNE @OUTPUT                    ; jump to label @OUTPUT if ZF=0

   MOV AH, 2                      ; set output function

   @DISPLAY:                      ; loop label
     POP DX                       ; pop a value from STACK to DX
     OR DL, 30H                   ; convert decimal to ascii code
     INT 21H                      ; print a character
   LOOP @DISPLAY                  ; jump to label @DISPLAY if CX!=0

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX

   RET                            ; return control to the calling procedure
 OUTDEC ENDP

 ;**************************************************************************;
 ;--------------------------------------------------------------------------;
 ;**************************************************************************;

 END MAIN