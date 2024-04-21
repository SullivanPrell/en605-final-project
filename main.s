.text
.global main

main:
     # push the stack
     SUB sp, sp, #4
     STR lr, [sp]

     LDR r0, =filename
     LDR r1, =writeMessage
     BL writeKeyFile

     # pop the stack
     LDR lr, [sp]
     ADD sp, sp, #4
     MOV pc, lr
.data
     filename: .asciz "writefile.txt"
     writeMessage: .asciz "writing to a file lalalalla"

# END main
