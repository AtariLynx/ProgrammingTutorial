;.setcpu "65C02"
.segment "CODE"
.include "lynx.inc"
.org $0200

start:
    ldy	RCART0
    ldx	#$ff
    txs
read2nd:
    inx
    lda	RCART0
    sta   $100,x
	dey
	bne	read2nd

	jmp	$100
end:

size = end-start
    .res 51-size, $00