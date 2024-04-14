# File Name:  stringToArrayTest.s
# Programmer: Rohan Abraham 
# Purpose:    Driver for testing stringToArray function

.text
.global main
main:
     # push the stack
     SUB sp, sp, #4
     STR lr, [sp]

     # convert input to array
     LDR r0, =input
     MOV r1, #8
     BL stringToArray

     MOV r4, r0
     MOV r5, r1

     # loop over array and print
     MOV r6, #0
     loop:
         CMP r6, r5
         BGE endLoop
         LDR r0, =format
         LSL r2, r6, #2
         LDR r1, [r4, r2]
         BL printf
         ADD r6, r6, #1
         B loop

     endLoop:

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
     input:  .asciz "A string"
     format: .asciz "%c\n"
#END main
