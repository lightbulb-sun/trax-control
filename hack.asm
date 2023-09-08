ROTATION                    equ $c93e
DIRECTION                   equ $c9f2
MULTIGAME_DIRECTION         equ $dcd2
HELD_BUTTONS                equ $ff98
BUTTON_A                    equ $01
CUR_POWERUP                 equ $c9ca
PUSH_TO_VRAM_BUFFER         equ $0441
SET_END_OF_VRAM_BUFFER      equ $0461
POWERUP_TILE_DEST           equ $8820
POWERUP_NUM_BYTES           equ $40
CUR_ROM_BANK                equ $ffb1
SWITCH_ROM_BANK             equ $0654


SECTION "unbind_a_button_for_rotation_1", ROMX[$4282], BANK[1]
        ld      a, 0
SECTION "unbind_a_button_for_rotation_2", ROMX[$428a], BANK[1]
        ld      a, 0
SECTION "north", ROMX[$4246], BANK[1]
        call    set_direction_and_rotate
SECTION "northeast", ROMX[$424d], BANK[1]
        call    set_direction_and_rotate
SECTION "east", ROMX[$4254], BANK[1]
        call    set_direction_and_rotate
SECTION "southeast", ROMX[$425b], BANK[1]
        call    set_direction_and_rotate
SECTION "south", ROMX[$4262], BANK[1]
        call    set_direction_and_rotate
SECTION "southwest", ROMX[$4269], BANK[1]
        call    set_direction_and_rotate
SECTION "west", ROMX[$4270], BANK[1]
        call    set_direction_and_rotate
SECTION "northwest", ROMX[$4277], BANK[1]
        call    set_direction_and_rotate

SECTION "multigame_unbind_a_button_for_rotation", ROMX[$4162], BANK[1]
        nop
SECTION "multigame_north", ROM0[$300d]
        call    multigame_set_direction_and_rotate
SECTION "multigame_northeast", ROM0[$3014]
        call    multigame_set_direction_and_rotate
SECTION "multigame_east", ROM0[$301b]
        call    multigame_set_direction_and_rotate
SECTION "multigame_southeast", ROM0[$3022]
        call    multigame_set_direction_and_rotate
SECTION "multigame_south", ROM0[$3029]
        call    multigame_set_direction_and_rotate
SECTION "multigame_southwest", ROM0[$3030]
        call    multigame_set_direction_and_rotate
SECTION "multigame_west", ROM0[$3037]
        call    multigame_set_direction_and_rotate
SECTION "multigame_northwest", ROM0[$303e]
        call    multigame_set_direction_and_rotate

SECTION "gain_powerup", ROMX[$4e40], BANK[1]
        call    draw_powerup_icon
SECTION "lose_powerup", ROMX[$41d5], BANK[1]
        call    lose_powerup

SECTION "level_loading", ROM0[$0905]
        call    level_loading_loader

SECTION "free_space_1", ROM0[$0067]
level_loading_loader::
        ; replace original instruction
        call    $1a97

        push    af
        push    bc
        push    de
        push    hl

        di
        ldh     a, [CUR_ROM_BANK]
        push    af
        ld      a, 1
        call    SWITCH_ROM_BANK
        call    level_loading
        pop     af
        call    SWITCH_ROM_BANK
        ei

        pop     hl
        pop     de
        pop     bc
        pop     af

        ret

SECTION "free_space_2", ROMX[$7e00], BANK[1]
set_direction_and_rotate::
        ; replace original instruction
        ld      [DIRECTION], a
.check_for_a_button_press
        ld      c, a
        ldh     a, [HELD_BUTTONS]
        and     BUTTON_A
        ret     nz
.no_a_press
        ld      a, c
        ld      [ROTATION], a
        ret

multigame_set_direction_and_rotate::
        ; replace original instruction
        ld      [MULTIGAME_DIRECTION], a
        jp      set_direction_and_rotate.check_for_a_button_press

level_loading::
        ld      a, [CUR_POWERUP]
        inc     a
        call    calculate_powerup_tile_address
        ld      de, POWERUP_TILE_DEST
        ld      b, POWERUP_NUM_BYTES
        call    copy_memory
        ret

copy_memory::
.loop
        ld      a, [hl+]
        ld      [de], a
        inc     de
        dec     b
        jr      nz, .loop
        ret

calculate_powerup_tile_address::
        dec     a
        swap    a
        ld      h, 0
        ld      l, a
        add     hl, hl
        add     hl, hl

        ld      de, powerup_tile_data
        add     hl, de
        ret

lose_powerup::
        ld      a, 1
draw_powerup_icon::
        push    af
        push    bc
        push    hl

        call    calculate_powerup_tile_address

        ld      a, HIGH(POWERUP_TILE_DEST)
        call    PUSH_TO_VRAM_BUFFER
        ld      a, LOW(POWERUP_TILE_DEST)
        call    PUSH_TO_VRAM_BUFFER
        ld      a, POWERUP_NUM_BYTES
        call    PUSH_TO_VRAM_BUFFER

        ld      b, POWERUP_NUM_BYTES
.loop
        ld      a, [hl+]
        call    PUSH_TO_VRAM_BUFFER
        dec     b
        jr      nz, .loop

        call    SET_END_OF_VRAM_BUFFER

        ; replace original instruction
        ld      de, CUR_POWERUP
        pop     hl
        pop     bc
        pop     af
        ret


powerup_tile_data::
powerup0::
        db $01, $01, $3a, $3e, $7e, $7e, $7e, $7c
        db $7d, $51, $39, $71, $30, $20, $33, $23
        db $30, $20, $30, $20, $38, $30, $7c, $70
        db $7f, $7c, $7f, $5f, $38, $3c, $00, $00
        db $80, $80, $5c, $7c, $7e, $7e, $7e, $3e
        db $be, $8a, $9c, $8e, $0c, $04, $cc, $c4
        db $0c, $04, $0c, $04, $1c, $0c, $3e, $0e
        db $fe, $3e, $fe, $fa, $1c, $3c, $00, $00
powerup1::
        db $7f, $3f, $ff, $61, $ff, $c3, $fe, $82
        db $fc, $84, $fc, $84, $87, $85, $ff, $87
        db $ff, $87, $fc, $84, $fe, $80, $fa, $80
        db $fa, $80, $da, $c0, $e0, $60, $7f, $3f
        db $fe, $fc, $e7, $86, $fb, $c3, $fd, $c1
        db $fd, $e1, $fd, $e1, $e1, $e1, $fd, $a1
        db $fd, $e1, $3d, $21, $7d, $01, $5d, $01
        db $5d, $01, $5b, $03, $07, $06, $fe, $fc
powerup2::
        db $7f, $3f, $ff, $60, $ff, $c1, $ff, $82
        db $ff, $84, $ff, $84, $ff, $8f, $f3, $91
        db $a3, $a1, $a7, $a3, $bf, $a7, $ff, $bf
        db $ff, $9f, $df, $cf, $e0, $60, $7f, $3f
        db $fe, $fc, $e7, $06, $eb, $cb, $fd, $21
        db $a9, $01, $fd, $45, $fd, $81, $fd, $c1
        db $e1, $e1, $e1, $e1, $e1, $a1, $fd, $a1
        db $fd, $41, $fb, $83, $07, $06, $fe, $fc
powerup3::
        db $7f, $3f, $ff, $63, $fc, $c4, $fd, $85
        db $ff, $87, $ff, $bb, $ce, $cc, $de, $dc
        db $fe, $f4, $ff, $b9, $fe, $86, $fc, $84
        db $fc, $8c, $d8, $c8, $e6, $66, $7f, $3f
        db $fe, $fc, $e7, $c6, $fb, $e3, $fd, $e1
        db $fd, $a1, $fd, $dd, $e7, $a7, $ef, $af
        db $ff, $bb, $fd, $9d, $fd, $61, $fd, $21
        db $fd, $31, $fb, $13, $e7, $66, $fe, $fc
powerup4::
        db $7f, $3f, $f9, $69, $f9, $c9, $ff, $8f
        db $df, $8f, $df, $87, $df, $83, $d7, $80
        db $d7, $80, $df, $83, $df, $87, $f9, $89
        db $f9, $89, $df, $cf, $ef, $6f, $7f, $3f
        db $fe, $fc, $f7, $f6, $fb, $f3, $fd, $d1
        db $f5, $91, $f5, $e1, $f5, $c1, $d5, $01
        db $d5, $01, $f5, $c1, $f5, $e1, $fd, $f1
        db $fd, $f1, $fb, $d3, $f7, $96, $fe, $fc
