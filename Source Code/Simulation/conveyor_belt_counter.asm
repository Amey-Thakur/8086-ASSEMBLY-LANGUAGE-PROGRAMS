; =============================================================================
; TITLE: Conveyor Belt Batch Counter
; DESCRIPTION: Counts items past a sensor and signals a full box every time a batch is complete, keeping the remainder.
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
    DISPLAY_PORT EQU 199

    BATCH   EQU 12                      ; Items to a box

    ; One byte per moment: 1 means an item broke the beam.
    BEAM    DB 1,0,1,1,0,1,1,1,0,1,1,0,1,1,1,0,1,1,0,1,1,1,0,1,1,0,1,1,1,0
    MOMENTS EQU 30

    M_TITLE DB 'Counting items into boxes of twelve', 0DH, 0AH, '$'
    M_BOX   DB 'box $'
    M_FULL  DB ' full at moment $'
    M_TOTAL DB 0DH, 0AH, 'Items counted:   $'
    M_BOXES DB 'Boxes filled:    $'
    M_REST  DB 'Left in the last: $'
    M_WHY   DB 0DH, 0AH
            DB 'The remainder is kept rather than discarded, so the next shift '
            DB 'continues the part filled box.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; BX COUNTS ITEMS IN THE CURRENT BOX, BP COUNTS BOXES AND DI COUNTS ITEMS
    ; ALTOGETHER. SI WALKS THE SENSOR RECORD.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    XOR BX, BX                          ; In the current box
    XOR BP, BP                          ; Boxes finished
    XOR DI, DI                          ; Items in total
    MOV CX, MOMENTS

EACH_MOMENT:
    CMP BEAM[SI], 1
    JNE NO_ITEM

    INC BX
    INC DI

    ; ---- the display always shows the current box ---------------------------
    MOV AX, BX
    OUT DISPLAY_PORT, AL

    CMP BX, BATCH
    JB NO_ITEM

    ; ---- a full box ---------------------------------------------------------
    INC BP
    XOR BX, BX                          ; Start the next one empty

    LEA DX, M_BOX
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_FULL
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

NO_ITEM:
    INC SI
    LOOP EACH_MOMENT

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_BOXES
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_REST
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WHY
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
; 1. Three counters, three questions:
;    - Items in the current box decides when to signal a full one.
;    - Boxes finished is the production figure.
;    - Items in total is the audit figure, and must equal boxes times batch plus remainder.
; 2. Reset the small counter, not the large:
;    - The per box count goes back to zero; the totals never do.
;    - Clearing the wrong one silently loses the whole shift figure.
;    - The final line proves it: 21 items is one box of twelve with nine over.
; 3. A level, not an edge:
;    - This record has one entry per item, so counting the ones is enough.
;    - A real beam stays broken while an item passes, giving many samples per item.
;    - That needs edge detection: count only where this sample is set and the last was clear.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
