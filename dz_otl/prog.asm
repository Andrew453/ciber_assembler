bits 16 


extern _password_check
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
    call _paintimage
    
    push ax
    push cx
    MOV AX,0xC6C0
    MOV CX, 0x002D
    PUSH AX
    PUSH CX
    CALL _sleep
    pop cx
    pop ax
    
    call _textmodeinit
    
    push clrf
    call _puts
    add sp, 2 
    ;пароль!
    jmp passwordcheck
passwordcheckerror: 
    push errorpass
    call _puts
    add sp, 2
    
    push clrf
    call _puts
    add sp, 2    
    
passwordcheck:
    push passtext
    call _puts
    add sp, 2
    
    push clrf
    call _puts
    add sp, 2
    
    push passstring
    call _gets
    push passstring 
    call _puts
    add sp,2
    
    push clrf
    call _puts
    add sp, 2
    ;; НОВЫЙ ПАРОЛЬ
;     push check_pass_bool
;     push 0x0009
;     push passstring
;     call _password_check
;     mov ax, [check_pass_bool]
;     cmp ax,0x01
    ;;  НОВЫЙ ПАРОЛЬ
    
    ;; СТАРЫЙ ПАРОЛЬ
    push passstring
    push pass
    call _cmpstr
    cmp ax,0x0001
    ;; СТАРЫЙ ПАРОЛЬ
    jne passwordcheckerror
    
    
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

    mov bx,0x28
    mov cx,0x28
    
    push cryptresult
    push bx
    push key
    push cx
    push text
        
    call _message_crypt
    add sp,10
    
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

check_pass_bool:
    db 0x00
entertext:
    db "Enter the string that needs to be encrypted (the string length is no more than   40 characters):", 0
getkey:
    db "Enter your key:",0
    
passtext:
    db "Enter password:",0
errorpass:
    db "Invalid password!",0
    
passstring;
    db "          ", 0
    
crypt:
    db "crypt     ", 0
decrypt:
    db "decrypt   ", 0
activity:
    db "What do you want to do? (crypt, decrypt):",0
choice:
    db "          ", 0
pass:
    db "hui       ", 0
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
ox:
    db 0
oy:
    db 0
    
    
_sleep:
    PUSH BP
    MOV BP,SP

    mov cx, [BP + 4]
    mov dx, [BP + 6]
    mov ah, 86h
    mov al, 0
    int 15h

    MOV SP,BP
    POP BP
    RET    
    
_gets:
    push bp
    mov bp, sp
    mov bx, [bp+4];
;   
;     push oy
;     push ox
;     call _getxy
;     add sp,2
;     mov cx,[ox]
;     mov dx,[oy]
;     inc dx
;     
loop:  
    
    call _getchar
    
    cmp al,0x0D
    JE exitgets
    mov [bx], al
    inc bx
    push ax
    call _putchar
;     
;     inc cx
;     push dx
;     push cx
;     call _gotoxy
;     add sp,2
;     
    JNE loop
exitgets:
;   
;     mov cx, 0
;     mov dx, 0
;     mov [ox], cx
;     mov [oy], dx
;     pop dx
;     pop cx
;   
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

%macro gotoxy 2
    MOV AH,0x02
    MOV BH, 0
    MOV DH, %2
    MOV DL, %1
    INT 0x10
%endmacro
    
%macro putchar 2
    MOV AH, 0x09
    MOV AL, %1
    MOV CX, 1
    MOV BL, %2
    MOV BH, 0 
    INT 0x10
%endmacro    
    
_paintimage:   
    MOV  AL, 2
    MOV AH, 0 
    INT 0x10    
gotoxy 0, 0
putchar '1', 0x02
gotoxy 1, 0
putchar '1', 0x02
gotoxy 2, 0
putchar '0', 0x02
gotoxy 3, 0
putchar '1', 0x02
gotoxy 4, 0
putchar '0', 0x02
gotoxy 5, 0
putchar '0', 0x02
gotoxy 6, 0
putchar '0', 0x02
gotoxy 7, 0
putchar '1', 0x02
gotoxy 8, 0
putchar '1', 0x02
gotoxy 9, 0
putchar '0', 0x02
gotoxy 10, 0
putchar '0', 0x02
gotoxy 11, 0
putchar '0', 0x02
gotoxy 12, 0
putchar '1', 0x02
gotoxy 13, 0
putchar '1', 0x02
gotoxy 14, 0
putchar '1', 0x02
gotoxy 15, 0
putchar '1', 0x02 
gotoxy 16, 0
putchar '1', 0x02
gotoxy 17, 0
putchar '0', 0x02
gotoxy 18, 0
putchar '0', 0x02
gotoxy 19, 0
putchar '0', 0x02
gotoxy 19, 0
putchar '0', 0x02
gotoxy 20, 0
putchar '0', 0x02
gotoxy 21, 0
putchar '1', 0x02
gotoxy 22, 0
putchar '1', 0x02
gotoxy 23, 0
putchar '0', 0x02
gotoxy 24, 0
putchar '1', 0x02
gotoxy 25, 0
putchar '0', 0x02
gotoxy 26, 0
putchar '0', 0x02
gotoxy 27, 0
putchar '0', 0x02
gotoxy 28, 0
putchar '0', 0x02
gotoxy 29, 0
putchar '0', 0x02
gotoxy 30, 0
putchar '1', 0x02
gotoxy 31, 0
putchar '0', 0x02
gotoxy 32, 0
putchar '1', 0x02
gotoxy 33, 0
putchar '1', 0x02
gotoxy 34, 0
putchar '1', 0x02
gotoxy 35, 0
putchar '0', 0x02
gotoxy 36, 0
putchar '1', 0x02
gotoxy 37, 0
putchar '1', 0x02
gotoxy 38, 0
putchar '1', 0x02
gotoxy 39, 0
putchar '1', 0x02
gotoxy 40, 0
putchar '0', 0x02
gotoxy 41, 0
putchar '1', 0x02
gotoxy 42, 0
putchar '0', 0x02
gotoxy 43, 0
putchar '0', 0x02
gotoxy 44, 0
putchar '0', 0x02
gotoxy 45, 0
putchar '1', 0x02
gotoxy 46, 0
putchar '1', 0x02
gotoxy 47, 0
putchar '0', 0x02
gotoxy 48, 0
putchar '0', 0x02
gotoxy 49, 0
putchar '0', 0x02
gotoxy 50, 0
putchar '1', 0x02
gotoxy 51, 0
putchar '1', 0x02
gotoxy 52, 0
putchar '1', 0x02
gotoxy 53, 0
putchar '0', 0x02
gotoxy 54, 0
putchar '1', 0x02
gotoxy 55, 0
putchar '1', 0x02
gotoxy 56, 0
putchar '0', 0x02
gotoxy 57, 0
putchar '1', 0x02
gotoxy 58, 0
putchar '0', 0x02
gotoxy 59, 0
putchar '0', 0x02
gotoxy 60, 0
putchar '0', 0x02
gotoxy 61, 0
putchar '0', 0x02
gotoxy 62, 0
putchar '1', 0x02
gotoxy 63, 0
putchar '0', 0x02
gotoxy 64, 0
putchar '1', 0x02
gotoxy 65, 0
putchar '1', 0x02
gotoxy 66, 0
putchar '0', 0x02
gotoxy 67, 0
putchar '0', 0x02
gotoxy 68, 0
putchar '0', 0x02
gotoxy 69, 0
putchar '1', 0x02
gotoxy 70, 0
putchar '1', 0x02
gotoxy 71, 0
putchar '1', 0x02
gotoxy 72, 0
putchar '0', 0x02
gotoxy 73, 0
putchar '1', 0x02
gotoxy 74, 0
putchar '0', 0x02
gotoxy 75, 0
putchar '0', 0x02
gotoxy 76, 0
putchar '0', 0x02
gotoxy 77, 0
putchar '0', 0x02
gotoxy 78, 0
putchar '1', 0x02
gotoxy 79, 0
putchar '0', 0x02
gotoxy 80, 0
putchar '1', 0x02


 gotoxy 29, 6
    putchar '*', 0x02
    gotoxy 30, 6
    putchar '*', 0x02
    gotoxy 31, 6
    putchar '*', 0x02
    gotoxy 32, 6
    putchar '*', 0x02
    gotoxy 33, 6
    putchar '*', 0x02

    gotoxy 27, 7
    putchar '*', 0x02
    gotoxy 28, 7
    putchar '*', 0x02

    gotoxy 29, 7
    putchar '*', 0x02
    gotoxy 30, 7
    putchar '*', 0x02
    gotoxy 31, 7
    putchar '*', 0x02
    gotoxy 32, 7
    putchar '*',0x02
    gotoxy 33, 7
    putchar '*', 0x02

    gotoxy 34, 7
    putchar '*', 0x02
    gotoxy 35, 7
    putchar '*', 0x02

    gotoxy 26, 8
    putchar '*', 0x02

    gotoxy 27, 8
    putchar '*', 0x02
    gotoxy 28, 8
    putchar '*', 0x02
    gotoxy 29, 8
    putchar '*', 0x02
    gotoxy 30, 8
    putchar '*', 0x02
    gotoxy 31, 8
    putchar '*', 0x02
    gotoxy 32, 8
    putchar '*', 0x02
    gotoxy 33, 8
    putchar '*', 0x02
    gotoxy 34, 8
    putchar '*', 0x02
    gotoxy 35, 8
    putchar '*', 0x02

    gotoxy 36, 8
    putchar '*', 0x02

    gotoxy 25, 9
    putchar '*', 0x02

    gotoxy 26, 9
    putchar '*', 0x02
    gotoxy 27, 9
    putchar '*', 0x02
    gotoxy 28, 9
    putchar '*', 0x02
    gotoxy 29, 9
    putchar '*', 0x02
    gotoxy 30, 9
    putchar '*', 0x02
    gotoxy 31, 9
    putchar '*', 0x02
    gotoxy 32, 9
    putchar '*', 0x02
    gotoxy 33, 9
    putchar '*', 0x02
    gotoxy 34, 9
    putchar '*', 0x02
    gotoxy 35, 9
    putchar '*', 0x02
    gotoxy 36, 9
    putchar '*', 0x02

    gotoxy 37, 9
    putchar '*', 0x02

    gotoxy 25, 10
    putchar '*', 0x02

    gotoxy 26, 10
    putchar '*', 0x02
    gotoxy 27, 10
    putchar '*', 0x02
    gotoxy 28, 10
    putchar '*', 0x02
    gotoxy 29, 10
    putchar '*', 0x02
    gotoxy 30, 10
    putchar '*', 0x02
    gotoxy 31, 10
    putchar '*', 0x02
    gotoxy 32, 10
    putchar '*', 0x02
    gotoxy 33, 10
    putchar '*', 0x02
    gotoxy 34, 10
    putchar '*', 0x02
    gotoxy 35, 10
    putchar '*', 0x02
    gotoxy 36, 10
    putchar '*', 0x02

    gotoxy 37, 10
    putchar '*', 0x02

    gotoxy 24, 11
    putchar '*', 0x02

    gotoxy 25, 11
    putchar '*', 0x02
    
    gotoxy 26, 11
    putchar '*', 0x02

    gotoxy 27, 11
    putchar '*', 0x02
    gotoxy 28, 11
    putchar '*', 0x02

    gotoxy 29, 11
    putchar '*', 0x02
    gotoxy 30, 11
    putchar '*', 0x02

    gotoxy 31, 11
    putchar '*', 0x02
    gotoxy 32, 11
    putchar '*', 0x02

    gotoxy 33, 11
    putchar '*', 0x02
    gotoxy 34, 11
    putchar '*', 0x02
    gotoxy 35, 11
    putchar '*', 0x02
    gotoxy 36, 11
    putchar '*', 0x02
    gotoxy 37, 11
    putchar '*', 0x02

    gotoxy 38, 11
    putchar '*', 0x02

    gotoxy 24, 12
    putchar '*', 0x02

    gotoxy 25, 12
    putchar '*', 0x02

    gotoxy 26, 12
    putchar '*', 0x02
    gotoxy 27, 12
    putchar '*', 0x02
    gotoxy 28, 12
    putchar '*', 0x02

    gotoxy 29, 12
    putchar '*', 0x02
    gotoxy 30, 12
    putchar '*', 0x02

    gotoxy 31, 12
    putchar '*', 0x02
    gotoxy 32, 12
    putchar '*', 0x02
    gotoxy 33, 12
    putchar '*', 0x02

    gotoxy 34, 12
    putchar '*', 0x02
    gotoxy 35, 12
    putchar '*', 0x02
    gotoxy 36, 12
    putchar '*', 0x02
    gotoxy 37, 12
    putchar '*', 0x02
    gotoxy 24, 12
    putchar '*', 0x02

    gotoxy 38, 12
    putchar '*', 0x02

    gotoxy 24, 13
    putchar '*', 0x02

    gotoxy 25, 13
    putchar '*', 0x02

    gotoxy 26, 13
    putchar '*', 0x02
    gotoxy 27, 13
    putchar '*', 0x02
    gotoxy 28, 13
    putchar '*', 0x02

    gotoxy 29, 13
    putchar '*', 0x02
    gotoxy 30, 13
    putchar '*', 0x02

    gotoxy 31, 13
    putchar '*', 0x02
    gotoxy 32, 13
    putchar '*', 0x02
    gotoxy 33, 13
    putchar '*', 0x02

    gotoxy 34, 13
    putchar '*', 0x02
    gotoxy 35, 13
    putchar '*', 0x02
    gotoxy 36, 13
    putchar '*', 0x02
    gotoxy 37, 13
    putchar '*', 0x02
    gotoxy 24, 13
    putchar '*', 0x02

    gotoxy 38, 13
    putchar '*', 0x02

    gotoxy 24, 14
    putchar '*', 0x02

    gotoxy 25, 14
    putchar '*', 0x02

    gotoxy 26, 14
    putchar '*', 0x02
    gotoxy 27, 14
    putchar '*', 0x02
    gotoxy 28, 14
    putchar '*', 0x02

    gotoxy 29, 14
    putchar '*', 0x02
    gotoxy 30, 14
    putchar '*', 0x02

    gotoxy 31, 14
    putchar '*', 0x02
    gotoxy 32, 14
    putchar '*', 0x02
    gotoxy 33, 14
    putchar '*', 0x02

    gotoxy 34, 14
    putchar '*', 0x02
    gotoxy 35, 14
    putchar '*', 0x02
    gotoxy 36, 14
    putchar '*', 0x02
    gotoxy 37, 14
    putchar '*', 0x02
    gotoxy 24, 14
    putchar '*', 0x02

    gotoxy 38, 14
    putchar '*', 0x02

    gotoxy 24, 15
    putchar '*', 0x02

    gotoxy 25, 15
    putchar '*', 0x02

    gotoxy 26, 15
    putchar '*', 0x02
    gotoxy 27, 15
    putchar '*', 0x02
    gotoxy 28, 15
    putchar '*', 0x02

    gotoxy 29, 15
    putchar '*', 0x02
    gotoxy 30, 15
    putchar '*', 0x02

    gotoxy 31, 15
    putchar '*', 0x02
    gotoxy 32, 15
    putchar '*', 0x02
    gotoxy 33, 15
    putchar '*', 0x02

    gotoxy 34, 15
    putchar '*', 0x02
    gotoxy 35, 15
    putchar '*', 0x02
    gotoxy 36, 15
    putchar '*', 0x02
    gotoxy 37, 15
    putchar '*', 0x02
    gotoxy 38, 15
    putchar '*', 0x02
    ret

    
    
section .DATA    

