; =============================================================================
; TITLE: Reading a Line with Service 0Ah
; DESCRIPTION: Reads a whole line into a buffer, using the three part
;              descriptor the service expects.
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
    ; The buffer is not a plain array. The first byte says how much room the
    ; program is offering, the second is filled in by DOS with how much was
    ; actually typed, and the text follows from the third byte onward. The
    ; three have to be declared adjacent, in this order.
    MAXLEN   DB 30                      ; What we are offering
    GOTLEN   DB 0                       ; What DOS reports
    TEXT     DB 30 DUP('$')

    M_ASK    DB 'Type something and press Enter: $'
    M_GOT    DB 0DH, 0AH, 'You typed $'
    M_CHARS  DB ' characters: $'
    CRLF     DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ASK
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; DX POINTS AT THE DESCRIPTOR, NOT AT THE TEXT. POINTING IT AT THE TEXT IS
    ; THE USUAL MISTAKE, AND IT MAKES DOS READ THE FIRST CHARACTER OF WHATEVER
    ; IS THERE AS THE BUFFER SIZE.
    ; -------------------------------------------------------------------------
    LEA DX, MAXLEN
    MOV AH, 0AH
    INT 21H

    LEA DX, M_GOT
    MOV AH, 09H
    INT 21H

    MOV AL, GOTLEN
    XOR AH, AH
    PUSH AX
    CALL PRINT_DECIMAL

    LEA DX, M_CHARS
    MOV AH, 09H
    INT 21H

    POP CX
    LEA SI, TEXT
    CALL PRINT_TEXT

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

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
; 1. THE THREE PARTS MUST BE ADJACENT:
;    - DOS finds the count at one byte past the descriptor and the text at
;    - two. Declaring them as separate variables works only because the
;    - assembler lays them out in the order they are written.
; 2. THE RETURN IS STORED TOO:
;    - A carriage return is written after the text, and it is not counted
;    - in the length. A program that prints the buffer without using the
;    - length prints that return as well.
; 3. THE CAPACITY IS ENFORCED:
;    - DOS refuses further characters once the buffer is full, so this is
;    - the safe way to read a line. Reading character by character without
;    - a bound is how buffers are overrun.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
