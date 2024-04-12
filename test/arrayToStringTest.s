# File Name:  arrayToStringTest.s
# Programmer: Rohan Abraham 
# Purpose:    Driver for testing arrayToString function

.text
.global main
main:
     # push the stack
     SUB sp, sp, #4
     STR lr, [sp]

     # convert array to string
     # output should be "Another string"
     LDR r0, =array
     MOV r1, #14
     BL arrayToString

     # print string
     MOV r1, r0
     LDR r0, =format
     BL printf

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
     array:  .word 65
             .word 110
             .word 111
             .word 116
             .word 104
             .word 101
             .word 114
             .word 32
             .word 115
             .word 116
             .word 114
             .word 105
             .word 110
             .word 103
     format: .asciz "%s\n"
#END main
