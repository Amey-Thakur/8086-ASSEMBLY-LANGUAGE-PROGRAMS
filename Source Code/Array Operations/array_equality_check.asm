; =============================================================================
; TITLE: Comparing Two Arrays
; DESCRIPTION: Decides whether two arrays hold the same values in the same
;              order, and reports the first place they differ.
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
    FIRST   DW 5, 12, 8, 30, 17
    SECOND  DW 5, 12, 8, 30, 17
    THIRD   DW 5, 12, 9, 30, 17
    HOWMANY EQU 5

    M_ONE   DB 'First and second: $'
    M_TWO   DB 'First and third:  $'
    M_SAME  DB 'identical', 0DH, 0AH, '$'
    M_DIFF  DB 'differ at index $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA DX, M_ONE
    MOV AH, 09H
    INT 21H
    LEA SI, FIRST
    LEA DI, SECOND
    CALL COMPARE_ARRAYS

    LEA DX, M_TWO
    MOV AH, 09H
    INT 21H
    LEA SI, FIRST
    LEA DI, THIRD
    CALL COMPARE_ARRAYS

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; COMPARE_ARRAYS
;
; SI and DI point at two arrays of HOWMANY words.
; -----------------------------------------------------------------------------
COMPARE_ARRAYS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; -------------------------------------------------------------------------
    ; REPE CMPSW COMPARES WORDS FOR AS LONG AS THEY MATCH. WHEN IT STOPS, CX
    ; SAYS HOW MANY WERE STILL TO COME, AND THE ZERO FLAG SAYS WHETHER IT
    ; STOPPED BECAUSE OF A DIFFERENCE OR BECAUSE IT RAN OUT.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    CLD
    REPE CMPSW
    JNE THEY_DIFFER

    LEA DX, M_SAME
    MOV AH, 09H
    INT 21H
    JMP CA_DONE

THEY_DIFFER:
    MOV AX, HOWMANY
    SUB AX, CX
    DEC AX                              ; The element just examined

    PUSH AX
    LEA DX, M_DIFF
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

CA_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
COMPARE_ARRAYS ENDP

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
; 1. CMPSW COMPARES WORDS:
;    - So the count is in elements, not bytes. Using CMPSB with the
;    - element count would compare only the first half of the array.
; 2. ES MUST BE SET:
;    - The second operand of every string instruction is ES:DI, whatever
;    - the first one is. A comparison with ES left unset reads from
;    - another segment and reports a difference at index nought.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
