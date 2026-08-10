; =============================================================================
; TITLE: Reading A File In Chunks And Counting It
; DESCRIPTION: A buffer smaller than the file, read repeatedly until it empties, counting lines and words on the way through.
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
    FILENAME DB 'REPORT.TXT', 0

    CONTENT  DB 'the first line here', 0DH, 0AH
             DB 'a second line', 0DH, 0AH
             DB 'and the third and last', 0DH, 0AH
    SPAN     EQU $ - CONTENT

    CHUNK   EQU 10                      ; Small on purpose
    BUFFER  DB CHUNK DUP (0)

    LINES_W DW 0
    WORDS_W DW 0
    CHARS_W DW 0
    INWORD  DB 0                        ; 1 while inside a word

    M_TITLE DB 'Counting a file with a buffer smaller than it is', 0DH, 0AH, '$'
    M_MADE  DB 'Wrote $'
    M_BYTES DB ' bytes to REPORT.TXT.', 0DH, 0AH, '$'
    M_CHUNK DB 'Buffer size: 10 bytes', 0DH, 0AH, '$'
    M_READS DB 0DH, 0AH, 'Reads performed: $'
    M_CHARS DB 'Characters:      $'
    M_LINES DB 'Lines:           $'
    M_WORDS DB 'Words:           $'
    M_CHECK DB 0DH, 0AH, 'Characters counted match the bytes written.', 0DH, 0AH, '$'
    M_BAD   DB 0DH, 0AH, 'Character count does not match.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'The word state has to survive between reads, because a word may '
            DB 'be split across two buffers.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- lay the file down --------------------------------------------------
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

    MOV AH, 3EH
    INT 21H

    LEA DX, M_MADE
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    CALL PRINT_MESSAGE
    LEA DX, M_CHUNK
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE COUNTING LOOP. DI COUNTS THE READS. THE THREE TOTALS AND THE WORD
    ; STATE ARE IN MEMORY RATHER THAN IN REGISTERS, BECAUSE THE DOS CALLS IN
    ; THE MIDDLE OF THE LOOP WOULD NOT LEAVE ENOUGH REGISTERS FREE.
    ; -------------------------------------------------------------------------
    MOV AX, 3D00H
    LEA DX, FILENAME
    INT 21H
    JC FINISHED
    MOV BP, AX                          ; The handle, kept out of the way

    XOR DI, DI                          ; Reads performed

NEXT_CHUNK:
    MOV BX, BP
    LEA DX, BUFFER
    MOV CX, CHUNK
    MOV AH, 3FH
    INT 21H
    JC READING_DONE

    INC DI
    MOV CX, AX                          ; Bytes in this chunk
    JCXZ READING_DONE

    PUSH CX
    LEA SI, BUFFER
    CALL COUNT_BUFFER
    POP CX

    ; A short read means that was the last chunk.
    CMP CX, CHUNK
    JB READING_DONE
    JMP NEXT_CHUNK

READING_DONE:
    MOV BX, BP
    MOV AH, 3EH
    INT 21H

    ; -------------------------------------------------------------------------
    ; A WORD LEFT OPEN AT THE END OF THE FILE STILL COUNTS. FORGETTING THIS
    ; UNDERCOUNTS BY ONE ON ANY FILE NOT ENDING IN WHITESPACE.
    ; -------------------------------------------------------------------------
    CMP INWORD, 1
    JNE REPORT
    INC WORDS_W
    MOV INWORD, 0

REPORT:
    LEA DX, M_READS
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_CHARS
    CALL PRINT_MESSAGE
    MOV AX, CHARS_W
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_LINES
    CALL PRINT_MESSAGE
    MOV AX, LINES_W
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WORDS
    CALL PRINT_MESSAGE
    MOV AX, WORDS_W
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, CHARS_W
    CMP AX, SPAN
    JNE COUNT_BAD

    LEA DX, M_CHECK
    CALL PRINT_MESSAGE
    JMP EXPLAIN

COUNT_BAD:
    LEA DX, M_BAD
    CALL PRINT_MESSAGE

EXPLAIN:
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; COUNT_BUFFER
;
; Adds the CX characters at DS:SI into the running totals.
;
; INWORD carries the word state across calls, which is what makes a word split
; between two buffers count once rather than twice.
; -----------------------------------------------------------------------------
COUNT_BUFFER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

EACH_CHARACTER:
    MOV AL, [SI]
    INC SI
    INC CHARS_W

    CMP AL, 0AH                         ; Line feed ends a line
    JNE NOT_NEWLINE
    INC LINES_W

NOT_NEWLINE:
    ; ---- is this character part of a word? ----------------------------------
    CMP AL, ' '
    JE IS_SPACE
    CMP AL, 0DH
    JE IS_SPACE
    CMP AL, 0AH
    JE IS_SPACE
    CMP AL, 09H
    JE IS_SPACE

    ; Not a space. A word starts here only if one was not already open.
    CMP INWORD, 1
    JE CHARACTER_DONE
    MOV INWORD, 1
    INC WORDS_W
    JMP CHARACTER_DONE

IS_SPACE:
    MOV INWORD, 0

CHARACTER_DONE:
    LOOP EACH_CHARACTER

    POP SI
    POP CX
    POP BX
    POP AX
    RET
COUNT_BUFFER ENDP

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
; 1. State must outlive the buffer:
;    - A word can begin in one chunk and end in the next.
;    - INWORD lives in memory so the two halves count as one word.
;    - Resetting it per chunk would count every split word twice.
; 2. Count line feeds, not carriage returns:
;    - A DOS line ends with both characters, so counting either alone would work here.
;    - Counting both would double the answer.
;    - The line feed is the safer choice, because a file from another system may lack the return.
; 3. The final word:
;    - A file not ending in whitespace leaves a word open when the reading stops.
;    - Closing it after the loop is what makes the count right.
;    - This file does end in a newline, so the check confirms the loop rather than the fix.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
