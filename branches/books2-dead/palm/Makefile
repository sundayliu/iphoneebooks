CC=gcc
#CFLAGS=-O3
LD=$(CC)
LDFLAGS=-lz -lobjc -ljpeg -framework CoreFoundation -framework Foundation

all:	pluckertest

pluckertest:	unpluck.o explode.o util.o config.o testmain.o
	$(LD) $(LDFLAGS) -v -o $@ $^

%.o:	%.m 
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -rf *.o *~ pluckertest

