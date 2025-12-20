;=============================================================================
; Program:     Delete Element from Array
; Description: Delete an element at a specified position by shifting
;              remaining elements left to fill the gap.
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
    ARR DB 10H, 20H, 30H, 40H, 50H     ; Original: {10, 20, 30, 40, 50}
    LEN EQU 5                           ; Array length
    POS EQU 2                           ; Position to delete (0-indexed)
                                        ; Delete 30H at position 2

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Setup Pointers for Shifting
    ; To delete: shift all elements after POS one position left
    ;-------------------------------------------------------------------------
    LEA SI, ARR                         ; Source pointer
    ADD SI, POS + 1                     ; Point to element AFTER deletion position
    LEA DI, ARR                         ; Destination pointer
    ADD DI, POS                         ; Point to deletion position
    
    ;-------------------------------------------------------------------------
    ; Calculate Number of Elements to Shift
    ;-------------------------------------------------------------------------
    MOV CX, LEN - 1                     ; Total elements - 1
    SUB CX, POS                         ; Minus position = elements to shift
                                        ; CX = 5 - 1 - 2 = 2 elements
    
    ;-------------------------------------------------------------------------
    ; Shift Elements Left
    ;-------------------------------------------------------------------------
SHIFT_LOOP:
    MOV AL, [SI]                        ; Get element from position after
    MOV [DI], AL                        ; Copy to current position
    INC SI                              ; Move source pointer forward
    INC DI                              ; Move destination pointer forward
    LOOP SHIFT_LOOP                     ; Repeat for remaining elements
    
    ;-------------------------------------------------------------------------
    ; Clear Last Element (Optional cleanup)
    ;-------------------------------------------------------------------------
    MOV BYTE PTR [DI], 0                ; Set last position to 0
    
    ; Result: ARR = {10H, 20H, 40H, 50H, 00H}
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOTES:
; - Deletion requires shifting all elements after the deletion point
; - Time complexity: O(n) where n is number of elements after deletion point
; - The length should be decremented after deletion (handled by caller)
; - Original: {10, 20, 30, 40, 50} -> After deleting pos 2: {10, 20, 40, 50, 0}
;=============================================================================
