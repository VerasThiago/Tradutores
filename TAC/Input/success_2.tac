.table
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
	sleq $1021, #0, 1
	brz __0_if_end, $1021
	return #0
__0_if_end:
	sub $1020, #0, 1
	param $1020
	call fibonacci, 1
	pop $1019
	mov $1, $1019
	sub $1018, #0, 2
	param $1018
	call fibonacci, 1
	pop $1017
	mov $2, $1017
	add $1016, $1, $2
	return $1016
	return 0
fibonacciDP:
__1_if:
	sleq $1015, #0, 1
	brz __1_if_end, $1015
	return #0
__1_if_end:
	mov $6, 1
	mov $7, 0
__2_for:
__2_for_pre_check:
	mov $4, 2
__2_for_check:
	sleq $1014, $4, #0
	brz __2_for_end, $1014
	jump __2_for_statement
__2_for_after_statement:
	add $1013, $4, 1
	mov $4, $1013
	jump __2_for_check
__2_for_statement:
	add $1012, $6, $7
	mov $5, $1012
	mov $7, $6
	mov $6, $5
	jump __2_for_after_statement
__2_for_end:
	return $5
	return 0
main:
	scani $8
	param 13
	mov $1011, &__0_str
	param $1011
	call __printf, 2
	print $8
	param 3
	mov $1010, &__1_str
	param $1010
	call __printf, 2
	param $8
	call fibonacciDP, 1
	pop $1009
	print $1009
	print '\n'
	param 13
	mov $1008, &__3_str
	param $1008
	call __printfln, 2
	nop
