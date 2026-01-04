; =============================================================================
; TITLE: Inverted Triangle Pattern
; DESCRIPTION: Generate and display a top-heavy (inverted) right-angled 
;              triangle using the decrementing loop technique.
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
    MAX_ROWS DB 5
    MSG      DB 'Inverted Star Triangle:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Print header
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV BL, MAX_ROWS                    ; Start with the long row
    MOV BH, MAX_ROWS                    ; Total rows to print
    
    ; -------------------------------------------------------------------------
    ; MAIN ROW LOOP
    ; -------------------------------------------------------------------------
ROW_LOOP:
    PUSH BX                             ; Save parameters
    
    ; 1. Print Stars for this row
    MOV CL, BL                          ; Load count into CL
STAR_ITER:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    LOOP STAR_ITER                      ; Loop CX times
    
    ; 2. Print Newline (CR/LF)
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    POP BX                              ; Restore counters
    DEC BL                              ; Reduce star count for next row
    DEC BH                              ; Decrement row limit
    JNZ ROW_LOOP                        ; Continue until 0 rows left
    
    ; Termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. LOGIC:
;    - Row 1 = 5 stars, Row 2 = 4 stars ... Row 5 = 1 star.
;    - This utilizes a 'double-nested' control structure where the inner count
;      decreases on every outer iteration.
;    - Expected Output:
;      *****
;      ****
;      ***
;      **
;      *
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
