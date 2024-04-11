use libloading::{Library, Symbol};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn totient_pq_prime() {
        unsafe {
            let libMath = Library::new("libMath.so").unwrap();
            let totient = libMath.get::<Symbol<extern "C" fn(i32,i32) -> i32>>(b"totient").unwrap();
            let result = totient(73, 97);
            assert_eq!(result, 6984)
        }
    }

    #[test]
    fn totient_pq_not_prime() {
        unsafe {
            let result = totient(72, 96);
            assert_eq!(result, -1)
        }
    }
}
