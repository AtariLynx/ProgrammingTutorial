                            * = $F2E2
INITSYS macro
F2E2   A9 0D                LDA #$0D
F2E4   8D 58 F7             STA $F758		; __dispctl
F2E7   A9 08                LDA #$08
F2E9   8D 57 F7             STA $F757		; __sprsys
F2EC   8D 92 FC             STA SPRSYS
F2EF   A9 08                LDA #$08		; Vector space
F2F1   8D F9 FF             STA MAPCTL		
F2F4   A9 0A                LDA #$0A		; CART_ADDR_DATA+RESTLESS	
F2F6   8D 59 F7             STA LF759		; __iodat
F2F9   8D 8B FD             STA IODAT
F2FC   8D 5A F7             STA $F75A		; __iodir
F2FF   8D 8A FD             STA IODIR
F302   A9 04                LDA #$04		; TXOPEN
F304   8D 8C FD             STA SERCTL

INITINT $F761 macro
F307   A9 61                LDA #$61
F309   8D FE FF             STA $FFFE
F30C   A9 F7                LDA #$F7
F30E   8D FF FF             STA $FFFF		; IRQ vector to $F761 UserIntHandler

; Initialize jump table at $EFE0 to $F77E IntReturn
F311   A2 0F                LDX #$0F
F313   A9 F7      LF313     LDA #$F7
F315   9D E0 EF             STA $EFE0,X
F318   CA                   DEX
F319   A9 7E                LDA #$7E
F31B   9D E0 EF             STA $EFE0,X
F31E   CA                   DEX
F31F   10 F2                BPL LF313

F321   A9 04                LDA #$04		; TXOPEN
F323   8D 8C FD             STA SERCTL		
F326   A9 10                LDA #$10
F328   8D 80 FD             STA INTRST		; Reset timer 4 for serial
End INITINT macro

F32B   58                   CLI			; Let's go
F32C   D8                   CLD
F32D   A2 20                LDX #$20		; Set stack pointer to start at 32?
F32F   9A                   TXS

Macro SETDISP_60
F330   A9 9E                LDA #$9E		; 158 == 159 before zero and +1 for underflow => 160 horizontal resolution
F332   8D 00 FD             STA TIMER0+BACKUP	
F335   A9 18                LDA #$18		; Enable reload and enable count
F337   8D 01 FD             STA TIMER0+CTL	; TIM1CTL
F33A   A9 68                LDA #$68		; 104 == 102 vertical resolution + 3 
F33C   8D 08 FD             STA TIMER2+BACKUP
F33F   A9 9F                LDA #$9F		; Enable reload + enable interrupt
F341   8D 09 FD             STA TIMER2+CTL	;
F344   A9 29                LDA #$29
F346   8D 93 FD             STA PBKUP		; Magic PBKUP 0x29 value
F349   20 87 F7             JSR LF787		; InitDisplayer
End of SETDISP macro

F34C   A9 F3                LDA #$F3
F34E   8D 83 FC             STA SPRINIT		; Special fixed value (docs say $F3)
F351   A9 7F                LDA #$7F
F353   8D 28 FC             STA HSIZOFFL
F356   8D 2A FC             STA VSIZOFFL	; Default values for offsets
F359   A9 01                LDA #$01
F35B   8D 90 FC             STA SUZYBUSEN	; Enable Suzy busy
F35E   9C 90 FD             STZ SDONEACK

Macro SETDBUF $D000 $D000 (single buffer?)
F361   A9 00                LDA #$00
F363   8D 5B F7             STA $F75B		; ??
F366   A9 D0                LDA #$D0		
F368   8D 5C F7             STA $F75C		; ??
F36B   A9 00                LDA #$00
F36D   8D 5D F7             STA $F75D		; DISPADRL
F370   A9 D0                LDA #$D0
F372   8D 5E F7             STA $F75E		; DISPADRH
F375   9C 60 F7             STZ $F760		; ??
F378   AD 57 F7             LDA $F757		; __sprsys
F37B   09 20                ORA #$20		; Don't collide
F37D   8D 57 F7             STA $F757
F380   8D 92 FC             STA SPRSYS

Initialize color map
RGB16 macro F9ED
F383   A9 ED                LDA #$ED
F385   85 E0                STA $E0		; sysptr
F387   A9 F9                LDA #$F9
F389   85 E1                STA $E1
F38B   A0 1F                LDY #$1F		; Initialize palette at $F9ED
F38D   B1 E0      LF38D     LDA ($E0),Y
F38F   99 A0 FD             STA COLMAP,Y
F392   88                   DEY
F393   10 F8                BPL LF38D

F395   A9 14                LDA #$14
F397   8D 04 FC             STA HOFFL		; HOFF8 macro
F39A   A9 14                LDA #$14
F39C   8D 06 FC             STA VOFFL		; VOFF8 macro

INITLIT $F200,21 macro (full-screen buffer at $F200)
F39F   A9 00                LDA #$00		; Initialize 8 values in $F200 to #$15
F3A1   A2 F2                LDX #$F2
F3A3   85 E0                STA $E0
F3A5   86 E1                STX $E1
F3A7   A2 07                LDX #$07		; FONT_HEIGT
F3A9   A9 15      LF3A9     LDA #$15
F3AB   92 E0 		    STA ($E0)
F3AD   18		    CLC
F3AE   65 E0                ADC $E0
F3B0   85 E0                STA $E0
F3B2   90 02                BCC LF3B6
F3B4   E6 E1                INC $E1
F3B6   CA         LF3B6     DEX
F3B7   D0 F0                BNE LF3A9

F3B9   A9 00                LDA #$00
F3BB   92 E0 		    STA ($E0)
End INITLIT macro

INITLIT $F294, 5 macro
F3BD   A9 94 		    LDA #$94
F3BF   A2 F2                LDX #$F2
F3C1   85 E0                STA $E0
F3C3   86 E1                STX $E1
F3C5   A2 07                LDX #$07
F3C7   A9 05      LF3C7     LDA #$05
F3C9   92 E0 		    STA ($E0)
F3CB   18	 	    CLC
F3CC   65 E0                ADC $E0
F3CE   85 E0                STA $E0
F3D0   90 02                BCC LF3D4
F3D2   E6 E1                INC $E1
F3D4   CA         LF3D4     DEX
F3D5   D0 F0                BNE LF3C7

F3D7   A9 00                LDA #$00
F3D9   92 E0 		    STA ($E0)
End INITLIT macro

; Initialize serial interrupt handler
F3DB   A9 2D 		    LDA #$2D
F3DB   8D E8 EF             STA $EFE8
F3E0   A9 F7                LDA #$F7
F3E2   8D E9 EF             STA $EFE9

F3E5   A9 03                LDA #$03	
F3E7   8D 10 FD             STA TIM4BKUP	; 31250 baud
F3EA   A9 18                LDA #$18		; Enable reload and enable count
F3EC   8D 11 FD             STA TIM4CTLA
F3EF   A9 4D                LDA #$4D		;RXINTEN+RESETERR+TXOPEN+PAREVEN
F3F1   8D 8C FD             STA SERCTL


F3F4   64 E6 		    STZ $E6
F3F6   64 E7                STZ $E7
F3F8   A9 FE                LDA #$FE
F3FA   85 EE                STA $EE
F3FC   64 F8                STZ $F8

Macro SPRITES FA0D, 0
F3FE   A9 0D                LDA #$0D
F400   8D 10 FC             STA SCBNEXTL		
F403   A9 FA                LDA #$FA
F405   8D 11 FC             STA SCBNEXTH
F408   AD 5B F7             LDA $F75B
F40B   8D 08 FC             STA VIDBASEL
F40E   AD 5C F7             LDA $F75C
F411   8D 09 FC             STA VIDBASEH
F414   9C 90 FD             STZ SDONEACK
F417   A9 01                LDA #$01
F419   8D 91 FC             STA SPRGO	
	
F41C   0C F9 FF 	    TSB MAPCTL
F41F   9C 91 FD             STZ CPUSLEEP
F422   1C F9 FF             TRB MAPCTL
F425   AD 92 FC             LDA DISPCTL
F428   29 01                AND #$01
F42A   D0 F0                BNE LF41C
F42C   9C 90 FD             STZ SDONEACK
End SPRITES macro 

F42F   20 CA F6   LF42F     JSR LF6CA

F432   C9 11                CMP #$11
F434   D0 F9                BNE LF42F
F436   20 CA F6             JSR LF6CA
F439   C9 07                CMP #$07
F43B   D0 F2                BNE LF42F
F43D   A9 25                LDA #$25
F43F   8D 44 FA             STA $FA44
F442   A9 1C                LDA #$1C
F444   8D 3A FA             STA $FA3A
F447   20 CA F6             JSR LF6CA
F44A   F0 0D                BEQ LF459
F44C   C9 01                CMP #$01
F44E   F0 11                BEQ LF461
F450   C9 02                CMP #$02
F452   F0 0F                BEQ LF463
F454   20 82 F4             JSR LF482
F457   80                   ???                ;%10000000
F458   10 20                BPL LF47A
F45A   82                   ???                ;%10000010
F45B   F4                   ???                ;%11110100
F45C   20 32 F5             JSR LF532
F45F   80                   ???                ;%10000000
F460   CE 80 CC             DEC $CC80
F463   20 84 F5   LF463     JSR LF584
F466   20 82 F4             JSR LF482
F469   78                   SEI
F46A   A9 0D                LDA #$0D
F46C   8D 8C FD             STA $FD8C
F46F   A9 FF                LDA #$FF
F471   8D 80 FD             STA $FD80
F474   A2 0F                LDX #$0F
F476   9E         LF476     ???                ;%10011110
F477   A0 FD                LDY #$FD
F479   9E         LF479     ???                ;%10011110
F47A   B0 FD      LF47A     BCS LF479
F47C   CA                   DEX
F47D   10 F7                BPL LF476
F47F   6C E8 00             JMP ($00E8)
F482   A9 3D      LF482     LDA #$3D
F484   8D 10 FC             STA $FC10
F487   A9 FA                LDA #$FA
F489   8D 11 FC             STA $FC11
F48C   9C         LF48C     ???                ;%10011100
F48D   90 FD                BCC LF48C
F48F   A9 01                LDA #$01
F491   8D 91 FC             STA $FC91
F494   0C         LF494     ???                ;%00001100
F495   F9 FF 9C             SBC $9CFF,Y
F498   91 FD                STA ($FD),Y
F49A   1C                   ???                ;%00011100
F49B   F9 FF AD             SBC $ADFF,Y
F49E   92                   ???                ;%10010010
F49F   FC                   ???                ;%11111100
F4A0   29 01                AND #$01
F4A2   D0 F0                BNE LF494
F4A4   9C         LF4A4     ???                ;%10011100
F4A5   90 FD                BCC LF4A4
F4A7   20 D7 F6             JSR LF6D7
F4AA   20 DD F6             JSR LF6DD
F4AD   20 E3 F6             JSR LF6E3
F4B0   20 F3 F6             JSR LF6F3
F4B3   A6 EC                LDX $EC
F4B5   E6 ED                INC $ED
F4B7   20 CA F6   LF4B7     JSR LF6CA
F4BA   92                   ???                ;%10010010
F4BB   EA                   NOP
F4BC   E6 EA                INC $EA
F4BE   D0 02                BNE LF4C2
F4C0   E6 EB                INC $EB
F4C2   DA         LF4C2     ???                ;%11011010
F4C3   86 F5                STX $F5
F4C5   A6 EE                LDX $EE
F4C7   BD 01 F1             LDA $F101,X
F4CA   C5 ED                CMP $ED
F4CC   D0 33                BNE LF501
F4CE   BD 00 F1             LDA $F100,X
F4D1   C5 F5                CMP $F5
F4D3   D0 2C                BNE LF501
F4D5   CA                   DEX
F4D6   CA                   DEX
F4D7   86 EE                STX $EE
F4D9   EE 44 FA             INC $FA44
F4DC   A9 3D                LDA #$3D
F4DE   8D 10 FC             STA $FC10
F4E1   A9 FA                LDA #$FA
F4E3   8D 11 FC             STA $FC11
F4E6   9C         LF4E6     ???                ;%10011100
F4E7   90 FD                BCC LF4E6
F4E9   A9 01                LDA #$01
F4EB   8D 91 FC             STA $FC91
F4EE   0C         LF4EE     ???                ;%00001100
F4EF   F9 FF 9C             SBC $9CFF,Y
F4F2   91 FD                STA ($FD),Y
F4F4   1C                   ???                ;%00011100
F4F5   F9 FF AD             SBC $ADFF,Y
F4F8   92                   ???                ;%10010010
F4F9   FC                   ???                ;%11111100
F4FA   29 01                AND #$01
F4FC   D0 F0                BNE LF4EE
F4FE   9C         LF4FE     ???                ;%10011100
F4FF   90 FD                BCC LF4FE
F501   A5 F8      LF501     LDA $F8
F503   D0 09                BNE LF50E
F505   FA                   ???                ;%11111010
F506   CA                   DEX
F507   D0 AE                BNE LF4B7
F509   C6 ED                DEC $ED
F50B   D0 AA                BNE LF4B7
F50D   60                   RTS
F50E   A9 0F      LF50E     LDA #$0F
F510   8D B0 FD             STA $FDB0
F513   20 18 F5             JSR LF518
F516   80                   ???                ;%10000000
F517   FB                   ???                ;%11111011
F518   AD B0 FC   LF518     LDA $FCB0
F51B   29 08                AND #$08
F51D   F0 12                BEQ LF531
F51F   A9 01                LDA #$01
F521   2C B1 FC             BIT $FCB1
F524   F0 0B                BEQ LF531
F526   9C         LF526     ???                ;%10011100
F527   B0 FD                BCS LF526
F529   2C B1 FC   LF529     BIT $FCB1
F52C   D0 FB                BNE LF529
F52E   4C F4 F3             JMP LF3F4
F531   60         LF531     RTS
F532   A0 1F      LF532     LDY #$1F
F534   B1 E8      LF534     LDA ($E8),Y
F536   99 A0 FD             STA $FDA0,Y
F539   88                   DEY
F53A   10 F8                BPL LF534
F53C   A9 00                LDA #$00
F53E   8D 04 FC             STA $FC04
F541   8D 06 FC             STA $FC06
F544   18                   CLC
F545   A5 E8                LDA $E8
F547   69 20                ADC #$20
F549   85 E8                STA $E8
F54B   90 02                BCC LF54F
F54D   E6 E9                INC $E9
F54F   A5 E8      LF54F     LDA $E8
F551   8D 10 FC             STA $FC10
F554   A5 E9                LDA $E9
F556   8D 11 FC             STA $FC11
F559   9C         LF559     ???                ;%10011100
F55A   90 FD                BCC LF559
F55C   A9 01                LDA #$01
F55E   8D 91 FC             STA $FC91
F561   0C         LF561     ???                ;%00001100
F562   F9 FF 9C             SBC $9CFF,Y
F565   91 FD                STA ($FD),Y
F567   1C                   ???                ;%00011100
F568   F9 FF AD             SBC $ADFF,Y
F56B   92                   ???                ;%10010010
F56C   FC                   ???                ;%11111100
F56D   29 01                AND #$01
F56F   D0 F0                BNE LF561
F571   9C         LF571     ???                ;%10011100
F572   90 FD                BCC LF571
F574   A9 14                LDA #$14
F576   8D 04 FC             STA $FC04
F579   A9 14                LDA #$14
F57B   8D 06 FC             STA $FC06
F57E   A9 25                LDA #$25
F580   8D 44 FA             STA $FA44
F583   60                   RTS
F584   A2 FF      LF584     LDX #$FF
F586   E8         LF586     INX
F587   20 CA F6             JSR LF6CA
F58A   9D B8 F2             STA $F2B8,X
F58D   D0 F7                BNE LF586
F58F   20 DD F6             JSR LF6DD
F592   A5 EB                LDA $EB
F594   48                   PHA
F595   4A                   LSR A
F596   4A                   LSR A
F597   4A                   LSR A
F598   4A                   LSR A
F599   1A                   ???                ;%00011010
F59A   1A                   ???                ;%00011010
F59B   8D A5 F9             STA $F9A5
F59E   68                   PLA
F59F   29 0F                AND #$0F
F5A1   1A                   ???                ;%00011010
F5A2   1A                   ???                ;%00011010
F5A3   8D A6 F9             STA $F9A6
F5A6   A5 EA                LDA $EA
F5A8   48                   PHA
F5A9   4A                   LSR A
F5AA   4A                   LSR A
F5AB   4A                   LSR A
F5AC   4A                   LSR A
F5AD   1A                   ???                ;%00011010
F5AE   1A                   ???                ;%00011010
F5AF   8D A7 F9             STA $F9A7
F5B2   68                   PLA
F5B3   29 0F                AND #$0F
F5B5   1A                   ???                ;%00011010
F5B6   1A                   ???                ;%00011010
F5B7   8D A8 F9             STA $F9A8
F5BA   A2 FF                LDX #$FF
F5BC   E8         LF5BC     INX
F5BD   20 CA F6             JSR LF6CA
F5C0   9D CD F2             STA $F2CD,X
F5C3   D0 F7                BNE LF5BC
F5C5   A9 18                LDA #$18
F5C7   20 C2 F6             JSR LF6C2
F5CA   A9 B8                LDA #$B8
F5CC   85 E0                STA $E0
F5CE   A9 F2                LDA #$F2
F5D0   85 E1                STA $E1
F5D2   A9 00                LDA #$00
F5D4   8D F9 00             STA $00F9
F5D7   A9 F2                LDA #$F2
F5D9   8D FA 00             STA $00FA
F5DC   20 D7 F7             JSR LF7D7
F5DF   A9 31                LDA #$31
F5E1   8D 10 FC             STA $FC10
F5E4   A9 FA                LDA #$FA
F5E6   8D 11 FC             STA $FC11
F5E9   9C         LF5E9     ???                ;%10011100
F5EA   90 FD                BCC LF5E9
F5EC   A9 01                LDA #$01
F5EE   8D 91 FC             STA $FC91
F5F1   0C         LF5F1     ???                ;%00001100
F5F2   F9 FF 9C             SBC $9CFF,Y
F5F5   91 FD                STA ($FD),Y
F5F7   1C                   ???                ;%00011100
F5F8   F9 FF AD             SBC $ADFF,Y
F5FB   92                   ???                ;%10010010
F5FC   FC                   ???                ;%11111100
F5FD   29 01                AND #$01
F5FF   D0 F0                BNE LF5F1
F601   9C         LF601     ???                ;%10011100
F602   90 FD                BCC LF601
F604   A9 18                LDA #$18
F606   20 C2 F6             JSR LF6C2
F609   A9 9B                LDA #$9B
F60B   85 E0                STA $E0
F60D   A9 F9                LDA #$F9
F60F   85 E1                STA $E1
F611   A9 00                LDA #$00
F613   8D F9 00             STA $00F9
F616   A9 F2                LDA #$F2
F618   8D FA 00             STA $00FA
F61B   20 D7 F7             JSR LF7D7
F61E   A9 31                LDA #$31
F620   8D 10 FC             STA $FC10
F623   A9 FA                LDA #$FA
F625   8D 11 FC             STA $FC11
F628   9C         LF628     ???                ;%10011100
F629   90 FD                BCC LF628
F62B   A9 01                LDA #$01
F62D   8D 91 FC             STA $FC91
F630   0C         LF630     ???                ;%00001100
F631   F9 FF 9C             SBC $9CFF,Y
F634   91 FD                STA ($FD),Y
F636   1C                   ???                ;%00011100
F637   F9 FF AD             SBC $ADFF,Y
F63A   92                   ???                ;%10010010
F63B   FC                   ???                ;%11111100
F63C   29 01                AND #$01
F63E   D0 F0                BNE LF630
F640   9C         LF640     ???                ;%10011100
F641   90 FD                BCC LF640
F643   A9 09                LDA #$09
F645   20 C2 F6             JSR LF6C2
F648   A9 A5                LDA #$A5
F64A   85 E0                STA $E0
F64C   A9 F9                LDA #$F9
F64E   85 E1                STA $E1
F650   A9 00                LDA #$00
F652   8D F9 00             STA $00F9
F655   A9 F2                LDA #$F2
F657   8D FA 00             STA $00FA
F65A   20 D7 F7             JSR LF7D7
F65D   A9 31                LDA #$31
F65F   8D 10 FC             STA $FC10
F662   A9 FA                LDA #$FA
F664   8D 11 FC             STA $FC11
F667   9C         LF667     ???                ;%10011100
F668   90 FD                BCC LF667
F66A   A9 01                LDA #$01
F66C   8D 91 FC             STA $FC91
F66F   0C         LF66F     ???                ;%00001100
F670   F9 FF 9C             SBC $9CFF,Y
F673   91 FD                STA ($FD),Y
F675   1C                   ???                ;%00011100
F676   F9 FF AD             SBC $ADFF,Y
F679   92                   ???                ;%10010010
F67A   FC                   ???                ;%11111100
F67B   29 01                AND #$01
F67D   D0 F0                BNE LF66F
F67F   9C         LF67F     ???                ;%10011100
F680   90 FD                BCC LF67F
F682   A9 09                LDA #$09
F684   20 C2 F6             JSR LF6C2
F687   A9 CD                LDA #$CD
F689   85 E0                STA $E0
F68B   A9 F2                LDA #$F2
F68D   85 E1                STA $E1
F68F   A9 00                LDA #$00
F691   8D F9 00             STA $00F9
F694   A9 F2                LDA #$F2
F696   8D FA 00             STA $00FA
F699   20 D7 F7             JSR LF7D7
F69C   A9 31                LDA #$31
F69E   8D 10 FC             STA $FC10
F6A1   A9 FA                LDA #$FA
F6A3   8D 11 FC             STA $FC11
F6A6   9C         LF6A6     ???                ;%10011100
F6A7   90 FD                BCC LF6A6
F6A9   A9 01                LDA #$01
F6AB   8D 91 FC             STA $FC91
F6AE   0C         LF6AE     ???                ;%00001100
F6AF   F9 FF 9C             SBC $9CFF,Y
F6B2   91 FD                STA ($FD),Y
F6B4   1C                   ???                ;%00011100
F6B5   F9 FF AD             SBC $ADFF,Y
F6B8   92                   ???                ;%10010010
F6B9   FC                   ???                ;%11111100
F6BA   29 01                AND #$01
F6BC   D0 F0                BNE LF6AE
F6BE   9C         LF6BE     ???                ;%10011100
F6BF   90 FD                BCC LF6BE
F6C1   60                   RTS
F6C2   18         LF6C2     CLC
F6C3   6D 3A FA             ADC $FA3A
F6C6   8D 3A FA             STA $FA3A
F6C9   60                   RTS

Subroutine 
F6CA   A4 E7      LF6CA     LDY $E7
F6CC   C4 E6                CPY $E6
F6CE   F0 FA                BEQ LF6CA
F6D0   C8                   INY
F6D1   B9 00 F0             LDA $F000,Y
F6D4   84 E7                STY $E7
F6D6   60                   RTS

F6D7   A2 E8      LF6D7     LDX #$E8
F6D9   20 E9 F6             JSR LF6E9
F6DC   60                   RTS
F6DD   A2 EA      LF6DD     LDX #$EA
F6DF   20 E9 F6             JSR LF6E9
F6E2   60                   RTS
F6E3   A2 EC      LF6E3     LDX #$EC
F6E5   20 E9 F6             JSR LF6E9
F6E8   60                   RTS

F6E9   20 ED F6   LF6E9     JSR LF6ED
F6EC   E8                   INX

F6ED   20 CA F6   LF6ED     JSR LF6CA
F6F0   95 00                STA $00,X
F6F2   60                   RTS
F6F3   A5 EC      LF6F3     LDA $EC
F6F5   0A                   ASL A
F6F6   85 EF                STA $EF
F6F8   85 F2                STA $F2
F6FA   A5 ED                LDA $ED
F6FC   2A                   ROL A
F6FD   85 F0                STA $F0
F6FF   85 F3                STA $F3
F701   A9 00                LDA #$00
F703   2A                   ROL A
F704   85 F1                STA $F1
F706   1A                   ???                ;%00011010
F707   85 F4                STA $F4
F709   A2 00                LDX #$00
F70B   A5 F3      LF70B     LDA $F3
F70D   9D 00 F1             STA $F100,X
F710   A5 F4                LDA $F4
F712   9D 01 F1             STA $F101,X
F715   18                   CLC
F716   A5 EF                LDA $EF
F718   65 F2                ADC $F2
F71A   85 F2                STA $F2
F71C   A5 F0                LDA $F0
F71E   65 F3                ADC $F3
F720   85 F3                STA $F3
F722   A5 F1                LDA $F1
F724   65 F4                ADC $F4
F726   85 F4                STA $F4
F728   E8                   INX
F729   E8                   INX
F72A   D0 DF                BNE LF70B
F72C   60                   RTS

; Serial interrupt handler
F72D   A2 05                LDX #$05		; TXOPEN+PAREVEN (no interrupts for now)
F72F   8E 8C FD             STX SERCTL
F732   A9 10                LDA #$10
F734   8D 80 FD             STA INTRST		; Reset timer interrupt bit for serial
F737   AD 8C FD             LDA SERCTL
F73A   89 40                BIT #$40		; RXRDY data available?
F73C   F0 11                BEQ LF74F		; No, skip to return

F73E   29 1C                AND #$1C		; PARERR+OVERRUN+FRAMERR 
F740   F0 02                BEQ LF744		; Check for errors
F742   E6 F8                INC $F8		; Count errors?

F744   AD 8D FD   LF744     LDA SERDAT		; Load serial data
F747   A6 E6                LDX $E6		; Store in circular buffer
F749   E8                   INX
F74A   86 E6                STX $E6
F74C   9D 00 F0             STA $F000,X		; Buffer at $F000-F0FF

F74F   A2 4D      LF74F     LDX #$4D		; RXINTEN+RESETERR+TXOPEN+PAREVEN
F751   8E 8C FD             STX SERCTL
F754   4C 7E F7             JMP LF77E		; End IRQ

SEGMENT .DATA
(sysdata.src)
F757   00                   BRK			; __sprsys
F758   00                   BRK			; __dispctl (see $F7AC and )
F759   00                   BRK			; __iodat
F75A   00                   BRK			; __iodir
F75B   00                   BRK			; ?
F75C   00                   BRK			; ?
F75D   00                   BRK			; DISPADRL value (read at $F7C4)
F75E   00                   BRK			; DISPADRH value
F75F   00                   BRK			; Save interrupt bits from INTSET
F760   00                   BRK			; DisplayFlags

.CODE from sys.src

; ISR routine!
UserIntHandler
F761   48                   PHA			; Store A and X
F762   DA                   PHX
F763   AD 81 FD             LDA INTSET		; Load interrupt bits
F766   89 10 		    BIT #$10		; Check for serial interrupt
F768   F0 03                BEQ $F76D
F76A   6C E8 EF             JMP ($EFE8)		; Use 4th entry in jump table
	
F76D   8D 5F F7             STA $F75F		; Save INTSET
F770   A2 00                LDX #$00
F772   A9 01                LDA #$01
F774   2C 5F F7   LF774     BIT $F75F		; Check for interrupt starting at 1
F777   D0 08                BNE LF781
F779   E8                   INX
F77A   E8                   INX
F77B   0A                   ASL A
F77C   D0 F6                BNE LF774

; Dummy IRQ handler (initial destination of jump table entries)
IntReturn
F77E   FA         LF77E     PLX			; End interrupt
F77F   68                   PLA
F780   40                   RTI

jumpIntTable
F781   8D 80 FD   LF781     STA INTRST		; Reset interrupt bit
F784   7C E0 EF             JMP ($EFE0,X)	; Use jump table

.CODE End of sys.src

InitDisplayer
F787   AD E4 EF   LF787     LDA $EFE4		; Modify jump address using third entry (timer 2)
F78A   8D D5 F7             STA $F7D5
F78D   AD E5 EF             LDA $EFE5
F790   8D D6 F7             STA $F7D6

F793   A9 9E                LDA #$9E		; Set third entry to handler at $F79E
F795   8D E4 EF             STA $EFE4
F798   A9 F7                LDA #$F7
F79A   8D E5 EF             STA $EFE5
F79D   60                   RTS

; End-of-Frame Handler
FrameEnd
F79E   5A                   PHY
F79F   AD F9 FF             LDA MAPCTL
F7A2   48                   PHA
F7A3   29 FE                AND #$FE
F7A5   8D F9 FF             STA MAPCTL		; Switch to RAM

TIMEOUT macro does nothing here

F7A8   68                   PLA
F7A9   8D F9 FF             STA MAPCTL	

DISPLAY macro	
F7AC   AD 58 F7             LDA $F758		; __dispctl
F7AF   8D 92 FD             STA DISPCTL
F7B2   29 02                AND #$02		; FLIP
F7B4   F0 0E                BEQ LF7C4

; This alternates screen base addresses between $D000 and $EFE0
F7B6   AD 5D F7             LDA $F75D		
F7B9   18                   CLC
F7BA   69 DF                ADC #$DF		; Shift #$1FDF to set address to 
F7BC   AA                   TAX
F7BD   AD 5E F7             LDA $F75E
F7C0   69 1F                ADC #$1F
F7C2   80 06 		    BRA $F7CA

F7C4   AE 5D F7 	    LDX $F75D
F7C7   AD 5E F7		    LDA $F75E

DISP_AX macro
F7CA   08             	    PHP
F7CB   78                   SEI
F7CC   8E 94 FD             STX DISPADRL	; 
F7CF   8D 95 FD             STA DISPADRH
F7D2   28                   PLP
End DISP_AX macro
End DISPLAY macro

F7D3   7A                   PLY

FrameEndExit
; Self modified destination from $F787-$F792 to FrameEnd 
F7D4   4C 7E F7             JMP LF77E		; IntReturn

.CODE for hprint.src

HandyPrint
F7D7   A5 F9      LF7D7     LDA $F9		; TextPtr
F7D9   85 E2                STA $E2
F7DB   A5 FA                LDA $FA		; TextPtr+1
F7DD   85 E3                STA $E3
F7DF   B2 E2                LDA ($E2)
F7E1   85 FB                STA $FB		; TextWidth
F7E3   3A                   DEC
F7E4   85 FC                STA $FC		; TextRemaining

hprintLoop
F7E6   B2 E0 		    LDA ($E0)
F7E8   D0 08                BNE 
F7EA   9C 61 FC             STZ MATHG		; Setup shortcut for math
F7ED   A6 FC                LDX $FC
F7EF   D0 1E                BNE LF80F
F7F1   60                   RTS

F7F2   3A         LF7F2     DEC
F7F3   8D 54 FC             STA MATHB
F7F6   A9 07                LDA #$07		; FONT_HEIGHT
F7F8   8D 52 FC             STA MATHD
F7FB   9C 53 FC             STZ MATHC
F7FE   9C 55 FC             STZ MATHA
F801   E6 E0                INC $E0
F803   D0 02                BNE LF807
F805   E6 E1                INC $E1

Macro WAITMATH
F807   2C 92 FC   LF807     BIT $FC92
F80A   30 FB                BMI LF807
End WAITMATH macro

F80C   AD 60 FC             LDA MATHH
F80F   18         LF80F     CLC
F810   69 44                ADC #$44		; <FontBase
F812   85 E4                STA $E4		; sysptr3
F814   AD 61 FC             LDA MATHG
F817   69 F8                ADC #$F8		; >FontBase
F819   85 E5                STA $E5
F81B   E6 F9                INC $F9
F81D   D0 02                BNE LF821
F81F   E6 FA                INC $FA
F821   A5 F9      LF821     LDA $F9
F823   85 E2                STA $E2
F825   A5 FA                LDA $FA
F827   85 E3                STA $E3
F829   A0 06                LDY #$06		; FONT_HEIGHT-1
F82B   B1 E4      LF82B     LDA ($E4),Y
F82D   92 E2                STA (sysptr2)
F82F   A5 E2                LDA sysptr2
F831   18                   CLC
F832   65 FB                ADC $FB
F834   85 E2                STA $E2
F836   A5 E3                LDA $E3
F838   69 00                ADC #$00
F83A   85 E3                STA $E3
F83C   88                   DEY
F83D   10 EC                BPL LF82B		; hprintCharLoop
F83F   C6 FC                DEC $FC
F841   4C E6 F7             JMP LF7E6		; hprintloop

End code for hprint.src

FontBase

Macro HPRFONT HPRDIGIT+UPPER+PUNC
; space
F844   00                   BRK
F845   00                   BRK
F846   00                   BRK
F847   00                   BRK
F848   00                   BRK
F849   00                   BRK
F84A   00                   BRK

; 0
F84B   7C                   ;%01111100
F84C   C6                   ;%11000110
F84D   E6                   ;%11100110
F84E   D6                   ;%11010110
F84E   CE                   ;%11001110
F850   C6                   ;%11000110                
F851   7C                   ;%01111100

; 1
F852   FE 18 18             ; 1
F855   18                   
F856   78                   
F857   38                   
F858   18                   

; 2
F859   FE 30 18             INC $1830,X
F85C   0C                   ???                ;%00001100
F85D   06 C6                ASL $C6
F85F   7C                   ???                ;%01111100 '|'

;3
F860   7C                   ???                ;%01111100 '|'
F861   C6 06                DEC $06
F863   0C                   ???                ;%00001100
F864   06 C6                ASL $C6
F866   7C                   ???                ;%01111100 '|'

;4
F867   0C                   ???                ;%00001100
F868   0C                   ???                ;%00001100
F869   FE CC 6C             INC $6CCC,X
F86C   3C                   ???                ;%00111100 '<'
F86D   1C                   ???                ;%00011100

;5
F86E   FC                   ???                ;%11111100
F86F   06 06                ASL $06
F871   FC                   ???                ;%11111100
F872   C0 C0                CPY #$C0
F874   FC                   ???                ;%11111100

;6
F875   7C                   ???                ;%01111100 '|'
F876   C6 C6                DEC $C6
F878   FC                   ???                ;%11111100
F879   C0 C0                CPY #$C0
F87B   7C                   ???                ;%01111100 '|'

;7
F87C   C0 60                CPY #$60
F87E   30 18                BMI LF898
F880   0C                   ???                ;%00001100
F881   06 FE                ASL $FE

;8
F883   7C                   ???                ;%01111100 '|'
F884   C6 C6                DEC $C6
F886   7C                   ???                ;%01111100 '|'
F887   C6 C6                DEC $C6
F889   7C                   ???                ;%01111100 '|'

;9
F88A   7C                   ;%01111100 
F88B   06                   ;%00000110
F88C   06                   ;%00000110
F88D   7E                   ;%01111110
F88D   C6                   ;%11000110
F88D   C6                   ;%11000110
F890   7C                   ;%01111100

;A
F891   C6                   ;%11000110
F892   C6                   ;%11000110
F893   C6                   ;%11000110
F894   FE                   ;%11111110
F895   C6                   ;%11000110
F896   6C                   ;%01101100
F897   38                   ;%00111000

F898   FC         LF898     ???                ;%11111100
F899   C6 C6                DEC $C6
F89B   FC                   ???                ;%11111100
F89C   C6 C6                DEC $C6
F89E   FC                   ???                ;%11111100

F89F   7C                   ???                ;%01111100 '|'
F8A0   C6 C0                DEC $C0
F8A2   C0 C0                CPY #$C0
F8A4   C6 7C                DEC $7C

F8A6   FC                   ???                ;%11111100
F8A7   C6 C6                DEC $C6
F8A9   C6 C6                DEC $C6
F8AB   C6 FC                DEC $FC

F8AD   FE C0 C0             INC $C0C0,X
F8B0   F8                   SED
F8B1   C0 C0                CPY #$C0
F8B3   FE 

C0 C0             INC $C0C0,X
F8B6   C0 F8                CPY #$F8
F8B8   C0 C0                CPY #$C0
F8BA   FE 

7E C6             INC $C67E,X
F8BD   C6 CE                DEC $CE
F8BF   C0 C6                CPY #$C6
F8C1   7C                   ???                ;%01111100 '|'

F8C2   C6 C6                DEC $C6
F8C4   C6 FE                DEC $FE
F8C6   C6 C6                DEC $C6
F8C8   C6 

;I
F8C9   7E                   ;%01111110
F8CA   18                   ;%00011000
F8CB   18                   CLC
F8CC   18                   CLC
F8CD   18                   CLC
F8CE   18                   CLC
F8CF   7E 

7C C6             	    ;%1100ROR $C67C,X
F8D2   06 06                ASL $06
F8D4   06 06                ASL $06
F8D6   7E 

C6 
CC             ROR $CCC6,X
F8D9   D8                   CLD
F8DA   F0 D8                BEQ LF8B4
F8DC   CC C6 

FE             CPY $FEC6
F8DF   C0 C0                CPY #$C0
F8E1   C0 C0                CPY #$C0
F8E3   C0 C0                CPY #$C0

F8E5   C6 C6                DEC $C6
F8E7   C6 D6                DEC $D6
F8E9   FE EE C6             INC $C6EE,X

F8EC   C6 C6                DEC $C6
F8EE   CE DE F6             DEC $F6DE
F8F1   E6 C6                INC $C6

F8F3   7C                   ???                ;%01111100 '|'
F8F4   C6 C6                DEC $C6
F8F6   C6 C6                DEC $C6
F8F8   C6 7C                DEC $7C

F8FA   C0 C0                CPY #$C0
F8FC   C0 FC                CPY #$FC
F8FE   C6 C6                DEC $C6
F900   FC                   ???                ;%11111100

F901   7A                   ???                ;%01111010 'z'
F902   CE D6 C6             DEC $C6D6
F905   C6 C6                DEC $C6
F907   7C                   ???                ;%01111100 '|'

F908   C6 CC                DEC $CC
F90A   D8                   CLD
F90B   FC                   ???                ;%11111100
F90C   C6 C6                DEC $C6
F90E   FC                   ???                ;%11111100

F90F   7C                   ???                ;%01111100 '|'
F910   C6 06                DEC $06
F912   7C                   ???                ;%01111100 '|'
F913   C0 C6                CPY #$C6
F915   7C                   ???                ;%01111100 '|'

F916   18                   CLC
F917   18                   CLC
F918   18                   CLC
F919   18                   CLC
F91A   18                   CLC
F91B   18                   CLC
F91C   7E 

7C C6             ROR $C67C,X
F91F   C6 C6                DEC $C6
F921   C6 C6                DEC $C6
F923   C6 

38                DEC $38
F925   38                   SEC
F926   6C 6C 6C             JMP ($6C6C)
F929   C6 C6                DEC $C6

F92B   6C D6 D6             JMP ($D6D6)
F92E   D6 C6                DEC $C6,X
F930   C6 C6                DEC $C6

F932   C6 C6                DEC $C6
F934   6C 38 6C             JMP ($6C38)
F937   C6 C6                DEC $C6

;Y
F939   18                   ;%00011000
F93A   18                   ;%00011000
F93B   18                   ;%00011000
F93C   18                   ;%00011000
F93D   3C                   ;%00111100 '<'
F93E   66                   ;%01100110
F93F   66                   ;%01100110

;Z
F940   FE                   ;%11111110
F941   C0                   ;%11000000
F942   60                   ;%01100000
F943   30                   ;%00110000
F943   18                   ;%00011000
F945   0C                   ;%00001100
F946   FE                   ;%11111110

;!
F946   18                   ;%00011000
F947   00                   ;%00000000
F949   18                   ;%00011000
F94A   3C                   ;%00111100 '<'
F94B   3C                   ;%00111100 '<'
F94C   3C                   ;%00111100 '<'
F94D   18                   ;%00011000

; "
F94E   00                   BRK
F94F   00                   BRK
F950   00                   BRK
F951   00                   BRK
F952   66 66                ROR $66
F954   66 

; ' 
F955   00                   ROR $00
F956   00                   BRK
F957   00                   BRK
F958   00                   BRK
F959   30                   ;%00110000
F959   18                   ;%00011000
F95B   18                   ;%00011000

; (
F95C   0C                   ;%00001100
F95D   18         LF95D     CLC
F95E   30 30                BMI LF990
F960   30 18                BMI LF97A
F962   0C                   ???                ;%00001100

; )
F963   30                   BMI LF97D
F963   18                   ;%00011000
F965   0C                   ;%00001100
F966   0C                   ;%00001100
F967   0C                   ;%00001100
F968   18                   ;%00011000
F969   30 		    ;%00110000

; ,
F96A   30                   ;%00110000
F96B   18                   ;%00011000
F96C   18                   ;%00011000
F96D   00                   BRK
F96E   00                   BRK
F96F   00                   BRK
F970   00                   BRK

; -
F971   00                   BRK
F972   00                   BRK
F973   00         LF973     BRK
F974   3C                   ???                ;%00111100 '<'
F975   00                   BRK
F976   00                   BRK
F977   00                   BRK

; .
F978   18                   CLC
F979   18                   CLC
F97A   00         LF97A     BRK
F97B   00                   BRK
F97C   00                   BRK
F97D   00         LF97D     BRK
F97E   00                   BRK

; :
F97F   00                   BRK
F980   18                   CLC
F981   18                   CLC
F982   00                   BRK
F983   18                   CLC
F984   18                   CLC
F985   00                   BRK

; ;
F986   30 18                BMI LF9A0
F988   18                   CLC
F989   00                   BRK
F98A   18                   CLC
F98B   18                   CLC
F98C   00                   BRK

; ?
F98D   18                   CLC
F98E   00                   BRK
F98F   18                   CLC
F990   0C         LF990     ;%00001100
F991   06                   ;%00000110
F991   C6                   ;%11000110
F993   7C                   ;%01111100
End of plain font

F994   A5                   ;%10100101
F995   5A                   ;%01011010
F996   A5                   ;%10100101
F997   5A                   ;%01011010
F998   A5                   ;%10100101
F999   5A                   ;%01011010
F99A   A5                   ;%10100101
Nix7


F99B   0E                   ;%00001110
F99C   1A                   ;%00011010
F99D   1B                   ;%00011011
F99E   24                   ;%00100100
F99E   1D                   ;%00011101
F9A0   14         LF9A0     ;%00010100
F9A1   12                   ;%00010010

F9A2   13                   ???                ;%00010011
F9A3   1F                   ???                ;%00011111
F9A4   00                   BRK
F9A5   01 01                ORA ($01,X)
F9A7   01 01                ORA ($01,X)
F9A9   01 0D                ORA ($0D,X)
F9AB   24 00                BIT $00
F9AD   08                   PHP
F9AE   7D F7 DF             ADC $DFF7,X
F9B1   7D F7 DF             ADC $DFF7,X
F9B4   14                   ???                ;%00010100
F9B5   0B                   ???                ;%00001011
F9B6   85 E7                STA $E7
F9B8   A1 79                LDA ($79,X)
F9BA   C8                   INY
F9BB   5E 72 17             LSR $1772,X
F9BE   9E                   ???                ;%10011110
F9BF   84 0B                STY $0B
F9C1   85 E7                STA $E7
F9C3   A1 79                LDA ($79,X)
F9C5   C8                   INY
F9C6   5E 72 17             LSR $1772,X
F9C9   9E                   ???                ;%10011110
F9CA   84 0B                STY $0B
F9CC   85 E7                STA $E7
F9CE   A1 79                LDA ($79,X)
F9D0   C8                   INY
F9D1   5E 72 17             LSR $1772,X
F9D4   9E                   ???                ;%10011110
F9D5   84 0B                STY $0B
F9D7   85 E7                STA $E7
F9D9   A1 79                LDA ($79,X)
F9DB   C8                   INY
F9DC   5E 72 17             LSR $1772,X
F9DF   9E                   ???                ;%10011110
F9E0   84 08                STY $08
F9E2   7D F7 DF             ADC $DFF7,X
F9E5   7D F7 DF             ADC $DFF7,X
F9E8   14                   ???                ;%00010100
F9E9   00                   BRK
F9EA   02                   ???                ;%00000010
F9EB   80                   ???                ;%10000000
F9EC   00                   BRK

; Palette values?
F9ED   00 00 0F 00 0F 0F 00 0F
F9F5   07 07 00 07 00 07 00 07
F9FD   00 0F 00 F0 F0 0F FF FF
FA05   7F 77 07 00 70 07 77 70 

FA0D   01	  
FA0E   B0 00                BCS LFA10
FA10   21 FA      LFA10     AND ($FA,X)
FA12   EA         LFA12     NOP
FA13   F9 14 00             SBC $0014,Y
FA16   14                   ???                ;%00010100
FA17   00                   BRK
FA18   00                   BRK
FA19   A0 00                LDY #$00
FA1B   66 00                ROR $00
FA1D   00                   BRK
FA1E   00                   BRK
FA1F   00                   BRK
FA20   00                   BRK
FA21   01 10                ORA ($10,X)
FA23   00                   BRK
FA24   00                   BRK
FA25   00                   BRK
FA26   AD F9 24             LDA $24F9
FA29   00                   BRK
FA2A   73                   ???                ;%01110011 's'
FA2B   00                   BRK
FA2C   00                   BRK
FA2D   01 00                ORA ($00,X)
FA2F   01 07                ORA ($07,X)
FA31   05 80                ORA $80
FA33   00                   BRK
FA34   00                   BRK
FA35   00                   BRK
FA36   00                   BRK
FA37   F2                   ???                ;%11110010
FA38   1C                   ???                ;%00011100
FA39   00                   BRK
FA3A   1C                   ???                ;%00011100
FA3B   00                   BRK
FA3C   02                   ???                ;%00000010
FA3D   05 90                ORA $90
FA3F   00                   BRK
FA40   00                   BRK
FA41   00                   BRK
FA42   EA                   NOP
FA43   F9 25 00             SBC $0025,Y
FA46   74                   ???                ;%01110100 't'
FA47   00                   BRK
FA48   00                   BRK
FA49   01 00                ORA ($00,X)
FA4B   04                   ???                ;%00000100
FA4C   06 00                ASL $00
                            .END

