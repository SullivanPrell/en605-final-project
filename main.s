.text
.global main
.bss
     file: 
          .space 100
main:
     # push the stack
     SUB sp, sp, #4
     STR lr, [sp]

     LDR r0, =filename
     BL readFileIO

     LDR r1, =file
     STRB r0, [r1]

     LDR r0, =printFmt
     LDR r1, =file
     BL printf

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr

.data
     filename: .asciz "fileread.txt"
     printFmt: .asciz "\n%s\n"

# END main
