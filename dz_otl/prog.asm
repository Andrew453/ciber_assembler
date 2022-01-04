bits 16 


extern _password_check
extern _message_crypt
extern _message_decrypt
extern _puts
extern _gotoxy
extern _getxy


global start 
global _crcTab

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
    call _create_file
    
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
    call _gets_star
;     push passstring 
;     call _puts
;     add sp,2
    
    push clrf
    call _puts
    add sp, 2
    ;; НОВЫЙ ПАРОЛЬ
    push check_pass_bool
    push 0x0009
    push passstring
    call _password_check
    mov al, [check_pass_bool]
    cmp al,1
    ;;  НОВЫЙ ПАРОЛЬ
    
    ;; СТАРЫЙ ПАРОЛЬ
;     push passstring
;     push pass
;     call _cmpstr
;     cmp ax,0x0001
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
    
    push text
    call _write_to_file
    
;     push clrf
;     call _write_to_file
    
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
    
    push key
    call _write_to_file
    
;     push clrf 
;     call _write_to_file
    
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
    
    push cryptresult
    call _write_to_file
    
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
    db "          ", 0
cryptresult:
    db  "                                        ",0
    
text:
    db "                                        ", 0
key:
    db "                                        ", 0    
ox:
    db 0
oy:
    db 0
errortext:
    db "Error: invalid input!",0
thanks:
    db "Successful! Your message:",0
clrf:
    db 13, 10, 0
n1:
    dd 1.0    
filename db "slejka.txt",0  


_crcTab:
	dw 0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7
	dw 0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef
	dw 0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6
	dw 0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de
	dw 0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485
	dw 0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d
	dw 0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4
	dw 0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc
	dw 0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823
	dw 0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b
	dw 0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12
	dw 0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a
	dw 0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41
	dw 0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49
	dw 0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70
	dw 0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78
	dw 0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f
	dw 0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067
	dw 0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e
	dw 0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256
	dw 0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d
	dw 0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405
	dw 0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c
	dw 0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634
	dw 0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab
	dw 0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3
	dw 0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a
	dw 0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92
	dw 0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9
	dw 0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1
	dw 0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8
	dw 0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
    

_create_file:
    mov ah, 3Ch
    mov cx, 0          ; attributes
    mov dx, filename
    int 21h            ; create our file
    ret                ; return


_write_to_file:
    PUSH BP
    MOV BP,SP
    mov cx, [BP + 4]
    mov ah, 3Dh       ; File Open func
    mov dx, filename   ; file we want to open
    xor al, 2         ; no access modes
    int 21h            ; Open!
                   ; if file was opened ax contains file handle
    mov bx, ax         ; save file handle to bx (write func needs file handle in bx)
    mov ah, 0x40       ; Write to file func
    mov dx, cx ; speaks for itself
    mov cx, 122        ; Bytes to write (yes my text takes 78 bytes)
    int 21h            ; Write to file
    mov ah, 0x3E ; close our file, bx still has file handle
    int 21h
    MOV SP,BP
    POP BP
    RET   
    ret    
    
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
    
_gets_star:
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
loop_star:  
    
    call _getchar
    
    cmp al,0x0D
    JE exitgets_star
    mov [bx], al
    inc bx
    push '*'
    call _putchar
;     
;     inc cx
;     push dx
;     push cx
;     call _gotoxy
;     add sp,2
;     
    JNE loop_star
exitgets_star:
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
putchar '1', 0x012
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

gotoxy 0, 1
putchar '1', 0x02
gotoxy 1, 1
putchar '1', 0x02
gotoxy 2, 1
putchar '0', 0x02
gotoxy 3, 1
putchar '1', 0x02
gotoxy 4, 1
putchar '1', 0x02 
gotoxy 5, 1
putchar '1', 0x02
gotoxy 6, 1
putchar '1', 0x02
gotoxy 7, 1
putchar '0', 0x02
gotoxy 8, 1
putchar '1', 0x02
gotoxy 9, 1
putchar '0', 0x02
gotoxy 10, 1
putchar '0', 0x02
gotoxy 11, 1
putchar '0', 0x02
gotoxy 12, 1
putchar '1', 0x02 
gotoxy 13, 1
putchar '1', 0x02
gotoxy 14, 1
putchar '0', 0x02
gotoxy 15, 1
putchar '0', 0x02  
gotoxy 16, 1
putchar '0', 0x02
gotoxy 17, 1
putchar '1', 0x02
gotoxy 18, 1
putchar '1', 0x02
gotoxy 19, 1
putchar '1', 0x02
gotoxy 19, 1
putchar '0', 0x02 
gotoxy 20, 1
putchar '1', 0x02 
gotoxy 21, 1
putchar '0', 0x02
gotoxy 22, 1
putchar '0', 0x02
gotoxy 23, 1
putchar '0', 0x02
gotoxy 24, 1
putchar '0', 0x02
gotoxy 25, 1
putchar '0', 0x02 
gotoxy 26, 1
putchar '1', 0x02
gotoxy 27, 1
putchar '1', 0x02
gotoxy 28, 1
putchar '0', 0x02
gotoxy 29, 1
putchar '1', 0x02 
gotoxy 30, 1
putchar '0', 0x02
gotoxy 31, 1
putchar '0', 0x02
gotoxy 32, 1
putchar '0', 0x02
gotoxy 33, 1
putchar '1', 0x02 
gotoxy 34, 1
putchar '1', 0x02
gotoxy 35, 1
putchar '0', 0x02
gotoxy 36, 1
putchar '0', 0x02
gotoxy 37, 1
putchar '0', 0x02 
gotoxy 38, 1
putchar '1', 0x02
gotoxy 39, 1
putchar '1', 0x02
gotoxy 40, 1
putchar '1', 0x02
gotoxy 41, 1
putchar '1', 0x02 
gotoxy 42, 1
putchar '1', 0x02
gotoxy 43, 1
putchar '1', 0x02
gotoxy 44, 1
putchar '0', 0x02
gotoxy 45, 1
putchar '1', 0x02 
gotoxy 46, 1
putchar '0', 0x02
gotoxy 47, 1
putchar '0', 0x02
gotoxy 48, 1
putchar '0', 0x02
gotoxy 49, 1
putchar '0', 0x02 
gotoxy 50, 1
putchar '1', 0x02
gotoxy 51, 1
putchar '0', 0x02
gotoxy 52, 1
putchar '1', 0x02
gotoxy 53, 1
putchar '1', 0x02  
gotoxy 54, 1
putchar '1', 0x02
gotoxy 55, 1
putchar '1', 0x02
gotoxy 56, 1
putchar '1', 0x02
gotoxy 57, 1
putchar '1', 0x02 
gotoxy 58, 1
putchar '1', 0x02
gotoxy 59, 1
putchar '1', 0x02
gotoxy 60, 1
putchar '0', 0x02
gotoxy 61, 1
putchar '1', 0x02 
gotoxy 62, 1
putchar '0', 0x02
gotoxy 63, 1
putchar '0', 0x02
gotoxy 64, 1
putchar '0', 0x02
gotoxy 65, 1
putchar '0', 0x02 
gotoxy 66, 1
putchar '1', 0x02
gotoxy 67, 1
putchar '0', 0x02
gotoxy 68, 1
putchar '1', 0x02
gotoxy 69, 1
putchar '1', 0x02 
gotoxy 70, 1
putchar '1', 0x02
gotoxy 71, 1
putchar '1', 0x02
gotoxy 72, 1
putchar '0', 0x02
gotoxy 73, 1
putchar '1', 0x02 
gotoxy 74, 1
putchar '1', 0x02
gotoxy 75, 1
putchar '1', 0x02
gotoxy 76, 1
putchar '0', 0x02
gotoxy 77, 1
putchar '1', 0x02 
gotoxy 78, 1
putchar '0', 0x02
gotoxy 79, 1
putchar '0', 0x02
gotoxy 80, 1
putchar '0', 0x02

gotoxy 0, 2
putchar '1', 0x02 
gotoxy 1, 2
putchar '1', 0x02
gotoxy 2, 2
putchar '0', 0x02
gotoxy 3, 2
putchar '0', 0x02
gotoxy 4, 2
putchar '0', 0x02
gotoxy 5, 2
putchar '0', 0x02
gotoxy 6, 2
putchar '1', 0x02
gotoxy 7, 2
putchar '1', 0x02
gotoxy 8, 2
putchar '1', 0x02
gotoxy 9, 2
putchar '0',0x02
gotoxy 10, 2
putchar '0', 0x02
gotoxy 11, 2
putchar '0', 0x02
gotoxy 12, 2
putchar '1', 0x02
gotoxy 13, 2
putchar '1', 0x02
gotoxy 14, 2
putchar '1', 0x02
gotoxy 15, 2
putchar '1', 0x02  
gotoxy 16, 2
putchar '1', 0x02
gotoxy 17, 2
putchar '0', 0x02
gotoxy 18, 2
putchar '0', 0x02
gotoxy 19, 2
putchar '0', 0x02
gotoxy 19, 2
putchar '0', 0x02
gotoxy 20, 2
putchar '0', 0x02 
gotoxy 21, 2
putchar '1', 0x02
gotoxy 22, 2
putchar '1', 0x02
gotoxy 23, 2
putchar '0', 0x02
gotoxy 24, 2
putchar '1', 0x02
gotoxy 25, 2
putchar '0', 0x02
gotoxy 26, 2
putchar '0', 0x02
gotoxy 27, 2
putchar '0', 0x02
gotoxy 28, 2
putchar '0', 0x02
gotoxy 29, 2
putchar '0', 0x02 
gotoxy 30, 2
putchar '1', 0x02
gotoxy 31, 2
putchar '0', 0x02
gotoxy 32, 2
putchar '1', 0x02
gotoxy 33, 2
putchar '1', 0x02
gotoxy 34, 2
putchar '1', 0x02
gotoxy 35, 2
putchar '0', 0x02
gotoxy 36, 2
putchar '1', 0x02
gotoxy 37, 2
putchar '1', 0x02 
gotoxy 38, 2
putchar '1', 0x02
gotoxy 39, 2
putchar '1', 0x02
gotoxy 40, 2
putchar '0', 0x02
gotoxy 41, 2
putchar '1', 0x02
gotoxy 42, 2
putchar '0', 0x02
gotoxy 43, 2
putchar '0', 0x02
gotoxy 44, 2
putchar '0', 0x02
gotoxy 45, 2
putchar '1', 0x02 
gotoxy 46, 2
putchar '1', 0x02
gotoxy 47, 2
putchar '0', 0x02
gotoxy 48, 2
putchar '0', 0x02
gotoxy 49, 2
putchar '0', 0x02
gotoxy 50, 2
putchar '1', 0x02
gotoxy 51, 2
putchar '1', 0x02
gotoxy 52, 2
putchar '1', 0x02
gotoxy 53, 2
putchar '0', 0x02  
gotoxy 54, 2
putchar '1', 0x02
gotoxy 55, 2
putchar '1', 0x02
gotoxy 56, 2
putchar '0', 0x02
gotoxy 57, 2
putchar '1', 0x02
gotoxy 58, 2
putchar '0', 0x02
gotoxy 59, 2
putchar '0', 0x02
gotoxy 60, 2
putchar '0', 0x02
gotoxy 61, 2
putchar '0', 0x02 
gotoxy 62, 2
putchar '1', 0x02
gotoxy 63, 2
putchar '0', 0x02
gotoxy 64, 2
putchar '1', 0x02
gotoxy 65, 2
putchar '1', 0x02
gotoxy 66, 2
putchar '0', 0x02
gotoxy 67, 2
putchar '0', 0x02
gotoxy 68, 2
putchar '0', 0x02
gotoxy 69, 2
putchar '1', 0x02 
gotoxy 70, 2
putchar '1', 0x02
gotoxy 71, 2
putchar '1', 0x02
gotoxy 72, 2
putchar '0', 0x02
gotoxy 73, 2
putchar '1', 0x02
gotoxy 74, 2
putchar '0', 0x02
gotoxy 75, 2
putchar '0', 0x02
gotoxy 76, 2
putchar '0', 0x02
gotoxy 77, 2
putchar '0', 0x02 
gotoxy 78, 2
putchar '1', 0x02
gotoxy 79, 2
putchar '0', 0x02
gotoxy 80, 2
putchar '1', 0x02

gotoxy 0, 3
putchar '1', 0x02
gotoxy 1, 3
putchar '1', 0x02
gotoxy 2, 3
putchar '0', 0x02
gotoxy 3, 3
putchar '1', 0x02
gotoxy 4, 3
putchar '0', 0x02
gotoxy 5, 3
putchar '0', 0x02
gotoxy 6, 3
putchar '0', 0x02
gotoxy 7, 3
putchar '1', 0x02
gotoxy 8, 3
putchar '1', 0x02
gotoxy 9, 3
putchar '0', 0x02
gotoxy 10, 3
putchar '0', 0x02
gotoxy 11, 3
putchar '0', 0x02
gotoxy 12, 3
putchar '1', 0x02
gotoxy 13, 3
putchar '1', 0x02
gotoxy 14, 3
putchar '1', 0x02
gotoxy 15, 3
putchar '1', 0x02  
gotoxy 16, 3
putchar '1', 0x02
gotoxy 17, 3
putchar '0', 0x02
gotoxy 18, 3
putchar '0', 0x02
gotoxy 19, 3
putchar '0', 0x02
gotoxy 19, 3
putchar '0', 0x02
gotoxy 20, 3
putchar '0', 0x02 
gotoxy 21, 3
putchar '1', 0x02
gotoxy 22, 3
putchar '1', 0x02
gotoxy 23, 3
putchar '0', 0x02
gotoxy 24, 3
putchar '1', 0x02
gotoxy 25, 3
putchar '0', 0x02
gotoxy 26, 3
putchar '0', 0x02
gotoxy 27, 3
putchar '0', 0x02
gotoxy 28, 3
putchar '0', 0x02
gotoxy 29, 3
putchar '0', 0x02 
gotoxy 30, 3
putchar '1', 0x02
gotoxy 31, 3
putchar '0', 0x02
gotoxy 32, 3
putchar '1', 0x02
gotoxy 33, 3
putchar '1', 0x02
gotoxy 34, 3
putchar '1', 0x02
gotoxy 35, 3
putchar '0', 0x02
gotoxy 36, 3
putchar '1', 0x02
gotoxy 37, 3
putchar '1', 0x02 
gotoxy 38, 3
putchar '1', 0x02
gotoxy 39, 3
putchar '1', 0x02
gotoxy 40, 3
putchar '0', 0x02
gotoxy 41, 3
putchar '1', 0x02
gotoxy 42, 3
putchar '0', 0x02
gotoxy 43, 3
putchar '0', 0x02
gotoxy 44, 3
putchar '0', 0x02
gotoxy 45, 3
putchar '1', 0x02 
gotoxy 46, 3
putchar '1', 0x02
gotoxy 47, 3
putchar '0', 0x02
gotoxy 48, 3
putchar '0', 0x02
gotoxy 49, 3
putchar '0', 0x02
gotoxy 50, 3
putchar '1', 0x02
gotoxy 51, 3
putchar '1', 0x02
gotoxy 52, 3
putchar '1', 0x02
gotoxy 53, 3
putchar '0', 0x02  
gotoxy 54, 3
putchar '1', 0x02
gotoxy 55, 3
putchar '1', 0x02
gotoxy 56, 3
putchar '0', 0x02
gotoxy 57, 3
putchar '1', 0x02
gotoxy 58, 3
putchar '0', 0x02
gotoxy 59, 3
putchar '0', 0x02
gotoxy 60, 3
putchar '0', 0x02
gotoxy 61, 3
putchar '0', 0x02 
gotoxy 62, 3
putchar '1', 0x02
gotoxy 63, 3
putchar '0', 0x02
gotoxy 64, 3
putchar '1', 0x02
gotoxy 65, 3
putchar '1', 0x02
gotoxy 66, 3
putchar '0', 0x02
gotoxy 67, 3
putchar '0', 0x02
gotoxy 68, 3
putchar '0', 0x02
gotoxy 69, 3
putchar '1', 0x02 
gotoxy 70, 3
putchar '1', 0x02
gotoxy 71, 3
putchar '1', 0x02
gotoxy 72, 3
putchar '0', 0x02
gotoxy 73, 3
putchar '1', 0x02
gotoxy 74, 3
putchar '0', 0x02
gotoxy 75, 3
putchar '0', 0x02
gotoxy 76, 3
putchar '0', 0x02
gotoxy 77, 3
putchar '0', 0x02 
gotoxy 78, 3
putchar '1', 0x02
gotoxy 79, 3
putchar '0', 0x02
gotoxy 80, 3
putchar '1', 0x02

gotoxy 0, 4
putchar '1', 0x02
gotoxy 1, 4
putchar '1', 0x02
gotoxy 2, 4
putchar '0', 0x02
gotoxy 3, 4
putchar '1', 0x02
gotoxy 4, 4
putchar '1', 0x02 
gotoxy 5, 4
putchar '1', 0x02
gotoxy 6, 4
putchar '1', 0x02
gotoxy 7, 4
putchar '0', 0x02
gotoxy 8, 4
putchar '1', 0x02
gotoxy 9, 4
putchar '0', 0x02
gotoxy 10, 4
putchar '0', 0x02
gotoxy 11, 4
putchar '0', 0x02
gotoxy 12, 4
putchar '1', 0x02 
gotoxy 13, 4
putchar '1', 0x02
gotoxy 14, 4
putchar '0', 0x02
gotoxy 15, 4
putchar '0', 0x02  
gotoxy 16, 4
putchar '0', 0x02
gotoxy 17, 4
putchar '1', 0x02
gotoxy 18, 4
putchar '1', 0x02
gotoxy 19, 4
putchar '1', 0x02
gotoxy 19, 4
putchar '0', 0x02 
gotoxy 20, 4
putchar '1', 0x02 
gotoxy 21, 4
putchar '0', 0x02
gotoxy 22, 4
putchar '0', 0x02
gotoxy 23, 4
putchar '0', 0x02
gotoxy 24, 4
putchar '0', 0x02
gotoxy 25, 4
putchar '0', 0x02 
gotoxy 26, 4
putchar '1', 0x02
gotoxy 27, 4
putchar '1', 0x02
gotoxy 28, 4
putchar '0', 0x02
gotoxy 29, 4
putchar '1', 0x02 
gotoxy 30, 4
putchar '0', 0x02
gotoxy 31, 4
putchar '0', 0x02
gotoxy 32, 4
putchar '0', 0x02
gotoxy 33, 4
putchar '1', 0x02 
gotoxy 34, 4
putchar '1', 0x02
gotoxy 35, 4
putchar '0', 0x02
gotoxy 36, 4
putchar '0', 0x02
gotoxy 37, 4
putchar '0', 0x02 
gotoxy 38, 4
putchar '1', 0x02
gotoxy 39, 4
putchar '1', 0x02
gotoxy 40, 4
putchar '1', 0x02
gotoxy 41, 4
putchar '1', 0x02 
gotoxy 42, 4
putchar '1', 0x02
gotoxy 43, 4
putchar '1', 0x02
gotoxy 44, 4
putchar '0', 0x02
gotoxy 45, 4
putchar '1', 0x02 
gotoxy 46, 4
putchar '0', 0x02
gotoxy 47, 4
putchar '0', 0x02
gotoxy 48, 4
putchar '0', 0x02
gotoxy 49, 4
putchar '0', 0x02 
gotoxy 50, 4
putchar '1', 0x02
gotoxy 51, 4
putchar '0', 0x02
gotoxy 52, 4
putchar '1', 0x02
gotoxy 53, 4
putchar '1', 0x02  
gotoxy 54, 4
putchar '1', 0x02
gotoxy 55, 4
putchar '1', 0x02
gotoxy 56, 4
putchar '1', 0x02
gotoxy 57, 4
putchar '1', 0x02 
gotoxy 58, 4
putchar '1', 0x02
gotoxy 59, 4
putchar '1', 0x02
gotoxy 60, 4
putchar '0', 0x02
gotoxy 61, 4
putchar '1', 0x02 
gotoxy 62, 4
putchar '0', 0x02
gotoxy 63, 4
putchar '0', 0x02
gotoxy 64, 4
putchar '0', 0x02
gotoxy 65, 4
putchar '0', 0x02 
gotoxy 66, 4
putchar '1', 0x02
gotoxy 67, 4
putchar '0', 0x02
gotoxy 68, 4
putchar '1', 0x02
gotoxy 69, 4
putchar '1', 0x02 
gotoxy 70, 4
putchar '1', 0x02
gotoxy 71, 4
putchar '1', 0x02
gotoxy 72, 4
putchar '0', 0x02
gotoxy 73, 4
putchar '1', 0x02 
gotoxy 74, 4
putchar '1', 0x02
gotoxy 75, 4
putchar '1', 0x02
gotoxy 76, 4
putchar '0', 0x02
gotoxy 77, 4
putchar '1', 0x02 
gotoxy 78, 4
putchar '0', 0x02
gotoxy 79, 4
putchar '0', 0x02
gotoxy 80, 4
putchar '0', 0x02

gotoxy 0, 5
putchar '1', 0x02 
gotoxy 1, 5
putchar '1', 0x02
gotoxy 2, 5
putchar '0', 0x02
gotoxy 3, 5
putchar '0', 0x02
gotoxy 4, 5
putchar '0', 0x02
gotoxy 5, 5
putchar '0', 0x02
gotoxy 6, 5
putchar '1', 0x02
gotoxy 7, 5
putchar '1', 0x02
gotoxy 8, 5
putchar '1', 0x02
gotoxy 9, 5
putchar '0',0x02
gotoxy 10, 5
putchar '0', 0x02
gotoxy 11, 5
putchar '0', 0x02
gotoxy 12, 5
putchar '1', 0x02
gotoxy 13, 5
putchar '1', 0x02
gotoxy 14, 5
putchar '1', 0x02
gotoxy 15, 5
putchar '1', 0x02  
gotoxy 16, 5
putchar '1', 0x02
gotoxy 17, 5
putchar '0', 0x02
gotoxy 18, 5
putchar '0', 0x02
gotoxy 19, 5
putchar '0', 0x02
gotoxy 19, 5
putchar '0', 0x02
gotoxy 20, 5
putchar '0', 0x02 
gotoxy 21, 5
putchar '1', 0x02
gotoxy 22, 5
putchar '1', 0x02
gotoxy 23, 5
putchar '0', 0x02
gotoxy 24, 5
putchar '1', 0x02
gotoxy 25, 5
putchar '0', 0x02
gotoxy 26, 5
putchar '0', 0x02
gotoxy 27, 5
putchar '0', 0x02
gotoxy 28, 5
putchar '0', 0x02
gotoxy 29, 5
putchar '0', 0x02 
gotoxy 30, 5
putchar '1', 0x02
gotoxy 31, 5
putchar '0', 0x02
gotoxy 32, 5
putchar '1', 0x02
gotoxy 33, 5
putchar '1', 0x02
gotoxy 34, 5
putchar '1', 0x02
gotoxy 35, 5
putchar '0', 0x02
gotoxy 36, 5
putchar '1', 0x02
gotoxy 37, 5
putchar '1', 0x02 
gotoxy 38, 5
putchar '1', 0x02
gotoxy 39, 5
putchar '1', 0x02
gotoxy 40, 5
putchar '0', 0x02
gotoxy 41, 5
putchar '1', 0x02
gotoxy 42, 5
putchar '0', 0x02
gotoxy 43, 5
putchar '0', 0x02
gotoxy 44, 5
putchar '0', 0x02
gotoxy 45, 5
putchar '1', 0x02 
gotoxy 46, 5
putchar '1', 0x02
gotoxy 47, 5
putchar '0', 0x02
gotoxy 48, 5
putchar '0', 0x02
gotoxy 49, 5
putchar '0', 0x02
gotoxy 50, 5
putchar '1', 0x02
gotoxy 51, 5
putchar '1', 0x02
gotoxy 52, 5
putchar '1', 0x02
gotoxy 53, 5
putchar '0', 0x02  
gotoxy 54, 5
putchar '1', 0x02
gotoxy 55, 5
putchar '1', 0x02
gotoxy 56, 5
putchar '0', 0x02
gotoxy 57, 5
putchar '1', 0x02
gotoxy 58, 5
putchar '0', 0x02
gotoxy 59, 5
putchar '0', 0x02
gotoxy 60, 5
putchar '0', 0x02
gotoxy 61, 5
putchar '0', 0x02 
gotoxy 62, 5
putchar '1', 0x02
gotoxy 63, 5
putchar '0', 0x02
gotoxy 64, 5
putchar '1', 0x02
gotoxy 65, 5
putchar '1', 0x02
gotoxy 66, 5
putchar '0', 0x02
gotoxy 67, 5
putchar '0', 0x02
gotoxy 68, 5
putchar '0', 0x02
gotoxy 69, 5
putchar '1', 0x02 
gotoxy 70, 5
putchar '1', 0x02
gotoxy 71, 5
putchar '1', 0x02
gotoxy 72, 5
putchar '0', 0x02
gotoxy 73, 5
putchar '1', 0x02
gotoxy 74, 5
putchar '0', 0x02
gotoxy 75, 5
putchar '0', 0x02
gotoxy 76, 5
putchar '0', 0x02
gotoxy 77, 5
putchar '0', 0x02 
gotoxy 78, 5
putchar '1', 0x02
gotoxy 79, 5
putchar '0', 0x02
gotoxy 80, 5
putchar '1', 0x02

gotoxy 0, 6
putchar '1', 0x02
gotoxy 1, 6
putchar '1', 0x02
gotoxy 2, 6
putchar '0', 0x02
gotoxy 3, 6
putchar '1', 0x02
gotoxy 4, 6
putchar '0', 0x02
gotoxy 5, 6
putchar '0', 0x02
gotoxy 6, 6
putchar '0', 0x02
gotoxy 7, 6
putchar '1', 0x02
gotoxy 8, 6
putchar '1', 0x02
gotoxy 9, 6
putchar '0', 0x02
gotoxy 10, 6
putchar '0', 0x02
gotoxy 11, 6
putchar '0', 0x02
gotoxy 12, 6
putchar '1', 0x02
gotoxy 13, 6
putchar '1', 0x02
gotoxy 14, 6
putchar '1', 0x02
gotoxy 15, 6
putchar '1', 0x02  
gotoxy 16, 6
putchar '1', 0x02
gotoxy 17, 6
putchar '0', 0x02
gotoxy 18, 6
putchar '0', 0x02
gotoxy 19, 6
putchar '0', 0x02
gotoxy 19, 6
putchar '0', 0x02
gotoxy 20, 6
putchar '0', 0x02 
gotoxy 21, 6
putchar '1', 0x02
gotoxy 22, 6
putchar '1', 0x02
gotoxy 23, 6
putchar '0', 0x02
gotoxy 24, 6
putchar '1', 0x02
gotoxy 25, 6
putchar '0', 0x02
gotoxy 26, 6
putchar '0', 0x02
gotoxy 27, 6
putchar '0', 0x02
gotoxy 28, 6
putchar '0', 0x02
gotoxy 29, 6
putchar '0', 0x02 
gotoxy 30, 6
putchar '1', 0x02
gotoxy 31, 6
putchar '0', 0x02
gotoxy 32, 6
putchar '1', 0x02
gotoxy 33, 6
putchar '1', 0x02
gotoxy 34, 6
putchar '1', 0x02
gotoxy 35, 6
putchar '0', 0x02
gotoxy 36, 6
putchar '1', 0x02
gotoxy 42, 6
putchar '0', 0x02
gotoxy 43, 6
putchar '0', 0x02
gotoxy 44, 6
putchar '0', 0x02
gotoxy 45, 6
putchar '1', 0x02 
gotoxy 46, 6
putchar '1', 0x02
gotoxy 47, 6
putchar '0', 0x02
gotoxy 48, 6
putchar '0', 0x02
gotoxy 49, 6
putchar '0', 0x02
gotoxy 50, 6
putchar '1', 0x02
gotoxy 51, 6
putchar '1', 0x02
gotoxy 52, 6
putchar '1', 0x02
gotoxy 53, 6
putchar '0', 0x02  
gotoxy 54, 6
putchar '1', 0x02
gotoxy 55, 6
putchar '1', 0x02
gotoxy 56, 6
putchar '0', 0x02
gotoxy 57, 6
putchar '1', 0x02
gotoxy 58, 6
putchar '0', 0x02
gotoxy 59, 6
putchar '0', 0x02
gotoxy 60, 6
putchar '0', 0x02
gotoxy 61, 6
putchar '0', 0x02 
gotoxy 62, 6
putchar '1', 0x02
gotoxy 63, 6
putchar '0', 0x02
gotoxy 64, 6
putchar '1', 0x02
gotoxy 65, 6
putchar '1', 0x02
gotoxy 66, 6
putchar '0', 0x02
gotoxy 67, 6
putchar '0', 0x02
gotoxy 68, 6
putchar '0', 0x02
gotoxy 69, 6
putchar '1', 0x02 
gotoxy 70, 6
putchar '1', 0x02
gotoxy 71, 6
putchar '1', 0x02
gotoxy 72, 6
putchar '0', 0x02
gotoxy 73, 6
putchar '1', 0x02
gotoxy 74, 6
putchar '0', 0x02
gotoxy 75, 6
putchar '0', 0x02
gotoxy 76, 6
putchar '0', 0x02
gotoxy 77, 6
putchar '0', 0x02 
gotoxy 78, 6
putchar '1', 0x02
gotoxy 79, 6
putchar '0', 0x02
gotoxy 80, 6
putchar '1', 0x02

gotoxy 0, 7
putchar '1', 0x02
gotoxy 1, 7
putchar '1', 0x02
gotoxy 2, 7
putchar '0', 0x02
gotoxy 3, 7
putchar '1', 0x02
gotoxy 4, 7
putchar '1', 0x02 
gotoxy 5, 7
putchar '1', 0x02
gotoxy 6, 7
putchar '1', 0x02
gotoxy 7, 7
putchar '0', 0x02
gotoxy 8, 7
putchar '1', 0x02
gotoxy 9, 7
putchar '0', 0x02
gotoxy 10, 7
putchar '0', 0x02
gotoxy 11, 7
putchar '0', 0x02
gotoxy 12, 7
putchar '1', 0x02 
gotoxy 13, 7
putchar '1', 0x02
gotoxy 14, 7
putchar '0', 0x02
gotoxy 15, 7
putchar '0', 0x02  
gotoxy 16, 7
putchar '0', 0x02
gotoxy 17, 7
putchar '1', 0x02
gotoxy 18, 7
putchar '1', 0x02
gotoxy 19, 7
putchar '1', 0x02
gotoxy 19, 7
putchar '0', 0x02 
gotoxy 20, 7
putchar '1', 0x02 
gotoxy 21, 7
putchar '0', 0x02
gotoxy 22, 7
putchar '0', 0x02
gotoxy 23, 7
putchar '0', 0x02
gotoxy 24, 7
putchar '0', 0x02
gotoxy 25, 7
putchar '0', 0x02 
gotoxy 26, 7
putchar '1', 0x02
gotoxy 27, 7
putchar '1', 0x02
gotoxy 28, 7
putchar '0', 0x02
gotoxy 29, 7
putchar '1', 0x02 
gotoxy 30, 7
putchar '0', 0x02
gotoxy 31, 7
putchar '0', 0x02
gotoxy 32, 7
putchar '0', 0x02
gotoxy 33, 7
putchar '1', 0x02 
gotoxy 34, 7
putchar '1', 0x02
gotoxy 44, 7
putchar '0', 0x02
gotoxy 45, 7
putchar '1', 0x02 
gotoxy 46, 7
putchar '0', 0x02
gotoxy 47, 7
putchar '0', 0x02
gotoxy 48, 7
putchar '0', 0x02
gotoxy 49, 7
putchar '0', 0x02 
gotoxy 50, 7
putchar '1', 0x02
gotoxy 51, 7
putchar '0', 0x02
gotoxy 52, 7
putchar '1', 0x02
gotoxy 53, 7
putchar '1', 0x02  
gotoxy 54, 7
putchar '1', 0x02
gotoxy 55, 7
putchar '1', 0x02
gotoxy 56, 7
putchar '1', 0x02
gotoxy 57, 7
putchar '1', 0x02 
gotoxy 58, 7
putchar '1', 0x02
gotoxy 59, 7
putchar '1', 0x02
gotoxy 60, 7
putchar '0', 0x02
gotoxy 61, 7
putchar '1', 0x02 
gotoxy 62, 7
putchar '0', 0x02
gotoxy 63, 7
putchar '0', 0x02
gotoxy 64, 7
putchar '0', 0x02
gotoxy 65, 7
putchar '0', 0x02 
gotoxy 66, 7
putchar '1', 0x02
gotoxy 67, 7
putchar '0', 0x02
gotoxy 68, 7
putchar '1', 0x02
gotoxy 69, 7
putchar '1', 0x02 
gotoxy 70, 7
putchar '1', 0x02
gotoxy 71, 7
putchar '1', 0x02
gotoxy 72, 7
putchar '0', 0x02
gotoxy 73, 7
putchar '1', 0x02 
gotoxy 74, 7
putchar '1', 0x02
gotoxy 75, 7
putchar '1', 0x02
gotoxy 76, 7
putchar '0', 0x02
gotoxy 77, 7
putchar '1', 0x02 
gotoxy 78, 7
putchar '0', 0x02
gotoxy 79, 7
putchar '0', 0x02
gotoxy 80, 7
putchar '0', 0x02

gotoxy 0, 8
putchar '1', 0x02 
gotoxy 1, 8
putchar '1', 0x02
gotoxy 2, 8
putchar '0', 0x02
gotoxy 3, 8
putchar '0', 0x02
gotoxy 4, 8
putchar '0', 0x02
gotoxy 5, 8
putchar '0', 0x02
gotoxy 6, 8
putchar '1', 0x02
gotoxy 7, 8
putchar '1', 0x02
gotoxy 8, 8
putchar '1', 0x02
gotoxy 9, 8
putchar '0',0x02
gotoxy 10, 8
putchar '0', 0x02
gotoxy 11, 8
putchar '0', 0x02
gotoxy 12, 8
putchar '1', 0x02
gotoxy 13, 8
putchar '1', 0x02
gotoxy 14, 8
putchar '1', 0x02
gotoxy 15, 8
putchar '1', 0x02  
gotoxy 16, 8
putchar '1', 0x02
gotoxy 17, 8
putchar '0', 0x02
gotoxy 18, 8
putchar '0', 0x02
gotoxy 19, 8
putchar '0', 0x02
gotoxy 19, 8
putchar '0', 0x02
gotoxy 20, 8
putchar '0', 0x02 
gotoxy 21, 8
putchar '1', 0x02
gotoxy 22, 8
putchar '1', 0x02
gotoxy 23, 8
putchar '0', 0x02
gotoxy 24, 8
putchar '1', 0x02
gotoxy 25, 8
putchar '0', 0x02
gotoxy 26, 8
putchar '0', 0x02
gotoxy 27, 8
putchar '0', 0x02
gotoxy 28, 8
putchar '0', 0x02
gotoxy 29, 8
putchar '0', 0x02 
gotoxy 30, 8
putchar '1', 0x02
gotoxy 31, 8
putchar '0', 0x02
gotoxy 32, 8
putchar '1', 0x02
gotoxy 33, 8
putchar '1', 0x02
gotoxy 45, 8
putchar '1', 0x02 
gotoxy 46, 8
putchar '1', 0x02
gotoxy 47, 8
putchar '0', 0x02
gotoxy 48, 8
putchar '0', 0x02
gotoxy 49, 8
putchar '0', 0x02
gotoxy 50, 8
putchar '1', 0x02
gotoxy 51, 8
putchar '1', 0x02
gotoxy 52, 8
putchar '1', 0x02
gotoxy 53, 8
putchar '0', 0x02  
gotoxy 54, 8
putchar '1', 0x02
gotoxy 55, 8
putchar '1', 0x02
gotoxy 56, 8
putchar '0', 0x02
gotoxy 57, 8
putchar '1', 0x02
gotoxy 58, 8
putchar '0', 0x02
gotoxy 59, 8
putchar '0', 0x02
gotoxy 60, 8
putchar '0', 0x02
gotoxy 61, 8
putchar '0', 0x02 
gotoxy 62, 8
putchar '1', 0x02
gotoxy 63, 8
putchar '0', 0x02
gotoxy 64, 8
putchar '1', 0x02
gotoxy 65, 8
putchar '1', 0x02
gotoxy 66, 8
putchar '0', 0x02
gotoxy 67, 8
putchar '0', 0x02
gotoxy 68, 8
putchar '0', 0x02
gotoxy 69, 8
putchar '1', 0x02 
gotoxy 70, 8
putchar '1', 0x02
gotoxy 71, 8
putchar '1', 0x02
gotoxy 72, 8
putchar '0', 0x02
gotoxy 73, 8
putchar '1', 0x02
gotoxy 74, 8
putchar '0', 0x02
gotoxy 75, 8
putchar '0', 0x02
gotoxy 76, 8
putchar '0', 0x02
gotoxy 77, 8
putchar '0', 0x02 
gotoxy 78, 8
putchar '1', 0x02
gotoxy 79, 8
putchar '0', 0x02
gotoxy 80, 8
putchar '1', 0x02

gotoxy 0, 9
putchar '1', 0x02
gotoxy 1, 9
putchar '1', 0x02
gotoxy 2, 9
putchar '0', 0x02
gotoxy 3, 9
putchar '1', 0x02
gotoxy 4, 9
putchar '0', 0x02
gotoxy 5, 9
putchar '0', 0x02
gotoxy 6, 9
putchar '0', 0x02
gotoxy 7, 9
putchar '1', 0x02
gotoxy 8, 9
putchar '1', 0x02
gotoxy 9, 9
putchar '0', 0x02
gotoxy 10, 9
putchar '0', 0x02
gotoxy 11, 9
putchar '0', 0x02
gotoxy 12, 9
putchar '1', 0x02
gotoxy 13, 9
putchar '1', 0x02
gotoxy 14, 9
putchar '1', 0x02
gotoxy 15, 9
putchar '1', 0x02  
gotoxy 16, 9
putchar '1', 0x02
gotoxy 17, 9
putchar '0', 0x02
gotoxy 18, 9
putchar '0', 0x02
gotoxy 19, 9
putchar '0', 0x02
gotoxy 19, 9
putchar '0', 0x02
gotoxy 20, 9
putchar '0', 0x02 
gotoxy 21, 9
putchar '1', 0x02
gotoxy 22, 9
putchar '1', 0x02
gotoxy 23, 9
putchar '0', 0x02
gotoxy 24, 9
putchar '1', 0x02
gotoxy 25, 9
putchar '0', 0x02
gotoxy 26, 9
putchar '0', 0x02
gotoxy 27, 9
putchar '0', 0x02
gotoxy 28, 9
putchar '0', 0x02
gotoxy 29, 9
putchar '0', 0x02 
gotoxy 30, 9
putchar '1', 0x02
gotoxy 31, 9
putchar '0', 0x02
gotoxy 32, 9
putchar '1', 0x02
gotoxy 46, 9
putchar '1', 0x02
gotoxy 47, 9
putchar '0', 0x02
gotoxy 48, 9
putchar '0', 0x02
gotoxy 49, 9
putchar '0', 0x02
gotoxy 50, 9
putchar '1', 0x02
gotoxy 51, 9
putchar '1', 0x02
gotoxy 52, 9
putchar '1', 0x02
gotoxy 53, 9
putchar '0', 0x02  
gotoxy 54, 9
putchar '1', 0x02
gotoxy 55, 9
putchar '1', 0x02
gotoxy 56, 9
putchar '0', 0x02
gotoxy 57, 9
putchar '1', 0x02
gotoxy 58, 9
putchar '0', 0x02
gotoxy 59, 9
putchar '0', 0x02
gotoxy 60, 9
putchar '0', 0x02
gotoxy 61, 9
putchar '0', 0x02 
gotoxy 62, 9
putchar '1', 0x02
gotoxy 63, 9
putchar '0', 0x02
gotoxy 64, 9
putchar '1', 0x02
gotoxy 65, 9
putchar '1', 0x02
gotoxy 66, 9
putchar '0', 0x02
gotoxy 67, 9
putchar '0', 0x02
gotoxy 68, 9
putchar '0', 0x02
gotoxy 69, 9
putchar '1', 0x02 
gotoxy 70, 9
putchar '1', 0x02
gotoxy 71, 9
putchar '1', 0x02
gotoxy 72, 9
putchar '0', 0x02
gotoxy 73, 9
putchar '1', 0x02
gotoxy 74, 9
putchar '0', 0x02
gotoxy 75, 9
putchar '0', 0x02
gotoxy 76, 9
putchar '0', 0x02
gotoxy 77, 9
putchar '0', 0x02 
gotoxy 78, 9
putchar '1', 0x02
gotoxy 79, 9
putchar '0', 0x02
gotoxy 80, 9
putchar '1', 0x02

gotoxy 0, 10
putchar '1', 0x02
gotoxy 1, 10
putchar '1', 0x02
gotoxy 2, 10
putchar '0', 0x02
gotoxy 3, 10
putchar '1', 0x02
gotoxy 4, 10
putchar '0', 0x02
gotoxy 5, 10
putchar '0', 0x02
gotoxy 6, 10
putchar '0', 0x02
gotoxy 7, 10
putchar '1', 0x02
gotoxy 8, 10
putchar '1', 0x02
gotoxy 9, 10
putchar '0', 0x02
gotoxy 10, 10
putchar '0', 0x02
gotoxy 11, 10
putchar '0', 0x02
gotoxy 12, 10
putchar '1', 0x02
gotoxy 13, 10
putchar '1', 0x02
gotoxy 14, 10
putchar '1', 0x02
gotoxy 15, 10
putchar '1', 0x02  
gotoxy 16, 10
putchar '1', 0x02
gotoxy 17, 10
putchar '0', 0x02
gotoxy 18, 10
putchar '0', 0x02
gotoxy 19, 10
putchar '0', 0x02
gotoxy 19, 10
putchar '0', 0x02
gotoxy 20, 10
putchar '0', 0x02 
gotoxy 21, 10
putchar '1', 0x02
gotoxy 22, 10
putchar '1', 0x02
gotoxy 23, 10
putchar '0', 0x02
gotoxy 24, 10
putchar '1', 0x02
gotoxy 25, 10
putchar '0', 0x02
gotoxy 26, 10
putchar '0', 0x02
gotoxy 27, 10
putchar '0', 0x02
gotoxy 28, 10
putchar '0', 0x02
gotoxy 29, 10
putchar '0', 0x02 
gotoxy 30, 10
putchar '1', 0x02
gotoxy 31, 10
putchar '0', 0x02
gotoxy 32, 10
putchar '1', 0x02
gotoxy 46, 10
putchar '1', 0x02
gotoxy 47, 10
putchar '0', 0x02
gotoxy 48, 10
putchar '0', 0x02
gotoxy 49, 10
putchar '0', 0x02
gotoxy 50, 10
putchar '1', 0x02
gotoxy 51, 10
putchar '1', 0x02
gotoxy 52, 10
putchar '1', 0x02
gotoxy 53, 10
putchar '0', 0x02  
gotoxy 54, 10
putchar '1', 0x02
gotoxy 55, 10
putchar '1', 0x02
gotoxy 56, 10
putchar '0', 0x02
gotoxy 57, 10
putchar '1', 0x02
gotoxy 58, 10
putchar '0', 0x02
gotoxy 59, 10
putchar '0', 0x02
gotoxy 60, 10
putchar '0', 0x02
gotoxy 61, 10
putchar '0', 0x02 
gotoxy 62, 10
putchar '1', 0x02
gotoxy 63, 10
putchar '0', 0x02
gotoxy 64, 10
putchar '1', 0x02
gotoxy 65, 10
putchar '1', 0x02
gotoxy 66, 10
putchar '0', 0x02
gotoxy 67, 10
putchar '0', 0x02
gotoxy 68, 10
putchar '0', 0x02
gotoxy 69, 10
putchar '1', 0x02 
gotoxy 70, 10
putchar '1', 0x02
gotoxy 71, 10
putchar '1', 0x02
gotoxy 72, 10
putchar '0', 0x02
gotoxy 73, 10
putchar '1', 0x02
gotoxy 74, 10
putchar '0', 0x02
gotoxy 75, 10
putchar '0', 0x02
gotoxy 76, 10
putchar '0', 0x02
gotoxy 77, 10
putchar '0', 0x02 
gotoxy 78, 10
putchar '1', 0x02
gotoxy 79, 10
putchar '0', 0x02
gotoxy 80, 10
putchar '1', 0x02

gotoxy 0, 11
putchar '1', 0x02
gotoxy 1, 11
putchar '1', 0x02
gotoxy 2, 11
putchar '0', 0x02
gotoxy 3, 11
putchar '1', 0x02
gotoxy 4, 11
putchar '1', 0x02 
gotoxy 5, 11
putchar '1', 0x02
gotoxy 6, 11
putchar '1', 0x02
gotoxy 7, 11
putchar '0', 0x02
gotoxy 8, 11
putchar '1', 0x02
gotoxy 9, 11
putchar '0', 0x02
gotoxy 10, 11
putchar '0', 0x02
gotoxy 11, 11
putchar '0', 0x02
gotoxy 12, 11
putchar '1', 0x02 
gotoxy 13, 11
putchar '1', 0x02
gotoxy 14, 11
putchar '0', 0x02
gotoxy 15, 11
putchar '0', 0x02  
gotoxy 16, 11
putchar '0', 0x02
gotoxy 17, 11
putchar '1', 0x02
gotoxy 18, 11
putchar '1', 0x02
gotoxy 19, 11
putchar '1', 0x02
gotoxy 19, 11
putchar '0', 0x02 
gotoxy 20, 11
putchar '1', 0x02 
gotoxy 21, 11
putchar '0', 0x02
gotoxy 22, 11
putchar '0', 0x02
gotoxy 23, 11
putchar '0', 0x02
gotoxy 24, 11
putchar '0', 0x02
gotoxy 25, 11
putchar '0', 0x02 
gotoxy 26, 11
putchar '1', 0x02
gotoxy 27, 11
putchar '1', 0x02
gotoxy 28, 11
putchar '0', 0x02
gotoxy 29, 11
putchar '1', 0x02 
gotoxy 30, 11
putchar '0', 0x02
gotoxy 31, 11
putchar '0', 0x02
gotoxy 47, 11
putchar '0', 0x02
gotoxy 48, 11
putchar '0', 0x02
gotoxy 49, 11
putchar '0', 0x02 
gotoxy 50, 11
putchar '1', 0x02
gotoxy 51, 11
putchar '0', 0x02
gotoxy 52, 11
putchar '1', 0x02
gotoxy 53, 11
putchar '1', 0x02  
gotoxy 54, 11
putchar '1', 0x02
gotoxy 55, 11
putchar '1', 0x02
gotoxy 56, 11
putchar '1', 0x02
gotoxy 57, 11
putchar '1', 0x02 
gotoxy 58, 11
putchar '1', 0x02
gotoxy 59, 11
putchar '1', 0x02
gotoxy 60, 11
putchar '0', 0x02
gotoxy 61, 11
putchar '1', 0x02 
gotoxy 62, 11
putchar '0', 0x02
gotoxy 63, 11
putchar '0', 0x02
gotoxy 64, 11
putchar '0', 0x02
gotoxy 65, 11
putchar '0', 0x02 
gotoxy 66, 11
putchar '1', 0x02
gotoxy 67, 11
putchar '0', 0x02
gotoxy 68, 11
putchar '1', 0x02
gotoxy 69, 11
putchar '1', 0x02 
gotoxy 70, 11
putchar '1', 0x02
gotoxy 71, 11
putchar '1', 0x02
gotoxy 72, 11
putchar '0', 0x02
gotoxy 73, 11
putchar '1', 0x02 
gotoxy 74, 11
putchar '1', 0x02
gotoxy 75, 11
putchar '1', 0x02
gotoxy 76, 11
putchar '0', 0x02
gotoxy 77, 11
putchar '1', 0x02 
gotoxy 78, 111
putchar '0', 0x02
gotoxy 79, 11
putchar '0', 0x02
gotoxy 80, 11
putchar '0', 0x02

gotoxy 0, 12
putchar '1', 0x02 
gotoxy 1, 12
putchar '1', 0x02
gotoxy 2, 12
putchar '0', 0x02
gotoxy 3, 12
putchar '0', 0x02
gotoxy 4, 12
putchar '0', 0x02
gotoxy 5, 12
putchar '0', 0x02
gotoxy 6, 12
putchar '1', 0x02
gotoxy 7, 12
putchar '1', 0x02
gotoxy 8, 12
putchar '1', 0x02
gotoxy 9, 12
putchar '0',0x02
gotoxy 10, 12
putchar '0', 0x02
gotoxy 11, 12
putchar '0', 0x02
gotoxy 12, 12
putchar '1', 0x02
gotoxy 13, 12
putchar '1', 0x02
gotoxy 14, 12
putchar '1', 0x02
gotoxy 15, 12
putchar '1', 0x02  
gotoxy 16, 12
putchar '1', 0x02
gotoxy 17, 12
putchar '0', 0x02
gotoxy 18, 12
putchar '0', 0x02
gotoxy 19, 12
putchar '0', 0x02
gotoxy 19, 12
putchar '0', 0x02
gotoxy 20, 12
putchar '0', 0x02 
gotoxy 21, 12
putchar '1', 0x02
gotoxy 22, 12
putchar '1', 0x02
gotoxy 23, 12
putchar '0', 0x02
gotoxy 24, 12
putchar '1', 0x02
gotoxy 25, 12
putchar '0', 0x02
gotoxy 26, 12
putchar '0', 0x02
gotoxy 27, 12
putchar '0', 0x02
gotoxy 28, 12
putchar '0', 0x02
gotoxy 29, 12
putchar '0', 0x02 
gotoxy 30, 12
putchar '1', 0x02
gotoxy 31, 12
putchar '0', 0x02
gotoxy 47, 12
putchar '0', 0x02
gotoxy 48, 12
putchar '0', 0x02
gotoxy 49, 12
putchar '0', 0x02
gotoxy 50, 12
putchar '1', 0x02
gotoxy 51, 12
putchar '1', 0x02
gotoxy 52, 12
putchar '1', 0x02
gotoxy 53, 12
putchar '0', 0x02  
gotoxy 54, 12
putchar '1', 0x02
gotoxy 55, 12
putchar '1', 0x02
gotoxy 56, 12
putchar '0', 0x02
gotoxy 57, 12
putchar '1', 0x02
gotoxy 58, 12
putchar '0', 0x02
gotoxy 59, 12
putchar '0', 0x02
gotoxy 60, 12
putchar '0', 0x02
gotoxy 61, 12
putchar '0', 0x02 
gotoxy 62, 12
putchar '1', 0x02
gotoxy 63, 12
putchar '0', 0x02
gotoxy 64, 12
putchar '1', 0x02
gotoxy 65, 12
putchar '1', 0x02
gotoxy 66, 12
putchar '0', 0x02
gotoxy 67, 12
putchar '0', 0x02
gotoxy 68, 12
putchar '0', 0x02
gotoxy 69, 12
putchar '1', 0x02 
gotoxy 70, 12
putchar '1', 0x02
gotoxy 71, 12
putchar '1', 0x02
gotoxy 72, 12
putchar '0', 0x02
gotoxy 73, 12
putchar '1', 0x02
gotoxy 74, 12
putchar '0', 0x02
gotoxy 75, 12
putchar '0', 0x02
gotoxy 76, 12
putchar '0', 0x02
gotoxy 77, 12
putchar '0', 0x02 
gotoxy 78, 12
putchar '1', 0x02
gotoxy 79, 12
putchar '0', 0x02
gotoxy 80, 12
putchar '1', 0x02

gotoxy 0, 13
putchar '1', 0x02
gotoxy 1, 13
putchar '1', 0x02
gotoxy 2, 13
putchar '0', 0x02
gotoxy 3, 13
putchar '1', 0x02
gotoxy 4, 13
putchar '0', 0x02
gotoxy 5, 13
putchar '0', 0x02
gotoxy 6, 13
putchar '0', 0x02
gotoxy 7, 13
putchar '1', 0x02
gotoxy 8, 13
putchar '1', 0x02
gotoxy 9, 13
putchar '0', 0x02
gotoxy 10, 13
putchar '0', 0x02
gotoxy 11, 13
putchar '0', 0x02
gotoxy 12, 13
putchar '1', 0x02
gotoxy 13, 13
putchar '1', 0x02
gotoxy 14, 13
putchar '1', 0x02
gotoxy 15, 13
putchar '1', 0x02  
gotoxy 16, 13
putchar '1', 0x02
gotoxy 17, 13
putchar '0', 0x02
gotoxy 18, 13
putchar '0', 0x02
gotoxy 19, 13
putchar '0', 0x02
gotoxy 19, 13
putchar '0', 0x02
gotoxy 20, 13
putchar '0', 0x02 
gotoxy 21, 13
putchar '1', 0x02
gotoxy 22, 13
putchar '1', 0x02
gotoxy 23, 13
putchar '0', 0x02
gotoxy 24, 13
putchar '1', 0x02
gotoxy 25, 13
putchar '0', 0x02
gotoxy 26, 13
putchar '0', 0x02
gotoxy 27, 13
putchar '0', 0x02
gotoxy 28, 13
putchar '0', 0x02
gotoxy 29, 13
putchar '0', 0x02 
gotoxy 30, 13
putchar '1', 0x02
gotoxy 31, 13
putchar '0', 0x02
gotoxy 47, 13
putchar '0', 0x02
gotoxy 48, 13
putchar '0', 0x02
gotoxy 49, 13
putchar '0', 0x02
gotoxy 50, 13
putchar '1', 0x02
gotoxy 51, 13
putchar '1', 0x02
gotoxy 52, 13
putchar '1', 0x02
gotoxy 53, 13
putchar '0', 0x02  
gotoxy 54, 13
putchar '1', 0x02
gotoxy 55, 13
putchar '1', 0x02
gotoxy 56, 13
putchar '0', 0x02
gotoxy 57, 13
putchar '1', 0x02
gotoxy 58, 13
putchar '0', 0x02
gotoxy 59, 13
putchar '0', 0x02
gotoxy 60, 13
putchar '0', 0x02
gotoxy 61, 13
putchar '0', 0x02 
gotoxy 62, 13
putchar '1', 0x02
gotoxy 63, 13
putchar '0', 0x02
gotoxy 64, 13
putchar '1', 0x02
gotoxy 65, 13
putchar '1', 0x02
gotoxy 66, 13
putchar '0', 0x02
gotoxy 67, 13
putchar '0', 0x02
gotoxy 68, 13
putchar '0', 0x02
gotoxy 69, 13
putchar '1', 0x02 
gotoxy 70, 13
putchar '1', 0x02
gotoxy 71, 13
putchar '1', 0x02
gotoxy 72, 13
putchar '0', 0x02
gotoxy 73, 13
putchar '1', 0x02
gotoxy 74, 13
putchar '0', 0x02
gotoxy 75, 13
putchar '0', 0x02
gotoxy 76, 13
putchar '0', 0x02
gotoxy 77, 13
putchar '0', 0x02 
gotoxy 78, 13
putchar '1', 0x02
gotoxy 79, 13
putchar '0', 0x02
gotoxy 80, 13
putchar '1', 0x02

gotoxy 0, 14
putchar '1', 0x02
gotoxy 1, 14
putchar '1', 0x02
gotoxy 2, 14
putchar '0', 0x02
gotoxy 3, 14
putchar '1', 0x02
gotoxy 4, 14
putchar '1', 0x02 
gotoxy 5, 14
putchar '1', 0x02
gotoxy 6, 14
putchar '1', 0x02
gotoxy 7, 14
putchar '0', 0x02
gotoxy 8, 14
putchar '1', 0x02
gotoxy 9, 14
putchar '0', 0x02
gotoxy 10, 14
putchar '0', 0x02
gotoxy 11, 14
putchar '0', 0x02
gotoxy 12, 14
putchar '1', 0x02 
gotoxy 13, 14
putchar '1', 0x02
gotoxy 14, 14
putchar '0', 0x02
gotoxy 15, 14
putchar '0', 0x02  
gotoxy 16, 14
putchar '0', 0x02
gotoxy 17, 14
putchar '1', 0x02
gotoxy 18, 14
putchar '1', 0x02
gotoxy 19, 14
putchar '1', 0x02
gotoxy 19, 14
putchar '0', 0x02 
gotoxy 20, 14
putchar '1', 0x02 
gotoxy 21, 14
putchar '0', 0x02
gotoxy 22, 14
putchar '0', 0x02
gotoxy 23, 14
putchar '0', 0x02
gotoxy 24, 14
putchar '0', 0x02
gotoxy 25, 14
putchar '0', 0x02
gotoxy 26, 14
putchar '1', 0x02
gotoxy 27, 14
putchar '1', 0x02
gotoxy 28, 14
putchar '0', 0x02
gotoxy 29, 14
putchar '1', 0x02 
gotoxy 30, 14
putchar '0', 0x02
gotoxy 31, 14
putchar '0', 0x02
gotoxy 47, 14
putchar '0', 0x02
gotoxy 48, 14
putchar '0', 0x02
gotoxy 49, 14
putchar '0', 0x02
gotoxy 50, 14
putchar '1', 0x02
gotoxy 51, 14
putchar '0', 0x02
gotoxy 52, 14
putchar '1', 0x02
gotoxy 53, 14
putchar '1', 0x02  
gotoxy 54, 14
putchar '1', 0x02
gotoxy 55, 14
putchar '1', 0x02
gotoxy 56, 14
putchar '1', 0x02
gotoxy 57, 14
putchar '1', 0x02
gotoxy 58, 14
putchar '1', 0x02
gotoxy 59, 14
putchar '1', 0x02
gotoxy 60, 14
putchar '0', 0x02
gotoxy 61, 14
putchar '1', 0x02 
gotoxy 62, 14
putchar '0', 0x02
gotoxy 63, 14
putchar '0', 0x02
gotoxy 64, 14
putchar '0', 0x02
gotoxy 65, 14
putchar '0', 0x02
gotoxy 66, 14
putchar '1', 0x02
gotoxy 67, 14
putchar '0', 0x02
gotoxy 68, 14
putchar '1', 0x02
gotoxy 69, 14
putchar '1', 0x02 
gotoxy 70, 14
putchar '1', 0x02
gotoxy 71, 14
putchar '1', 0x02
gotoxy 72, 14
putchar '0', 0x02
gotoxy 73, 14
putchar '1', 0x02
gotoxy 74, 14
putchar '1', 0x02
gotoxy 75, 14
putchar '1', 0x02
gotoxy 76, 14
putchar '0', 0x02
gotoxy 77, 14
putchar '1', 0x02 
gotoxy 78, 14
putchar '0', 0x02
gotoxy 79, 14
putchar '0', 0x02
gotoxy 80, 14
putchar '0', 0x02

gotoxy 0, 15
putchar '1', 0x02 
gotoxy 1, 15
putchar '1', 0x02
gotoxy 2, 15
putchar '0', 0x02
gotoxy 3, 15
putchar '0', 0x02
gotoxy 4, 15
putchar '0', 0x02
gotoxy 5, 15
putchar '0', 0x02
gotoxy 6, 15
putchar '1', 0x02
gotoxy 7, 15
putchar '1', 0x02
gotoxy 8, 15
putchar '1', 0x02
gotoxy 9, 15
putchar '0',0x02
gotoxy 10, 15
putchar '0', 0x02
gotoxy 11, 15
putchar '0', 0x02
gotoxy 12, 15
putchar '1', 0x02
gotoxy 13, 15
putchar '1', 0x02
gotoxy 14, 15
putchar '1', 0x02
gotoxy 15, 15
putchar '1', 0x02  
gotoxy 16, 15
putchar '1', 0x02
gotoxy 17, 15
putchar '0', 0x02
gotoxy 18, 15
putchar '0', 0x02
gotoxy 19, 15
putchar '0', 0x02
gotoxy 19, 15
putchar '0', 0x02
gotoxy 20, 15
putchar '0', 0x02 
gotoxy 21, 15
putchar '1', 0x02
gotoxy 22, 15
putchar '1', 0x02
gotoxy 23, 15
putchar '0', 0x02
gotoxy 24, 15
putchar '1', 0x02
gotoxy 25, 15
putchar '0', 0x02
gotoxy 26, 15
putchar '0', 0x02
gotoxy 27, 15
putchar '0', 0x02
gotoxy 28, 15
putchar '0', 0x02
gotoxy 29, 15
putchar '0', 0x02 
gotoxy 30, 15
putchar '1', 0x02
gotoxy 31, 15
putchar '0', 0x02
gotoxy 47, 15
putchar '0', 0x02
gotoxy 48, 15
putchar '0', 0x02
gotoxy 49, 15
putchar '0', 0x02
gotoxy 50, 15
putchar '1', 0x02
gotoxy 51, 15
putchar '1', 0x02
gotoxy 52, 15
putchar '1', 0x02
gotoxy 53, 15
putchar '0', 0x02  
gotoxy 54, 15
putchar '1', 0x02
gotoxy 55, 15
putchar '1', 0x02
gotoxy 56, 15
putchar '0', 0x02
gotoxy 57, 15
putchar '1', 0x02
gotoxy 58, 15
putchar '0', 0x02
gotoxy 59, 15
putchar '0', 0x02
gotoxy 60, 15
putchar '0', 0x02
gotoxy 61, 15
putchar '0', 0x02 
gotoxy 62, 15
putchar '1', 0x02
gotoxy 63, 15
putchar '0', 0x02
gotoxy 64, 15
putchar '1', 0x02
gotoxy 65, 15
putchar '1', 0x02
gotoxy 66, 15
putchar '0', 0x02
gotoxy 67, 15
putchar '0', 0x02
gotoxy 68, 15
putchar '0', 0x02
gotoxy 69, 15
putchar '1', 0x02 
gotoxy 70, 15
putchar '1', 0x02
gotoxy 71, 15
putchar '1', 0x02
gotoxy 72, 15
putchar '0', 0x02
gotoxy 73, 15
putchar '1', 0x02
gotoxy 74, 15
putchar '0', 0x02
gotoxy 75, 15
putchar '0', 0x02
gotoxy 76, 15
putchar '0', 0x02
gotoxy 77, 15
putchar '0', 0x02 
gotoxy 78, 15
putchar '1', 0x02
gotoxy 79, 15
putchar '0', 0x02
gotoxy 80, 15
putchar '1', 0x02

gotoxy 0, 16
putchar '1', 0x02
gotoxy 1, 16
putchar '1', 0x02
gotoxy 2, 16
putchar '0', 0x02
gotoxy 3, 16
putchar '1', 0x02
gotoxy 4, 16
putchar '0', 0x02
gotoxy 5, 16
putchar '0', 0x02
gotoxy 6, 16
putchar '0', 0x02
gotoxy 7, 16
putchar '1', 0x02
gotoxy 8, 16
putchar '1', 0x02
gotoxy 9, 16
putchar '0', 0x02
gotoxy 10, 16
putchar '0', 0x02
gotoxy 11, 16
putchar '0', 0x02
gotoxy 12, 16
putchar '1', 0x02
gotoxy 13, 16
putchar '1', 0x02
gotoxy 14, 16
putchar '1', 0x02
gotoxy 15, 16
putchar '1', 0x02  
gotoxy 16, 16
putchar '1', 0x02
gotoxy 17, 16
putchar '0', 0x02
gotoxy 18, 16
putchar '0', 0x02
gotoxy 19, 16
putchar '0', 0x02
gotoxy 19, 16
putchar '0', 0x02
gotoxy 20, 16
putchar '0', 0x02 
gotoxy 21, 16
putchar '1', 0x02
gotoxy 22, 16
putchar '1', 0x02
gotoxy 23, 16
putchar '0', 0x02
gotoxy 24, 16
putchar '1', 0x02
gotoxy 25, 16
putchar '0', 0x02
gotoxy 26, 16
putchar '0', 0x02
gotoxy 27, 16
putchar '0', 0x02
gotoxy 28, 16
putchar '0', 0x02
gotoxy 29, 16
putchar '0', 0x02 
gotoxy 30, 16
putchar '1', 0x02
gotoxy 31, 16
putchar '0', 0x02
gotoxy 47, 16
putchar '0', 0x02
gotoxy 48, 16
putchar '0', 0x02
gotoxy 49, 16
putchar '0', 0x02
gotoxy 50, 16
putchar '1', 0x02
gotoxy 51, 16
putchar '1', 0x02
gotoxy 52, 16
putchar '1', 0x02
gotoxy 53, 16
putchar '0', 0x02  
gotoxy 54, 16
putchar '1', 0x02
gotoxy 55, 16
putchar '1', 0x02
gotoxy 56, 16
putchar '0', 0x02
gotoxy 57, 16
putchar '1', 0x02
gotoxy 58, 16
putchar '0', 0x02
gotoxy 59, 16
putchar '0', 0x02
gotoxy 60, 16
putchar '0', 0x02
gotoxy 61, 16
putchar '0', 0x02 
gotoxy 62, 16
putchar '1', 0x02
gotoxy 63, 16
putchar '0', 0x02
gotoxy 64, 16
putchar '1', 0x02
gotoxy 65, 16
putchar '1', 0x02
gotoxy 66, 16
putchar '0', 0x02
gotoxy 67, 16
putchar '0', 0x02
gotoxy 68, 16
putchar '0', 0x02
gotoxy 69, 16
putchar '1', 0x02 
gotoxy 70, 16
putchar '1', 0x02
gotoxy 71, 16
putchar '1', 0x02
gotoxy 72, 16
putchar '0', 0x02
gotoxy 73, 16
putchar '1', 0x02
gotoxy 74, 16
putchar '0', 0x02
gotoxy 75, 16
putchar '0', 0x02
gotoxy 76, 16
putchar '0', 0x02
gotoxy 77, 16
putchar '0', 0x02 
gotoxy 78, 16
putchar '1', 0x02
gotoxy 79, 16
putchar '0', 0x02
gotoxy 80, 16
putchar '1', 0x02

gotoxy 0, 17
putchar '1', 0x02
gotoxy 1, 17
putchar '1', 0x02
gotoxy 2, 17
putchar '0', 0x02
gotoxy 3, 17
putchar '1', 0x02
gotoxy 4, 17
putchar '1', 0x02
gotoxy 5, 17
putchar '1', 0x02
gotoxy 6, 17
putchar '1', 0x02
gotoxy 7, 17
putchar '0', 0x02
gotoxy 8, 17
putchar '1', 0x02
gotoxy 9, 17
putchar '0', 0x02
gotoxy 10, 17
putchar '0', 0x02
gotoxy 11, 17
putchar '0', 0x02
gotoxy 12, 17
putchar '1', 0x02 
gotoxy 13, 17
putchar '1', 0x02
gotoxy 14, 17
putchar '0', 0x02
gotoxy 15, 17
putchar '0', 0x02  
gotoxy 16, 17
putchar '0', 0x02
gotoxy 17, 17
putchar '1', 0x02
gotoxy 18, 17
putchar '1', 0x02
gotoxy 19, 17
putchar '1', 0x02
gotoxy 19, 17
putchar '0', 0x02 
gotoxy 20, 17
putchar '1', 0x02 
gotoxy 21, 17
putchar '0', 0x02
gotoxy 22, 17
putchar '0', 0x02
gotoxy 23, 17
putchar '0', 0x02
gotoxy 24, 17
putchar '0', 0x02
gotoxy 25, 17
putchar '0', 0x02 
gotoxy 26, 17
putchar '1', 0x02
gotoxy 27, 17
putchar '1', 0x02
gotoxy 28, 17
putchar '0', 0x02
gotoxy 29, 17
putchar '1', 0x02 
gotoxy 30, 17
putchar '0', 0x02
gotoxy 47, 17
putchar '0', 0x02
gotoxy 48, 17
putchar '0', 0x02
gotoxy 49, 17
putchar '0', 0x02 
gotoxy 50, 17
putchar '1', 0x02
gotoxy 51, 17
putchar '0', 0x02
gotoxy 52, 17
putchar '1', 0x02
gotoxy 53, 17
putchar '1', 0x02  
gotoxy 54, 17
putchar '1', 0x02
gotoxy 55, 17
putchar '1', 0x02
gotoxy 56, 17
putchar '1', 0x02
gotoxy 57, 17
putchar '1', 0x02 
gotoxy 58, 17
putchar '1', 0x02
gotoxy 59, 17
putchar '1', 0x02
gotoxy 60, 17
putchar '0', 0x02
gotoxy 61, 17
putchar '1', 0x02 
gotoxy 62, 17
putchar '0', 0x02
gotoxy 63, 17
putchar '0', 0x02
gotoxy 64, 17
putchar '0', 0x02
gotoxy 65, 17
putchar '0', 0x02 
gotoxy 66, 17
putchar '1', 0x02
gotoxy 67, 17
putchar '0', 0x02
gotoxy 68, 17
putchar '1', 0x02
gotoxy 69, 17
putchar '1', 0x02 
gotoxy 70, 17
putchar '1', 0x02
gotoxy 71, 17
putchar '1', 0x02
gotoxy 72, 17
putchar '0', 0x02
gotoxy 73, 17
putchar '1', 0x02 
gotoxy 74, 17
putchar '1', 0x02
gotoxy 75, 17
putchar '1', 0x02
gotoxy 76, 17
putchar '0', 0x02
gotoxy 77, 17
putchar '1', 0x02 
gotoxy 78, 17
putchar '0', 0x02
gotoxy 79, 17
putchar '0', 0x02
gotoxy 80, 17
putchar '0', 0x02

gotoxy 0, 18
putchar '1', 0x02 
gotoxy 1, 18
putchar '1', 0x02
gotoxy 2, 18
putchar '0', 0x02
gotoxy 3, 18
putchar '0', 0x02
gotoxy 4, 18
putchar '0', 0x02
gotoxy 5, 18
putchar '0', 0x02
gotoxy 6, 18
putchar '1', 0x02
gotoxy 7, 18
putchar '1', 0x02
gotoxy 8, 18
putchar '1', 0x02
gotoxy 9, 18
putchar '0',0x02
gotoxy 10, 18
putchar '0', 0x02
gotoxy 11, 18
putchar '0', 0x02
gotoxy 12, 18
putchar '1', 0x02
gotoxy 13, 18
putchar '1', 0x02
gotoxy 14, 18
putchar '1', 0x02
gotoxy 15, 18
putchar '1', 0x02  
gotoxy 16, 18
putchar '1', 0x02
gotoxy 17, 18
putchar '0', 0x02
gotoxy 18, 18
putchar '0', 0x02
gotoxy 19, 18
putchar '0', 0x02
gotoxy 19, 18
putchar '0', 0x02
gotoxy 20, 18
putchar '0', 0x02 
gotoxy 21, 18
putchar '1', 0x02
gotoxy 22, 18
putchar '1', 0x02
gotoxy 23, 18
putchar '0', 0x02
gotoxy 24, 18
putchar '1', 0x02
gotoxy 25, 18
putchar '0', 0x02
gotoxy 26, 18
putchar '0', 0x02
gotoxy 27, 18
putchar '0', 0x02
gotoxy 28, 18
putchar '0', 0x02
gotoxy 29, 18
putchar '0', 0x02 
gotoxy 30, 18
putchar '1', 0x02
gotoxy 48, 18
putchar '0', 0x02
gotoxy 49, 18
putchar '0', 0x02
gotoxy 50, 18
putchar '1', 0x02
gotoxy 51, 18
putchar '1', 0x02
gotoxy 52, 18
putchar '1', 0x02
gotoxy 53, 18
putchar '0', 0x02  
gotoxy 54, 18
putchar '1', 0x02
gotoxy 55, 18
putchar '1', 0x02
gotoxy 56, 18
putchar '0', 0x02
gotoxy 57, 18
putchar '1', 0x02
gotoxy 58, 18
putchar '0', 0x02
gotoxy 59, 18
putchar '0', 0x02
gotoxy 60, 18
putchar '0', 0x02
gotoxy 61, 18
putchar '0', 0x02 
gotoxy 62, 18
putchar '1', 0x02
gotoxy 63, 18
putchar '0', 0x02
gotoxy 64, 18
putchar '1', 0x02
gotoxy 65, 18
putchar '1', 0x02
gotoxy 66, 18
putchar '0', 0x02
gotoxy 67, 18
putchar '0', 0x02
gotoxy 68, 18
putchar '0', 0x02
gotoxy 69, 18
putchar '1', 0x02 
gotoxy 70, 18
putchar '1', 0x02
gotoxy 71, 18
putchar '1', 0x02
gotoxy 72, 18
putchar '0', 0x02
gotoxy 73, 18
putchar '1', 0x02
gotoxy 74, 18
putchar '0', 0x02
gotoxy 75, 18
putchar '0', 0x02
gotoxy 76, 18
putchar '0', 0x02
gotoxy 77, 18
putchar '0', 0x02 
gotoxy 78, 18
putchar '1', 0x02
gotoxy 79, 18
putchar '0', 0x02
gotoxy 80, 18
putchar '1', 0x02

gotoxy 0, 19
putchar '1', 0x02
gotoxy 1, 19
putchar '1', 0x02
gotoxy 2, 19
putchar '0', 0x02
gotoxy 3, 19
putchar '1', 0x02
gotoxy 4, 19
putchar '0', 0x02
gotoxy 5, 19
putchar '0', 0x02
gotoxy 6, 19
putchar '0', 0x02
gotoxy 7, 19
putchar '1', 0x02
gotoxy 8, 19
putchar '1', 0x02
gotoxy 9, 19
putchar '0', 0x02
gotoxy 10, 19
putchar '0', 0x02
gotoxy 11, 19
putchar '0', 0x02
gotoxy 12, 19
putchar '1', 0x02
gotoxy 13, 19
putchar '1', 0x02
gotoxy 14, 19
putchar '1', 0x02
gotoxy 15, 19
putchar '1', 0x02  
gotoxy 16, 19
putchar '1', 0x02
gotoxy 17, 19
putchar '0', 0x02
gotoxy 18, 19
putchar '0', 0x02
gotoxy 19, 19
putchar '0', 0x02
gotoxy 19, 19
putchar '0', 0x02
gotoxy 20, 19
putchar '0', 0x02 
gotoxy 21, 19
putchar '1', 0x02
gotoxy 22, 19
putchar '1', 0x02
gotoxy 23, 19
putchar '0', 0x02
gotoxy 24, 19
putchar '1', 0x02
gotoxy 25, 19
putchar '0', 0x02
gotoxy 26, 19
putchar '0', 0x02
gotoxy 27, 19
putchar '0', 0x02
gotoxy 28, 19
putchar '0', 0x02
gotoxy 29, 19
putchar '0', 0x02 
gotoxy 30, 19
putchar '1', 0x02
gotoxy 31, 19
putchar '0', 0x02
gotoxy 32, 19
putchar '1', 0x02
gotoxy 33, 19
putchar '1', 0x02
gotoxy 34, 19
putchar '1', 0x02
gotoxy 49, 19
putchar '0', 0x02
gotoxy 50, 19
putchar '1', 0x02
gotoxy 51, 19
putchar '1', 0x02
gotoxy 52, 19
putchar '1', 0x02
gotoxy 53, 19
putchar '0', 0x02  
gotoxy 54, 19
putchar '1', 0x02
gotoxy 55, 19
putchar '1', 0x02
gotoxy 56, 19
putchar '0', 0x02
gotoxy 57, 19
putchar '1', 0x02
gotoxy 58, 19
putchar '0', 0x02
gotoxy 59, 19
putchar '0', 0x02
gotoxy 60, 19
putchar '0', 0x02
gotoxy 61, 19
putchar '0', 0x02 
gotoxy 62, 19
putchar '1', 0x02
gotoxy 63, 19
putchar '0', 0x02
gotoxy 64, 19
putchar '1', 0x02
gotoxy 65, 19
putchar '1', 0x02
gotoxy 66, 19
putchar '0', 0x02
gotoxy 67, 19
putchar '0', 0x02
gotoxy 68, 19
putchar '0', 0x02
gotoxy 69, 19
putchar '1', 0x02 
gotoxy 70, 19
putchar '1', 0x02
gotoxy 71, 19
putchar '1', 0x02
gotoxy 72, 19
putchar '0', 0x02
gotoxy 73, 19
putchar '1', 0x02
gotoxy 74, 19
putchar '0', 0x02
gotoxy 75, 19
putchar '0', 0x02
gotoxy 76, 19
putchar '0', 0x02
gotoxy 77, 19
putchar '0', 0x02 
gotoxy 78, 19
putchar '1', 0x02
gotoxy 79, 19
putchar '0', 0x02
gotoxy 80, 19
putchar '1', 0x02

gotoxy 0, 20
putchar '1', 0x02
gotoxy 1, 20
putchar '1', 0x02
gotoxy 2, 20
putchar '0', 0x02
gotoxy 3, 20
putchar '1', 0x02
gotoxy 4, 20
putchar '0', 0x02
gotoxy 5, 20
putchar '0', 0x02
gotoxy 6, 20
putchar '0', 0x02
gotoxy 7, 20
putchar '1', 0x02
gotoxy 8, 20
putchar '1', 0x02
gotoxy 9, 20
putchar '0', 0x02
gotoxy 10, 20
putchar '0', 0x02
gotoxy 11, 20
putchar '0', 0x02
gotoxy 12, 20
putchar '1', 0x02
gotoxy 13, 20
putchar '1', 0x02
gotoxy 14, 20
putchar '1', 0x02
gotoxy 15, 20
putchar '1', 0x02  
gotoxy 16, 20
putchar '1', 0x02
gotoxy 17, 20
putchar '0', 0x02
gotoxy 18, 20
putchar '0', 0x02
gotoxy 19, 20
putchar '0', 0x02
gotoxy 19, 20
putchar '0', 0x02
gotoxy 20, 20
putchar '0', 0x02 
gotoxy 21, 20
putchar '1', 0x02
gotoxy 22, 20
putchar '1', 0x02
gotoxy 23, 20
putchar '0', 0x02
gotoxy 24, 20
putchar '1', 0x02
gotoxy 25, 20
putchar '0', 0x02
gotoxy 26, 20
putchar '0', 0x02
gotoxy 27, 20
putchar '0', 0x02
gotoxy 28, 20
putchar '0', 0x02
gotoxy 29, 20
putchar '0', 0x02 
gotoxy 30, 20
putchar '1', 0x02
gotoxy 31, 20
putchar '0', 0x02
gotoxy 32, 20
putchar '1', 0x02
gotoxy 33, 20
putchar '1', 0x02
gotoxy 34, 20
putchar '1', 0x02
gotoxy 35, 20
putchar '0', 0x02
gotoxy 36, 20
putchar '1', 0x02
gotoxy 48, 20
putchar '0', 0x02
gotoxy 49, 20
putchar '0', 0x02
gotoxy 50, 20
putchar '1', 0x02
gotoxy 51, 20
putchar '1', 0x02
gotoxy 52, 20
putchar '1', 0x02
gotoxy 53, 20
putchar '0', 0x02  
gotoxy 54, 20
putchar '1', 0x02
gotoxy 55, 20
putchar '1', 0x02
gotoxy 56, 20
putchar '0', 0x02
gotoxy 57, 20
putchar '1', 0x02
gotoxy 58, 20
putchar '0', 0x02
gotoxy 59, 20
putchar '0', 0x02
gotoxy 60, 20
putchar '0', 0x02
gotoxy 61, 20
putchar '0', 0x02 
gotoxy 62, 20
putchar '1', 0x02
gotoxy 63, 20
putchar '0', 0x02
gotoxy 64, 20
putchar '1', 0x02
gotoxy 65, 20
putchar '1', 0x02
gotoxy 66, 20
putchar '0', 0x02
gotoxy 67, 20
putchar '0', 0x02
gotoxy 68, 20
putchar '0', 0x02
gotoxy 69, 20
putchar '1', 0x02 
gotoxy 70, 20
putchar '1', 0x02
gotoxy 71, 20
putchar '1', 0x02
gotoxy 72, 20
putchar '0', 0x02
gotoxy 73, 20
putchar '1', 0x02
gotoxy 74, 20
putchar '0', 0x02
gotoxy 75, 20
putchar '0', 0x02
gotoxy 76, 20
putchar '0', 0x02
gotoxy 77, 20
putchar '0', 0x02 
gotoxy 78, 20
putchar '1', 0x02
gotoxy 79, 20
putchar '0', 0x02
gotoxy 80, 20
putchar '1', 0x02

gotoxy 0, 21
putchar '1', 0x02
gotoxy 1, 21
putchar '1', 0x02
gotoxy 2, 21
putchar '0', 0x02
gotoxy 3, 21
putchar '1', 0x02
gotoxy 4, 21
putchar '1', 0x02 
gotoxy 5, 21
putchar '1', 0x02
gotoxy 6, 21
putchar '1', 0x02
gotoxy 7, 21
putchar '0', 0x02
gotoxy 8, 21
putchar '1', 0x02
gotoxy 9, 21
putchar '0', 0x02
gotoxy 10, 21
putchar '0', 0x02
gotoxy 11, 21
putchar '0', 0x02
gotoxy 12, 21
putchar '1', 0x02 
gotoxy 13, 21
putchar '1', 0x02
gotoxy 14, 21
putchar '0', 0x02
gotoxy 15, 21
putchar '0', 0x02  
gotoxy 16, 21
putchar '0', 0x02
gotoxy 17, 21
putchar '1', 0x02
gotoxy 18, 21
putchar '1', 0x02
gotoxy 19, 21
putchar '1', 0x02
gotoxy 19, 21
putchar '0', 0x02 
gotoxy 20, 21
putchar '1', 0x02 
gotoxy 21, 21
putchar '0', 0x02
gotoxy 22, 21
putchar '0', 0x02
gotoxy 23, 21
putchar '0', 0x02
gotoxy 24, 21
putchar '0', 0x02
gotoxy 25, 21
putchar '0', 0x02 
gotoxy 26, 21
putchar '1', 0x02
gotoxy 27, 21
putchar '1', 0x02
gotoxy 28, 21
putchar '0', 0x02
gotoxy 29, 21
putchar '1', 0x02 
gotoxy 30, 21
putchar '0', 0x02
gotoxy 31, 21
putchar '0', 0x02
gotoxy 32, 21
putchar '0', 0x02
gotoxy 33, 21
putchar '1', 0x02 
gotoxy 34, 21
putchar '1', 0x02
gotoxy 35, 21
putchar '0', 0x02
gotoxy 36, 21
putchar '0', 0x02
gotoxy 37, 21
putchar '0', 0x02 
gotoxy 38, 21
putchar '1', 0x02
gotoxy 39, 21
putchar '1', 0x02
gotoxy 47, 21
putchar '0', 0x02
gotoxy 48, 21
putchar '0', 0x02
gotoxy 49, 21
putchar '0', 0x02 
gotoxy 50, 21
putchar '1', 0x02
gotoxy 51, 21
putchar '0', 0x02
gotoxy 52, 21
putchar '1', 0x02
gotoxy 53, 21
putchar '1', 0x02  
gotoxy 54, 21
putchar '1', 0x02
gotoxy 55, 21
putchar '1', 0x02
gotoxy 56, 21
putchar '1', 0x02
gotoxy 57, 21
putchar '1', 0x02 
gotoxy 58, 21
putchar '1', 0x02
gotoxy 59, 21
putchar '1', 0x02
gotoxy 60, 21
putchar '0', 0x02
gotoxy 61, 21
putchar '1', 0x02 
gotoxy 62, 21
putchar '0', 0x02
gotoxy 63, 21
putchar '0', 0x02
gotoxy 64, 21
putchar '0', 0x02
gotoxy 65, 21
putchar '0', 0x02 
gotoxy 66, 21
putchar '1', 0x02
gotoxy 67, 21
putchar '0', 0x02
gotoxy 68, 21
putchar '1', 0x02
gotoxy 69, 21
putchar '1', 0x02 
gotoxy 70, 21
putchar '1', 0x02
gotoxy 71, 21
putchar '1', 0x02
gotoxy 72, 21
putchar '0', 0x02
gotoxy 73, 21
putchar '1', 0x02 
gotoxy 74, 21
putchar '1', 0x02
gotoxy 75, 21
putchar '1', 0x02
gotoxy 76, 21
putchar '0', 0x02
gotoxy 77, 21
putchar '1', 0x02 
gotoxy 78, 21
putchar '0', 0x02
gotoxy 79, 21
putchar '0', 0x02
gotoxy 80, 21
putchar '0', 0x02

gotoxy 0, 22
putchar '1', 0x02 
gotoxy 1, 22
putchar '1', 0x02
gotoxy 2, 22
putchar '0', 0x02
gotoxy 3, 22
putchar '0', 0x02
gotoxy 4, 22
putchar '0', 0x02
gotoxy 5, 22
putchar '0', 0x02
gotoxy 6, 22
putchar '1', 0x02
gotoxy 7, 22
putchar '1', 0x02
gotoxy 8, 22
putchar '1', 0x02
gotoxy 9, 22
putchar '0',0x02
gotoxy 10, 22
putchar '0', 0x02
gotoxy 11, 22
putchar '0', 0x02
gotoxy 12, 22
putchar '1', 0x02
gotoxy 13, 22
putchar '1', 0x02
gotoxy 14, 22
putchar '1', 0x02
gotoxy 15, 22
putchar '1', 0x02  
gotoxy 16, 22
putchar '1', 0x02
gotoxy 17, 22
putchar '0', 0x02
gotoxy 18, 22
putchar '0', 0x02
gotoxy 19, 22
putchar '0', 0x02
gotoxy 19, 22
putchar '0', 0x02
gotoxy 20, 22
putchar '0', 0x02 
gotoxy 21, 22
putchar '1', 0x02
gotoxy 22, 22
putchar '1', 0x02
gotoxy 23, 22
putchar '0', 0x02
gotoxy 24, 22
putchar '1', 0x02
gotoxy 25, 22
putchar '0', 0x02
gotoxy 26, 22
putchar '0', 0x02
gotoxy 27, 22
putchar '0', 0x02
gotoxy 28, 22
putchar '0', 0x02
gotoxy 29, 22
putchar '0', 0x02 
gotoxy 30, 22
putchar '1', 0x02
gotoxy 31, 22
putchar '0', 0x02
gotoxy 32, 22
putchar '1', 0x02
gotoxy 33, 22
putchar '1', 0x02
gotoxy 34, 22
putchar '1', 0x02
gotoxy 35, 22
putchar '0', 0x02
gotoxy 36, 22
putchar '1', 0x02
gotoxy 37, 22
putchar '1', 0x02 
gotoxy 38, 22
putchar '1', 0x02
gotoxy 39, 22
putchar '1', 0x02
gotoxy 40, 22
putchar '0', 0x02
gotoxy 41, 22
putchar '1', 0x02
gotoxy 42, 22
putchar '0', 0x02
gotoxy 43, 22
putchar '0', 0x02
gotoxy 44, 22
putchar '0', 0x02
gotoxy 45, 22
putchar '1', 0x02 
gotoxy 46, 22
putchar '1', 0x02
gotoxy 47, 22
putchar '0', 0x02
gotoxy 48, 22
putchar '0', 0x02
gotoxy 49, 22
putchar '0', 0x02
gotoxy 50, 22
putchar '1', 0x02
gotoxy 51, 22
putchar '1', 0x02
gotoxy 52, 22
putchar '1', 0x02
gotoxy 53, 22
putchar '0', 0x02  
gotoxy 54, 22
putchar '1', 0x02
gotoxy 55, 22
putchar '1', 0x02
gotoxy 56, 22
putchar '0', 0x02
gotoxy 57, 22
putchar '1', 0x02
gotoxy 58, 22
putchar '0', 0x02
gotoxy 59, 22
putchar '0', 0x02
gotoxy 60, 22
putchar '0', 0x02
gotoxy 61, 22
putchar '0', 0x02 
gotoxy 62, 22
putchar '1', 0x02
gotoxy 63, 22
putchar '0', 0x02
gotoxy 64, 22
putchar '1', 0x02
gotoxy 65, 22
putchar '1', 0x02
gotoxy 66, 22
putchar '0', 0x02
gotoxy 67, 22
putchar '0', 0x02
gotoxy 68, 22
putchar '0', 0x02
gotoxy 69, 22
putchar '1', 0x02 
gotoxy 70, 22
putchar '1', 0x02
gotoxy 71, 22
putchar '1', 0x02
gotoxy 72, 22
putchar '0', 0x02
gotoxy 73, 22
putchar '1', 0x02
gotoxy 74, 22
putchar '0', 0x02
gotoxy 75, 22
putchar '0', 0x02
gotoxy 76, 22
putchar '0', 0x02
gotoxy 77, 22
putchar '0', 0x02 
gotoxy 78, 22
putchar '1', 0x02
gotoxy 79, 22
putchar '0', 0x02
gotoxy 80, 22
putchar '1', 0x02

gotoxy 0, 23
putchar '1', 0x02
gotoxy 1, 23
putchar '1', 0x02
gotoxy 2, 23
putchar '0', 0x02
gotoxy 3, 23
putchar '1', 0x02
gotoxy 4, 23
putchar '0', 0x02
gotoxy 5, 23
putchar '0', 0x02
gotoxy 6, 23
putchar '0', 0x02
gotoxy 7, 23
putchar '1', 0x02
gotoxy 8, 23
putchar '1', 0x02
gotoxy 9, 23
putchar '0', 0x02
gotoxy 10, 23
putchar '0', 0x02
gotoxy 11, 23
putchar '0', 0x02
gotoxy 12, 23
putchar '1', 0x02
gotoxy 13, 23
putchar '1', 0x02
gotoxy 14, 23
putchar '1', 0x02
gotoxy 15, 23
putchar '1', 0x02  
gotoxy 16, 23
putchar '1', 0x02
gotoxy 17, 23
putchar '0', 0x02
gotoxy 18, 23
putchar '0', 0x02
gotoxy 19, 23
putchar '0', 0x02
gotoxy 19, 23
putchar '0', 0x02
gotoxy 20, 23
putchar '0', 0x02 
gotoxy 21, 23
putchar '1', 0x02
gotoxy 22, 23
putchar '1', 0x02
gotoxy 23, 23
putchar '0', 0x02
gotoxy 24, 23
putchar '1', 0x02
gotoxy 25, 23
putchar '0', 0x02
gotoxy 26, 23
putchar '0', 0x02
gotoxy 27, 23
putchar '0', 0x02
gotoxy 28, 23
putchar '0', 0x02
gotoxy 29, 23
putchar '0', 0x02 
gotoxy 30, 23
putchar '1', 0x02
gotoxy 31, 23
putchar '0', 0x02
gotoxy 32, 23
putchar '1', 0x02
gotoxy 33, 23
putchar '1', 0x02
gotoxy 34, 23
putchar '1', 0x02
gotoxy 35, 23
putchar '0', 0x02
gotoxy 36, 23
putchar '1', 0x02
gotoxy 37, 23
putchar '1', 0x02 
gotoxy 38, 23
putchar '1', 0x02
gotoxy 39, 23
putchar '1', 0x02
gotoxy 40, 23
putchar '0', 0x02
gotoxy 41, 23
putchar '1', 0x02
gotoxy 42, 23
putchar '0', 0x02
gotoxy 43, 23
putchar '0', 0x02
gotoxy 44, 23
putchar '0', 0x02
gotoxy 45, 23
putchar '1', 0x02 
gotoxy 46, 23
putchar '1', 0x02
gotoxy 47, 23
putchar '0', 0x02
gotoxy 48, 23
putchar '0', 0x02
gotoxy 49, 23
putchar '0', 0x02
gotoxy 50, 23
putchar '1', 0x02
gotoxy 51, 23
putchar '1', 0x02
gotoxy 52, 23
putchar '1', 0x02
gotoxy 53, 23
putchar '0', 0x02  
gotoxy 54, 23
putchar '1', 0x02
gotoxy 55, 23
putchar '1', 0x02
gotoxy 56, 23
putchar '0', 0x02
gotoxy 57, 23
putchar '1', 0x02
gotoxy 58, 23
putchar '0', 0x02
gotoxy 59, 23
putchar '0', 0x02
gotoxy 60, 23
putchar '0', 0x02
gotoxy 61, 23
putchar '0', 0x02 
gotoxy 62, 23
putchar '1', 0x02
gotoxy 63, 23
putchar '0', 0x02
gotoxy 64, 23
putchar '1', 0x02
gotoxy 65, 23
putchar '1', 0x02
gotoxy 66, 23
putchar '0', 0x02
gotoxy 67, 23
putchar '0', 0x02
gotoxy 68, 23
putchar '0', 0x02
gotoxy 69, 23
putchar '1', 0x02 
gotoxy 70, 23
putchar '1', 0x02
gotoxy 71, 23
putchar '1', 0x02
gotoxy 72, 23
putchar '0', 0x02
gotoxy 73, 23
putchar '1', 0x02
gotoxy 74, 23
putchar '0', 0x02
gotoxy 75, 23
putchar '0', 0x02
gotoxy 76, 23
putchar '0', 0x02
gotoxy 77, 23
putchar '0', 0x02 
gotoxy 78, 23
putchar '1', 0x02
gotoxy 79, 23
putchar '0', 0x02
gotoxy 80, 23
putchar '1', 0x02

gotoxy 0, 24
putchar '1', 0x02
gotoxy 1, 24
putchar '1', 0x02
gotoxy 2, 24
putchar '0', 0x02
gotoxy 3, 24
putchar '1', 0x02
gotoxy 4, 24
putchar '1', 0x02 
gotoxy 5, 24
putchar '1', 0x02
gotoxy 6, 24
putchar '1', 0x02
gotoxy 7, 24
putchar '0', 0x02
gotoxy 8, 24
putchar '1', 0x02
gotoxy 9, 24
putchar '0', 0x02
gotoxy 10, 24
putchar '0', 0x02
gotoxy 11, 24
putchar '0', 0x02
gotoxy 12, 24
putchar '1', 0x02 
gotoxy 13, 24
putchar '1', 0x02
gotoxy 14, 24
putchar '0', 0x02
gotoxy 15, 24
putchar '0', 0x02  
gotoxy 16, 24
putchar '0', 0x02
gotoxy 17, 24
putchar '1', 0x02
gotoxy 18, 24
putchar '1', 0x02
gotoxy 19, 24
putchar '1', 0x02
gotoxy 19, 24
putchar '0', 0x02 
gotoxy 20, 24
putchar '1', 0x02 
gotoxy 21, 24
putchar '0', 0x02
gotoxy 22, 24
putchar '0', 0x02
gotoxy 23, 24
putchar '0', 0x02
gotoxy 24, 24
putchar '0', 0x02
gotoxy 25, 24
putchar '0', 0x02 
gotoxy 26, 24
putchar '1', 0x02
gotoxy 27, 24
putchar '1', 0x02
gotoxy 28, 24
putchar '0', 0x02
gotoxy 29, 24
putchar '1', 0x02 
gotoxy 30, 24
putchar '0', 0x02
gotoxy 31, 24
putchar '0', 0x02
gotoxy 32, 24
putchar '0', 0x02
gotoxy 33, 24
putchar '1', 0x02 
gotoxy 34, 24
putchar '1', 0x02
gotoxy 35, 24
putchar '0', 0x02
gotoxy 36, 24
putchar '0', 0x02
gotoxy 37, 24
putchar '0', 0x02 
gotoxy 38, 24
putchar '1', 0x02
gotoxy 39, 24
putchar '1', 0x02
gotoxy 40, 24
putchar '1', 0x02
gotoxy 41, 24
putchar '1', 0x02 
gotoxy 42, 24
putchar '1', 0x02
gotoxy 43, 24
putchar '1', 0x02
gotoxy 44, 24
putchar '0', 0x02
gotoxy 45, 24
putchar '1', 0x02 
gotoxy 46, 24
putchar '0', 0x02
gotoxy 47, 24
putchar '0', 0x02
gotoxy 48, 24
putchar '0', 0x02
gotoxy 49, 24
putchar '0', 0x02 
gotoxy 50, 24
putchar '1', 0x02
gotoxy 51, 24
putchar '0', 0x02
gotoxy 52, 24
putchar '1', 0x02
gotoxy 53, 24
putchar '1', 0x02  
gotoxy 54, 24
putchar '1', 0x02
gotoxy 55, 24
putchar '1', 0x02
gotoxy 56, 24
putchar '1', 0x02
gotoxy 57, 24
putchar '1', 0x02 
gotoxy 58, 24
putchar '1', 0x02
gotoxy 59, 24
putchar '1', 0x02
gotoxy 60, 24
putchar '0', 0x02
gotoxy 61, 24
putchar '1', 0x02 
gotoxy 62, 24
putchar '0', 0x02
gotoxy 63, 24
putchar '0', 0x02
gotoxy 64, 24
putchar '0', 0x02
gotoxy 65, 24
putchar '0', 0x02 
gotoxy 66, 24
putchar '1', 0x02
gotoxy 67, 24
putchar '0', 0x02
gotoxy 68, 24
putchar '1', 0x02
gotoxy 69, 24
putchar '1', 0x02 
gotoxy 70, 24
putchar '1', 0x02
gotoxy 71, 24
putchar '1', 0x02
gotoxy 72, 24
putchar '0', 0x02
gotoxy 73, 24
putchar '1', 0x02 
gotoxy 74, 24
putchar '1', 0x02
gotoxy 75, 24
putchar '1', 0x02
gotoxy 76, 24
putchar '0', 0x02
gotoxy 77, 24
putchar '1', 0x02 
gotoxy 78, 24
putchar '0', 0x02
gotoxy 79, 24
putchar '0', 0x02
gotoxy 80, 24
putchar '0', 0x02

    gotoxy 37, 6
    putchar '*', 0x07
    gotoxy 38, 6
    putchar '*', 0x07
    gotoxy 39, 6
    putchar '*', 0x07
    gotoxy 40, 6
    putchar '*', 0x07
    gotoxy 41, 6
    putchar '*', 0x07

    gotoxy 35, 7
    putchar '*', 0x07
    gotoxy 36, 7
    putchar '*', 0x07
    gotoxy 37, 7
    putchar '*', 0x0F
    gotoxy 38, 7
    putchar '*', 0x0F
    gotoxy 39, 7
    putchar '*', 0x0F
    gotoxy 40, 7
    putchar '*', 0x0F
    gotoxy 41, 7
    putchar '*', 0x0F
    gotoxy 42, 7
    putchar '*', 0x07
    gotoxy 43, 7
    putchar '*', 0x07

    gotoxy 34, 8
    putchar '*', 0x07
    gotoxy 35, 8
    putchar '*', 0x0F
    gotoxy 36, 8
    putchar '*', 0x0F
    gotoxy 37, 8
    putchar '*', 0x0F
    gotoxy 38, 8
    putchar '*', 0x0F
    gotoxy 39, 8
    putchar '*', 0x0F
    gotoxy 40, 8
    putchar '*', 0x0F
    gotoxy 41, 8
    putchar '*', 0x0F
    gotoxy 42, 8
    putchar '*', 0x0F
    gotoxy 43, 8
    putchar '*', 0x0F
    gotoxy 44, 8
    putchar '*', 0x07

    gotoxy 33, 9
    putchar '*', 0x07
    gotoxy 34, 9
    putchar '*', 0x0F
    gotoxy 35, 9
    putchar '*', 0x0F
    gotoxy 36, 9
    putchar '*', 0x0F
    gotoxy 37, 9
    putchar '*', 0x0F
    gotoxy 38, 9
    putchar '*', 0x0F
    gotoxy 39, 9
    putchar '*', 0x0F
    gotoxy 40, 9
    putchar '*', 0x0F
    gotoxy 41, 9
    putchar '*', 0x0F
    gotoxy 42, 9
    putchar '*', 0x0F
    gotoxy 43, 9
    putchar '*', 0x0F
    gotoxy 44, 9
    putchar '*', 0x0F
    gotoxy 45, 9
    putchar '*', 0x07

    gotoxy 33, 10
    putchar '*', 0x07
    gotoxy 34, 10
    putchar '*', 0x0F
    gotoxy 35, 10
    putchar '*', 0x0F
    gotoxy 36, 10
    putchar '*', 0x0F
    gotoxy 37, 10
    putchar '*', 0x0F
    gotoxy 38, 10
    putchar '*', 0x0F
    gotoxy 39, 10
    putchar '*', 0x0F
    gotoxy 40, 10
    putchar '*', 0x0F
    gotoxy 41, 10
    putchar '*', 0x0F
    gotoxy 42, 10
    putchar '*', 0x0F
    gotoxy 43, 10
    putchar '*', 0x0F
    gotoxy 44, 10
    putchar '*', 0x0F
    gotoxy 45, 10
    putchar '*', 0x07

    gotoxy 32, 11
    putchar '*', 0x07
    gotoxy 33, 11
    putchar '*', 0x0F  
    gotoxy 34, 11
    putchar '*', 0x0F
    gotoxy 35, 11
    putchar '*', 0x07
    gotoxy 36, 11
    putchar '*', 0x07
    gotoxy 37, 11
    putchar '*', 0x0F
    gotoxy 38, 11
    putchar '*', 0x0F
    gotoxy 39, 11
    putchar '*', 0x07
    gotoxy 40, 11
    putchar '*', 0x07
    gotoxy 41, 11
    putchar '*', 0x0F
    gotoxy 42, 11
    putchar '*', 0x0F
    gotoxy 43, 11
    putchar '*', 0x0F
    gotoxy 44, 11
    putchar '*', 0x0F
    gotoxy 45, 11
    putchar '*', 0x0F
    gotoxy 46, 11
    putchar '*', 0x07

    gotoxy 32, 12
    putchar '*', 0x07
    gotoxy 33, 12
    putchar '*', 0x0F
    gotoxy 34, 12
    putchar '*', 0x07
    gotoxy 35, 12
    putchar '*', 0x07
    gotoxy 36, 12
    putchar '*', 0x07
    gotoxy 37, 12
    putchar '*', 0x0F
    gotoxy 38, 12
    putchar '*', 0x0F
    gotoxy 39, 12
    putchar '*', 0x07
    gotoxy 40, 12
    putchar '*', 0x07
    gotoxy 41, 12
    putchar '*', 0x07
    gotoxy 42, 12
    putchar '*', 0x0F
    gotoxy 43, 12
    putchar '*', 0x0F
    gotoxy 44, 12
    putchar '*', 0x0F
    gotoxy 45, 12
    putchar '*', 0x0F
    gotoxy 46, 12
    putchar '*', 0x07

    gotoxy 32, 13
    putchar '*', 0x07
    gotoxy 33, 13
    putchar '*', 0x0F
    gotoxy 34, 13
    putchar '*', 0x07
    gotoxy 35, 13
    putchar '*', 0x07
    gotoxy 36, 13
    putchar '*', 0x07
    gotoxy 37, 13
    putchar '*', 0x0F
    gotoxy 38, 13
    putchar '*', 0x0F
    gotoxy 39, 13
    putchar '*', 0x07
    gotoxy 40, 13
    putchar '*', 0x07
    gotoxy 41, 13
    putchar '*', 0x07
    gotoxy 42, 13
    putchar '*', 0x0F
    gotoxy 43, 13
    putchar '*', 0x0F
    gotoxy 44, 13
    putchar '*', 0x0F
    gotoxy 45, 13
    putchar '*', 0x0F
    gotoxy 46, 13
    putchar '*', 0x07

    gotoxy 32, 14
    putchar '*', 0x07
    gotoxy 33, 14
    putchar '*', 0x0F
    gotoxy 34, 14
    putchar '*', 0x07
    gotoxy 35, 14
    putchar '*', 0x07
    gotoxy 36, 14
    putchar '*', 0x0F
    gotoxy 37, 14
    putchar '*', 0x0F
    gotoxy 38, 14
    putchar '*', 0x0F
    gotoxy 39, 14
    putchar '*', 0x0F
    gotoxy 40, 14
    putchar '*', 0x07
    gotoxy 41, 14
    putchar '*', 0x07
    gotoxy 42, 14
    putchar '*', 0x0F
    gotoxy 43, 14
    putchar '*', 0x0F
    gotoxy 44, 14
    putchar '*', 0x0F
    gotoxy 45, 14
    putchar '*', 0x0F
    gotoxy 46, 14
    putchar '*', 0x07

    gotoxy 32, 15
    putchar '*', 0x07
    gotoxy 33, 15
    putchar '*', 0x0F
    gotoxy 34, 15
    putchar '*', 0x0F
    gotoxy 35, 15
    putchar '*', 0x0F
    gotoxy 36, 15
    putchar '*', 0x0F
    gotoxy 37, 15
    putchar '*', 0x0F
    gotoxy 38, 15
    putchar '*', 0x0F
    gotoxy 39, 15
    putchar '*', 0x0F
    gotoxy 40, 15
    putchar '*', 0x0F
    gotoxy 41, 15
    putchar '*', 0x0F
    gotoxy 42, 15
    putchar '*', 0x0F
    gotoxy 43, 15
    putchar '*', 0x0F
    gotoxy 44, 15
    putchar '*', 0x0F
    gotoxy 45, 15
    putchar '*', 0x0F
    gotoxy 46, 15
    putchar '*', 0x07

    gotoxy 32, 16
    putchar '*', 0x07
    gotoxy 33, 16
    putchar '*', 0x0F
    gotoxy 34, 16
    putchar '*', 0x0F
    gotoxy 35, 16
    putchar '*', 0x0F
    gotoxy 36, 16
    putchar '*', 0x0F
    gotoxy 37, 16
    putchar '*', 0x07
    gotoxy 38, 16
    putchar '*', 0x07
    gotoxy 39, 16
    putchar '*', 0x0F
    gotoxy 40, 16
    putchar '*', 0x0F
    gotoxy 41, 16
    putchar '*', 0x0F
    gotoxy 42, 16
    putchar '*', 0x07
    gotoxy 43, 16
    putchar '*', 0x07
    gotoxy 44, 16
    putchar '*', 0x0F
    gotoxy 45, 16
    putchar '*', 0x0F
    gotoxy 46, 16
    putchar '*', 0x07

    gotoxy 31, 17
    putchar '*', 0x07
    gotoxy 32, 17
    putchar '*', 0x0F
    gotoxy 33, 17
    putchar '*', 0x07
    gotoxy 34, 17
    putchar '*', 0x0F
    gotoxy 35, 17
    putchar '*', 0x0F
    gotoxy 36, 17
    putchar '*', 0x0F
    gotoxy 37, 17
    putchar '*', 0x07
    gotoxy 38, 17
    putchar '*', 0x07
    gotoxy 39, 17
    putchar '*', 0x0F
    gotoxy 40, 17
    putchar '*', 0x0F
    gotoxy 41, 17
    putchar '*', 0x07
    gotoxy 42, 17
    putchar '*', 0x0F
    gotoxy 43, 17
    putchar '*', 0x0F
    gotoxy 44, 17
    putchar '*', 0x0F
    gotoxy 45, 17
    putchar '*', 0x0F
    gotoxy 46, 17
    putchar '*', 0x07

    gotoxy 31, 18
    putchar '*', 0x07
    gotoxy 32, 18
    putchar '*', 0x0F
    gotoxy 33, 18
    putchar '*', 0x07
    gotoxy 34, 18
    putchar '*', 0x07
    gotoxy 35, 18
    putchar '*', 0x0F
    gotoxy 36, 18
    putchar '*', 0x0F
    gotoxy 37, 18
    putchar '*', 0x07
    gotoxy 38, 18
    putchar '*', 0x07
    gotoxy 39, 18
    putchar '*', 0x0F
    gotoxy 40, 18
    putchar '*', 0x0F
    gotoxy 41, 18
    putchar '*', 0x07
    gotoxy 42, 18
    putchar '*', 0x0F
    gotoxy 43, 18
    putchar '*', 0x0F
    gotoxy 44, 18
    putchar '*', 0x0F
    gotoxy 45, 18
    putchar '*', 0x0F
    gotoxy 46, 18
    putchar '*', 0x0F
    gotoxy 47, 18
    putchar '*', 0x07

    gotoxy 35, 19
    putchar '*', 0x07
    gotoxy 36, 19
    putchar '*', 0x07
    gotoxy 37, 19
    putchar '*', 0x0F
    gotoxy 38, 19
    putchar '*', 0x0F
    gotoxy 39, 19
    putchar '*', 0x0F
    gotoxy 40, 19
    putchar '*', 0x0F
    gotoxy 41, 19
    putchar '*', 0x07
    gotoxy 42, 19
    putchar '*', 0x07
    gotoxy 43, 19
    putchar '*', 0x0F
    gotoxy 44, 19
    putchar '*', 0x0F
    gotoxy 45, 19
    putchar '*', 0x0F
    gotoxy 46, 19
    putchar '*', 0x0F
    gotoxy 47, 19
    putchar '*', 0x0F
    gotoxy 48, 19
    putchar '*', 0x07

    gotoxy 37, 20
    putchar '*', 0x07
    gotoxy 38, 20
    putchar '*', 0x07
    gotoxy 39, 20
    putchar '*', 0x07
    gotoxy 40, 20
    putchar '*', 0x0F
    gotoxy 41, 20
    putchar '*', 0x0F
    gotoxy 42, 20
    putchar '*', 0x0F
    gotoxy 43, 20
    putchar '*', 0x0F
    gotoxy 44, 20
    putchar '*', 0x0F
    gotoxy 45, 20
    putchar '*', 0x0F
    gotoxy 46, 20
    putchar '*', 0x0F
    gotoxy 47, 20
    putchar '*', 0x07

    gotoxy 40, 21
    putchar '*', 0x07
    gotoxy 41, 21
    putchar '*', 0x07
    gotoxy 42, 21
    putchar '*', 0x07
    gotoxy 43, 21
    putchar '*', 0x07
    gotoxy 44, 21
    putchar '*', 0x07
    gotoxy 45, 21
    putchar '*', 0x07
    gotoxy 46, 21
    putchar '*', 0x07
    ret

    
        

