;=============================================================================
; Program:     Hello World (Segmented EXE style)
; Description: Standard multi-segment application structure displaying 
;              a string using DOS services.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    MSG DB "Hello, World!$"
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    ; Standard Initialization for Segmented EXE
    MOV AX, DATA                    ; Load segment address of DATA
    MOV DS, AX                      ; Point DS to it
    
    ; Prepare string output
    LEA DX, MSG                     ; Load offset of the string
    MOV AH, 09H                     ; DOS function: display string
    INT 21H                         ; Call DOS system services
    
EXIT:
    ; Terminate process (Standard DOS Exit)
    MOV AX, 4C00H                   ; AH=4Ch (Exit), AL=00h (Return Code)
    INT 21H                         ; Return control to MS-DOS

CODE ENDS

END START

;=============================================================================
; ARCHITECTURE NOTES:
; - EXE files can have multiple segments (Code, Data, Stack).
; - 'ASSUME' tells the assembler which segment register points where.
; - 'MOV DS, AX' is required because you cannot move immediate values 
;   directly into segment registers.
;=============================================================================
