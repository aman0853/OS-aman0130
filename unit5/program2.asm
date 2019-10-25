.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
main: {
    jsr showpid
    jsr yield
    jsr showpid
    jsr yield
    jsr showpid
    jsr yield
    jsr showpid
    jsr yield
  __b1:
    jmp __b1
}
yield: {
    jsr enable_syscalls
    lda #0
    sta $d645
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
showpid: {
    jsr enable_syscalls
    lda #0
    sta $d646
    nop
    rts
}
