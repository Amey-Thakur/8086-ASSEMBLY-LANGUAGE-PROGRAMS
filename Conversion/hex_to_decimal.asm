;=============================================================================
; Program:     Hexadecimal to Decimal Conversion
; Description: Convert a 16-bit hexadecimal number to its decimal string
;              representation and display on screen.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    NUM DW 1234H                        ; Hex number (4660 decimal)
    RES DB 10 DUP ('$')                 ; Result string buffer
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME DS:DATA, CS:CODE
    
START:       
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
   
    ;-------------------------------------------------------------------------
    ; Load Number and Convert to Decimal
    ;-------------------------------------------------------------------------
    MOV AX, NUM                          ; AX = 1234H = 4660 decimal
      
    LEA SI, RES                          ; Point to result buffer
    CALL HEX2DEC                         ; Convert to decimal string
   
    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
    LEA DX, RES
    MOV AH, 9                            ; DOS: Display string
    INT 21H 
            
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H        
CODE ENDS

;-----------------------------------------------------------------------------
; HEX2DEC: Convert AX (hex) to decimal string at [SI]
; Algorithm: Repeatedly divide by 10, store remainders
;-----------------------------------------------------------------------------
HEX2DEC PROC NEAR
    MOV CX, 0                            ; Digit counter
    MOV BX, 10                           ; Divisor
   
LOOP1: 
    MOV DX, 0                            ; Clear for 32-bit division
    DIV BX                               ; AX = quotient, DX = remainder
    ADD DL, 30H                          ; Convert to ASCII
    PUSH DX                              ; Save digit (reversed order)
    INC CX                               ; Count digit
    CMP AX, 9                            ; More than one digit left?
    JG LOOP1
     
    ;-------------------------------------------------------------------------
    ; Store first (most significant) digit
    ;-------------------------------------------------------------------------
    ADD AL, 30H                          ; Convert last quotient to ASCII
    MOV [SI], AL
     
    ;-------------------------------------------------------------------------
    ; Pop and store remaining digits (in correct order)
    ;-------------------------------------------------------------------------
LOOP2: 
    POP AX                               ; Get saved digit
    INC SI
    MOV [SI], AL                         ; Store digit
    LOOP LOOP2
    RET
HEX2DEC ENDP           
   
END START

;=============================================================================
; HEX TO DECIMAL CONVERSION NOTES:
; - Algorithm: Repeated division by 10
; - Remainders give digits in reverse order
; - Stack used to reverse digit order
; - Example: 1234H = 4660 decimal
;=============================================================================
