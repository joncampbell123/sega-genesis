
/* ROM IMAGE OFFSET: 0x000000 */
.text

#include <genesis-68k-registers.h>

.extern RTE
.extern _start
.extern ExtInt
.extern HSync
.extern VSync

/*-----------------------------------------------------------------------
 *	exception vectors
 *-----------------------------------------------------------------------*/
.global INTVECTORS
INTVECTORS:
	.long	0xFFFFFE00		/* startup SP */
	.long	_start			/* startup PC */

	.long	RTE,RTE,RTE,RTE		/* bus,addr,illegal,divzero */
	.long	RTE,RTE,RTE		/* CHK,TRAPV,priv */

	.long	RTE			/* trace */
	.long	RTE			/* line 1010 emulator */
	.long	RTE			/* line 1111 emulator */
	.long	RTE,RTE,RTE,RTE		/* unassigned/uninitialized */
	.long	RTE,RTE,RTE,RTE		/* unassigned */
	.long	RTE,RTE,RTE,RTE		/* unassigned */
	.long	RTE			/* spurious interrupt */
	.long	RTE			/* interrupt level 1 (lowest priority) */
	.long	ExtInt			/* interrupt level 2 = external interrupt */
	.long	RTE			/* interrupt level 3 */
	.long	HSync			/* interrupt level 4 = H-sync interrupt */
	.long	RTE			/* interrupt level 5 */
	.long	VSync			/* interrupt level 6 = V-sync interrupt */
	.long	RTE			/* interrupt level 7 (highest priority) */
	.long	RTE,RTE,RTE,RTE		/* TRAP instruction vectors */
	.long	RTE,RTE,RTE,RTE		/* TRAP instruction vectors */
	.long	RTE,RTE,RTE,RTE		/* TRAP instruction vectors */
	.long	RTE,RTE,RTE,RTE		/* TRAP instruction vectors */
	.long	RTE,RTE,RTE,RTE		/* unassigned */
	.long	RTE,RTE,RTE,RTE		/* unassigned */
	.long	RTE,RTE,RTE,RTE		/* unassigned */
	.long	RTE,RTE,RTE,RTE		/* unassigned */

