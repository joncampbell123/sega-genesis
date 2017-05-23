; hello.asm

		LIST	OFF
		INCLUDE	gen.h
		LIST	ON

;-----------------------------------------------------------------------
;	exception vectors
;-----------------------------------------------------------------------


	DC.L	$FFFFFE00	; startup SP
	DC.L	START		; startup PC

	DS.L	7,RTE		; bus,addr,illegal,divzero,CHK,TRAPV,priv
	DC.L	RTE		; trace
	DC.L	RTE		; line 1010 emulator
	DC.L	RTE		; line 1111 emulator
	DS.L	4,RTE		; unassigned/uninitialized
	DS.L	8,RTE		; unassigned
	DC.L	RTE		; spurious interrupt
	DC.L	RTE		; interrupt level 1 (lowest priority)
	DC.L	ExtInt		; interrupt level 2 = external interrupt
	DC.L	RTE		; interrupt level 3
	DC.L	HSync		; interrupt level 4 = H-sync interrupt
	DC.L	RTE		; interrupt level 5
	DC.L	VSync		; interrupt level 6 = V-sync interrupt
	DC.L	RTE		; interrupt level 7 (highest priority)
	DS.L	16,RTE		; TRAP instruction vectors
	DS.L	16,RTE		; unassigned

;-----------------------------------------------------------------------
;	cartridge info header
;-----------------------------------------------------------------------

	DC.B	"SEGA GENESIS    "	; must start with "SEGA"
	DC.B	"(C)---- "		; copyright
 	DC.B	"2006.DEC"		; date
	DC.B	"HELLO WORLD                                     " ; cart name
	DC.B	"HELLO WORLD                                     " ; cart name (alt. language)
	DC.B	"GM MK-0000 -00"	; program type / catalog number
	DC.W	$0000			; ROM checksum
	DC.B	"J               "	; hardware used
	DC.L	$00000000		; start of ROM
	DC.L	$003FFFFF		; end of ROM
	DC.L	$00FF0000,$00FFFFFF	; RAM start/end
	DC.B	"            "		; backup RAM info
	DC.B	"            "		; modem info
	DC.B	"                                        " ; comment
	DC.B	"JUE             "	; regions allowed

;-----------------------------------------------------------------------
;	generic exception handler
;-----------------------------------------------------------------------

ExtInt
HSync
VSync
RTE	RTE

;-----------------------------------------------------------------------
;	main entry point
;-----------------------------------------------------------------------

START
		LEA	Regs1(PC),A5	; initialize registers
		MOVEM.L	(A5)+,D5-D7/A0-A4

		; initialize TMSS
		MOVE.B	(A1),D0		; A10001 test the hardware version
		ANDI.B	#$0F,D0
		BEQ.B	.1		; branch if no TMSS

		MOVE.L	#'SEGA',(A2)	; A14000 disable TMSS

.1		MOVE.W	(A4),D0		; C00004 read VDP status (interrupt acknowledge?)

		; initialize USP and stuff
		MOVEQ	#0,D0		; D0 = 0
		MOVEA.L	D0,A6		; A6 = 0
		MOVE	A6,USP		; USP = 0

		MOVEQ	#24-1,D1	; length of video initialization block
.2		MOVE.B	(A5)+,D5	; get next video control byte
		MOVE.W	D5,(A4)		; C00004 send write register command to VDP
		ADD.W	D7,D5		; point to next VDP register
		DBRA	D1,.2		; loop for rest of block

		; DMA is now set up for 65535-byte fill of VRAM, let's do it
		MOVE.L	#$40000080,(A4)	; C00004 = VRAM write to $0000 (what is the 80 bit for?)
		MOVE.W	D0,(A3)		; C00000 = write zero to VRAM (starts DMA fill)

.3		MOVE.W	(A4),D4		; C00004 read VDP status
		BTST	#1,D4		; test DMA busy flag
		BNE.B	.3		; loop while DMA busy

		; initialize CRAM
		MOVE.L	#$81048F02,(A4)	; C00004 reg 1 = 0x04, reg 15 = 0x02: blank, auto-increment=2
		MOVE.L	#$C0000000,(A4)	; C00004 write CRAM address $0000
		MOVEQ	#32-1,D3	; loop for 32 CRAM registers
.4		MOVE.L	D0,(A3)		; C00000 clear CRAM register
		DBRA	D3,.4

		; initialize VSRAM
		MOVE.L	#$40000010,(A4)	; C00004 VSRAM write address $0000
		MOVEQ	#20-1,D4	; loop for 20 VSRAM registers
.5		MOVE.L	D0,(A3)		; C00000 clear VSRAM register
		DBRA	D4,.5

		; initialize PSG
		MOVEQ	#4-1,D5		; loop for 4 PSG registers
.6		MOVE.B	(A5)+,$0011(A3)	; C00011 copy PSG initialization commands
		DBRA	D5,.6

		LEA	Regs2(PC),A1	; initialize registers
		MOVEM.L	(A1)+,D4-D7/A2-A6

		BSR.B	InitCRAM	; set up colors in CRAM

		MOVE.L	#$4C200000,(A4)	; C00004 VRAM write to $0C20
.7		MOVE.L	(A1)+,(A5)	; C00000 write next longword of charset to VDP
		DBRA	D6,.7		; loop until done

		LEA	HelloMsg(PC),A1
		BSR.B	PrintMsg	; copy startup message to screen

		MOVE.W	#$8144,(A4)	; C00004 reg 1 = 0x44 unblank display

		MOVE.W	#60,D0
		BSR.B	Delay		; delay about 3 seconds

;		MOVE.W	#$8104,(A4)	; C00004 reg 1 = 0x04 blank display

	BRA.B	*

;-----------------------------------------------------------------------

Delay		MOVE.W	#$95CE,D1	; delay a long time (about 1/20 sec?)
.1		DBRA	D1,.1
		DBRA	D0,Delay
		RTS

;-----------------------------------------------------------------------
; set up colors in CRAM

InitCRAM
		MOVE.W	(A2)+,D0		; get length word
		MOVE.L	#$C0020000,(A4)		; C00004 CRAM write address = $0002
.1		MOVE.W	(A2)+,(A5)		; C00000 write next word to video
		DBRA	D0,.1			; loop until done
		RTS

		; CRAM initialization
CRAM_tab
		DC.W	(CRAM_end-CRAM_tab)/2-2	; number of entries - 1
		DC.W	$0EEE,$0EE8
CRAM_end

;-----------------------------------------------------------------------
; copy startup message to screen

PrintMsg	MOVE.L	D5,(A4)			; C00004 write next character to VDP
.1		MOVEQ	#0,D1			; clear high byte of word
		MOVE.B	(A1)+,D1		; get next byte
		BMI.B	.3			; branch if high bit set
		BNE.B	.2			; store byte if not null
		RTS				; exit if null

.2		MOVE.W	D1,(A5)			; C00000 store next word of name data
		BRA.B	.1

.3		ADDI.L	#$01000000,D5		; offset VRAM address by $0100 to skip a line
		BRA.B	PrintMsg

		; startup message

HelloMsg	DC.B	"hello "
		DC.B	$7C,$7D,$7E,$7F	; "SEGA" logo characters
		DC.B	" world"
		DC.B	$7B		; "."
		DC.B	0

		EVEN

;-----------------------------------------------------------------------

Regs1		DC.L	$00008000	; D5 = VDP register 0 write command
		DC.L	0		; D6 = unused
		DC.L	$00000100	; D7 = video register offset
		DC.L	0		; A0 = unused
		DC.L	HW_Version	; A1 = hardware version register
		DC.L	TMSS_reg	; A2 = TMSS register
		DC.L	VDP_data	; A3 = VDP data
		DC.L	VDP_ctrl	; A4 = VDP control / status
					; A5 = pointer to the following data:

		; VDP register initialization (24 bytes)
		DC.B	$04	; reg  0 = mode register 1: no H interrupt
		DC.B	$14	; reg  1 = mode register 2: blanked, no V interrupt, DMA enable
		DC.B	$30	; reg  2 = name table base for scroll A: $C000
		DC.B	$3C	; reg  3 = name table base for window:   $F000
		DC.B	$07	; reg  4 = name table base for scroll B: $E000
		DC.B	$6C	; reg  5 = sprite attribute table base: $D800
		DC.B	$00	; reg  6 = unused register: $00
		DC.B	$00	; reg  7 = background color: $00
		DC.B	$00	; reg  8 = unused register: $00
		DC.B	$00	; reg  9 = unused register: $00
		DC.B	$FF	; reg 10 = H interrupt register: $FF (esentially off)
		DC.B	$00	; reg 11 = mode register 3: disable ext int, full H/V scroll
		DC.B	$81	; reg 12 = mode register 4: 40 cell horizontal mode, no interlace
		DC.B	$37	; reg 13 = H scroll table base: $FC00
		DC.B	$00	; reg 14 = unused register: $00
		DC.B	$01	; reg 15 = auto increment: $01
		DC.B	$01	; reg 16 = scroll size: V=32 cell, H=64 cell
		DC.B	$00	; reg 17 = window H position: $00
		DC.B	$00	; reg 18 = window V position: $00
		DC.B	$FF	; reg 19 = DMA length count low:   $00FF
		DC.B	$FF	; reg 20 = DMA length count high:  $FFxx
		DC.B	$00	; reg 21 = DMA source address low: $xxxx00
		DC.B	$00	; reg 22 = DMA source address mid: $xx00xx
		DC.B	$80	; reg 23 = DMA source address high: VRAM fill, addr = $00xxxx

		; PSG initialization: set all channels to minimum volume
		DC.B	$9F,$BF,$DF,$FF

;-----------------------------------------------------------------------

Regs2		DC.L	0		; D4 = unused
		DC.L	$45940003	; D5 = VRAM write to middle of screen, addr = $C594
		DC.L	FontSize/4-1	; D6 = size of charset data
		DC.L	0		; D7 = unused
		DC.L	CRAM_tab	; A2 = CRAM table
		DC.L	0		; A3 = unused
		DC.L	VDP_ctrl	; A4 = VDP control / status
		DC.L	VDP_data	; A5 = VDP data
		DC.L	0		; A6 = unused
					; A1 = pointer to the following data:

		; pattern table initialization
Font		HEX	01111100 11000110 11000110 11000110 ; A
		HEX	11111110 11000110 11000110 00000000
		HEX	11111100 11000110 11000110 11111100 ; B
		HEX	11000110 11000110 11111100 00000000
		HEX	11111110 11000110 11000110 11000000 ; C
		HEX	11000110 11000110 11111110 00000000
		HEX	11111100 11000110 11000110 11000110 ; D
		HEX	11000110 11000110 11111100 00000000
		HEX	11111110 11000000 11000000 11111100 ; E
		HEX	11000000 11000000 11111110 00000000
		HEX	11111110 11000000 11000000 11111100 ; F
		HEX	11000000 11000000 11000000 00000000
		HEX	11111110 11000110 11000000 11001110 ; G
		HEX	11000110 11000110 11111110 00000000
		HEX	11000110 11000110 11000110 11111110 ; H
		HEX	11000110 11000110 11000110 00000000
		HEX	00111000 00111000 00111000 00111000 ; I
		HEX	00111000 00111000 00111000 00000000
		HEX	00000110 00000110 00000110 00000110 ; J
		HEX	00000110 01100110 01111110 00000000
		HEX	11000110 11001100 11111000 11111000 ; K
		HEX	11001100 11000110 11000110 00000000
		HEX	01100000 01100000 01100000 01100000 ; L
		HEX	01100000 01100000 01111110 00000000
		HEX	11000110 11101110 11111110 11010110 ; M
		HEX	11000110 11000110 11000110 00000000
		HEX	11000110 11100110 11110110 11011110 ; N
		HEX	11001110 11000110 11000110 00000000
		HEX	11111110 11000110 11000110 11000110 ; O
		HEX	11000110 11000110 11111110 00000000
		HEX	11111110 11000110 11000110 11111110 ; P
		HEX	11000000 11000000 11000000 00000000
		HEX	11111110 11000110 11000110 11000110 ; Q
		HEX	11001110 11001110 11111110 00000000
		HEX	11111110 11000110 11000110 11111100 ; R
		HEX	11000110 11000110 11000110 00000000
		HEX	11111110 11000110 11000000 11111110 ; S
		HEX	00000110 11000110 11111110 00000000
		HEX	11111110 00111000 00111000 00111000 ; T
		HEX	00111000 00111000 00111000 00000000
		HEX	11000110 11000110 11000110 11000110 ; U
		HEX	11000110 11000110 11111110 00000000
		HEX	11000110 11000110 11000110 11000110 ; V
		HEX	01101100 00111000 00010000 00000000
		HEX	11000110 11000110 11000110 11010110 ; W
		HEX	11111110 11101110 11000110 00000000
		HEX	11000110 11000110 11101110 01111100 ; X
		HEX	11101110 11000110 11000110 00000000
		HEX	11000110 11000110 11000110 01101100 ; Y
		HEX	00111000 00111000 00111000 00000000
		HEX	11111110 00001110 00011100 00111000 ; Z
		HEX	01110000 11100000 11111110 00000000
		HEX	00000000 00000000 00000000 00000000 ; 7B = .
		HEX	00000000 01100000 01100000 00000000
		HEX	02222200 22000220 22000000 02222200 ; 7C = S
		HEX	00000220 22000220 02222200 00000000
		HEX	02222220 22000000 22000000 22222200 ; 7D = E
		HEX	22000000 22000000 02222220 00000000
		HEX	02222200 22000220 22000000 22002220 ; 7E = G
		HEX	22000220 22000220 02222220 00000000
		HEX	00022000 00222200 00222200 02200220 ; 7F = A
		HEX	02200220 22000022 22022222 00000000
FontSize = * - Font

		END	0
