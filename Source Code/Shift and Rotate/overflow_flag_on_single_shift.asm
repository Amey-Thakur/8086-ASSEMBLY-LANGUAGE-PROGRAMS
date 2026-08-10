; =============================================================================
; TITLE: The Overflow Flag on a Single Shift
; DESCRIPTION: Shows when SHL sets the overflow flag, and why the flag is only
;              meaningful for a shift of exactly one place.
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
    CASE_A DW 4000H                     ; Top two bits differ after the shift
    CASE_B DW 2000H                     ; They do not
    A_MSG  DB '4000H shifted left once: OF = $'
    B_MSG  DB '2000H shifted left once: OF = $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; FOR A SHIFT OF ONE, OF IS SET WHEN THE SIGN BIT CHANGED. THAT IS THE
    ; SIGNED SENSE OF OVERFLOW: THE DOUBLING TOOK THE VALUE PAST WHAT A
    ; SIGNED WORD CAN HOLD.
    ; -------------------------------------------------------------------------
    LEA DX, A_MSG
    MOV AH, 09H
    INT 21H

    MOV BX, CASE_A                      ; 0100 0000 ... becomes 1000 0000 ...
    SHL BX, 1
    CALL SHOW_OVERFLOW

    LEA DX, B_MSG
    MOV AH, 09H
    INT 21H

    MOV BX, CASE_B                      ; 0010 0000 ... becomes 0100 0000 ...
    SHL BX, 1
    CALL SHOW_OVERFLOW

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_OVERFLOW
;
; Prints 1 or 0 for the overflow flag as it stood on entry, then a newline.
; -----------------------------------------------------------------------------
SHOW_OVERFLOW PROC
    MOV DL, '0'
    JNO SO_EMIT
    MOV DL, '1'

SO_EMIT:
    MOV AH, 02H
    INT 21H
    CALL NEWLINE
    RET
SHOW_OVERFLOW ENDP

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
; 1. WHAT OF MEANS HERE:
;    - After SHL by one, OF is set when the new sign bit differs from the
;    - old one. 4000h is positive and becomes 8000h, which is negative,
;    - so OF is set. 2000h stays positive, so it is not.
; 2. WHY ONLY FOR A COUNT OF ONE:
;    - For any larger count the processor leaves OF undefined, because
;    - the sign may have changed several times on the way and a single
;    - flag cannot report that. Never test OF after a multi place shift.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
