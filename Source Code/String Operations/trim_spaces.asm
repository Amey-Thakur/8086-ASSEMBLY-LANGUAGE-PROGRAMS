; =============================================================================
; TITLE: Trim Leading and Trailing Spaces
; DESCRIPTION: Removes the spaces from both ends of a string without touching
;              the ones inside it, and reports how many were taken off.
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
    RAW     DB '     amey   thakur      '
    RAWLEN  EQU $ - RAW
    M_RAW   DB 'Raw:     [$'
    M_TRIM  DB 'Trimmed: [$'
    M_CLOSE DB ']', 0DH, 0AH, '$'
    M_TAKEN DB 'Removed $'
    M_CHARS DB ' characters', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_RAW
    MOV AH, 09H
    INT 21H
    LEA SI, RAW
    MOV CX, RAWLEN
    CALL PRINT_TEXT
    LEA DX, M_CLOSE
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; FIND THE FIRST CHARACTER THAT IS NOT A SPACE, WORKING FORWARD, AND THE
    ; LAST, WORKING BACKWARD. WHAT LIES BETWEEN THEM IS THE ANSWER, AND NOTHING
    ; HAS TO BE MOVED AT ALL.
    ; -------------------------------------------------------------------------
    LEA SI, RAW
    MOV CX, RAWLEN

SKIP_LEADING:
    JCXZ ALL_SPACES
    CMP BYTE PTR [SI], ' '
    JNE FOUND_START
    INC SI
    DEC CX
    JMP SKIP_LEADING

FOUND_START:
    ; SI is the start, CX is how much is left from there
    MOV DI, SI
    ADD DI, CX
    DEC DI                              ; The last byte of what remains

SKIP_TRAILING:
    CMP BYTE PTR [DI], ' '
    JNE FOUND_END
    DEC DI
    DEC CX
    JMP SKIP_TRAILING

FOUND_END:
    LEA DX, M_TRIM
    MOV AH, 09H
    INT 21H
    CALL PRINT_TEXT                     ; SI and CX already describe it
    LEA DX, M_CLOSE
    MOV AH, 09H
    INT 21H

    MOV BX, RAWLEN
    SUB BX, CX

    LEA DX, M_TAKEN
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_CHARS
    MOV AH, 09H
    INT 21H
    JMP FINISH

ALL_SPACES:
    LEA DX, M_TRIM
    MOV AH, 09H
    INT 21H
    LEA DX, M_CLOSE
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. NOTHING IS COPIED:
;    - Trimming is a change of where the string begins and how long it
;    - is, not a change to the bytes. Moving them would be work for no
;    - benefit.
; 2. THE ALL SPACES CASE:
;    - A string of nothing but spaces exhausts the forward scan, and the
;    - backward scan would then run off the front of the buffer. It has
;    - to be caught before the second loop starts.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
