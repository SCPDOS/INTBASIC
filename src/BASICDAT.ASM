prompt  db "Ok",LF,CR,0
mainmsg db "SCR INTBASIC/64 v0.1",LF,CR,0
cpyrt   db "Copyright (c) 2022, 2024 Yll Buzoku",LF,CR, "All rights reserved.",CR,LF,0
bytemsg db " Bytes free",LF,CR,0
crlf    db LF,CR,0
errmsg  db "Error",LF,CR,0
numbers db "0123456789"
;startVarChars db "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ;Valid starting chars for a var name
;numStartVarChars equ $ - startVarChars
varChrs db "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789%$" ;Valid inner chars for var name
numVarChars equ $ - varChrs
;% => Integer variable (8 bytes)
;! => Single-Precision, Unused and ignored
;# => Double-Precision, Unused and ignored
;$ => String variable

;Error Messages
noMem   db "Out of memory",LF,CR,0
syntax  db "Syntax error",LF,CR,0
typeError   db "Type mismatch",LF,CR,0
lineNoXist  db "Undefined line number",LF,CR,0
breakmsg db "Break in ",0
stkOvflw db "Stack overflow",LF,CR,0

noWend   db "WHILE without WEND", LF, CR, 0
noWhile  db "WEND without WHILE", LF, CR, 0
noFor    db "NEXT without FOR", LF, CR, 0
noNext   db "FOR without NEXT", LF, CR, 0
noReturn db "RETURN without GOSUB", LF, CR, 0
uknowner db "Unprintable error", LF, CR, 0

divZer   db "Division by zero", LF, CR, 0

;Simple char equates
CR  equ 0Dh
LF  equ 0Ah