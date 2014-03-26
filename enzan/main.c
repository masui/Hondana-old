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
} ScoreEntry;

#define max(x,y) ((x) > (y) ? (x) : (y))
#define min(x,y) ((x) < (y) ? (x) : (y))

int compare(const void *p1, const void *p2)
{
	float v1 = ((ScoreEntry*)p1)->score;
	float v2 = ((ScoreEntry*)p2)->score;
	return v2 > v1 ? 1 : v1 == v2 ? 0 : -1;
}

#define SIMILAR_LIMIT 20
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
			if(command == ADD){ // 必要なのか?
				return NULL;
			}
			if(command == SIMILAR){
				return NULL;
			}
		}
		if(inputkind == BOOK){
			if(command == ADD){
				return fl_join(fl1,fl2);
			}
			if(command == SIMILAR){
				return NULL;
			}
		}
	}
	if(outputkind == SHELF){
		if(inputkind == SHELF){
			if(command == ADD){
				return fl_join(fl1,fl2);
			}
			if(command == SIMILAR){
				return NULL;
			}
		}
		if(inputkind == BOOK){
			if(command == ADD){
				return NULL;
			}
			if(command == SIMILAR){
				int query_books_length = fl_length(fl1);
				ScoreEntry *entries = (ScoreEntry*)alloca(sizeof(ScoreEntry)*nshelves);
				for(i=0;i<nshelves;i++){
					FreqList *books = _shelf_books[i];
					int books_length = fl_length(books);
					entries[i].score = fl_intersection_count(fl1,books)*1.0/(query_books_length+books_length);
					entries[i].ind = i;
					
				}
				qsort(entries, nshelves, sizeof(ScoreEntry), compare);
				int len = min(nshelves,SIMILAR_LIMIT);
				FreqList *shelflist = (FreqList*)malloc(sizeof(Freq)*(len+1));
				for(i=0;i<len;i++){
					(*shelflist)[i][0] = entries[i].ind;
					(*shelflist)[i][1] = 1;
				}
				(*shelflist)[len][0] = -1;
				return shelflist;

				/*
				for(i=0;i<SIMILAR_LIMIT;i++){
					printf("%d %f %s\n",entries[i].ind,entries[i].score,shelves[entries[i].ind]);
				}
				*/
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

	FreqList *list1 = shelf_books("yuco");                 // 'yuco' という本棚の本を取得
	FreqList *list2 = calc(SIMILAR,BOOK,SHELF,list1,NULL); // flという本リストに似た本棚リストを取得
	for(i=0;i<fl_length(list2);i++){
		int ind = (*list2)[i][0];
		printf("%d %s\n",ind,shelves[ind]);
	}
}
