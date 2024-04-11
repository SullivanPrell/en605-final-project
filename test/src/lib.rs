use libloading::{Library, Symbol};

#[cfg(test)]
mod tests {
    use std::env;
    use super::*;

    #[test]
    fn gcd_expect_true() {
        unsafe {
            let lib_math = Library::new("./libMath.so").unwrap();
            let gcd = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"gcd").unwrap();
            let result = gcd(46, 23);
            let result1 = gcd(450, 125);
            assert_eq!(result, 23);
            assert_eq!(result1, 25);
        }
    }

    #[test]
    fn pow_expect_correct() {
        unsafe {
            let lib_math = Library::new("./libMath.so").unwrap();
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
            let lib_math = Library::new("./libMath.so").unwrap();
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
            let lib_math = Library::new("./libMath.so").unwrap();
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
            let lib_math = Library::new("./libMath.so").unwrap();
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
            let lib_math = Library::new("./libMath.so").unwrap();
            let totient = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"totient").unwrap();
            let result = totient(72, 96);
            let result1 = totient(44, 26);
            assert_eq!(result, -1);
            assert_eq!(result1, -1);
        }
    }
}
