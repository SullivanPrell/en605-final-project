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

# START writeArray
.global writeArray
# Function: writeArray
# Purpose:  Write 32 bit integer array to a file
# Input:    r0 - Name of file to write
# Input:    r1 - pointer to message to write
# Input:    r2 - length of string
.text
writeArray:
    PUSH {r4, r5, r6, r7, lr}

    // register dictionary
    // r4 - file pointer
    // r5 - array pointer
    // r6 - array length
    // r7 - loop counter
    MOV r5, r1
    MOV r6, r2

    // Open file (C function fopen) save pointer to file in r4
    LDR r1, =fileOpModeWrite
    BL fopen
    MOV r4, r0

    // Check for null file
    CMP r4, #0
    BEQ errWriteArray

    # initialize loop counter
    MOV r7, #0
    writeArrayLoop:
        # exit if loop counter >= array length
        CMP r7, r6
        BGE endWriteArrayLoop
        # load integer from array
        LSL r3, r7, #2
        LDR r2, [r5, r3]
        # write integer to file
        MOV r0, r4
        LDR r1, =writeFormat
        BL fprintf
        ADD r7, r7, #1
        B writeArrayLoop

    endWriteArrayLoop:

    // Close file
    MOV r0, r4
    BL fclose
    B exitWriteArray

    errWriteArray:
        LDR r0, =errWriteFileMsg
        BL printf
        B exitWriteArray
    
    exitWriteArray:
    POP {r4, r5, r6, r7, pc}
.data
    writeFormat: .asciz "%d "
# END writeArray

# START readArray
.global readArray
# Function: readArray
# Purpose:  Read file to 32 bit integer array
# Input:    r0 - name of file to read
# Output:   r0 - pointer to array
# Output:   r1 - array length
.text
readArray:
    PUSH {r4, r5, r6, r7, lr}

    // Open file (C function fopen) save pointer to file in r4
    LDR r1, =fileOpModeRead
    BL fopen
    MOV r4, r0

    // Check for null file
    CMP r4, #0
    BEQ errReadNullArray

    // register dictionary
    // r4 - file pointer
    // r5 - pointer to array
    // r6 - array length
    // r7 - loop counter
    MOV r6, #0
    # check if end of file
    MOV r0, r4
    BL feof
    CMP r0, #0
    BNE endScanFileLoop
    scanFileLoop:
        # scan from file
        MOV r0, r4
        LDR r1, =readFormat
        LDR r2, =num
        BL fscanf
        # check if end of file
        MOV r0, r4
        BL feof
        CMP r0, #0
        BNE endScanFileLoop
        # push to stack
        LDR r0, =num
        LDR r0, [r0]
        PUSH {r0}
        ADD r6, r6, #1
        B scanFileLoop

    endScanFileLoop:

    # allocate memory
    LSL r0, r6, #2
    BL malloc
    MOV r5, r0

    # initialize loop counter
    MOV r7, #1
    storeArrayLoop:
        CMP r7, r6
        BGT endStoreArrayLoop
        # pop stack and store in array from back first
        SUB r1, r6, r7
        LSL r1, r1, #2
        POP {r0}
        STR r0, [r5, r1]
        ADD r7, r7, #1
        B storeArrayLoop

    endStoreArrayLoop:

    // Close file
    MOV r0, r4
    BL fclose
    B exitReadArray

    errReadNullArray:
        LDR r0, =errReadNullFileMsg
        BL printf
        B exitReadArray
    
    exitReadArray:
    MOV r0, r5
    MOV r1, r6
    POP {r4, r5, r6, r7, pc}
.data
    readFormat: .asciz "%d"
    num: .word 0
    fileOpModeRead: .asciz "r"
    errReadNullFileMsg: .asciz "ERROR: NULL FILE\n"
# END readArray

