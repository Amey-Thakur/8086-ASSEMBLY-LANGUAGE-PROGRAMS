;=============================================================================
; Program:     Garment Defect Detection (Simulation)
; Description: Simulate a quality control station in a textile factory. 
;              The program scans "pieces" (array elements) against grade
;              thresholds and logs inventory statistics.
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
    THRESHOLD1 DB ?                      ; Quality cut-off 1
    THRESHOLD2 DB ?                      ; Quality cut-off 2
    
    ; Array of garment grades (1-9)
    BATCH      DB 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
    BATCH_COUNT EQU 10
    
    GOOD_COUNT DB 10                     ; Initial assumption
    BAD_COUNT  DB 0                      ; Counter for defects
    
    MSG_T1      DB 10,13,"Enter Minimum Grade (T1): $"
    MSG_T2      DB 10,13,"Enter Maximum Tolerance (T2): $"
    MSG_DEFECT  DB 10,13,"[QC] Defect detected at station. $"
    MSG_FIXED   DB 10,13,"[QC] Defective piece flagged and removed. $"
    MSG_REPORT_G DB 10,13,"Inventory Report: Good pieces = $"
    MSG_REPORT_B DB 10,13,"Inventory Report: Defective pieces = $"

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; State init
    MOV AX, @DATA
    MOV DS, AX
    
    ; 1. Setup Quality Parameters
    LEA DX, MSG_T1
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV THRESHOLD1, AL

    LEA DX, MSG_T2
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV THRESHOLD2, AL

    ; 2. Start Processing Batch
    LEA SI, BATCH
    MOV CX, BATCH_COUNT
    
PROCESS_LOOP:
    MOV AL, [SI]                        ; Fetch current piece grade
    
    ; Logic: If (Grade < T1) OR (Grade < T2) - specific logic per requirements
    CMP AL, THRESHOLD1
    JL LOG_DEFECT
    CMP AL, THRESHOLD2
    JL LOG_DEFECT
    JMP NEXT_PIECE

LOG_DEFECT:
    LEA DX, MSG_DEFECT
    MOV AH, 09H
    INT 21H
    
    ; Flag logic: Zero out the buffer and update counts
    MOV BYTE PTR [SI], 0
    INC BAD_COUNT
    DEC GOOD_COUNT
    
    LEA DX, MSG_FIXED
    MOV AH, 09H
    INT 21H

NEXT_PIECE:
    INC SI
    LOOP PROCESS_LOOP
    
;-------------------------------------------------------------------------
; FINAL INVENTORY REPORT
;-------------------------------------------------------------------------
    ; Display Good
    LEA DX, MSG_REPORT_G
    MOV AH, 09H
    INT 21H
    MOV DL, GOOD_COUNT
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    
    ; Display Bad
    LEA DX, MSG_REPORT_B
    MOV AH, 09H
    INT 21H
    MOV DL, BAD_COUNT
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    
    ; Program Halt
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; SMART AUTOMATION NOTES:
; - Array 'BATCH' represents a physical conveyor belt.
; - Thresholding simulates sensor input.
; - Inventory reporting is a key feature of Industrial IoT (IIoT) logic.
;=============================================================================