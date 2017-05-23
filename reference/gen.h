; Sega Genesis/Megadrive I/O addresses

;-----------------------------------------------------------------------
;		68K memory map:
;-----------------------------------------------------------------------
;	000000 - 3FFFFF = ROM cartridge
;	400000 - 7FFFFF = alternate ROM space
;	800000 - 9FFFFF = reserved (used by 32X?)
;	A00000          = Z-80 access
;	A10000          = I/O
;	A11000          = control
;	A12000          = sega CD gate array
;	A13000          = address space for /TIME cartridge pin
;	C00000 - DFFFFF = VDP
;	FF0000 - FFFFFF = work RAM

;-----------------------------------------------------------------------
;		$A000xx = Z80 area
;		NOTE: no I/O ports are mapped in Z80 slave mode
;-----------------------------------------------------------------------

Z_base		EQU	$A00000	; Z80 address window base, add to the values below from 68K
Z_sndRAM	EQU	$0000	; Z80 sound RAM at 0000-1FFF
Z_audio		EQU	$4000	; YM2612 chip at 4000-4003
Z_audio_A0	EQU	$4000	; YM2612 A0
Z_audio_D0	EQU	$4001	; YM2612 D0
Z_audio_A1	EQU	$4002	; YM2612 A1
Z_audio_D1	EQU	$4003	; YM2612 D1
Z_bank		EQU	$6000	; bank select register
Z_VDP		EQU	$7F00	; 7F00/7F04/7F08, but useless in VDP mode 5
Z_PSG		EQU	$7F11	; 76489 PSG sound chip
Z_68K		EQU	$8000	; 8000-FFFF = window to 68000 memory bank

;-----------------------------------------------------------------------
;		$A100xx = I/O area (all are byte registers)
;-----------------------------------------------------------------------

HW_version	EQU	$A10001	; hardware version in low nibble
				; bit 6 is PAL (50Hz) if set, NTSC (60Hz) if clear
				; region flags in bits 7 and 6:
				;         USA NTSC = $80
				;         Asia PAL = $C0
				;         Japan NTSC = $00
				;         Europe PAL = $C0
P_data_1	EQU	$A10003	; data (left controller)
P_data_2	EQU	$A10005	; data (right controller)
P_data_3	EQU	$A10007	; data (expansion port)
P_control_1	EQU	$A10009	; control (L)
P_control_2	EQU	$A1000B	; control (R)
P_control_3	EQU	$A1000D	; control (exp)
P_TxData_1	EQU	$A1000F	; TxData (L)
P_RxData_1	EQU	$A10011	; RxData (L)
P_SCtrl_1	EQU	$A10013	; S-Ctrl (L)
P_TxData_2	EQU	$A10015	; TxData (R)
P_RxData_2	EQU	$A10017	; RxData (R)
P_SCtrl_2	EQU	$A10019	; S-Ctrl (R)
P_TxData_3	EQU	$A1001B	; TxData (exp)
P_RxData_3	EQU	$A1001D	; RxData (exp)
P_SCtrl_3	EQU	$A1001F	; S-Ctrl (exp)

;-----------------------------------------------------------------------
;		$A110xx = Control area
;-----------------------------------------------------------------------

;		EQU	$A11000	; memory mode (enables DRAM mode)
Z_busreq	EQU	$A11100	; Z80 busreq (R/W)
Z_reset		EQU	$A11200	; Z80 reset
TMSS_reg	EQU	$A14000	; (long) must store 'SEGA' if not version 0 hardware
;		EQU	$A14101	; cartridge control register (byte) - used by boot ROM only
				; bit 0 = 0 disables cartridge ROM, = 1 enables cartridge ROM

;-----------------------------------------------------------------------
;		$C000xx = VDP area
;-----------------------------------------------------------------------

VDP_data	EQU	$C00000	; VDP data, R/W word or longword access only
VDP_ctrl	EQU	$C00004	; VDP control, word or longword writes only
VDP_stat	EQU	$C00004 ; VDP status
;  0xxx000x = VRAM  read (video RAM)
;  0xxx001x = VSRAM read (vertical scroll RAM)
;  0xxx002x = CRAM  read (color RAM)
;  4xxx000x = VRAM  write
;  4xxx001x = VSRAM write
;  8xyy     = register write
;  8xyy8xyy = double register write (high word first)
;  Cxxx     = CRAM write (this form may not work)
;  Cxxx000x = CRAM write with A14, A15
VDP_HVctr	EQU	$C00008	; VDP HV counter (even/high is Vert, odd/low is Horiz)
PSG		EQU	$C00011	; 76489 PSG sound chip, byte access only
