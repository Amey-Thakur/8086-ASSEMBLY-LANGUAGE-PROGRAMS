; =============================================================================
; TITLE: What a Stack Frame Contains
; DESCRIPTION: Prints the addresses and contents of a frame from inside the
;              procedure, so the layout can be seen rather than described.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    M_BP     DB 'BP now points at    $'
    M_SAVED  DB 'Saved BP there is   $'
    M_RETURN DB 'Return address at BP+2 is $'
    M_ARG1   DB 'First argument BP+4 is    $'
    M_ARG2   DB 'Second argument BP+6 is   $'
    M_LOCAL  DB 'A local at BP-2 is        $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; ARGUMENTS ARE PUSHED IN REVERSE, SO THE FIRST ONE WRITTEN ENDS UP
    ; CLOSEST TO BP INSIDE THE PROCEDURE.
    ; -------------------------------------------------------------------------
    MOV AX, 2222
    PUSH AX                             ; The second argument
    MOV AX, 1111
    PUSH AX                             ; The first
    CALL SHOW_FRAME
    ADD SP, 4

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_FRAME
;
; The layout, from the top of the stack downward:
;
;     BP+6   second argument
;     BP+4   first argument
;     BP+2   return address, put there by CALL
;     BP+0   the caller's BP, saved on entry
;     BP-2   the first local variable
; -----------------------------------------------------------------------------
SHOW_FRAME PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2                           ; Room for one local
    PUSH AX
    PUSH DX

    MOV WORD PTR [BP-2], 9999           ; Fill the local

    LEA DX, M_BP
    MOV AH, 09H
    INT 21H
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SAVED
    MOV AH, 09H
    INT 21H
    MOV AX, [BP]
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_RETURN
    MOV AH, 09H
    INT 21H
    MOV AX, [BP+2]
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_ARG1
    MOV AH, 09H
    INT 21H
    MOV AX, [BP+4]
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_ARG2
    MOV AH, 09H
    INT 21H
    MOV AX, [BP+6]
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_LOCAL
    MOV AH, 09H
    INT 21H
    MOV AX, [BP-2]
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP AX
    MOV SP, BP                          ; Discard the locals in one step
    POP BP
    RET
SHOW_FRAME ENDP

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
; 1. WHY BP AND NOT SP:
;    - SP moves whenever anything is pushed. BP is set once on entry and
;    - stays still, so every offset within the frame remains correct
;    - however much the procedure pushes afterwards.
; 2. MOV SP, BP UNDOES THE LOCALS:
;    - Whatever SUB SP reserved is released in one instruction, without
;    - having to remember how much it was.
; 3. BP DEFAULTS TO THE STACK SEGMENT:
;    - An address through BP is taken in SS rather than DS, which is
;    - exactly right for a frame and a trap when BP is used as a general
;    - pointer into data.
; 4. THE RETURN ADDRESS IN THE WEB SIMULATOR:
;    - On real hardware the value at BP+2 is the byte offset of the
;    - instruction after the CALL. The browser simulator holds the
;    - program as a list of instructions rather than as encoded bytes,
;    - so it stores the index of that instruction instead.
;    - The structure of the frame is identical either way; only the
;    - number differs, and it is small rather than several hundred.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
