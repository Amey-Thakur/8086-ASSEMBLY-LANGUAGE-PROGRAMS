;=============================================================================
; Program:     Find Minimum in Array
; Description: Find the minimum (smallest) value in an array of numbers.
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
    MIN DB ?                            ; Minimum value storage
    MSG DB 'Minimum value found$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Initialize: Assume first element is minimum
    ;-------------------------------------------------------------------------
    LEA SI, ARR                         ; SI points to array start
    MOV CL, LEN                         ; Loop counter
    MOV AL, [SI]                        ; AL = first element (initial min)
    INC SI                              ; Point to second element
    DEC CL                              ; Adjust counter (already checked first)
    
    ;-------------------------------------------------------------------------
    ; Find Minimum Loop
    ; Compare current min with each remaining element
    ;-------------------------------------------------------------------------
FIND_MIN:
    CMP AL, [SI]                        ; Compare current min with element
    JB SKIP                             ; Jump if Below (AL < [SI])
                                        ; If AL >= [SI], update min
    MOV AL, [SI]                        ; Update min with smaller value
SKIP:
    INC SI                              ; Move to next element
    DEC CL                              ; Decrement counter
    JNZ FIND_MIN                        ; Continue if not done
    
    ;-------------------------------------------------------------------------
    ; Store Result
    ; Minimum: 12H = 18 decimal
    ;-------------------------------------------------------------------------
    MOV MIN, AL                         ; Store minimum value
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOTES:
; - JB (Jump if Below) is for unsigned comparison
; - JL (Jump if Less) is for signed comparison
; - Algorithm: Initialize min with first element, then compare with rest
; - Time complexity: O(n) - must check every element
;=============================================================================
