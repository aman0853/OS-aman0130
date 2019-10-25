// XMega65 Kernal Development Template
// Each function of the kernal is a no-args function
// The functions are placed in the SYSCALLS table surrounded by JMP and NOP
  .file [name="os5.3.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  .const SIZEOF_WORD = 2
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE = 1
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME = 2
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS = 4
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS = 8
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE = $c
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label COLS = $d800
  .const WHITE = 1
  .const STATE_NOTRUNNING = 0
  .const STATE_NEW = 1
  .const STATE_READY = 2
  .const STATE_READYSUSPENDED = 3
  .const STATE_BLOCKEDSUSPENDED = 4
  .const STATE_BLOCKED = 5
  .const STATE_RUNNING = 6
  .const STATE_EXIT = 7
  // Process stored state will live at $C000-$C7FF, with 256 bytes
  // for each process reserved
  .label stored_pdbs = $c000
  // 8 processes x 16 bytes = 128 bytes for names
  .label process_names = $c800
  // 8 processes x 64 bytes context state = 512 bytes
  .label process_context_states = $c900
  .const JMP = $4c
  .const NOP = $ea
  .label running_pdb = $2a
  .label pid_counter = $2b
  .label lpeek_value = $2c
  .label current_screen_line = $b
  .label current_screen_x = $d
  // Which is the current running process?
  lda #$ff
  sta.z running_pdb
  // Counter for helping determine the next available proccess ID.
  lda #0
  sta.z pid_counter
  lda #$12
  sta.z lpeek_value
  lda #<SCREEN
  sta.z current_screen_line
  lda #>SCREEN
  sta.z current_screen_line+1
  lda #0
  sta.z current_screen_x
  jsr main
  rts
.segment Code
main: {
    rts
}
//XXX - Copy your RESET() routine from os5.2.kc
reset: {
    .label sc = $2d
    .label msg = $4c
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
    lda #<$400
    sta.z current_screen_line
    lda #>$400
    sta.z current_screen_line+1
    lda #0
    sta.z current_screen_x
    lda #<SCREEN+$28
    sta.z sc
    lda #>SCREEN+$28
    sta.z sc+1
    lda #<MESSAGE
    sta.z msg
    lda #>MESSAGE
    sta.z msg+1
  __b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne __b2
    lda #<SCREEN
    sta.z current_screen_line
    lda #>SCREEN
    sta.z current_screen_line+1
    jsr print_newline
    jsr print_newline
    jsr print_newline
    jsr initialise_pdb
    jsr load_program
    jsr resume_pdb
    rts
  __b2:
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
    jmp __b1
  .segment Data
    name: .text "program1.prg"
    .byte 0
}
.segment Code
resume_pdb: {
    .const pdb_number = 0
    .label p = stored_pdbs
    .label __7 = $43
    .label ss = $2d
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta.z dma_copy.src
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    sta.z dma_copy.src+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    sta.z dma_copy.src+2
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    sta.z dma_copy.src+3
    lda #0
    sta.z dma_copy.dest
    sta.z dma_copy.dest+1
    sta.z dma_copy.dest+2
    sta.z dma_copy.dest+3
    lda #<$400
    sta.z dma_copy.length
    lda #>$400
    sta.z dma_copy.length+1
    jsr dma_copy
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta.z __7
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    sta.z __7+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    sta.z __7+2
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    sta.z __7+3
    lda.z dma_copy.src
    clc
    adc #<$800
    sta.z dma_copy.src
    lda.z dma_copy.src+1
    adc #>$800
    sta.z dma_copy.src+1
    lda.z dma_copy.src+2
    adc #0
    sta.z dma_copy.src+2
    lda.z dma_copy.src+3
    adc #0
    sta.z dma_copy.src+3
    lda #<$800
    sta.z dma_copy.dest
    lda #>$800
    sta.z dma_copy.dest+1
    lda #<$800>>$10
    sta.z dma_copy.dest+2
    lda #>$800>>$10
    sta.z dma_copy.dest+3
    lda #<$1800
    sta.z dma_copy.length
    lda #>$1800
    sta.z dma_copy.length+1
    jsr dma_copy
    // Load stored CPU state into Hypervisor saved register area at $FFD3640
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    sta.z ss
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE+1
    sta.z ss+1
    ldy #0
  //XXX - Use a for() loop to copy 63 bytes from ss[0]--ss[62] to ((unsigned char *)$D640)[0]
  //      -- ((unsigned char *)$D640)[62] (dma_copy doesn't work for this for some slightly
  //      complex reasons.)
  __b1:
    cpy #$3f
    bcc __b2
    // Set state of process to running
    //XXX - Set p->process_state to STATE_RUNNING
    lda #STATE_RUNNING
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    // Mark this PDB as the running process
    //XXX - Set running_pdb to the PDB number we are resuming
    lda #pdb_number
    sta.z running_pdb
    jsr exit_hypervisor
    rts
  __b2:
    lda (ss),y
    sta $d640,y
    iny
    jmp __b1
}
exit_hypervisor: {
    // Exit hypervisor
    lda #1
    sta $d67f
    rts
}
// dma_copy(dword zeropage($43) src, dword zeropage(2) dest, word zeropage($4c) length)
dma_copy: {
    .label __0 = $2f
    .label __2 = $33
    .label __4 = $4a
    .label __5 = $37
    .label __7 = $3b
    .label __9 = $48
    .label src = $43
    .label list_request_format0a = $14
    .label list_source_mb_option80 = $15
    .label list_source_mb = $16
    .label list_dest_mb_option81 = $17
    .label list_dest_mb = $18
    .label list_end_of_options00 = $19
    .label list_cmd = $1a
    .label list_size = $1b
    .label list_source_addr = $1d
    .label list_source_bank = $1f
    .label list_dest_addr = $20
    .label list_dest_bank = $22
    .label list_modulo00 = $23
    .label dest = 2
    .label length = $4c
    lda #0
    sta.z list_request_format0a
    sta.z list_source_mb_option80
    sta.z list_source_mb
    sta.z list_dest_mb_option81
    sta.z list_dest_mb
    sta.z list_end_of_options00
    sta.z list_cmd
    sta.z list_size
    sta.z list_size+1
    sta.z list_source_addr
    sta.z list_source_addr+1
    sta.z list_source_bank
    sta.z list_dest_addr
    sta.z list_dest_addr+1
    sta.z list_dest_bank
    sta.z list_modulo00
    lda #$a
    sta.z list_request_format0a
    lda #$80
    sta.z list_source_mb_option80
    lda #$81
    sta.z list_dest_mb_option81
    lda #0
    sta.z list_end_of_options00
    sta.z list_cmd
    sta.z list_modulo00
    lda.z length
    sta.z list_size
    lda.z length+1
    sta.z list_size+1
    ldx #$14
    lda.z dest
    sta.z __0
    lda.z dest+1
    sta.z __0+1
    lda.z dest+2
    sta.z __0+2
    lda.z dest+3
    sta.z __0+3
    cpx #0
    beq !e+
  !:
    lsr.z __0+3
    ror.z __0+2
    ror.z __0+1
    ror.z __0
    dex
    bne !-
  !e:
    lda.z __0
    sta.z list_dest_mb
    lda #0
    sta.z __2+2
    sta.z __2+3
    lda.z dest+3
    sta.z __2+1
    lda.z dest+2
    sta.z __2
    lda #$7f
    and.z __2
    sta.z list_dest_bank
    lda.z dest
    sta.z __4
    lda.z dest+1
    sta.z __4+1
    lda.z __4
    sta.z list_dest_addr
    lda.z __4+1
    sta.z list_dest_addr+1
    ldx #$14
    lda.z src
    sta.z __5
    lda.z src+1
    sta.z __5+1
    lda.z src+2
    sta.z __5+2
    lda.z src+3
    sta.z __5+3
    cpx #0
    beq !e+
  !:
    lsr.z __5+3
    ror.z __5+2
    ror.z __5+1
    ror.z __5
    dex
    bne !-
  !e:
    lda.z __5
    // Work around missing fragments in KickC
    sta.z list_source_mb
    lda #0
    sta.z __7+2
    sta.z __7+3
    lda.z src+3
    sta.z __7+1
    lda.z src+2
    sta.z __7
    lda #$7f
    and.z __7
    sta.z list_source_bank
    lda.z src
    sta.z __9
    lda.z src+1
    sta.z __9+1
    lda.z __9
    sta.z list_source_addr
    lda.z __9+1
    sta.z list_source_addr+1
    // DMA list lives in hypervisor memory, so use correct list address
    // when triggering
    // (Variables in KickC usually end up in ZP, so we have to provide the
    // base page correction
    lda #0
    cmp #>list_request_format0a
    beq __b1
    lda #>list_request_format0a
    sta $d701
  __b2:
    lda #$7f
    sta $d702
    lda #$ff
    sta $d704
    lda #<list_request_format0a
    sta $d705
    rts
  __b1:
    lda #$bf+(>list_request_format0a)
    sta $d701
    jmp __b2
}
load_program: {
    .label pdb = stored_pdbs
    .label __30 = $43
    .label __31 = $43
    .label __34 = 6
    .label __35 = 6
    .label n = $4a
    .label c2 = $47
    .label new_address = $3f
    .label address = 6
    .label length = $28
    .label dest = 2
    .label match = $a
    lda #0
    sta.z match
    lda #<$20000
    sta.z address
    lda #>$20000
    sta.z address+1
    lda #<$20000>>$10
    sta.z address+2
    lda #>$20000>>$10
    sta.z address+3
  __b1:
    lda.z address
    sta.z lpeek.address
    lda.z address+1
    sta.z lpeek.address+1
    lda.z address+2
    sta.z lpeek.address+2
    lda.z address+3
    sta.z lpeek.address+3
    jsr lpeek
    txa
    cmp #0
    bne b1
    rts
  // Check for name match
  b1:
    ldy #0
  __b2:
    cpy #$10
    bcs !__b3+
    jmp __b3
  !__b3:
    jmp __b5
  b3:
    lda #1
    sta.z match
  __b5:
    lda #0
    cmp.z match
    bne !__b8+
    jmp __b8
  !__b8:
    // Found program -- now copy it into place
    sta.z length
    sta.z length+1
    lda #$10
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z length
    lda #0
    sta.z length+1
    lda #$11
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    stx length+1
    // Copy program into place.
    // As the program is formatted as a C64 program with a 
    // $0801 header, we copy it to offset $07FF.
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta.z dest
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    sta.z dest+1
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    sta.z dest+2
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    sta.z dest+3
    lda.z dest
    clc
    adc #<$7ff
    sta.z dest
    lda.z dest+1
    adc #>$7ff
    sta.z dest+1
    lda.z dest+2
    adc #0
    sta.z dest+2
    lda.z dest+3
    adc #0
    sta.z dest+3
    lda #$20
    clc
    adc.z address
    sta.z dma_copy.src
    lda.z address+1
    adc #0
    sta.z dma_copy.src+1
    lda.z address+2
    adc #0
    sta.z dma_copy.src+2
    lda.z address+3
    adc #0
    sta.z dma_copy.src+3
    lda.z length
    sta.z dma_copy.length
    txa
    sta.z dma_copy.length+1
    jsr dma_copy
    // Mark process as now runnable
    lda #STATE_READY
    sta pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    rts
  __b8:
    lda #$12
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z new_address
    lda #0
    sta.z new_address+1
    sta.z new_address+2
    sta.z new_address+3
    lda #$13
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z __30
    lda #0
    sta.z __30+1
    sta.z __30+2
    sta.z __30+3
    lda.z __31+2
    sta.z __31+3
    lda.z __31+1
    sta.z __31+2
    lda.z __31
    sta.z __31+1
    lda #0
    sta.z __31
    ora.z new_address
    sta.z new_address
    lda.z __31+1
    ora.z new_address+1
    sta.z new_address+1
    lda.z __31+2
    ora.z new_address+2
    sta.z new_address+2
    lda.z __31+3
    ora.z new_address+3
    sta.z new_address+3
    lda #$14
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z __34
    lda #0
    sta.z __34+1
    sta.z __34+2
    sta.z __34+3
    lda.z __35+1
    sta.z __35+3
    lda.z __35
    sta.z __35+2
    lda #0
    sta.z __35
    sta.z __35+1
    lda.z new_address
    ora.z address
    sta.z address
    lda.z new_address+1
    ora.z address+1
    sta.z address+1
    lda.z new_address+2
    ora.z address+2
    sta.z address+2
    lda.z new_address+3
    ora.z address+3
    sta.z address+3
    jmp __b1
  __b3:
    tya
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    sta.z n
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME+1
    sta.z n+1
    lda (n),y
    sta.z c2
    cpx #0
    bne __b4
    cmp #0
    bne !b3+
    jmp b3
  !b3:
  __b4:
    cpx.z c2
    beq __b6
    jmp __b5
  __b6:
    iny
    jmp __b2
}
// lpeek(dword zeropage($43) address)
lpeek: {
    .label t = $24
    .label address = $43
    // Work around all sorts of fun problems in KickC
    //  dma_copy(address,$BF00+((unsigned short)<&lpeek_value),1);  
    lda #<lpeek_value
    sta.z t
    lda #>lpeek_value
    sta.z t+1
    lda #<lpeek_value>>$10
    sta.z t+2
    lda #>lpeek_value>>$10
    sta.z t+3
    lda #0
    cmp #>lpeek_value
    bne __b1
    lda.z t
    clc
    adc #<$fffbf00
    sta.z t
    lda.z t+1
    adc #>$fffbf00
    sta.z t+1
    lda.z t+2
    adc #<$fffbf00>>$10
    sta.z t+2
    lda.z t+3
    adc #>$fffbf00>>$10
    sta.z t+3
  __b2:
    lda.z t
    sta.z dma_copy.dest
    lda.z t+1
    sta.z dma_copy.dest+1
    lda.z t+2
    sta.z dma_copy.dest+2
    lda.z t+3
    sta.z dma_copy.dest+3
    lda #<1
    sta.z dma_copy.length
    lda #>1
    sta.z dma_copy.length+1
    jsr dma_copy
    ldx.z lpeek_value
    rts
  __b1:
    lda.z t
    clc
    adc #<$fff0000
    sta.z t
    lda.z t+1
    adc #>$fff0000
    sta.z t+1
    lda.z t+2
    adc #<$fff0000>>$10
    sta.z t+2
    lda.z t+3
    adc #>$fff0000>>$10
    sta.z t+3
    jmp __b2
}
// Setup a new process descriptor block
initialise_pdb: {
    .label p = stored_pdbs
    .label pn = $48
    .label i1 = $2d
    .label ss = $4e
    .label __32 = $4a
    .label __33 = $4c
    jsr next_free_pid
    lda.z next_free_pid.pid
    sta p
    lda #<process_names
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda #>process_names
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    sta.z pn
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME+1
    sta.z pn+1
    lda #<0
    sta.z i1
    sta.z i1+1
  __b1:
    lda.z i1+1
    bmi __b2
    cmp #>$11
    bcc __b2
    bne !+
    lda.z i1
    cmp #<$11
    bcc __b2
  !:
    lda #STATE_NOTRUNNING
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    lda #<$30000
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda #>$30000
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    lda #<$30000>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    lda #>$30000>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    lda #<$31fff
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS
    lda #>$31fff
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+1
    lda #<$31fff>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+2
    lda #>$31fff>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+3
    lda #<process_context_states
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda #>process_context_states
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    sta.z ss
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE+1
    sta.z ss+1
    ldy #0
  __b4:
    cpy #$3f
    bcc __b5
    lda #$24
    ldy #7
    sta (ss),y
    ldy #5
    lda #<$1ff
    sta (ss),y
    iny
    lda #>$1ff
    sta (ss),y
    ldy #8
    lda #<$80d
    sta (ss),y
    iny
    lda #>$80d
    sta (ss),y
    rts
  __b5:
    lda #0
    sta (ss),y
    iny
    jmp __b4
  __b2:
    lda #<reset.name
    clc
    adc.z i1
    sta.z __32
    lda #>reset.name
    adc.z i1+1
    sta.z __32+1
    lda.z pn
    clc
    adc.z i1
    sta.z __33
    lda.z pn+1
    adc.z i1+1
    sta.z __33+1
    ldy #0
    lda (__32),y
    sta (__33),y
    inc.z i1
    bne !+
    inc.z i1+1
  !:
    jmp __b1
}
next_free_pid: {
    .label __2 = $4e
    .label pid = $a
    .label p = $4e
    .label i = $4c
    inc.z pid_counter
    // Start with the next process ID
    lda.z pid_counter
    sta.z pid
    ldx #1
  __b1:
    cpx #0
    bne b1
    rts
  b1:
    ldx #0
    txa
    sta.z i
    sta.z i+1
  __b2:
    lda.z i+1
    cmp #>8
    bcc __b3
    bne !+
    lda.z i
    cmp #<8
    bcc __b3
  !:
    jmp __b1
  __b3:
    lda.z i
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    ldy #0
    lda (p),y
    cmp.z pid
    bne __b4
    inc.z pid
    ldx #1
  __b4:
    inc.z i
    bne !+
    inc.z i+1
  !:
    jmp __b2
}
print_newline: {
    lda #$28
    clc
    adc.z current_screen_line
    sta.z current_screen_line
    bcc !+
    inc.z current_screen_line+1
  !:
    lda #0
    sta.z current_screen_x
    rts
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage($2d) str, byte register(X) c, word zeropage($4c) num)
memset: {
    .label end = $4c
    .label dst = $2d
    .label num = $4c
    .label str = $2d
    lda.z num
    bne !+
    lda.z num+1
    beq __breturn
  !:
    lda.z end
    clc
    adc.z str
    sta.z end
    lda.z end+1
    adc.z str+1
    sta.z end+1
  __b2:
    lda.z dst+1
    cmp.z end+1
    bne __b3
    lda.z dst
    cmp.z end
    bne __b3
  __breturn:
    rts
  __b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp __b2
}
syscall63: {
    jsr exit_hypervisor
    rts
}
syscall62: {
    jsr exit_hypervisor
    rts
}
syscall61: {
    jsr exit_hypervisor
    rts
}
syscall60: {
    jsr exit_hypervisor
    rts
}
syscall59: {
    jsr exit_hypervisor
    rts
}
syscall58: {
    jsr exit_hypervisor
    rts
}
syscall57: {
    jsr exit_hypervisor
    rts
}
syscall56: {
    jsr exit_hypervisor
    rts
}
syscall55: {
    jsr exit_hypervisor
    rts
}
syscall54: {
    jsr exit_hypervisor
    rts
}
syscall53: {
    jsr exit_hypervisor
    rts
}
syscall52: {
    jsr exit_hypervisor
    rts
}
syscall51: {
    jsr exit_hypervisor
    rts
}
syscall50: {
    jsr exit_hypervisor
    rts
}
syscall49: {
    jsr exit_hypervisor
    rts
}
syscall48: {
    jsr exit_hypervisor
    rts
}
syscall47: {
    jsr exit_hypervisor
    rts
}
syscall46: {
    jsr exit_hypervisor
    rts
}
syscall45: {
    jsr exit_hypervisor
    rts
}
syscall44: {
    jsr exit_hypervisor
    rts
}
syscall43: {
    jsr exit_hypervisor
    rts
}
syscall42: {
    jsr exit_hypervisor
    rts
}
syscall41: {
    jsr exit_hypervisor
    rts
}
syscall40: {
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
syscall19: {
    jsr exit_hypervisor
    rts
}
securexit: {
    jsr exit_hypervisor
    rts
}
securentr: {
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
syscall12: {
    jsr exit_hypervisor
    rts
}
syscall11: {
    jsr exit_hypervisor
    rts
}
syscall10: {
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
    ldx.z running_pdb
    jsr describe_pdb
    jsr exit_hypervisor
    rts
}
// describe_pdb(byte register(X) pdb_number)
describe_pdb: {
    .label __1 = $50
    .label __2 = $50
    .label p = $50
    .label n = $52
    .label ss = $e
    txa
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    lda #<message
    sta.z print_to_screen.c
    lda #>message
    sta.z print_to_screen.c+1
    jsr print_to_screen
    txa
    sta.z print_hex.value
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
    lda #<message1
    sta.z print_to_screen.c
    lda #>message1
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jsr print_newline
    lda #<message2
    sta.z print_to_screen.c
    lda #>message2
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #0
    lda (p),y
    sta.z print_hex.value
    iny
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
    jsr print_newline
    lda #<message3
    sta.z print_to_screen.c
    lda #>message3
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    lda (p),y
    cmp #STATE_NEW
    bne !__b7+
    jmp __b7
  !__b7:
    lda (p),y
    cmp #STATE_RUNNING
    bne !__b8+
    jmp __b8
  !__b8:
    lda (p),y
    cmp #STATE_BLOCKED
    bne !__b9+
    jmp __b9
  !__b9:
    lda (p),y
    cmp #STATE_READY
    bne !__b10+
    jmp __b10
  !__b10:
    lda (p),y
    cmp #STATE_BLOCKEDSUSPENDED
    bne !__b11+
    jmp __b11
  !__b11:
    lda (p),y
    cmp #STATE_READYSUSPENDED
    bne !__b12+
    jmp __b12
  !__b12:
    lda (p),y
    cmp #STATE_EXIT
    bne !__b13+
    jmp __b13
  !__b13:
    lda (p),y
    sta.z print_hex.value
    iny
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
  __b15:
    jsr print_newline
    lda #<message11
    sta.z print_to_screen.c
    lda #>message11
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda (p),y
    sta.z n
    iny
    lda (p),y
    sta.z n+1
    ldx #0
  __b16:
    txa
    tay
    lda (n),y
    cmp #0
    bne __b17
    jsr print_newline
    lda #<message12
    sta.z print_to_screen.c
    lda #>message12
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda (p),y
    sta.z print_dhex.value
    iny
    lda (p),y
    sta.z print_dhex.value+1
    iny
    lda (p),y
    sta.z print_dhex.value+2
    iny
    lda (p),y
    sta.z print_dhex.value+3
    jsr print_dhex
    jsr print_newline
    lda #<message13
    sta.z print_to_screen.c
    lda #>message13
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS
    lda (p),y
    sta.z print_dhex.value
    iny
    lda (p),y
    sta.z print_dhex.value+1
    iny
    lda (p),y
    sta.z print_dhex.value+2
    iny
    lda (p),y
    sta.z print_dhex.value+3
    jsr print_dhex
    jsr print_newline
    lda #<message14
    sta.z print_to_screen.c
    lda #>message14
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda (p),y
    sta.z ss
    iny
    lda (p),y
    sta.z ss+1
    ldy #4*SIZEOF_WORD
    lda (print_hex.value),y
    pha
    iny
    lda (print_hex.value),y
    sta.z print_hex.value+1
    pla
    sta.z print_hex.value
    jsr print_hex
    jsr print_newline
    rts
  __b17:
    txa
    tay
    lda (n),y
    jsr print_char
    inx
    jmp __b16
  __b13:
    lda #<message10
    sta.z print_to_screen.c
    lda #>message10
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b12:
    lda #<message9
    sta.z print_to_screen.c
    lda #>message9
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b11:
    lda #<message8
    sta.z print_to_screen.c
    lda #>message8
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b10:
    lda #<message7
    sta.z print_to_screen.c
    lda #>message7
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b9:
    lda #<message6
    sta.z print_to_screen.c
    lda #>message6
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b8:
    lda #<message5
    sta.z print_to_screen.c
    lda #>message5
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b7:
    lda #<message4
    sta.z print_to_screen.c
    lda #>message4
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  .segment Data
    message: .text "pdb#"
    .byte 0
    message1: .text ":"
    .byte 0
    message2: .text "  pid:          "
    .byte 0
    message3: .text "  state:        "
    .byte 0
    message4: .text "new"
    .byte 0
    message5: .text "running"
    .byte 0
    message6: .text "blocked"
    .byte 0
    message7: .text "ready"
    .byte 0
    message8: .text "blockedsuspended"
    .byte 0
    message9: .text "readysuspended"
    .byte 0
    message10: .text "exit"
    .byte 0
    message11: .text "  process name: "
    .byte 0
    message12: .text "  mem start:    $"
    .byte 0
    message13: .text "  mem end:      $"
    .byte 0
    message14: .text "  pc:           $"
    .byte 0
}
.segment Code
print_to_screen: {
    .label c = $e
  __b1:
    ldy #0
    lda (c),y
    cmp #0
    bne __b2
    rts
  __b2:
    ldy #0
    lda (c),y
    ldy.z current_screen_x
    sta (current_screen_line),y
    inc.z current_screen_x
    inc.z c
    bne !+
    inc.z c+1
  !:
    jmp __b1
}
// print_char(byte register(A) c)
print_char: {
    ldy.z current_screen_x
    sta (current_screen_line),y
    inc.z current_screen_x
    rts
}
// print_hex(word zeropage($e) value)
print_hex: {
    .label __3 = $52
    .label __6 = $54
    .label value = $e
    ldx #0
  __b1:
    cpx #8
    bcc __b2
    lda #0
    sta hex+4
    lda #<hex
    sta.z print_to_screen.c
    lda #>hex
    sta.z print_to_screen.c+1
    jsr print_to_screen
    rts
  __b2:
    lda.z value+1
    cmp #>$a000
    bcc __b4
    bne !+
    lda.z value
    cmp #<$a000
    bcc __b4
  !:
    ldy #$c
    lda.z value
    sta.z __3
    lda.z value+1
    sta.z __3+1
    cpy #0
    beq !e+
  !:
    lsr.z __3+1
    ror.z __3
    dey
    bne !-
  !e:
    lda.z __3
    sec
    sbc #9
    sta hex,x
  __b5:
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    inx
    jmp __b1
  __b4:
    ldy #$c
    lda.z value
    sta.z __6
    lda.z value+1
    sta.z __6+1
    cpy #0
    beq !e+
  !:
    lsr.z __6+1
    ror.z __6
    dey
    bne !-
  !e:
    lda.z __6
    clc
    adc #'0'
    sta hex,x
    jmp __b5
  .segment Data
    hex: .fill 5, 0
}
.segment Code
// print_dhex(dword zeropage($10) value)
print_dhex: {
    .label __0 = $56
    .label value = $10
    lda #0
    sta.z __0+2
    sta.z __0+3
    lda.z value+3
    sta.z __0+1
    lda.z value+2
    sta.z __0
    sta.z print_hex.value
    lda.z __0+1
    sta.z print_hex.value+1
    jsr print_hex
    lda.z value
    sta.z print_hex.value
    lda.z value+1
    sta.z print_hex.value+1
    jsr print_hex
    rts
}
syscall02: {
    jsr exit_hypervisor
    rts
}
syscall01: {
    jsr exit_hypervisor
    rts
}
syscall00: {
    jsr exit_hypervisor
    rts
}
cpukil: {
    jsr exit_hypervisor
    rts
}
undefined_trap: {
    jsr exit_hypervisor
    rts
}
vf011wr: {
    jsr exit_hypervisor
    rts
}
vf011rd: {
    jsr exit_hypervisor
    rts
}
alttabkey: {
    jsr exit_hypervisor
    rts
}
restorkey: {
    jsr exit_hypervisor
    rts
}
//XXX -  Copy your syscall handler functions from os5.2.kc
pagfault: {
    jsr exit_hypervisor
    rts
}
.segment Data
  MESSAGE: .text "checkpoint 5.3 by aman0130"
  .byte 0
.segment Syscall
  SYSCALLS: .byte JMP
  .word syscall00
  .byte NOP, JMP
  .word syscall01
  .byte NOP, JMP
  .word syscall02
  .byte NOP, JMP
  .word syscall03
  .byte NOP, JMP
  .word syscall04
  .byte NOP, JMP
  .word syscall05
  .byte NOP, JMP
  .word syscall06
  .byte NOP, JMP
  .word syscall07
  .byte NOP, JMP
  .word syscall08
  .byte NOP, JMP
  .word syscall09
  .byte NOP, JMP
  .word syscall10
  .byte NOP, JMP
  .word syscall11
  .byte NOP, JMP
  .word syscall12
  .byte NOP, JMP
  .word syscall13
  .byte NOP, JMP
  .word syscall14
  .byte NOP, JMP
  .word syscall15
  .byte NOP, JMP
  .word syscall16
  .byte NOP, JMP
  .word securentr
  .byte NOP, JMP
  .word securexit
  .byte NOP, JMP
  .word syscall19
  .byte NOP, JMP
  .word syscall20
  .byte NOP, JMP
  .word syscall21
  .byte NOP, JMP
  .word syscall22
  .byte NOP, JMP
  .word syscall23
  .byte NOP, JMP
  .word syscall24
  .byte NOP, JMP
  .word syscall25
  .byte NOP, JMP
  .word syscall26
  .byte NOP, JMP
  .word syscall27
  .byte NOP, JMP
  .word syscall28
  .byte NOP, JMP
  .word syscall29
  .byte NOP, JMP
  .word syscall30
  .byte NOP, JMP
  .word syscall31
  .byte NOP, JMP
  .word syscall32
  .byte NOP, JMP
  .word syscall33
  .byte NOP, JMP
  .word syscall34
  .byte NOP, JMP
  .word syscall35
  .byte NOP, JMP
  .word syscall36
  .byte NOP, JMP
  .word syscall37
  .byte NOP, JMP
  .word syscall38
  .byte NOP, JMP
  .word syscall39
  .byte NOP, JMP
  .word syscall40
  .byte NOP, JMP
  .word syscall41
  .byte NOP, JMP
  .word syscall42
  .byte NOP, JMP
  .word syscall43
  .byte NOP, JMP
  .word syscall44
  .byte NOP, JMP
  .word syscall45
  .byte NOP, JMP
  .word syscall46
  .byte NOP, JMP
  .word syscall47
  .byte NOP, JMP
  .word syscall48
  .byte NOP, JMP
  .word syscall49
  .byte NOP, JMP
  .word syscall50
  .byte NOP, JMP
  .word syscall51
  .byte NOP, JMP
  .word syscall52
  .byte NOP, JMP
  .word syscall53
  .byte NOP, JMP
  .word syscall54
  .byte NOP, JMP
  .word syscall55
  .byte NOP, JMP
  .word syscall56
  .byte NOP, JMP
  .word syscall57
  .byte NOP, JMP
  .word syscall58
  .byte NOP, JMP
  .word syscall59
  .byte NOP, JMP
  .word syscall60
  .byte NOP, JMP
  .word syscall61
  .byte NOP, JMP
  .word syscall62
  .byte NOP, JMP
  .word syscall63
  .byte NOP
  .align $100
  TRAPS: .byte JMP
  .word reset
  .byte NOP, JMP
  .word pagfault
  .byte NOP, JMP
  .word restorkey
  .byte NOP, JMP
  .word alttabkey
  .byte NOP, JMP
  .word vf011rd
  .byte NOP, JMP
  .word vf011wr
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word cpukil
  .byte NOP
