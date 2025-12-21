; =============================================================================
; TITLE: Memory Block Comparison
; DESCRIPTION: Compare two memory buffers for equality using the 8086 
;              CMPSB (Compare String Byte) instruction.
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
    STR1            DB 'Assembly'        ; Primary buffer
    STR2            DB 'Assembly'        ; Secondary buffer
    LEN             EQU 8                ; Comparison length
    
    MSG_EQUAL       DB 'Status: Memory blocks are identical.$'
    MSG_NOT_EQUAL   DB 'Status: Memory blocks differ.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Segments
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; ES used by CMPSB for second operand
    
    ; -------------------------------------------------------------------------
    ; STRING COMPARISON SETUP
    ; Operands: DS:SI vs ES:DI
    ; -------------------------------------------------------------------------
    LEA SI, STR1
    LEA DI, STR2
    MOV CX, LEN                         ; Number of bytes to check
    
    CLD                                 ; Increment SI and DI
    
    ; REPE CMPSB: Repeat 'Compare String Byte' while Equal AND CX > 0
    ; Subtracts ES:[DI] from DS:[SI] to set flags, but doesn't store result.
    REPE CMPSB
    
    ; Check the Zero Flag (ZF): 
    ; If comparison finished and ZF=1, all bytes matched.
    JNE NOT_EQUAL                       
    
    LEA DX, MSG_EQUAL
    JMP DISPLAY_RESULT
    
NOT_EQUAL:
    LEA DX, MSG_NOT_EQUAL
    
DISPLAY_RESULT:
    MOV AH, 09H                         ; DOS: Print string
    INT 21H
    
    ; EXIT
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. INSTRUCTION LOGIC:
;    - 'REPE' (Repeat While Equal) is synonymous with 'REPZ'.
;    - If the loop terminates due to a mismatch, the Zero Flag (ZF) is cleared.
;    - If the loop terminates because CX reached 0, the Zero Flag remains set.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
