.text
.global main
main:
     PUSH {r4, r5, r6, lr}

     # prompt user
     LDR r0, =promptAction
     BL printf

     # get user choice
     LDR r0, =intFmt
     LDR r1, =actionChoice
     BL scanf

     # respond to choice
     LDR r0, =actionChoice
     LDR r0, [r0]
     CMP r0, #1
     BNE Else1
         BL generateKeys
         B EndIf

     Else1:
         CMP r0, #2
         BNE Else2
             BL encrypt
             B EndIf

         Else2:
             CMP r0, #3
             BNE Else3
                 # TODO decrypt
                 #BL decrypt
                 B EndIf

             Else3:
                 B inputError
     EndIf:
     B exit

     inputError:
          LDR r0, =errorMsg
          BL printf
          B exit

     exit:
     POP {r4, r5, r6, pc}
.data
     intFmt: .asciz "%d"
     errorMsg: .asciz "\nError: invalid selection \n"
     promptAction: .asciz "\Please enter:\n1 - to generate keys\n2 - to encrypt plaintext\n3 - to decrypt ciphertext (in progress)\nSelection: "
     actionChoice: .word 0
# END main
