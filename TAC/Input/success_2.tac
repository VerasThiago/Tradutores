.table
.code
main:
	scani $0
	mov $2, 0
__2_for:
__3_for_pre_check:
	mov $3, 0
__4_for_check:
	slt $1023, $3, $0
	brz __2_for_end, $1023
	jump __6_for_statement
__5_for_after_statement:
	add $1022, $3, 1
	mov $3, $1022
	jump __4_for_check
__6_for_statement:
	scani $1
__0_if:
	slt $1021, $1, 0
	brz __1_else, $1021
	sub $1020, $2, $1
	mov $2, $1020
	jump __1_else_end
__1_else:
	add $1019, $2, $1
	mov $2, $1019
__1_else_end:
	jump __5_for_after_statement
__2_for_end:
	println $2
	nop
