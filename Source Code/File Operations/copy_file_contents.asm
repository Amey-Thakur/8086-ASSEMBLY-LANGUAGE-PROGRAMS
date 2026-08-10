; =============================================================================
; TITLE: Copying One File To Another
; DESCRIPTION: Reads a block, writes a block, and stops when the read comes back short, which is the only reliable end of file test.
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
    SOURCE_N DB 'ORIGIN.TXT', 0
    TARGET_N DB 'COPY.TXT', 0

    CONTENT  DB 'Alpha Bravo Charlie Delta Echo Foxtrot Golf Hotel India'
    SPAN     EQU $ - CONTENT

    CHUNK   EQU 16                      ; Deliberately smaller than the file
    BUFFER  DB CHUNK DUP (0)
    CHECK   DB 80 DUP (0)

    M_TITLE DB 'Copying a file sixteen bytes at a time', 0DH, 0AH, '$'
    M_MADE  DB 'Source written, $'
    M_BYTES DB ' bytes.', 0DH, 0AH, '$'
    M_BLOCK DB 'block $'
    M_GOT   DB ': read $'
    M_PUT   DB ', wrote $'
    M_NL    DB 0DH, 0AH, '$'
    M_DONE  DB 0DH, 0AH, 'Copy finished. Blocks: $'
    M_TOTAL DB 'Bytes copied: $'
    M_SAME  DB 0DH, 0AH, 'The copy reads back identical to the source.', 0DH, 0AH, '$'
    M_DIFF  DB 0DH, 0AH, 'The copy differs from the source.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'A read returning fewer bytes than asked for is the end of the '
            DB 'file. There is no separate flag for it.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- something to copy --------------------------------------------------
    LEA DX, SOURCE_N
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

    MOV AH, 3EH
    INT 21H

    LEA DX, M_MADE
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; BOTH FILES ARE HELD OPEN AT ONCE, SO TWO HANDLES ARE IN PLAY: SI FOR THE
    ; SOURCE AND DI FOR THE TARGET. BX IS RELOADED FROM WHICHEVER IS WANTED,
    ; BECAUSE EVERY SERVICE TAKES ITS HANDLE THERE.
    ; -------------------------------------------------------------------------
    MOV AX, 3D00H
    LEA DX, SOURCE_N
    INT 21H
    JC FINISHED
    MOV SI, AX                          ; Source handle

    LEA DX, TARGET_N
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    JC FINISHED
    MOV DI, AX                          ; Target handle

    XOR BP, BP                          ; Bytes copied

    MOV CX, 1                           ; Block number, counted up
COPY_BLOCK:
    PUSH CX

    ; ---- read from the source -----------------------------------------------
    MOV BX, SI
    LEA DX, BUFFER
    MOV CX, CHUNK
    MOV AH, 3FH
    INT 21H
    JC COPY_ENDED

    MOV CX, AX                          ; How many actually came back
    JCXZ COPY_ENDED                      ; Nothing left at all

    LEA DX, M_BLOCK
    CALL PRINT_MESSAGE
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    LEA DX, M_GOT
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL

    ; ---- write exactly that many to the target ------------------------------
    MOV BX, DI
    LEA DX, BUFFER
    MOV AH, 40H
    INT 21H

    ADD BP, AX
    LEA DX, M_PUT
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    LEA DX, M_NL
    CALL PRINT_MESSAGE

    ; A short read means the file ended with this block.
    CMP CX, CHUNK
    JB COPY_ENDED

    POP CX
    INC CX
    JMP COPY_BLOCK

COPY_ENDED:
    POP CX

    MOV BX, SI
    MOV AH, 3EH
    INT 21H
    MOV BX, DI
    MOV AH, 3EH
    INT 21H

    LEA DX, M_DONE
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; AND THE COPY IS COMPARED AGAINST THE ORIGINAL RATHER THAN ASSUMED GOOD.
    ; -------------------------------------------------------------------------
    MOV AX, 3D00H
    LEA DX, TARGET_N
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, CHECK
    MOV CX, 80
    MOV AH, 3FH
    INT 21H
    MOV BP, AX

    MOV AH, 3EH
    INT 21H

    CMP BP, SPAN
    JNE NOT_THE_SAME

    LEA SI, CONTENT
    LEA DI, CHECK
    MOV CX, SPAN
    CLD
    REPE CMPSB
    JNE NOT_THE_SAME

    LEA DX, M_SAME
    CALL PRINT_MESSAGE
    JMP EXPLAIN

NOT_THE_SAME:
    LEA DX, M_DIFF
    CALL PRINT_MESSAGE

EXPLAIN:
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
; 1. A short read is the end of file:
;    - Asking for sixteen and getting nine means nine were left.
;    - Asking again then returns zero, which is the other way to see it.
;    - There is no end of file flag; the count is the only signal.
; 2. Write what was read, not what was asked:
;    - The write count comes from the read result, not from the buffer size.
;    - Writing the full buffer would append rubbish from the previous block.
;    - This is the single commonest bug in a hand written copy loop.
; 3. Two handles at once:
;    - Both files stay open, so both handles have to be kept somewhere.
;    - Every service takes its handle in BX, which is reloaded before each call.
;    - Losing track of which is which writes the source over the target.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
