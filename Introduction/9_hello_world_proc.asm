;Program to print Hello World using a procedure

ORG 100H

LEA SI,msg                  ;Load effective address of message into source index register

CALL print_me               ;Calls the procedure

RET

;=========================================================================================

;this procedure prints a string, the string should end with null
;only then will the procedure terminate
;the string address is in SI register to allow for indexing
;this way the string will be covered as an array of characters

print_me PROC
    
next_char:
        CMP b.[SI],0       ;check for zero to stop
        JE stop            ;short jump if first operand = second operand in CMP
        
        MOV AL,[SI]        ;next get ASCII char
        
        MOV AH,0EH         ;teletype output function number
        INT 10H            ;video interrupt
        
        ADD SI,1           ;advance index of string array
        
        JMP next_char      ;go back, and type another char
      
stop:
    RET                    ;return to caller
    print_me ENDP

;=========================================================================================

msg DB 'Hello World!',0    ;null terminated string

END