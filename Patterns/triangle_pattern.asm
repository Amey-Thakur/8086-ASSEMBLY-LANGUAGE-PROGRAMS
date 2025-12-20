;=============================================================================
; Program:     Right-Angled Triangle Pattern
; Description: Generate an increasing star pattern (*) using nested loops 
;              to iterate through rows and columns.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    ROWS DB 5                           ; Total height of the triangle
    MSG  DB 'Right-Angled Star Triangle:', 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Segment registers initialization
    MOV AX, @DATA
    MOV DS, AX
    
    ; Header text
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV BL, 1                           ; Number of stars for first row
    MOV BH, ROWS                        ; Counter for total rows
    
;-------------------------------------------------------------------------
; OUTER ROW LOOP: Managed by BH
;-------------------------------------------------------------------------
ROW_START:
    PUSH BX                             ; Preserve state for inner processing
    
    ;-------------------------------------------------------------------------
    ; INNER COLUMN LOOP: Managed by CL
    ;-------------------------------------------------------------------------
    MOV CL, BL                          ; Load current star count
STAR_PRINT:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    LOOP STAR_PRINT                     ; Automatically decrements CX and loops
    
    ; Print Newline (CR/LF sequence)
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    POP BX                              ; Restore counters
    INC BL                              ; Increase star count for next row
    DEC BH                              ; One less row to process
    JNZ ROW_START                       ; Continue until BH is 0
    
    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; TRIANGLE PATTERN NOTES:
; - Standard nested loop architecture (O(N^2)).
; - Uses CX register with the 'LOOP' opcode for efficient inner iteration.
; - Expected Output:
;   *
;   **
;   ***
;   ****
;   *****
;=============================================================================
