# File Name:   libIO.s
# Programmers: Rohan Abraham, Sullivan Prellwitz, Tero Suontaka
# Purpose:     Library of general IO functions for RSA

.global stringToArray
# Function: stringToArray
# Purpose:  Converts a string (byte array) to an array of 32 bit integers
# Input:    r0 - pointer to string
#           r1 - size of string
# Output:   r0 - pointer to integer array
#           r1 - size of array
.text
stringToArray:
     # push stack
     SUB sp, sp, #20
     STR lr, [sp, #0]
     STR r4, [sp, #4]
     STR r5, [sp, #8]
     STR r6, [sp, #12]
     STR r7, [sp, #16]

     # register dictionary
     # r4 - pointer to string
     # r5 - size of string
     # r6 - pointer to array
     # r7 - loop counter
     MOV r4, r0
     MOV r5, r1

     # allocate memory
     # string size words
     # 4 * string size bytes
     LSL r0, r5, #2
     BL malloc
     MOV r6, r0

     # initialize counter
     MOV r7, #0

     stringToArrayLoop:
         # exit if counter >= string size
         CMP r7, r5
         BGE stringToArrayLoopEnd

         LDRB r0, [r4, r7]
         LSL r1, r7, #2
         STR r0, [r6, r1]

         # increment and loop
         ADD r7, r7, #1
         B stringToArrayLoop

     stringToArrayLoopEnd:

     MOV r0, r6
     MOV r1, r5

     # pop stack
     LDR lr, [sp, #0]
     LDR r4, [sp, #4]
     LDR r5, [sp, #8]
     LDR r6, [sp, #12]
     LDR r7, [sp, #16]
     ADD sp, sp, #20
     MOV pc, lr

.data
# END stringToArray

.global arrayToString
# Function: arrayToString
# Purpose:  Converts an integer array to a null delimited string
# Input:    r0 - pointer to integer array
#           r1 - size of array
# Output:   r0 - pointer to string
#           r1 - size of string
.text
arrayToString:
     # push stack
     SUB sp, sp, #20
     STR lr, [sp, #0]
     STR r4, [sp, #4]
     STR r5, [sp, #8]
     STR r6, [sp, #12]
     STR r7, [sp, #16]

     # register dictionary
     # r4 - pointer to array
     # r5 - size of array
     # r6 - pointer to string
     # r7 - loop counter
     MOV r4, r0
     MOV r5, r1

     # allocate memory
     # array size bytes plus 1 for null
     MOV r0, r5
     ADD r0, r0, #1
     BL malloc
     MOV r6, r0

     # initialize counter
     MOV r7, #0

     arrayToStringLoop:
         # exit if counter >= array size
         CMP r7, r5
         BGE arrayToStringLoopEnd

         # get integer from current word
         # store as byte in string
         LSL r1, r7, #2
         LDR r0, [r4, r1]
         STRB r0, [r6, r7]

         # increment and loop
         ADD r7, r7, #1
         B arrayToStringLoop

     arrayToStringLoopEnd:

     # store null in last space
     ADD r7, r7, #1
     MOV r0, #0
     STRB r0, [r6, r7]

     MOV r0, r6
     MOV r1, r5

     # pop stack
     LDR lr, [sp, #0]
     LDR r4, [sp, #4]
     LDR r5, [sp, #8]
     LDR r6, [sp, #12]
     LDR r7, [sp, #16]
     ADD sp, sp, #20
     MOV pc, lr

.data
# END arrayToString
