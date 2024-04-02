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
     LDR r1, =a
     BL scanf

     # prompt for second integer
     LDR r0, =prompt2
     BL printf

     # scan for input
     LDR r0, =format
     LDR r1, =b
     BL scanf

     # compute gcd
     LDR r0, =a
     LDR r0, [r0]
     LDR r1, =b
     LDR r1, [r1]
     BL pow

     # print output
     MOV r1, r0
     LDR r0, =output
     BL printf

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
     prompt1: .asciz "Enter first integer a: "
     prompt2: .asciz "Enter second integer b: "
     format:  .asciz "%d"
     a:       .word 0
     b:       .word 0
     output:  .asciz "pow(a,b) = %d\n"
#END main
