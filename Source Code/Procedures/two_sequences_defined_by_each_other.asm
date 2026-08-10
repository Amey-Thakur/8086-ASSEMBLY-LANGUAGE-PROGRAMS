; =============================================================================
; TITLE: Two Sequences Defined In Terms Of Each Other
; DESCRIPTION: The Hofstadter female and male sequences, where each procedure
;              can only finish by calling the other, so neither may be written
;              or tested on its own.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 400H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    LAST_N  EQU 10                      ; The table runs from zero to here

    FEM_V   DW ?                        ; This row's two answers, held in
    MAL_V   DW ?                        ; memory so both survive the printing

    M_TITLE DB 'F(n) and M(n), each defined by way of the other', 0DH, 0AH
            DB 'F(0) = 1 and M(0) = 0', 0DH, 0AH
            DB 'F(n) = n - M(F(n-1))', 0DH, 0AH
            DB 'M(n) = n - F(M(n-1))', 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD  DB ' n     F     M', 0DH, 0AH, '$'
    M_GAP   DB '    $'
    M_SPACE DB ' $'
    M_AGREE DB 0DH, 0AH, 'The two agree at $'
    M_OF    DB ' of the $'
    M_ROWS  DB ' values above', 0DH, 0AH, '$'
    M_CLOSE DB 0DH, 0AH
            DB 'Neither procedure has a stopping rule of its own beyond n = 0. '
            DB 'What ends the descent is that every recursive call is made on '
            DB 'a strictly smaller argument, whichever of the two makes it.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI                          ; The n of this row
    XOR DI, DI                          ; How often the two answers match

; -----------------------------------------------------------------------------
; ONE ROW PER N. SI AND DI ARE SAFE ACROSS THE CALLS BECAUSE NEITHER SEQUENCE
; PROCEDURE TOUCHES ANYTHING BUT AX AND BX.
; -----------------------------------------------------------------------------
EACH_N:
    MOV AX, SI
    CALL PRINT_PADDED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, SI
    CALL FEMALE
    MOV FEM_V, AX
    CALL PRINT_PADDED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, SI
    CALL MALE
    MOV MAL_V, AX
    CALL PRINT_PADDED
    CALL NEWLINE

    MOV AX, FEM_V
    CMP AX, MAL_V
    JNE NOT_ALIKE
    INC DI
NOT_ALIKE:

    INC SI
    CMP SI, LAST_N
    JBE EACH_N                          ; Unsigned, n never goes negative

    LEA DX, M_AGREE
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, M_OF
    CALL PRINT_MESSAGE
    MOV AX, LAST_N
    INC AX                              ; Zero counts as a row as well
    CALL PRINT_DECIMAL
    LEA DX, M_ROWS
    CALL PRINT_MESSAGE

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; FEMALE
;
; Entry: AX = n. Exit: AX = F(n). BX is preserved, and so is every other
; register, which is what lets the caller keep its loop position in SI.
;
; The recursion goes down through MALE and comes back, so a single frame of
; this procedure has two different procedures active beneath it.
; -----------------------------------------------------------------------------
FEMALE PROC
    OR  AX, AX
    JNZ FE_STEP
    MOV AX, 1                           ; F(0) is one by definition
    RET

FE_STEP:
    PUSH BX
    MOV BX, AX                          ; Keep n while the descent happens
    DEC AX
    CALL FEMALE                         ; F(n-1)
    CALL MALE                           ; M of that
    XCHG AX, BX                         ; AX = n, BX = M(F(n-1))
    SUB AX, BX
    POP BX
    RET
FEMALE ENDP

; -----------------------------------------------------------------------------
; MALE
;
; Entry: AX = n. Exit: AX = M(n). The shape is identical to FEMALE with the two
; names exchanged, which is the definition read literally.
; -----------------------------------------------------------------------------
MALE PROC
    OR  AX, AX
    JNZ MA_STEP
    RET                                 ; M(0) is zero, and AX already is

MA_STEP:
    PUSH BX
    MOV BX, AX
    DEC AX
    CALL MALE                           ; M(n-1)
    CALL FEMALE                         ; F of that
    XCHG AX, BX                         ; AX = n, BX = F(M(n-1))
    SUB AX, BX
    POP BX
    RET
MALE ENDP

; -----------------------------------------------------------------------------
; PRINT_PADDED
;
; Prints AX in decimal, right aligned in two columns, so the table lines up
; when n reaches double figures.
; -----------------------------------------------------------------------------
PRINT_PADDED PROC
    PUSH AX
    PUSH DX

    CMP AX, 10
    JAE PP_SHOW                         ; Unsigned, these are all counts
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE

PP_SHOW:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_PADDED ENDP

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
; 1. WHY THE ASSEMBLER DOES NOT MIND:
;    - FEMALE names MALE before MALE has been assembled, and the reverse.
;    - The first pass records where every label lands, the second fills it in.
;    - A one pass assembler would need both procedures declared in advance.
; 2. WHAT STOPS THE DESCENT:
;    - Every recursive call is made on an argument strictly below n.
;    - So the chain of calls must reach zero, whichever procedure is running.
;    - Neither procedure alone contains the whole of that argument.
; 3. THE COST OF NOT REMEMBERING:
;    - F(n-1) is worked out afresh for every row of the table.
;    - Storing each answer once computed would make the table linear work.
;    - The plain form is kept here because the recursion is the subject.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
