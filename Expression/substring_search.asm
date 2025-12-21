; =============================================================================
; TITLE: Substring Search
; DESCRIPTION: Scans a "Main" string to see if it contains a specific "Target" 
;              substring. Implements a naive pattern matching algorithm (O(N*M)).
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
    MAIN_STR    DB "TheQuickFox$"       ; Source Text
    SUB_STR     DB "Fox$"               ; Pattern to find
    
    MSG_FOUND   DB 0DH, 0AH, "Substring FOUND at Index: $"
    MSG_NOT     DB 0DH, 0AH, "Substring NOT FOUND$"
    
    POS_INDEX   DB ?

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    ; --- Step 2: Search Logic ---
    ; Loop through Main String until match or end
    LEA SI, MAIN_STR                    ; SI = Main Iterator
    MOV DX, 0                           ; DX = Current Index
    
SEARCH_LOOP:
    MOV AL, [SI]
    CMP AL, '$'                         ; End of Main?
    JE L_NOT_FOUND
    
    ; Potential Match Start?
    LEA DI, SUB_STR                     ; DI = Pattern Iterator
    MOV AL, [DI]
    CMP [SI], AL                        ; Check first char
    JE START_CHECK
    
    ; Iterate Context
    INC SI
    INC DX
    JMP SEARCH_LOOP
    
START_CHECK:
    ; Nested Loop: Check full pattern
    PUSH SI                             ; Save current Main position
    PUSH DI                             ; Save Pattern start (though reset anyway)
    
CHECK_MATCH:
    MOV AL, [DI]
    CMP AL, '$'                         ; End of Pattern?
    JE L_MATCH_CONFIRMED                ; If we reached end of pattern, it matched!
    
    CMP [SI], '$'                       ; End of Main mid-pattern?
    JE L_MATCH_FAIL                     ; Main ran out
    
    MOV AH, [SI]
    CMP AL, AH
    JNE L_MATCH_FAIL
    
    INC SI
    INC DI
    JMP CHECK_MATCH
    
L_MATCH_FAIL:
    POP DI
    POP SI
    INC SI                              ; Not it, advance Main
    INC DX
    JMP SEARCH_LOOP
    
L_MATCH_CONFIRMED:
    POP DI
    POP SI                              ; Stack Balance
    MOV POS_INDEX, DL
    
    ; --- Step 3: Success ---
    LEA DX, MSG_FOUND
    MOV AH, 09H
    INT 21H
    
    MOV AL, POS_INDEX
    ADD AL, '0'                         ; ASCII (Works for 0-9)
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP L_EXIT

L_NOT_FOUND:
    LEA DX, MSG_NOT
    MOV AH, 09H
    INT 21H

L_EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. NAIVE SEARCH ALGORITHM:
;    We try to match the Pattern string at every position of the Main string.
;    - Outer Loop: Iterates 'Main'.
;    - Inner Loop: Iterates 'Pattern' while characters match.
;    If Inner Loop completes (reaches '$'), we found it.
;    If Inner Loop breaks (mismatch), resume Outer Loop.
;
; 2. POINTER RESTORATION:
;    Crucial: When a partial match fails (e.g., matching "Fo" in "Foot"), 
;    we must restore SI to "Main position + 1" and try again. Using PUSH/POP 
;    SI enables this "rewind".
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
