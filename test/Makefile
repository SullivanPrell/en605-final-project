# Specify the compiler and archiver
CC=arm-linux-gnueabihf-gcc
AR=ar

# Compiler and archiver flags
CFLAGS=-g -fPIC
ARFLAGS=rcs
LDFLAGS=-shared

# Specify the output names
OUTPUT=rsa
STATIC_LIB_OUTPUT=libMath.a
SHARED_LIB_OUTPUT=libMath.so

# Default target builds both static and shared libraries and the main executable
all: $(STATIC_LIB_OUTPUT) $(SHARED_LIB_OUTPUT) $(OUTPUT)

# Link the final executable against the static library
$(OUTPUT): totientTest.o $(STATIC_LIB_OUTPUT)
	$(CC) -g -o $@ $^

# Create the static library
$(STATIC_LIB_OUTPUT): libMath.o
	$(AR) $(ARFLAGS) $@ $^

# Create the shared library
$(SHARED_LIB_OUTPUT): libMath.o
	$(CC) $(LDFLAGS) -o $@ $^

# Compile the main object file
totientTest.o: totientTest.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

# Compile the main object file
main.o: ../main.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

# Compile the libMath object file
libMath.o: ../libMath.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

clean: 
	rm *.o *.so *.a rsa
	rm -rf target

test:
	make
	cargo test
