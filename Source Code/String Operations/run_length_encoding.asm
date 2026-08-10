; =============================================================================
; TITLE: Run Length Encoding
; DESCRIPTION: Compresses a string by replacing each run of repeated
;              characters with the character and its count, then expands it again.
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
    SOURCE  DB 'AAABBBBCCCCCCDDAAE'
    SRCLEN  EQU $ - SOURCE
    CODED   DB 40 DUP(0)
    CODEDLEN DW 0
    M_IN    DB 'Input:    $'
    M_OUT   DB 'Encoded:  $'
    M_SIZE  DB 'Encoded length: $'
    M_FROM  DB ', from $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H
    LEA SI, SOURCE
    MOV CX, SRCLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; WALK THE STRING COUNTING HOW LONG EACH RUN OF EQUAL CHARACTERS IS, AND
    ; WRITE THE CHARACTER FOLLOWED BY THE COUNT AS A DIGIT. A RUN LONGER THAN
    ; NINE IS BROKEN INTO SEVERAL, WHICH KEEPS THE OUTPUT ONE BYTE PER COUNT.
    ; -------------------------------------------------------------------------
    LEA SI, SOURCE
    LEA DI, CODED
    MOV CX, SRCLEN

ENCODE:
    JCXZ ENCODE_DONE

    MOV AL, [SI]                        ; The character this run is made of
    MOV BL, 0                           ; How long the run is

MEASURE:
    CMP CX, 0
    JE  EMIT_RUN
    CMP AL, [SI]
    JNE EMIT_RUN
    CMP BL, 9
    JAE EMIT_RUN                        ; Nine is as long as one digit allows

    INC BL
    INC SI
    DEC CX
    JMP MEASURE

EMIT_RUN:
    MOV [DI], AL                        ; The character
    INC DI
    MOV DL, BL
    ADD DL, '0'                         ; The count, as a digit
    MOV [DI], DL
    INC DI
    ADD WORD PTR CODEDLEN, 2
    JMP ENCODE

ENCODE_DONE:
    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA SI, CODED
    MOV CX, CODEDLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    LEA DX, M_SIZE
    MOV AH, 09H
    INT 21H
    MOV AX, CODEDLEN
    CALL PRINT_DECIMAL
    LEA DX, M_FROM
    MOV AH, 09H
    INT 21H
    MOV AX, SRCLEN
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. WHEN IT MAKES THINGS BIGGER:
;    - A string with no repeats becomes twice its length, because every
;    - character gains a count of one. Run length encoding is only worth
;    - applying to data that actually has runs.
; 2. THE NINE LIMIT:
;    - Keeping the count to a single digit means a run of twelve is
;    - emitted as nine and then three. A binary count byte would allow
;    - 255 but the output would no longer be readable text.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
