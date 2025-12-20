;=============================================================================
; Program:     Insert Element in Array
; Description: Insert an element at a specified position by shifting
;              existing elements right to make space.
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
    ARR DB 10H, 20H, 30H, 40H, 50H, 0  ; Extra space for new element
                                       ; Original: {10, 20, 30, 40, 50}
    LEN EQU 5                          ; Current array length
    POS EQU 2                          ; Position to insert (0-indexed)
    ELEM DB 25H                        ; Element to insert (37 decimal)

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Setup Pointers for Shifting (Right to Left)
    ; To insert: shift all elements from end backwards to position
    ;-------------------------------------------------------------------------
    LEA SI, ARR                         ; Source pointer
    ADD SI, LEN - 1                     ; Point to last element (index 4)
    LEA DI, ARR                         ; Destination pointer
    ADD DI, LEN                         ; Point to new last position (index 5)
    
    ;-------------------------------------------------------------------------
    ; Calculate Number of Elements to Shift
    ;-------------------------------------------------------------------------
    MOV CX, LEN                         ; Total elements
    SUB CX, POS                         ; Minus position = elements to shift
                                        ; CX = 5 - 2 = 3 elements (30,40,50)
    
    ;-------------------------------------------------------------------------
    ; Shift Elements Right (working backwards)
    ;-------------------------------------------------------------------------
SHIFT_LOOP:
    MOV AL, [SI]                        ; Get element
    MOV [DI], AL                        ; Copy to position one right
    DEC SI                              ; Move source pointer back
    DEC DI                              ; Move destination pointer back
    LOOP SHIFT_LOOP                     ; Repeat for remaining elements
    
    ;-------------------------------------------------------------------------
    ; Insert New Element
    ;-------------------------------------------------------------------------
    LEA SI, ARR                         ; Point to array start
    ADD SI, POS                         ; Move to insertion position
    MOV AL, ELEM                        ; Load new element (25H)
    MOV [SI], AL                        ; Insert element
    
    ; Result: ARR = {10H, 20H, 25H, 30H, 40H, 50H}
    ;         {16, 32, 37, 48, 64, 80} in decimal
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOTES:
; - Insertion requires shifting elements RIGHT (from end to position)
; - Must shift backward to avoid overwriting elements
; - Ensure array has extra space allocated before insertion
; - Time complexity: O(n) where n is elements after insertion point
; - Original: {10, 20, 30, 40, 50} -> After inserting 25 at pos 2:
;             {10, 20, 25, 30, 40, 50}
;=============================================================================
