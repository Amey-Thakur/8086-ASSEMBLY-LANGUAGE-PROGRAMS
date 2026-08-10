; =============================================================================
; TITLE: Appending To A File
; DESCRIPTION: Opening a file leaves the position at the start, so appending means seeking to the end before writing.
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
    FILENAME DB 'LOG.TXT', 0
    LINE_1   DB 'first entry', 0DH, 0AH
    LEN_1    EQU $ - LINE_1
    LINE_2   DB 'second entry', 0DH, 0AH
    LEN_2    EQU $ - LINE_2
    LINE_3   DB 'third entry', 0DH, 0AH
    LEN_3    EQU $ - LINE_3
    BUFFER   DB 80 DUP (0)

    M_TITLE DB 'Appending, which needs a seek to the end first', 0DH, 0AH, '$'
    M_MADE  DB 'Created the log with the first entry.', 0DH, 0AH, '$'
    M_APP   DB 'Appended an entry, file is now $'
    M_LONG  DB ' bytes.', 0DH, 0AH, '$'
    M_ALL   DB 0DH, 0AH, 'The whole log read back:', 0DH, 0AH, '$'
    M_WARN  DB 0DH, 0AH
            DB 'Writing without the seek would have overwritten the start of '
            DB 'the file instead of adding to it.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- the log starts with one entry --------------------------------------
    LEA DX, FILENAME
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, LINE_1
    MOV CX, LEN_1
    MOV AH, 40H
    INT 21H

    MOV AH, 3EH
    INT 21H

    LEA DX, M_MADE
    CALL PRINT_MESSAGE

    ; ---- two appends --------------------------------------------------------
    LEA SI, LINE_2
    MOV CX, LEN_2
    CALL APPEND_BYTES

    LEA SI, LINE_3
    MOV CX, LEN_3
    CALL APPEND_BYTES

    ; -------------------------------------------------------------------------
    ; AND THE WHOLE THING READ BACK, WHICH IS THE ONLY HONEST CHECK THAT THE
    ; APPENDS WENT ON THE END RATHER THAN OVER THE TOP.
    ; -------------------------------------------------------------------------
    LEA DX, M_ALL
    CALL PRINT_MESSAGE

    MOV AX, 3D00H
    LEA DX, FILENAME
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, BUFFER
    MOV CX, 80
    MOV AH, 3FH
    INT 21H
    MOV BP, AX                          ; How many bytes came back

    MOV AH, 3EH
    INT 21H

    LEA SI, BUFFER
    MOV CX, BP
    CALL PRINT_TEXT

    LEA DX, M_WARN
    CALL PRINT_MESSAGE

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; APPEND_BYTES
;
; Adds CX bytes from DS:SI to the end of FILENAME and reports the new length.
;
; The order matters: open, seek to the end, write, close. Opening for writing
; does not move the position, so without the seek the write would land at zero.
; -----------------------------------------------------------------------------
APPEND_BYTES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV DI, CX                          ; Keep the count, CX is needed for the seek

    MOV AX, 3D01H                       ; Open for writing
    LEA DX, FILENAME
    INT 21H
    JC APPEND_DONE
    MOV BX, AX

    MOV AX, 4202H                       ; To the end
    XOR CX, CX
    XOR DX, DX
    INT 21H

    MOV DX, SI                          ; The bytes to add
    MOV CX, DI
    MOV AH, 40H
    INT 21H

    ; Measure again, so the report is taken from the file and not computed.
    MOV AX, 4202H
    XOR CX, CX
    XOR DX, DX
    INT 21H
    MOV SI, AX

    MOV AH, 3EH
    INT 21H

    LEA DX, M_APP
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_LONG
    CALL PRINT_MESSAGE

APPEND_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
APPEND_BYTES ENDP

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
; 1. Opening does not move to the end:
;    - Every open leaves the position at zero, whatever the mode.
;    - A write therefore overwrites from the start unless the position is moved first.
;    - DOS has no append mode; the seek is how appending is expressed.
; 2. Register pressure around the calls:
;    - The seek wants CX and DX for the offset; the write wants them for the count and address.
;    - So the count is parked in DI across the seek and restored afterwards.
;    - This kind of shuffling is why a file helper is worth writing once.
; 3. Measure rather than compute:
;    - The new length is read back with another seek instead of being added up.
;    - A short write would make the computed figure wrong and the measured one right.
;    - Trusting the file over the program is the habit worth forming.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
