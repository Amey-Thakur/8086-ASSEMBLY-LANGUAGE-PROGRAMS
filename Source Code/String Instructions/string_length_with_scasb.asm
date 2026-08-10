; =============================================================================
; TITLE: Measuring a String with SCASB
; DESCRIPTION: Finds the length of a terminated string by scanning for the
;              terminator, without knowing the length in advance.
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
    TEXT    DB 'Microprocessor and Microcontroller', 0
    M_LEN   DB 'The string is $'
    M_TAIL  DB ' characters long', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; -------------------------------------------------------------------------
    ; THE LENGTH IS NOT KNOWN, SO CX IS SET TO A CEILING RATHER THAN A COUNT.
    ; THE SEARCH IS FOR THE ZERO BYTE, AND WHAT IS LEFT IN CX SAYS HOW FAR IT
    ; GOT BEFORE FINDING IT.
    ; -------------------------------------------------------------------------
    LEA DI, TEXT
    MOV CX, 0FFFFH                      ; A limit, not a length
    XOR AL, AL                          ; Looking for the terminator
    CLD
    REPNE SCASB

    ; -------------------------------------------------------------------------
    ; CX COUNTED DOWN FROM FFFFH, SO THE NUMBER EXAMINED IS FFFFH LESS WHAT
    ; REMAINS. ONE COMES OFF AGAIN BECAUSE THE TERMINATOR ITSELF IS NOT PART
    ; OF THE STRING.
    ; -------------------------------------------------------------------------
    MOV AX, 0FFFFH
    SUB AX, CX
    DEC AX
    MOV BX, AX

    LEA DX, M_LEN
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. A CEILING GUARDS AGAINST A MISSING TERMINATOR:
;    - Without a limit in CX the scan would run through the whole segment
;    - if the zero byte were ever left out. FFFFh is the largest sensible
;    - bound, and a real routine would use the buffer size instead.
; 2. THIS IS HOW STRLEN WORKS:
;    - The C library routine of the same name does exactly this, and on
;    - this processor it compiles to very nearly these instructions.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
