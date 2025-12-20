;=============================================================================
; Program:     Hello World (DOS COM style)
; Description: Smallest possible "Hello World" using DOS Interrupt 21H
;              in a single-segment COM utility.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

ORG 100H                            ; COM file entry point

;-----------------------------------------------------------------------------
; MAIN CODE SECTION
;-----------------------------------------------------------------------------
START:
    JMP MAIN_CODE                   ; Jump over data definition

    ; String must terminate with '$' for DOS function 09h
    MSG DB 'Hello, World!', 0DH, 0AH, '$'

MAIN_CODE:
    LEA DX, MSG                     ; Load address of our string
    MOV AH, 09H                     ; DOS: display string
    INT 21H                         ; Execution!
    
    ; Wait for a key to let user read the message
    MOV AH, 00H
    INT 16H
    
    RET                             ; Return to OS

END

;=============================================================================
; COM FILE NOTES:
; - COM files are limited to 64KB (single segment).
; - ORG 100h is mandatory for the Program Segment Prefix (PSP).
; - Code and Data coexist in the same segment (CS=DS=SS).
;=============================================================================
