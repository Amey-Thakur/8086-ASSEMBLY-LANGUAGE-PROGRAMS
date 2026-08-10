; =============================================================================
; TITLE: Driving a Stepper Motor, Full Step
; DESCRIPTION: Energises two coils at a time in the four step sequence, and
;              reverses it.
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
    MOTOR   EQU 7

    ; Two adjacent coils on at once, which gives the most torque. The four
    ; patterns cycle in this order and the motor turns one step for each.
    FORWARD DB 00000011B, 00000110B, 00001100B, 00001001B
    STEPS   EQU 4

    M_FWD   DB 'Turning forward:', 0DH, 0AH, '$'
    M_REV   DB 'Turning back:', 0DH, 0AH, '$'
    REVS    EQU 2

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_FWD
    MOV AH, 09H
    INT 21H

    MOV BP, REVS

FORWARD_TURNS:
    XOR BX, BX

FORWARD_STEP:
    CMP BX, STEPS
    JAE FORWARD_CYCLE_DONE

    MOV AL, FORWARD[BX]
    OUT MOTOR, AL

    PUSH BX
    CALL SHOW_BITS
    CALL NEWLINE
    POP BX

    INC BX
    JMP FORWARD_STEP

FORWARD_CYCLE_DONE:
    DEC BP
    JNZ FORWARD_TURNS

    ; -------------------------------------------------------------------------
    ; REVERSING NEEDS NO SECOND TABLE. WALKING THE SAME FOUR PATTERNS BACKWARD
    ; TURNS THE MOTOR THE OTHER WAY, WHICH IS WHY THE SEQUENCE IS ALWAYS
    ; WRITTEN AS A CYCLE RATHER THAN AS TWO LISTS.
    ; -------------------------------------------------------------------------
    LEA DX, M_REV
    MOV AH, 09H
    INT 21H

    MOV BP, REVS

REVERSE_TURNS:
    MOV BX, STEPS
    DEC BX

REVERSE_STEP:
    MOV AL, FORWARD[BX]
    OUT MOTOR, AL

    PUSH BX
    CALL SHOW_BITS
    CALL NEWLINE
    POP BX

    DEC BX
    CMP BX, 0FFFFH
    JNE REVERSE_STEP

    DEC BP
    JNZ REVERSE_TURNS

    ; De-energise the coils
    MOV AL, 0
    OUT MOTOR, AL

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_BITS
;
; Prints AL as eight ones and zeros, most significant first. A port value is
; a set of independent lines rather than a number, so binary is the form that
; says what it means.
; -----------------------------------------------------------------------------
SHOW_BITS PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, 8

SB_LOOP:
    SHL AL, 1
    MOV DL, '0'
    JNC SB_EMIT
    MOV DL, '1'

SB_EMIT:
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    LOOP SB_LOOP

    POP DX
    POP CX
    POP AX
    RET
SHOW_BITS ENDP

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
; 1. TWO COILS AT ONCE:
;    - Full stepping energises adjacent pairs, which gives roughly forty
;    - per cent more torque than one coil at a time and draws twice the
;    - current.
; 2. THE ORDER IS THE DIRECTION:
;    - The same four patterns in reverse turn the motor the other way. A
;    - motor that runs backwards is almost always a table walked the wrong
;    - way, not a wiring fault.
; 3. DE-ENERGISING AT THE END:
;    - Coils left energised hold position and get hot. A driver that ends
;    - without clearing the port leaves the motor drawing current for as
;    - long as the machine is on.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
