.include        "lynx.inc"
.export _turbo_upload
.global         _FileDestAddr: zp
.global         _FileFileLen: zp
.global         _FileCurrBlock: zp

load_len=_FileDestAddr
load_ptr=_FileFileLen
load_ptr2=_FileCurrBlock

.macro read_byte
        .local read0
read0:
        bit     SERCTL         ; Check for RXRDY ($40)
        bvc     read0
        lda     SERDAT
.endmacro

.segment "CODE"

.proc _turbo_upload
        dec	$fda0
        dec	$fda1
        ldy     #4
loop0:
        read_byte
        sta     load_len-1,y
        dey
        bne     loop0       ; get destination and length
        tax                 ; lowbyte of length

        lda     load_ptr
        sta     load_ptr2
        lda     load_ptr+1
        sta     load_ptr2+1

        inc	$fda0
        inc	$fda0

loop1:
        inx
        bne     cont1
        inc     load_len+1
        bne     cont1
        jmp     (load_ptr)

cont1:
        read_byte
        sta     (load_ptr2),y
        sta     PALETTE + 1         ; feedback ;-)
        iny
        bne     loop1
        inc     load_ptr2+1
        bra     loop1
.endproc