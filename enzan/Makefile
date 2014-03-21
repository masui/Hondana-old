all:
	ruby marshal_shelfbooks > marshal.shelfbooks
	ruby marshal_bookinfo > marshal.bookinfo

main: main.o data.o freqlist.o search.o
	cc -o main main.o data.o freqlist.o search.o

data.c: marshal2c marshal.shelfbooks
	ruby marshal2c > data.c
data.o: data.c data.h
freqlist.o: freqlist.c freqlist.h


