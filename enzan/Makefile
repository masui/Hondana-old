all:
	ruby marshal_shelfbooks > marshal.shelfbooks
	ruby marshal_bookinfo > marshal.bookinfo
data.h: marshal2c marshal.shelfbooks
	ruby marshal2c > data.h
