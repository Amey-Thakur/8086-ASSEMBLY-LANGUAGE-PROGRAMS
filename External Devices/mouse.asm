;=============================================================================
; Program:     Mouse Interface Test
; Description: Demonstrate mouse integration in 8086 assembly using INT 33h.
;              Displays real-time X/Y coordinates and button status.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

NAME "mouse"

ORG 100H                            ; COM file format

;-----------------------------------------------------------------------------
; MACROS
;-----------------------------------------------------------------------------

; Print string at (x, y) with color attribute
PRINT MACRO X, Y, ATTRIB, SDAT
LOCAL S_DCL, SKIP_DCL, S_DCL_END
    PUSHA
    MOV DX, CS
    MOV ES, DX
    MOV AH, 13H                     ; BIOS: Print string with attributes
    MOV AL, 1                       ; Update cursor after printing
    MOV BH, 0                       ; Page 0
    MOV BL, ATTRIB                  ; Color attribute
    MOV CX, OFFSET S_DCL_END - OFFSET S_DCL
    MOV DL, X                       ; column
    MOV DH, Y                       ; row
    MOV BP, OFFSET S_DCL            ; String pointer
    INT 10H
    POPA
    JMP SKIP_DCL
S_DCL DB SDAT
S_DCL_END DB 0
SKIP_DCL:    
ENDM

; Clear entire screen with default grey background
CLEAR_SCREEN MACRO
    PUSHA
    MOV AX, 0600H                   ; Scroll window up (clear)
    MOV BH, 0000_1111B              ; Fill attribute (white on black)
    MOV CX, 0                       ; Top left (0,0)
    MOV DH, 24                      ; Bottom row
    MOV DL, 79                      ; Right column
    INT 10H
    POPA
ENDM

; Print multiple spaces to clear previous text
PRINT_SPACE MACRO NUM
    PUSHA
    MOV AH, 9                       ; BIOS: Write character and attribute
    MOV AL, ' '
    MOV BL, 0000_1111B
    MOV CX, NUM                     ; Number of times
    INT 10H
    POPA
ENDM

;-----------------------------------------------------------------------------
; MAIN SECTION
;-----------------------------------------------------------------------------

JMP START

; Current states to avoid unnecessary updates
CURX DW 0
CURY DW 0
CURB DW 0

START:
    ; Configure video mode basics
    MOV AX, 1003H                   ; BIOS: Disable blinking (enable 16 background colors)
    MOV BX, 0        
    INT 10H

    ; Hide text cursor for clean UI
    MOV CH, 32                      ; Set cursor scanlines (outside visible range)
    MOV AH, 1
    INT 10H

    ; Reset mouse and check status
    MOV AX, 0                       ; Mouse: Reset/Initialize
    INT 33H
    CMP AX, 0                       ; Returns AX=0 if no mouse driver
    JNE OK
    PRINT 1, 1, 0010_1111B, " mouse not found :-( "
    JMP STOP

OK:
    CLEAR_SCREEN

    ; Instructions
    PRINT 7, 7, 0010_1011B, " note: in the emulator you may need to press and hold mouse buttons "
    PRINT 7, 8, 0010_1011B, " because mouse interrupts are not processed in real time.           "
    PRINT 7, 9, 0010_1011B, " for a real test, click external->run from the menu.                "
    PRINT 10, 11, 0010_1111B, " click/hold both buttons to exit... "

    ; Display mouse cursor
    MOV AX, 1                       ; Mouse: Show pointer
    INT 33H

;-----------------------------------------------------------------------------
; Mouse Status Poll Loop
;-----------------------------------------------------------------------------
CHECK_MOUSE_BUTTONS:
    MOV AX, 3                       ; Mouse: Get position and buttons
    INT 33H
    ; Returns: BX=buttons, CX=X, DX=Y
    
    CMP BX, 3                       ; Both left and right buttons pressed?
    JE  HIDE                        ; Yes, exit
    
    CMP CX, CURX                    ; Has X moved?
    JNE PRINT_XY
    CMP DX, CURY                    ; Has Y moved?
    JNE PRINT_XY
    CMP BX, CURB                    ; Have buttons changed?
    JNE PRINT_BUTTONS
    
    JMP CHECK_MOUSE_BUTTONS         ; Keep polling

;-----------------------------------------------------------------------------
; Update Displays
;-----------------------------------------------------------------------------

PRINT_XY:
    PRINT 0, 0, 0000_1111B, "x="
    MOV AX, CX
    CALL PRINT_AX
    PRINT_SPACE 4
    
    PRINT 0, 1, 0000_1111B, "y="
    MOV AX, DX
    CALL PRINT_AX
    PRINT_SPACE 4
    
    MOV CURX, CX
    MOV CURY, DX
    JMP CHECK_MOUSE_BUTTONS

PRINT_BUTTONS:
    PRINT 0, 2, 0000_1111B, "btn="
    MOV AX, BX
    CALL PRINT_AX
    PRINT_SPACE 4
    MOV CURB, BX
    JMP CHECK_MOUSE_BUTTONS

HIDE:
    MOV AX, 2                       ; Mouse: Hide pointer
    INT 33H

    CLEAR_SCREEN
    PRINT 1, 1, 1010_0000B, " hardware must be free!      free the mice! "

STOP:
    ; Restore box-shaped blinking text cursor
    MOV AH, 1
    MOV CH, 0
    MOV CL, 8
    INT 10H

    PRINT 4, 7, 0000_1010B, " press any key.... "
    MOV AH, 0                       ; BIOS: Read keystroke
    INT 16H
    RET

;-----------------------------------------------------------------------------
; UTILITY: Print AX as decimal
;-----------------------------------------------------------------------------
PRINT_AX PROC
    CMP AX, 0
    JNE PRINT_AX_R
    PUSH AX
    MOV AL, '0'
    MOV AH, 0EH
    INT 10H
    POP AX
    RET 
PRINT_AX_R:
    PUSHA
    MOV DX, 0
    CMP AX, 0
    JE PN_DONE
    MOV BX, 10
    DIV BX    
    CALL PRINT_AX_R                 ; Recursive call for next digit
    MOV AX, DX
    ADD AL, 30H                     ; ASCII convert
    MOV AH, 0EH
    INT 10H    
    JMP PN_DONE
PN_DONE:
    POPA  
    RET  
ENDP

END

;=============================================================================
; MOUSE INTERFACE (INT 33h) NOTES:
; - AX=0: Init mouse. Returns AX=FFFFh if driver exists.
; - AX=1: Show cursor.
; - AX=2: Hide cursor (should always do this before changing screen content).
; - AX=3: Get status. BX bits: 0=Left, 1=Right, 2=Middle.
; - X/Y coordinates in text mode are pixels (often 640x200 or 320x200).
;=============================================================================
