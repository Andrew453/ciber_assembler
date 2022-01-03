CC = open-watcom.owcc-dos
LD = open-watcom.owcc-dos
AS = nasm
RUN = dosbox

CFLAGS = -mcmodel=t -march=i86 -c -std=c99 -fno-stack-check -fno-omit-frame-pointer -fnostdlib -g0 -mabi=d
LDFLAGS = -mcmodel=t -b com -mabi=d -march=i86 -s
ASFLAGS = -f obj

all: prog.com

video.obj:
	$(CC) $(CFLAGS) -o video.obj video.c

cipher.obj:
	$(CC) $(CFLAGS) -o cipher.obj vernam_cipher.c
prog.obj:
	$(AS) $(ASFLAGS) -o prog.obj prog.asm

prog.raw: prog.obj cipher.obj video.obj
	$(LD) $(LDFLAGS) -o prog.raw prog.obj cipher.obj video.obj

prog.com: prog.raw
	dd bs=256 skip=1 if=prog.raw of=prog.com

clean:
	rm *.obj *.com *.raw

run: prog.com
	dosbox $(PWD)/prog.com
