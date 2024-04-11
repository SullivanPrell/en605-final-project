use std::env;

fn main() {
    let current_dir = env::current_dir().unwrap();

    // Tell cargo to link the static library `libMath`
    println!("cargo:rustc-link-search=native={}",current_dir.display());
    println!("cargo:rustc-link-lib=Math");
}
