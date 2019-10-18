  .file [name="checkpoint2.2.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  .label RASTER = $d012
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label BGCOL = $d021
  .label COLS = $d800
  .const BLACK = 0
  .const WHITE = 1
  .const JMP = $4c
  .const NOP = $ea
.segment Code
main: {
    .label sc = 4
    .label msg = 2
    lda #$14
    sta VIC_MEMORY
    ldx #' '
    lda #<SCREEN
    sta.z memset.str
    lda #>SCREEN
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    ldx #WHITE
    lda #<COLS
    sta.z memset.str
    lda #>COLS
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    lda #<SCREEN+$28
    sta.z sc
    lda #>SCREEN+$28
    sta.z sc+1
    lda #<MESSAGE
    sta.z msg
    lda #>MESSAGE
    sta.z msg+1
  b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne b2
  b3:
    lda #$36
    cmp RASTER
    beq b4
    lda #$41
    cmp RASTER
    beq b4
    lda #BLACK
    sta BGCOL
    jmp b3
  b4:
    lda #WHITE
    sta BGCOL
    jmp b3
  b2:
    ldy #0
    lda (msg),y
    sta (sc),y
    inc.z sc
    bne !+
    inc.z sc+1
  !:
    inc.z msg
    bne !+
    inc.z msg+1
  !:
    jmp b1
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage(4) str, byte register(X) c, word zeropage(2) num)
memset: {
    .label end = 2
    .label dst = 4
    .label num = 2
    .label str = 4
    lda.z num
    bne !+
    lda.z num+1
    beq breturn
  !:
    lda.z end
    clc
    adc.z str
    sta.z end
    lda.z end+1
    adc.z str+1
    sta.z end+1
  b2:
    lda.z dst+1
    cmp.z end+1
    bne b3
    lda.z dst
    cmp.z end
    bne b3
  breturn:
    rts
  b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp b2
}
RESERVED: {
    rts
}
VF011WR: {
    rts
}
VF011RD: {
    rts
}
ALTTABKEY: {
    rts
}
RESTORKEY: {
    rts
}
PAGFAULT: {
    rts
}
RESET: {
    rts
}
syscall3F: {
    rts
}
syscall3E: {
    rts
}
syscall3D: {
    rts
}
syscall3C: {
    rts
}
syscall3B: {
    rts
}
syscall3A: {
    rts
}
syscall39: {
    rts
}
syscall38: {
    rts
}
syscall37: {
    rts
}
syscall36: {
    rts
}
syscall35: {
    rts
}
syscall34: {
    rts
}
syscall33: {
    rts
}
syscall32: {
    rts
}
syscall31: {
    rts
}
syscall30: {
    rts
}
syscall2F: {
    rts
}
syscall2E: {
    rts
}
syscall2D: {
    rts
}
syscall2C: {
    rts
}
syscall2B: {
    rts
}
syscall2A: {
    rts
}
syscall29: {
    rts
}
syscall28: {
    rts
}
syscall27: {
    rts
}
syscall26: {
    rts
}
syscall25: {
    rts
}
syscall24: {
    rts
}
syscall23: {
    rts
}
syscall22: {
    rts
}
syscall21: {
    rts
}
syscall20: {
    rts
}
syscall1F: {
    rts
}
syscall1E: {
    rts
}
syscall1D: {
    rts
}
syscall1C: {
    rts
}
syscall1B: {
    rts
}
syscall1A: {
    rts
}
syscall19: {
    rts
}
syscall18: {
    rts
}
syscall17: {
    rts
}
syscall16: {
    rts
}
syscall15: {
    rts
}
syscall14: {
    rts
}
syscall13: {
    rts
}
SECUREXIT: {
    rts
}
SECURENTR: {
    rts
}
syscall10: {
    rts
}
syscall0F: {
    rts
}
syscall0E: {
    rts
}
syscall0D: {
    rts
}
syscall0C: {
    rts
}
syscall0B: {
    rts
}
syscall0A: {
    rts
}
syscall09: {
    rts
}
syscall08: {
    rts
}
syscall07: {
    rts
}
syscall06: {
    rts
}
syscall05: {
    rts
}
syscall04: {
    rts
}
syscall03: {
    rts
}
syscall02: {
    lda #'<'
    sta SCREEN+$4e
    rts
}
syscall01: {
    lda #'>'
    sta SCREEN+$4f
    rts
}
.segment Data
  MESSAGE: .text "checkpoint 2.2 by aman0130"
  .byte 0
.segment Syscall
SYSCALLS:
  .byte JMP
  .word syscall01
  .byte NOP
  .byte JMP
  .word syscall02
  .byte NOP
  .byte JMP
  .word syscall03
  .byte NOP
  .byte JMP
  .word syscall04
  .byte NOP
  .byte JMP
  .word syscall05
  .byte NOP
  .byte JMP
  .word syscall06
  .byte NOP
  .byte JMP
  .word syscall07
  .byte NOP
  .byte JMP
  .word syscall08
  .byte NOP
  .byte JMP
  .word syscall09
  .byte NOP
  .byte JMP
  .word syscall0A
  .byte NOP
  .byte JMP
  .word syscall0B
  .byte NOP
  .byte JMP
  .word syscall0C
  .byte NOP
  .byte JMP
  .word syscall0D
  .byte NOP
  .byte JMP
  .word syscall0E
  .byte NOP
  .byte JMP
  .word syscall0F
  .byte NOP
  .byte JMP
  .word syscall10
  .byte NOP
  .byte JMP
  .word SECURENTR
  .byte NOP
  .byte JMP
  .word SECUREXIT
  .byte NOP
  .byte JMP
  .word syscall13
  .byte NOP
  .byte JMP
  .word syscall14
  .byte NOP
  .byte JMP
  .word syscall15
  .byte NOP
  .byte JMP
  .word syscall16
  .byte NOP
  .byte JMP
  .word syscall17
  .byte NOP
  .byte JMP
  .word syscall18
  .byte NOP
  .byte JMP
  .word syscall19
  .byte NOP
  .byte JMP
  .word syscall1A
  .byte NOP
  .byte JMP
  .word syscall1B
  .byte NOP
  .byte JMP
  .word syscall1C
  .byte NOP
  .byte JMP
  .word syscall1D
  .byte NOP
  .byte JMP
  .word syscall1E
  .byte NOP
  .byte JMP
  .word syscall1F
  .byte NOP
  .byte JMP
  .word syscall20
  .byte NOP
  .byte JMP
  .word syscall21
  .byte NOP
  .byte JMP
  .word syscall22
  .byte NOP
  .byte JMP
  .word syscall23
  .byte NOP
  .byte JMP
  .word syscall24
  .byte NOP
  .byte JMP
  .word syscall25
  .byte NOP
  .byte JMP
  .word syscall26
  .byte NOP
  .byte JMP
  .word syscall27
  .byte NOP
  .byte JMP
  .word syscall28
  .byte NOP
  .byte JMP
  .word syscall29
  .byte NOP
  .byte JMP
  .word syscall2A
  .byte NOP
  .byte JMP
  .word syscall2B
  .byte NOP
  .byte JMP
  .word syscall2C
  .byte NOP
  .byte JMP
  .word syscall2D
  .byte NOP
  .byte JMP
  .word syscall2E
  .byte NOP
  .byte JMP
  .word syscall2F
  .byte NOP
  .byte JMP
  .word syscall30
  .byte NOP
  .byte JMP
  .word syscall31
  .byte NOP
  .byte JMP
  .word syscall32
  .byte NOP
  .byte JMP
  .word syscall33
  .byte NOP
  .byte JMP
  .word syscall34
  .byte NOP
  .byte JMP
  .word syscall35
  .byte NOP
  .byte JMP
  .word syscall36
  .byte NOP
  .byte JMP
  .word syscall37
  .byte NOP
  .byte JMP
  .word syscall38
  .byte NOP
  .byte JMP
  .word syscall39
  .byte NOP
  .byte JMP
  .word syscall3A
  .byte NOP
  .byte JMP
  .word syscall3B
  .byte NOP
  .byte JMP
  .word syscall3C
  .byte NOP
  .byte JMP
  .word syscall3D
  .byte NOP
  .byte JMP
  .word syscall3E
  .byte NOP
  .byte JMP
  .word syscall3F
  .byte NOP
  .align $100
SYSCALL_TRAPS:
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word RESET
  .byte NOP
  .byte JMP
  .word PAGFAULT
  .byte NOP
  .byte JMP
  .word RESTORKEY
  .byte NOP
  .byte JMP
  .word ALTTABKEY
  .byte NOP
  .byte JMP
  .word VF011RD
  .byte NOP
  .byte JMP
  .word VF011WR
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
