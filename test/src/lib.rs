use libloading::{Library, Symbol};

#[cfg(test)]
mod tests {
    use std::env;
    use super::*;

    #[test]
    fn totient_pq_prime() {
        unsafe {
            let path = env::current_dir().unwrap();
            println!("The current directory is {}", path.display());
            let lib_math = Library::new("./libMath.so").unwrap();
            let totient = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"totient").unwrap();
            let result = totient(73, 97);
            assert_eq!(result, 6984);
        }
    }

    #[test]
    fn totient_pq_not_prime() {
        unsafe {
            let lib_math = Library::new("./libMath.so").unwrap();
            let totient = lib_math.get::<Symbol<extern "C" fn(i32, i32) -> i32>>(b"totient").unwrap();
            let result = totient(72, 96);
            assert_eq!(result, -1);
        }
    }
}
