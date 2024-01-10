.include	"lynx.inc"
.include	"extzp.inc"
.export _upload

.segment "UPCODE"

read_byte:
	bit     SERCTL
	bvc     read_byte
	lda     SERDAT
	rts

.proc _upload

	lda		INTSET
	and		#$10
;	bne	@L0

repeat:
	jsr     read_byte
    sta     PALETTE         ; feedback ;-)

	lda		#$10
	sta		INTRST
	clc
	rts

.endproc ; _upload

.segment "UPDATA"

flag:
	.byte   0
