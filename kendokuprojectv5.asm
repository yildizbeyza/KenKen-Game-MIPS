.data
	kenKenGame: .word 0, 0, 0, 0
		    .word 0, 0, 0, 0
		    .word 0, 0, 0, 0
		    .word 0, 0, 0, 0
	
	kenKenSolution: .word 4, 2, 1, 3
		    	.word 2, 3, 4, 1
		    	.word 3, 1, 2, 4
		    	.word 1, 4, 3, 2
	
	empty_prompt: .asciiz "x"
	control: .word -1
	size: .word 4
	lineNumber: .word 8
	.eqv DATA_SIZE 4	# Game numbers are integer values
	
	controlNumbers: .asciiz "These are control numbers from left top to right bottom:\n 2-,1,2-\n2,10+\n2-,9+"
	welcome: .asciiz "#####\nWelcome to our Kendoku game, start with inputting row and col values \nthen decide would you like to add (5) or delete(6) a number\nthen input your desired value\n#####\n"
	newLine: .asciiz "\n"
	lineSpace: .asciiz "|"
	space: .asciiz " "
	line: .asciiz "-"
	tableLine: .asciiz "|-------|"
	keyboard_text: .asciiz "Enter a Number:"
	row_text: .asciiz "Row Number:"
	coll_text: .asciiz "Coll Number:"
	number_text: .asciiz "number Number:"		
	test: .asciiz "test line"
	continue_string: .asciiz "Please continue.\n"
	game_over_string: .asciiz "GAME OVER.\n"		
	
					
	number_count: .word 0			#If it is equal to 16, it means table has been filled											
	count: .word 0
	number_row: .word 0
	number_coll: .word 0
	number: .word 0 
	can: .word 3
	.eqv WIDTH 512				#if I want to change this values I cannot use .eqv (it makes them constant) !!!!!!!!!!!!!!!!!!!!
	.eqv HEIGHT 256
	.eqv ORIGIN 0x10010000
	.eqv NUM_PIXELS 100
	
	.eqv WHITE 0x00ffffff
	.eqv GREEN 0x0000ff00
	.eqv BLUE 0x000000ff
	
	.eqv EXIT 113 			# "q", leave the keyboard

	
.macro print_int
 li $v0, 1
 syscall
.end_macro

.macro print_controlNumbers
 li $v0, 4
 la $a0, controlNumbers
 syscall
.end_macro

.macro print_a0			#Use it with caution, controlling a0
 li $v0, 1
 syscall
.end_macro						
.macro print_test			#for testing errors, unexpected sitatuions etc.
 li $v0, 4
 la $a0, test
 syscall
 print_newLine
.end_macro

.macro print_welcome
li $v0, 4
la $a0, welcome
syscall
.end_macro						
																		
.macro print_lineSpace
 li $v0, 4
 la $a0, lineSpace
 syscall
.end_macro

.macro print_tableLine
 li $v0, 4
 la $a0, tableLine
 syscall
 print_newLine
 .end_macro

.macro print_newLine
 la $a0, newLine
 li $v0, 4
 syscall
.end_macro

.macro print_line
 la $a0, line
 li $v0, 4
 syscall
.end_macro

.macro print_row
 la $s1, number_row
 lw $a0, 0($s1)
 #subu $a0, $a0, 48
 li $v0, 1
 syscall
.end_macro

				
.macro print_coll
 la $s1, number_coll
 lw $a0, 0($s1)
 
 #subu $a0, $a0, 48
 li $v0, 1
 syscall
.end_macro				
												
.text
		
main:
 print_welcome
 print_controlNumbers
 loopMain:						#Try to loop the game(This version causing crash)
  #print_line
  jal changeValue
  #print_tableLine
  jal printTable
  jal gameCheck
  addi, $t4, $zero, 0
  beq $zero, $zero, loopMain 	
 

gameCheck:
 lw $t1, number_count
 beq $t1, 16, isItFinished 
 jr $ra

isItFinished:
 li $t1, 0	#k = 0
 li $t0, 0	#i = 0
 lw $t9, size
 j outer_loop

outer_loop:
    
    blt     $t0, $t9, inner_loop
    j       gameIsFinished			#All numbers are equal


inner_loop:
    blt     $t1, $t9, check_elements    # if(k < size) branch to check_elements
    addi    $t0, $t0, 1     # i++
    j       outer_loop                  # jump to outer_loop

check_elements:
    la      $t2, kenKenGame          # load address of array a
    la      $t3, kenKenSolution          # load address of array b
    add     $t4, $t0, $t1   # calculate index: i * size + k
    sll     $t4, $t4, 2     # multiply index by 4 (word size)
    add     $t2, $t2, $t4   # calculate address of a[i][k]
    add     $t3, $t3, $t4   # calculate address of b[i][k]
    lw      $t2, 0($t2)     # load a[i][k]
    lw      $t3, 0($t3)     # load b[i][k]
    bne     $t2, $t3, decrease_can     # if(a[i][k] != b[i][k]) branch to decrease_can

    addi    $t1, $t1, 1
    j       inner_loop

decrease_can:
    lw      $t5, can
    addi    $t5, $t5, -1
    sw      $t5, can

    #addi    $t1, $t1, 1
    j       gameIsNotFinished

finish:
    li      $v0, 10
    syscall
gameIsNotFinished:
    li $v0, 4
    la $a0, continue_string
    syscall
    # Continue the flow of the game
    j poll

gameIsFinished:
     # Print "GAME OVER."
    li $v0, 4
    la $a0, game_over_string
    syscall

    # Stop the game
    j done

poll:
 
 #la $a0, keyboard_text
 #li $v0, 4
 #syscall
 

 lw $t1, 0($t0)
 andi $t1, $t1, 0x0001
 beq $t1, $zero, poll
	
 lw $a0, 4($t0)
 beq $a0, $s0, done
 
 lw $t2, 4($t0)
 subu $t2, $t2, 48			
 add $a0, $zero, $t2
 
 #ble $t4 1, takeCount
 la $t3, count
 lw $t4, 0($t3)
 
 	beq $t4, 3, assign_number
 	beq $t4, 2, assign_control	#now t4 is control number
 	beq $t4, 1, assign_coll
 	beq $t4, 0, assign_row
 	
 print_int
 print_newLine
 j poll
 

 
  
finish_poll:
 li $t1, 0
 sw $t1, count
 j changeValue

done:
 li $v0, 10
 syscall
 
assign_row:

 li $t1, 1
 sw $t1, count
 sw $a0, number_row
 
 li $v0, 4
 la $a0, row_text
 syscall
 print_row
 j poll
assign_coll:

 li $t1, 2
 sw $t1, count
 sw $a0, number_coll
 
 li $v0, 4
 la $a0, coll_text
 syscall
 print_coll
 j poll
 
assign_control:
 li $t1, 3
 sw $t1, count
 sw $a0, control
 					#print_test
 la $t3, control
 lw $t5, 0($t3)
 addi $t1, $zero, 6
 beq $t5, $t1, delNumber		#It's in here because we don't want to get one more input for deleting number
 addi $t1, $zero, 5
 beq $t5, $t1, isItEmpty
 j poll				#for now it is also going to poll, 

isItEmpty:
 la $t7, kenKenGame
 lw $t1, number_row
 lw $t2, size
 lw $t3, number_coll
 
 mul $t4, $t1, $t2
 add $t4, $t4, $t3
 sll $t4, $t4, 2
 add $t5, $t7, $t4
 lw $t6, 0($t5)		# kenkenGame[i][k]

 beq $t6, $zero, Empty
 j NotEmpty 

Empty:
 la $t1, control
 beq $t1, 5, EmptyAdd
 beq $t1, 6, EmptyRemove
 j poll
 
NotEmpty:
 lw $t1, control
 beq $t1, 5, NotEmptyAdd
 beq $t1, 6, NotEmptyRemove
 j poll

EmptyAdd:
 la $t1, number_count					#Can't We just use lw instead of using 2 different registers
 lw $t2, 0($t1)
 addi $t2, $t2, 1
 sw $t2, number_count
 j poll
 
EmptyRemove:
#... Inform user it is already empty.
 j finish_poll
 
NotEmptyAdd:
 #... Inform user it is already has been filled
 j poll

NotEmptyRemove:
 la $t1, number_count					#Can't We just use lw instead of using 2 different registers
 lw $t2, 0($t1)			
 subu $t2, $t2, 1
 sw $t2, number_count
 print_newLine
 j finish_poll
   
delNumber:
 addi $a0, $zero, 0
 sw $a0, number
 j isItEmpty			#Can be used to make our game more efficent
 j finish_poll
 
assign_number:
 sw $a0, number
 
 li $v0, 4
 la $a0, number_text
 syscall
 
 print_newLine
 j finish_poll
 

 
changeValue:
 addi  $s0, $0, EXIT
 lui $t0, 0xFFFF 
 
 beq $t4,0, poll			#maybe it is not working this way?
 
 
 la $t0, kenKenGame
 la $t6, number_row
 lw $t1, 0($t6)
 					#li $t1, 1
 					#li $t2, 5
 
 la $t6, number_coll
 lw $t2, 0($t6)		
 mul $t1, $t1, 4
 add $t1, $t1, $t2
 
 sll $t1, $t1, 2
 add $t3, $t0, $t1
 lw $t4, 0($t3)
 la $t6, number
 lw $t5, 0($t6)	
 					#li $t5, 99
 sw $t5, 0($t3)
 jr $ra



						
printTable:
    la $t0, kenKenGame
    li $t1, 0   # i = 0
    lw $t2, size
    lw $t8, lineNumber
    print_tableLine
    
    firstLoop:
    	
        li $t3, 0   # k = 0
        li $t7, 0   # j = 0
        secondLoop:
            mul $t4, $t1, $t2
            add $t4, $t4, $t3
            sll $t4, $t4, 2
            add $t5, $t0, $t4
            lw $t6, 0($t5)
            li $v0, 1
            move $a0, $t6
            syscall

            print_lineSpace

            addi $t3, $t3, 1
            blt $t3, $t2, secondLoop

        print_newLine

        thirdLoop:
            print_line

            addi $t7, $t7, 1
            blt $t7, $t8, thirdLoop

        print_newLine

        addi $t1, $t1, 1
        blt $t1, $t2, firstLoop

        # Check if the game is finished
        lw $t9, number_count
        li $t4, 16
        beq $t9, $t4, gameIsFinished
	print_tableLine
        jr $ra