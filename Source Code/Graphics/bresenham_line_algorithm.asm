; =============================================================================
; TITLE: Bresenham Line Drawing
; DESCRIPTION: Draws a line using only addition, subtraction and comparison, which is why it was the standard method on hardware like this.
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
    ; The line, chosen so the shallow case is exercised: 100 across, 40 down.
    X0_W    DW 20
    Y0_W    DW 20
    X1_W    DW 120
    Y1_W    DW 60

    DX_W    DW 0
    DY_W    DW 0
    ERR_W   DW 0
    CUR_X   DW 0
    CUR_Y   DW 0
    PLOTTED DW 0

    M_TITLE DB 'Bresenham from 20,20 to 120,60 in mode 13h', 0DH, 0AH, '$'
    M_DXDY  DB 'dx = $'
    M_DYIS  DB ', dy = $'
    M_STEPS DB 0DH, 0AH, 'Pixels plotted: $'
    M_EXP   DB 'Expected dx plus one: $'
    M_ENDED DB 0DH, 0AH, 'Line ended at $'
    M_COMMA DB ',$'
    M_WHY   DB 0DH, 0AH
            DB 'No multiplication and no division: only an error term that is '
            DB 'adjusted by whole numbers.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE SHALLOW CASE ONLY: DX IS LARGER THAN DY AND BOTH ARE POSITIVE, SO THE
    ; LINE ADVANCES ONE COLUMN EVERY STEP AND SOMETIMES A ROW. THE GENERAL CASE
    ; IS THE SAME IDEA WITH THE AXES SWAPPED WHEN DY IS LARGER.
    ; -------------------------------------------------------------------------
    MOV AX, X1_W
    SUB AX, X0_W
    MOV DX_W, AX                        ; dx

    MOV AX, Y1_W
    SUB AX, Y0_W
    MOV DY_W, AX                        ; dy

    ; The error term starts at half the run, expressed as dx shifted right once
    ; so that no fraction is ever needed.
    MOV AX, DX_W
    SHR AX, 1
    MOV ERR_W, AX

    MOV AX, X0_W
    MOV CUR_X, AX
    MOV AX, Y0_W
    MOV CUR_Y, AX

    MOV AX, 0013H
    INT 10H

    ; -------------------------------------------------------------------------
    ; ONE ITERATION PER COLUMN. THE ERROR TERM LOSES DY EACH TIME AND GAINS DX
    ; WHENEVER IT GOES NEGATIVE, WHICH IS THE MOMENT THE LINE STEPS DOWN A ROW.
    ; -------------------------------------------------------------------------
    MOV CX, DX_W
    INC CX                              ; Both ends included

EACH_COLUMN:
    MOV AL, 14                          ; Yellow
    PUSH CX
    MOV CX, CUR_X
    MOV DX, CUR_Y
    MOV AH, 0CH
    MOV BH, 0
    INT 10H
    POP CX
    INC PLOTTED

    ; ---- the error term ----------------------------------------------------
    MOV AX, ERR_W
    SUB AX, DY_W
    MOV ERR_W, AX

    ; A signed test, because the error term is deliberately allowed to go below
    ; zero. JB here would never be taken.
    CMP AX, 0
    JGE NO_ROW_STEP

    INC CUR_Y
    MOV AX, ERR_W
    ADD AX, DX_W
    MOV ERR_W, AX

NO_ROW_STEP:
    INC CUR_X
    LOOP EACH_COLUMN

    MOV AX, 0003H
    INT 10H

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_DXDY
    CALL PRINT_MESSAGE
    MOV AX, DX_W
    CALL PRINT_DECIMAL
    LEA DX, M_DYIS
    CALL PRINT_MESSAGE
    MOV AX, DY_W
    CALL PRINT_DECIMAL

    LEA DX, M_STEPS
    CALL PRINT_MESSAGE
    MOV AX, PLOTTED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_EXP
    CALL PRINT_MESSAGE
    MOV AX, DX_W
    INC AX
    CALL PRINT_DECIMAL

    LEA DX, M_ENDED
    CALL PRINT_MESSAGE
    MOV AX, CUR_X
    DEC AX                              ; CUR_X ran one past the last pixel
    CALL PRINT_DECIMAL
    LEA DX, M_COMMA
    CALL PRINT_MESSAGE
    MOV AX, CUR_Y
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

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

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. Integers only:
;    - The gradient is never computed, so there is no division and no rounding.
;    - The error term stands in for the fractional part, scaled by dx.
;    - On a processor with no floating point unit this is the difference between fast and unusable.
; 2. Signed comparison for the error:
;    - The error term is meant to go below zero; that is what triggers the row step.
;    - JGE is the signed test. JAE would treat minus one as 65535 and never step.
;    - This is the single most common way the algorithm is got wrong in assembly.
; 3. The shallow case only:
;    - This version assumes dx exceeds dy and both are positive.
;    - The general algorithm swaps the roles of the axes when dy is larger.
;    - Handling all eight octants means choosing which axis drives the loop first.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
