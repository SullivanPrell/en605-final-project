.text
.global main
main:
     PUSH {r4, r5, r6, lr}

     # prompt user
     LDR r0, =promptAction
     BL printf

     # get user choice
     LDR r0, =intFmt
     LDR r1, =actionChoice
     BL scanf

     # respond to choice
     LDR r0, =actionChoice
     LDR r0, [r0]
     CMP r0, #1
     BEQ generateKeys
     CMP r0, #2
     BEQ encryptPlaintext
     CMP r0, #3
     BEQ encryptPlaintextFile
     CMP r0, #4
     BEQ decryptCiphertext
     CMP r0, #5
     BEQ decryptCiphertextFile
     B inputError

     generateKeys:
          # give user info for p,q,e
          LDR r0, =introPrompt
          BL printf
          
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

          # prompt e
          LDR r0, =promptE
          BL printf

          # save e
          LDR r0, =intFmt
          LDR r1, =pubExpE
          BL scanf

          # validate e, -1 if bad news bears
          LDR r0, =pVal
          LDR r0, [r0]
          LDR r1, =qVal
          LDR r1, [r1]
          LDR r2, =pubExpE
          LDR r2, [r2]
          BL cpubexp
          CMP r0, #-1
          BEQ inputError

           # grab mod
          LDR r0, =pVal
          LDR r0, [r0]
          LDR r1, =qVal
          LDR r1, [r1]
          BL pqMod
          LDR r2, =modVal
          STR r0, [r2]

          # calc private exp, -1 if bad news bears, store in privExp
          LDR r0, =pubExpE
          LDR r0, [r0]
          LDR r1, =modVal
          LDR r1, [r1]
          BL cprivexp
          CMP r0, #-1
          BEQ inputError
          LDR r1, =privExp
          STR r0, [r1]
     
          # write public key to file - exp mod
          LDR r0, =pubKeyFileStr
          LDR r1, =keyFmtStr
          LDR r2, =pubExpE
          LDR r2, [r2]
          LDR r3, =modVal
          LDR r3, [r3]
          BL sprintf
          LDR r0, =pubKeyFile
          LDR r1, =pubKeyFileStr
          BL writeFile

          # write private key to file - exp mod
          LDR r0, =privKeyFileStr
          LDR r1, =keyFmtStr
          LDR r2, =privExp
          LDR r2, [r2]
          LDR r3, =modVal
          LDR r3, [r3]
          BL sprintf
          LDR r0, =privKeyFile
          LDR r1, =privKeyFileStr
          BL writeFile

          

          B exit
   
     encryptPlaintext:
          # prompt user
          LDR r0, =promptPlainText
          BL printf

          # clear stdin
          clearStdin:
               BL getchar
               CMP r0, #'\n'
               BEQ cont
               CMP r0, #-1
               BEQ cont
               B clearStdin
          cont:
          # save plaintext
          LDR r0, =plaintext
          MOV r1, #1024
          LDR r2, =stdin
          LDR r2, [r2]
          BL fgets

          # prompt for public key exp
          LDR r0, =promptPubExp
          BL printf

          # store pub exp
          LDR r0, =intFmt
          LDR r1, =pubExpE
          BL scanf

          # prompt for mod
          LDR r0, =promptMod
          BL printf

          # store mod
          LDR r0, =intFmt
          LDR r1, =modVal
          BL scanf

          # get len of plaintext
          LDR r0, =plaintext
          BL strlen
          MOV r1, r0

          # call string to array, array in r0, length in r1
          LDR r0, =plaintext
          BL arrayToString

          # encrypt plaintext
          LDR r2, =pubExpE
          LDR r2, [r2]
          LDR r3, =modVal
          LDR r3, [r3]
          BL processArray
          LDR r2, =ciphertext
          STR r0, [r2]

          # print ciphertext
          LDR r0, =stringFmt
          LDR r1, =ciphertext
          BL printf
          B exit
     encryptPlaintextFile:

     decryptCiphertext:

     decryptCiphertextFile:

     inputError:
          LDR r0, =errorMsg
          BL printf
          B exit

    exit:
     POP {r4, r5, r6, pc}
.data
     pubKeyFile: .asciz "key.pub"
     privKeyFile: .asciz "key"
     keyFmtStr: .asciz "%d %d"
     pubKeyFileStr: .byte 0
     privKeyFileStr: .byte 0
     plaintext: .byte 0
     ciphertext: .byte 0
     pubExpE: .word 0
     privExp: .word 0
     pVal: .word 0
     qVal: .word 0
     modVal: .word 0
     plaintextFileName: .word 0
     ciphertextFileName: .word 0
     actionChoice: .word 0
     intFmt: .asciz "%d"
     stringFmt: .asciz "%s"
     successMsg: .asciz "\nSuccess! Your key has been generated and saved to the current directory. key == private, key.pub == public\n"
     errorMsg: .asciz "\nError please try again \n"
     debugMsg: .asciz "\n debug here \n"
     promptP: .asciz "\nPlease enter your P value: "
     promptQ: .asciz "\nPlease enter your Q value: "
     promptE: .asciz "\nPlease enter your public exponenet E: "
     promptPlainText: .asciz "\nPlease enter your plaintext: "
     promptCipherText: .asciz "\nPlease enter your ciphertext: "
     promptCTFile: .asciz "\nPlease enter your ciphertext file [limit 1024 characters, file should be in the same dir as the executable]: "
     promptPTFile: .asciz "\nPlease enter your plaintext file [limit 1024 characters, file should be in the same dir as the executable]: "
     promptPubExp: .asciz "\nPlease enter your public key exponent: "
     promptPrivExp: .asciz "\nPlease enter your private key exponent: "
     promptMod: .asciz "\nPlease enter your modulo value: "
     promptPubKeyFile: .asciz "\nPlease enter your public key filename [file should be in the same dir as the executable:]"
     promptPrivKeyFile: .asciz "\nPlease enter your private key filename [file should be in the same dir as the executable]: "
     introPrompt: .asciz "\n=== Small key size RSA generation ===\nPlease prepare the following information:\n- Positive integers P and Q such that P & Q are both prime\n- Public key value e s.t. 1 < e < Φ(n) and e is co-prime to Φ(n) [ gcd(e, Φ(n)) = 1 ]\n- Private key calc value x such that gcd(e,x) == Φ(n)\n"
     promptAction: .asciz "\Please enter:\n1 - to generate keys\n2 - to encrypt plaintext\n3 - to encrypt plaintext file\n4 - to decrypt ciphertext\n5 - to decrypt ciphertext file\nSelection: "
# END main
