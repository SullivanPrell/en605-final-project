# File Name: encryptTest.s
# Purpose:   Driver for testing encryption and decryption function

.text
.global main
main:
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]

     # input base
     LDR r0, =prompt1
     BL printf
     LDR r0, =format
     LDR r1, =base
     BL scanf

     # input exponent
     LDR r0, =prompt2
     BL printf
     LDR r0, =format
     LDR r1, =exponent
     BL scanf

     # input modulus
     LDR r0, =prompt3
     BL printf
     LDR r0, =format
     LDR r1, =modulus
     BL scanf

     # process
     LDR r0, =base
     LDR r0, [r0]
     LDR r1, =exponent
     LDR r1, [r1]
     LDR r2, =modulus
     LDR r2, [r2]
     BL process

     # print output
     MOV r1, r0
     LDR r0, =output
     BL printf

     # pop stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr 
.data
     prompt1:  .asciz "Enter base: "
     prompt2:  .asciz "Enter exponent: "
     prompt3:  .asciz "Enter modulus: "
     base:     .word 0
     exponent: .word 0
     modulus:  .word 0
     format:   .asciz "%d"
     output:   .asciz "The output is: %d\n"
