# Specify the name of the output file here (without extension)
OUTPUT=bin/rsa

all: $(OUTPUT)

$(OUTPUT): bin/main.o bin/libIO.o bin/libMath.o bin/libRSA.o 
	$(CC) $(LDFLAGS) -g -o $@ $^

bin/main.o: main.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

bin/libMath.o: libMath.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

bin/libIO.o: libIO.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

bin/libRSA.o: libRSA.s
	$(CC) $(CFLAGS) -g -c -o $@ $<

submission: 
	tar -czvf ./sprellw1-en605-final-project.zip ./submission-dir
