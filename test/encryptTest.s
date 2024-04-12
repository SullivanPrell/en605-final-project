.text
.global main
main:
	# push stack
  SUB sp, sp, #4
  STR lr, [sp]
	
	LDR r0, =inputMsg
	MOV r1, #3
	MOV r2, #11
	LDR r3, =outputMsg
	BL encrypt

	# Print encrypted message
	LDR r0, =testOutputFormat
	LDR r1, =outputMsg
	BL printf

	# pop stack
  LDR lr, [sp]
  ADD sp, sp, #4
  MOV pc, lr 
.data
	inputMsg: .asciz "ABC DEF"
	outputMsg: .space 256
	testOutputFormat: .asciz "%s\n"
