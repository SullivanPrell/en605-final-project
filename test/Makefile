# Set compiler
CC=arm-linux-gnueabihf-gcc

# Compiler flags
CFLAGS=-g -fPIC
LDFLAGS=-shared

# Set shared library name
SHARED_LIB_RSA=libRSA.so

# Default builds the shared library
all: $(SHARED_LIB_RSA)

# Create shared library
$(SHARED_LIB_RSA): libMath.o libRSA.o
	$(CC) $(LDFLAGS) -o $@ $^

# Create shared library
$(SHARED_LIB_OUTPUT_RSA): libRSA.o
	$(CC) $(LDFLAGS) -o $@ $^

# Compile libMath object file
libMath.o: ../libMath.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

# Compile libRSA object file
libRSA.o: ../libRSA.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

# Remove artifacts from building asm and rust
# Forces recompiling when running tests, comment the 2nd line to skip this step
clean: 
	rm -f *.o *.so *.a
	rm -rf target

# Make project and run tests
test:
	make
	cargo test

# Install latest version of rust
rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
