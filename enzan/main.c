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
				return shelf_books[(*fl1)[0][0]];
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
					FreqList *books = shelf_books[i];
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

int main()
{
	int i,j;

	FreqList *fl;

	/*
	int ind = shelf_ind("増井");
	Freq freq[2];
	freq[0][0] = ind;
	freq[0][1] = 1;
	freq[1][0] = -1;
	fl = calc(SEARCH,SHELF,BOOK,&freq,NULL); // 増井の本棚の本リスト

	fl = calc(SIMILAR,BOOK,SHELF,fl,NULL); // 増井の本棚の本リストに近い本棚

	fl = shelf_books[shelf_ind("増井")];
	fl = calc(SIMILAR,BOOK,SHELF,fl,NULL);
	*/
	/*
	FreqList *fl1 = shelf_books[shelf_ind("増井")];
	FreqList *fl2 = shelf_books[shelf_ind("yuco")];
	FreqList *fl3 = calc(ADD,BOOK,BOOK,fl1,fl2);
	fl_dump(fl3);
	*/
	fl = shelf_books[shelf_ind("yuco")];
	fl = calc(SIMILAR,BOOK,SHELF,fl,NULL);
}
