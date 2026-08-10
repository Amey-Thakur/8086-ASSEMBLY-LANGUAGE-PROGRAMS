; =============================================================================
; TITLE: The Roots Of A Quadratic
; DESCRIPTION: The discriminant decides how many roots there are, and only then is a square root worth taking.
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
    ; Four equations, chosen so all three cases appear and the roots are whole.
    A_W     DW 1,  1,  1,  2
    B_W     DW -5, -4,  2, -8
    C_W     DW 6,  4,  5,  6
    HOWMANY EQU 4

    M_TITLE DB 'Solving a quadratic, one case at a time', 0DH, 0AH, '$'
    M_EQN   DB 0DH, 0AH, 'a=$'
    M_B     DB ' b=$'
    M_C     DB ' c=$'
    M_DISC  DB '   discriminant $'
    M_TWO   DB 0DH, 0AH, '   two real roots: $'
    M_AND   DB ' and $'
    M_ONE   DB 0DH, 0AH, '   one repeated root: $'
    M_NONE  DB 0DH, 0AH, '   no real roots', 0DH, 0AH, '$'
    M_NL    DB 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'The discriminant is tested before the square root is taken. '
            DB 'Taking the root first would need a negative number under it.'
            DB 0DH, 0AH, '$'
    M_INT   DB 'These roots are whole numbers by design. A fractional root '
            DB 'would need the division carried out to more than integer '
            DB 'precision.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_EQUATION:
    PUSH CX

    LEA DX, M_EQN
    CALL PRINT_MESSAGE
    MOV AX, A_W[SI]
    CALL PRINT_SIGNED
    LEA DX, M_B
    CALL PRINT_MESSAGE
    MOV AX, B_W[SI]
    CALL PRINT_SIGNED
    LEA DX, M_C
    CALL PRINT_MESSAGE
    MOV AX, C_W[SI]
    CALL PRINT_SIGNED

    ; -------------------------------------------------------------------------
    ; THE DISCRIMINANT, B SQUARED MINUS FOUR A C. EVERY MULTIPLICATION IS SIGNED,
    ; BECAUSE B IS NEGATIVE IN THREE OF THE FOUR CASES.
    ; -------------------------------------------------------------------------
    MOV AX, B_W[SI]
    IMUL AX                             ; b squared
    MOV DI, AX

    MOV AX, A_W[SI]
    IMUL WORD PTR C_W[SI]
    MOV BX, 4
    IMUL BX                             ; four a c
    SUB DI, AX                          ; the discriminant

    LEA DX, M_DISC
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_SIGNED

    ; -------------------------------------------------------------------------
    ; AND ONLY NOW IS IT SAFE TO ASK FOR A SQUARE ROOT. TESTING AFTERWARDS WOULD
    ; MEAN TAKING THE ROOT OF A NEGATIVE NUMBER FIRST.
    ; -------------------------------------------------------------------------
    CMP DI, 0
    JL NO_REAL_ROOTS
    JE ONE_ROOT

    ; ---- two roots -----------------------------------------------------------
    MOV AX, DI
    CALL SQUARE_ROOT
    MOV BP, AX                          ; The root of the discriminant

    LEA DX, M_TWO
    CALL PRINT_MESSAGE

    ; (-b + root) / 2a
    MOV AX, B_W[SI]
    NEG AX
    ADD AX, BP
    CALL HALVE_BY_A
    CALL PRINT_SIGNED

    LEA DX, M_AND
    CALL PRINT_MESSAGE

    ; (-b - root) / 2a
    MOV AX, B_W[SI]
    NEG AX
    SUB AX, BP
    CALL HALVE_BY_A
    CALL PRINT_SIGNED
    CALL NEWLINE
    JMP NEXT_EQUATION

ONE_ROOT:
    LEA DX, M_ONE
    CALL PRINT_MESSAGE
    MOV AX, B_W[SI]
    NEG AX
    CALL HALVE_BY_A
    CALL PRINT_SIGNED
    CALL NEWLINE
    JMP NEXT_EQUATION

NO_REAL_ROOTS:
    LEA DX, M_NONE
    CALL PRINT_MESSAGE

NEXT_EQUATION:
    ADD SI, 2
    POP CX
    LOOP EACH_EQUATION

    LEA DX, M_WHY
    CALL PRINT_MESSAGE
    LEA DX, M_INT
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; HALVE_BY_A
;
; Divides AX by twice the coefficient a for the current equation.
;
; IDIV is used because the numerator is signed. It takes its dividend from
; DX:AX, so the sign has to be extended into DX first with CWD; leaving DX at
; zero would make a negative numerator look enormous and positive.
; -----------------------------------------------------------------------------
HALVE_BY_A PROC
    PUSH BX
    PUSH DX

    MOV BX, A_W[SI]
    SHL BX, 1                           ; two a

    CWD                                 ; sign extend AX into DX:AX
    IDIV BX

    POP DX
    POP BX
    RET
HALVE_BY_A ENDP

; -----------------------------------------------------------------------------
; SQUARE_ROOT
;
; The integer square root of AX, by trial. Small enough here that a search from
; zero costs less than anything cleverer would.
; -----------------------------------------------------------------------------
SQUARE_ROOT PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, AX                          ; What is being rooted
    XOR BX, BX                          ; The candidate

ROOT_AGAIN:
    MOV AX, BX
    MUL BX                              ; unsigned: both are known positive here
    CMP AX, CX
    JA ROOT_FOUND                       ; Gone past it
    JE ROOT_EXACT

    INC BX
    JMP ROOT_AGAIN

ROOT_FOUND:
    DEC BX                              ; The last one that was not too large

ROOT_EXACT:
    MOV AX, BX

    POP DX
    POP CX
    POP BX
    RET
SQUARE_ROOT ENDP

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. Test the discriminant first:
;    - A negative discriminant means no real roots, and no square root should be attempted.
;    - Rooting first and testing afterwards asks for the root of a negative number.
;    - Zero is its own case: one repeated root rather than two that coincide.
; 2. CWD before IDIV:
;    - IDIV divides the whole of DX:AX, so DX must hold the sign extension of AX.
;    - CWD does exactly that: it fills DX with copies of the top bit of AX.
;    - Leaving DX at zero makes a negative numerator look like a huge positive one.
; 3. Signed and unsigned in one program:
;    - The coefficients and roots are signed, so IMUL and IDIV are used for them.
;    - The square root works on a value already known to be positive, so MUL is right there.
;    - Choosing per operation, rather than once for the program, is what keeps it correct.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
