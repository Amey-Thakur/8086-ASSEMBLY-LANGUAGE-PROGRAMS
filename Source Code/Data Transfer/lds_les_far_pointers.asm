; =============================================================================
; TITLE: Loading a Far Pointer with LDS and LES
; DESCRIPTION: Loads a segment and offset pair in one instruction, which is how
;              a program reaches data outside its own segment.
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
    ; A far pointer is four bytes: the offset first, then the segment.
    SCREEN_PTR DW 0000H, 0B800H
    BUFFER_PTR DW 0200H, 0A000H

    MSG_ES DB 'LES gave ES:BX = $'
    MSG_DS DB 'LDS gave DS:SI = $'
    COLON  DB ':$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; LES READS FOUR BYTES: THE FIRST WORD INTO THE NAMED REGISTER AND THE
    ; SECOND INTO ES. ONE INSTRUCTION LOADS A COMPLETE ADDRESS.
    ; -------------------------------------------------------------------------
    LES BX, SCREEN_PTR

    LEA DX, MSG_ES
    MOV AH, 09H
    INT 21H
    MOV AX, ES
    CALL PRINT_HEX
    LEA DX, COLON
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; LDS DOES THE SAME INTO DS. IT IS DONE LAST HERE, BECAUSE CHANGING DS
    ; MOVES EVERY DATA NAME IN THE PROGRAM OUT OF REACH.
    ; -------------------------------------------------------------------------
    LEA DX, MSG_DS
    MOV AH, 09H
    INT 21H

    LDS SI, BUFFER_PTR
    MOV AX, DS
    MOV BX, SI

    PUSH AX                             ; DS is no longer the data segment,
    MOV AX, @DATA                       ; so it has to be restored before
    MOV DS, AX                          ; anything else can be printed
    POP AX

    CALL PRINT_HEX
    LEA DX, COLON
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE ORDER IN MEMORY:
;    - Offset first, segment second. It matches the little endian rule
;    - that the less significant part comes first, and it is the order
;    - a far CALL pushes a return address in.
; 2. LDS IS DANGEROUS MID PROGRAM:
;    - Every unqualified data name is relative to DS. The moment LDS
;    - changes it, MSG and the rest are no longer where the code thinks.
;    - Restoring DS before the next reference is not optional.
; 3. WHY LES IS THE SAFER ONE:
;    - ES exists for exactly this, and no ordinary data reference depends
;    - on it. A far pointer is normally loaded into ES for that reason.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
