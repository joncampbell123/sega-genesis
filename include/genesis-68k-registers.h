
/*-----------------------------------------------------------------------
 *		$A110xx = Control area
 *-----------------------------------------------------------------------*/

#define HW_Version			0xA10001
/* hardware version in low nibble
   bit 6 is PAL (50Hz) if set, NTSC (60Hz) if clear
   region flags in bits 7 and 6:
         USA NTSC = $80
         Asia PAL = $C0
         Japan NTSC = $00
         Europe PAL = $C0 */

/*-----------------------------------------------------------------------
 *		$A110xx = Control area
 *-----------------------------------------------------------------------*/

#define TMSS_reg			0xA14000
/* (long) must store 'SEGA' if not version 0 hardware */

/*-----------------------------------------------------------------------
 *		$C000xx = VDP area
 *-----------------------------------------------------------------------*/

#define VDP_data			0xC00000
/* VDP data, R/W word or longword access only */

#define VDP_ctrl			0xC00004
/* VDP control, word or longword writes only */

#define VDP_stat			0xC00004
/* VDP status
   0xxx000x = VRAM  read (video RAM)
   0xxx001x = VSRAM read (vertical scroll RAM)
   0xxx002x = CRAM  read (color RAM)
   4xxx000x = VRAM  write
   4xxx001x = VSRAM write
   8xyy     = register write
   8xyy8xyy = double register write (high word first)
   Cxxx     = CRAM write (this form may not work)
   Cxxx000x = CRAM write with A14, A15 */

#define VDP_HVctr			0xC00008
/* VDP HV counter (even/high is Vert, odd/low is Horiz) */

#define PSG				0xC00011
/* 76489 PSG sound chip, byte access only */

