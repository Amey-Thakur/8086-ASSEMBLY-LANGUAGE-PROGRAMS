;=============================================================================
; Program:     Switch-Case Structure (Jump Table)
; Description: Implement switch-case using jump table technique.
;              Efficient for multiple branch decisions.
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
    CHOICE DB 2                         ; User choice (1-3)
    MSG1 DB 'Option 1 selected$'
    MSG2 DB 'Option 2 selected$'
    MSG3 DB 'Option 3 selected$'
    MSG_DEF DB 'Invalid option$'
    
    ;-------------------------------------------------------------------------
    ; Jump Table - Array of addresses for each case
    ;-------------------------------------------------------------------------
    JUMP_TABLE DW CASE_1, CASE_2, CASE_3

;-----------------------------------------------------------------------------
; CODE SEGMENT
; 
; High-level equivalent:
;   switch (choice)
;       case 1: print "Option 1"
;       case 2: print "Option 2"
;       case 3: print "Option 3"
;       default: print "Invalid"
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Validate Choice (bounds check)
    ;-------------------------------------------------------------------------
    MOV AL, CHOICE                      ; Load choice
    CMP AL, 1
    JB DEFAULT_CASE                     ; If choice < 1, invalid
    CMP AL, 3
    JA DEFAULT_CASE                     ; If choice > 3, invalid
    
    ;-------------------------------------------------------------------------
    ; Calculate Jump Table Index
    ; Index = (choice - 1) * 2 (each address is 2 bytes)
    ;-------------------------------------------------------------------------
    DEC AL                              ; AL = choice - 1 (0-based index)
    XOR AH, AH                          ; Clear high byte
    SHL AX, 1                           ; AX = AX * 2 (word offset)
    
    ;-------------------------------------------------------------------------
    ; Jump through Table
    ;-------------------------------------------------------------------------
    MOV BX, AX                          ; BX = offset into table
    JMP JUMP_TABLE[BX]                  ; Indirect jump to case handler
    
CASE_1:
    LEA DX, MSG1
    JMP END_SWITCH
    
CASE_2:
    LEA DX, MSG2
    JMP END_SWITCH
    
CASE_3:
    LEA DX, MSG3
    JMP END_SWITCH
    
DEFAULT_CASE:
    LEA DX, MSG_DEF
    
END_SWITCH:
    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; SWITCH-CASE IMPLEMENTATION METHODS
;=============================================================================
; 
; Method 1: Compare and Jump (Simple but slow for many cases)
;   CMP AL, 1 / JE CASE_1
;   CMP AL, 2 / JE CASE_2
;   ...
; 
; Method 2: Jump Table (Fast for consecutive values)
;   - Create table of addresses
;   - Calculate index: (value - base) * 2
;   - Indirect jump: JMP TABLE[BX]
;   - O(1) time complexity regardless of cases
; 
; Method 3: Binary Search (for sparse values)
;   - Good for non-consecutive case values
;=============================================================================
