; =============================================================================
; TITLE: The Second Largest Element
; DESCRIPTION: Finds the largest and the next largest in a single pass, keeping
;              both as it goes rather than sorting or scanning twice.
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
    DATA_W  DW 14, 92, 37, 92, 65, 8, 71
    HOWMANY EQU 7

    M_ARRAY DB 'The array:      $'
    M_FIRST DB 'Largest:        $'
    M_SECOND DB 'Second largest: $'
    M_NONE  DB 'every element is the same', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ARRAY
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; TWO VALUES ARE CARRIED: THE BEST SO FAR AND THE BEST OF THE REST. WHEN A
    ; NEW LARGEST ARRIVES THE OLD ONE BECOMES THE SECOND, WHICH IS WHY THE
    ; ORDER OF THOSE TWO ASSIGNMENTS MATTERS.
    ;
    ; A VALUE EQUAL TO THE LARGEST IS DELIBERATELY IGNORED, SO THE 92 THAT
    ; APPEARS TWICE DOES NOT BECOME ITS OWN RUNNER UP.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    MOV BX, 0                           ; The largest
    MOV DI, 0                           ; The second largest
    MOV BP, 0                           ; Whether a second was ever found
    MOV CX, HOWMANY

SCAN:
    MOV AX, [SI]

    CMP AX, BX
    JBE NOT_A_NEW_BEST

    MOV DI, BX                          ; The old best is now the second
    MOV BX, AX
    CMP DI, 0
    JE  NO_SECOND_YET
    MOV BP, 1

NO_SECOND_YET:
    JMP NEXT

NOT_A_NEW_BEST:
    CMP AX, BX
    JE  NEXT                            ; A tie with the largest is not second
    CMP AX, DI
    JBE NEXT

    MOV DI, AX
    MOV BP, 1

NEXT:
    ADD SI, 2
    LOOP SCAN

    LEA DX, M_FIRST
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    OR  BP, BP
    JZ  ALL_EQUAL

    LEA DX, M_SECOND
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP FINISHED

ALL_EQUAL:
    LEA DX, M_SECOND
    MOV AH, 09H
    INT 21H
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

FINISHED:
    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

SR_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_SIGNED
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX

    ADD SI, 2
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONE PASS, NOT TWO:
;    - Finding the largest and then scanning again for the largest of the
;    - rest reads the array twice. Carrying both answers reads it once.
; 2. THE DUPLICATE IS THE INTERESTING CASE:
;    - With 92 appearing twice, a careless version reports 92 as both the
;    - largest and the second largest. Skipping a value equal to the best
;    - is what makes 71 the right answer.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
