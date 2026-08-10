; =============================================================================
; TITLE: Reading the Shift and Lock Keys
; DESCRIPTION: Asks which modifier keys are held down or latched, each one a
;              single bit in the returned byte.
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
    M_HEAD  DB 'Keyboard state:', 0DH, 0AH, '$'
    M_RIGHT DB '  right shift  $'
    M_LEFT  DB '  left shift   $'
    M_CTRL  DB '  control      $'
    M_ALT   DB '  alt          $'
    M_SCROLL DB '  scroll lock  $'
    M_NUM   DB '  num lock     $'
    M_CAPS  DB '  caps lock    $'
    M_INS   DB '  insert       $'
    M_ON    DB 'on', 0DH, 0AH, '$'
    M_OFF   DB 'off', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 02H RETURNS ONE BYTE IN AL WHERE EVERY BIT IS A DIFFERENT KEY.
    ; THE LOW FOUR ARE HELD DOWN NOW; THE HIGH FOUR ARE LATCHED STATES THAT
    ; STAY UNTIL PRESSED AGAIN.
    ;
    ;   bit 0  right shift        bit 4  scroll lock
    ;   bit 1  left shift         bit 5  num lock
    ;   bit 2  control            bit 6  caps lock
    ;   bit 3  alt                bit 7  insert
    ; -------------------------------------------------------------------------
    MOV AH, 02H
    INT 16H
    MOV BL, AL                          ; Keep it; printing will destroy AX

    LEA DX, M_RIGHT
    MOV CL, 0
    CALL SHOW_BIT

    LEA DX, M_LEFT
    MOV CL, 1
    CALL SHOW_BIT

    LEA DX, M_CTRL
    MOV CL, 2
    CALL SHOW_BIT

    LEA DX, M_ALT
    MOV CL, 3
    CALL SHOW_BIT

    LEA DX, M_SCROLL
    MOV CL, 4
    CALL SHOW_BIT

    LEA DX, M_NUM
    MOV CL, 5
    CALL SHOW_BIT

    LEA DX, M_CAPS
    MOV CL, 6
    CALL SHOW_BIT

    LEA DX, M_INS
    MOV CL, 7
    CALL SHOW_BIT

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_BIT
;
; Prints the label at DS:DX, then whether bit CL of BL is set.
; -----------------------------------------------------------------------------
SHOW_BIT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AH, 09H
    INT 21H

    MOV AL, 1
    SHL AL, CL                          ; The mask for this bit
    TEST BL, AL
    JZ  SB_OFF

    LEA DX, M_ON
    JMP SB_SHOW

SB_OFF:
    LEA DX, M_OFF

SB_SHOW:
    MOV AH, 09H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_BIT ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. BUILDING THE MASK BY SHIFTING:
;    - One shifted left by the bit number gives the mask for that bit, so
;    - a single routine tests all eight rather than eight routines with
;    - eight constants.
; 2. HELD DOWN VERSUS LATCHED:
;    - The low four bits are true only while the key is down. The high
;    - four are toggles that stay as they were left, which is why caps
;    - lock survives being released.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
