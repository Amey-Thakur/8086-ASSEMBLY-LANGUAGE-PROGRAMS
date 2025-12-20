;=============================================================================
; Program:     Reverse an Array
; Description: Reverse the elements of an array in memory.
;              Copies elements in reverse order to new array.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    STR1 DB 01H, 02H, 05H, 03H, 04H     ; Original array
    STR2 DB 5 DUP(?)                     ; Reversed array
    LEN EQU 5                            ; Array length
DATA ENDS
 
;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Setup Pointers
    ; SI points to start of source
    ; DI points to end of destination
    ;-------------------------------------------------------------------------
    LEA SI, STR1                        ; Source: beginning
    LEA DI, STR2 + LEN - 1              ; Destination: end
    MOV CX, LEN                         ; Counter
 
    ;-------------------------------------------------------------------------
    ; Reverse Copy Loop
    ; Copy from start of source to end of destination
    ;-------------------------------------------------------------------------
BACK: 
    CLD                                 ; Clear direction flag
    MOV AL, [SI]                        ; Get element from source
    MOV [DI], AL                        ; Store at destination (reversed)
    INC SI                              ; Move source forward
    DEC DI                              ; Move destination backward
    DEC CX                              ; Decrement counter
    JNZ BACK                            ; Continue if not done
 
    ; Result: STR2 = {04H, 03H, 05H, 02H, 01H}
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

;=============================================================================
; REVERSE ARRAY NOTES:
; - Original: {1, 2, 5, 3, 4}
; - Reversed: {4, 3, 5, 2, 1}
; - Alternative: In-place reversal using swap from both ends
;=============================================================================
