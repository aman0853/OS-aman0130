  .file [name="checkpoint3.2.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label COLS = $d800
  .const WHITE = 1
  .const JMP = $4c
  .const NOP = $ea
  .label current_screen_x = 7
  .label current_screen_line = 3
  .label current_screen_line_38 = 5
  .label current_screen_line_64 = 5
  .label current_screen_line_65 = 5
  .label current_screen_line_66 = 5
  .label current_screen_line_67 = 5
  .label current_screen_line_68 = 5
.segment Code
main: {
    rts
}
RESET: {
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
    lda #0
    sta.z current_screen_x
    lda #<$400
    sta.z current_screen_line_38
    lda #>$400
    sta.z current_screen_line_38+1
    lda #<message
    sta.z print_to_screen.message
    lda #>message
    sta.z print_to_screen.message+1
    jsr print_to_screen
    lda #<$400
    sta.z current_screen_line
    lda #>$400
    sta.z current_screen_line+1
    jsr print_newline
    lda.z current_screen_line
    sta.z current_screen_line_64
    lda.z current_screen_line+1
    sta.z current_screen_line_64+1
    lda #0
    sta.z current_screen_x
    lda #<message1
    sta.z print_to_screen.message
    lda #>message1
    sta.z print_to_screen.message+1
    jsr print_to_screen
    jsr print_newline
    jsr test_memory
    jsr exit_hypervisor
    rts
  .segment Data
    message: .text "aman0130 operating system starting.."
    .byte 0
    message1: .text "testing hardware"
    .byte 0
}
.segment Code
//system call Function 
exit_hypervisor: {
    // Trigger exit from Hypervisor mode 
    lda #1
    sta $d67f
    rts
}
test_memory: {
    .const mem_start = $800
    .label p = $c
    .label mem_end = $a
    .label mem_error = 2
    .label mem_end_10 = 8
    .label mem_end_12 = 8
    .label mem_end_15 = 8
    .label mem_end_19 = 8
    lda #<0
    sta.z p
    sta.z p+1
    sta.z current_screen_x
    sta.z mem_error
    lda #<$800
    sta.z mem_end
    lda #>$800
    sta.z mem_end+1
  b1:
    lda.z mem_end+1
    cmp #>$7fff
    bcc b18
    bne !+
    lda.z mem_end
    cmp #<$7fff
    bcc b18
  !:
  b3:
    jsr print_newline
    lda.z current_screen_line
    sta.z current_screen_line_67
    lda.z current_screen_line+1
    sta.z current_screen_line_67+1
    lda #0
    sta.z current_screen_x
    lda #<message
    sta.z print_to_screen.message
    lda #>message
    sta.z print_to_screen.message+1
    jsr print_to_screen
    lda #<mem_start
    sta.z print_hex.value
    lda #>mem_start
    sta.z print_hex.value+1
    jsr print_hex
    lda.z current_screen_line
    sta.z current_screen_line_68
    lda.z current_screen_line+1
    sta.z current_screen_line_68+1
    lda #<message1
    sta.z print_to_screen.message
    lda #>message1
    sta.z print_to_screen.message+1
    jsr print_to_screen
    lda.z mem_end
    sta.z print_hex.value
    lda.z mem_end+1
    sta.z print_hex.value+1
    jsr print_hex
    jsr print_newline
    jsr print_newline
    jsr print_newline
    rts
  b18:
    lda.z mem_error
    cmp #0
    bne b3
    lda.z mem_end
    sta.z mem_end_19
    lda.z mem_end+1
    sta.z mem_end_19+1
    ldx #0
  b4:
    cpx #$ff
    bcc b19
  b6:
    lda.z mem_end_10
    clc
    adc #1
    sta.z mem_end
    lda.z mem_end_10+1
    adc #0
    sta.z mem_end+1
    jmp b1
  b19:
    lda.z mem_error
    cmp #0
    bne b6
    txa
    ldy #0
    sta (mem_end),y
    txa
    cmp (mem_end),y
    beq b7
    lda.z current_screen_line
    sta.z current_screen_line_66
    lda.z current_screen_line+1
    sta.z current_screen_line_66+1
    lda #<message2
    sta.z print_to_screen.message
    lda #>message2
    sta.z print_to_screen.message+1
    jsr print_to_screen
    jsr print_newline
    lda.z mem_end_15
    bne !+
    dec.z mem_end_15+1
  !:
    dec.z mem_end_15
    jsr print_newline
    lda #0
    sta.z current_screen_x
    lda #1
    sta.z mem_error
  b7:
    inx
    jmp b4
  .segment Data
    message: .text "found memory from: "
    .byte 0
    message1: .text " - "
    .byte 0
    message2: .text "unsuccessful"
    .byte 0
}
.segment Code
print_newline: {
    lda #$28
    clc
    adc.z current_screen_line
    sta.z current_screen_line
    bcc !+
    inc.z current_screen_line+1
  !:
    rts
}
// print_to_screen(byte* zeropage($e) message)
print_to_screen: {
    .label message = $e
  b1:
    ldy #0
    lda (message),y
    cmp #0
    bne b2
    rts
  b2:
    ldy #0
    lda (message),y
    ldy.z current_screen_x
    sta (current_screen_line_38),y
    inc.z message
    bne !+
    inc.z message+1
  !:
    inc.z current_screen_x
    jmp b1
}
// print_hex(word zeropage(8) value)
print_hex: {
    .label _3 = $e
    .label _6 = $10
    .label value = 8
    ldx #0
  b1:
    cpx #4
    bcc b2
    lda #0
    sta hex+4
    lda.z current_screen_line
    sta.z current_screen_line_65
    lda.z current_screen_line+1
    sta.z current_screen_line_65+1
    lda #<hex
    sta.z print_to_screen.message
    lda #>hex
    sta.z print_to_screen.message+1
    jsr print_to_screen
    rts
  b2:
    lda.z value+1
    cmp #>$a000
    bcc b4
    bne !+
    lda.z value
    cmp #<$a000
    bcc b4
  !:
    ldy #$c
    lda.z value
    sta.z _3
    lda.z value+1
    sta.z _3+1
    cpy #0
    beq !e+
  !:
    lsr.z _3+1
    ror.z _3
    dey
    bne !-
  !e:
    lda.z _3
    sec
    sbc #9
    sta hex,x
  b5:
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    inx
    jmp b1
  b4:
    ldy #$c
    lda.z value
    sta.z _6
    lda.z value+1
    sta.z _6+1
    cpy #0
    beq !e+
  !:
    lsr.z _6+1
    ror.z _6
    dey
    bne !-
  !e:
    lda.z _6
    clc
    adc #'0'
    sta hex,x
    jmp b5
  .segment Data
    hex: .fill 5, 0
}
.segment Code
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage($e) str, byte register(X) c, word zeropage($a) num)
memset: {
    .label end = $a
    .label dst = $e
    .label num = $a
    .label str = $e
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
CPUKIL: {
    jsr exit_hypervisor
    rts
}
VF011WR: {
    jsr exit_hypervisor
    rts
}
VF011RD: {
    jsr exit_hypervisor
    rts
}
ALTTABKEY: {
    jsr exit_hypervisor
    rts
}
RESTOREKEY: {
    jsr exit_hypervisor
    rts
}
PAGFAULT: {
    jsr exit_hypervisor
    rts
}
undefined_trap: {
    jsr exit_hypervisor
    rts
}
syscall3F: {
    jsr exit_hypervisor
    rts
}
syscall3E: {
    jsr exit_hypervisor
    rts
}
syscall3D: {
    jsr exit_hypervisor
    rts
}
syscall3C: {
    jsr exit_hypervisor
    rts
}
syscall3B: {
    jsr exit_hypervisor
    rts
}
syscall3A: {
    jsr exit_hypervisor
    rts
}
syscall39: {
    jsr exit_hypervisor
    rts
}
syscall38: {
    jsr exit_hypervisor
    rts
}
syscall37: {
    jsr exit_hypervisor
    rts
}
syscall36: {
    jsr exit_hypervisor
    rts
}
syscall35: {
    jsr exit_hypervisor
    rts
}
syscall34: {
    jsr exit_hypervisor
    rts
}
syscall33: {
    jsr exit_hypervisor
    rts
}
syscall32: {
    jsr exit_hypervisor
    rts
}
syscall31: {
    jsr exit_hypervisor
    rts
}
syscall30: {
    jsr exit_hypervisor
    rts
}
syscall2F: {
    jsr exit_hypervisor
    rts
}
syscall2E: {
    jsr exit_hypervisor
    rts
}
syscall2D: {
    jsr exit_hypervisor
    rts
}
syscall2C: {
    jsr exit_hypervisor
    rts
}
syscall2B: {
    jsr exit_hypervisor
    rts
}
syscall2A: {
    jsr exit_hypervisor
    rts
}
syscall29: {
    jsr exit_hypervisor
    rts
}
syscall28: {
    jsr exit_hypervisor
    rts
}
syscall27: {
    jsr exit_hypervisor
    rts
}
syscall26: {
    jsr exit_hypervisor
    rts
}
syscall25: {
    jsr exit_hypervisor
    rts
}
syscall24: {
    jsr exit_hypervisor
    rts
}
syscall23: {
    jsr exit_hypervisor
    rts
}
syscall22: {
    jsr exit_hypervisor
    rts
}
syscall21: {
    jsr exit_hypervisor
    rts
}
syscall20: {
    jsr exit_hypervisor
    rts
}
syscall1F: {
    jsr exit_hypervisor
    rts
}
syscall1E: {
    jsr exit_hypervisor
    rts
}
syscall1D: {
    jsr exit_hypervisor
    rts
}
syscall1C: {
    jsr exit_hypervisor
    rts
}
syscall1B: {
    jsr exit_hypervisor
    rts
}
syscall1A: {
    jsr exit_hypervisor
    rts
}
syscall19: {
    jsr exit_hypervisor
    rts
}
syscall18: {
    jsr exit_hypervisor
    rts
}
syscall17: {
    jsr exit_hypervisor
    rts
}
syscall16: {
    jsr exit_hypervisor
    rts
}
syscall15: {
    jsr exit_hypervisor
    rts
}
syscall14: {
    jsr exit_hypervisor
    rts
}
syscall13: {
    jsr exit_hypervisor
    rts
}
syscallsecureexit: {
    jsr exit_hypervisor
    rts
}
syscallsecureentr: {
    jsr exit_hypervisor
    rts
}
syscall10: {
    jsr exit_hypervisor
    rts
}
syscall0F: {
    jsr exit_hypervisor
    rts
}
syscall0E: {
    jsr exit_hypervisor
    rts
}
syscall0D: {
    jsr exit_hypervisor
    rts
}
syscall0C: {
    jsr exit_hypervisor
    rts
}
syscall0B: {
    jsr exit_hypervisor
    rts
}
syscall0A: {
    jsr exit_hypervisor
    rts
}
syscall09: {
    jsr exit_hypervisor
    rts
}
syscall08: {
    jsr exit_hypervisor
    rts
}
syscall07: {
    jsr exit_hypervisor
    rts
}
syscall06: {
    jsr exit_hypervisor
    rts
}
syscall05: {
    jsr exit_hypervisor
    rts
}
syscall04: {
    jsr exit_hypervisor
    rts
}
syscall03: {
    jsr exit_hypervisor
    rts
}
syscall00: {
    jsr exit_hypervisor
    rts
}
syscall02: {
    lda #'('
    sta SCREEN+$4e
    jsr exit_hypervisor
    rts
}
syscall01: {
    lda #')'
    sta SCREEN+$4f
    jsr exit_hypervisor
    rts
}
.segment Syscall
SYSCALLS:
  .byte JMP
  .word syscall00
  .byte NOP
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
  .word syscallsecureentr
  .byte NOP
  .byte JMP
  .word syscallsecureexit
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
TRAPS:
  .byte JMP
  .word RESET
  .byte NOP
  .byte JMP
  .word PAGFAULT
  .byte NOP
  .byte JMP
  .word RESTOREKEY
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
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word CPUKIL
  .byte NOP
