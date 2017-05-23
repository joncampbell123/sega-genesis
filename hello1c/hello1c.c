
#include <genesis-68k-mmio.h>
#include <genesis-68k-registers.h>
#include <util.h>

/* VDP register initialization (24 bytes) */
const unsigned char VDPInitData[] = {
	0x04,		/* reg  0 = mode register 1: no H interrupt */
	0x14,		/* reg  1 = mode register 2: blanked, no V interrupt, DMA enable */
	0x30,		/* reg  2 = name table base for scroll A: $C000 */
	0x3C,		/* reg  3 = name table base for window:   $F000 */
	0x07,		/* reg  4 = name table base for scroll B: $E000 */
	0x6C,		/* reg  5 = sprite attribute table base: $D800 */
	0x00,		/* reg  6 = unused register: $00 */
	0x00,		/* reg  7 = background color: $00 */
	0x00,		/* reg  8 = unused register: $00 */
	0x00,		/* reg  9 = unused register: $00 */
	0xFF,		/* reg 10 = H interrupt register: $FF (esentially off) */
	0x00,		/* reg 11 = mode register 3: disable ext int, full H/V scroll */
	0x81,		/* reg 12 = mode register 4: 40 cell horizontal mode, no interlace */
	0x37,		/* reg 13 = H scroll table base: $FC00 */
	0x00,		/* reg 14 = unused register: $00 */
	0x01,		/* reg 15 = auto increment: $01 */
	0x01,		/* reg 16 = scroll size: V=32 cell, H=64 cell */
	0x00,		/* reg 17 = window H position: $00 */
	0x00,		/* reg 18 = window V position: $00 */
	0xFF,		/* reg 19 = DMA length count low:   $00FF */
	0xFF,		/* reg 20 = DMA length count high:  $FFxx */
	0x00,		/* reg 21 = DMA source address low: $xxxx00 */
	0x00,		/* reg 22 = DMA source address mid: $xx00xx */
	0x80		/* reg 23 = DMA source address high: VRAM fill, addr = $00xxxx */
};

/* pattern table initialization */
const unsigned long Font[] = {
	0x01111100,0x11000110,0x11000110,0x11000110, /* A */
	0x11111110,0x11000110,0x11000110,0x00000000,
	0x11111100,0x11000110,0x11000110,0x11111100, /* B */
	0x11000110,0x11000110,0x11111100,0x00000000,
	0x11111110,0x11000110,0x11000110,0x11000000, /* C */
	0x11000110,0x11000110,0x11111110,0x00000000,
	0x11111100,0x11000110,0x11000110,0x11000110, /* D */
	0x11000110,0x11000110,0x11111100,0x00000000,
	0x11111110,0x11000000,0x11000000,0x11111100, /* E */
	0x11000000,0x11000000,0x11111110,0x00000000,
	0x11111110,0x11000000,0x11000000,0x11111100, /* F */
	0x11000000,0x11000000,0x11000000,0x00000000,
	0x11111110,0x11000110,0x11000000,0x11001110, /* G */
	0x11000110,0x11000110,0x11111110,0x00000000,
	0x11000110,0x11000110,0x11000110,0x11111110, /* H */
	0x11000110,0x11000110,0x11000110,0x00000000,
	0x00111000,0x00111000,0x00111000,0x00111000, /* I */
	0x00111000,0x00111000,0x00111000,0x00000000,
	0x00000110,0x00000110,0x00000110,0x00000110, /* J */
	0x00000110,0x01100110,0x01111110,0x00000000,
	0x11000110,0x11001100,0x11111000,0x11111000, /* K */
	0x11001100,0x11000110,0x11000110,0x00000000,
	0x01100000,0x01100000,0x01100000,0x01100000, /* L */
	0x01100000,0x01100000,0x01111110,0x00000000,
	0x11000110,0x11101110,0x11111110,0x11010110, /* M */
	0x11000110,0x11000110,0x11000110,0x00000000,
	0x11000110,0x11100110,0x11110110,0x11011110, /* N */
	0x11001110,0x11000110,0x11000110,0x00000000,
	0x11111110,0x11000110,0x11000110,0x11000110, /* O */
	0x11000110,0x11000110,0x11111110,0x00000000,
	0x11111110,0x11000110,0x11000110,0x11111110, /* P */
	0x11000000,0x11000000,0x11000000,0x00000000,
	0x11111110,0x11000110,0x11000110,0x11000110, /* Q */
	0x11001110,0x11001110,0x11111110,0x00000000,
	0x11111110,0x11000110,0x11000110,0x11111100, /* R */
	0x11000110,0x11000110,0x11000110,0x00000000,
	0x11111110,0x11000110,0x11000000,0x11111110, /* S */
	0x00000110,0x11000110,0x11111110,0x00000000,
	0x11111110,0x00111000,0x00111000,0x00111000, /* T */
	0x00111000,0x00111000,0x00111000,0x00000000,
	0x11000110,0x11000110,0x11000110,0x11000110, /* U */
	0x11000110,0x11000110,0x11111110,0x00000000,
	0x11000110,0x11000110,0x11000110,0x11000110, /* V */
	0x01101100,0x00111000,0x00010000,0x00000000,
	0x11000110,0x11000110,0x11000110,0x11010110, /* W */
	0x11111110,0x11101110,0x11000110,0x00000000,
	0x11000110,0x11000110,0x11101110,0x01111100, /* X */
	0x11101110,0x11000110,0x11000110,0x00000000,
	0x11000110,0x11000110,0x11000110,0x01101100, /* Y */
	0x00111000,0x00111000,0x00111000,0x00000000,
	0x11111110,0x00001110,0x00011100,0x00111000, /* Z */
	0x01110000,0x11100000,0x11111110,0x00000000,
	0x00000000,0x00000000,0x00000000,0x00000000, /* 7B = . */
	0x00000000,0x01100000,0x01100000,0x00000000,
	0x02222200,0x22000220,0x22000000,0x02222200, /* 7C = S */
	0x00000220,0x22000220,0x02222200,0x00000000,
	0x02222220,0x22000000,0x22000000,0x22222200, /* 7D = E */
	0x22000000,0x22000000,0x02222220,0x00000000,
	0x02222200,0x22000220,0x22000000,0x22002220, /* 7E = G */
	0x22000220,0x22000220,0x02222220,0x00000000,
	0x00022000,0x00222200,0x00222200,0x02200220, /* 7F = A */
	0x02200220,0x22000022,0x22022222,0x00000000
};

/* color palette */
const unsigned short CRAM_tab[] = {
	0xEEE,		/* white */
	0xEE8		/* light cyan */
};

/* NTS: The font we took from the asm has no uppercase letters */
const char HelloMsg[] = "hello \x7C\x7D\x7E\x7F world \x7B\ni am written in c";

/* External interrupt */
void __attribute__ ((interrupt)) ExtInt() {
}

/* horizontal retrace interrupt */
void __attribute__ ((interrupt)) HSync() {
}

/* vertical retrace interrupt */
void __attribute__ ((interrupt)) VSync() {
}

/* general non-specific interrupt or exception */
void __attribute__ ((interrupt)) RTE() {
}

void setup_cram() {
	register unsigned int x;

	SEGAWRITE_LONG(VDP_ctrl) = 0xC0020000; /* CRAM write address = 2 */
	for (x=0;x < ARRAYSIZE(CRAM_tab);x++)
		SEGAWRITE_WORD(VDP_data) = CRAM_tab[x];
}

void write_hello_msg() {
	unsigned int vdpa = 0x45940003; /* middle of screen 0xC594 ?? */
	const char *s = HelloMsg;

	SEGAWRITE_LONG(VDP_ctrl) = vdpa;
	while (*s) {
		if (*s == '\n') {
			vdpa += 0x01000000; /* down one row */
			SEGAWRITE_LONG(VDP_ctrl) = vdpa;
			s++;
		}
		else {
			SEGAWRITE_WORD(VDP_data) = *s++;
		}
	}
}

static inline void unblank_display() {
	SEGAWRITE_WORD(VDP_ctrl) = 0x8144; /* C00004 reg 1 = 0x44 unblank display */
}

static inline void blank_display() {
	SEGAWRITE_WORD(VDP_ctrl) = 0x8104; /* C00004 reg 1 = 0x04 blank display */
}

void load_font() {
	register unsigned int x;

	SEGAWRITE_LONG(VDP_ctrl) = 0x4C200000; /* VRAM write to 0x0C20 */
	for (x=0;x < ARRAYSIZE(Font);x++) SEGAWRITE_LONG(VDP_data) = Font[x];
}

static inline void init_psg() {
	static const unsigned char psg_init_cmds[] = {0x9F,0xBF,0xDF,0xFF};
	register unsigned int x;

	for (x=0;x < ARRAYSIZE(psg_init_cmds);x++)
		SEGAWRITE_BYTE(PSG) = psg_init_cmds[x];
}

static inline void init_vsram() {
	register unsigned int x;

	SEGAWRITE_LONG(VDP_ctrl) = 0x40000010; /* C00004 VSRAM write address $0000 */
	for (x=0;x < 20;x++) SEGAWRITE_LONG(VDP_data) = 0; /* clear VSRAM register */
}

static inline void init_cram() {
	register unsigned int x;

	SEGAWRITE_LONG(VDP_ctrl) = 0x81048F02; /* C00004 reg 1 = 0x04, reg 15 = 0x02: blank, auto-increment=2 */
	SEGAWRITE_LONG(VDP_ctrl) = 0xC0000000; /* C00004 write CRAM address $0000 */
	for (x=0;x < 32;x++) SEGAWRITE_LONG(VDP_data) = 0; /* clear CRAM register */
}

static inline void init_vdp() {
	register unsigned int x;
	register unsigned long vdp;

	vdp = 0x00008000; /* VDP register 0 */
	for (x=0;x < ARRAYSIZE(VDPInitData);x++) {
		SEGAWRITE_WORD(VDP_ctrl) = vdp | (unsigned int)VDPInitData[x];
		vdp += 0x00000100; /* next register */
	}

	/* DMA is now set up for 65535-byte fill of VRAM, let's do it */
	SEGAWRITE_LONG(VDP_ctrl) = 0x40000080;		/* C00004 = VRAM write to $0000 (what is the 80 bit for?) */
	SEGAWRITE_WORD(VDP_data) = 0x0000;		/* C00000 = write zero to VRAM (starts DMA fill) */

	/* wait for VDP DMA to finish */
	while (SEGAREAD_WORD(VDP_ctrl) & 1);
}

static inline void sega_tmss() {
	if ((SEGAREAD_BYTE(HW_Version) & 0xF) != 0) {
		/* v1 and later require us to write 'SEGA' to the TMSS register */
		SEGAWRITE_LONG(TMSS_reg) = 0x53454741; /* ASCII "SEGA" */
	}
}

/* entry point */
void SegaMain() {
	sega_tmss();
	init_vdp();
	init_cram();
	init_vsram();
	init_psg();

	setup_cram();
	load_font();

	write_hello_msg();
	unblank_display();
	Delay(60); /* 60 x 1/20ths of a sec = 3 seconds */
	blank_display();
}

