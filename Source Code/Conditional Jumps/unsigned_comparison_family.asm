; =============================================================================
; TITLE: The Unsigned Branch Family
; DESCRIPTION: Runs every unsigned conditional jump against the same pair of
;              values: above, below, and the two that allow equality.
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
    BIG    DW 60000
    SMALL_ DW 40000
    M_JA   DB 'JA   taken: 60000 is above 40000', 0DH, 0AH, '$'
    M_JAE  DB 'JAE  taken: 60000 is above or equal', 0DH, 0AH, '$'
    M_JB   DB 'JB   taken: 40000 is below 60000', 0DH, 0AH, '$'
    M_JBE  DB 'JBE  taken: 40000 is below or equal', 0DH, 0AH, '$'
    M_EQ   DB 'JAE and JBE both taken when equal', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE UNSIGNED FAMILY READS THE CARRY FLAG. CMP SETS THE CARRY WHEN THE
    ; SUBTRACTION NEEDED A BORROW, WHICH IS EXACTLY WHEN THE FIRST OPERAND IS
    ; THE SMALLER OF THE TWO AS UNSIGNED VALUES.
    ; -------------------------------------------------------------------------
    MOV AX, BIG
    CMP AX, SMALL_
    JBE SKIP_JA
    LEA DX, M_JA
    MOV AH, 09H
    INT 21H

SKIP_JA:
    MOV AX, BIG
    CMP AX, SMALL_
    JB  SKIP_JAE
    LEA DX, M_JAE
    MOV AH, 09H
    INT 21H

SKIP_JAE:
    MOV AX, SMALL_
    CMP AX, BIG
    JAE SKIP_JB
    LEA DX, M_JB
    MOV AH, 09H
    INT 21H

SKIP_JB:
    MOV AX, SMALL_
    CMP AX, BIG
    JA  SKIP_JBE
    LEA DX, M_JBE
    MOV AH, 09H
    INT 21H

SKIP_JBE:
    ; -------------------------------------------------------------------------
    ; THE TWO THAT ALLOW EQUALITY ARE BOTH TRUE WHEN THE VALUES MATCH.
    ; -------------------------------------------------------------------------
    MOV AX, BIG
    CMP AX, BIG
    JB  FINISH
    JA  FINISH

    LEA DX, M_EQ
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE SYNONYMS:
;    - JA is JNBE, JAE is JNB and JNC, JB is JNAE and JC, JBE is JNA.
;    - Each pair assembles to one opcode; the names exist so the source
;    - can say what the programmer meant.
; 2. WHY 60000 IS ABOVE 40000:
;    - Both fit in sixteen bits without a sign, so the comparison is the
;    - plain numeric one. Read as signed they would be -5536 and -25536,
;    - and the answer would still be the same, but for other pairs it is
;    - not.
; 3. THE VOCABULARY IS DELIBERATE:
;    - Above and below are the unsigned words. Greater and less are the
;    - signed ones. Confusing them is one of the most common causes of a
;    - comparison that works for small numbers and fails for large ones.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
