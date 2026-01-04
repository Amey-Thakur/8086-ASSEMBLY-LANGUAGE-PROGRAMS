;=============================================================================
; Program:     Compare Two Strings
; Description: Compare two strings using CMPSB instruction.
;              Demonstrates string comparison operations.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    STR1 DB 'HELLO$'                     ; First string
    STR2 DB 'HELLO$'                     ; Second string
    LEN EQU 5                            ; String length
    MSG_SAME DB 0DH, 0AH, 'Strings are EQUAL$'
    MSG_DIFF DB 0DH, 0AH, 'Strings are NOT EQUAL$'
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, ES:DATA
    
START:
    ; Initialize Segments
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX                           ; ES = DS for CMPSB
    
    ;-------------------------------------------------------------------------
    ; Setup String Pointers
    ;-------------------------------------------------------------------------
    LEA SI, STR1                         ; Source string (DS:SI)
    LEA DI, STR2                         ; Destination string (ES:DI)
    MOV CX, LEN                          ; String length
    
    ;-------------------------------------------------------------------------
    ; Compare Strings
    ; CLD: Forward direction (increment SI/DI)
    ; REPE CMPSB: Repeat Compare String Byte while Equal
    ;-------------------------------------------------------------------------
    CLD                                  ; Clear direction flag
    REPE CMPSB                           ; Compare bytes until mismatch or CX=0
    
    ;-------------------------------------------------------------------------
    ; Check Result
    ; If ZF=1, strings are equal
    ;-------------------------------------------------------------------------
    JE EQUAL                             ; Jump if strings are equal
    
    ; Strings are different
    LEA DX, MSG_DIFF
    JMP DISPLAY
    
EQUAL:
    LEA DX, MSG_SAME
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

;=============================================================================
; STRING COMPARE NOTES:
; - CMPSB: Compare byte at DS:SI with ES:DI
; - CMPSW: Compare word at DS:SI with ES:DI
; - REPE: Repeat while Equal (ZF=1) AND CX!=0
; - REPNE: Repeat while Not Equal (ZF=0) AND CX!=0
; - After REPE CMPSB, ZF=1 means all bytes matched
;=============================================================================
