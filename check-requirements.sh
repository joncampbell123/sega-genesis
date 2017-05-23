#!/bin/bash
if [[ !( -x /usr/m68k-elf/bin/m68k-elf-ld ) ]]; then
	echo m68k-elf linker is missing
	exit 1
fi
if [[ !( -x /usr/m68k-elf/bin/m68k-elf-ar ) ]]; then
	echo m68k-elf ar is missing
	exit 1
fi
if [[ !( -x /usr/m68k-elf/bin/m68k-elf-as ) ]]; then
	echo m68k-elf as is missing
	exit 1
fi
if [[ !( -x /usr/m68k-elf/bin/m68k-elf-gcc ) ]]; then
	echo m68k-elf gcc is missing
	exit 1
fi

