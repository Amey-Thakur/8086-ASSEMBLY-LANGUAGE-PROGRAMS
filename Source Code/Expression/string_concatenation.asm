; =============================================================================
; TITLE: String Concatenation
; DESCRIPTION: Joins (concatenates) two user-provided strings into a single 
;              output string. Manages string length calculation and memory copy.
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
    ; Input Buffers (Format: Max, Actual, Buffer)
    STR_A_BUF   DB 50, ?, 50 DUP('$')   
    STR_B_BUF   DB 50, ?, 50 DUP('$')
    
    PROMPT_1    DB 0DH, 0AH, "Enter String 1: $"
    PROMPT_2    DB 0DH, 0AH, "Enter String 2: $"
    MSG_RES     DB 0DH, 0AH, "Concatenated:   $"
    
    ; The Output Buffer (Large enough to hold both)
    FINAL_STR   DB 101 DUP('$')

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          
    
    ; --- Step 2: Get Inputs ---
    LEA DX, PROMPT_1
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR_A_BUF
    MOV AH, 0AH
    INT 21H
    
    LEA DX, PROMPT_2
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR_B_BUF
    MOV AH, 0AH
    INT 21H
    
    ; --- Step 3: Concatenation ---
    LEA DI, FINAL_STR                   ; Destination Pointer
    
    ; Copy String A
    LEA SI, STR_A_BUF + 2               ; Skin Metadata
    MOV CL, STR_A_BUF + 1               ; Length
    CMP CL, 0
    JE COPY_B
    XOR CH, CH
    
L_COPY_A:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP L_COPY_A
    
COPY_B:
    ; Copy String B
    LEA SI, STR_B_BUF + 2
    MOV CL, STR_B_BUF + 1
    CMP CL, 0
    JE L_SHOW
    XOR CH, CH
    
L_COPY_B:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP L_COPY_B
    
    ; Force Terminator
    MOV BYTE PTR [DI], '$'
    
L_SHOW:
    ; --- Step 4: Display Result ---
    LEA DX, MSG_RES
    MOV AH, 09H
    INT 21H
    
    LEA DX, FINAL_STR
    MOV AH, 09H
    INT 21H
    
    ; --- Step 5: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. MEMORY LAYOUT:
;    We use a dedicated 'FINAL_STR' buffer to avoid creating a new dynamic 
;    memory block (which 8086 DOS doesn't do easily). This is "static allocation".
;
; 2. BUFFER ACCESS:
;    DOS Input Buffer starts with [MAX_LEN] [ACTUAL_LEN]. The actual chars 
;    start at Offset + 2. We must skip the first two bytes to access the text.
;
; 3. POINTER CONTINUITY:
;    DI (Destination Index) is NOT reset between copies. It continues from 
;    where String A left off, ensuring String B is appended immediately after.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
