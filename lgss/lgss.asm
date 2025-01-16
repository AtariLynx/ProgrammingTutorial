;EOF_USER	.EQU	1
;EOL_USER	.EQU	1
;AUTO_TIMEOUT_USER .EQU 1
;BRK_USER .EQU 1
;FRAMECOUNT_DOWN	.EQU	1

  .65C02		; Select processor for the HANDY

SERIALPORT_USER .EQU 1

HOFFSET_PRESET	.EQU	20
VOFFSET_PRESET	.EQU	20

  .LIST	OFF

  .IN	6502:include/harddefs.i
  .IN	6502:include/sprite.i
  .IN	6502:include/hprint.i

  ;------	Include the system's zpage data declarations 
  ;------	after the include file inclusions and 
  ;------	before any code or data declarations
  .IN	6502:macros/zpage.mac
NEXTZPG     .=     $E0
  .IN	6502:src/syszpage.src

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

;HPR_CHARSET
; .CS 6502:fonts/cset_0b.src seems to be loaded: verify!

; Absolute address variables

  .OR $D000 ; This is required correct placement

; Align the PC to the next multiple of 4, which is required by the hardware 
; for the placement of the display buffers
  .ALIGN	4
screen0		.DS	DISPLAY_BUFSIZE ; from harddefs.i ($D000-$EFDF)

InterruptTable	.DS	8*2  ; Located at $EFE0-$EFEF
SerialVector .DS 2 ; $EFF0-$EFF1 TODO: Check is this is jump address for serial 4 interrupt handler ($F72D) 

; TODO: what is from $EFF1 to $EFFF? 
What .DS 14

ReceiveBuffer .DS 256
OtherBuffer .DS 256

TextBuffer	.DS	{TEXT_BUF_WIDTH*FONT_HEIGHT}+1 ; F200-F293 (148)
DigitBuffer	.DS	{DIGIT_BUF_WIDTH*FONT_HEIGHT}+1 ; F294-F2B7 (36)
NameBuffer .DS 21 ; F2B8-F2CC
AuthorBuffer .DS 21 ; F2CD-F2E0

;F2E2
start	.RUN

  INITSYS
  INITINT InterruptTable

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
  STA TIMER4+TIM_BACKUP	; 31250 baud
  LDA #ENABLE_RELOAD+ENABLE_COUNT   ; #$18		; Enable reload and enable count
  STA TIMER4+TIM_CONTROLA
  LDA #RXINTEN+RESETERR+TXOPEN+PAREVEN ; #$4D		;RXINTEN+RESETERR+TXOPEN+PAREVEN
  STA SERCTL

  STZ $E6
  STZ $E7
  LDA #$FE
  STA $EE
  STZ $F8  ; TODO: Remove this comment Ends at F3FC-F3FD (next at F3FE)

; 

  .OR $F757 ; TODO: Remove when placed correctly
  ;.LIST	OFF
  
	.IN	6502:src/sysdata.src
  .IN	6502:src/sys.src
  .IN	6502:src/display.src
  .IN	6502:src/hprint.src

  .OR $F844 ; TODO: Remove once placed correctly
  ;------	Load the plain font
  HPRFONT plain
  
	;.LIST	ON

	.OR $F9ED ; TODO: Remove once placed correctly
Palette
  .BYTE $00,$00,$0F,$00,$0F,$0F,$00,$0F
  .BYTE $07,$07,$00,$07,$00,$07,$00,$07
  .BYTE $00,$0F,$00,$F0,$F0,$0F,$FF,$FF
  .BYTE $7F,$77,$07,$00,$70,$07,$77,$70
