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

.global cpubexp
#
# Function: cpubexp
# Purpose:  Validates the public exponent s.t. 1 < e < Φ(n) and e is co-prime to Φ(n) [ gcd(e, Φ(n)) = 1 ]
# Input: r0 = p, r1 = q, r2 = e
# Output: r0 = pub exponent
# Output: r0 = -1 error
#
.text
cpubexp:
    PUSH {r4, r5, r6, lr}

    MOV r4, r0 // p & n after totient calc
    MOV r5, r1 // q
    MOV r6, r2 // e

    MOV r0, r2
    CMP r0, #1
    BLT pubError

    # Calc totient and store in r4, error if p or q aren't prime
    MOV r0, r4
    MOV r1, r5
    BL totient
    CMP r0, #-1
    BEQ pubError
    MOV r4, r0

    # Check if e is less than totient of n
    CMP r6, r4
    BGT pubError

    # Load exp and totient and check gcd, error if not 1
    MOV r0, r6
    MOV r1, r4
    BL gcd
    CMP r0, #1
    BEQ pubValid
    B pubError

    pubError:
        MOV r0, #-1
        B end

    pubValid:
        MOV r0, r6
        B end

    end:
    # pop stack
    POP {r4, r5, r6, pc}

.data
# END cpubexp

