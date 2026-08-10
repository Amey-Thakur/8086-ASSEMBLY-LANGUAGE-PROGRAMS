; =============================================================================
; TITLE: Filling a Buffer with REP STOSB
; DESCRIPTION: Clears a block of memory to a chosen byte, the fastest fill the
;              processor offers, and shows the word form for a two byte pattern.
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
    BUFFER  DB 20 DUP('?')
    OUT_BUF DB 24 DUP('$')
    M_FILL  DB 'Filled with dots: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; -------------------------------------------------------------------------
    ; STOSB WRITES AL TO ES:DI AND ADVANCES. WITH REP IN FRONT OF IT, ONE
    ; INSTRUCTION FILLS AS MANY BYTES AS CX SAYS.
    ; -------------------------------------------------------------------------
    LEA DI, BUFFER
    MOV CX, 20
    MOV AL, '.'
    CLD
    REP STOSB

    ; Copy it somewhere terminated so the print service can show it
    LEA SI, BUFFER
    LEA DI, OUT_BUF
    MOV CX, 20
    CLD
    REP MOVSB
    MOV BYTE PTR [DI], '$'

    LEA DX, M_FILL
    MOV AH, 09H
    INT 21H
    LEA DX, OUT_BUF
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. THE VALUE COMES FROM AL:
;    - STOSB has no operand. It always writes AL, always to ES:DI. That
;    - is what lets it be a single byte instruction.
; 2. STOSW FILLS WITH A PATTERN:
;    - The word form writes AX, so a two byte pattern such as 2020h fills
;    - twice as fast as the byte form doing the same job.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
