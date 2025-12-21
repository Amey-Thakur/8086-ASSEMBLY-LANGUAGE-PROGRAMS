; =============================================================================
; TITLE: Mouse Interface (INT 33h)
; DESCRIPTION: A comprehensive mouse handling program. Detects driver presence, 
;              tracks X/Y coordinates, and monitors Left/Right button clicks 
;              using interrupt services.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

NAME "mouse_io"
ORG 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
    MSG_NO_MOUSE DB "Error: Mouse Driver not found!$"
    MSG_EXIT     DB "Click BOTH buttons to Exit...$"
    
    COORD_X      DW 0
    COORD_Y      DW 0
    BTN_STATUS   DW 0

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- Step 1: Initialize Mouse ---
    MOV AX, 0                           ; Driver Reset
    INT 33H
    CMP AX, 0                           ; 0 = Not Installed, FFFFh = Installed
    JE L_ERR_DRIVER
    
    ; --- Step 2: Show Mouse Pointer ---
    MOV AX, 1
    INT 33H
    
    ; Setup Screen Text
    MOV DX, OFFSET MSG_EXIT
    MOV AH, 09H
    INT 21H
    
; --- Step 3: Polling Loop ---
POLL_MOUSE:
    ; Get Mouse Status
    MOV AX, 3
    INT 33H
    ; Returns:
    ; BX = Button Status (Bit 0: Left, Bit 1: Right)
    ; CX = Horizontal (X) Coordinate
    ; DX = Vertical (Y) Coordinate
    
    ; Check Exit Condition (Both Buttons: 1 + 2 = 3)
    CMP BX, 3
    JE L_EXIT_APP
    
    ; Update Global Storage (Simulated Logic)
    MOV COORD_X, CX
    MOV COORD_Y, DX
    MOV BTN_STATUS, BX
    
    ; In a real GUI, we would redraw cursor/UI here.
    ; For console, we just loop until exit.
    JMP POLL_MOUSE
    
L_EXIT_APP:
    ; Hide Cursor before exit
    MOV AX, 2
    INT 33H
    
    RET                                 ; Return to DOS

L_ERR_DRIVER:
    MOV DX, OFFSET MSG_NO_MOUSE
    MOV AH, 09H
    INT 21H
    RET

END START

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. INT 33H SERVICES:
;    This interrupt is provided by the Mouse Driver (mouse.com / ctmouse.exe).
;    It is NOT a BIOS standard interrupt but became the de-facto standard.
;
; 2. COORDINATE SYSTEM:
;    - Text Mode (80x25): X ranges 0-639, Y ranges 0-199 (Virtual pixels).
;    - The driver maps these to character cells (8x8 pixels usually).
;    - To get text column: Divide CX by 8.
;
; 3. POLLING VS EVENTS:
;    This code Polls (busy wait). A more advanced method is to register an 
;    Event Handler (Callback) using AX=000Ch, which triggers a FAR CALL 
;    whenever the mouse moves or clicks.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
