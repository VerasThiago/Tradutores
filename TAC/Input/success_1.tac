.table
	float L_1
	float R_1
	int i_1
	float ans_1
	float mid_2
	float x_5
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
	inttofl $0, 0
	mov L_1, $0
	mov R_1, #0
__2_for:
__2_for_pre_check:
	mov i_1, 0
__2_for_check:
	slt $1, i_1, 100
	brz __2_for_end, $1
	add $3, L_1, R_1
	inttofl $5, 2
	div $4, $3, $5
	mov mid_2, $4
__1_if:
	mul $6, mid_2, mid_2
	sleq $7, $6, #0
	fltoint $7, $7
	brz __1_else, $7
	mov ans_1, mid_2
	mov L_1, mid_2
	jump __1_else_end
__1_else:
	mov R_1, mid_2
__1_else_end:
__2_for_after_statement:
	add $2, i_1, 1
	mov i_1, $2
	jump __2_for_check
__2_for_end:
	return ans_1
	return 0
__0_main:
	param 40
	mov $8, &__0_str
	param $8
	call __printf, 2
	scanf x_5
	param 8
	mov $9, &__1_str
	param $9
	call __printf, 2
	print x_5
	param 3
	mov $10, &__2_str
	param $10
	call __printf, 2
	param x_5
	call calcRaiz, 1
	pop $11
	println $11
	return 0
main:
	call __0_main, 0
