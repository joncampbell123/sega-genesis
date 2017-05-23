
/* ROM IMAGE OFFSET: 0x000100 */
.text

#include <genesis-68k-registers.h>

/*-----------------------------------------------------------------------
 *	cartridge info header
 *-----------------------------------------------------------------------*/

.global CARTHEADER
CARTHEADER:
	.ascii	"SEGA GENESIS    "	/* must start with "SEGA" */
	.ascii	"(C)---- "		/* copyright */
 	.ascii	"2006.DEC"		/* date */
	.ascii	"HELLO WORLD                                     " /* cart name */
	.ascii	"HELLO WORLD                                     " /* cart name (alt. language) */
	.ascii	"GM MK-0000 -00"	/* program type / catalog number */
	.word	0x0000			/* ROM checksum */
	.ascii	"J               "	/* hardware used */
	.long	0x00000000		/* start of ROM */
	.long	0x003FFFFF		/* end of ROM */
	.long	0x00FF0000,0x00FFFFFF	/* RAM start/end */
	.ascii	"            "		/* backup RAM info */
	.ascii	"            "		/* modem info */
	.ascii	"                                        " /* comment */
	.ascii	"JUE             "	/* regions allowed */

