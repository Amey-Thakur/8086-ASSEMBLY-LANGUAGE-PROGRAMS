;8086 PROGRAM: COUNT NUMBER OF VOWELS IN GIVEN LINE OF A TEXT/SENTENCE
.MODEL SMALL
 
.STACK 100H 
          
.DATA
  STRING DB 10,13,"The quick brown fox jumped over lazy sleeping dog$"
  VOWEL DB ?
  MSG1 DB 10,13,"Number of vowels are: $"
 
 .CODE
  MAIN PROC
  MOV AX, @DATA
  MOV DS, AX
  MOV SI, OFFSET STRING  
  MOV BL, 00     
 
  BACK: MOV AL, [SI]
        CMP AL,'$'
        JZ FINAL
        CMP AL,'A'
        JZ COUNT   
        CMP AL,'E'
        JZ COUNT   
        CMP AL,'I'
        JZ COUNT   
        CMP AL,'O'
        JZ COUNT   
        CMP AL,'U'
        JZ COUNT
        CMP AL,'a'
        JZ COUNT   
        CMP AL,'e'
        JZ COUNT   
        CMP AL,'i'
        JZ COUNT   
        CMP AL,'o'
        JZ COUNT   
        CMP AL,'u'
        JZ COUNT   
        INC SI
        JMP BACK

  COUNT: INC BL
        INC SI
        JMP BACK

  FINAL: MOV AH,2H
        MOV DL,BL
        INT 21H         ;print number of vowels

        MOV AH, 4CH
        INT 21H
MAIN ENDP
END
