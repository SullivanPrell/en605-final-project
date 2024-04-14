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

.global process
# Function: process 
# Purpose:  Processes the input for RSA encryption and decryption
#           For encryption, use private key as exponent
#           For decryption, use public key as exponent
# Input:    r0 - integer base a
#           r1 - integer exponent b
#           r2 - integer modulus n
# Output:   r0 - integer a^b mod n
.text
process:
     # push stack
     SUB sp, sp, #20
     STR lr, [sp, #0]
     STR r4, [sp, #4]
     STR r5, [sp, #8]
     STR r6, [sp, #12]
     STR r7, [sp, #16]

     # register dictionary
     # r4 - base
     # r5 - exponent
     # r6 - modulus
     # r7 - loop counter
     MOV r4, r0
     MOV r5, r1
     MOV r6, r2
     MOV r7, #0

     # start at exponent of 0
     MOV r0, #1

     # all calculations are done in a word
     # even small powers result in numbers larger than can be stored in a word
     # to save memory, mod is applied at every step of exponentiation

     processLoop:
         # exit if counter >= exponent
         CMP r7, r5
         BGE processLoopEnd
         
         # multiply then mod
         MUL r0, r0, r4
         MOV r1, r6
         BL mod

         # increment and loop
         ADD r7, r7, #1
         B processLoop

     processLoopEnd:

     # pop stack
     LDR lr, [sp, #0]
     LDR r4, [sp, #4]
     LDR r5, [sp, #8]
     LDR r6, [sp, #12]
     LDR r7, [sp, #16]
     ADD sp, sp, #20
     MOV pc, lr

.data
# END process

.global processArray
# Function: processArray
# Purpose:  Processes an integer array for RSA encryption and decryption
#           Applies a^b mod n for all a in array
# Input:    r0 - pointer to integer array
#           r1 - size of array
#           r2 - integer exponent b
#           r3 - integer modulus n
# Output:   r0 - pointer to processed integer array
#           r1 - size of array
.text
processArray:
     # push stack
     SUB sp, sp, #24
     STR lr, [sp, #0]
     STR r4, [sp, #4]
     STR r5, [sp, #8]
     STR r6, [sp, #12]
     STR r7, [sp, #16]
     STR r8, [sp, #20]

     # register dictionary
     # r4 - pointer to array
     # r5 - size of array
     # r6 - exponent
     # r7 - modulus
     # r8 - loop counter
     MOV r4, r0
     MOV r5, r1
     MOV r6, r2
     MOV r7, r3
     MOV r8, #0

     processArrayLoop:
         # exit if counter >= array size
         CMP r8, r5
         BGE processArrayLoopEnd

         # process data in current word
         LSL r1, r8, #2
         LDR r0, [r4, r1]
         MOV r1, r6
         MOV r2, r7
         BL process

         # store processed data in current word
         LSL r1, r8, #2
         STR r0, [r4, r1]

         # increment and loop
         ADD r8, r8, #1
         B processArrayLoop

     processArrayLoopEnd:

     MOV r0, r4
     MOV r1, r5

     # pop stack
     LDR lr, [sp, #0]
     LDR r4, [sp, #4]
     LDR r5, [sp, #8]
     LDR r6, [sp, #12]
     LDR r7, [sp, #16]
     LDR r8, [sp, #20]
     ADD sp, sp, #24
     MOV pc, lr

.data

