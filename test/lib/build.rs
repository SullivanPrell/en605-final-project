use std::process::Command;
use std::env;
use std::path::PathBuf;

fn main() {
    let current_dir = env::current_dir().unwrap();

    // Tell cargo to link the static library `libMath`
    println!("cargo:rustc-link-search=native=./");
    println!("cargo:rustc-link-lib=dylib=customMathLib");
}
