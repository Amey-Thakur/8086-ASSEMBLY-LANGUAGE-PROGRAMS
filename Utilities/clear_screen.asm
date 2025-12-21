; TITLE: Clear Screen Utility
; DESCRIPTION: A program to clear the console screen and reset the cursor to the top-left position using BIOS interrupts.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License

.MODEL SMALL
.STACK 100H

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
    MOV AH, 4CH      ; DOS Function: Exit to DOS
    INT 21H
MAIN ENDP

; =============================================================================
; NOTES:
; 1. SCROLL WINDOW (AH=06H): This is the most professional way to clear the screen 
;    as it allows specifying a color attribute and window region.
; 2. COLOR ATTRIBUTES (BH): 
;    - High 4 bits: Background color (0-7, or 0-F if blinking is disabled)
;    - Low 4 bits: Foreground (text) color (0-F)
;    - 07H is the default DOS color (Light Grey text on Black background).
; 3. VGA COORDINATES: Standard text mode 03H is 80 columns (0-79) by 25 rows (0-24).
;    - 184FH in DX represents: Row 18H (24) and Column 4FH (79).
; 4. INTERRUPT 10H: The primary interface for video hardware in the x86 BIOS.
; =============================================================================

END MAIN
