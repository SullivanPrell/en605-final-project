use libloading::{Library, Symbol};

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
            let result = cpubexp(41, 43, 557); // p = 857 | q = 449 | e = 285457
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
}
