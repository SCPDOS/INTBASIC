start:
    ;mov eax, 0C501h
    ;int 35h         ;Connect the debugger
    breakpoint
    call ttyClear   ;Clear the teletype
    ;Memory stuff
    lea rbp, mainmsg
    call ttyOutString
    lea rbp, cpyrt
    call ttyOutString
    mov rbp, rsp    ;Pass the original stack pointer to the function
    call memoryDetection
    lea rbp, bytemsg
    call ttyOutString
    lea rsp, stacktop    ;Reinitialize stack pointer
    call newProgram         ;Use this to reset program pointers
    mov byte [stateByte], 0 ;Init the byte to 0
mainLoop:
;Entering here resets the program counter but doesnt remove the program from memory
    mov ax, word [firstLinNum]  ;Error occured, restart the program counter
    mov word [currentLine], ax

    cld                 ;Set default string op direction
    lea rsp, stacktop    ;Reinitialize stack pointer
    and byte [stateByte], 0FEh  ;Clear the break bit
    lea rbp, prompt
    call ttyOutString
    lea rax, mainLoop
    push rax    ;Save address on stack
.ml0:
;This section will execute an input line if it is an interactive expression
; or store it in the program if it has a line number.
;It will keep accepting lines until a line is entered without a line number
    call getLineInput
    lea rsi, inString   ;Point to the string for the below!
    call decimalToHex   ;Check to see if we have a valid line number
    test ax, ax
    jnz .saveLine
;Here we execute the line, move rsi to the start of the line
    lea rsi, inString
    jmp runLine
.saveLine:
    ;ax has the line number
    mov dx, ax
    call searchForProgramLine
    cmp rbx, -1
    jne .commonProc ;If not equal, line must exist, continue
    call spaceSkip  ;Skip all the prceeding spaces
    cmp byte [rsi], 0  ;Is the first non space char the end of the string?
    je .lineDoesntExist
    ;So we have a new line that isn't empty, allocate a new block for this line
    call allocateBlock  ;Return a default block in rbx
    mov byte [rbx + progLineBlock.bBlockType], progLineBlockType
    mov word [rbx + progLineBlock.wLineNum], ax
    mov word [rbx + progLineBlock.wBlockSize], progLineBlock_size
.commonProc:
    ;If the line already exists, simply override the stored string
    ;rbx has a pointer to the block
    call strlen ;Get the string length
    lea rdi, qword [rbx + progLineBlock.sLine]  ;Get address here
    call strcpy ;Copy the program string to the program block
    push rsi
    mov rsi, rbx    ;Move the block into rsi
    call insertProgramLine
    pop rsi
    jmp short .ml0
.lineDoesntExist:
    lea rbp, lineNoXist
;For any error, syntax or otherwise, come here
criticalError:
;Called with rbp pointing at error message
    call ttyOutString
    mov byte [stateByte], 0 ;Reset the state byte
    jmp mainLoop    ;Trash input line, restart line input

ctrlBreakHandler:
    or byte [stateByte], 1  ;Set the byte
    iretq
setHandler:
;Called with:
;   rdi = Pointer to interrupt handler
;   al = Interrupt number
    push rdx
    mov rdx, rdi
    mov ah, 35h
    int 21h
    pop rdx
    ret