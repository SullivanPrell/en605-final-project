# File Name:   libRSA.s
# Programmers: Rohan Abraham, Sullivan Prellwitz, Tero Suontaka
# Purpose:     Library of general purpose RSA functions

.global cprivexp
# Function: cprivexp
# Purpose:  Calculates the private exponent
#           Calculates multiplicative inverse of public key
#           over ring of integers mod n
# Input:    r0 - public exponent (e)
#           r1 - integer such that gcd(r0,r1) = 1 (phi(n))
# Output:   r0 - private exponent
# Errors:   returns -1 if gcd(r0,r1) != 1
.text
cprivexp:
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]

     # store r4 on stack
     SUB sp, sp, #4
     STR r4, [sp]

     # store r5 on stack
     SUB sp, sp, #4
     STR r4, [sp]

     # store r6 on stack
     SUB sp, sp, #4
     STR r5, [sp]

     # store inputs in r4 and r5
     # to preserve across function calls
     MOV r4, r0
     MOV r5, r1

     # check error condition
     BL gcd
     CMP r0, #1
     MOVNE r0, #-1
     BNE PrivExpEnd
     
     # initialize x
     MOV r6, #1
     PrivExpLoop:
         # 1 + x*phi(n)
         MUL r0, r5, r6
         ADD r0, r0, #1

         # check if e divides 1 + x*phi(n)
         MOV r1, r4
         BL mod
         CMP r0, #0
         BEQ PrivExpEndLoop
         # increment and iterate
         ADD r6, r6, #1
         B PrivExpLoop

     PrivExpEndLoop:
         # calculate private key
         MUL r0, r5, r6
         ADD r0, r0, #1
         MOV r1, r4
         BL __aeabi_idiv
         B PrivExpEnd

     PrivExpEnd:

     # retrieve r6 from stack
     LDR r6, [sp]
     ADD sp, sp, #4

     # retrieve r5 from stack
     LDR r5, [sp]
     ADD sp, sp, #4

     # retrieve r4 from stack
     LDR r4, [sp]
     ADD sp, sp, #4

     # pop stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
# END cprivexp

.global encrypt
# Function: encrypt 
# Purpose:  Encrypts a ASCII character string message using RSA
#           encryption laid out in this library.
# 					The idea below is to follow the formula in assignment description:
#						c = m^e mod n, where:
#							c: cipher text
# 						m: individual plaintext character
# 						e: public key exponent
#								- positive integer, and 1 < e < phi(n), and co-prime to phi(n)
# 						n: calculated modulus for public and private keys (n = p * q)
# Input:    r0 - address of input message (&m[0])
#						r1 - e public key exponent
#						r2 - n calculated modulus
# 					r3 - address of output message
#
# Output:   encrypted output message in address specified by r3
#
.text
encrypt:
	# 
	# Push stack
	SUB sp, sp, #36
	STR lr, [sp]
 	STR r4, [sp, #4]
 	STR r5, [sp, #8]
 	STR r6, [sp, #12]
 	STR r7, [sp, #16]
 	STR r8, [sp, #20]
 	STR r9,	[sp, #24]
 	STR r10,[sp, #28]
 	STR r11,[sp, #32]

	# Store inputs
	# Msg
	MOV r4, r0
	# e exponent
	MOV r5, r1
	# n modulus
	MOV r6, r2
	# Output message address
	MOV r9, r3

	# Loop index
	MOV r7, #0
	# Null character
	MOV r8, #0
	# Space character
	MOV r11, #32

	#
	# Loop input message
	#
	msgStart:
		# Load a byte from message to r10
		LDRB r10, [r4, r7]

		# Check if end of string
		CMP r10, r8
		BEQ msgEnd
	
		# Check if a space character 0x20
		CMP r10, r11
		LDREQ r0, =str64
		STREQ r11, [r9]
		ADDEQ r9, r9, #1
		BEQ outMsgEnd

		# Compute m^e and output to r0
		MOV r0, r10
		MOV r1, r5
		BL pow

		# Compute m^e mod n and output to r0
		MOV r1, r6
		BL mod

		# Convert r0 int to string in str64
		MOV r2, r0
		LDR r0, =str64
		LDR r1, =intStrFormat
		BL sprintf
	
		#
		# Loop output message
		#
		# Output message loop index
		MOV r3, #0
		outMsgStart:
			# Output message base address
			LDR r0, =str64
			LDRB r0, [r0, r3]

			# Check EOS
			CMP r0, r8
			BEQ outMsgEnd

			# Copy over bytes
			STRB r0, [r9]
			ADD r3, r3, #1
			ADD r9, r9, #1
			B outMsgStart
		outMsgEnd:
	
		# Loop back to msg read start
		ADD r7, r7, #1
		B msgStart
	msgEnd:

	# Pop stack
	LDR lr, [sp]
 	LDR r4, [sp, #4]
 	LDR r5, [sp, #8]
 	LDR r6, [sp, #12]
 	LDR r7, [sp, #16]
 	LDR r8, [sp, #20]
 	LDR r9, [sp, #24]
 	LDR r10,[sp, #28]
 	LDR r11,[sp, #32]
	ADD sp, sp, #36
	MOV pc, lr

.data
	str64: 				.space 64
	intStrFormat: .asciz "%d"
# END encrypt 

