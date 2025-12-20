;=============================================================================
; Program:     Substring Search
; Description: Check if a substring exists within a main string.
;              Returns position if found, -1 if not found.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; MACRO: Display String
;-----------------------------------------------------------------------------
DISPLAY MACRO MSG
    MOV AH, 9
    LEA DX, MSG
    INT 21H
ENDM

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    STR DB 'AXYBCSDEF$'                 ; Main string
    SUBSTR DB 'BCS$'                    ; Substring to find
    LEN1 DB 0                           ; Length of main string
    LEN2 DB 0                           ; Length of substring
    MSG1 DB 10, 13, 'STRING IS: $'
    MSG2 DB 10, 13, 'SUBSTRING IS: $'
    MSG3 DB 10, 13, 'SUBSTRING FOUND AT POSITION: $'
    MSG4 DB 10, 13, 'SUBSTRING NOT FOUND$'
    POS DB -1                           ; Position (0-indexed)
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    
    ; Display strings
    DISPLAY MSG1
    DISPLAY STR
    DISPLAY MSG2
    DISPLAY SUBSTR
    
    ;-------------------------------------------------------------------------
    ; Calculate Length of Main String
    ;-------------------------------------------------------------------------
    LEA SI, STR
NXT1:
    CMP BYTE PTR [SI], '$'
    JE DONE1
    INC LEN1
    INC SI
    JMP NXT1
DONE1:

    ;-------------------------------------------------------------------------
    ; Calculate Length of Substring
    ;-------------------------------------------------------------------------
    LEA DI, SUBSTR
NXT2:
    CMP BYTE PTR [DI], '$'
    JE DONE2
    INC LEN2
    INC DI
    JMP NXT2
DONE2:

    ;-------------------------------------------------------------------------
    ; Search for Substring
    ;-------------------------------------------------------------------------
    LEA SI, STR
    MOV AL, LEN1
    SUB AL, LEN2
    MOV CL, AL
    MOV CH, 0
    
FIRST:
    INC POS
    MOV AL, [SI]
    CMP AL, SUBSTR[0]                   ; First char match?
    JE CMPR
    INC SI
    LOOP FIRST
    JMP NOTFOUND

CMPR:
    ; Check remaining characters
    PUSH SI
    PUSH CX
    LEA DI, SUBSTR
    MOV CL, LEN2
    
CHECK_LOOP:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE NOTMATCH
    INC SI
    INC DI
    DEC CL
    JNZ CHECK_LOOP
    JMP FOUND

NOTMATCH:
    POP CX
    POP SI
    INC SI
    LOOP FIRST
    
NOTFOUND:
    DISPLAY MSG4
    JMP EXIT

FOUND:
    DISPLAY MSG3
    MOV DL, POS
    ADD DL, 30H
    MOV AH, 2
    INT 21H

EXIT:
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

;=============================================================================
; SUBSTRING SEARCH NOTES:
; - Searches for pattern within text
; - Returns 0-based position if found
; - "AXYBCSDEF" contains "BCS" at position 3
;=============================================================================
