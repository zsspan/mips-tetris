.data
ADDR_DSPL: .word 0x10008000  # base address for framebuffer
Board: .space 2048   # 32 rows * 16 columns * 4 bytes = 2048 bytes
ADDR_KBRD: .word 0xffff0000

active_piece: .word 0
active_row: .word 0
active_col: .word 5
I_piece:
    .byte 0,0,0,0
    .byte 1,1,1,1
    .byte 0,0,0,0
    .byte 0,0,0,0

Z_piece:
    .byte 0,0,0,0
    .byte 1,1,1,1
    .byte 0,1,1,0
    .byte 0,1,1,0

S_piece:
    .byte 1,0,1,1
    .byte 1,1,1,1
    .byte 0,1,1,0
    .byte 0,1,1,0

L_piece:
    .byte 0,0,0,0
    .byte 0,1,0,0
    .byte 0,1,0,0
    .byte 0,1,1,0

BINGBONG_piece:
    .byte 1,1,1,1
    .byte 1,0,0,1
    .byte 1,0,0,1
    .byte 1,1,1,1

.text
.globl main
main:
    la   $s7, ADDR_KBRD
    lw   $s7, 0($s7)       # now $s7 = 0xffff0000

    # setup and draw static UI
    jal init_game

    # re-load keyboard addr just in case
    la   $s7, ADDR_KBRD
    lw   $s7, 0($s7)
    
    # Set active piece to I_piece
    la  $t0, L_piece
    sw  $t0, active_piece

    li  $t1, 2      # row = 0
    sw  $t1, active_row

    li  $t2, 8      # col = center
    sw  $t2, active_col


game_loop:
    # 1a. check if key has been pressed
    lw   $t0, 0($s7)           # key status
    beqz $t0, skip_key

    # 1b. Read the key
    lw   $t1, 4($s7)           # $t1 = ASCII keycode

    # 'a' = move left
    li   $t2, 97               # ASCII 'a'
    beq  $t1, $t2, move_left

    # 'd' = move right
    li   $t2, 100              # ASCII 'd'
    beq  $t1, $t2, move_right

    # 's' = move down
    li   $t2, 115              # ASCII 's'
    beq  $t1, $t2, move_down

skip_key:
    # 3. Draw the screen or update gameplay
    jal start_drawing

    j game_loop

move_left:
    # clear current position
    lw $a0, active_piece
    lw $a1, active_row
    lw $a2, active_col
    jal clear_piece
    
    li $a0, 0        # row delta
    li $a1, -1       # col delta
    jal can_move
    beqz $v0, game_loop

    lw  $t0, active_col
    addi $t0, $t0, -1
    sw  $t0, active_col
    j   game_loop


move_right:
    lw $a0, active_piece
    lw $a1, active_row
    lw $a2, active_col
    jal clear_piece
    
    li $a0, 0        # row delta
    li $a1, 1        # col delta
    jal can_move
    beqz $v0, game_loop

    lw  $t0, active_col
    addi $t0, $t0, 1
    sw  $t0, active_col
    j   game_loop


move_down:
    lw $a0, active_piece
    lw $a1, active_row
    lw $a2, active_col
    jal clear_piece
    
    li $a0, 1        # row delta
    li $a1, 0        # col delta
    jal can_move
    beqz $v0, move_down_lock

    lw  $t0, active_row
    addi $t0, $t0, 1
    sw  $t0, active_row
    j   game_loop

move_down_lock:
    la   $a0, active_piece
    lw   $a0, 0($a0)
    lw   $a2, active_row
    lw   $a3, active_col
    jal  lock_piece

    # spawn more pieces
    j game_loop

##############################################################################

init_game:
    lw $t0, ADDR_DSPL        # $t0 = base framebuffer address
    li $t1, 0xa40c50         # red color
    li $s5, 0xa20aaa
    li $s4, 0x262626

    li $t2, 0                # row index
    li $t3, 32               # total rows (64 * 4 = 256 pixels)

    # PLAY AREA IS FROM COL 2 to 17 (16 blocks wide)

draw_loop:
    mul $t4, $t2, 128        # offset = row * 128 bytes (32 units * 4 bytes)
    add $t5, $t0, $t4        # $t5 = start of current row

    # First, second, second-last, last row: draw full red
    beq $t2, $zero, draw_full_row
    li $t6, 1
    beq $t2, $t6, draw_full_row
    li $t6, 30
    beq $t2, $t6, draw_full_row
    li $t6, 31
    beq $t2, $t6, draw_full_row

    # Draw left border (col 0 + 1)
    sw $t1, 0($t5)
    addi $t8, $t5, 4       # col 1 = $t5 + 4
    sw $t1, 0($t8)

    # Draw right border (col 18 + 19)
    li $t6, 18
    mul $t7, $t6, 4
    add $t8, $t5, $t7
    sw $t1, 0($t8)
    add $t8, $t8, 4
    sw $t1, 0($t8)

    # Clear play area (cols 2 to 17)
    li $t6, 2        # start col
    li $t7, 17       # end col (inclusive)

clear_loop:
    #t2, t6 is row (index) / column (index)
    mul $t9, $t6, 4  # column index * 4
    addu $t4, $t5, $t9 # t4 = current_row + column offset

    # now we make a checkerboard pattern
    # if (row + col) % 2 == 0, make it gray instead
    
    add $t9, $t2, $t6 # we can reuse t9 now
    andi $t9, $t9, 1  # t9 = (row + col) % 2

    bne $t9, $zero, store_black
    sw $s4, 0($t4) # colour it
    j continue_clear

store_black:
    sw  $s0, 0($t4)         # store black
    j   continue_clear

continue_clear:
    addi $t6, $t6, 1
    ble $t6, $t7, clear_loop # if not done clearing the area

    # UI area -purple (cols 29 to 31)
    li $t6, 20
    li $t7, 31

ui_loop:
    mul $t9, $t6, 4
    addu $t4, $t5, $t9
    sw $s5, 0($t4) # mark it mystery colour for now
    addi $t6, $t6, 1
    ble $t6, $t7, ui_loop

    j next_row

draw_full_row:
    li $t6, 32               # total units in a row
    move $t4, $t5    # t4 = base address
full_row_loop:
    sw $t1, 0($t4)
    addi $t4, $t4, 4
    addi $t6, $t6, -1
    bgtz $t6, full_row_loop

next_row:
    addi $t2, $t2, 1
    blt $t2, $t3, draw_loop

    jr $ra


##############################################################################
start_drawing:
    addiu $sp, $sp, -4 # push
    sw    $ra, 0($sp)
    
    # load active piece and draw it
    lw  $a0, active_piece
    li  $a1, 0x9999ff         # color
    lw  $a2, active_row
    lw  $a3, active_col
    jal draw_piece


    # pop and go back
    lw    $ra, 0($sp)
    addiu $sp, $sp, 4
    jr    $ra


##############################################################################
# fxn draw_piece(a0, a1, a2, a3): draws a piece
# a2, a3 are row and column (indices)

draw_piece:
    move $t0, $a0        # piece pointer
    move $t1, $a1        # color
    move $t2, $a2        # row pos
    move $t3, $a3        # col pos

    li   $t4, 0          # piece row index (0..3)
draw_row_loop:
    li   $t5, 0          # piece col index (0..3)
draw_col_loop:
    mul  $t6, $t4, 4
    add  $t6, $t6, $t5      # piece offset
    add  $t7, $t0, $t6
    lb   $t8, 0($t7)        # piece[i,j]

    beq  $t8, $zero, skip_pixel

    add  $t9, $t2, $t4      # screen row
    add  $s0, $t3, $t5      # screen col (using $s0 temporarily)

    mul  $t9, $t9, 128      # row offset in bytes
    mul  $s0, $s0, 4        # col offset in bytes

    lw   $s1, ADDR_DSPL     # framebuffer base
    addu $t9, $s1, $t9
    addu $t9, $t9, $s0

    sw   $t1, 0($t9)        # write pixel color

skip_pixel:
    addi $t5, $t5, 1
    li   $t6, 4
    blt  $t5, $t6, draw_col_loop

    addi $t4, $t4, 1
    li   $t6, 4
    blt  $t4, $t6, draw_row_loop

    jr $ra

clear_piece:
    move $t0, $a0        # piece pointer
    move $t2, $a1        # row pos
    move $t3, $a2        # col pos

    li   $t4, 0          # piece row index (0..3)
cp_row_loop:
    li   $t5, 0          # piece col index (0..3)
cp_col_loop:
    mul  $t6, $t4, 4
    add  $t6, $t6, $t5      # piece offset
    add  $t7, $t0, $t6
    lb   $t8, 0($t7)        # piece[i,j]

    beq  $t8, $zero, cp_skip_pixel

    add  $t9, $t2, $t4      # screen row
    add  $s0, $t3, $t5      # screen col (using $s0 temporarily)

    mul  $t9, $t9, 128      # row offset in bytes
    mul  $s0, $s0, 4        # col offset in bytes

    lw   $s1, ADDR_DSPL     # framebuffer base
    addu $t9, $s1, $t9
    addu $t9, $t9, $s0

    # Calculate checkerboard pattern:
    add $s2, $t2, $t4    # abs_row
    add $s3, $t3, $t5    # abs_col
    add $s4, $s2, $s3
    andi $s4, $s4, 1
    beqz $s4, cp_gray
    sw $zero, 0($t9)     # black
    j cp_skip_pixel

cp_gray:
    li $s5, 0x262626     # gray
    sw $s5, 0($t9)

cp_skip_pixel:
    addi $t5, $t5, 1
    blt  $t5, 4, cp_col_loop

    addi $t4, $t4, 1
    blt  $t4, 4, cp_row_loop

    jr $ra

##############################################################################
# fxn lock_piece(a0, a2, a3): commits a piece to board
# a2, a3 are row/col, a0 is piece
lock_piece:
    li   $t0, 0              # piece row index (0..3)
lp_row_loop:
    li   $t1, 0              # piece col index (0..3)
lp_col_loop:
    mul  $t2, $t0, 4
    add  $t2, $t2, $t1       # offset in piece
    add  $t3, $a0, $t2
    lb   $t4, 0($t3)         # get value of piece[i][j]

    beq  $t4, $zero, lp_skip # skip if empty block

    add  $t5, $a2, $t0       # board row
    add  $t6, $a3, $t1       # board col

    li   $t7, 16
    mul  $t8, $t5, $t7
    add  $t8, $t8, $t6
    sll  $t8, $t8, 2         # multiply by 4

    la   $t9, Board
    add  $t9, $t9, $t8
    li   $s0, 1
    sw   $s0, 0($t9)

lp_skip:
    addi $t1, $t1, 1
    li   $t2, 4
    blt  $t1, $t2, lp_col_loop

    addi $t0, $t0, 1
    li   $t2, 4
    blt  $t0, $t2, lp_row_loop

    jr $ra

##############################################################################
# fxn can_move_down(): returns boolean in v0
# uses stack # can_move: returns 1 in $v0 if move by (d_row=$a0, d_col=$a1) is legal
can_move:
    addiu $sp, $sp, -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)

    lw    $s0, active_piece     # $s0 = pointer to piece
    lw    $t0, active_row       # $t0 = active row
    lw    $t1, active_col       # $t1 = active col

    move  $t2, $a0              # $t2 = d_row
    move  $t3, $a1              # $t3 = d_col

    li    $t4, 0                # i = 0
row_loop:
    li    $t5, 0                # j = 0
col_loop:
    mul   $t6, $t4, 4
    add   $t6, $t6, $t5         # offset = i*4 + j
    add   $t7, $s0, $t6
    lb    $t8, 0($t7)           # piece[i][j]

    beqz  $t8, skip_cell

    # abs_row = active_row + i + d_row
    add   $t9, $t0, $t4
    add   $t9, $t9, $t2

    # abs_col = active_col + j + d_col
    add   $t6, $t1, $t5
    add   $t6, $t6, $t3

 
    # check row > 1 and < 32
    li   $t7, 1
    ble  $t9, $t7, fail_move
    li   $t7, 30
    bge  $t9, $t7, fail_move
    
    # check col > 1 and < 14
    li   $t7, 1
    ble  $t6, $t7, fail_move
    li   $t7, 18
    bge  $t6, $t7, fail_move


    # check collision in Board[abs_row][abs_col]
    li    $t7, 16
    mul   $t7, $t9, $t7         # t7 = abs_row * 16
    add   $t7, $t7, $t6         # + abs_col
    sll   $t7, $t7, 2           # * 4 (word address)

    la    $t8, Board
    add   $t8, $t8, $t7
    lw    $t9, 0($t8)
    bnez  $t9, fail_move # if board[i][j] == 1, its alr occupied

skip_cell:
    addi  $t5, $t5, 1
    blt   $t5, 4, col_loop

    addi  $t4, $t4, 1
    blt   $t4, 4, row_loop

    li    $v0, 1
    j     done_move

fail_move:
    li    $v0, 0

done_move:
    lw    $ra, 0($sp)
    lw    $s0, 4($sp)
    addiu $sp, $sp, 8
    jr    $ra
