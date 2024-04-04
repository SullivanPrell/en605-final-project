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
