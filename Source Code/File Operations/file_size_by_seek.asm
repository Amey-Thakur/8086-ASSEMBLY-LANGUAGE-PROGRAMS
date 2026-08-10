; =============================================================================
; TITLE: Finding A File Size By Seeking
; DESCRIPTION: Seeking to the end with an offset of zero returns the length, which is the standard way to measure a file.
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
    FILENAME DB 'MEASURE.DAT', 0
    CONTENT  DB 'Twenty-six letters: abcdefghijklmnopqrstuvwxyz'
    SPAN     EQU $ - CONTENT

    M_TITLE DB 'Measuring a file with service 42h', 0DH, 0AH, '$'
    M_WROTE DB 'Wrote $'
    M_BYTES DB ' bytes.', 0DH, 0AH, '$'
    M_SIZE  DB 'Seek to the end returned $'
    M_HIGH  DB 'The high word of the position: $'
    M_AGREE DB 'It agrees with what was written.', 0DH, 0AH, '$'
    M_DISAG DB 'It does not agree.', 0DH, 0AH, '$'
    M_BACK  DB 0DH, 0AH, 'Seeking back to the start returned $'
    M_MID   DB 'Seeking to the middle returned $'
    M_WHY   DB 0DH, 0AH
            DB 'The position is a thirty-two bit number in DX and AX, because a '
            DB 'file may be longer than 65535 bytes.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- make a file of a known length --------------------------------------
    LEA DX, FILENAME
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, CONTENT
    MOV CX, SPAN
    MOV AH, 40H
    INT 21H
    MOV SI, AX

    LEA DX, M_WROTE
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE MEASUREMENT. AL = 2 MEANS FROM THE END, AND CX:DX = 0 MEANS NO FURTHER
    ; OFFSET, SO THE POSITION RETURNED IS THE LENGTH. THE ANSWER COMES BACK IN
    ; DX:AX, HIGH WORD IN DX.
    ; -------------------------------------------------------------------------
    MOV AX, 4202H                       ; 42h, from the end
    XOR CX, CX
    XOR DX, DX
    INT 21H
    JC FINISHED

    MOV SI, AX                          ; Low word of the size
    MOV DI, DX                          ; High word

    LEA DX, M_SIZE
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_HIGH
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; ---- and it is checked, not merely printed ------------------------------
    CMP SI, SPAN
    JNE SIZE_WRONG
    CMP DI, 0
    JNE SIZE_WRONG

    LEA DX, M_AGREE
    CALL PRINT_MESSAGE
    JMP SEEK_AROUND

SIZE_WRONG:
    LEA DX, M_DISAG
    CALL PRINT_MESSAGE

SEEK_AROUND:
    ; -------------------------------------------------------------------------
    ; ORIGIN 0 IS FROM THE START, SO SEEKING TO ZERO REWINDS. THIS IS WHAT A
    ; PROGRAM DOES AFTER MEASURING, BECAUSE THE MEASUREMENT LEFT THE POSITION
    ; AT THE END WHERE A READ WOULD RETURN NOTHING.
    ; -------------------------------------------------------------------------
    MOV AX, 4200H
    XOR CX, CX
    XOR DX, DX
    INT 21H

    MOV SI, AX
    LEA DX, M_BACK
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 4200H
    XOR CX, CX
    MOV DX, 20
    INT 21H

    MOV SI, AX
    LEA DX, M_MID
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 3EH
    INT 21H

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

FINISHED:
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
; 1. Why seek and not a size service:
;    - The handle services have no call that asks for a length directly.
;    - Seeking to the end returns the position, which for the end is the length.
;    - The file control block interface had a size field, but handles replaced it.
; 2. Thirty-two bits in two registers:
;    - The offset goes in CX:DX and the result comes back in DX:AX, high word first.
;    - A file over 65535 bytes needs the high word, so it cannot be ignored.
;    - Checking DX for zero is how a program confirms the size fits in one word.
; 3. Measuring moves the position:
;    - After seeking to the end a read returns nothing at all.
;    - The rewind is not optional; it is part of the measurement.
;    - Forgetting it produces a program that reads an empty file it just measured as full.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
