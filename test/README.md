# Testing project for EN605 Final project
## WARNING: This project targets armv7-unknown-linux-gnueabihf and all assembly is written for 32-bit ARM
### Notes:
- running `make` will create the RSA shared library from the main project assembly files for the test library 
- running `make test` will clear all build artifacts, assemble and link the shared library, build and run the tests
- running `make clean` will clear all build artifacts 
- running `make rust` will install rust using the official install script located here: https://sh.rustup.rs 
- To create the shared library and run the tests separately please run `make` followed by `cargo test`
- After building the shared library running the below command will force rust to run the tests synchronously with maximum compatibility 
    - `RUSTFLAGS=-Fsanitizer=address cargo test -- --test-threads 1 --show-output`