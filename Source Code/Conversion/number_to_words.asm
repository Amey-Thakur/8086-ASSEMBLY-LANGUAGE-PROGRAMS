; =============================================================================
; TITLE: Writing a Number in Words
; DESCRIPTION: Spells a number below one thousand, which needs the teens
;              treated separately because they follow no pattern.
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
    SAMPLES DW 472, 15, 90, 907, 0
    HOWMANY EQU 5

    ; Each name is padded to a fixed width so the index can find it by
    ; multiplication rather than by walking a list of variable length strings.
    WIDTH   EQU 10

    UNITS   DB 'zero      one       two       three     four      '
            DB 'five      six       seven     eight     nine      '
    TEENS   DB 'ten       eleven    twelve    thirteen  fourteen  '
            DB 'fifteen   sixteen   seventeen eighteen  nineteen  '
    TENS    DB '          ten       twenty    thirty    forty     '
            DB 'fifty     sixty     seventy   eighty    ninety    '

    M_HUND  DB 'hundred $'
    M_IS    DB ' is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH:
    MOV AX, [SI]

    PUSH CX
    PUSH SI
    PUSH AX

    CALL PRINT_DECIMAL
    LEA DX, M_IS
    MOV AH, 09H
    INT 21H

    POP AX
    CALL SPELL
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SPELL
;
; Writes AX in words. Handles nought to 999.
; -----------------------------------------------------------------------------
SPELL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    OR  AX, AX
    JNZ SP_NOT_ZERO

    LEA SI, UNITS                       ; Nought is the one value with no parts
    MOV CX, WIDTH
    CALL PRINT_TEXT
    JMP SP_DONE

SP_NOT_ZERO:
    ; ---- the hundreds -------------------------------------------------------
    XOR DX, DX
    MOV BX, 100
    DIV BX                              ; AX = hundreds, DX = the rest
    MOV CX, DX                          ; Keep the remainder

    OR  AX, AX
    JZ  SP_TENS

    PUSH CX
    MOV BX, WIDTH
    MUL BX
    LEA SI, UNITS
    ADD SI, AX
    MOV CX, WIDTH
    CALL PRINT_TEXT
    LEA DX, M_HUND
    MOV AH, 09H
    INT 21H
    POP CX

SP_TENS:
    MOV AX, CX
    OR  AX, AX
    JZ  SP_DONE                         ; An exact hundred needs nothing more

    ; -------------------------------------------------------------------------
    ; TEN TO NINETEEN HAVE NAMES OF THEIR OWN THAT FOLLOW NO RULE, SO THEY ARE
    ; LOOKED UP WHOLE. EVERYTHING ELSE IS A TENS NAME AND PERHAPS A UNIT.
    ; -------------------------------------------------------------------------
    CMP AX, 10
    JB  SP_UNITS
    CMP AX, 19
    JA  SP_LARGER_TENS

    SUB AX, 10
    MOV BX, WIDTH
    MUL BX
    LEA SI, TEENS
    ADD SI, AX
    MOV CX, WIDTH
    CALL PRINT_TEXT
    JMP SP_DONE

SP_LARGER_TENS:
    XOR DX, DX
    MOV BX, 10
    DIV BX                              ; AX = tens digit, DX = units digit
    MOV CX, DX

    MOV BX, WIDTH
    MUL BX
    LEA SI, TENS
    ADD SI, AX
    PUSH CX
    MOV CX, WIDTH
    CALL PRINT_TEXT
    POP CX

    MOV AX, CX
    OR  AX, AX
    JZ  SP_DONE                         ; An exact ten needs no unit

SP_UNITS:
    MOV BX, WIDTH
    MUL BX
    LEA SI, UNITS
    ADD SI, AX
    MOV CX, WIDTH
    CALL PRINT_TEXT

SP_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SPELL ENDP

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. FIXED WIDTH NAMES:
;    - Padding every name to ten characters means the address of the nth
;    - name is the base plus ten times n. A list of variable length
;    - strings would have to be walked from the start every time.
; 2. THE TEENS ARE THE AWKWARD PART:
;    - Eleven and twelve follow no pattern at all, and thirteen to
;    - nineteen follow a different one from twenty to ninety. A separate
;    - table is shorter than any rule that would generate them.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
