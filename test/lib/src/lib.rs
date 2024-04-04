extern "C" {
    fn totient(p: i32, q: i32) -> i32;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn totient_pq_prime() {
        unsafe {
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
