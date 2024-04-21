.text
.global main

main:
     # push the stack
     SUB sp, sp, #4
     STR lr, [sp]

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

     encryptPlaintext:

     encryptPlaintextFile:

     decryptCiphertext:

     decryptCiphertextFile:
    
     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr
.data
     pubKeyFile: .asciz "key.pub"
     privKeyFile: .asciz "key"
     keyFmtStr: .asciz "%x"
     pubKeyFileStr: .byte 0
     privKeyFileStr: .byte 0
     pubExpE: .word 0
     privExp: .word 0
     pVal: .word 0
     qVal: .word 0
     plaintext: .word 0
     ciphertext: .word 0
     plaintextFileName: .word 0
     ciphertextFileName: .word 0
     actionChoice: .word 0
     intFmt: .asciz "%d"
     promptP: .asciz "\nPlease enter your P value: "
     promptQ: .asciz "\nPlease enter your Q value: "
     promptE: .asciz "\nPlease enter your public exponenet E: "
     introPrompt: .asciz "\n=== Small key size RSA generation ===\nPlease prepare the following information:\n- Positive integers P and Q such that P & Q are both prime\n- Public key value e s.t. 1 < e < Φ(n) and e is co-prime to Φ(n) [ gcd(e, Φ(n)) = 1 ]\n"
     promptAction: .asciz "\Please enter 1 to generate keys\n2 to encrypt plaintext\n3 to encrypt plaintext file\n4 to decrypt ciphertext\n5 to decrypt ciphertext file"
# END main
