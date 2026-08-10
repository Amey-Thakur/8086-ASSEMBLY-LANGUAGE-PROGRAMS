; =============================================================================
; TITLE: The Signed Branch Family
; DESCRIPTION: Runs every signed conditional jump against a negative and a
;              positive value: greater, less, and the two that allow equality.
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
    POSITIVE DW 25
    NEGATIVE DW -30
    M_JG     DB 'JG   taken: 25 is greater than -30', 0DH, 0AH, '$'
    M_JGE    DB 'JGE  taken: 25 is greater or equal', 0DH, 0AH, '$'
    M_JL     DB 'JL   taken: -30 is less than 25', 0DH, 0AH, '$'
    M_JLE    DB 'JLE  taken: -30 is less or equal', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE SIGNED FAMILY READS THE SIGN AND OVERFLOW FLAGS TOGETHER. THE
    ; RESULT IS NEGATIVE WHEN SF DIFFERS FROM OF, BECAUSE AN OVERFLOW MEANS
    ; THE SIGN BIT IS THE OPPOSITE OF THE TRUE ANSWER.
    ; -------------------------------------------------------------------------
    MOV AX, POSITIVE
    CMP AX, NEGATIVE
    JLE SKIP_JG
    LEA DX, M_JG
    MOV AH, 09H
    INT 21H

SKIP_JG:
    MOV AX, POSITIVE
    CMP AX, NEGATIVE
    JL  SKIP_JGE
    LEA DX, M_JGE
    MOV AH, 09H
    INT 21H

SKIP_JGE:
    MOV AX, NEGATIVE
    CMP AX, POSITIVE
    JGE SKIP_JL
    LEA DX, M_JL
    MOV AH, 09H
    INT 21H

SKIP_JL:
    MOV AX, NEGATIVE
    CMP AX, POSITIVE
    JG  FINISH
    LEA DX, M_JLE
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY OF IS INVOLVED:
;    - Comparing 30000 with -30000 gives a difference of 60000, which does
;    - not fit in a signed word. The sign bit ends up wrong, and OF being
;    - set is what tells the branch to read it the other way round.
; 2. THE SYNONYMS:
;    - JG is JNLE, JGE is JNL, JL is JNGE, JLE is JNG. As with the
;    - unsigned family, each pair is one opcode.
; 3. JS IS NOT JL:
;    - JS tests the sign flag alone and ignores overflow. It answers "is
;    - the result negative", not "was the first value smaller". They
;    - agree until an overflow happens, and then they do not.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
