
/* ROM offset: 0x00000200 or later */
.text

#include <genesis-68k-registers.h>

.global Delay
Delay:		movel	4(%sp),%d0
0:		movew	#0x95CE,%d1		/* delay a long time (about 1/20 sec?) */
1:		dbra	%d1,1b
		dbra	%d0,0b
		rts

