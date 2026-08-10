; =============================================================================
; TITLE: Driving a Stepper Motor, Half Step
; DESCRIPTION: Alternates between one coil and two, which doubles the number of
;              positions the motor can hold.
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

    ; -------------------------------------------------------------------------
    ; EIGHT PATTERNS RATHER THAN FOUR, ALTERNATING BETWEEN ONE COIL AND TWO.
    ; EACH SINGLE COIL POSITION SITS BETWEEN TWO OF THE FULL STEP POSITIONS,
    ; WHICH IS WHERE THE EXTRA RESOLUTION COMES FROM.
    ; -------------------------------------------------------------------------
    HALF    DB 00000001B, 00000011B, 00000010B, 00000110B
            DB 00000100B, 00001100B, 00001000B, 00001001B
    STEPS   EQU 8

    M_HEAD  DB 'Eight half steps, one full revolution of the sequence:', 0DH, 0AH, '$'
    M_ONE   DB '   one coil', 0DH, 0AH, '$'
    M_TWO   DB '   two coils', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    XOR BX, BX

EACH_STEP:
    CMP BX, STEPS
    JAE FINISHED

    MOV AL, HALF[BX]
    OUT MOTOR, AL

    PUSH BX
    CALL SHOW_BITS

    ; -------------------------------------------------------------------------
    ; WHETHER ONE COIL OR TWO IS ENERGISED IS JUST HOW MANY BITS ARE SET, AND
    ; THE KERNIGHAN TEST DECIDES IT: A VALUE WITH ONE BIT SET BECOMES ZERO WHEN
    ; ANDED WITH ITSELF LESS ONE.
    ; -------------------------------------------------------------------------
    POP BX
    PUSH BX
    MOV AL, HALF[BX]
    XOR AH, AH
    MOV DI, AX
    DEC DI
    AND DI, AX
    JNZ TWO_COILS

    LEA DX, M_ONE
    JMP REPORT

TWO_COILS:
    LEA DX, M_TWO

REPORT:
    MOV AH, 09H
    INT 21H
    POP BX

    INC BX
    JMP EACH_STEP

FINISHED:
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
; 1. TWICE THE POSITIONS, LESS TORQUE:
;    - The single coil steps hold with about seventy per cent of the
;    - torque of the two coil ones, so the motor is smoother but weaker
;    - at half the positions.
; 2. THE FULL STEP SEQUENCE IS INSIDE THIS ONE:
;    - Taking every second entry of the eight gives the four two coil
;    - patterns back. That is why a driver can switch between the two
;    - modes without the motor losing its place.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
