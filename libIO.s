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

# START readKeyFile
.global readKeyFile
#
# Function: readKeyFile
# Purpose:  Parses a user supplied file key file (public or private RSA key)
# Input:    r0 - name of file to read w/out path (file must be in the same location as executable)
# Output:   r0 - exp
#           r1 - totient
#           r2 - mod
# Key format: %d %d %d [exp, totient, mod]
#
.text
readKeyFile:
    PUSH {r4, r5, lr}

    // Open file (C function fopen) save pointer to file in r4
    LDR r1, =keyFileOp
    BL fopen
    MOV r4, r0

    // Check for null file
    CMP r4, #0
    BEQ errKeyFile

    // Parse file (C function fscanf)
    MOV r0, r4
    LDR r1, =keyFile
    LDR r2, =keyFormat
    LDR r3, =keyExp
    LDR r4, =keyTot
    LDR r5, =keyMod
    BL fscanf

    // Close file
    MOV r0, r4
    BL fclose
    B exitReadKey

    errKeyFile:
        LDR r0, =errKeyFileMsg
        BL printf
        B exitReadKey
    
    exitReadKey:
        LDR r0, =keyFile
    POP {r4, r5, pc}
.data
    keyFileOp: .asciz "r"
    errKeyFileMsg: .asciz "\nERROR: NULL FILE\n"
    keyFile: .word 0
    keyFormat: .asciz "%d %d %d"
    keyExp: .word 0
    keyMod: .word 0
    keyTot: .word 0
# END readKeyFile

.global readMessageFile
#
# Function: readMessageFile
# Purpose:  Parses a user supplied file containing a message to a string (can be encrypted or not)
# Input:    r0 - name of file to read w/out path (file must be in the same location as executable)
# Input Limit: message file will only read the first 1024 characters
# Output:   r0 - pointer to string
#
.text
readMessageFile:
    PUSH {r4, r5, lr}

    // Open file (C function fopen) save pointer to file in r4
    LDR r1, =fileOpModeRead
    BL fopen
    MOV r4, r0

    // Check for null file
    CMP r4, #0
    BEQ errReadNullFile

    // Parse file (C function fscanf)
    MOV r2, r4
    MOV r1, #1024
    LDR r0, =fileRead
    BL fgets

    // Close file
    MOV r0, r4
    BL fclose
    B exitReadFile

    errReadNullFile:
        LDR r0, =errReadNullFileMsg
        BL printf
        B exitReadFile
    
    exitReadFile:
        LDR r0, =fileRead
    POP {r4, r5, pc}
.data
    fileOpModeRead: .asciz "r+"
    errReadNullFileMsg: .asciz "\nERROR: NULL FILE\n"
    fileRead: .byte 0
# END readMessageFile

# START writeFile
.global writeFile
#
# Function: writeFile
# Purpose:  Write to a file, name provided by user
# Input:    r0 - name of file to write
# Input:    r1 - pointer to message to write
#
.text
writeFile:
    PUSH {r4, r5, lr}

    // Store message in r5
    MOV r5, r1

    // Open file (C function fopen) save pointer to file in r4
    LDR r1, =fileOpModeWrite
    BL fopen
    MOV r4, r0

    // Check for null file
    CMP r4, #0
    BEQ errWriteFile

    // Write file (C function fprintf)
    MOV r0, r4
    MOV r1, r5
    BL fprintf

    // Close file
    MOV r0, r4
    BL fclose
    B exitWriteFile

    errWriteFile:
        LDR r0, =errWriteFileMsg
        BL printf
        B exitWriteFile
    
    exitWriteFile:
    POP {r4, r5, pc}
.data
    fileOpModeWrite: .asciz "w"
    errWriteFileMsg: .asciz "\nERROR: COULDN'T WRITE TO FILE\n"
# END writeFile

.global writeIntArrayToFile
# Function: writeIntArrayToFile
# Purpose:  Writes an integer array to a file in ASCII
# Input:    r0 - pointer to integer array
#           r1 - size of array
#           r2 - filename 
# Output:   r0 - pointer to string
#           r1 - size of string
.text
writeIntArrayToFile:
    # push stack
    SUB sp, sp, #24
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]
    STR r6, [sp, #12]
    STR r7, [sp, #16]
    STR r8, [sp, #20]

    # register dictionary
    # r4 - pointer to array
    # r5 - size of array
    # r6 - filename
    # r7 - loop counter
    # r8 - file pointer
    MOV r4, r0
    MOV r5, r1
    MOV r6, r2

    // Open file (C function fopen) save pointer to file in r4
    MOV r0, r6
    LDR r1, =writeArryMode
    BL fopen
    MOV r8, r0

    // Check for null file
    CMP r8, #0
    BEQ errWriteArrayFile

    # initialize counter
    MOV r7, #0

    writeToFileLoop:
        # exit if counter >= array size
        CMP r7, r5
        BGE writeToFileLoopEnd

        # get integer from current word
        # write to file
        LDR r2, [r4, r7, lsl #2]
        AND r2, r2, #0xFF
        // Write char to file
        MOV r0, r8
        LDR r1, =charFmt
        BL fprintf

        // Write space to file
        MOV r0, r8
        LDR r1, =charFmt
        MOV r2, #32
        BL fprintf

        # increment and loop
        ADD r7, r7, #1
        B writeToFileLoop    

    errWriteArrayFile:
        LDR r0, =errWriteFileMsg
        BL printf
        B writeToFileLoopEnd
             
    writeToFileLoopEnd:
    // Close file
    MOV r0, r8
    BL fclose
    B exitWriteFile

    # pop stack
    LDR lr, [sp, #0]
    LDR r4, [sp, #4]
    LDR r5, [sp, #8]
    LDR r6, [sp, #12]
    LDR r7, [sp, #16]
    LDR r8, [sp, #20]
    ADD sp, sp, #24
    MOV pc, lr

.data
    writeArryMode: .asciz "w+"
    errWriteFileArrayMsg: .asciz "\nERROR: COULDN'T WRITE TO FILE\n"
    charFmt: .asciz "%c"
# END writeIntArrayToFile

