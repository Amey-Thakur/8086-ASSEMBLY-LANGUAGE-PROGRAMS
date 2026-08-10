; =============================================================================
; TITLE: Branching on Equality
; DESCRIPTION: Compares two values and branches on the result, showing that JE
;              and JZ are the same instruction under two names.
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
    FIRST   DW 42
    SECOND  DW 42
    THIRD   DW 17
    SAME    DB 'The first two are equal.', 0DH, 0AH, '$'
    DIFFER  DB 'The first and third differ.', 0DH, 0AH, '$'
    SYNONYM DB 'JE and JZ took the same branch.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; CMP SUBTRACTS AND THROWS THE ANSWER AWAY, KEEPING ONLY THE FLAGS. WHEN
    ; THE TWO VALUES ARE EQUAL THE DIFFERENCE IS ZERO, SO THE ZERO FLAG IS
    ; SET. THAT IS ALL JE TESTS.
    ; -------------------------------------------------------------------------
    MOV AX, FIRST
    CMP AX, SECOND
    JNE NOT_EQUAL

    LEA DX, SAME
    MOV AH, 09H
    INT 21H

NOT_EQUAL:
    MOV AX, FIRST
    CMP AX, THIRD
    JE  SKIP_DIFFER

    LEA DX, DIFFER
    MOV AH, 09H
    INT 21H

SKIP_DIFFER:
    ; -------------------------------------------------------------------------
    ; JE AND JZ ASSEMBLE TO THE SAME OPCODE. THE TWO NAMES EXIST BECAUSE THE
    ; SAME TEST READS BETTER AS "EQUAL" AFTER A COMPARE AND AS "ZERO" AFTER
    ; AN ARITHMETIC INSTRUCTION.
    ; -------------------------------------------------------------------------
    MOV AX, FIRST
    CMP AX, SECOND
    JE  ARRIVED_BY_JE
    JMP FINISH

ARRIVED_BY_JE:
    MOV AX, FIRST
    SUB AX, SECOND                      ; The result really is zero
    JZ  CONFIRMED
    JMP FINISH

CONFIRMED:
    LEA DX, SYNONYM
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CMP CHANGES NOTHING BUT THE FLAGS:
;    - It is a subtraction whose result is discarded. Both operands are
;    - still intact afterwards, which is why a value can be compared
;    - several times in a row without reloading it.
; 2. THE BRANCH IS ALWAYS THE OPPOSITE:
;    - To do something when two values are equal, branch away when they
;    - are not. Writing the test the other way needs a jump over a jump,
;    - which is longer and harder to follow.
; 3. EQUALITY IS SIGN INDEPENDENT:
;    - JE is the one comparison that does not care whether the values are
;    - signed. Equal bits are equal bits, however they are interpreted.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
