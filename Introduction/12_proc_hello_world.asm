ORG 100H

LEA SI,msg      ;load effective address                                     

CALL print_me

RET             ;return to operating system

;==================================================
;this procedure prints a string should be null
;terminated (have zero in the end),
;the string address should be in SI register:

print_me PROC
    
next_char:
    CMP b.[SI],0 ;check for zero to stop
    JE stop     ;
    
    MOV AL,[SI] ;next get ASCII char
    
    MOV AH,0EH  ;teletype function number
    INT 10H     ;using interrupt to print a char in AL
    
    ADD SI,1    ;advance index of string array
    
    JMP next_char
    
stop:
    RET         ;return to caller
    print_me ENDP

;===================================================

msg DB 'Hello World!',0     ;null terminated string

END