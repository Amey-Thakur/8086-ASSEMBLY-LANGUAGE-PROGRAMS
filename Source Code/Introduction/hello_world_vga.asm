; =============================================================================
; TITLE: Hello World (Direct VGA Memory)
; DESCRIPTION: Display "Hello, World!" by writing directly to the video 
;              memory segment 0B800h in text mode.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H                            ; COM file entry point

; -----------------------------------------------------------------------------
; INITIALIZATION
; -----------------------------------------------------------------------------
START:
    ; Set Video Mode: 80x25 16-color text (Mode 03h)
    MOV AX, 0003H                   ; AH=0, AL=3
    INT 10H
    
    ; Optional: Disable blinking to enable all 16 background colors
    MOV AX, 1003H
    MOV BX, 0
    INT 10H
    
    ; Point DS to the video memory segment (Text Mode: 0B800h)
    MOV AX, 0B800H
    MOV DS, AX

; -----------------------------------------------------------------------------
; WRITE CHARACTERS TO VIDEO RAM
; Memory layout: [Char1][Attr1][Char2][Attr2]...
; Offset [00h] is top-left corner.
; -----------------------------------------------------------------------------
    MOV [02H], 'H'                  ; Write 'H' at 2nd column
    MOV [04H], 'e'
    MOV [06H], 'l'
    MOV [08H], 'l'
    MOV [0AH], 'o'
    MOV [0CH], ','
    MOV [0EH], 'W'
    MOV [10H], 'o'
    MOV [12H], 'r'
    MOV [14H], 'l'
    MOV [16H], 'd'
    MOV [18H], '!'

; -----------------------------------------------------------------------------
; COLOR THE CHARACTERS
; Attributes are stored at odd offsets (1, 3, 5...).
; -----------------------------------------------------------------------------
    MOV CX, 12                      ; Number of characters to color
    MOV DI, 03H                     ; Start at the attribute byte of 'H'

COLOR_LOOP:
    ; Attribute bitmask: [B-G-R-I (BG)] [B-G-R-I (FG)]
    ; 11101100b: Light Red on Yellow
    MOV BYTE PTR [DI], 11101100B
    ADD DI, 2                       ; Move to next attribute byte
    LOOP COLOR_LOOP
    
    ; Wait for keypress
    MOV AH, 0
    INT 16H

    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself instead of needing a debugger.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

    RET                             ; Back to DOS


; -----------------------------------------------------------------------------
; THE REPORT
;
; Everything below belongs to the report added so this program shows its result
; rather than leaving it in the registers for a debugger to find. The strings
; sit here beside the code that uses them, which is legal: the assembler places
; every declaration in the data image wherever it is written.
; -----------------------------------------------------------------------------
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; RPT_REGISTERS
;
; Prints the four general registers as they were on entry.
;
; They are pushed first and read back through BP, because printing needs AX for
; the value and DX for the message. Reading them any later would report the
; state of the printer rather than the state of the program.
; -----------------------------------------------------------------------------
RPT_REGISTERS PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX

    PUSH BP
    MOV BP, SP

    ; The program may have pointed DS somewhere of its own, at a video segment
    ; or at segment zero, and the strings below live in the data image. SEG
    ; gives their segment whatever the program left in DS.
    PUSH DS
    MOV AX, SEG RPT_HEAD
    MOV DS, AX

    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_AX
    CALL RPT_SAY
    MOV AX, [BP+2]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_BX
    CALL RPT_SAY
    MOV AX, [BP+4]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_CX
    CALL RPT_SAY
    MOV AX, [BP+6]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_DX
    CALL RPT_SAY
    MOV AX, [BP+8]
    CALL RPT_DECIMAL

    LEA DX, RPT_NL
    CALL RPT_SAY

    POP DS
    POP BP

    POP AX
    POP BX
    POP CX
    POP DX
    RET
RPT_REGISTERS ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal, lowest digit last.
; -----------------------------------------------------------------------------
RPT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

RPT_SPLIT:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE RPT_SPLIT

RPT_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP RPT_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
RPT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; RPT_SAY
;
; Prints the dollar terminated string at DS:DX, leaving AX alone.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP

END

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. VGA MEMORY:
;    - Text mode memory starts at 0B8000h (Segment 0B800h).
;    - Each screen position takes 2 bytes:
;      Byte 1: ASCII Character
;      Byte 2: Attribute (Colors and effects)
;    - This is the fastest way to update the screen.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
