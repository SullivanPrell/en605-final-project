# File Name:   libMath.s
# Programmers: Rohan Abraham, Sullivan Prellwitz, Tero Suontaka
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
# END gcd

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

     # store r4 in stack
     SUB sp, sp, #4
     STR r4, [sp]

     # store r5 in stack
     SUB sp, sp, #4
     STR r5, [sp]

     # move r0 and r1 to r4 and r5 for safekeeping
     MOV r4, r0
     MOV r5, r1

     # Math:  a % n = a - floor(a / n) * n
     BL __aeabi_idiv
     # r0 = floor(a/n) * n
     MUL r0, r0, r5
     # r0 = a - floor(a/n) * n
     SUB r0, r4, r0
     
     # load r5 from stack
     LDR r5, [sp]
     ADD sp, sp, #4

     # load r4 from stack
     LDR r4, [sp]
     ADD sp, sp, #4

     # pop stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr
# END mod

.global pow
# Function: pow - base r0, exponent r1: r0^r1
# Purpose:  Power calculation for an integer base r0 to the integer r1 exponent
# Input:    r0 - integer base
#           r1 - integer exponent
# Output:   r0 - return: pow value
pow:
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]
     # fence post
     MOV r2, r0     @ move base -> r2
     SUB r1, r1, #1 @ r1--

powLoop:
     CMP r1, #0     @ Check if we're done
     BEQ endPow     @ break
     MUL r0, r2, r0 @ r0 * r2
     SUB r1, r1, #1 @ r1--
     B powLoop      @ cont.

endPow:
     # pop stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr
# END pow

.global isPrime
# Function: isPrime
# Purpose:  Determines if a number is prime
# Input:    r0 - integer to test
# Output:   r0 - binary value indicating primality
#           returns -1 for invalid values
isPrime:
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]

     # store r4 in stack
     SUB sp, sp, #4
     STR r4, [sp]

     # store r5 in stack
     SUB sp, sp, #4
     STR r5, [sp]

     # check if greater than 1
     CMP r0, #1
     MOVLE r0, #-1
     BLE PrimeEnd
         # loop from 2 to sqrt(n)
         # store r0 in r4 to prevent overwrite from mod
         MOV r4, r0

         # initialize counter
         MOV r5, #2
         PrimeLoop:
             # check if counter is greater than sqrt(n)
             MUL r0, r5, r5
             CMP r0, r4
             # end loop check
             MOVGT r0, #1
             BGT PrimeEnd
                 # check if r5 divides r4
                 MOV r0, r4
                 MOV r1, r5
                 BL mod
                 CMP r0, #0
                 BEQ PrimeEnd
                 # increment counter
                 ADD r5, r5, #1
                 B PrimeLoop

     PrimeEnd:

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

.global totient
# 
# Function: Totient calculation Φ(n) = (p – 1) (q – 1) s.t. p & q are prime
# Purpose:  Calculate and return totient
# Input:    r0 - p
#           r1 - q
# Output:   r0 - return: totient value of (n)
# Output:   r0 == -1 if p or q are NOT prime (error)
totient:
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]

     # store p in r3, q in r4
     MOV r3, r0
     MOV r4, r1
     
     # check prime - p
     BL isPrime
     CMP r0, #0
     BLT errorNotPrime

     # check prime - q
     MOV r0, r4
     BL isPrime
     CMP r0, #0
     BLT errorNotPrime

     # PEMDAS - Parenthesis
     SUB r3, r3, #1
     SUB r4, r4, #1
     # PEMDAS - Multiplication
     MUL r0, r3, r4
     B endTotient

     errorNotPrime:
          MOV r0, #-1
          B endTotient
     
     endTotient:
          # pop stack
          LDR lr, [sp]
          ADD sp, sp, #4
          MOV pc, lr
.data
