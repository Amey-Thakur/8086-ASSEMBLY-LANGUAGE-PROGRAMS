;=============================================================================
; Program:     Timer and Delay Function
; Description: Demonstrate BIOS timer interrupt (INT 15h / AH=86h).
;              Prints characters with a 1-second delay.
;              Designed as a boot sector program.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

NAME "timer"

#make_boot#
ORG 7C00H                           ; Boot sector entry point

;-----------------------------------------------------------------------------
; INITIALIZATION
;-----------------------------------------------------------------------------
; Setup segment registers
MOV AX, CS
MOV DS, AX
MOV ES, AX

; Initialize UI
CALL SET_VIDEO_MODE
CALL CLEAR_SCREEN

;-----------------------------------------------------------------------------
; MAIN LOOP: PRINT WITH DELAY
;-----------------------------------------------------------------------------
NEXT_CHAR:
    CMP COUNT, 0                     ; All chars printed?
    JZ STOP

    ; Print current character using BIOS TTY
    MOV AL, C1
    MOV AH, 0EH
    INT 10H

    ; Increment ASCII and decrement counter
    INC C1
    DEC COUNT

    ;-------------------------------------------------------------------------
    ; WAIT DELAY (INT 15h / AH=86h)
    ; Input CX:DX = microseconds to wait
    ; 1,000,000 microseconds = 1 second = 000F 4240h
    ;-------------------------------------------------------------------------
    MOV CX, 0FH                     ; High word of 1,000,000
    MOV DX, 4240H                   ; Low word of 1,000,000
    MOV AH, 86H                     ; BIOS: Wait function
    INT 15H

    JC STOP                         ; Exit if interrupt not supported (CF=1)

    JMP NEXT_CHAR                   ; Continue loop

;-----------------------------------------------------------------------------
; TERMINATION: DISP NOTIFY AND REBOOT
;-----------------------------------------------------------------------------
STOP:
    ; Print message using BIOS service 13h (Print string with attribute)
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0010_1111B              ; Attribute: White on Green
    MOV CX, MSG_SIZE
    MOV DL, 4                       ; Column
    MOV DH, 15                      ; Row
    MOV BP, OFFSET MSG
    MOV AH, 13H
    INT 10H

    ; Wait for user input
    MOV AH, 0
    INT 16H

    ; Perform a soft reboot
    INT 19H                         ; BIOS Bootstrap loader

;-----------------------------------------------------------------------------
; DATA SECTION
;-----------------------------------------------------------------------------
COUNT DB 10                         ; Print 10 characters
C1    DB 'a'                        ; Starting character

MSG DB "remove floppy disk and press any key to reboot..."
MSG_SIZE = $ - MSG

;-----------------------------------------------------------------------------
; PROCEDURES
;-----------------------------------------------------------------------------

; Set standard text mode
SET_VIDEO_MODE PROC
    MOV AH, 0
    MOV AL, 3                       ; 80x25 characters, 16 colors
    INT 10H
    
    ; Disable blinking to allow 16 background colors
    MOV AX, 1003H
    MOV BX, 0    
    INT 10H
    RET
SET_VIDEO_MODE ENDP

; Clear screen and reset cursor
CLEAR_SCREEN PROC NEAR
    PUSH AX
    PUSH DS
    PUSH BX
    PUSH CX
    PUSH DI

    MOV AX, 40H                     ; Access BIOS Data Area
    MOV DS, AX  
    
    MOV AH, 06H                     ; BIOS: Scroll window up
    MOV AL, 0                       ; 0 = clear entire window
    MOV BH, 1111_0000B              ; Fill attribute: Black on White
    MOV CH, 0                       ; Top row
    MOV CL, 0                       ; Left column
    
    MOV DI, 84H                     ; BDA: Rows on screen - 1
    MOV DH, [DI]                    ; Lower right row
    MOV DI, 4AH                     ; BDA: Columns on screen
    MOV DL, [DI]
    DEC DL                          ; Lower right column
    INT 10H

    ; Set cursor at (0,0)
    MOV BH, 0
    MOV DL, 0
    MOV DH, 0
    MOV AH, 02H
    INT 10H

    POP DI
    POP CX
    POP BX
    POP DS
    POP AX
    RET
CLEAR_SCREEN ENDP

END

;=============================================================================
; TIMER INTERRUPT NOTES:
; - INT 15h, AH=86h is used for precise microsecond delays.
; - CX (high word) and DX (low word) together form a 32-bit wait value.
; - Support varies: Real mode support is standard, but some NT-based Windows
;   emulations fail this call (setting Carry Flag).
; - Microseconds: 1,000,000 = 1 sec.
;=============================================================================