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
# END process Φ(n) 

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

# START generateKeys
.global generateKeys

# Function: generateKeys
# Purpose:  Prompt user for primes and public exponent and generate private key
.text
generateKeys:
    PUSH {r4, r5, lr}
    # give user info for p,q,e
    LDR r0, =introPrompt
    BL printf

    promptPrimesLoop:
       # prompt p
       LDR r0, =promptP
       BL printf

       # save p
       LDR r0, =intFmt
       LDR r1, =pVal
       BL scanf

       # prompt q
       LDR r0, =promptQ
       BL printf

       # save q
       LDR r0, =intFmt
       LDR r1, =qVal
       BL scanf

       # calculate totient
       # loop if bad value
       LDR r0, =pVal
       LDR r0, [r0]
       LDR r1, =qVal
       LDR r1, [r1]
       BL totient
       CMP r0, #-1
       BNE primesValidated
           LDR r0, =primeError
           BL printf
           B promptPrimesLoop
 
       primesValidated:
       MOV r4, r0

    # public exponent loop
    promptPubKeyLoop:
        LDR r0, =promptE
        BL printf

        # save e
        LDR r0, =intFmt
        LDR r1, =pubKey
        BL scanf

        # validate e
        LDR r0, =pVal
        LDR r0, [r0]
        LDR r1, =qVal
        LDR r1, [r1]
        LDR r2, =pubKey
        LDR r2, [r2]
        BL cpubexp
        # loop if bad value
        CMP r0, #-1
        BNE pubKeyValidated
            LDR r0, =pubKeyError
            MOV r1, r4
            MOV r2, r4
            BL printf
            B promptPubKeyLoop

        pubKeyValidated:
    
    # calculate private key
    LDR r0, =pubKey
    LDR r0, [r0]
    MOV r1, r4
    BL cprivexp
    MOV r5, r0

    # get modulus
    LDR r0, =pVal
    LDR r0, [r0]
    LDR r1, =qVal
    LDR r1, [r1]
    MUL r1, r0, r1

    # print keys
    LDR r0, =displayMod
    BL printf

    LDR r0, =displayPubKey
    LDR r1, =pubKey
    LDR r1, [r1]
    BL printf

    LDR r0, =displayPrivKey
    MOV r1, r5
    BL printf

    POP {r4, r5, pc}
.data
    introPrompt: .asciz "\n=== Small key size RSA generation ===\nPlease prepare the following information:\n- Positive integers P and Q such that P & Q are both prime\n- Public key value e s.t. 1 < e < Φ(n) and e is co-prime to Φ(n) [ gcd(e, Φ(n)) = 1 ]\n"
    intFmt: .asciz "%d"
    pVal: .word 0
    qVal: .word 0
    promptP: .asciz "Enter first prime: "
    promptQ: .asciz "Enter second prime: "
    primeError: .asciz "ERROR: One of the given integers was not prime\n"
    pubKey: .word 0
    promptE: .asciz "Enter desired public key: "
    pubKeyError: .asciz "ERROR: Invalid public key\nMust be between 1 and %d and coprime to %d\n"
    displayMod: .asciz "Modulus: %d\n"
    displayPubKey: .asciz "Public Key: %d\n"
    displayPrivKey: .asciz "Private Key: %d\n"

# START encrypt
.global encrypt
# Function: encrypt
# Purpose:  Encrypts a message given public key and modulus
.text
encrypt:
     PUSH {r4, r5, lr}

     # get public key
     LDR r0, =promptPubKey
     BL printf

     LDR r0, =intFmt
     LDR r1, =publicKey
     BL scanf

     # get modulus
     LDR r0, =promptModulus
     BL printf

     LDR r0, =intFmt
     LDR r1, =modulus
     BL scanf

     # clear stdin
     clearStdin:
         BL getchar
         CMP r0, #'\n'
         BEQ cont
         CMP r0, #-1
         BEQ cont
         B clearStdin
     cont:

     # prompt text
     LDR r0, =promptText
     BL printf

     # allocate memory
     MOV r0, #255
     BL malloc

     # scan from console
     MOV r1, #255
     LDR r2, =stdin
     LDR r2, [r2]
     BL fgets

     MOV r4, r0

     # get string length
     # subtract one to remove added new line character from fgets
     BL strlen
     SUB r5, r0, #1

     # convert string to array
     MOV r0, r4
     MOV r1, r5
     BL stringToArray

     # encrypt array
     LDR r2, =publicKey
     LDR r2, [r2]
     LDR r3, =modulus
     LDR r3, [r3]
     BL processArray

     # write array to file
     MOV r2, r1
     MOV r1, r0
     LDR r0, =fileName
     BL writeArray

     # print message
     LDR r0, =encryptionDone
     BL printf

     POP {r4, r5, pc}
.data
     promptPubKey: .asciz "Enter public key: "
     publicKey: .word 0
     promptModulus: .asciz "Enter modulus: "
     modulus: .word 0
     promptText: .asciz "Enter text to encrypt: "
     fileName: .asciz "encrypted.txt"
     encryptionDone: .asciz "Encrypted text is in encrypted.txt\n"

# START decrypt
.global decrypt
# Function: decrypt
# Purpose:  Decrypts a message from encrypted.txt given private key and modulus
.text
decrypt:
     PUSH {r4, r5, lr}

     # get public key
     LDR r0, =promptPrivKey
     BL printf

     LDR r0, =intFmt
     LDR r1, =privateKey
     BL scanf

     # get modulus
     LDR r0, =promptModulus
     BL printf

     LDR r0, =intFmt
     LDR r1, =modulus
     BL scanf

     # read array
     LDR r0, =fileName
     BL readArray

     # decrypt array
     LDR r2, =privateKey
     LDR r2, [r2]
     LDR r3, =modulus
     LDR r3, [r3]
     BL processArray

     # convert array to string
     BL arrayToString
     MOV r1, r0
     LDR r0, =plaintextFileName
     BL writeFile

     # print done message
     LDR r0, =decryptionDone
     BL printf

     POP {r4, r5, pc} 
.data
     promptPrivKey: .asciz "Enter private key: "
     privateKey: .word 0
     plaintextFileName: .asciz "plaintext.txt"
     decryptionDone: .asciz "Decrypted text is in plaintext.txt\n"
