; =============================================================================
; TITLE: Reverse Digits of Integer Value
; DESCRIPTION: This program extracts decimal digits from an integer, stores 
;              them in an array, and then reconstructs a new integer in 
;              reverse order. Example: 12345 (Integer) -> 54321 (Integer).
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
    ; Numeric Storage
    VAL_ORIGINAL  DW 12345              ; Input number
    VAL_REVERSED  DW ?                  ; Output buffer
    
    ; Workspace
    DIGIT_ARRAY   DB 10 DUP(0)          ; Holds extracted digits
    TEMP_STORAGE  DW ?                  ; Calculation workspace
    
    ; Output Messages
    MSG_ORIG      DB 10, 13, 'Input Integer:  $'
    MSG_REV       DB 10, 13, 'Reversed Result: $'
    STR_OUTPUT    DB 10 DUP('$')        ; Reusable display buffer

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Display Original State ---
    LEA DX, MSG_ORIG
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_ORIGINAL
    LEA SI, STR_OUTPUT
    CALL SUB_INT_TO_ASCII               ; Convert to string for display
    LEA DX, STR_OUTPUT
    MOV AH, 09H
    INT 21H
    
    ; --- Step 3: Digit Extraction (Radix Peel) ---
    ; We divide by 10 repeatedly to get digits in REVERSE order.
    ; 12345 -> [5, 4, 3, 2, 1]
    LEA SI, DIGIT_ARRAY
    MOV AX, VAL_ORIGINAL
    MOV BX, 10
    XOR CX, CX                          ; CX will count found digits
    
L_EXTRACT_DIGITS:
    XOR DX, DX
    DIV BX                              ; AX = Quotient, DX = Remainder (Digit)
    MOV [SI], DL                        ; Store digit in array
    INC SI
    INC CX                              ; Track how many digits we have
    CMP AX, 0                           
    JNE L_EXTRACT_DIGITS                
    
    ; --- Step 4: Numeric Reconstruction (Reversal) ---
    ; Algorithm: (RunningTotal * 10) + CurrentDigit
    ; Data in array: [5, 4, 3, 2, 1]
    LEA SI, DIGIT_ARRAY
    MOV AX, 0                           ; Reversal Accumulator
    MOV BX, 10
    
L_RECONSTRUCT:
    MUL BX                              ; AX = AX * 10
    MOV DL, [SI]                        ; Get next digit
    XOR DH, DH
    ADD AX, DX                          ; Add to accumulated total
    INC SI
    LOOP L_RECONSTRUCT                  ; Use digit count from Step 3
    
    MOV VAL_REVERSED, AX                ; Store final result (54321)
    
    ; --- Step 5: Display Result ---
    LEA DX, MSG_REV
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_REVERSED
    LEA SI, STR_OUTPUT
    CALL SUB_INT_TO_ASCII
    LEA DX, STR_OUTPUT
    MOV AH, 09H
    INT 21H
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; SUBROUTINE: SUB_INT_TO_ASCII
; DESCRIPTION: Helper to visualize binary integers as decimal strings.
; -----------------------------------------------------------------------------
SUB_INT_TO_ASCII PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, 10
    XOR CX, CX
L_IA_LOOP1:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    PUSH DX
    INC CX
    CMP AX, 0
    JNE L_IA_LOOP1
    
L_IA_LOOP2:
    POP AX
    MOV [SI], AL
    INC SI
    LOOP L_IA_LOOP2
    
    ; Terminate string for DOS
    MOV BYTE PTR [SI], '$'
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SUB_INT_TO_ASCII ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. THE PEEL-AND-BUILD ALGORITHM:
;    Reversing a number involves two distinct phases:
;    (a) Decomposition: Breaking the number into its base-10 digits.
;    (b) Composition: Rebuilding the number using positional multiplication.
;
; 2. INTEGER OVERFLOW RISK:
;    The 8086 carries 16-bit registers (max 65535). If we attempt to reverse 
;    60,000, the result (00,006) fits. However, if we reverse 12,345 to 
;    54,321, it fits. But reversing 50,001 to 10,005 fits. Reversing 12,345 
;    to 54,321 works, but reversing 65,000 to something like 00,056 is fine. 
;    The danger is if the INPUT is small but its REVERSE exceeds 65535.
;
; 3. MATHEMATICAL LOGIC:
;    The composition logic 'Accumulator = (Accumulator * 10) + Digit' is the 
;    standard way to process strings or arrays of digits into scalar values.
;
; 4. ARRAY VS STACK:
;    While this program uses an array (DIGIT_ARRAY) for clarity, the same 
;    logic could be achieved using the CPU stack as temporary storage, 
;    saving a few bytes of data segment memory.
;
; 5. DOS INTERRUPT LIMITATIONS:
;    Note that the visual check (SUB_INT_TO_ASCII) is required because 'VAL_REVERSED' 
;    is stored as binary 1101010000110001 (54321). Without the conversion, 
;    the CPU would simply display the ASCII character corresponding to that 
;    binary value, which is not what the user expects.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
