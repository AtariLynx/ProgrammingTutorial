    .setcpu		"65C02"
    .smart		on
    .autoimport	on
    .case		on
    .debuginfo	off
    .macpack	longbranch

    .forceimport	__STARTUP__
    .export		_main

    .forceimport	__STARTUP__
    .export		_main


    .segment "CODE"

    .proc _main: near

loop:
    inc $FDA0
    bra loop

    .endproc