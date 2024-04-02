# Specify the name of the output file here (without extension)
OUTPUT=bin/rsa

all: $(OUTPUT)

$(OUTPUT): bin/libMath.o bin/main.o
	$(CC) $(LDFLAGS) -g -o $@ $^

bin/main.o: main.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

bin/libMath.o: libMath.s
	$(CC) $(CFLAGS) -g -c -o $@ $<