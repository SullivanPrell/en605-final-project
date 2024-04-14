use std::env;

fn main() {
    let current_dir = env::current_dir().unwrap(); // get current directory

    // Tell cargo to link the shared library `libRSA.so`
    println!("cargo:rustc-link-search=native={}",current_dir.display()); // .display() == .ToString()
    println!("cargo:rustc-link-lib=RSA"); // Omit the `lib` as rustc will append this to `Math`
}
