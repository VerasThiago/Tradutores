.table
.code
main:
	mov $0, 20
	add $1023, 10, 502
	mov $0, $1023
	add $1022, 10, $0
	add $1021, $1022, 30
	add $1020, $1021, 40
	mov $0, $1020
	println $0
	slt $1019, $0, 900
	println $1019
	scani $1
	sub $1018, $0, $1
	mov $1, $1018
	println $1
