# File Name:  isPrimeTest.s
# Programmer: Rohan Abraham 
# Purpose:    Driver for testing GCD function

.text
.global main
main:
     # push the stack
     SUB sp, sp, #4
     STR lr, [sp]

     # prompt for first integer
     LDR r0, =prompt
     BL printf

     # scan for input
     LDR r0, =format
     LDR r1, =num
     BL scanf

     # check if prime
     LDR r0, =num
     LDR r0, [r0]
     BL isPrime

     # print output
     CMP r0, #1
     LDREQ r0, =output1
     LDRNE r0, =output2
     LDR r1, =num
     LDR r1, [r1]
     BL printf

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
     prompt:  .asciz "Enter integer: "
     format:  .asciz "%d"
     num:     .word 0
     output1: .asciz "%d is prime\n"
     output2: .asciz "%d is not prime\n"
#END main
