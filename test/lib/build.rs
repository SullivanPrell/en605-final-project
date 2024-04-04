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


    // Assemble the ARM assembly file into an object file
    Command::new("as")
        .args(&[math_lib_asm.to_str().unwrap(), "-o", math_lib_object.to_str().unwrap()])
        .status()
        .expect("Failed to assemble libMath.s");

    // Tell cargo to tell rustc to link the assembled object file
    println!("cargo:rustc-link-search=native={}", out_dir.to_str().unwrap());
    println!("cargo:rustc-link-lib=static={}", math_lib_object.to_str().unwrap());
    // println!("cargo:rustc-link-lib=static={}", rsa_lib_object.to_str().unwrap());


    // Tell cargo to rerun this script if the assembly file changes
    println!("cargo:rerun-if-changed=libMath.s");
    // println!("cargo:rerun-if-changed=libRSA.s");

}
