
/* ROM offset: 0x00000200 or later */
.text

#include <genesis-68k-registers.h>

.extern SegaMain
.global _start
_start:
		move	%sp,%usp
		bsrw	SegaMain
		brab	.

