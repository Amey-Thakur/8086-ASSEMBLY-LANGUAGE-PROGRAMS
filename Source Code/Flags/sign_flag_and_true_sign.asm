; =============================================================================
; TITLE: When The Sign Flag Is Not The Sign
; DESCRIPTION: Adds signed words and works out the true sign of each answer,
;              which is the sign flag corrected by the overflow flag.
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
    ; The first two pairs overflow the signed range and the last two do not,
    ; so the sign flag is right twice and wrong twice.
    PAIRS    DW 20000, 20000, -20000, -20000, 100, -300, 300, -100
    HOWMANY  EQU 4

    BIG_POS  DW 20000
    BIG_NEG  DW -20000

    NUMBER_W EQU 6                      ; Columns each number is padded to
    SF_MASK  EQU 0080H                  ; The sign lives in bit 7
    OF_MASK  EQU 0800H                  ; The overflow lives in bit 11

    M_TITLE  DB 'When the sign flag is not the sign', 0DH, 0AH, 0DH, 0AH
             DB 'The sign flag is a copy of the top bit of the stored result. '
             DB 'When the', 0DH, 0AH
             DB 'overflow flag is set that bit is not the sign of the true '
             DB 'answer, and', 0DH, 0AH
             DB 'the sign has to be read as SF exclusive or OF.', 0DH, 0AH
             DB 0DH, 0AH, '$'
    M_HEAD   DB '     A       B  stored  SF  OF  true sign', 0DH, 0AH
             DB '------  ------  ------  --  --  ---------', 0DH, 0AH, '$'
    M_GAP    DB '  $'
    M_FGAP   DB '   $'
    M_SPACE  DB ' $'
    M_POS    DB '  positive', 0DH, 0AH, '$'
    M_NEG    DB '  negative', 0DH, 0AH, '$'

    M_CMP    DB 0DH, 0AH
             DB 'CMP 20000 with -20000 leaves the sign set and the overflow '
             DB 'set as well.', 0DH, 0AH, '$'
    M_JS_Y   DB '  JS is taken, so the sign flag alone calls 20000 the smaller.'
             DB 0DH, 0AH, '$'
    M_JS_N   DB '  JS is not taken.', 0DH, 0AH, '$'
    M_JL_Y   DB '  JL is taken.', 0DH, 0AH, '$'
    M_JL_N   DB '  JL is not taken, because JL asks whether SF and OF differ.'
             DB 0DH, 0AH, '$'
    M_CLOSE  DB 0DH, 0AH
             DB 'That difference is the whole reason the signed branches exist '
             DB 'apart from', 0DH, 0AH
             DB 'JS and JNS. JS reads one bit and JL reads the pair.', 0DH, 0AH, '$'

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
    CALL SHOW_FIELD
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, [SI+2]
    CALL SHOW_FIELD
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE FLAGS GO INTO BX AT ONCE. THE SUM IS PRINTED AFTERWARDS, AND EVERY
    ; DIVISION THAT PRINTING DOES WOULD OTHERWISE HAVE REPLACED THEM.
    ; -------------------------------------------------------------------------
    MOV AX, [SI]
    ADD AX, [SI+2]
    PUSHF
    POP BX

    CALL SHOW_FIELD

    ; ---- the sign flag, which is only the top bit ---------------------------
    LEA DX, M_FGAP
    CALL PRINT_MESSAGE
    MOV AX, BX
    AND AX, SF_MASK
    JZ  SIGN_CLEAR
    MOV AX, 1                           ; A flag prints as one column, not as a mask

SIGN_CLEAR:
    MOV DI, AX                          ; Held for the verdict below
    CALL PRINT_DECIMAL

    ; ---- the overflow flag, which says whether that bit can be trusted ------
    LEA DX, M_FGAP
    CALL PRINT_MESSAGE
    MOV AX, BX
    AND AX, OF_MASK
    JZ  OVER_CLEAR
    MOV AX, 1

OVER_CLEAR:
    XOR DI, AX                          ; An overflow inverts what the top bit said
    CALL PRINT_DECIMAL

    OR  DI, DI
    JNZ ROW_NEGATIVE
    LEA DX, M_POS
    JMP ROW_REPORT

ROW_NEGATIVE:
    LEA DX, M_NEG

ROW_REPORT:
    CALL PRINT_MESSAGE

    POP CX
    ADD SI, 4                           ; Two words to the next pair
    LOOP EACH_PAIR

    ; -------------------------------------------------------------------------
    ; THE SAME POINT AS A COMPARISON. THE FLAGS ARE SAVED ONCE AND RESTORED
    ; BEFORE EACH BRANCH, BECAUSE A BRANCH THAT IS NOT TAKEN STILL HAS TO SEE
    ; THE FLAGS THE COMPARISON LEFT AND NOT THE ONES PRINTING LEFT.
    ; -------------------------------------------------------------------------
    LEA DX, M_CMP
    CALL PRINT_MESSAGE

    MOV AX, BIG_POS
    CMP AX, BIG_NEG
    PUSHF
    POP BX

    PUSH BX
    POPF
    JS  SIGN_SAYS_LESS
    LEA DX, M_JS_N
    JMP SIGN_REPORT

SIGN_SAYS_LESS:
    LEA DX, M_JS_Y

SIGN_REPORT:
    CALL PRINT_MESSAGE

    PUSH BX
    POPF
    JL  LESS_SAYS_LESS
    LEA DX, M_JL_N
    JMP LESS_REPORT

LESS_SAYS_LESS:
    LEA DX, M_JL_Y

LESS_REPORT:
    CALL PRINT_MESSAGE

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_FIELD
;
; Prints AX as a signed value, right aligned in NUMBER_W columns.
;
; The width is measured before anything is printed, and the minus sign is
; counted as a column of its own. Padding after the number would push it to
; the left of the field instead.
; -----------------------------------------------------------------------------
SHOW_FIELD PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    MOV BX, AX                          ; The value, kept back for printing
    MOV CX, 1                           ; Every number occupies at least one column

    OR  AX, AX
    JNS SFD_COUNT                       ; Sign flag clear means not negative
    INC CX
    NEG AX                              ; The digits are those of the magnitude

SFD_COUNT:
    CMP AX, 10
    JB  SFD_PAD

    XOR DX, DX
    MOV DI, 10
    DIV DI
    INC CX
    JMP SFD_COUNT

SFD_PAD:
    MOV AX, NUMBER_W
    SUB AX, CX
    MOV CX, AX
    JCXZ SFD_VALUE                      ; A full width field needs no padding

SFD_SPACE:
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    LOOP SFD_SPACE

SFD_VALUE:
    MOV AX, BX
    CALL PRINT_SIGNED

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_FIELD ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE RULE IN ONE LINE:
;    - The true sign of a signed result is SF exclusive or OF. When no
;    - overflow happened the two agree with SF, and when one happened the
;    - stored top bit is the opposite of the answer.
; 2. WHY JL IS BUILT THAT WAY:
;    - JL is taken when SF and OF differ, JGE when they agree, and JG and
;    - JLE add the zero flag. None of them can be replaced by JS, which
;    - reads a single bit and has no way to know it was corrupted.
; 3. THE UNSIGNED SIDE HAS NO SUCH PROBLEM:
;    - An unsigned result has no sign bit to corrupt, so the carry alone
;    - settles the question and JB and JAE need nothing else.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
