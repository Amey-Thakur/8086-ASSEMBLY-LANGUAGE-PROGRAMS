;=============================================================================
; Program:     Count Words in Sentence
; Description: Count the number of words in a user-entered sentence.
;              Words are separated by spaces.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 64

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    MAXLEN DB 100                       ; Maximum input length
    ACTCHAR DB ?                        ; Actual characters entered
    STR DB 101 DUP('$')                 ; Input buffer
    STR1 DB "NO. OF WORDS IS ", '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC FAR
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Initialize Counters
    ;-------------------------------------------------------------------------
    MOV CX, 00
    MOV BX, 00
    MOV AX, 00
    
    ;-------------------------------------------------------------------------
    ; Read String from User
    ;-------------------------------------------------------------------------
    LEA DX, MAXLEN
    MOV AH, 0AH                         ; Buffered input
    INT 21H

    ;-------------------------------------------------------------------------
    ; Count Words (by counting spaces + 1)
    ;-------------------------------------------------------------------------
    MOV CH, 00H
    MOV CL, ACTCHAR                     ; Length of input
    MOV DX, 0100H                       ; DL=word count tens, DH=units
    
    ; Handle leading space
    CMP STR[0], ' '
    JNZ L1
    SUB DH, 01

L1: 
    CMP STR[BX], ' '                    ; Is current char a space?
    JNZ L3
    
    ; Skip consecutive spaces
L2: 
    INC BX
    DEC CX
    CMP STR[BX], ' '
    JZ L2
    
    INC DH                              ; Found new word
    CMP DH, 0AH                         ; Check for overflow
    JB L3
    MOV DH, 00
    INC DL
    
L3: 
    INC BX
    LOOP L1
    
    ; Handle trailing space
    CMP STR[BX-1], ' '
    JNZ L4
    SUB DH, 01
    JNC L4
    SUB DL, 01
    ADD DH, 0AH

    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
L4: 
    MOV BX, DX
    
    ; Newline
    MOV AH, 02H
    MOV DL, 0AH
    INT 21H
    MOV DL, 0DH
    INT 21H
    
    ; Display message
    LEA DX, STR1
    MOV AH, 09H
    INT 21H

    ; Display count
    MOV DX, BX
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    ADD DH, 30H
    MOV DL, DH
    MOV AH, 02H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AX, 4C00H
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; WORD COUNT NOTES:
; - Words are separated by one or more spaces
; - Handle leading/trailing spaces
; - Handle multiple consecutive spaces
;=============================================================================
