extern unsigned short _cdecl strlen(char* string) {
    unsigned short ret = 0;
    while (1) {
        if (string[ret]==0) {
            return ret;        
        }
        ret = ret + 1;
    }
}


extern void _cdecl textmodeinit() {
    
    __asm {
        push ax
        mov ax,0003h
        int 10h
        pop ax
    }
}

//Перемещает курсор в точку x y
extern void _cdecl gotoxy(short x, short y) {

    __asm {

        push ax
        push bx
        push dx

        mov ax, y
        mov dh, al
        mov ax, x
        mov dl, al
        mov ah, 2
        mov al, 0
        mov bx, 0
        int 10h

        pop dx
        pop bx
        pop ax

    }
}

//Узнает текущее положение курсора
extern void _cdecl getxy(short* x, short* y) {
    short loc_temp;

    __asm {
        push ax
        push bx
        push cx
        push dx
        mov ah, 03H
        mov bx, 0
        int 10h
        mov loc_temp, dx
        pop dx
        pop cx
        pop bx
        pop ax
    }
    *y = (loc_temp & 0xFF00) >> 8;
    *x = (loc_temp & 0x00FF);
}

//Кладет символ в текущее положение курсора
void putch(char sym) {

    __asm {
        push ax
        push bx
        push cx    

        mov al, sym
        mov ah, 0ah
        mov cx, 1        
        mov bx, 0
        int 10h
    
        pop cx
        pop bx
        pop ax
    }

}

//Кладет строку в текущее положение курсора
extern void _cdecl puts(char* str) {
    short x;
    short y;
    short counter;
    unsigned short len;
    getxy(&x, &y);
    len = strlen(str);
    for (counter=0;counter<len;counter=counter+1) {
        if (x==81) {
            y=y+1;
            x=0;
        }
        if (str[counter]=='\r') {
            x=0;
            continue;        
        }
        if (str[counter]=='\n') {
            y=y+1;
            continue;        
        }
        gotoxy(x, y);
        putch(str[counter]);
        x=x+1;
    } 
    gotoxy(x, y);
    
}
