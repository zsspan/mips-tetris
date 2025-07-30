.data
ADDR_DSPL: .word 0x10008000  # base address for framebuffer
Board: .space 2048   # 32 rows * 16 columns * 4 bytes = 2048 bytes

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

BINGBONG_piece:
    .byte 1,1,1,1
    .byte 1,0,0,1
    .byte 1,0,0,1
    .byte 1,1,1,1

.text
.globl main
main:
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
    # if (row + col) % 2 == 0, make it gray instead (which is in s4)
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


# NOW WE ARE DONE DRAWING THE BASE USER INTERFACE

start_drawing:
    # Prepare arguments for draw_piece (since there are exactly 4 arguments, we use argument calling convention)
    # PLAY AREA IS (2-31), (2-17)
    la   $a0, BINGBONG_piece  # piece pointer
    li   $a1, 0xbae1cc        # color
    li   $a2, 2               # row position
    li   $a3, 2               # column position
    jal  draw_piece

    la   $a0, I_piece  # piece pointer
    li   $a1, 0x9999ff       # color
    li   $a2, 8               # row position
    li   $a3, 12              # column position
    jal  draw_piece

    la   $a0, Z_piece  # piece pointer
    li   $a1, 0xdae1e9        # color
    li   $a2, 26               # row position
    li   $a3, 12              # column position
    jal  draw_piece
    jal lock_piece

    # Exit
    li $v0, 10
    syscall

# fxn draw_piece(a0, a1, a2, a3):
# Arguments:
#     a0 = pointer to piece data (4x4 bytes)
#     a1 = color (word)
#     a2, a3 = row, column (IN TERMS OF THE PLAYING FIELD)

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

# lock_piece(a0=piece, a2=row, a3=col)
# NOTE: assumes all arguments are still valid in registers (reuse from draw_piece call)
lock_piece:
    # piece pointer = $a0
    # start row = $a2
    # start col = $a3

    li   $t0, 0              # piece row index (0..3)
lp_row_loop:
    li   $t1, 0              # piece col index (0..3)
lp_col_loop:
    mul  $t2, $t0, 4
    add  $t2, $t2, $t1       # offset in piece
    add  $t3, $a0, $t2
    lb   $t4, 0($t3)         # get value of piece[i][j]

    beq  $t4, $zero, lp_skip # skip if empty block

    # Calculate board row/col
    add  $t5, $a2, $t0       # board row
    add  $t6, $a3, $t1       # board col

    # bounds check (optional)
    # (skip if t5 >= 32 or t6 >= 16)

    # offset = (row * 16 + col) * 4
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
