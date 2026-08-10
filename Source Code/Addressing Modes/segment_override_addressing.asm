; =============================================================================
; TITLE: Segment Override Prefixes
; DESCRIPTION: Each addressing mode has a default segment, and a one byte prefix changes it when the default is not what is wanted.
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
    DATA_W  DW 1111, 2222, 3333, 4444
    SPARE   DW 0, 0, 0, 0

    M_TITLE DB 'Segment overrides: changing which segment a mode uses', 0DH, 0AH, '$'
    M_DS    DB 'DS:[BX] reads $'
    M_ES    DB 'ES:[BX] with ES = DS reads the same word: $'
    M_COPY  DB 'Copied to SPARE through ES: $'
    M_BP    DB '[BP] defaults to the stack and reads $'
    M_BPDS  DB 'DS:[BP] overrides that and reads $'
    M_COST  DB 'A prefix costs one byte and two clocks. The defaults are '
            DB 'chosen so most code needs none.', 0DH, 0AH, '$'
    M_SPACE DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; Both segment registers on the data

    LEA DX, M_TITLE

    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; WITH ES AND DS HOLDING THE SAME SEGMENT, THE OVERRIDE MAKES NO DIFFERENCE
    ; TO THE VALUE READ. THAT IS THE POINT: THE PREFIX SELECTS THE SEGMENT
    ; REGISTER, NOT THE OFFSET.
    ; -------------------------------------------------------------------------
    LEA BX, DATA_W

    MOV AX, [BX]
    LEA DX, M_DS
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, ES:[BX]
    LEA DX, M_ES
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A COPY WITH THE SOURCE THROUGH DS AND THE DESTINATION THROUGH ES IS THE
    ; ORDINARY USE OF THE PREFIX, AND IS WHAT THE STRING INSTRUCTIONS DO
    ; WITHOUT HAVING TO SAY SO.
    ; -------------------------------------------------------------------------
    LEA BX, DATA_W
    LEA DI, SPARE
    MOV CX, 4
COPY_WORD:
    MOV AX, [BX]
    MOV ES:[DI], AX
    ADD BX, 2
    ADD DI, 2
    LOOP COPY_WORD

    LEA DX, M_COPY

    CALL PRINT_MESSAGE
    LEA SI, SPARE
    MOV CX, 4
SHOW_SPARE:
    MOV AX, [SI]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP SHOW_SPARE
    CALL NEWLINE
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; BP IS THE INTERESTING CASE. IT DEFAULTS TO THE STACK, SO THE TWO READS
    ; BELOW USE THE SAME OFFSET AND FIND DIFFERENT THINGS: ONE THE WORD JUST
    ; PUSHED, THE OTHER WHATEVER LIVES AT THAT OFFSET IN THE DATA SEGMENT.
    ; -------------------------------------------------------------------------
    MOV AX, 9999
    PUSH AX
    MOV BP, SP

    MOV AX, [BP]
    LEA DX, M_BP
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV BP, OFFSET DATA_W               ; A data offset this time
    MOV AX, DS:[BP]
    LEA DX, M_BPDS
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    POP AX
    LEA DX, M_COST
    CALL PRINT_MESSAGE

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
; 1. The default for each mode:
;    - A direct address, [BX], [SI] and [DI] use DS.
;    - [BP] and anything through SP uses SS.
;    - A string destination through DI uses ES, and instruction fetch always uses CS.
; 2. What the prefix actually is:
;    - One byte in front of the instruction: 26H for ES, 2EH for CS, 36H for SS, 3EH for DS.
;    - It changes the segment register the address adder uses and nothing else.
;    - The offset calculation is untouched, which is why ES:[BX] and [BX] agree when ES equals DS.
; 3. Where it is unavoidable:
;    - A destination in ES while the source is in DS, as in any buffer copy.
;    - Reading a constant out of the code segment with CS:.
;    - Reaching data at a BP based offset, which needs DS: to escape the stack default.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
