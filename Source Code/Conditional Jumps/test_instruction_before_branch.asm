; =============================================================================
; TITLE: TEST, CMP, and Choosing Between Them
; DESCRIPTION: Uses TEST to examine individual bits without disturbing the value,
;              and contrasts it with CMP and with a plain AND.
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
    STATUS   DB 10110100B
    M_BIT2   DB 'Bit 2 is clear.', 0DH, 0AH, '$'
    M_BIT2S  DB 'Bit 2 is set.', 0DH, 0AH, '$'
    M_BIT4   DB 'Bit 4 is set.', 0DH, 0AH, '$'
    M_BIT4C  DB 'Bit 4 is clear.', 0DH, 0AH, '$'
    M_INTACT DB 'STATUS is unchanged after both tests.', 0DH, 0AH, '$'
    M_CHANGED DB 'STATUS was modified.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; TEST IS AN AND WHOSE RESULT IS THROWN AWAY. IT SETS THE ZERO FLAG WHEN
    ; NONE OF THE SELECTED BITS ARE SET, AND LEAVES THE OPERAND ALONE.
    ; -------------------------------------------------------------------------
    MOV AL, STATUS
    TEST AL, 00000100B                  ; Is bit 2 set?
    JNZ BIT2_SET

    LEA DX, M_BIT2
    JMP SHOW_BIT2

BIT2_SET:
    LEA DX, M_BIT2S

SHOW_BIT2:
    MOV AH, 09H
    INT 21H

    MOV AL, STATUS
    TEST AL, 00010000B                  ; Is bit 4 set?
    JZ  BIT4_CLEAR

    LEA DX, M_BIT4
    JMP SHOW_BIT4

BIT4_CLEAR:
    LEA DX, M_BIT4C

SHOW_BIT4:
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; NEITHER TEST WROTE ANYTHING BACK, SO THE ORIGINAL BYTE IS STILL THERE.
    ; AN AND WOULD HAVE LEFT ONLY THE SELECTED BIT BEHIND.
    ; -------------------------------------------------------------------------
    MOV AL, STATUS
    CMP AL, 10110100B
    JNE WAS_CHANGED

    LEA DX, M_INTACT
    JMP REPORT

WAS_CHANGED:
    LEA DX, M_CHANGED

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. TEST IS TO AND AS CMP IS TO SUB:
;    - Each performs the operation for the flags alone. Two instructions
;    - that exist purely so a value can be examined without being changed.
; 2. READING THE RESULT:
;    - ZF set means none of the selected bits were set. There is no flag
;    - for "all of them were", so testing several bits at once answers
;    - only "any" and not "all".
; 3. THE CARRY IS ALWAYS CLEARED:
;    - TEST, AND, OR and XOR all clear CF and OF. A carry that mattered
;    - has to be saved before any of them.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
