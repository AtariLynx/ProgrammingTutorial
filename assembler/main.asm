.segment "CODE"
.org $0200
.import _update

start:
    jsr _update
    bra start