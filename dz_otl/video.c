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


extern void _cdecl draw_char(unsigned short cc) {
	char sym;
	char color;
	sym = cc & 0x00FF;
	color = (cc & 0xFF00) >> 8;
	__asm {
	   push ax
	   push bx
	   push cx
	   
	   mov bh, 0
	   mov al, sym
	   mov cx, 1
	   mov bl, color
	   mov ah, 0x09
	   int 0x10
	   
	   pop cx
	   pop bx
	   pop ax
	}
}


extern void _cdecl test_me() { 
gotoxy (37, 6);
draw_char(0x7000 | (' '));
gotoxy (38, 6);
draw_char(0x7000 | (' '));
gotoxy (39, 6);
draw_char(0x7000 | (' '));
gotoxy (40, 6);
draw_char(0x7000 | (' '));
gotoxy (41, 6);
draw_char(0x7000 | (' '));
gotoxy (35, 7);
draw_char(0x7000 | (' '));
gotoxy (36, 7);
draw_char(0x7000 | (' '));
gotoxy (37, 7);
draw_char(0x7000 | (' '));
gotoxy (38, 7);
draw_char(0x7000 | (' '));
gotoxy (39, 7);
draw_char(0x7000 | (' '));
gotoxy (40, 7);
draw_char(0x7000 | (' '));
gotoxy (41, 7);
draw_char(0x7000 | (' '));
gotoxy (42, 7);
draw_char(0x7000 | (' '));
gotoxy (43, 7);
draw_char(0x7000 | (' '));
gotoxy (34, 8);
draw_char(0x7000 | (' '));
gotoxy (35, 8);
draw_char(0x7000 | (' '));
gotoxy (36, 8);
draw_char(0x7000 | (' '));
gotoxy (37, 8);
draw_char(0x7000 | (' '));
gotoxy (38, 8);
draw_char(0x7000 | (' '));
gotoxy (39, 8);
draw_char(0x7000 | (' '));
gotoxy (40, 8);
draw_char(0x7000 | (' '));
gotoxy (41, 8);
draw_char(0x7000 | (' '));
gotoxy (42, 8);
draw_char(0x7000 | (' '));
gotoxy (43, 8);
draw_char(0x7000 | (' '));
gotoxy (44, 8);
draw_char(0x7000 | (' '));
gotoxy (33, 9);
draw_char(0x7000 | (' '));
gotoxy (34, 9);
draw_char(0x7000 | (' '));
gotoxy (35, 9);
draw_char(0x7000 | (' '));
gotoxy (36, 9);
draw_char(0x7000 | (' '));
gotoxy (37, 9);
draw_char(0x7000 | (' '));
gotoxy (38, 9);
draw_char(0x7000 | (' '));
gotoxy (39, 9);
draw_char(0x7000 | (' '));
gotoxy (40, 9);
draw_char(0x7000 | (' '));
gotoxy (41, 9);
draw_char(0x7000 | (' '));
gotoxy (42, 9);
draw_char(0x7000 | (' '));
gotoxy (43, 9);
draw_char(0x7000 | (' '));
gotoxy (44, 9);
draw_char(0x7000 | (' '));
gotoxy (45, 9);
draw_char(0x7000 | (' '));
gotoxy (33, 10);
draw_char(0x7000 | (' '));
gotoxy (34, 10);
draw_char(0x7000 | (' '));
gotoxy (35, 10);
draw_char(0x7000 | (' '));
gotoxy (36, 10);
draw_char(0x7000 | (' '));
gotoxy (37, 10);
draw_char(0x7000 | (' '));
gotoxy (38, 10);
draw_char(0x7000 | (' '));
gotoxy (39, 10);
draw_char(0x7000 | (' '));
gotoxy (40, 10);
draw_char(0x7000 | (' '));
gotoxy (41, 10);
draw_char(0x7000 | (' '));
gotoxy (42, 10);
draw_char(0x7000 | (' '));
gotoxy (43, 10);
draw_char(0x7000 | (' '));
gotoxy (44, 10);
draw_char(0x7000 | (' '));
gotoxy (45, 10);
draw_char(0x7000 | (' '));
gotoxy (32, 11);
draw_char(0x7000 | (' '));
gotoxy (33, 11);
draw_char(0x7000 | (' '));
gotoxy (34, 11);
draw_char(0x7000 | (' '));
gotoxy (35, 11);
draw_char(0x0000 | (' '));
gotoxy (36, 11);
draw_char(0x0000 | (' '));
gotoxy (37, 11);
draw_char(0x7000 | (' '));
gotoxy (38, 11);
draw_char(0x7000 | (' '));
gotoxy (39, 11);
draw_char(0x0000 | (' '));
gotoxy (40, 11);
draw_char(0x0000 | (' '));
gotoxy (41, 11);
draw_char(0x7000 | (' '));
gotoxy (42, 11);
draw_char(0x7000 | (' '));
gotoxy (43, 11);
draw_char(0x7000 | (' '));
gotoxy (44, 11);
draw_char(0x7000 | (' '));
gotoxy (45, 11);
draw_char(0x7000 | (' '));
gotoxy (46, 11);
draw_char(0x7000 | (' '));
gotoxy (32, 12);
draw_char(0x7000 | (' '));
gotoxy (33, 12);
draw_char(0x7000 | (' '));
gotoxy (34, 12);
draw_char(0x0000 | (' '));
gotoxy (35, 12);
draw_char(0x0000 | (' '));
gotoxy (36, 12);
draw_char(0x0000 | (' '));
gotoxy (37, 12);
draw_char(0x7000 | (' '));
gotoxy (38, 12);
draw_char(0x7000 | (' '));
gotoxy (39, 12);
draw_char(0x0000 | (' '));
gotoxy (40, 12);
draw_char(0x0000 | (' '));
gotoxy (41, 12);
draw_char(0x0000 | (' '));
gotoxy (42, 12);
draw_char(0x7000 | (' '));
gotoxy (43, 12);
draw_char(0x7000 | (' '));
gotoxy (44, 12);
draw_char(0x7000 | (' '));
gotoxy (45, 12);
draw_char(0x7000 | (' '));
gotoxy (46, 12);
draw_char(0x7000 | (' '));
gotoxy (32, 13);
draw_char(0x7000 | (' '));
gotoxy (33, 13);
draw_char(0x7000 | (' '));
gotoxy (34, 13);
draw_char(0x0000 | (' '));
gotoxy (35, 13);
draw_char(0x0000 | (' '));
gotoxy (36, 13);
draw_char(0x0000 | (' '));
gotoxy (37, 13);
draw_char(0x7000 | (' '));
gotoxy (38, 13);
draw_char(0x7000 | (' '));
gotoxy (39, 13);
draw_char(0x0000 | (' '));
gotoxy (40, 13);
draw_char(0x0000 | (' '));
gotoxy (41, 13);
draw_char(0x0000 | (' '));
gotoxy (42, 13);
draw_char(0x7000 | (' '));
gotoxy (43, 13);
draw_char(0x7000 | (' '));
gotoxy (44, 13);
draw_char(0x7000 | (' '));
gotoxy (45, 13);
draw_char(0x7000 | (' '));
gotoxy (46, 13);
draw_char(0x7000 | (' '));
gotoxy (32, 14);
draw_char(0x7000 | (' '));
gotoxy (33, 14);
draw_char(0x7000 | (' '));
gotoxy (34, 14);
draw_char(0x0000 | (' '));
gotoxy (35, 14);
draw_char(0x0000 | (' '));
gotoxy (36, 14);
draw_char(0x7000 | (' '));
gotoxy (37, 14);
draw_char(0x7000 | (' '));
gotoxy (38, 14);
draw_char(0x7000 | (' '));
gotoxy (39, 14);
draw_char(0x7000 | (' '));
gotoxy (40, 14);
draw_char(0x0000 | (' '));
gotoxy (41, 14);
draw_char(0x0000 | (' '));
gotoxy (42, 14);
draw_char(0x7000 | (' '));
gotoxy (43, 14);
draw_char(0x7000 | (' '));
gotoxy (44, 14);
draw_char(0x7000 | (' '));
gotoxy (45, 14);
draw_char(0x7000 | (' '));
gotoxy (46, 14);
draw_char(0x7000 | (' '));
gotoxy (32, 15);
draw_char(0x7000 | (' '));
gotoxy (33, 15);
draw_char(0x7000 | (' '));
gotoxy (34, 15);
draw_char(0x7000 | (' '));
gotoxy (35, 15);
draw_char(0x7000 | (' '));
gotoxy (36, 15);
draw_char(0x7000 | (' '));
gotoxy (37, 15);
draw_char(0x7000 | (' '));
gotoxy (38, 15);
draw_char(0x7000 | (' '));
gotoxy (39, 15);
draw_char(0x7000 | (' '));
gotoxy (40, 15);
draw_char(0x7000 | (' '));
gotoxy (41, 15);
draw_char(0x7000 | (' '));
gotoxy (42, 15);
draw_char(0x7000 | (' '));
gotoxy (43, 15);
draw_char(0x7000 | (' '));
gotoxy (44, 15);
draw_char(0x7000 | (' '));
gotoxy (45, 15);
draw_char(0x7000 | (' '));
gotoxy (46, 15);
draw_char(0x7000 | (' '));
gotoxy (32, 16);
draw_char(0x7000 | (' '));
gotoxy (33, 16);
draw_char(0x7000 | (' '));
gotoxy (34, 16);
draw_char(0x7000 | (' '));
gotoxy (35, 16);
draw_char(0x7000 | (' '));
gotoxy (36, 16);
draw_char(0x7000 | (' '));
gotoxy (37, 16);
draw_char(0x0000 | (' '));
gotoxy (38, 16);
draw_char(0x0000 | (' '));
gotoxy (39, 16);
draw_char(0x7000 | (' '));
gotoxy (40, 16);
draw_char(0x7000 | (' '));
gotoxy (41, 16);
draw_char(0x7000 | (' '));
gotoxy (42, 16);
draw_char(0x7000 | (' '));
gotoxy (43, 16);
draw_char(0x7000 | (' '));
gotoxy (44, 16);
draw_char(0x7000 | (' '));
gotoxy (45, 16);
draw_char(0x7000 | (' '));
gotoxy (46, 16);
draw_char(0x7000 | (' '));
gotoxy (31, 17);
draw_char(0x7000 | (' '));
gotoxy (32, 17);
draw_char(0x7000 | (' '));
gotoxy (33, 17);
draw_char(0x7000 | (' '));
gotoxy (34, 17);
draw_char(0x7000 | (' '));
gotoxy (35, 17);
draw_char(0x7000 | (' '));
gotoxy (36, 17);
draw_char(0x7000 | (' '));
gotoxy (37, 17);
draw_char(0x0000 | (' '));
gotoxy (38, 17);
draw_char(0x0000 | (' '));
gotoxy (39, 17);
draw_char(0x7000 | (' '));
gotoxy (40, 17);
draw_char(0x7000 | (' '));
gotoxy (41, 17);
draw_char(0x7000 | (' '));
gotoxy (42, 17);
draw_char(0x7000 | (' '));
gotoxy (43, 17);
draw_char(0x7000 | (' '));
gotoxy (44, 17);
draw_char(0x7000 | (' '));
gotoxy (45, 17);
draw_char(0x7000 | (' '));
gotoxy (46, 17);
draw_char(0x7000 | (' '));
gotoxy (31, 18);
draw_char(0x7000 | (' '));
gotoxy (32, 18);
draw_char(0x7000 | (' '));
gotoxy (33, 18);
draw_char(0x7000 | (' '));
gotoxy (34, 18);
draw_char(0x7000 | (' '));
gotoxy (35, 18);
draw_char(0x7000 | (' '));
gotoxy (36, 18);
draw_char(0x7000 | (' '));
gotoxy (37, 18);
draw_char(0x7000 | (' '));
gotoxy (38, 18);
draw_char(0x7000 | (' '));
gotoxy (39, 18);
draw_char(0x7000 | (' '));
gotoxy (40, 18);
draw_char(0x7000 | (' '));
gotoxy (41, 18);
draw_char(0x7000 | (' '));
gotoxy (42, 18);
draw_char(0x7000 | (' '));
gotoxy (43, 18);
draw_char(0x7000 | (' '));
gotoxy (44, 18);
draw_char(0x7000 | (' '));
gotoxy (45, 18);
draw_char(0x7000 | (' '));
gotoxy (46, 18);
draw_char(0x7000 | (' '));
gotoxy (47, 18);
draw_char(0x7000 | (' '));
gotoxy (35, 19);
draw_char(0x7000 | (' '));
gotoxy (36, 19);
draw_char(0x7000 | (' '));
gotoxy (37, 19);
draw_char(0x7000 | (' '));
gotoxy (38, 19);
draw_char(0x7000 | (' '));
gotoxy (39, 19);
draw_char(0x7000 | (' '));
gotoxy (40, 19);
draw_char(0x7000 | (' '));
gotoxy (41, 19);
draw_char(0x7000 | (' '));
gotoxy (42, 19);
draw_char(0x7000 | (' '));
gotoxy (43, 19);
draw_char(0x7000 | (' '));
gotoxy (44, 19);
draw_char(0x7000 | (' '));
gotoxy (45, 19);
draw_char(0x7000 | (' '));
gotoxy (46, 19);
draw_char(0x7000 | (' '));
gotoxy (47, 19);
draw_char(0x7000 | (' '));
gotoxy (48, 19);
draw_char(0x7000 | (' '));
gotoxy (37, 20);
draw_char(0x7000 | (' '));
gotoxy (38, 20);
draw_char(0x7000 | (' '));
gotoxy (39, 20);
draw_char(0x7000 | (' '));
gotoxy (40, 20);
draw_char(0x7000 | (' '));
gotoxy (41, 20);
draw_char(0x7000 | (' '));
gotoxy (42, 20);
draw_char(0x7000 | (' '));
gotoxy (43, 20);
draw_char(0x7000 | (' '));
gotoxy (44, 20);
draw_char(0x7000 | (' '));
gotoxy (45, 20);
draw_char(0x7000 | (' '));
gotoxy (46, 20);
draw_char(0x7000 | (' '));
gotoxy (47, 20);
draw_char(0x7000 | (' '));
gotoxy (40, 21);
draw_char(0x7000 | (' '));
gotoxy (41, 21);
draw_char(0x7000 | (' '));
gotoxy (42, 21);
draw_char(0x7000 | (' '));
gotoxy (43, 21);
draw_char(0x7000 | (' '));
gotoxy (44, 21);
draw_char(0x7000 | (' '));
gotoxy (45, 21);
draw_char(0x7000 | (' '));
gotoxy (46, 21);
draw_char(0x7000 | (' '));

 
}