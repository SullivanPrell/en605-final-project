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

     # prompt for first integer
     LDR r0, =prompt1
     BL printf

     # scan for input
     LDR r0, =format
     LDR r1, =num1
     BL scanf

     LDR r0, =num
     LDR r1, =num1
     LDR r0, [r0]
     LDR r1, [r1]
     BL totient

     # print output
    MOV r0, r1
    LDR r0, =output1
    BL printf

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
     prompt:  .asciz "Enter integer 1: "
     prompt1:  .asciz "Enter integer 2: "
     format:  .asciz "%d"
     num:     .word 0
     num1:     .word 0
     output1: .asciz "%d result\n"
#END main
