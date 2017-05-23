all: libcommon1.a

CFLAGS=-I../include -nostdinc -nostdlib -m68000 -g0 -Os -fomit-frame-pointer

libcommon1.a: delay.o
	/usr/m68k-elf/bin/m68k-elf-ar r $@ $^

delay.o: delay.s
	cpp -I../include -o $^.pp $^
	/usr/m68k-elf/bin/m68k-elf-as -m68000 -o $@ $^.pp

clean:
	rm -f *.bin *.bin.elf *.o *.pp *.a

