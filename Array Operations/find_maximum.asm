;=============================================================================
; Program:     Find Maximum in Array
; Description: Find the maximum (largest) value in an array of numbers.
;              Demonstrates comparison and conditional jumps.
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
    ARR DB 45H, 23H, 89H, 12H, 67H     ; Array: {69, 35, 137, 18, 103}
    LEN EQU 5                           ; Array length
    MAX DB ?                            ; Maximum value storage
    MSG DB 'Maximum value found$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Initialize: Assume first element is maximum
    ;-------------------------------------------------------------------------
    LEA SI, ARR                         ; SI points to array start
    MOV CL, LEN                         ; Loop counter
    MOV AL, [SI]                        ; AL = first element (initial max)
    INC SI                              ; Point to second element
    DEC CL                              ; Adjust counter (already checked first)
    
    ;-------------------------------------------------------------------------
    ; Find Maximum Loop
    ; Compare current max with each remaining element
    ;-------------------------------------------------------------------------
FIND_MAX:
    CMP AL, [SI]                        ; Compare current max with element
    JA SKIP                             ; Jump if Above (AL > [SI])
                                        ; If AL <= [SI], update max
    MOV AL, [SI]                        ; Update max with larger value
SKIP:
    INC SI                              ; Move to next element
    DEC CL                              ; Decrement counter
    JNZ FIND_MAX                        ; Continue if not done
    
    ;-------------------------------------------------------------------------
    ; Store Result
    ; Maximum: 89H = 137 decimal
    ;-------------------------------------------------------------------------
    MOV MAX, AL                         ; Store maximum value
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOTES:
; - JA (Jump if Above) is for unsigned comparison
; - JG (Jump if Greater) is for signed comparison
; - Algorithm: Initialize max with first element, then compare with rest
; - Time complexity: O(n) - must check every element
;=============================================================================
