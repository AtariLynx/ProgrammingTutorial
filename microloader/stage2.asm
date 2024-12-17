.setcpu "65C02"
.include "lynx.inc"

BAUDRATE = 62500
_SDONEACK = SDONEACK-$fd00
_CPUSLEEP = CPUSLEEP-$fd00

.segment "RODATA"
.org $0150

MIKEY_addr: .byte   $10,$11,$8c,_CPUSLEEP,_SDONEACK,$b3,$a0
MIKEY_data: .byte	125000/BAUDRATE-1,%11000,%11101,0,0,$0f,0

_SCBNEXT = SCBNEXTL-$fc00
_SPRGO = SPRGO-$fc00

SUZY_addr: .byte _SPRGO,_SCBNEXT+1,_SCBNEXT,$09,$08,$04,$06,$28,$2a,$83,$92,$90
SUZY_data: .byte 1,>plot_SCB,<plot_SCB,$20,$00,$00,$00,$7f,$7f,$f3,$00

.macro READ_BYTE
.local again
again:
    bit $fd8c
    bvc again
    lda $fd8d
.endmacro

.segment "CODE"
.org $0400

start:
    .byte size
    ldx #.sizeof(SUZY_addr)-1
sloop:
    ldy SUZY_addr,x
    lda SUZY_data,x
    sta	$fc00,y
    dex
    bpl sloop

    ldx #.sizeof(MIKEY_addr)-1
mloop:
    ldy MIKEY_addr,x
    lda MIKEY_data,x
    sta $fd00,y
    dex
    bpl	mloop

    lda	$fcb0
    bne noturbo
    dec $fda0
    lda #%00010000
    sta $FD9C      ; MTEST0: UARTturbo
noturbo:

wait:
	READ_BYTE
	cmp	#$81
	bne	wait
	READ_BYTE
	cmp	#'P'
	bne	wait

.segment "RODATA"

plot_SCB:
next:
	.byte $01					;0
	.byte LITERAL| REHV         ;1
	.byte 0						;2
	.word 0						;3
	.word plot_data				;5
;plot_x 
    .word 80-21					;7
;plot_y	
    .word 51-3					;9
    .word $100					;11
    .word $200					;13
plot_color:						;15
	.byte	3

plot_data:
; "NEW_BLL"
	.incbin "new_bll.spr"

end:

size = end - start