.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
main: {
    jsr fork
    cmp #0
    bne __b1
    jsr exec
  __b3:
    jsr yield
    jmp __b3
  __b1:
    jsr showpid
    jmp __b3
}
showpid: {
    jsr enable_syscalls
    lda #0
    sta $d646
    nop
    rts
}
enable_syscalls: {
    lda #$47
    sta $d02f
    lda #$53
    sta $d02f
    rts
}
yield: {
    jsr enable_syscalls
    lda #0
    sta $d645
    nop
    rts
}
exec: {
    jsr enable_syscalls
    lda #0
    sta $d648
    nop
    rts
}
fork: {
    jsr enable_syscalls
    lda #0
    sta $d647
    nop
    lda $300
    rts
}
