; =============================================================================
; TITLE: A Hash Table with Linear Probing
; DESCRIPTION: Stores values at a position derived from the value itself, and
;              steps forward when that position is already taken.
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
    SLOTS   EQU 11                      ; A prime, which spreads the values out
    EMPTY   EQU 0FFFFH

    TABLE   DW SLOTS DUP(EMPTY)
    ITEMS   DW 27, 18, 29, 40, 5, 16
    HOWMANY EQU 6

    M_INS   DB 'stored $'
    M_AT    DB ' at slot $'
    M_PROBE DB ', after $'
    M_STEPS DB ' probes', 0DH, 0AH, '$'
    M_FOUND DB '29 was found at slot $'
    M_MISS  DB '99 is not in the table', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, ITEMS
    MOV CX, HOWMANY

INSERT_ALL:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL INSERT
    POP SI
    POP CX

    ADD SI, 2
    LOOP INSERT_ALL

    ; Look one up, and look one up that is not there
    MOV AX, 29
    CALL LOOKUP
    CMP AX, EMPTY
    JE  NOT_THERE

    PUSH AX
    LEA DX, M_FOUND
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

NOT_THERE:
    MOV AX, 99
    CALL LOOKUP
    CMP AX, EMPTY
    JNE FINISH

    LEA DX, M_MISS
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; INSERT
;
; Places AX in the table.
; -----------------------------------------------------------------------------
INSERT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, AX                          ; Keep the value

    ; -------------------------------------------------------------------------
    ; THE HASH IS THE VALUE MODULO THE NUMBER OF SLOTS. WHEN THAT SLOT IS
    ; TAKEN, THE NEXT ONE IS TRIED, AND SO ON ROUND THE TABLE. THAT IS LINEAR
    ; PROBING, AND IT IS WHY THE TABLE MUST NEVER BE ALLOWED TO FILL.
    ; -------------------------------------------------------------------------
    XOR DX, DX
    MOV BX, SLOTS
    DIV BX
    MOV BX, DX                          ; The slot to try first
    XOR DI, DI                          ; How many probes it took

IN_PROBE:
    PUSH BX
    SHL BX, 1
    CMP WORD PTR TABLE[BX], EMPTY
    POP BX
    JE  IN_PLACE

    INC DI
    INC BX
    CMP BX, SLOTS
    JB  IN_PROBE
    XOR BX, BX                          ; Round the end
    JMP IN_PROBE

IN_PLACE:
    PUSH BX
    SHL BX, 1
    MOV TABLE[BX], CX
    POP BX

    ; Report where it went
    PUSH BX
    PUSH DI
    LEA DX, M_INS
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_DECIMAL
    LEA DX, M_AT
    MOV AH, 09H
    INT 21H
    POP DI
    POP BX
    PUSH DI
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_PROBE
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_STEPS
    MOV AH, 09H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
INSERT ENDP

; -----------------------------------------------------------------------------
; LOOKUP
;
; Returns the slot holding AX, or EMPTY when it is not present.
; -----------------------------------------------------------------------------
LOOKUP PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, AX
    XOR DX, DX
    MOV BX, SLOTS
    DIV BX
    MOV BX, DX
    MOV DI, SLOTS                       ; At most one pass round the table

LU_PROBE:
    PUSH BX
    SHL BX, 1
    MOV AX, TABLE[BX]
    POP BX

    CMP AX, CX
    JE  LU_FOUND
    CMP AX, EMPTY
    JE  LU_MISSING                      ; An empty slot means it is not here

    INC BX
    CMP BX, SLOTS
    JB  LU_COUNT
    XOR BX, BX

LU_COUNT:
    DEC DI
    JNZ LU_PROBE

LU_MISSING:
    MOV AX, EMPTY
    JMP LU_DONE

LU_FOUND:
    MOV AX, BX

LU_DONE:
    POP DX
    POP CX
    POP BX
    RET
LOOKUP ENDP

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
; 1. WHY THE SLOT COUNT IS PRIME:
;    - A composite size makes values sharing a factor with it collide far
;    - more often. Eleven spreads the six values here across the table
;    - rather than bunching them.
; 2. AN EMPTY SLOT ENDS THE SEARCH:
;    - If the value were present it would have been placed at the first
;    - free slot on its path, so reaching an empty one proves it is not
;    - there. That is what makes a failed lookup fast.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
