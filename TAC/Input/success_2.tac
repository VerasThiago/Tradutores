.table
.code
main:
	scani $0
	scani $1
__0:
	slt $1023, $0, $1
	brz __0_end, $1023
	add $1022, $0, 90000
	println $1022
__0_end:
__1:
	sleq $1021, $1, $0
	brz __1_end, $1021
	sub $1020, $1, 350000
	println $1020
__1_end:
	return 0
