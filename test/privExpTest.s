# File Name:  privExpTest.s
# Programmer: Rohan Abraham 
# Purpose:    Driver for testing calculating private exponent

.text
.global main
main:
     # push the stack
     SUB sp, sp, #4
     STR lr, [sp]

     # prompt for first integer
     LDR r0, =prompt1
     BL printf

     # scan for input
     LDR r0, =format
     LDR r1, =e
     BL scanf

     # prompt for second integer
     LDR r0, =prompt2
     BL printf

     # scan for input
     LDR r0, =format
     LDR r1, =tot
     BL scanf

     # compute private exponent
     LDR r0, =e
     LDR r0, [r0]
     LDR r1, =tot
     LDR r1, [r1]
     BL cprivexp

     # print output
     MOV r1, r0
     LDR r0, =output
     BL printf

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
     prompt1: .asciz "Enter public exponent e: "
     prompt2: .asciz "Enter totient phi(n): "
     format:  .asciz "%d"
     e:       .word 0
     tot:     .word 0
     output:  .asciz "The private exponent is %d\n"
     error:   .asciz "Error: gcd(e,phi(n)) must be 1\n"
#END main
