; =============================================================================
; TITLE: Jumping to an Address Held in a Register
; DESCRIPTION: Selects one of three routines by computing its address and
;              jumping to it, without a chain of comparisons.
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
    ; A table of routine addresses, filled in by the assembler
    ROUTINES DW ROUTINE_ZERO, ROUTINE_ONE, ROUTINE_TWO
    CHOICE   DW 2
    M_ZERO   DB 'Routine zero ran.', 0DH, 0AH, '$'
    M_ONE    DB 'Routine one ran.', 0DH, 0AH, '$'
    M_TWO    DB 'Routine two ran.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE CHOICE IS DOUBLED BECAUSE EACH TABLE ENTRY IS A WORD, THEN USED AS
    ; AN INDEX INTO THE TABLE. THE ADDRESS FOUND THERE IS JUMPED TO DIRECTLY,
    ; SO THE COST DOES NOT GROW WITH THE NUMBER OF CASES.
    ; -------------------------------------------------------------------------
    MOV BX, CHOICE
    SHL BX, 1                           ; Two bytes per entry
    JMP ROUTINES[BX]

ROUTINE_ZERO:
    LEA DX, M_ZERO
    JMP REPORT

ROUTINE_ONE:
    LEA DX, M_ONE
    JMP REPORT

ROUTINE_TWO:
    LEA DX, M_TWO

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CONSTANT TIME DISPATCH:
;    - A chain of compares costs one test per case that is not taken. A
;    - table costs the same however many cases there are, which is why a
;    - large switch is usually compiled into one.
; 2. THE INDEX MUST BE CHECKED:
;    - Nothing here stops a choice of nine reading past the end of the
;    - table and jumping into whatever follows. Real code compares the
;    - index against the table length first.
; 3. FORWARD REFERENCES IN DATA:
;    - The table names labels that appear later in the file. The
;    - assembler reserves the space on its first pass and fills in the
;    - addresses on the second.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
