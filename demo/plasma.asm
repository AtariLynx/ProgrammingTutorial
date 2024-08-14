; Code ported from rasta128 demo by Bastian Schick
; See original source code: https://github.com/42Bastian/lynx_hacking/tree/master/128b/rasta128 

.include "lynx.inc"
.segment "ZEROPAGE" : zeropage

screen:		.res    2
rx:         .res    1
ry:         .res    1
temp:       .res    2
pal_off:    .res    1
ptr:        .res    2

.segment "CODE"
.org $0200

start:
    lda	#ACCUMULATE	; == $40
	sta	SPRSYS
	lsr
	sta	screen+1

	jsr	gen_pal

	lda	#166		; 64 lines more for scrolling
	sta	ry
ly:
	lda	#160
	sta	rx
lx:
	stz	MATHM

	lda	rx
	tax
	jsr	mulAX

	lda	ry
	tax
	jsr	mulAX

	lda	rx
	ldx	ry
	jsr	mulAX

	lda	rx
	sbc	#80
	jsr	get_sin
	tax
	lda	ry
	sbc	#51
	jsr	get_cos
	jsr	mulAX

	ldx	MATHM

    lda	rx
	lsr
	txa
	bcc	@11
	asl
	asl
	and	#$f0
	sta	temp
	bra	@12
@11:
	lsr
	lsr
	and	#$f
	ora	temp
	sta	(screen)

	inc	screen
	bne	@12
	inc	screen+1
@12:
	dec	rx
	bne	lx
	dec	ry
	bne	ly

endless:
	stz	screen
	lda	#$20
	sta	screen+1

loop:
	jsr	waitVBL

	lda	screen
	sta	DISPADRL
	lda	screen+1
	sta	DISPADRH

	clc			; "hardware" scrolling :-)
	lda	screen
	adc	#80
	sta	screen
	bcc	@3
	inc	screen+1
@3:
	inc	pal_off
	jsr waitVBL
	jsr	gen_pal

	lda	screen+1
	cmp	#$34		; 64 lines scrolled?
	bne	loop
	bra	endless

mulAX:
	sta	MATHD		; A = C * E
	stx	MATHB		; AKKU = AKKU + A
	stz	MATHA
;//->.waitm1
;//->	lda	SPRSYS
;//->	bmi	.waitm1
	rts

waitVBL:
@1:
	lda	$fd0a
	bne	@1
@2:
	lda	$fd0a
	beq	@2
	rts

gen_pal:
	ldx	#15
@1:
	txa
	clc
	adc	pal_off
	jsr	get_sin
	sta	$fda0,x
	txa
	adc	pal_off
	asl
	jsr	get_sin
	sta	temp
	txa
	jsr	get_cos
	asl
	asl
	asl
	asl
	ora	temp
	sta	$fdb0,x
	dex
	bpl @1
    rts
;;->	rts		; falling thru does not "hurt"

get_cos:
	clc
	adc	#8
get_sin:
	and	#$1f
	lsr
	tay
	lda	sin,y
	bcs	@99
	lsr
	lsr
	lsr
	lsr
@99:
	and	#$f
	clc
	rts

sin:	
    .byte $89,$ab,$cd,$ee
	.byte $fe,$ed,$cb,$a9
	.byte $76,$54,$32,$11
	.byte $11,$12,$34,$56
