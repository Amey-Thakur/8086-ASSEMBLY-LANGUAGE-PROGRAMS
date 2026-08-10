; =============================================================================
; TITLE: Recursive Factorial
; DESCRIPTION: Calculate the factorial of a 16-bit number (n!) using 
;              a recursive procedure call.
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
    NUM    DW 5                         ; Target number
    RESULT DW ?                         ; Buffer for 120 (5!)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_NUM DB '  NUM = ', '$'
    RPT_N_RESULT DB '  RESULT = ', '$'
.CODE

; Procedure: FACTORIAL (Recursive)
; Logic: 
;   IF n <= 1 RETURN 1
;   ELSE RETURN n * FACTORIAL(n-1)
FACTORIAL PROC
    ; Base Condition check
    CMP AX, 1
    JLE BASE_CASE                       ; If AX <= 1, return 1
    
    ; Recursive step
    PUSH AX                             ; Save current 'n' on stack
    DEC AX                              ; AX = n - 1
    
    CALL FACTORIAL                      ; Recursion: find (n-1)!
                                        ; Result of (n-1)! returns in AX
    
    POP BX                              ; Recover current 'n' into BX
    MUL BX                              ; AX = (n-1)! * n
    
    RET                                 ; Go up one level in recursion
    
BASE_CASE:
    MOV AX, 1                           ; 1! = 1
    RET
FACTORIAL ENDP

MAIN PROC
    ; Environment setup
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM                         ; Start with input '5'
    CALL FACTORIAL                      ; Compute 5!
    MOV RESULT, AX                      ; Final result: 120
    
    ; Application Exit
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_NUM
    CALL RPT_SAY
    MOV AX, NUM
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RESULT
    CALL RPT_SAY
    MOV AX, RESULT
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from any helper the
; program already had, so adding this report cannot clash with it.
;
; The digits come out of the division lowest first, which is the wrong order to
; print them in, so they are pushed and then popped back off.
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
; Prints the dollar terminated string at DS:DX without disturbing AX, which
; matters because the caller usually has the value it is about to print there.
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
; 1. RECURSION:
;    - Recursion in 8086 depends heavily on the Stack for saving return
;      addresses and local state (registers).
;    - Risk: "Stack Overflow" if the recursion is too deep.
;    - This implementation uses the register AX to pass and return values.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
