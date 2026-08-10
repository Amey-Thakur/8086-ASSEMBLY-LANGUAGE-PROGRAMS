; =============================================================================
; TITLE: Reading The Interrupt Vector Table
; DESCRIPTION: The first kilobyte of memory is 256 far pointers, one per interrupt, and any of them can simply be read.
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
    ; The interrupts worth looking at, and what each one is for.
    WANTED  DB 00H, 08H, 09H, 10H, 13H, 16H, 1AH, 21H
    HOWMANY EQU 8

    N_00    DB 'divide by zero  $'
    N_08    DB 'timer tick      $'
    N_09    DB 'keyboard        $'
    N_10    DB 'video BIOS      $'
    N_13    DB 'disc BIOS       $'
    N_16    DB 'keyboard BIOS   $'
    N_1A    DB 'clock BIOS      $'
    N_21    DB 'DOS services    $'
    NAMES   DW N_00, N_08, N_09, N_10, N_13, N_16, N_1A, N_21

    M_TITLE DB 'The interrupt vector table, read straight out of memory', 0DH, 0AH, '$'
    M_HOW   DB 'Vector n lives at 0000:n*4, as an offset then a segment.', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'int  at      handler        what it is', 0DH, 0AH, '$'
    M_COLON DB ':$'
    M_GAP   DB '   $'
    M_HEX   DB 'H$'
    M_WHY   DB 0DH, 0AH
            DB 'Installing a handler means writing four bytes here. Doing it '
            DB 'without disabling interrupts first risks the timer firing '
            DB 'between the two words.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HOW
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; ES POINTS AT SEGMENT ZERO, WHERE THE TABLE LIVES. DS STILL POINTS AT THE
    ; PROGRAM DATA, WHICH IS WHY THE NAMES ARE STILL REACHABLE WHILE THE TABLE
    ; IS BEING READ.
    ; -------------------------------------------------------------------------
    XOR AX, AX
    MOV ES, AX

    XOR SI, SI
    MOV CX, HOWMANY

EACH_VECTOR:
    PUSH CX

    ; ---- the interrupt number ----------------------------------------------
    MOV BL, WANTED[SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- where its vector sits: the number times four ----------------------
    MOV DI, BX
    SHL DI, 1
    SHL DI, 1
    MOV AX, DI
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- the handler address, segment first for readability ----------------
    MOV AX, ES:[DI+2]                   ; The segment
    CALL PRINT_HEX
    LEA DX, M_COLON
    CALL PRINT_MESSAGE
    MOV AX, ES:[DI]                     ; The offset
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- and what it is for -------------------------------------------------
    MOV DI, SI
    SHL DI, 1
    MOV DX, NAMES[DI]
    CALL PRINT_MESSAGE
    CALL NEWLINE

    INC SI
    POP CX
    LOOP EACH_VECTOR

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX
;
; Prints the value in AX as four hexadecimal digits followed by H.
; -----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed for DOS
    MOV CX, 4                           ; Four nibbles, most significant first

PH_NEXT:
    ROL BX, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE PH_EMIT
    ADD DL, 7                           ; A to F sit seven further on

PH_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP PH_NEXT

    MOV DL, 'H'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

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
; 1. Four bytes per interrupt:
;    - Vector n is at address n times four, in segment zero.
;    - The offset comes first and the segment second, as every far pointer does.
;    - Two hundred and fifty-six vectors is the first kilobyte of memory, and nothing else lives there.
; 2. Two segment registers at once:
;    - ES points at segment zero for the table and DS stays on the program data.
;    - Without the override every read would come from the data segment instead.
;    - This is the ordinary reason a small model program still needs ES.
; 3. Installing a handler:
;    - Writing the four bytes is the whole installation.
;    - The old value must be saved and put back, or the next program inherits yours.
;    - CLI around the two writes stops an interrupt arriving between them.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
