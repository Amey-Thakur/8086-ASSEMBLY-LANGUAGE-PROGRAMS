; =============================================================================
; TITLE: Word Count Analysis (String Processing)
; DESCRIPTION: Analyzes a user-input sentence to count the number of words. 
;              The logic detects words by tracking transitions from delimiters 
;              (SPACES) to characters, handling multiple spaces correctly.
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
    MAX_CAP     DB 100                  ; Max input size
    ACT_LEN     DB ?                    ; Actual size read
    INPUT_STR   DB 101 DUP('$')         ; Buffer
    
    MSG_PROMPT  DB 0DH, 0AH, "Enter a Sentence: $"
    MSG_RESULT  DB 0DH, 0AH, "Word Count: $"
    
    WORD_COUNT  DB 0

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Get User Input ---
    LEA DX, MSG_PROMPT
    MOV AH, 09H
    INT 21H
    
    ; DOS Function 0AH - Buffered Input
    LEA DX, MAX_CAP
    MOV AH, 0AH
    INT 21H
    
    ; --- Step 3: Initialize Scanner ---
    MOV CL, ACT_LEN                     ; Loop Counter
    CMP CL, 0                           ; Check for empty string
    JE L_SHOW_RESULT                    ; If empty, Count = 0
    
    LEA SI, INPUT_STR                   ; Pointer to String
    MOV BL, 0                           ; Word Counter
    MOV BH, 0                           ; State Flag (0=Space, 1=Word)
    
SCAN_LOOP:
    MOV AL, [SI]
    CMP AL, 0DH                         ; Carriage return ends string
    JE L_SCAN_DONE
    
    CMP AL, ' '                         ; Is current char a space?
    JE L_IS_SPACE
    
    ; --- Case: Character ---
    CMP BH, 0                           ; Were we previously in a space?
    JNE L_NEXT_CHAR                     ; If no (already in word), continue
    
    ; Transition: Space -> Word
    INC BL                              ; Increment Word Count
    MOV BH, 1                           ; Set State = Word
    JMP L_NEXT_CHAR
    
L_IS_SPACE:
    MOV BH, 0                           ; Set State = Space
    
L_NEXT_CHAR:
    INC SI
    LOOP SCAN_LOOP
    
L_SCAN_DONE:
    MOV WORD_COUNT, BL
    
L_SHOW_RESULT:
    ; --- Step 4: Display Result ---
    LEA DX, MSG_RESULT
    MOV AH, 09H
    INT 21H
    
    ; Convert Byte to Decimal ASCII (0-99 supported)
    MOV AL, WORD_COUNT
    AAM                                 ; AH=Tens, AL=Units
    
    ADD AX, 3030H                       ; Convert to ASCII
    MOV CX, AX                          ; Save
    
    MOV DL, CH                          ; Tens
    MOV AH, 02H
    INT 21H
    
    MOV DL, CL                          ; Units
    MOV AH, 02H
    INT 21H
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. STATE MACHINE LOGIC:
;    Just counting spaces + 1 is flawed (fails on multiple spaces or 
;    trailing/leading spaces).
;    This program uses a "State Flag" (BH):
;    - State 0: Inside whitespace.
;    - State 1: Inside a word.
;    We only increment the counter when transitioning from State 0 to State 1.
;
; 2. BUFFERED INPUT (INT 21H / 0AH):
;    The input buffer struct is:
;    Byte 0: Max Length
;    Byte 1: Actual Length (Returned by DOS)
;    Byte 2+: String Characters
;    This is safer than reading char-by-char.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
