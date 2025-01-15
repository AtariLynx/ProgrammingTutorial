lgss.asm

;EOF_USER	.EQU	1
;EOL_USER	.EQU	1
;AUTO_TIMEOUT_USER .EQU 1
;BRK_USER .EQU 1
;FRAMECOUNT_DOWN	.EQU	1

HOFFSET_PRESET	.EQU	14  ; TODO: Must be hex 14 (or is the equ decimal?)
VOFFSET_PRESET	.EQU	14  ; TODO

		.LIST	OFF

;		.IN	6502:include/monitor.i
		.IN	6502:include/harddefs.i
		.IN	6502:include/sprite.i
    .IN	6502:include/hprint.i

		;------	Include the system's zpage data declarations 
		;------	after the include file inclusions and 
		;------	before any code or data declarations
		.IN	6502:macros/zpage.mac
		.IN	6502:src/syszpage.src ; declares sysptr, 2 and 3. Must be at $E0-$E5

		.IN	6502:macros/sys.mac
		.IN	6502:macros/sprite.mac
    .IN	6502:macros/handymath.mac
		.IN	6502:macros/display.mac
		.IN	6502:macros/hprint.mac

		.LIST	ON

		BEGIN_ZPAGE
; Zero page data goes here
; From hprint.src included as VPAGE are TextPtr ($F9-$FA), TextWidth $FB and TextRemaining $FC
		END_ZPAGE

FONT_TYPE	.EQU HPR_BASIC ; is equal to HPR_DIGIT+HPR_UPPER+HPR_PUNC
FONT_HEIGHT	.EQU 7

TEXT_BUF_WIDTH	.EQU	{20+1}
DIGIT_BUF_WIDTH	.EQU	{4+1}

HPR_CHARSET
; .CS 6502:fonts/cset_0b.src seems to be loaded: verify!

; Absolute address variables

  .OR $D000 ; This is required correct placement

  .ALIGN	4
; Align the PC to the next multiple of 4, which is required by the hardware 
; for the placement of the display buffers
screen0		.DS	DISPLAY_BUFSIZE ; from harddefs.i
	.ALIGN 4
; screen1		.DS DISPLAY_BUFSIZE ; TODO: single buffer version?

InterruptTable	.DS	8*2  ; Located at $EFE0
SerialVector .DS 2 ; TODO: Check is this is jump address for serial 4 interrupt handler ($F72D) 

; TODO: what is from $EFEA to $F1FF (27==39 bytes)? 
.OR $F000 
ReceiveBuffer?
.OR $F100 
OtherBuffer?

.OR $F200
TextBuffer	.DS	{TEXT_BUF_WIDTH*FONT_HEIGHT}+1
.OR $F294 ; to F2B7
DigitBuffer	.DS	{DIGIT_BUF_WIDTH*FONT_HEIGHT}+1

  .OR $F2CD
; TODO Buffer... of 20

	.OR $F2E2 ; TODO: what is from F2B8 to $F2E2 to here?

start	.RUN

INITSYS
INITINT	InterruptTable

CLI
CLD
LDX #$20
TXS

SETDISP_60
INITSUZY

SETDBUF screen0, screen0 ; ? Is this single buffer?

;------	Turn off all collisions
LDA	SPRSYS_RAM
ORA	#NO_COLLIDE
STA	SPRSYS_RAM
STA	SPRSYS

RGB16	Palette

LDA	#HOFFSET_PRESET
HOFF8
LDA	#VOFFSET_PRESET
VOFF8

INITLIT	TextBuffer,TEXT_BUF_WIDTH
INITLIT	DigitBuffer,DIGIT_BUF_WIDTH

LDA #$2D
STA $EFE8  ; SerialVector?
LDA #$F7
STA $EFE9  ; SerialVector+1?
LDA #$03	
STA TIM4BKUP	; 31250 baud
LDA #$18		; Enable reload and enable count
STA TIM4CTLA
LDA #$4D		;RXINTEN+RESETERR+TXOPEN+PAREVEN
STA SERCTL

STZ $E6
STZ $E7
LDA #$FE
STA $EE
STZ $F8

;------	Display our buffer
SPRITES	ProgressSprite,0



.OR $F72D ; TODO: Remove when placed correctly
LDX #$05		; TXOPEN+PAREVEN (no interrupts for now)
STX SERCTL
LDA #$10
STA INTRST		; Reset timer interrupt bit for serial
LDA SERCTL
BIT #$40		; RXRDY data available?
BEQ ::1		; No, skip to return
AND #$1C		; PARERR+OVERRUN+FRAMERR 
BEQ ::0		; Check for errors
INC $F8		; Count errors?
::0
LDA SERDAT		; Load serial data
LDX $E6		; Store in circular buffer
INX
STX $E6
STA $F000,X		; Buffer at $F000-F0FF
::1
LDX #$4D		; RXINTEN+RESETERR+TXOPEN+PAREVEN
STX SERCTL
JMP IntReturn		; End IRQ in sys.src


.OR $F757 ; TODO: Remove when placed correctly
		.LIST	OFF
		.IN	6502:src/sysdata.src ; TODO: Should be at $F757
		.IN	6502:src/sys.src
		.IN	6502:src/display.src
		.IN	6502:src/hprint.src

.OR $F844 ; TODO: Remove once placed correctly
		;------	Load the plain font
		HPRFONT plain
		.LIST	ON

; TODO: What is from F99B to F9EC (52 bytes)

; Palette must be at F9ED
.OR $F9ED ; TODO: Remove once placed correctly
Palette
  .BYTE $00,$00,$0F,$00,$0F,$0F,$00,$0F
  .BYTE $07,$07,$00,$07,$00,$07,$00,$07
  .BYTE $00,$0F,$00,$F0,$F0,$0F,$FF,$FF
  .BYTE $7F,$77,$07,$00,$70,$07,$77,$70

.OR $FA0D ; TODO: remove once placed correctly
ProgressSprite

.OR $FA3D ; TODO: remove once placed correctly
SN0Sprite

;;;;;;;;;;

EraseSpriteData
; Handy Sprite Image Data
; Bits per Pixel = 1
; Next data is down-right
		.BYTE	$02,$00
		.BYTE	$00