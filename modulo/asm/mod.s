###############################################################################
#
# Program Name: 
# Author: Tero Suontaka
# Date: 
# Purpose: 
# Functions:
# Inputs: 
#
# Outputs: 
###############################################################################

.text
.global main

	main:
		// Save return to OS on stack
		SUB sp, sp, #4
		STR lr, [sp]

		// [TEST]
		// Print input prompt
		//LDR r0, =inputPromptA
		//BL printf

		// Scan user input A
		// to r2
		LDR r0, =inputFormat
		LDR r1, =inputA
		BL scanf

		// [TEST]
		// Print input prompt
		//LDR r0, =inputPromptA
		//BL printf
		
		// Scan user input A
		// to r2
		LDR r0, =inputFormat
		LDR r1, =inputB
		BL scanf
		
		LDR r0, =inputA
		LDR r0, [r0]
		LDR r1, =inputB
		LDR r1, [r1]

		// Math:  a % n = a - floor(a / n) * n
		BL __aeabi_idiv
	
		// Note: __aeabi_idiv stores remainder in r3
		LDR r1, =inputB
		STR r3, [r1]

		// Print input A prompt
		LDR r0, =outputPrompt
		LDR r1, [r1]
		BL printf
		
		// Return to the OS
		LDR lr, [sp]
		ADD sp, sp, #4
		MOV pc, lr

.data
	inputA: .word 0
	inputB: .word 0
	inputPromptA: .asciz "Please input integer\n"
	// [TEST] output string
	outputPrompt: .asciz "%d\n"
	inputFormat: .asciz "%d"
