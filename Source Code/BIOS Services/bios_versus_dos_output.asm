; =============================================================================
; TITLE: The BIOS and DOS Compared
; DESCRIPTION: Prints the same line through both routes and sets out when each
;              one is the right choice.
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
    LINE_A  DB 'Printed through DOS service 09h.', 0DH, 0AH, '$'

    LINE_B  DB 'Printed through BIOS service 0Eh.'
    LINE_BLEN EQU $ - LINE_B

    M_NOTE  DB 0DH, 0AH, 'Both reached the screen. The difference is what', 0DH, 0AH
            DB 'each one depends on.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; DOS: ONE CALL FOR THE WHOLE STRING, BUT IT NEEDS DOS TO BE RUNNING AND
    ; THE TEXT CANNOT CONTAIN A DOLLAR SIGN.
    ; -------------------------------------------------------------------------
    LEA DX, LINE_A
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; BIOS: ONE CALL PER CHARACTER, BUT IT WORKS BEFORE ANY OPERATING SYSTEM
    ; HAS LOADED AND THE TEXT MAY CONTAIN ANY BYTE AT ALL.
    ; -------------------------------------------------------------------------
    LEA SI, LINE_B
    MOV CX, LINE_BLEN

BIOS_LOOP:
    MOV AL, [SI]
    MOV AH, 0EH
    MOV BH, 0
    INT 10H
    INC SI
    LOOP BIOS_LOOP

    LEA DX, M_NOTE
    MOV AH, 09H
    INT 21H

    MOV AX, 4C00H
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHEN TO USE THE BIOS:
;    - A boot sector, a device driver, an interrupt handler, or anything
;    - that runs before or beneath DOS. None of those can call INT 21h.
; 2. WHEN TO USE DOS:
;    - Everything else. It is one call rather than a loop, and its output
;    - can be redirected to a file at the command line, which BIOS output
;    - cannot.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
