Code located in LGSS.bin from $0410-$047F

0216   A2 07                LDX #$07
0218   BD 6C 02   L0218     LDA $026C,X
021B   95 4A                STA $4A,X
021D   CA                   DEX
021E   10 F8                BPL L0218

0220   A9 03                LDA #$03		; Modify code to load entry 3?
0222   8D 3B 03             STA $033B		; Original code 033A A9 01	LDA #$01
0225   20 0C 03             JSR $030C		; Calculate 2s complement of directory length
0228   A5 4E                LDA $4E		; Low part of load address	
022A   18                   CLC
022B   69 20                ADC #$20		; Skip 32 bytes to set first byte of SCB
022D   8D 10 FC             STA SCBNEXTL
0230   A5 4F                LDA $4F
0232   69 00                ADC #$00
0234   8D 11 FC             STA $SCBNEXTH	; Set SCB to display

0237   A2 08                LDX #$08		; Initialize Suzy
0239   BD 74 02   L0239     LDA $0274,X
023C   BC 7D 02             LDY $027D,X
023F   99 00 FC             STA $FC00,Y
0242   CA                   DEX
0243   10 F4                BPL L0239

0245   9C 91 FD             STZ $FD91		; Initialize palette with first 32 loaded bytes
0248   A0 1F                LDY #$1F
024A   B1 4E      L024A     LDA ($4E),Y
024C   99 A0 FD             STA $FDA0,Y
024F   88                   DEY
0250   10 F8                BPL L024A

0252   9C 94 FD             STZ DISPADRL
0255   A9 04                LDA #$04
0257   8D 95 FD             STA DISPADRH
025A   A2 70                LDX #$70
025C   AD B0 FC   L025C     LDA JOYSTICK
025F   D0 47                BNE $02A8		; Original Mikey bootloader code (Clears screen and load/runs second file entry)

0261   1A         L0261     INC
0262   D0 FD                BNE L0261
0264   C8                   INY
0265   D0 F5                BNE L025C
0267   CA                   DEX
0268   D0 F2                BNE L025C
026A   80 3C 		    BRA ?????????????	; Run second stage? 

;Store:4A 4B 4C 4D 4E 4F 50 51
026C   01 AA 01 00 00 24 9C 0A			; Entry for splash screen

0274   01 7F 7F 04 00 20 01 00 00
027D   91 28 2A 09 08 92 90 04 06
0286   00

;auto-generated symbols and labels
 L0218      $0218
 L0239      $0239
 L024A      $024A
 L0261      $0261
 L025C      $025C