; =============================================================================
; TITLE: Linear Search with a Sentinel
; DESCRIPTION: Removes the bounds check from the inner loop by planting the
;              sought value past the end, so the search is certain to stop.
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
    ; One extra slot at the end holds the sentinel, so the array proper is
    ; HOWMANY long and the storage is one longer.
    DATA_W  DW 41, 8, 27, 63, 15, 92, 4, 0
    HOWMANY EQU 7

    KEEP    DW 0                        ; What the sentinel slot held
    WANTED  DW 63
    ABSENT  DW 50

    M_ARRAY DB 'The array: $'
    M_LOOK  DB 'Looking for $'
    M_AT    DB '   found at index $'
    M_NONE  DB '   not present', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ARRAY
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    MOV AX, WANTED
    CALL SENTINEL_SEARCH

    MOV AX, ABSENT
    CALL SENTINEL_SEARCH

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SENTINEL_SEARCH
;
; Looks for AX. Returns its index, or HOWMANY when it is absent.
; -----------------------------------------------------------------------------
SENTINEL_SEARCH PROC
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI

    PUSH AX
    LEA DX, M_LOOK
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    POP AX

    ; -------------------------------------------------------------------------
    ; PLANT THE SOUGHT VALUE IN THE SLOT AFTER THE ARRAY. THE LOOP THEN NEEDS
    ; ONLY ONE TEST PER ELEMENT INSTEAD OF TWO, BECAUSE IT CANNOT RUN OFF THE
    ; END: SOMETHING WILL ALWAYS MATCH. WHETHER IT WAS THE SENTINEL IS DECIDED
    ; ONCE, AFTERWARDS.
    ; -------------------------------------------------------------------------
    MOV BX, DATA_W[HOWMANY * 2]
    MOV KEEP, BX                        ; Remember what was there
    MOV DATA_W[HOWMANY * 2], AX

    LEA SI, DATA_W

SCAN:
    CMP AX, [SI]
    JE  STOPPED
    ADD SI, 2
    JMP SCAN

STOPPED:
    ; Put the slot back before anything else can see it changed
    MOV BX, KEEP
    MOV DATA_W[HOWMANY * 2], BX

    LEA BX, DATA_W
    MOV AX, SI
    SUB AX, BX
    SHR AX, 1                           ; The index it stopped at

    CMP AX, HOWMANY
    JE  SS_ABSENT

    PUSH AX
    LEA DX, M_AT
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP SS_DONE

SS_ABSENT:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

SS_DONE:
    POP SI
    POP DX
    POP BX
    POP AX
    RET
SENTINEL_SEARCH ENDP

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

SR_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX
    ADD SI, 2
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

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
; 1. ONE TEST INSTEAD OF TWO:
;    - An ordinary linear search compares the element and then checks
;    - whether it has run out. The sentinel makes the second test
;    - unnecessary, which on a long array is a real saving.
; 2. THE SLOT MUST BE RESTORED:
;    - The array is temporarily modified, so anything that reads it in
;    - between sees the wrong value. Putting it back before returning is
;    - what makes the trick invisible to the caller.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
