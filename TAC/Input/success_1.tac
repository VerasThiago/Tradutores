.table
	char __0_str [] = "Digite o valor para encontrar sua raiz: "
	char __1_str [] = "Raiz de "
	char __2_str [] = " = "
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
calcRaiz:
	inttofl $1021, 0
	mov $1, $1021
	mov $2, #0
__2_for:
__2_for_pre_check:
	mov $3, 0
__2_for_check:
	slt $1020, $3, 100
	brz __2_for_end, $1020
	add $1018, $1, $2
	inttofl $1016, 2
	div $1017, $1018, $1016
	mov $5, $1017
__1_if:
	mul $1015, $5, $5
	sleq $1014, $1015, #0
	fltoint $1014, $1014
	brz __1_else, $1014
	mov $4, $5
	mov $1, $5
	jump __1_else_end
__1_else:
	mov $2, $5
__1_else_end:
__2_for_after_statement:
	add $1019, $3, 1
	mov $3, $1019
	jump __2_for_check
__2_for_end:
	return $4
	return 0
__0_main:
	param 40
	mov $1013, &__0_str
	param $1013
	call __printf, 2
	scanf $6
	param 8
	mov $1012, &__1_str
	param $1012
	call __printf, 2
	print $6
	param 3
	mov $1011, &__2_str
	param $1011
	call __printf, 2
	param $6
	call calcRaiz, 1
	pop $1010
	println $1010
	return 0
main:
	call __0_main, 0
