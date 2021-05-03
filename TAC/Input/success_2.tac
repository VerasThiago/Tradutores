.table
.code
main:
	scani $0
	scani $1
__2_if:
	slt $1023, $0, $1
	brz __3_else, $1023
	add $1022, $0, 90000
	println $1022
	jump __3_else_end
__3_else:
__0_if:
	slt $1021, $1, $0
	brz __1_else, $1021
	sub $1020, $1, 350000
	println $1020
	jump __1_else_end
__1_else:
	println 157
__1_else_end:
__3_else_end:
	nop
