bits 16 

extern _message_crypt
extern _message_decrypt
extern _puts
extern _gotoxy
extern _getxy

section .TEXT

global start 

resb 100h
start: 
    ; преамбула преднастройка окружения программы
    cli 
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov bp, 0xFFFF
    mov sp, 0xFFFF
    sti
    ; функция очистки и установки экрана(без аргументов)
    call _textmodeinit
    ; вывод начального вопроса - что делать?
    push activity
    call _puts
    add sp, 2
    
    push clrf
    call _puts
    add sp, 2
    
    ; чтение ответа
    push choice
    call _gets
    push choice 
    call _puts
    add sp,2
    
    ; сравнение ответа со строкой crypt
    push choice
    push crypt
    call _cmpstr
    cmp ax,0x0001
    je cr
    
    ; сравнение ответа со строкой decrypt
    push choice
    push decrypt
    call _cmpstr
    cmp ax, 0x0001
    je decr
    jmp error
    ;обработка неправильного ввода - вывод ошибки и завершение программы
error:
    push errortext
    call _puts
    add sp, 2
    int 20h
    
cr:
decr:
    xor ax,ax
    
    push clrf
    call _puts
    add sp, 2
    
    ;вывод сообщения с просьбой ввести строку для шифрования
    push entertext
    call _puts
    add sp, 2
    
    push clrf
    call _puts
    add sp, 2
    
    ; чтение текста для шифрования/дешифрования
    push text
    call _gets
    push text 
    call _puts
    add sp,2
    
    push clrf
    call _puts
    add sp, 2
    ; вывод сообщения о вводе ключа
    push getkey
    call _puts
    add sp, 2
    
    push clrf
    call _puts
    add sp, 2
    ; чтение ключа в память
    push key
    call _gets
    push key
    call _puts
    add sp,2
    

    
    ;; шифрование

;     xor ax,ax
    mov bx,0x28
    mov cx,0x28
    
    push cryptresult
    push bx
    push key
    push cx
    push text
        
    call _message_crypt
    add sp,10
    
;     push clrf
;     call _puts
;     add sp, 2
    ; вывод итогового расшифрованного/зашифрованного сообщения
;     push clrf
;     call _puts
;     add sp, 2
    push clrf
    call _puts
    add sp, 2
    
    push thanks
    call _puts
    add sp,2
    
    push clrf
    call _puts
    add sp, 2
    
    push cryptresult
    call _puts
    add sp, 2
    
    int 20h

entertext:
    db "Enter the string that needs to be encrypted (the string length is no more than   40 characters):", 0
getkey:
    db "Enter your key:",0
crypt:
    db "crypt     ",0
decrypt:
    db "decrypt   ",0
activity:
    db "What do you want to do? (crypt, decrypt):",0
choice:
    db "          ",0
pass:
    db "hui", 0
cryptresult:
    db  "                                        ",0
    
errortext:
    db "Error: invalid input!",0
thanks:
    db "Successful! Your message:",0
clrf:
    db 13, 10, 0
n1:
    dd 1.0
text:
    db "                                        ", 0
key:
    db "                                        ", 0    
    
_gets:
    push bp
    mov bp, sp
    mov bx, [bp+4];
loop:
    call _getchar
    
    cmp al,0x0D
    JE exitgets
    mov [bx], al
    inc bx
    push ax
    call _putchar
    JNE loop
exitgets:
    mov sp, bp
    pop bp
    ret

_getchar:
    mov ah, 0x00
    int 16h
    ret
    
_putchar:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    mov ax, [bp+4]; символ который будем писать
    mov ah, 0x09;команда на перезапись символа
    mov bl, 0x07;видеоатрибут
    mov cx, 1; сколько символов записать
    mov bh, 0; номер видеостраницы
    int 0x10;
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_textmodeinit:
        push ax
        mov ax,0003h
        int 10h
        pop ax    
        inc bx
;функция сравнения строк.        
_cmpstr:
    PUSH BP
    MOV BP, SP
    MOV BX, [BP + 4]
    MOV CX, [BP + 6]
;  Посимвольное сравнение строк, чтение параллельное
cyclecmpstr:    
    MOV AH, [BX]
    PUSH BX
    MOV BX, CX
    MOV AL, [BX]
    POP BX
    INC BX
    INC CX
    CMP AH, AL
    JNE out
    CMP AH, 0x00;
    JNE cyclecmpstr
    MOV AX, 0x0001
exit:    
    MOV SP, BP
    POP BP
    RET
    
out:
    MOV AX, 0x0000
    JMP exit
    
;     Функция подсчета длины строки.
_strlen:
    push bx
    push cx
    
    PUSH BP
    MOV BP, SP
    MOV BX, [BP + 4];
cycle:    
    MOV AX, [BX]
    CMP AL, 0x00;
    JE return;
    INC CX
    INC BX
    JMP cycle;
    
return:
    pop cx
    pop bx
    MOV AX, CX;
    MOV SP, BP
    POP BP;
    RET;    
    
    
section .DATA    

