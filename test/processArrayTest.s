# File Name: processArrayTest.s
# Purpose:   Driver for testing encryption and decryption of array function

.text
.global main
main:
     # push stack
     SUB sp, sp, #4
     STR lr, [sp]

     # process array
     # exponent - 13
     # modulus - 200
     LDR r0, =array
     MOV r1, #7
     MOV r2, #13
     MOV r3, #200
     BL processArray

     MOV r4, r0
     MOV r5, #0
     MOV r6, #7
     loop:
         CMP r5, r6
         BEQ endLoop

         LSL r1, r5, #2
         LDR r1, [r4, r1]
         LDR r0, =output
         BL printf
         ADD r5, r5, #1
         B loop

     endLoop:

     # pop stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr 
.data
     array:  .word 95
             .word 4
             .word 16
             .word 3
             .word 46
             .word 53
             .word 102 
     output: .asciz "%d\n"
