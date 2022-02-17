;TO COUNT THE NUMBER OF WORDS PRESENTED IN THE ENTERED SENTENCE.

.MODEL SMALL
.STACK 64
.DATA
MAXLEN Db 100
            ACTCHAR Db ?
            STR DB 101 DUP('$')
            STR1 DB "NO. OF WORDS IS ",'$'
.CODE
MAIN PROC FAR
            MOV AX, @DATA
            MOV DS, AX
MOV CX, 00
            MOV BX, 00
            MOV AX, 00
            LEA DX, MAXLEN
            MOV AH, 0AH
            INT 21H

     
MOV CH, 00H
            MOV Cl, ACTCHAR
            MOV DX, 0100H
            CMP STR [0], ' '
            JNZ L1
            SUB DH, 01

L1:       CMP STR [BX], ' '
            JNZ L3
L2:       INC BX
            DEC CX
            CMP STR [BX], ' '
            JZ l2
            INC DH
            CMP DH, 0AH
            JB L3
            MOV DH, 00
            INC DL
L3:       INC BX
            LOOP L1
            CMP STR [BX-1], ' '
            JNZ L4
            SUB DH, 01
            JNC L4
            SUB DL, 01
            ADD DH, 0AH

  L4:     MOV BX, DX
            MOV AH, 02H
            MOV DL, 0AH
            INT 21H
            MOV DL, 0DH
            INT 21H
            LEA DX, STR1
            MOV AH, 09H
            INT 21H

            MOV DX, BX
            ADD DL, 30H
            MOV AH, 02H
            INT 21H
            ADD DH, 30H
            MOV DL, DH
            MOV AH, 02H
            INT 21H
            MOV AX, 4C00H
            INT 21H
  MAIN ENDP
  END MAIN
