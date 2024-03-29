# File Name:   libMath.s
# Programmers: Rohan Abraham,
# Purpose:     Contains library of ARM assembly RSA functions

.text

.global gcd
# Function: gcd
# Purpose:  Computes the greatest common divisor of two integers
# Input:    r0 - first integer to compute gcd of
#           r1 - second integer to compute gcd of
# Output:   r0 - greatest common divisor of two input integers
gcd: 
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]

     # Uses the euclidean algorithm to compute gcd
     GCDStartLoop:
        # Loop control
        # while a != b
        CMP r0, r1
        BEQ GCDEndLoop

        # Loop code
           # if a > b
           BLT GCDElse
              # If block
              SUB r0, r0, r1
              B GCDEndIf
           GCDElse:
              # Else block
              SUB r1, r1, r0
           GCDEndIf:

        B GCDStartLoop
           
     GCDEndLoop:

     # pop stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.global mod
# Function: mod
# Purpose:  Modulo calculation: r0 mod r1 = r0
# Input:    r0 - first integer to compute modulo
#           r1 - second integer to compute modulo
# Output:   r0 - return: modulo value
mod:
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]
   	
     // Math:  a % n = a - floor(a / n) * n
	BL __aeabi_idiv
	
	// Note: __aeabi_idiv stores remainder in r3
	MOV r0, r3

     # pop stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data