.table
	int left_1
	int right_1
	int i_2
	int curr_2
	int prev_2
	int prevPrev_2
	int x_4
	char __0_str [] = "Fibonnaci de "
	char __1_str [] = " = "
	char __3_str [] = "Obrigado, xau"
.code
__printf:
	mov $1022, 0
__while:
	mov $1023, #1
	mov $1023, $1023[$1022]
	print $1023
	sub $1023, $1022, #0
	add $1022, $1022, 1
	brnz __while, $1023
	return
	
__printfln:
	call __printf, 2
	println
	return
fibonacci:
__0_if:
	sleq $0, #0, 1
	brz __0_if_end, $0
	return #0
__0_if_end:
	param 1
	sub $1, #0, 1
	call fibonacci, 1
	pop $2
	mov left_1, $2
	param 2
	sub $3, #0, 2
	call fibonacci, 1
	pop $4
	mov right_1, $4
	add $5, left_1, right_1
	return $5
	return 0
fibonacciDP:
__1_if:
	sleq $6, #0, 1
	brz __1_if_end, $6
	return #0
__1_if_end:
	mov prev_2, 1
	mov prevPrev_2, 0
__2_for:
__2_for_pre_check:
	mov i_2, 2
__2_for_check:
	sleq $7, i_2, #0
	brz __2_for_end, $7
	jump __2_for_statement
__2_for_after_statement:
	add $8, i_2, 1
	mov i_2, $8
	jump __2_for_check
__2_for_statement:
	add $9, prev_2, prevPrev_2
	mov curr_2, $9
	mov prevPrev_2, prev_2
	mov prev_2, curr_2
	jump __2_for_after_statement
__2_for_end:
	return curr_2
	return 0
main:
	scani x_4
	param 13
	mov $10, &__0_str
	param $10
	call __printf, 2
	print x_4
	param 3
	mov $11, &__1_str
	param $11
	call __printf, 2
	param x_4
	call fibonacciDP, 1
	pop $12
	print $12
	print '\n'
	param 13
	mov $13, &__3_str
	param $13
	call __printfln, 2
	nop
