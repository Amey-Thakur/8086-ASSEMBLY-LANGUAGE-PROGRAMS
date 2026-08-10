; =============================================================================
; TITLE: Reading Bytes with LODSB
; DESCRIPTION: Walks a string one byte at a time with LODSB, converting each
;              letter to upper case as it passes.
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
    TEXT    DB 'amey thakur 2022'
    LENGTH  EQU 16
    RESULT  DB 17 DUP('$')
    M_IN    DB 'Input:  $'
    M_OUT   DB 'Upper:  $'
    SOURCE  DB 'amey thakur 2022$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H
    LEA DX, SOURCE
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; LODSB AND STOSB TOGETHER MAKE A TRANSFORMING COPY: ONE BRINGS A BYTE IN
    ; THROUGH AL, THE OTHER WRITES IT OUT, AND WHATEVER HAPPENS IN BETWEEN IS
    ; THE TRANSFORMATION. REP CANNOT BE USED, BECAUSE WORK HAPPENS PER BYTE.
    ; -------------------------------------------------------------------------
    LEA SI, TEXT
    LEA DI, RESULT
    MOV CX, LENGTH
    CLD

CONVERT_LOOP:
    LODSB                               ; AL = [SI], SI advances

    CMP AL, 'a'
    JB  STORE_IT
    CMP AL, 'z'
    JA  STORE_IT
    SUB AL, 32                          ; The gap between the two cases

STORE_IT:
    STOSB                               ; [DI] = AL, DI advances
    LOOP CONVERT_LOOP

    MOV BYTE PTR [DI], '$'

    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA DX, RESULT
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
; 1. WHY 32 CONVERTS THE CASE:
;    - 'a' is 61h and 'A' is 41h. The two cases differ by exactly one bit,
;    - so subtracting 32 or clearing bit five does the same job.
; 2. THE RANGE CHECK MATTERS:
;    - Subtracting 32 from a digit or a space would corrupt it. Only the
;    - letters are adjusted, which is why both bounds are tested.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
