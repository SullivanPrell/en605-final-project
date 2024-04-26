use libloading::{Library, Symbol};
use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;
use std::env;
use std::fs;
use lipsum::lipsum;

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

    #[test]
    fn pq_mod_expect_correct() {
        unsafe {
            let lib_math = Library::new("./libRSA.so").unwrap();
            let pq_mod = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"pqMod").unwrap();
            let result = pq_mod(2, 2);
            assert_eq!(result, 4);
            let result1 = pq_mod(22, 3);
            assert_eq!(result1, 66);
        }
    }

    #[test]
    fn pow_expect_correct() {
        unsafe {
            let lib_math = Library::new("./libRSA.so").unwrap();
            let pow = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"pow").unwrap();
            let result = pow(2, 2);
            assert_eq!(result, 4);
            let result1 = pow(22, 3);
            assert_eq!(result1, 10648);
        }
    }

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
    fn write_to_file_expect_true() {
        unsafe {
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            
            let write_file = lib_rsa.get::<Symbol<extern "C" fn(*const c_char, *const c_char)>>(b"writeFile").unwrap();
    
            let file_name = CString::new("testWrite.txt").expect("CString::new failed");
            let char_ptr_fname: *const c_char = file_name.as_ptr();
            let message = CString::new("writing some text to a file!!!!!").expect("CString::new failed");
            let char_ptr_message: *const c_char = message.as_ptr();

            write_file(char_ptr_fname, char_ptr_message);
            let file_contents = fs::read_to_string("testWrite.txt").expect("Should have been able to read the file");
            assert_eq!(file_contents, "writing some text to a file!!!!!");
        }
    }

    #[test]
    fn read_from_message_file_expect_true() {
        unsafe {
            let lorem = lipsum(25);
            let lib_rsa = Library::new("./libRSA.so").unwrap();
            
            let read_file = lib_rsa.get::<Symbol<extern "C" fn(*const c_char) -> *const c_char>>(b"readMessageFile").unwrap();
    
            let file_name = CString::new("testRead.txt").expect("CString::new failed");
            let char_ptr_fname: *const c_char = file_name.as_ptr();

            fs::write("testRead.txt", lorem.clone()).expect("Unable to write file");

            let file_contents = read_file(char_ptr_fname);
            // Convert C string (file contents) to Rust String
            let c_string = CStr::from_ptr(file_contents);
            let result = c_string.to_string_lossy().into_owned();
            assert_eq!(result, lorem.clone());
        }
    }

    // TODO: need to fix this its broken
    // #[test]
    // fn string_to_array_expect_true() {
    //     unsafe {
    //         let lib_rsa = Library::new("./libRSA.so").unwrap();
    //         let string_to_array = lib_rsa.get::<Symbol<extern "C" fn(*const c_char) -> ([i32], i32)>>(b"stringToArray").unwrap();
    
    //         let c_string = CString::new("Another string").expect("CString::new failed");
    //         let char_ptr: *const c_char = c_string.as_ptr();
    
    //         let result = string_to_array(char_ptr);
    //         let test_array: [i32; 14] = [65, 110, 111, 116, 104, 101, 114, 32, 115, 116, 114, 105, 110, 103];
    //         assert_eq!(result.0, test_array);
    //     }
    // }
    /* libIO test END */
}
