; =============================================================================
; TITLE: Finding a Character with REPNE SCASB
; DESCRIPTION: Searches a string for a character and reports its position, the
;              fastest search the 8086 offers.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    TEXT    DB 'MICROPROCESSOR'
    LENGTH  EQU 14
    WANTED  DB 'P'
    M_FOUND DB 'Found at position $'
    M_NONE  DB 'The character is not present.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; SCASB reads ES:DI

    ; -------------------------------------------------------------------------
    ; SCASB COMPARES AL AGAINST THE BYTE AT ES:DI. REPNE KEEPS IT GOING WHILE
    ; THEY DIFFER, SO THE PAIR SEARCHES A WHOLE STRING IN TWO INSTRUCTIONS.
    ; -------------------------------------------------------------------------
    LEA DI, TEXT
    MOV CX, LENGTH
    MOV AL, WANTED
    CLD
    REPNE SCASB
    JNE NOT_PRESENT

    MOV AX, LENGTH
    SUB AX, CX
    DEC AX                              ; Positions count from zero
    MOV BX, AX

    LEA DX, M_FOUND
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP FINISH

NOT_PRESENT:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_DECIMAL
;
; Prints the unsigned value in AX as decimal, with no leading zeros.
; Every register it touches is restored, so a caller can rely on it.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PD_DIVIDE:
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    DIV BX                              ; AX = quotient, DX = this digit
    PUSH DX                             ; Digits arrive lowest first
    INC CX
    OR  AX, AX
    JNZ PD_DIVIDE                       ; Keep going until the quotient is zero

PD_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PD_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; NEWLINE
;
; Moves to the start of the next line. DOS needs both characters: the return
; moves the cursor to column zero and the feed moves it down a line.
; -----------------------------------------------------------------------------
NEWLINE PROC
    PUSH AX
    PUSH DX

    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    POP DX
    POP AX
    RET
NEWLINE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE FLAG DECIDES THE OUTCOME:
;    - ZF set means the loop stopped on a match. ZF clear means the count
;    - ran out. Testing CX alone is not enough, because a match on the
;    - last element also leaves CX at zero.
; 2. SCASW SEARCHES WORDS:
;    - The same instruction one size up, comparing AX instead of AL,
;    - which is how a word array is searched.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
