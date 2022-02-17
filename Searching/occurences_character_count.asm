;An Assembly Language Program to search for a character in a given string and calculate the number 
;of occurrences of the character in the given string
DATA SEGMENT
    MSG1 DB 10,13,'ENTER ANY STRING :- $'
    MSG2 DB 10,13,'ENTER ANY CHARACTER :- $'
    MSG3 DB 10,13,' $'
    MSG4 DB 10,13,'NO, CHARACTER FOUND IN THE GIVEN STRING $' 
    MSG5 DB ' CHARACTER(S) FOUND IN THE GIVEN STRING $'
    CHAR DB ?
    COUNT DB 0
    P1 LABEL BYTE
    M1 DB 0FFH
    L1 DB ?
    P11 DB 0FFH DUP ('$')
DATA ENDS
