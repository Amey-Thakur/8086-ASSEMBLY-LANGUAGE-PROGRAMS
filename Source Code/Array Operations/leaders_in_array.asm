; =============================================================================
; TITLE: Elements Larger Than Everything After Them
; DESCRIPTION: Finds the leaders of an array by scanning from the right, which
;              turns a quadratic problem into one pass.
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
    DATA_W  DW 16, 17, 4, 3, 5, 2
    HOWMANY EQU 6

    FOUND   DW HOWMANY DUP(0)
    COUNT   DW 0

    M_ARRAY DB 'The array:   $'
    M_LEAD  DB 'The leaders: $'

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
    ; A LEADER IS AN ELEMENT LARGER THAN EVERY ELEMENT TO ITS RIGHT. SCANNING
    ; FROM THE LEFT WOULD MEAN LOOKING AT THE WHOLE TAIL FOR EACH ONE.
    ; SCANNING FROM THE RIGHT, THE LARGEST SEEN SO FAR IS EXACTLY WHAT EACH
    ; ELEMENT HAS TO BEAT, SO ONE PASS ANSWERS IT.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    ADD SI, (HOWMANY - 1) * 2           ; The last element
    MOV BX, 0                           ; The largest seen to the right
    MOV CX, HOWMANY

SCAN:
    MOV AX, [SI]

    CMP AX, BX
    JBE NOT_A_LEADER

    ; It is a leader: remember it and raise the bar
    MOV DI, COUNT
    SHL DI, 1
    MOV FOUND[DI], AX
    INC WORD PTR COUNT
    MOV BX, AX

NOT_A_LEADER:
    SUB SI, 2
    LOOP SCAN

    ; -------------------------------------------------------------------------
    ; THEY WERE FOUND FROM THE RIGHT, SO THEY ARE IN REVERSE ORDER. REVERSING
    ; THE LIST PUTS THEM BACK INTO THE ORDER THEY APPEAR IN THE ARRAY.
    ; -------------------------------------------------------------------------
    LEA SI, FOUND
    MOV CX, COUNT
    CALL REVERSE_RUN

    LEA DX, M_LEAD
    MOV AH, 09H
    INT 21H
    LEA SI, FOUND
    MOV CX, COUNT
    CALL SHOW_RUN

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; REVERSE_RUN
; -----------------------------------------------------------------------------
REVERSE_RUN PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    CMP CX, 1
    JBE RR_DONE

    MOV DI, SI
    ADD DI, CX
    ADD DI, CX
    SUB DI, 2
    SHR CX, 1

RR_SWAP:
    MOV AX, [SI]
    MOV BX, [DI]
    MOV [SI], BX
    MOV [DI], AX
    ADD SI, 2
    SUB DI, 2
    LOOP RR_SWAP

RR_DONE:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
REVERSE_RUN ENDP

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
; 1. THE DIRECTION IS THE ALGORITHM:
;    - From the left, each element needs the whole tail examined. From the
;    - right, one running maximum already summarises the tail. Nothing
;    - else changes.
; 2. THE LAST ELEMENT IS ALWAYS A LEADER:
;    - It has nothing to its right, so it beats everything there vacuously.
;    - Starting the running maximum at nought makes that fall out
;    - automatically for positive data.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
