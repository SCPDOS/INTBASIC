getLineInput:
;Null terminates the string that was input, replacing the ending CR!
;Parses the input so that all chars are uppercased except those enclosed in speechmarks
    xor ah, ah
    mov byte [strLen], ah   ;Zero the char counter
    lea rdi, inString   ;Move to start of line
    mov rsi, rdi
    push rdi
    mov ecx, maxLineLen
    xor al, al    ;Ensure the input line is sanitised
    rep stosb
    pop rdi
    xor ecx, ecx    ;Use cl as a counter for speech marks, which dictates UC-ing chars
.getChar:
    call ttyIn
    cmp al, CR ;Carriage return
    je .gliExit
    cmp al, LF
    je .getChar ;Ignore line feed chars
    cmp al, BSP ;Bspace
    je .glibspace
    cmp byte [strLen], -2   ;If at max length (255 chars), simply beep and wait for either bspace or enter
    je .gliFull 
    cmp al, byte '"'
    je .gspchMk
    test al, al
    je .gliExtendedChar
    jmp short .gliCheckCase
.gspchMk:
;Here if a speech mark.
    inc cl      ;Speech mark hit, inc count
    jmp short .gliCheckCase
.glibspace:
    test byte [strLen], -1  ;This will only be zero if strLen=0
    jz .getChar
    dec rdi ;Go back by one position in the input line
    dec byte [strLen]
    mov al, BSP
    call ttyOutChar
    mov al, SPC  
    call ttyOutChar
    mov al, BSP
    call ttyOutChar
    jmp short .getChar
.gliCheckCase:
    ;al has char
    call ttyOutChar ;Echo the char as is, but store it uppercase if cl is even
    test cl, 1      ;UC char if cl is even only
    jnz .gStore
    call ucChar
.gStore:
    stosb   ;Increment the pointer, add char to buffer
    inc byte [strLen]   ;Inc char count
    jmp short .getChar
.gliExtendedChar:
    ;Currently, extended chars do nothing, 
    ; eventually add F1-F10 functionality
    ; and arrow key support
    jmp short .getChar
.gliExit:
    lea rbp, crlf
    call ttyOutString
    mov byte [rdi], 0   ;Null terminate string here
    ret
.gliFull:
    mov al, 07h
    call ttyOutChar
    jmp .getChar

ucChar:
;Input: al = Char to uppercase
;Output: al = Adjusted char 
    push rbx    ;Save on original stack
    push rax    ;Put the word on the stack
    mov eax, 1213h  ;Uppercase the char in al
    int 2fh
    pop rbx     ;Pop off the word we placed on the stack
    pop rbx     ;Get back original rbx
    ret

ttyOutChar:
    push rdx
    mov dl, al
    mov eax, 0200h   ;Output char!
    int 21h
    pop rdx
    ret
ttyOutString:
;Print 0 terminated strings
;Input: rbp -> String
    push rbx
    push rcx
    push rdx
    push rsi
    mov rsi, rbp
    call strlen     ;Get the length of the string to print in ecx
    dec ecx         ;Drop the terminating null
    mov rdx, rbp    ;Get string ptr
    mov ebx, 1      ;STDOUT
    mov eax, 4000h  ;Write!
    int 21h 
    pop rsi    
    pop rdx
    pop rcx
    pop rbx
    ret
ttyIn:
;Output: al -> ASCII char
    mov eax, 0800h  ;Input no echo to tty
    int 21h
    ret
ttyClear:
;Use Int 2Eh to get command.com to violate the hardware abstraction for us.
;Or just add ANSI clear code to our basic driver (probably easier...)
    ;mov eax, 0500h  ;Set page zero as the default page
    ;int 30h
    ;mov ah, 02h
    ;xor edx, edx    ;Set screen cursor to top right corner
    ;mov bh, dl      ;Set cursor for page 0
    ;int 30h
    ;mov bh, 07h     ;Grey/Black attribs
    ;mov eax, 0600h  ;Clear whole screen
    ;int 30h
    ;ret
    push rsi
    lea rsi, .s
    int 2Eh
    pop rsi
    ret
.s: db 03h, "CLS",CR