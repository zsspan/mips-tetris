#####################################################################
# CSCB58 Summer 2025 Assembly Final Project - UTSC
# Name, Student Number, UTorID, official email
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed) 
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
# 
# Currently has rotation, movement, collision detection, and central loop and piece locking.
# More info will be written in final submission
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
ADDR_DSPL: .word 0x10008000  # base address for framebuffer
Board: .space 1792   # 28 rows * 16 columns * 4 bytes = 2048 bytes
ADDR_KBRD: .word 0xffff0000
seed: .word 76575 # determines random seed

active_piece: .word 0
active_row: .word 0
active_col: .word 5
active_color: .word 0
active_orientation: .word 0
active_rotation_block: .word 0

# parallel list of pieces and colours
AllPieces: .word I_piece_rotations, L_piece_rotations, T_piece_rotations, O_piece_rotations, S_piece_rotations, Z_piece_rotations, J_piece_rotations
PieceColors: .word 0x9999ff, 0xe27102, 0xae2fcb, 0xebf01d, 0x50d3ac, 0xaa2822, 0x33a6eb

# piece info
I_piece_rotations: .word I_piece, I_piece_90, I_piece_180, I_piece_270
L_piece_rotations: .word L_piece, L_piece_90, L_piece_180, L_piece_270
T_piece_rotations: .word T_piece, T_piece_90, T_piece_180, T_piece_270
O_piece_rotations: .word O_piece, O_piece_90, O_piece_180, O_piece_270
S_piece_rotations: .word S_piece, S_piece_90, S_piece_180, S_piece_270
Z_piece_rotations: .word Z_piece, Z_piece_90, Z_piece_180, Z_piece_270
J_piece_rotations: .word J_piece, J_piece_90, J_piece_180, J_piece_270

I_piece:
    .byte 0,0,0,0
    .byte 1,1,1,1
    .byte 0,0,0,0
    .byte 0,0,0,0
    
I_piece_90:
    .byte 0,1,0,0
    .byte 0,1,0,0
    .byte 0,1,0,0
    .byte 0,1,0,0

I_piece_180:
    .byte 0,0,0,0
    .byte 0,0,0,0
    .byte 1,1,1,1
    .byte 0,0,0,0

I_piece_270:
    .byte 0,0,1,0
    .byte 0,0,1,0
    .byte 0,0,1,0
    .byte 0,0,1,0

L_piece:
    .byte 0,0,0,0
    .byte 0,1,0,0
    .byte 0,1,0,0
    .byte 0,1,1,0

L_piece_90:
    .byte 0,0,0,0
    .byte 0,0,0,0
    .byte 1,1,1,0
    .byte 1,0,0,0

L_piece_180:
    .byte 1,1,0,0
    .byte 0,1,0,0
    .byte 0,1,0,0
    .byte 0,0,0,0

L_piece_270:
    .byte 0,0,1,0
    .byte 1,1,1,0
    .byte 0,0,0,0
    .byte 0,0,0,0

J_piece:
    .byte 0,0,0,0
    .byte 1,1,1,0
    .byte 0,0,1,0
    .byte 0,0,0,0

J_piece_90:
    .byte 0,1,0,0
    .byte 0,1,0,0
    .byte 1,1,0,0
    .byte 0,0,0,0

J_piece_180:
    .byte 0,0,0,0
    .byte 1,0,0,0
    .byte 1,1,1,0
    .byte 0,0,0,0

J_piece_270:
    .byte 0,1,1,0
    .byte 0,1,0,0
    .byte 0,1,0,0
    .byte 0,0,0,0

T_piece:
    .byte 0,0,0,0
    .byte 1,1,1,0
    .byte 0,1,0,0
    .byte 0,0,0,0

T_piece_90:
    .byte 0,1,0,0
    .byte 1,1,0,0
    .byte 0,1,0,0
    .byte 0,0,0,0

T_piece_180:
    .byte 0,1,0,0
    .byte 1,1,1,0
    .byte 0,0,0,0
    .byte 0,0,0,0

T_piece_270:
    .byte 0,1,0,0
    .byte 0,1,1,0
    .byte 0,1,0,0
    .byte 0,0,0,0

S_piece:
    .byte 0,0,0,0
    .byte 0,1,1,0
    .byte 1,1,0,0
    .byte 0,0,0,0

S_piece_90:
    .byte 1,0,0,0
    .byte 1,1,0,0
    .byte 0,1,0,0
    .byte 0,0,0,0

S_piece_180:
    .byte 0,0,0,0
    .byte 0,1,1,0
    .byte 1,1,0,0
    .byte 0,0,0,0

S_piece_270:
    .byte 1,0,0,0
    .byte 1,1,0,0
    .byte 0,1,0,0
    .byte 0,0,0,0

Z_piece:
    .byte 0,0,0,0
    .byte 1,1,0,0
    .byte 0,1,1,0
    .byte 0,0,0,0

Z_piece_90:
    .byte 0,1,0,0
    .byte 1,1,0,0
    .byte 1,0,0,0
    .byte 0,0,0,0

Z_piece_180:
    .byte 0,0,0,0
    .byte 1,1,0,0
    .byte 0,1,1,0
    .byte 0,0,0,0

Z_piece_270:
    .byte 0,1,0,0
    .byte 1,1,0,0
    .byte 1,0,0,0
    .byte 0,0,0,0

O_piece:
    .byte 0,1,1,0
    .byte 0,1,1,0
    .byte 0,0,0,0
    .byte 0,0,0,0

O_piece_90:
    .byte 0,1,1,0
    .byte 0,1,1,0
    .byte 0,0,0,0
    .byte 0,0,0,0

O_piece_180:
    .byte 0,1,1,0
    .byte 0,1,1,0
    .byte 0,0,0,0
    .byte 0,0,0,0

O_piece_270:
    .byte 0,1,1,0
    .byte 0,1,1,0
    .byte 0,0,0,0
    .byte 0,0,0,0

gray_color: .word 0x262626

.text
.globl main
main:
    la $s7, ADDR_KBRD
    lw $s7, 0($s7)       # now $s7 = 0xffff0000

    # setup and draw static UI
    jal init_game

    # re-load keyboard addr just in case
    la $s7, ADDR_KBRD
    lw $s7, 0($s7)

    # idk this apparently does RNG nonsense
    li $a0, 0      # generator ID
    lw $a1, seed  # seed
    li $v0, 40     # syscall 40
    syscall

    sw $zero, active_orientation # init to 0

    # random nonsense
    la $t0, I_piece_rotations
    sw $t0, active_rotation_block  # store pointer to it

    # set active piece to L_piece (using pointer nonsense)
    lw $t1, 0($t0) # this is orientation 0 of I piece
    sw $t1, active_piece

    # set active row, column and color
    li $t1, 2 # row = 0
    sw $t1, active_row
    li $t1, 8 # col = center
    sw $t1, active_col

    li $t1, 0x9999ff
    sw $t1, active_color


game_loop:
    # 1a. check if key has been pressed
    lw $t0, 0($s7)           # key status
    beqz $t0, skip_key

    # 1b. read the key and check keypress
    lw $t1, 4($s7) # $t1 = ASCII keycode

    # 'w' = move left
    li $t2, 119
    beq $t1, $t2, try_rotate
    
    # 'a' = move left
    li $t2, 97
    beq $t1, $t2, move_left

    # 'd' = move right
    li $t2, 100
    beq $t1, $t2, move_right

    # 's' = move down
    li $t2, 115
    beq $t1, $t2, move_down

    # 'q' = quit
    li $t2, 113
    beq $t1, $t2, quit

skip_key:
    # 3. draw the screen or update gameplay
    jal start_drawing

    j game_loop

quit:
    li $v0, 10 # syscall to exit
    syscall
    
try_rotate:
    lw $t0, active_orientation        # current orientation
    addi $t1, $t0, 1
    andi $t1, $t1, 3                   # next orientation mod 4
    move $s3, $t1 # save for now
    
    lw $t2, active_rotation_block    # pointer to rotation block array

    sll $t3, $t1, 2                  # offset = next_orientation * 4 bytes
    addu $t3, $t3, $t2                # pointer to rotated piece pointer

    lw $t4, 0($t3)                  # rotated piece pointer
    move $s4, $t4 # save for now

    lw $a1, active_row
    lw $a2, active_col
    move $a0, $t4                     # rotated piece ptr

    jal can_place_piece
    beqz $v0, rotate_fail             # fail if can't place

    # save old active_piece pointer before updating
    lw $t5, active_piece

    # clear old piece
    move $a0, $t5
    lw $a1, active_row
    lw $a2, active_col
    jal clear_piece

    # update rotation state
    sw $s3, active_orientation
    sw $s4, active_piece

    # j game_loop

rotate_fail:
    j    game_loop


move_left:
    # clear current position
    lw $a0, active_piece
    lw $a1, active_row
    lw $a2, active_col
    jal clear_piece
    
    li $a0, 0 # row delta
    li $a1, -1 # col delta
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
    
    li $a0, 0 # row delta
    li $a1, 1 # col delta
    jal can_move
    beqz $v0, game_loop

    lw  $t0, active_col
    addi $t0, $t0, 1
    sw $t0, active_col
    j game_loop


move_down:
    li $a0, 1 # row delta
    li $a1, 0 # col delta
    jal can_move
    beqz $v0, move_down_lock
    
    lw $a0, active_piece
    lw $a1, active_row
    lw $a2, active_col
    jal clear_piece
    
    lw $t0, active_row
    addi $t0, $t0, 1
    sw $t0, active_row
    j game_loop

move_down_lock:
    lw $a0, active_piece
    lw $a2, active_row
    lw $a3, active_col
    jal lock_piece

    # jal print_board

    jal clear_lines

    beqz $v0, spawn_piece # no clearing happened
    # else redraw board
    jal init_game # this will clear the board (not ideal b/c it redraws red, but wtv)
    # now we redraw the board
    # jal print_board
    jal redraw_board

    # keep creating pieces next

spawn_piece:
    sw $zero, active_orientation # set each to 0

    # get random number
    li $a0, 0 # generator ID (MUST BE SET)
    li $a1, 7 # NUMBER OF PIECES
    li $v0, 42
    syscall # result is in $a0
    # li $a0, 0       # force index to 0 (I piece) - temp

    sll $t7, $a0, 2 # offset = (random_index) * 4 (use this for piece + colour)

    la $t8, PieceColors # base address of PieceColors
    add $t9, $t8, $t7 # t9 = address of PieceColors[index]
    lw $t0, 0($t9) # t0 = colour of piece
    sw $t0, active_color # make colour active

    la $t6, AllPieces # base address of array
    add $t6, $t6, $t7 # pointer to AllPieces[index]
    lw $t7, 0($t6) # load the rotation block pointer
    sw $t7, active_rotation_block # active_rotation_block = t7*
    
    lw $t0, 0($t7) # rotation 0 of the current piece
    sw $t0, active_piece
    
    li $t1, 2
    sw $t1, active_row
    li $t2, 8
    sw $t2, active_col

    lw $a0 active_piece
    lw $a1 active_row
    lw $a2 active_col


    jal can_place_piece # check if the game is over (v0 = 0)
    beq $zero, $v0 quit
    
    j game_loop

##############################################################################

init_game:
    lw $t0, ADDR_DSPL        # $t0 = base framebuffer address
    li $t1, 0xa40c50         # red color
    li $s5, 0xa20aaa
    li $s4, 0x262626 # gray for checkboard

    li $t2, 0           # row index
    li $t3, 32          # total rows (64 * 4 = 256 pixels)

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
    sw  $zero, 0($t4)         # store black
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
start_drawing: # this is basically a do while loop
    addi $sp, $sp, -4 # push
    sw $ra, 0($sp)
        
    # load active piece and draw it
    lw $a0, active_piece
    lw $a1, active_color
    lw $a2, active_row
    lw $a3, active_col
    jal draw_piece


    # pop and go back
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


##############################################################################
# fxn draw_piece(a0, a1, a2, a3): draws a piece
# a2, a3 are row and column (indices)

draw_piece:
    move $t0, $a0        # piece pointer
    move $t1, $a1        # color
    move $t2, $a2        # row pos
    move $t3, $a3        # col pos

    li $t4, 0          # piece row index (0..3)
draw_row_loop:
    li $t5, 0          # piece col index (0..3)
draw_col_loop:
    mul $t6, $t4, 4
    add $t6, $t6, $t5      # piece offset
    add $t7, $t0, $t6
    lb $t8, 0($t7)        # piece[i,j]

    beq $t8, $zero, skip_pixel

    add $t9, $t2, $t4      # screen row
    add $s0, $t3, $t5        # screen col (using $s0 temporarily)

    mul $t9, $t9, 128       # row offset in bytes
    mul $s0, $s0, 4         # col offset in bytes

    lw $s1, ADDR_DSPL     # framebuffer base
    addu $t9, $s1, $t9
    addu $t9, $t9, $s0

    sw $t1, 0($t9)        # write pixel color

skip_pixel:
    addi $t5, $t5, 1
    li $t6, 4
    blt $t5, $t6, draw_col_loop

    addi $t4, $t4, 1
    li $t6, 4
    blt $t4, $t6, draw_row_loop

    jr $ra

clear_piece:
    move $t0, $a0        # piece pointer
    move $t2, $a1        # row pos
    move $t3, $a2        # col pos

    li $t4, 0          # piece row index (0..3)
cp_row_loop:
    li $t5, 0          # piece col index (0..3)
cp_col_loop:
    mul $t6, $t4, 4
    add $t6, $t6, $t5      # piece offset
    add $t7, $t0, $t6
    lb $t8, 0($t7)        # piece[i,j]

    beq $t8, $zero, cp_skip_pixel

    add $t9, $t2, $t4      # screen row
    add $s0, $t3, $t5      # screen col (using $s0 temporarily)

    mul $t9, $t9, 128      # row offset in bytes
    mul $s0, $s0, 4        # col offset in bytes

    lw $s1, ADDR_DSPL     # framebuffer base
    addu $t9, $s1, $t9
    addu $t9, $t9, $s0

    # done with t6, t7, t8
    # calculate checkerboard pattern:
    add $t6, $t2, $t4    # abs_row
    add $t7, $t3, $t5    # abs_col
    add $t8, $t6, $t7
    andi $t8, $t8, 1
    beqz $t8, cp_gray # if t8 == 1, do black
    
    sw $zero, 0($t9)     # black
    j cp_skip_pixel

cp_gray:
    li $s5, 0x262626     # gray
    sw $s5, 0($t9)

cp_skip_pixel:
    addi $t5, $t5, 1
    blt $t5, 4, cp_col_loop

    addi $t4, $t4, 1
    blt $t4, 4, cp_row_loop

    jr $ra

##############################################################################
# fxn lock_piece(a0, a2, a3): commits a piece to board (no return), assumes board has only playable area
# a2, a3 are row/col, a0 is piece
lock_piece:
    subi $a2, $a2, 2 #checktest
    subi $a3, $a3, 2
    
    li $t0, 0              # piece row index (0..3)
lp_row_loop:
    li $t1, 0              # piece col index (0..3)
lp_col_loop:
    mul $t2, $t0, 4
    add $t2, $t2, $t1       # offset in piece
    add $t3, $a0, $t2
    lb $t4, 0($t3)         # get value of piece[i][j]

    beq $t4, $zero, lp_skip # skip if empty block, change later

    add $t5, $a2, $t0       # board row
    add $t6, $a3, $t1        # board col

    li $t7, 16
    mul $t8, $t5, $t7
    add $t8, $t8, $t6
    sll $t8, $t8, 2         # multiply by 4

    la  $t9, Board
    add $t9, $t9, $t8
    lw $s0, active_color #trackme
    sw $s0, 0($t9) # save to the board, but we should store colours not piece values
    # now we store colour

lp_skip:
    addi $t1, $t1, 1
    li $t2, 4
    blt $t1, $t2, lp_col_loop

    addi $t0, $t0, 1
    li $t2, 4
    blt $t0, $t2, lp_row_loop

    jr $ra

##############################################################################
# fxn can_move_down(): returns boolean in v0
# uses stack: returns 1 in $v0 if move by (d_row=a0, d_col=$a1) is legal
can_move:
    addi $sp, $sp, -4 # push ra
    sw $ra, 0($sp)     # push ra


    lw $s0, active_piece     # $s0 = pointer to piece
    lw $t0, active_row       # $t0 = active row
    lw $t1, active_col       # $t1 = active col

    # t2, t3 = deltas (change in row/col)
    move $t2, $a0
    move $t3, $a1

    li $t4, 0                # i = 0
row_loop:
    li $t5, 0                # j = 0
col_loop:
    sll $t6, $t4, 2 # t6 = t4 * 4
    add $t6, $t6, $t5         # offset in 4x4 grid = i*4 + j
    add $t7, $s0, $t6
    lb $t8, 0($t7)           # piece[i][j]

    beqz $t8, skip_cell

    # abs_row = active_row + i + d_row
    add $t9, $t0, $t4
    add $t9, $t9, $t2

    # abs_col = active_col + j + d_col
    add $t6, $t1, $t5
    add $t6, $t6, $t3

 
    # check row > 1 and < 32
    li $t7, 1
    ble $t9, $t7, fail_move
    li $t7, 30
    bge $t9, $t7, fail_move
    
    # check col > 1 and < 14
    li $t7, 1
    ble $t6, $t7, fail_move
    li $t7, 18
    bge $t6, $t7, fail_move

    subi $t6, $t6, 2
    subi $t9, $t9, 2
    
    # check collision in Board[abs_row][abs_col]
    li $t7, 16
    mul $t7, $t9, $t7         # t7 = abs_row * 16
    add $t7, $t7, $t6         # + abs_col
    sll $t7, $t7, 2           # * 4 (word address)

    la $t8, Board
    add $t8, $t8, $t7
    lw $t9, 0($t8)
    bnez $t9, fail_move # if board[i][j] == 1, its alr occupied

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
    lw    $ra, 0($sp) # pop ra
    addi $sp, $sp, 4
    jr    $ra

##############################################################################
# fxn can_rotate(): returns boolean in v0
# uses stack: returns 1 in $v0 if a piece at (active_row, active_col)is legal
# should refactor but to can_move, but whatever
can_place_piece:
    addi $sp, $sp, -4 # push ra
    sw $ra, 0($sp)

    move $s0, $a0          # piece pointer
    move $t0, $a1          # target row
    move $t1, $a2          # target col

    li $t2, 0    # piece row index i = 0

row_loop_cp:
    li $t3, 0            # piece col index j = 0
col_loop_cp:
    mul $t4, $t2, 4
    add $t4, $t4, $t3     # offset i*4 + j
    add $t5, $s0, $t4
    lb $t6, 0($t5)       # piece[i][j]

    beqz $t6, skip_cell_cp

    # abs_row = target_row + i
    add $t7, $t0, $t2
    # abs_col = target_col + j
    add $t8, $t1, $t3

    # check rows > 1 and < 30
    li $t9, 1
    ble $t7, $t9, fail_cp
    li $t9, 30
    bge $t7, $t9, fail_cp

    # check cols > 1 and < 18
    li $t9, 1
    ble $t8, $t9, fail_cp
    li $t9, 18
    bge $t8, $t9, fail_cp

    subi $t7, $t7, 2
    subi $t8, $t8, 2
    
    # check collision on Board
    li $t9, 16
    mul $t9, $t7, $t9      # row * 16
    add $t9, $t9, $t8      # + col
    sll $t9, $t9, 2        # * 4 bytes

    la $t6, Board
    addu $t6, $t6, $t9
    lw $t7, 0($t6)
    bnez $t7, fail_cp

skip_cell_cp:
    addi $t3, $t3, 1
    blt $t3, 4, col_loop_cp

    addi $t2, $t2, 1
    blt $t2, 4, row_loop_cp

    li $v0, 1 # return 1 if fits
    j done_cp

fail_cp:
    li $v0, 0 # return 0 if it doesn't fit

done_cp:
    lw $ra, 0($sp) # pop ra
    addi $sp, $sp, 4
    jr $ra

####################################################
# fxn clear_lines(): no args, checks for cleared lines
# returns 1 in v0 if lines were cleared
### clear lines ####################################
clear_lines:
    li $v0, 0
    li $t0, 27          # start from bottom playable row (index 27)

check_row_loop:
    li $t1, 0           # start column 0
    li $t2, 1           # assume full row

check_col_loop:
    li $t3, 16          # columns per row

    mul $t4, $t0, $t3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    la $t5, Board
    add $t6, $t5, $t4
    lw $t7, 0($t6)

    beqz $t7, row_not_full # check if board[i][j] is 0

    addi $t1, $t1, 1
    ble $t1, 15, check_col_loop

    li $v0, 1

    li $t1, 0
clear_row_loop:
    mul $t4, $t0, $t3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    la $t5, Board
    add $t6, $t5, $t4
    sw $zero, 0($t6)

    addi $t1, $t1, 1
    ble $t1, 15, clear_row_loop

    addi $t8, $t0, -1

shift_rows_loop:
    li $t1, 0

shift_cols_loop:
    mul $t4, $t8, $t3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    la $t5, Board
    add $t6, $t5, $t4
    lw $t7, 0($t6)

    addi $t9, $t8, 1
    mul $t4, $t9, $t3
    add $t4, $t4, $t1
    sll $t4, $t4, 2
    add $t6, $t5, $t4
    sw $t7, 0($t6)

    addi $t1, $t1, 1
    ble $t1, 15, shift_cols_loop

    addi $t8, $t8, -1
    bge $t8, 0, shift_rows_loop

    j check_row_loop

row_not_full:
    addi $t0, $t0, -1
    bge $t0, 0, check_row_loop

    jr $ra



#########################################################################
# fxn redraw_board(): takes no params, returns void
#########################################################################
redraw_board:
    lw $t0, ADDR_DSPL        # base framebuffer address → $t0
    li $t1, 0                # row index (0–31)
rb_row_loop:
    li $t2, 0                # col index (0–15)
rb_col_loop:
    # Get color = Board[row][col]
    mul $t3, $t1, 16         # row * 16
    add $t3, $t3, $t2        # + col
    sll $t3, $t3, 2          # *4 (word offset)
    la $t4, Board
    add $t4, $t4, $t3
    lw $t5, 0($t4)           # $t5 = color

    beqz $t5, rb_skip_cell      # skip if color == 0, need to adjust later

    # Draw to screen at row+2, col+2
    addi $t6, $t1, 2         # row + 2
    addi $t7, $t2, 2         # col + 2
    mul $t8, $t6, 128        # (row + 2) * 128
    mul $t9, $t7, 4          # (col + 2) * 4
    add $t8, $t8, $t9        # total offset
    add $t8, $t8, $t0        # final address
    sw $t5, 0($t8)

rb_skip_cell:
    addi $t2, $t2, 1
    li $t9, 16
    blt $t2, $t9, rb_col_loop

    addi $t1, $t1, 1
    li $t9, 28
    blt $t1, $t9, rb_row_loop

    jr $ra

########### helper
print_board:
    li $t0, 0          # row index = 0
pb_row_loop:
    li $t1, 0          # col index = 0
pb_col_loop:
    # Calculate offset: (row * 16 + col) * 4
    mul $t2, $t0, 16
    add $t2, $t2, $t1
    sll $t2, $t2, 2

    la $t3, Board
    add $t3, $t3, $t2
    lw $a0, 0($t3)

    li $v0, 1          # syscall 1: print int
    syscall

    # print space
    li $a0, 32         # ASCII ' '
    li $v0, 11         # syscall 11: print char
    syscall

    addi $t1, $t1, 1
    li $t4, 16
    blt $t1, $t4, pb_col_loop

    # print newline after each row
    li $a0, 10         # ASCII newline
    li $v0, 11
    syscall

    addi $t0, $t0, 1
    li $t4, 28
    blt $t0, $t4, pb_row_loop

    jr $ra

