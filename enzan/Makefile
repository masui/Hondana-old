CFLAGS = -I/usr/local/include/CUnit -fPIC
LIBS = /usr/local/lib/libcunit.a

all: test

allx:
	ruby marshal_shelfbooks > marshal.shelfbooks
	ruby marshal_bookinfo > marshal.bookinfo

main: main.o data.o freq.o calc.o
	cc -o main -lcunit main.o data.o freq.o calc.o

data.c: marshal2c marshal.shelfbooks
	ruby marshal2c > data.c
data.o: data.c data.h
freqlist.o: freqlist.c freqlist.h

libenzan.so: data.o freq.o calc.o
	cc -shared -o libenzan.so data.o freq.o calc.o

libfoo.so: foo.o
	cc -shared -o libfoo.so foo.o
foo.o: foo.c
	cc -c foo.c

test: libenzan.so
	ruby enzan.rb


