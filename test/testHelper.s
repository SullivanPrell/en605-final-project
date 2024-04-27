# START read_array_expect_true_helper
.text
.global read_array_expect_true_helper
# Helper function for the rust test, this supplies the filename
read_array_expect_true_helper:
    PUSH {lr}

    LDR r0, =filenameRA // load filename
    BL readArray // read array in file
    MOV r2, r1 // move length
    MOV r1, r0 // move array
    LDR r0, =fileWriteRA // load filename
    BL writeArray // write to file
    
    POP {pc}
.data
    filenameRA: .asciz "encrypted-read_array_expect_true.txt"
    fileWriteRA: .asciz "encrypted-read_array_expect_true_helper.txt"
# END read_array_expect_true_helper

# START string_to_array_expect_true_helper
.text
.global string_to_array_expect_true_helper
string_to_array_expect_true_helper:
    PUSH {lr}

    LDR r0, =stringToArr // load string
    BL strlen // get length
    MOV r2, r0 // move length

    MOV r1, r2 // move length
    LDR r0, =stringToArr // load string
    BL stringToArray // convert string to array
    MOV r2, r1 // move array length
    MOV r1, r0 // move array
    LDR r0, =fileWriteStr // load filename
    BL writeArray // write to file

    POP {pc}
.data
    stringToArr: .asciz "hello plaintext"
    fileWriteStr: .asciz "stringToArray-string_to_array_expect_true_helper.txt"
# END string_to_array_expect_true_helper

# START encrypt_expect_true_helper
.text
.global encrypt_expect_true_helper
encrypt_expect_true_helper:
    PUSH {r4, r5, lr}

    LDR r2, =pub // key
    LDR r2, [r2]
    LDR r3, =mod // mod
    LDR r3, [r3]
    LDR r0, =arrayPlaintext // load plaintext
    MOV r1, #15 // move length of plaintext

    BL processArray // process plaintext
    MOV r4, r1 // move length
    # write array to file
    MOV r2, r1 // move length
    MOV r1, r0 // move array
    LDR r0, =fnameEncrypt // load filename
    BL writeArray // write to file
    MOV r0, r4 // move length
    
    POP {r4, r5, pc}
.data
    fnameEncrypt: .asciz "encrypted-encrypt_expect_true_helper.txt"
    pub: .word 557
    mod: .word 1763
    arrayPlaintext:
        .word 104 
        .word 101 
        .word 108 
        .word 108 
        .word 111 
        .word 32 
        .word 112 
        .word 108 
        .word 97 
        .word 105 
        .word 110 
        .word 116 
        .word 101 
        .word 120 
        .word 116
# END encrypt_expect_true_helper

# START decrypt_expect_true_helper
.text
.global decrypt_expect_true_helper
decrypt_expect_true_helper:
    PUSH {r4, r5, lr}

    LDR r2, =priv // key
    LDR r2, [r2]
    LDR r3, =mod // mod
    LDR r3, [r3]
    LDR r0, =arrayCiphertext // load ciphertext
    MOV r1, #15 // move ciphertext length

    BL processArray // process ciphertext
    MOV r4, r1 // move length
    # write array to file
    MOV r2, r1 // move length
    MOV r1, r0 // move array
    LDR r0, =fnameDecrypt // load filename
    BL writeArray // write to file
    MOV r0, r4

    POP {r4, r5, pc}
.data
    fnameDecrypt: .asciz "plaintext-decrypt_expect_true_helper.txt"
    priv: .word 1493
    mod1: .word 1763
    arrayCiphertext:
        .word 263 
        .word 762 
        .word 309 
        .word 309 
        .word 1715 
        .word 237 
        .word 1094 
        .word 309 
        .word 1741 
        .word 373 
        .word 1218 
        .word 235 
        .word 762 
        .word 3 
        .word 235

# END decrypt_expect_true_helper
