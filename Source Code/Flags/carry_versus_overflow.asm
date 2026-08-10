; =============================================================================
; TITLE: Carry And Overflow Answer Different Questions
; DESCRIPTION: Adds four pairs of words and reports the carry and the overflow
;              side by side, so that all four combinations of the two appear.
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
    ; Four pairs, chosen so that carry and overflow take every combination of
    ; values between them. Nothing else about the pairs matters.
    PAIRS    DW 10000, 20000, 60000, 10000, 30000, 20000, 40000, 40000
    HOWMANY  EQU 4

    NUMBER_W EQU 6                      ; Columns each number is padded to
    CF_MASK  EQU 0001H                  ; The carry lives in bit 0
    OF_MASK  EQU 0800H                  ; The overflow lives in bit 11

    M_TITLE  DB 'Carry and overflow answer different questions', 0DH, 0AH, 0DH, 0AH
             DB 'Carry asks whether the sum fitted as an unsigned number.', 0DH, 0AH
             DB 'Overflow asks whether it fitted as a signed one. The stored '
             DB 'bits are', 0DH, 0AH
             DB 'the same either way, so only the reader decides which flag is '
             DB 'the error.', 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD   DB '     A       B  stored  CF  OF', 0DH, 0AH
             DB '------  ------  ------  --  --', 0DH, 0AH, '$'
    M_GAP    DB '  $'
    M_FGAP   DB '   $'
    M_SPACE  DB ' $'
    M_CLOSE  DB 0DH, 0AH
             DB 'The second row is wrong only for unsigned work and the third '
             DB 'only for', 0DH, 0AH
             DB 'signed work. The fourth is wrong for both, and the first for '
             DB 'neither.', 0DH, 0AH, '$'

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

    LEA SI, PAIRS
    MOV CX, HOWMANY

EACH_PAIR:
    PUSH CX

    MOV AX, [SI]
    CALL PRINT_PADDED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, [SI+2]
    CALL PRINT_PADDED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE FLAGS ARE TAKEN OFF THE STACK BEFORE ANYTHING ELSE HAPPENS. PRINTING
    ; A NUMBER DIVIDES IT DOWN, AND THE DIVISION WOULD LEAVE ITS OWN CARRY AND
    ; OVERFLOW BEHIND, WHICH IS NOT WHAT THIS TABLE IS ABOUT.
    ; -------------------------------------------------------------------------
    MOV AX, [SI]
    ADD AX, [SI+2]
    PUSHF
    POP BX

    CALL PRINT_PADDED

    ; ---- the unsigned verdict -----------------------------------------------
    LEA DX, M_FGAP
    CALL PRINT_MESSAGE
    MOV AX, BX
    AND AX, CF_MASK
    JZ  NO_CARRY
    MOV AX, 1                           ; A flag prints as one column, not as a mask

NO_CARRY:
    CALL PRINT_DECIMAL

    ; ---- the signed verdict -------------------------------------------------
    LEA DX, M_FGAP
    CALL PRINT_MESSAGE
    MOV AX, BX
    AND AX, OF_MASK
    JZ  NO_OVERFLOW
    MOV AX, 1

NO_OVERFLOW:
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP CX
    ADD SI, 4                           ; Two words to the next pair
    LOOP EACH_PAIR

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_PADDED
;
; Prints AX right aligned in NUMBER_W columns.
;
; The width is counted first by dividing the value down, then that many spaces
; short of the field are printed before the number itself. Printing and then
; padding would left align it instead.
; -----------------------------------------------------------------------------
PRINT_PADDED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI                             ; The caller keeps its row offset here

    ; ---- how many digits? ---------------------------------------------------
    MOV BX, AX                          ; Keep the value
    MOV CX, 1                           ; Every number has at least one digit
    MOV DX, 10

COUNT_DIGITS:
    CMP AX, 10
    JB DIGITS_COUNTED

    XOR DX, DX
    MOV DI, 10
    DIV DI
    INC CX
    JMP COUNT_DIGITS

DIGITS_COUNTED:
    ; ---- the padding --------------------------------------------------------
    MOV AX, NUMBER_W
    SUB AX, CX
    MOV CX, AX
    JCXZ NO_PADDING

PAD_ONE:
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    LOOP PAD_ONE

NO_PADDING:
    MOV AX, BX
    CALL PRINT_DECIMAL

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_PADDED ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. TWO FLAGS, ONE ADDITION:
;    - The processor does not know whether the operands were signed. It
;    - sets both flags on every addition and leaves the program to read
;    - whichever one matches the meaning the operands were given.
; 2. HOW EACH IS DERIVED:
;    - The carry is the bit that fell out of the top of the word. The
;    - overflow is the carry into the top bit compared with the carry out
;    - of it, and it is set when the two disagree.
; 3. WHICH BRANCHES READ WHICH:
;    - JC, JA and JB read the carry, so they belong to unsigned work. JO,
;    - JG and JL read the overflow and the sign together, so they belong
;    - to signed work. Mixing the families is the usual mistake.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
