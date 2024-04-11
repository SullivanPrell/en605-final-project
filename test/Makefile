# Specify the compiler
CC=arm-linux-gnueabihf-gcc

# Compiler flags
CFLAGS=-g -fPIC
LDFLAGS=-shared

# Specify the output name
SHARED_LIB_OUTPUT=libMath.so

# Default target builds both static and shared libraries and the main executable
all: $(SHARED_LIB_OUTPUT)

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
	rm -f *.o *.so *.a
	rm -rf target

test:
	make
	cargo test
