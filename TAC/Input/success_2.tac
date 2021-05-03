.table
.code
fibonacci:
__0_if:
	sleq $1023, #0, 1
	brz __0_if_end, $1023
	return #0
__0_if_end:
	sub $1022, #0, 1
	param $1022
	call fibonacci, 1
	pop $1021
	mov $1, $1021
	sub $1020, #0, 2
	param $1020
	call fibonacci, 1
	pop $1019
	mov $2, $1019
	add $1018, $1, $2
	return $1018
fibonacciDP:
__1_if:
	sleq $1017, #0, 1
	brz __1_if_end, $1017
	return #0
__1_if_end:
	mov $6, 1
	mov $7, 0
__2_for:
__2_for_pre_check:
	mov $4, 2
__2_for_check:
	sleq $1016, $4, #0
	brz __2_for_end, $1016
	jump __2_for_statement
__2_for_after_statement:
	add $1015, $4, 1
	mov $4, $1015
	jump __2_for_check
__2_for_statement:
	add $1014, $6, $7
	mov $5, $1014
	mov $7, $6
	mov $6, $5
	jump __2_for_after_statement
__2_for_end:
	return $5
main:
	scani $8
	param $8
	call fibonacciDP, 1
	pop $1013
	println $1013
	nop
