# Specify the name of the output file here (without extension)
OUTPUT=bin/rsa

all: $(OUTPUT)

$(OUTPUT): bin/libIO.o bin/main.o bin/libMath.o bin/libRSA.o 
	$(CC) $(LDFLAGS) -g -o $@ $^

bin/main.o: main.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

bin/libMath.o: libMath.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

bin/libIO.o: libIO.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

bin/libRSA.o: libRSA.s
	$(CC) $(CFLAGS) -g -c -o $@ $<
