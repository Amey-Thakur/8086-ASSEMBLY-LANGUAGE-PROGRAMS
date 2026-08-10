; =============================================================================
; TITLE: Testing Whether an Array Is Sorted
; DESCRIPTION: Decides in one pass whether an array is already in order, which
;              is worth doing before paying for a sort.
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
    ORDERED   DW 2, 5, 9, 14, 20, 31
    JUMBLED   DW 2, 5, 9, 4, 20, 31
    HOWMANY   EQU 6
    M_FIRST   DB 'The first array:  $'
    M_SECOND  DB 'The second array: $'
    M_SORTED  DB 'is in order', 0DH, 0AH, '$'
    M_NOT     DB 'is not in order', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_FIRST
    MOV AH, 09H
    INT 21H
    LEA SI, ORDERED
    CALL IS_SORTED
    CALL REPORT

    LEA DX, M_SECOND
    MOV AH, 09H
    INT 21H
    LEA SI, JUMBLED
    CALL IS_SORTED
    CALL REPORT

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; IS_SORTED
;
; SI points at the array. Returns 1 in AX when every neighbouring pair is in
; order, and stops at the first pair that is not.
; -----------------------------------------------------------------------------
IS_SORTED PROC
    PUSH BX
    PUSH CX
    PUSH SI

    MOV CX, HOWMANY
    DEC CX                              ; Pairs, not elements

CHECK:
    MOV AX, [SI]
    MOV BX, [SI+2]
    CMP AX, BX
    JA  OUT_OF_ORDER                    ; One pair is enough to decide

    ADD SI, 2
    LOOP CHECK

    MOV AX, 1
    JMP IS_SORTED_RETURN

OUT_OF_ORDER:
    XOR AX, AX

IS_SORTED_RETURN:
    POP SI
    POP CX
    POP BX
    RET
IS_SORTED ENDP

; -----------------------------------------------------------------------------
; REPORT
; -----------------------------------------------------------------------------
REPORT PROC
    OR  AX, AX
    JZ  R_NOT
    LEA DX, M_SORTED
    JMP R_SHOW

R_NOT:
    LEA DX, M_NOT

R_SHOW:
    MOV AH, 09H
    INT 21H
    RET
REPORT ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONE COUNTEREXAMPLE IS ENOUGH:
;    - The test stops at the first pair out of order. Proving an array
;    - sorted needs every pair; proving it unsorted needs one.
; 2. PAIRS, NOT ELEMENTS:
;    - Six elements have five neighbouring pairs. Looping the full count
;    - reads one element past the end of the array.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
