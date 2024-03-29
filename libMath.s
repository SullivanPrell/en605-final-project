# File Name:   libMath.s
# Programmers: Rohan Abraham,
# Purpose:     Contains library of ARM assembly RSA functions


.global gcd

# Function: gcd
# Purpose:  Computes the greatest common divisor of two integers
# Input:    r0 - first integer to compute gcd of
#           r1 - second integer to compute gcd of
# Output:   r0 - greatest common divisor of two input integers

.text
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

.data
