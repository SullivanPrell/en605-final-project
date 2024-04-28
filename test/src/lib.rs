use libloading::{Library, Symbol};
use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;
use std::env;
use std::fs;
use lipsum::lipsum;
use std::fs::File;
use std::io::prelude::*;
use std::arch::asm;

#[cfg(test)]
mod tests {
    use std::env;
    use super::*;

    /* 
    * General strategy for calling 32bit ARM functions in Rust:
    * Rust uses snake case for variable names so our math lib is `lib_math` not `libRSA`
    * In the case of integers we will use i32 or a signed 32bit integer value
    * Rust has very strict typing so mapping ARM to Rust is essential
    * Expect easy use of r0-r3 for parameters, outside of this other steps must be taken
    * r0 is the default return register
    */

    /* libMath tests START */

    #[test]
    fn gcd_expect_true() {
        unsafe { // this is marked unsafe since we are calling functions external to rust
            let lib_math = Library::new("./libRSA.so").unwrap(); // Get the library
            let gcd = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"gcd").unwrap(); // get specific function
            
            let result = gcd(46, 23); // call the function
            let result1 = gcd(450, 125); // call the function
             // assert that the result is equivalent to the vlaue on the right 
             // the ! is related to error handling NOT negating the results
            assert_eq!(result, 23);
            assert_eq!(result1, 25);
        }
    }

    // #[test]
    // fn pq_mod_expect_correct() {
    //     unsafe {
    //         let lib_math = Library::new("./libRSA.so").unwrap();
    //         let pq_mod = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"pqMod").unwrap();
            
    //         let result = pq_mod(2, 2);
    //         assert_eq!(result, 4);
    //         let result1 = pq_mod(22, 3);
    //         assert_eq!(result1, 66);
    //     }
    // }

    // #[test]
    // fn pow_expect_correct() {
    //     unsafe {
    //         let lib_math = Library::new("./libRSA.so").unwrap();
    //         let pow = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"pow").unwrap();
            
    //         let result = pow(2, 2);
    //         assert_eq!(result, 4);
    //         let result1 = pow(22, 3);
    //         assert_eq!(result1, 10648);
    //     }
    // }

    #[test]
    fn is_prime_expect_correct() {
        unsafe {
            let lib_math = Library::new("./libRSA.so").unwrap();
            let is_prime = lib_math.get::<Symbol<extern "C" fn(i32) -> i32>>(b"isPrime").unwrap();
            
            let result = is_prime(17);
            let result1 = is_prime(11);
            assert_eq!(result, 1);
            assert_eq!(result1, 1);
        }
    }

    #[test]
    fn is_prime_expect_false() {
        unsafe {
            let lib_math = Library::new("./libRSA.so").unwrap();
            let is_prime = lib_math.get::<Symbol<extern "C" fn(i32) -> i32>>(b"isPrime").unwrap();
            
            let result = is_prime(22);
            let result1 = is_prime(90);
            assert!(result < 1, "is prime broken");
            assert!(result1 < 1, "is prime broken");
        }
    }

    #[test]
    fn totient_pq_prime() {
        unsafe {
            let lib_math = Library::new("./libRSA.so").unwrap();
            let totient = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"totient").unwrap();
            
            let result = totient(73, 97);
            let result1 = totient(197, 1997);
            assert_eq!(result, 6912);
            assert_eq!(result1, 391216);
        }
    }

    #[test]
    fn totient_pq_not_prime() {
        unsafe {
            let lib_math = Library::new("./libRSA.so").unwrap();
            let totient = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"totient").unwrap();
            
            let result = totient(72, 96);
            let result1 = totient(44, 26);
            assert_eq!(result, -1);
            assert_eq!(result1, -1);
        }
    }

    /* libMath tests END */

    /* libRSA tests START */

    #[test]
    fn cpubexp_expect_valid() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let cpubexp = lib_rsa.get::<Symbol<extern "C" fn(i32, i32, i32) -> i32>>(b"cpubexp").unwrap();
            
            let result = cpubexp(41, 43, 557); // p = 41 | q = 43 | e = 557
            assert_eq!(result , 557);
        }
    }

    #[test]
    fn cprivexp_expect_valid() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let cpubexp = lib_rsa.get::<Symbol<extern "C" fn(i32, i32, i32) -> i32>>(b"cpubexp").unwrap();
            let cprivexp = lib_rsa.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"cprivexp").unwrap();
            
            let result = cprivexp(cpubexp(41, 43, 557), 2); 
            assert!(result != -1, "private exponent is incorrect got {}", result);
        }
    }

    #[test]
    fn decrypt_expect_true() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let decrypt = lib_rsa.get::<Symbol<extern "C" fn() -> i32>>(b"decrypt_expect_true_helper").unwrap();
            
            let result = decrypt();
            assert_eq!(result, 15);
            let file_contents = fs::read_to_string("plaintext-decrypt_expect_true_helper.txt").expect("Should have been able to read the file");
            assert_eq!(file_contents, "104 101 108 108 111 32 112 108 97 105 110 116 101 120 116 ");
        }
    }

    #[test]
    fn encrypt_expect_true() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let process_array = lib_rsa.get::<Symbol<extern "C" fn() -> (i32)>>(b"encrypt_expect_true_helper").unwrap();

            let result = process_array();
            assert_eq!(result, 15);
            let file_contents = fs::read_to_string("encrypted-encrypt_expect_true_helper.txt").expect("Should have been able to read the file");
            assert_eq!(file_contents, "263 762 309 309 1715 237 1094 309 1741 373 1218 235 762 3 235 ");
        }
    }

    /* libRSA tests END */

    /* libIO test START */
    #[test]
    fn array_to_string_expect_true() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            // the function takes a pointer to an array of ints (32 bit) and the length of the array
            // in rust this means we pass a pointer to a slice of integers (i32) and the length 
            // the return is more tricky, we get back a C style string which is a pointer to a null terminated char array
            // so we take a couple steps to turn this into a rust string for ease of testing
            let array_to_string = lib_rsa.get::<Symbol<extern "C" fn(&[i32], i32) -> *const c_char>>(b"arrayToString").unwrap();
    
            let test_array: [i32; 14] = [65, 110, 111, 116, 104, 101, 114, 32, 115, 116, 114, 105, 110, 103];
            let char_array_ptr = array_to_string(&test_array, 14);
    
            // Convert C string to Rust String
            let c_string = CStr::from_ptr(char_array_ptr);
            let result = c_string.to_string_lossy().into_owned();
    
            assert_eq!(result, "Another string");
        }
    }

    #[test]
    fn read_array_expect_true() {
        let mut file = File::create("encrypted-read_array_expect_true.txt").expect("Error couldn't create file");
        file.write_all(b"263 762 309 309 1715 237 1094 309 1741 373 1218 235 762 3 235  ").expect("Error couldn't write to file");
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let read_array = lib_rsa.get::<Symbol<extern "C" fn() -> i32>>(b"read_array_expect_true_helper").unwrap();
            
            read_array();
            let file_contents = fs::read_to_string("encrypted-read_array_expect_true_helper.txt").expect("Should have been able to read the file");
            assert_eq!(file_contents, "263 762 309 309 1715 237 1094 309 1741 373 1218 235 762 3 235 ")
        }
    }

    #[test]
    fn write_array_expect_true() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let write_array = lib_rsa.get::<Symbol<extern "C" fn(*const c_char, &[i32], i32)>>(b"writeArray").unwrap();

            let file_name = CString::new("writeArray-tst.txt").expect("CString::new failed");
            let char_ptr_fname: *const c_char = file_name.as_ptr();
            let test_array: [i32; 15] = [389,407,432,432,484,342,142,432,411,447,383,182,407,426,182];
            write_array(char_ptr_fname, &test_array, 15);
            let file_contents = fs::read_to_string("writeArray-tst.txt").expect("Should have been able to read the file");
            assert_eq!(file_contents, "389 407 432 432 484 342 142 432 411 447 383 182 407 426 182 ");
        }
    }

    #[test]
    fn write_to_file_expect_true() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let write_file = lib_rsa.get::<Symbol<extern "C" fn(*const c_char, *const c_char)>>(b"writeFile").unwrap();
    
            let file_name = CString::new("testWrite-tst.txt").expect("CString::new failed");
            let char_ptr_fname: *const c_char = file_name.as_ptr();
            let message = CString::new("writing some text to a file!!!!!").expect("CString::new failed");
            let char_ptr_message: *const c_char = message.as_ptr();

            write_file(char_ptr_fname, char_ptr_message);
            let file_contents = fs::read_to_string("testWrite-tst.txt").expect("Should have been able to read the file");
            assert_eq!(file_contents, "writing some text to a file!!!!!");
        }
    }

    #[test]
    fn string_to_array_expect_true() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            let string_to_array = lib_rsa.get::<Symbol<extern "C" fn()>>(b"string_to_array_expect_true_helper").unwrap();
    
            string_to_array();
            let file_contents = fs::read_to_string("stringToArray-string_to_array_expect_true_helper.txt").expect("Should have been able to read the file");
            assert_eq!(file_contents, "104 101 108 108 111 32 112 108 97 105 110 116 101 120 116 ");
        }
    }
    /* libIO test END */
}
