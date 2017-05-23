all: hello1.bin

# NTS: interrupt_vectors.o must come first, followed by cartridge_header.o, to ensure
#      they appear in their proper place at the start of the ROM.
hello1.bin: hello1.o interrupt_vectors.o cartridge_header.o 
	/usr/m68k-elf/bin/m68k-elf-ld -T ../sega-genesis-m68k.linker-script -o $@ $^

hello1.o: hello1.s
	cpp -I../include -o $^.pp $^
	/usr/m68k-elf/bin/m68k-elf-as -m68000 -o $@ $^.pp

cartridge_header.o: cartridge_header.s
	cpp -I../include -o $^.pp $^
	/usr/m68k-elf/bin/m68k-elf-as -m68000 -o $@ $^.pp

interrupt_vectors.o: interrupt_vectors.s
	cpp -I../include -o $^.pp $^
	/usr/m68k-elf/bin/m68k-elf-as -m68000 -o $@ $^.pp

clean:
	rm -f *.bin *.bin.elf *.o *.pp

