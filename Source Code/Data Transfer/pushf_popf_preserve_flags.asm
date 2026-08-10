; =============================================================================
; TITLE: Preserving the Flags with PUSHF and POPF
; DESCRIPTION: Saves the flags across a calculation that would otherwise destroy
;              them, which is what any routine that must not disturb its caller does.
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
    KEPT DB 'The carry survived the calculation.', 0DH, 0AH, '$'
    LOST DB 'The carry was destroyed.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    STC                                 ; A carry worth keeping

    ; -------------------------------------------------------------------------
    ; PUSHF PUTS THE WHOLE FLAGS WORD ON THE STACK. ANYTHING MAY HAPPEN IN
    ; BETWEEN; POPF PUTS EVERY FLAG BACK AS IT WAS.
    ; -------------------------------------------------------------------------
    PUSHF

    MOV AX, 100                         ; This clears the carry
    ADD AX, 1
    XOR BX, BX                          ; So does this

    POPF                                ; Every flag restored

    JC  SURVIVED
    LEA DX, LOST
    JMP REPORT

SURVIVED:
    LEA DX, KEPT

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ALL OR NOTHING:
;    - PUSHF saves every flag, including the direction and interrupt
;    - flags. There is no instruction that saves one flag on its own.
; 2. THE COMMON MISTAKE:
;    - Calling a routine between the test and the branch loses the flags,
;    - because the routine will have run instructions of its own. Either
;    - branch first or save the flags first.
; 3. LAHF IS THE CHEAPER HALF:
;    - When only the arithmetic flags matter, LAHF puts them in AH without
;    - touching the stack, and SAHF puts them back.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
