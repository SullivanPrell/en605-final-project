use std::process::Command;
use std::env;
use std::path::PathBuf;

fn main() {
    let mut root_proj_dir = env::current_dir().unwrap();
    root_proj_dir.pop();
    root_proj_dir.pop();
    let math_lib_asm = root_proj_dir.join("libMath.s");
    // let rsa_lib_asm = root_proj_dir.join("rsaLib.s");


    // Directory where the output object file will be saved
    let out_dir = root_proj_dir.join("bin");
    let math_lib_object = out_dir.join("libMath.o");
    // let rsa_lib_asm = out_dir.join("rsaLib.o");

    // Tell cargo to link the static library `libMath`
    println!("cargo:rustc-link-lib=static=Math");    // Specify the search directory for `libMath.a`
    println!("cargo:rustc-link-search=native={}", out_dir.join("libMath.a").to_str().unwrap());

}
