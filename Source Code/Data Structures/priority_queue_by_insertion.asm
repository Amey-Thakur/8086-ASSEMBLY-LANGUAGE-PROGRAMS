; =============================================================================
; TITLE: A Priority Queue
; DESCRIPTION: Keeps its contents in order as they arrive, so the most urgent
;              item is always the one at the front.
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
    CAPACITY EQU 8
    QUEUE    DW CAPACITY DUP(0)
    COUNT    DW 0

    M_ADD    DB 'arrives $'
    M_TAKE   DB 'serving $'
    M_STATE  DB '   waiting: $'
    M_EMPTY  DB 'nobody is waiting', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, 5
    CALL ADMIT
    MOV AX, 1
    CALL ADMIT
    MOV AX, 9
    CALL ADMIT
    MOV AX, 3
    CALL ADMIT

    CALL SERVE
    CALL SERVE
    CALL SERVE
    CALL SERVE
    CALL SERVE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; ADMIT
;
; Inserts AX so that the queue stays in order, smallest first.
; -----------------------------------------------------------------------------
ADMIT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, COUNT
    CMP CX, CAPACITY
    JAE AD_DONE

    ; -------------------------------------------------------------------------
    ; WALK BACK FROM THE END, MOVING EVERY ITEM LESS URGENT THAN THIS ONE UP
    ; A PLACE, AND DROP IT INTO THE GAP. THE COST IS PAID ON ARRIVAL SO THAT
    ; SERVING IS FREE, WHICH IS THE RIGHT TRADE WHEN THINGS ARE SERVED MORE
    ; OFTEN THAN THEY ARRIVE.
    ; -------------------------------------------------------------------------
    MOV BX, CX
    SHL BX, 1                           ; One past the last item

AD_SLIDE:
    CMP BX, 0
    JE  AD_PLACE

    MOV DX, QUEUE[BX-2]
    CMP DX, AX
    JBE AD_PLACE                        ; Found where it belongs

    MOV QUEUE[BX], DX                   ; Shift the less urgent item along
    SUB BX, 2
    JMP AD_SLIDE

AD_PLACE:
    MOV QUEUE[BX], AX
    INC WORD PTR COUNT

    PUSH AX
    LEA DX, M_ADD
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_QUEUE

AD_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ADMIT ENDP

; -----------------------------------------------------------------------------
; SERVE
;
; Takes the most urgent item, which is always the first, and closes the gap.
; -----------------------------------------------------------------------------
SERVE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP WORD PTR COUNT, 0
    JE  SV_EMPTY

    MOV AX, QUEUE[0]

    ; Close the gap by moving everything down one place
    MOV CX, COUNT
    DEC CX
    XOR BX, BX

SV_CLOSE:
    JCXZ SV_CLOSED
    MOV DX, QUEUE[BX+2]
    MOV QUEUE[BX], DX
    ADD BX, 2
    LOOP SV_CLOSE

SV_CLOSED:
    DEC WORD PTR COUNT

    PUSH AX
    LEA DX, M_TAKE
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_QUEUE
    JMP SV_DONE

SV_EMPTY:
    LEA DX, M_EMPTY
    MOV AH, 09H
    INT 21H

SV_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SERVE ENDP

; -----------------------------------------------------------------------------
; SHOW_QUEUE
; -----------------------------------------------------------------------------
SHOW_QUEUE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    LEA DX, M_STATE
    MOV AH, 09H
    INT 21H

    MOV CX, COUNT
    JCXZ SQ_DONE
    XOR BX, BX

SQ_LOOP:
    MOV AX, QUEUE[BX]
    PUSH BX
    PUSH CX
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP CX
    POP BX

    ADD BX, 2
    LOOP SQ_LOOP

SQ_DONE:
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_QUEUE ENDP

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
; 1. WHERE THE COST IS PAID:
;    - Sorted insertion makes arriving expensive and serving instant. The
;    - alternative, searching for the smallest when serving, reverses
;    - that. Which is better depends on which happens more often.
; 2. A HEAP IS THE USUAL ANSWER:
;    - It makes both operations cost the logarithm of the size rather
;    - than one being free and the other linear. For eight items the
;    - difference is not worth the complication.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
