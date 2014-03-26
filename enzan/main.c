//
// 本棚演算をCで高速化する実験
//
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "freqlist.h"
#include "data.h"
#include "search.h"

typedef enum {
	BOOK=1, SHELF
} Kind;

typedef enum {
	SEARCH, ADD, SUB, SIMILAR
} Command;


typedef struct {
	int ind;
	float score;
} Entry;

int compare(const void *p1, const void *p2)
{
	float v1 = ((Entry*)p1)->score;
	float v2 = ((Entry*)p2)->score;
	return v2 > v1 ? 1 : v1 == v2 ? 0 : -1;
}

//
// fl = shelf_books[shelf_ind("増井")];
// fl = calc(SIMILAR,BOOK,SHELF,fl);
//
FreqList *calc(Command command, Kind inputkind, Kind outputkind, FreqList *fl1, FreqList *fl2)
{
	int i;
	FreqList *result;
	if(outputkind == BOOK){
		if(inputkind == SHELF){
			if(command == SEARCH){
				return _shelf_books[(*fl1)[0][0]];
			}
		}
		if(inputkind == BOOK){
			if(command == ADD){
				return fl_join(fl1,fl2);
			}
		}
	}
	if(outputkind == SHELF){
		if(inputkind == BOOK){
			if(command == SIMILAR){
				int query_books_length = fl_length(fl1);
				Entry *entries = (Entry*)alloca(sizeof(Entry)*nshelves);
				for(i=0;i<nshelves;i++){
					FreqList *books = _shelf_books[i];
					int books_length = fl_length(books);
					entries[i].score = fl_intersection_count(fl1,books)*1.0/(query_books_length+books_length);
					entries[i].ind = i;
					
				}
				qsort(entries, nshelves, sizeof(Entry), compare);
				for(i=0;i<10;i++){
					printf("%d %f %s\n",entries[i].ind,entries[i].score,shelves[entries[i].ind]);
				}
			}
		}
	}
}

FreqList *shelf_books(char *shelfname)
{
	return _shelf_books[shelf_ind(shelfname)];
}

FreqList *book_shelves(char *isbn)
{
	return _book_shelves[isbn_ind(isbn)];
}

int main()
{
	int i,j;

	FreqList *fl;

	fl = shelf_books("yuco");
	fl = calc(SIMILAR,BOOK,SHELF,fl,NULL);
}
