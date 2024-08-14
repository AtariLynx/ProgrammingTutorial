.segment "CODE"
.org $0200

start:
    inc $FDA0
    bra start