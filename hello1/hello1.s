/* hello1.asm.
   NOT written by Jonathan Campbell,
   but Jonathan ported it to compile and assemble with GNU binutils + ld */

/* ROM offset: 0x00000200 */
.text

#include <genesis-68k-registers.h>

/* External interrupt */
.global ExtInt
ExtInt:	RTE

/* horizontal retrace interrupt */
.global HSync
HSync:	RTE

/* vertical retrace interrupt */
.global VSync
VSync:	RTE

/* general non-specific interrupt or exception */
.global RTE
RTE:	RTE

/*-----------------------------------------------------------------------
 *      Entry point
 *-----------------------------------------------------------------------*/
.global _start
_start:
		lea	%pc@(Regs1),%a5		/* initialize registers */
		moveml	%a5@+,%d5-%d7/%a0-%a4

		/* initialize TMSS */
		moveb	(%a1),%d0		/* A10001 test the hardware version */
		andib	#0x0F,%d0		/* mask 4 lower bits: is it zero? */
		beqb	no_tmss			/* branch if no TMSS (is zero) */

		movel	#0x53454741,(%a2)	/* A14000 disable TMSS (Writes 'SEGA') */

no_tmss:	movew	(%a4),%d0		/* C00004 read VDP status (interrupt acknowledge?) */

		/* initialize USP and stuff */
		moveq	#0,%d0			/* D0 = 0 */
		moval	%d0,%a6			/* A6 = 0 */
		move	%a6,%usp		/* USP = 0 */

		moveq	#24-1,%d1		/* length of video initialization block */
1:		moveb	(%a5)+,%d5		/* get next video control byte */
		movew	%d5,(%a4)		/* C00004 send write register command to VDP */
		addw	%d7,%d5			/* point to next VDP register */
		dbra	%d1,1b			/* loop for rest of block */

		/* DMA is now set up for 65535-byte fill of VRAM, let's do it */
		movel	#0x40000080,(%a4)	/* C00004 = VRAM write to $0000 (what is the 80 bit for?) */
		movew	%d0,(%a3)		/* C00000 = write zero to VRAM (starts DMA fill) */

3:		movew	(%a4),%d4		/* C00004 read VDP status */
		btst	#1,%d4			/* test DMA busy flag */
		bneb	3b			/* loop while DMA busy */

		/* initialize CRAM */
		movel	#0x81048F02,(%a4)	/* C00004 reg 1 = 0x04, reg 15 = 0x02: blank, auto-increment=2 */
		movel	#0xC0000000,(%a4)	/* C00004 write CRAM address $0000 */
		moveq	#32-1,%d3		/* loop for 32 CRAM registers */
4:		movel	%d0,(%a3)		/* C00000 clear CRAM register */
		dbra	%d3,4b

		/* initialize VSRAM */
		movel	#0x40000010,(%a4)	/* C00004 VSRAM write address $0000 */
		moveq	#20-1,%d4		/* loop for 20 VSRAM registers */
5:		movel	%d0,(%a3)		/* C00000 clear VSRAM register */
		dbra	%d4,5b

		/* initialize PSG */
		moveq	#4-1,%d5		/* loop for 4 PSG registers */
6:		moveb	(%a5)+,0x0011(%a3)	/* C00011 copy PSG initialization commands */
		dbra	%d5,6b

		lea	%pc@(Regs2),%a1		/* initialize registers */
		moveml	%a1@+,%d4-%d7/%a2-%a6

		bsrb	InitCRAM		/* set up colors in CRAM */

		movel	#0x4C200000,(%a4)	/* C00004 VRAM write to $0C20 */
7:		movel	(%a1)+,(%a5)		/* C00000 write next longword of charset to VDP */
		dbra	%d6,7b			/* loop until done */

		lea	%pc@(HelloMsg),%a1
		bsrb	PrintMsg		/* copy startup message to screen */

		movew	#0x8144,(%a4)		/* C00004 reg 1 = 0x44 unblank display */

		movew	#60,%d0
		bsrb	Delay			/* delay about 3 seconds */

		movew	#0x8104,(%a4)		/* C00004 reg 1 = 0x04 blank display */

		brab	.

/*-----------------------------------------------------------------------*/

Delay:		movew	#0x95CE,%d1		/* delay a long time (about 1/20 sec?) */
1:		dbra	%d1,1b
		dbra	%d0,Delay
		rts

/*-----------------------------------------------------------------------*/
/* set up colors in CRAM */

InitCRAM:	movew	(%a2)+,%d0		/* get length word */
		movel	#0xC0020000,(%a4)	/* C00004 CRAM write address = $0002 */
1:		movew	(%a2)+,(%a5)		/* C00000 write next word to video */
		dbra	%d0,1b			/* loop until done */
		rts

/*-----------------------------------------------------------------------*/
/* copy startup message to screen */

PrintMsg:	movel	%d5,(%a4)		/* C00004 write next character to VDP */
1:		moveq	#0,%d1			/* clear high byte of word */
		moveb	(%a1)+,%d1		/* get next byte */
		bmib	3f			/* branch if high bit set */
		bneb	2f			/* store byte if not null */
		rts				/* exit if null */

2:		movew	%d1,(%a5)		/* C00000 store next word of name data */
		brab	1b

3:		addil	#0x01000000,%d5		/* offset VRAM address by $0100 to skip a line */
		brab	PrintMsg

/*-----------------------------------------------------------------------*/

Regs1:		.long	0x00008000	/* D5 = VDP register 0 write command */
		.long	0		/* D6 = unused */
		.long	0x00000100	/* D7 = video register offset */
		.long	0		/* A0 = unused */
		.long	HW_Version	/* A1 = hardware version register */
		.long	TMSS_reg	/* A2 = TMSS register */
		.long	VDP_data	/* A3 = VDP data */
		.long	VDP_ctrl	/* A4 = VDP control / status */
					/* A5 = pointer to the following data: */

		/* VDP register initialization (24 bytes) */
		.byte	0x04		/* reg  0 = mode register 1: no H interrupt */
		.byte	0x14		/* reg  1 = mode register 2: blanked, no V interrupt, DMA enable */
		.byte	0x30		/* reg  2 = name table base for scroll A: $C000 */
		.byte	0x3C		/* reg  3 = name table base for window:   $F000 */
		.byte	0x07		/* reg  4 = name table base for scroll B: $E000 */
		.byte	0x6C		/* reg  5 = sprite attribute table base: $D800 */
		.byte	0x00		/* reg  6 = unused register: $00 */
		.byte	0x00		/* reg  7 = background color: $00 */
		.byte	0x00		/* reg  8 = unused register: $00 */
		.byte	0x00		/* reg  9 = unused register: $00 */
		.byte	0xFF		/* reg 10 = H interrupt register: $FF (esentially off) */
		.byte	0x00		/* reg 11 = mode register 3: disable ext int, full H/V scroll */
		.byte	0x81		/* reg 12 = mode register 4: 40 cell horizontal mode, no interlace */
		.byte	0x37		/* reg 13 = H scroll table base: $FC00 */
		.byte	0x00		/* reg 14 = unused register: $00 */
		.byte	0x01		/* reg 15 = auto increment: $01 */
		.byte	0x01		/* reg 16 = scroll size: V=32 cell, H=64 cell */
		.byte	0x00		/* reg 17 = window H position: $00 */
		.byte	0x00		/* reg 18 = window V position: $00 */
		.byte	0xFF		/* reg 19 = DMA length count low:   $00FF */
		.byte	0xFF		/* reg 20 = DMA length count high:  $FFxx */
		.byte	0x00		/* reg 21 = DMA source address low: $xxxx00 */
		.byte	0x00		/* reg 22 = DMA source address mid: $xx00xx */
		.byte	0x80		/* reg 23 = DMA source address high: VRAM fill, addr = $00xxxx */

Regs2:		.long	0		/* D4 = unused */
		.long	0x45940003	/* D5 = VRAM write to middle of screen, addr = $C594 */
		.long	FontSize/4-1	/* D6 = size of charset data */
		.long	0		/* D7 = unused */
		.long	CRAM_tab	/* A2 = CRAM table */
		.long	0		/* A3 = unused */
		.long	VDP_ctrl	/* A4 = VDP control / status */
		.long	VDP_data	/* A5 = VDP data */
		.long	0		/* A6 = unused */
					/* A1 = pointer to the following data: */

		/* pattern table initialization */
Font:		.long	0x01111100,0x11000110,0x11000110,0x11000110 /* A */
		.long	0x11111110,0x11000110,0x11000110,0x00000000
		.long	0x11111100,0x11000110,0x11000110,0x11111100 /* B */
		.long	0x11000110,0x11000110,0x11111100,0x00000000
		.long	0x11111110,0x11000110,0x11000110,0x11000000 /* C */
		.long	0x11000110,0x11000110,0x11111110,0x00000000
		.long	0x11111100,0x11000110,0x11000110,0x11000110 /* D */
		.long	0x11000110,0x11000110,0x11111100,0x00000000
		.long	0x11111110,0x11000000,0x11000000,0x11111100 /* E */
		.long	0x11000000,0x11000000,0x11111110,0x00000000
		.long	0x11111110,0x11000000,0x11000000,0x11111100 /* F */
		.long	0x11000000,0x11000000,0x11000000,0x00000000
		.long	0x11111110,0x11000110,0x11000000,0x11001110 /* G */
		.long	0x11000110,0x11000110,0x11111110,0x00000000
		.long	0x11000110,0x11000110,0x11000110,0x11111110 /* H */
		.long	0x11000110,0x11000110,0x11000110,0x00000000
		.long	0x00111000,0x00111000,0x00111000,0x00111000 /* I */
		.long	0x00111000,0x00111000,0x00111000,0x00000000
		.long	0x00000110,0x00000110,0x00000110,0x00000110 /* J */
		.long	0x00000110,0x01100110,0x01111110,0x00000000
		.long	0x11000110,0x11001100,0x11111000,0x11111000 /* K */
		.long	0x11001100,0x11000110,0x11000110,0x00000000
		.long	0x01100000,0x01100000,0x01100000,0x01100000 /* L */
		.long	0x01100000,0x01100000,0x01111110,0x00000000
		.long	0x11000110,0x11101110,0x11111110,0x11010110 /* M */
		.long	0x11000110,0x11000110,0x11000110,0x00000000
		.long	0x11000110,0x11100110,0x11110110,0x11011110 /* N */
		.long	0x11001110,0x11000110,0x11000110,0x00000000
		.long	0x11111110,0x11000110,0x11000110,0x11000110 /* O */
		.long	0x11000110,0x11000110,0x11111110,0x00000000
		.long	0x11111110,0x11000110,0x11000110,0x11111110 /* P */
		.long	0x11000000,0x11000000,0x11000000,0x00000000
		.long	0x11111110,0x11000110,0x11000110,0x11000110 /* Q */
		.long	0x11001110,0x11001110,0x11111110,0x00000000
		.long	0x11111110,0x11000110,0x11000110,0x11111100 /* R */
		.long	0x11000110,0x11000110,0x11000110,0x00000000
		.long	0x11111110,0x11000110,0x11000000,0x11111110 /* S */
		.long	0x00000110,0x11000110,0x11111110,0x00000000
		.long	0x11111110,0x00111000,0x00111000,0x00111000 /* T */
		.long	0x00111000,0x00111000,0x00111000,0x00000000
		.long	0x11000110,0x11000110,0x11000110,0x11000110 /* U */
		.long	0x11000110,0x11000110,0x11111110,0x00000000
		.long	0x11000110,0x11000110,0x11000110,0x11000110 /* V */
		.long	0x01101100,0x00111000,0x00010000,0x00000000
		.long	0x11000110,0x11000110,0x11000110,0x11010110 /* W */
		.long	0x11111110,0x11101110,0x11000110,0x00000000
		.long	0x11000110,0x11000110,0x11101110,0x01111100 /* X */
		.long	0x11101110,0x11000110,0x11000110,0x00000000
		.long	0x11000110,0x11000110,0x11000110,0x01101100 /* Y */
		.long	0x00111000,0x00111000,0x00111000,0x00000000
		.long	0x11111110,0x00001110,0x00011100,0x00111000 /* Z */
		.long	0x01110000,0x11100000,0x11111110,0x00000000
		.long	0x00000000,0x00000000,0x00000000,0x00000000 /* 7B = . */
		.long	0x00000000,0x01100000,0x01100000,0x00000000
		.long	0x02222200,0x22000220,0x22000000,0x02222200 /* 7C = S */
		.long	0x00000220,0x22000220,0x02222200,0x00000000
		.long	0x02222220,0x22000000,0x22000000,0x22222200 /* 7D = E */
		.long	0x22000000,0x22000000,0x02222220,0x00000000
		.long	0x02222200,0x22000220,0x22000000,0x22002220 /* 7E = G */
		.long	0x22000220,0x22000220,0x02222220,0x00000000
		.long	0x00022000,0x00222200,0x00222200,0x02200220 /* 7F = A */
		.long	0x02200220,0x22000022,0x22022222,0x00000000
		.equ	FontSize, . - Font

		/* CRAM initialization */
CRAM_tab:	.word	(CRAM_end-CRAM_tab)/2-2	/* number of entries - 1 */
		.word	0x0EEE,0x0EE8
CRAM_end:

HelloMsg:	.ascii	"hello "
		.byte	0x7C,0x7D,0x7E,0x7F	/* "SEGA" logo characters */
		.ascii	" world"
		.byte	0x7B			/* "." */
		.byte	0

