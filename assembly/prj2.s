! This program executes pow as a test program using the LC 2200 calling convention
! Check your registers ($v0) and memory to see if it is consistent with this program

        ! vector table
vector0:
        .fill 0x00000000                        ! device ID 0
        .fill 0x00000000                        ! device ID 1
        .fill 0x00000000                        ! ...
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000                        ! device ID 15
        ! end vector table

main:	lea $sp, initsp                         ! initialize the stack pointer
        lw $sp, 0($sp)                          ! finish initialization

        lea     $t0, vector0                    ! Install timer interrupt handler into vector table
        lea     $t1, timer_handler
        sw      $t0, 1($t0)
        
        lea     $t0, vector0                    ! Install keyboard interrupt handler into vector table
        lea     $t1, keyboard_handler
        sw      $t0, 2($t0)

        ei                                      ! Enable interrupts

        lea $a0, BASE                           ! load base for pow
        lw $a0, 0($a0)
        lea $a1, EXP                            ! load power for pow
        lw $a1, 0($a1)
        lea $at, POW                            ! load address of pow
        jalr $ra, $at                           ! run pow
        lea $a0, ANS                            ! load base for pow
        sw $v0, 0($a0)

        halt                                    ! stop the program here
        addi $v0, $zero, -1                     ! load a bad value on failure to halt

BASE:   .fill 2
EXP:    .fill 8
ANS:	.fill 0                                 ! should come out to 256 (BASE^EXP)

POW:    addi $sp, $sp, -1                       ! allocate space for old frame pointer
        sw $fp, 0($sp)

        addi $fp, $sp, 0                        ! set new frame pinter
        
        skplt $zero, $a1                        ! check if $a1 is zero (if not, skip the goto)
        goto RET1                               ! if the power is 0 return 1
        skplt $zero, $a0
        goto RET0                               ! if the base is 0 return 0 (otherwise, the goto was skipped)

        addi $a1, $a1, -1                       ! decrement the power

        lea $at, POW                            ! load the address of POW
        addi $sp, $sp, -2                       ! push 2 slots onto the stack
        sw $ra, -1($fp)                         ! save RA to stack
        sw $a0, -2($fp)                         ! save arg 0 to stack
        jalr $ra, $at                           ! recursively call POW
        add $a1, $v0, $zero                     ! store return value in arg 1
        lw $a0, -2($fp)                         ! load the base into arg 0
        lea $at, MULT                           ! load the address of MULT
        jalr $ra, $at                           ! multiply arg 0 (base) and arg 1 (running product)
        lw $ra, -1($fp)                         ! load RA from the stack
        addi $sp, $sp, 2

        goto FIN                                ! return

RET1:   addi $v0, $zero, 1                      ! return a value of 1
        skplt $zero, $v0                        ! convenient use of skplt to get to FIN (0 < 1)

RET0:   add $v0, $zero, $zero                   ! return a value of 0

FIN:	lw $fp, 0($fp)                          ! restore old frame pointer
        addi $sp, $sp, 1                        ! pop off the stack
        jalr $zero, $ra

MULT:   add $v0, $zero, $zero                   ! return value = 0
        addi $t0, $zero, 1                      ! sentinel = 0
AGAIN:  add $v0, $v0, $a0                       ! return value += argument0
        addi $t0, $t0, 1                        ! increment sentinel
        skplt $a1, $t0                          ! if $t0 <= $a1, keep looping
        goto AGAIN                              ! loop again

        jalr $zero, $ra                         ! return from mult

timer_handler:
        addi    $sp, $sp, -1                    ! save $k0
        sw      $k0, 0($sp)                     

        ei                                      ! enable interrupt

        addi    $sp, $sp, -14                    ! save the state of the program
        sw      $at, 14($sp)
        sw      $v0, 13($sp)
        sw      $a0, 12($sp)
        sw      $a1, 11($sp)
        sw      $a2, 10($sp)
        sw      $t0, 9($sp)
        sw      $t1, 8($sp)
        sw      $t2, 7($sp)
        sw      $s0, 6($sp)
        sw      $s1, 5($sp)
        sw      $s2, 4($sp)
        sw      $k0, 3($sp)
        sw      $sp, 2($sp)
        sw      $fp, 1($sp)
        sw      $ra, 0($sp)


        lea     $t0, ticks                      ! increment the counter ticks
        lw      $t1, 0($t0)
        addi    $t2, $t1, 1
        sw      $t2, 0($t0)


        lw      $at, 14($sp)                    ! restore the state of the program
        lw      $v0, 13($sp)
        lw      $a0, 12($sp)
        lw      $a1, 11($sp)
        lw      $a2, 10($sp)
        lw      $t0, 9($sp)
        lw      $t1, 8($sp)
        lw      $t2, 7($sp)
        lw      $s0, 6($sp)
        lw      $s1, 5($sp)
        lw      $s2, 4($sp)
        lw      $k0, 3($sp)
        lw      $sp, 2($sp)
        lw      $fp, 1($sp)
        lw      $ra, 0($sp)
        addi    $sp, $sp, 14

        di                                      ! disable interrupt

        lw      $k0, 0($sp)                     ! restore $k0
        addi 	$sp, $sp, 1

        reti



keyboard_handler:
        addi    $sp, $sp, -1                    ! save $k0
        sw      $k0, 0($sp)                     

        ei                                      ! enable interrupt

        addi    $sp, $sp, -14                    ! save the state of the program
        sw      $at, 14($sp)
        sw      $v0, 13($sp)
        sw      $a0, 12($sp)
        sw      $a1, 11($sp)
        sw      $a2, 10($sp)
        sw      $t0, 9($sp)
        sw      $t1, 8($sp)
        sw      $t2, 7($sp)
        sw      $s0, 6($sp)
        sw      $s1, 5($sp)
        sw      $s2, 4($sp)
        sw      $k0, 3($sp)
        sw      $sp, 2($sp)
        sw      $fp, 1($sp)
        sw      $ra, 0($sp)


        lea     $t0, key_buf_ptr                ! handler code
        lw      $t1, 0($t0)
        in      $t2, 0x2                     
        sw      $t2, 0($t1)
        addi    $t2, $t1, 1
        sw      $t2, 0($t0)


        lw      $at, 14($sp)                    ! restore the state of the program
        lw      $v0, 13($sp)
        lw      $a0, 12($sp)
        lw      $a1, 11($sp)
        lw      $a2, 10($sp)
        lw      $t0, 9($sp)
        lw      $t1, 8($sp)
        lw      $t2, 7($sp)
        lw      $s0, 6($sp)
        lw      $s1, 5($sp)
        lw      $s2, 4($sp)
        lw      $k0, 3($sp)
        lw      $sp, 2($sp)
        lw      $fp, 1($sp)
        lw      $ra, 0($sp)
        addi    $sp, $sp, 14

        di                                      ! disable interrupt

        lw      $k0, 0($sp)                     ! restore $k0
        addi    $sp, $sp, 1

        reti



initsp: .fill 0xA000

ticks:  .fill 0xFFFF
key_buf_ptr: .fill 0xFFE0
