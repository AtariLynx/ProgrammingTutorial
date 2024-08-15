    .export		_update
    .include "lynx.inc"
    .segment "CODE"

    .proc _update: near

loop:
    inc GCOLMAP
    rts

    .endproc