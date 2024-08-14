; Code ported from rasta128 demo by Bastian Schick
; See original source code: https://github.com/42Bastian/lynx_hacking/tree/master/128b/rasta128 

.include "lynx.inc"
.segment "ZEROPAGE" : zeropage

pos:        .res    3
barsize:    .res    3
pos_inc:    .res    3
col:        .res    3

.segment "CODE"
.org $0200

start:
    bra	cont
	lda	INTSET		; get pending interrupt
	sta	INTRST		; ack
	dec			    ; 1 => HBL, 8 => VBL
	bne	vbl

    ldx	col
	stx	GCOLMAP		; green foreground
	bne	@xx
	lda	col+1		; blue middle
	beq	@xy
	asl
	asl
	asl
	asl
    .byte  $ae
@xy:
	lda	col+2
@xx:
	sta	RBCOLMAP
	ldx	#2

loop:
	lda	VTIMCNT		; line counter
	cmp	pos,x
	bcs	@next
	lda	barsize,x
	sta	col,x
	dec	barsize,x
	bpl	@next
	stz	col,x
@next:
	dex
	bpl	loop
	rti

vbl:
	ldx	#2
loop_v:
	lda	#15
	sta	barsize,x
	clc
	lda	pos,x
	adc	pos_inc,x
	sta	pos,x
	cmp	#15
	beq	top
	cmp	#101
	bne	next_v
top:
	lda	pos_inc,x
	eor	#$fe		; 1 => -1 ; -1 => 1
	sta	pos_inc,x
next_v:
	dex
	bpl	loop_v
	rti

cont:
	ldx	#8
	stx	MAPCTL		; map vector table
    ldy #$02
	sty	INTVECTL	; y = 2 => $202
	sty	INTVECTH
	lda	#$80
	tsb	HTIMCTLA	; enable HBL
	tsb	VTIMCTLA	; enable VBL
	cli
	lsr
	sta	pos
	sta	pos+1
	lsr
	sta	pos+2
	lda	#1
	sta	pos_inc
	sta	pos_inc+2
	lda	#$ff
	sta	pos_inc+1

wait:
	bra	wait
