all: hello1.bin

CFLAGS=-I../include -nostdinc -nostdlib -m68000 -g0 -Os -fomit-frame-pointer

# NTS: interrupt_vectors.o must come first, followed by cartridge_header.o, to ensure
#      they appear in their proper place at the start of the ROM.
hello1.bin: entry.o hello1c.o interrupt_vectors.o cartridge_header.o ../common/libcommon1.a
	/usr/m68k-elf/bin/m68k-elf-ld -Map=$@.map -T ../sega-genesis-m68k.linker-script -o $@ $^

../common/libcommon1.a:
	make -C ../common

entry.o: entry.s
	cpp -I../include -o $^.pp $^
	/usr/m68k-elf/bin/m68k-elf-as -m68000 -o $@ $^.pp

hello1c.o: hello1c.c
	/usr/m68k-elf/bin/m68k-elf-gcc $(CFLAGS) -c -o $@ $^

cartridge_header.o: cartridge_header.s
	cpp -I../include -o $^.pp $^
	/usr/m68k-elf/bin/m68k-elf-as -m68000 -o $@ $^.pp

interrupt_vectors.o: interrupt_vectors.s
	cpp -I../include -o $^.pp $^
	/usr/m68k-elf/bin/m68k-elf-as -m68000 -o $@ $^.pp

clean:
	rm -f *.bin *.bin.elf *.o *.pp *.map

