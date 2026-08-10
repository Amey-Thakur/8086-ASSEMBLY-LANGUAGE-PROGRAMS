; =============================================================================
; TITLE: Clear Screen Utility
; DESCRIPTION: A program to clear the console screen and reset the cursor to 
;              the top-left position using BIOS interrupts.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Method 1: Using BIOS Interrupt 10H, Function 06H (Scroll Up) ---
    ; By scrolling up 0 lines with AL=00, BIOS clears the specified window.
    
    MOV AX, 0600H    ; AH=06 (Scroll Window Up), AL=00 (Clear entire window)
    MOV BH, 07H      ; BH = Background Color Attribute (07H = Light Grey on Black)
    MOV CX, 0000H    ; CX = Upper Left Corner (Row 0, Column 0)
    MOV DX, 184FH    ; DX = Lower Right Corner (Row 24, Column 79)
    INT 10H          ; Call BIOS Video Service
    
    ; --- Reset Cursor Position ---
    ; After clearing the screen, the cursor usually stays at its previous position.
    ; We must manually move it back to (0,0).
    
    MOV AH, 02H      ; AH=02 BIOS Function: Set Cursor Position
    MOV BH, 00H      ; BH = Video Page Number (usually 0)
    MOV DX, 0000H    ; DH = Row 0, DL = Column 0
    INT 10H          ; Call BIOS Video Service
    
    ; --- Method 2: Reset Video Mode (Optional) ---
    ; Changing the video mode effectively clears the screen and reset the cursor.
    ; MOV AH, 00H
    ; MOV AL, 03H    ; 80x25 Color Text Mode
    ; INT 10H
    
    ; Clean termination
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself instead of needing a debugger.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

    MOV AH, 4CH      ; DOS Function: Exit to DOS
    INT 21H
MAIN ENDP

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

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. SCROLL WINDOW (AH=06H):
;    - Most professional way to clear screen.
;    - Allows specifying color attribute and window region.
; 2. COLOR ATTRIBUTES (BH): 
;    - High 4 bits: Background color (0-7).
;    - Low 4 bits: Foreground (text) color (0-F).
;    - 07H is default DOS color (Light Grey text on Black background).
; 3. VGA COORDINATES: 
;    - Standard text mode 03H is 80 columns (0-79) by 25 rows (0-24).
;    - 184FH in DX represents: Row 18H (24) and Column 4FH (79).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
