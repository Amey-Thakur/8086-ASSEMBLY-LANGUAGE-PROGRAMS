; =============================================================================
; TITLE: A Double Ended Queue
; DESCRIPTION: A buffer that accepts and releases values at either end, which
;              is a stack and a queue at the same time.
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
    CAPACITY EQU 6
    BUFFER   DW CAPACITY DUP(0)
    FRONT    DW 0
    COUNT    DW 0

    M_FRONT  DB 'push front $'
    M_BACK   DB 'push back  $'
    M_POPF   DB 'pop front  $'
    M_POPB   DB 'pop back   $'
    M_STATE  DB '   holding: $'
    M_FULL   DB 'no room', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, 30
    CALL PUSH_BACK
    MOV AX, 40
    CALL PUSH_BACK
    MOV AX, 20
    CALL PUSH_FRONT
    MOV AX, 10
    CALL PUSH_FRONT

    CALL POP_BACK
    CALL POP_FRONT

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PUSH_BACK
;
; Adds AX after the last item.
; -----------------------------------------------------------------------------
PUSH_BACK PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV BX, COUNT
    CMP BX, CAPACITY
    JAE PB_FULL

    ; The slot after the last is front plus count, wrapped
    ADD BX, FRONT
    CALL WRAP_INDEX
    SHL BX, 1
    MOV BUFFER[BX], AX
    INC WORD PTR COUNT

    PUSH AX
    LEA DX, M_BACK
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_DEQUE
    JMP PB_DONE

PB_FULL:
    LEA DX, M_FULL
    MOV AH, 09H
    INT 21H

PB_DONE:
    POP DX
    POP BX
    POP AX
    RET
PUSH_BACK ENDP

; -----------------------------------------------------------------------------
; PUSH_FRONT
;
; Adds AX before the first item, by stepping the front backward.
; -----------------------------------------------------------------------------
PUSH_FRONT PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV BX, COUNT
    CMP BX, CAPACITY
    JAE PF_FULL

    ; -------------------------------------------------------------------------
    ; STEPPING BACKWARD FROM SLOT ZERO WRAPS TO THE LAST SLOT. ADDING THE
    ; CAPACITY BEFORE SUBTRACTING KEEPS THE ARITHMETIC POSITIVE THROUGHOUT,
    ; WHICH MATTERS BECAUSE THE INDEX IS UNSIGNED.
    ; -------------------------------------------------------------------------
    MOV BX, FRONT
    ADD BX, CAPACITY
    DEC BX
    CALL WRAP_INDEX
    MOV FRONT, BX

    SHL BX, 1
    MOV BUFFER[BX], AX
    INC WORD PTR COUNT

    PUSH AX
    LEA DX, M_FRONT
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_DEQUE
    JMP PF_DONE

PF_FULL:
    LEA DX, M_FULL
    MOV AH, 09H
    INT 21H

PF_DONE:
    POP DX
    POP BX
    POP AX
    RET
PUSH_FRONT ENDP

; -----------------------------------------------------------------------------
; POP_FRONT
; -----------------------------------------------------------------------------
POP_FRONT PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP WORD PTR COUNT, 0
    JE  POF_DONE

    MOV BX, FRONT
    SHL BX, 1
    MOV AX, BUFFER[BX]

    MOV BX, FRONT
    INC BX
    CALL WRAP_INDEX
    MOV FRONT, BX
    DEC WORD PTR COUNT

    PUSH AX
    LEA DX, M_POPF
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_DEQUE

POF_DONE:
    POP DX
    POP BX
    POP AX
    RET
POP_FRONT ENDP

; -----------------------------------------------------------------------------
; POP_BACK
; -----------------------------------------------------------------------------
POP_BACK PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP WORD PTR COUNT, 0
    JE  POB_DONE

    MOV BX, FRONT
    ADD BX, COUNT
    DEC BX
    CALL WRAP_INDEX
    SHL BX, 1
    MOV AX, BUFFER[BX]
    DEC WORD PTR COUNT

    PUSH AX
    LEA DX, M_POPB
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_DEQUE

POB_DONE:
    POP DX
    POP BX
    POP AX
    RET
POP_BACK ENDP

; -----------------------------------------------------------------------------
; WRAP_INDEX
;
; Brings BX back inside the buffer by subtracting the capacity if it has run
; past. Only ever off by one, so a comparison is enough.
; -----------------------------------------------------------------------------
WRAP_INDEX PROC
    CMP BX, CAPACITY
    JB  WI_DONE
    SUB BX, CAPACITY

WI_DONE:
    RET
WRAP_INDEX ENDP

; -----------------------------------------------------------------------------
; SHOW_DEQUE
; -----------------------------------------------------------------------------
SHOW_DEQUE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    LEA DX, M_STATE
    MOV AH, 09H
    INT 21H

    MOV CX, COUNT
    JCXZ SD_DONE
    MOV BX, FRONT

SD_LOOP:
    PUSH BX
    SHL BX, 1
    MOV AX, BUFFER[BX]
    POP BX

    PUSH BX
    PUSH CX
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP CX
    POP BX

    INC BX
    CALL WRAP_INDEX
    LOOP SD_LOOP

SD_DONE:
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_DEQUE ENDP

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
; 1. ADDING THE CAPACITY BEFORE SUBTRACTING:
;    - Stepping the front back from zero would give minus one, which as
;    - an unsigned index is 65535. Adding the capacity first keeps every
;    - intermediate value in range.
; 2. ONE STRUCTURE, TWO BEHAVIOURS:
;    - Using only the back end makes it a stack; using one end for each
;    - makes it a queue. That is why a deque is the structure most
;    - libraries actually provide.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
