;=============================================================================
; Program:     Linear Search Implementation
; Description: Search for an 8-bit element in an array using sequential 
;              comparison and loop-based traversal.
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
    ARRAY   DB 01h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h, 10h
    A_LEN   EQU 10
    TARGET  DB 05h                       ; Element to find
    
    MSG_FOUND DB 'Element located in array! (True/FFh in DL)$'
    MSG_FAIL  DB 'Element not present in array. (False/00h in DL)$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize data access
    MOV AX, @DATA
    MOV DS, AX
    
    MOV CX, A_LEN                       ; Setup loop counter
    LEA BX, ARRAY                       ; Base address of array
    MOV SI, 0                           ; Index offset
    
;-------------------------------------------------------------------------
; SEQUENTIAL SCAN LOOP
;-------------------------------------------------------------------------
SCAN_ARRAY:
    MOV AL, [BX+SI]                     ; Access current element
    CMP AL, TARGET                      ; Check against our key
    JE  MATCH_FOUND                     ; If equal, we are done
    
    INC SI                              ; Move to next byte
    LOOP SCAN_ARRAY                     ; Repeat until CX becomes 0
    
; If we reach here, no match was found
NO_MATCH:
    MOV DL, 00H                         ; Set failure flag
    LEA DX, MSG_FAIL
    JMP DISPLAY_AND_EXIT

MATCH_FOUND:
    MOV DL, 0FFH                        ; Set success flag
    LEA DX, MSG_FOUND

DISPLAY_AND_EXIT:
    ; Standard string output
    MOV AH, 09H
    INT 21H
    
    ; Termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; LINEAR SEARCH NOTES:
; - Best Case: O(1) - element is at the very start.
; - Worst Case: O(N) - element is at the end or missing.
; - Does not require the array to be sorted.
; - The 'LOOP' instruction in 8086 is a convenient way to perform this scan.
;=============================================================================