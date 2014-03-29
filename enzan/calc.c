#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "freq.h"
#include "data.h"
#include "calc.h"

static int compare(const void *p1, const void *p2)
{
	float v1 = ((ScoreEntry*)p1)->score;
	float v2 = ((ScoreEntry*)p2)->score;
	return v2 > v1 ? 1 : v1 == v2 ? 0 : -1;
}

//
// fl = shelf_books[shelf_ind("増井")];
// fl = calc(SIMILAR,BOOK,SHELF,fl);
//
struct Freq *calc(Command command, Kind inputkind, Kind outputkind, struct Freq *list1, struct Freq *list2)
{
	int i;
	struct Freq *result;

	if(inputkind == BOOK){
		if(outputkind == SHELF){
			if(command == SEARCH){ // この本を持っている本棚をリストする
				int len = freq_length(list1);
				struct Freq *shelflist = _book_shelves[list1[0].index];
				for(i=0;i<len;i++){
					shelflist = freq_join(shelflist,_book_shelves[list1[i].index]);
				}
				return shelflist;
			}
			if(command == ADD){
				struct Freq *shelves1 = calc(SEARCH,BOOK,SHELF,list1,NULL);
				struct Freq *shelves2 = calc(SEARCH,BOOK,SHELF,list2,NULL);
				return calc(ADD,SHELF,SHELF,shelves1,shelves2);
			}
			if(command == SIMILAR){ // 本リストに近い本棚リストを返す
				int query_books_length = freq_length(list1);
				ScoreEntry *entries = (ScoreEntry*)alloca(sizeof(ScoreEntry)*nshelves);
				for(i=0;i<nshelves;i++){
					struct Freq *books = _shelf_books[i];
					int books_length = freq_length(books);
					entries[i].score = freq_intersection_count(list1,books)*1.0/(query_books_length+books_length);
					entries[i].ind = i;
					
				}
				qsort(entries, nshelves, sizeof(ScoreEntry), compare);
				int len = min(nshelves,SIMILAR_LIMIT);
				result = (struct Freq*)malloc(sizeof(struct Freq)*(len+1));
				for(i=0;i<len;i++){
					result[i].index = entries[i].ind;
					result[i].freq = 1;
				}
				result[len].index = -1;
				return result;
			}
		}
		if(outputkind == BOOK){
			if(command == SEARCH){ // 何もしない
				return list1;
			}
			if(command == ADD){
				return freq_join(list1,list2);
			}
			if(command == SIMILAR){ // 本リストに近い本をリスト?
				struct Freq *shelflist = calc(SEARCH,BOOK,SHELF,list1,list2);
				return calc(SIMILAR,SHELF,BOOK,shelflist,NULL);
			}
		}
	}
	if(inputkind == SHELF){
		if(outputkind == SHELF){
			if(command == SEARCH){
				return list1;
			}
			if(command == ADD){
				struct Freq *p = freq_join(list1,list2);
				printf("%d\n",p[0].index);
				printf("%d\n",p[1].index);
				printf("%d\n",p[2].index);
				return p;
			}
			if(command == SIMILAR){ // 本棚リストに近い本棚をリスト
				struct Freq *isbnlist = calc(SEARCH,SHELF,BOOK,list1,list2);
				return calc(SIMILAR,BOOK,SHELF,isbnlist,NULL);
			}
		}
		if(outputkind == BOOK){
			if(command == SEARCH){
				int len = freq_length(list1);
				struct Freq *booklist = _shelf_books[list1[0].index];
				for(i=0;i<len;i++){
					booklist = freq_join(booklist,_shelf_books[list1[i].index]);
				}
				return booklist;
			}
			if(command == ADD){ // 必要なのか?
				struct Freq *books1 = calc(SEARCH,SHELF,BOOK,list1,NULL);
				struct Freq *books2 = calc(SEARCH,SHELF,BOOK,list2,NULL);
				return calc(ADD,BOOK,BOOK,books1,books2);
			}
			if(command == SIMILAR){ // 本棚リストに近い本リストを返す
				int query_shelves_length = freq_length(list1);
				ScoreEntry *entries = (ScoreEntry*)alloca(sizeof(ScoreEntry)*nbooks);
				for(i=0;i<nbooks;i++){
					struct Freq *shelves = _book_shelves[i];
					int shelves_length = freq_length(shelves);
					entries[i].score = freq_intersection_count(list1,shelves)*1.0/(query_shelves_length+shelves_length);
					entries[i].ind = i;
				}
				qsort(entries, nbooks, sizeof(ScoreEntry), compare);
				int len = min(nbooks,SIMILAR_LIMIT);
				result = (struct Freq*)malloc(sizeof(struct Freq)*(len+1));
				for(i=0;i<len;i++){
					result[i].index = entries[i].ind;
					result[i].freq = 1;
				}
				result[len].index = -1;

				struct Freq *f;
				int k;
				for(k=0;k<20;k++){
					f = _book_shelves[result[k].index];
					for(i=0;;i++){
						if(f[i].index < 0) break;
					}
				}

				return result;
			}
		}
	}
	return NULL;
}

struct Freq *shelves(int ind)
{
	printf("ind = %d\n",ind);
	struct Freq *result = (struct Freq*)malloc(sizeof(struct Freq)*2);
	result[0].index = ind;
	result[0].freq = 1;
	result[1].index = -1;
	return result;
}

struct Freq *books(int ind)
{
	struct Freq *result = (struct Freq*)malloc(sizeof(struct Freq)*2);
	result[0].index = ind;
	result[0].freq = 1;
	result[1].index = -1;
	return result;
}

int test(struct Freq *p)
{
	printf("p[0].index = %d\n",p[0].index);
	printf("p[1].index = %d\n",p[1].index);
	printf("length = %d\n",freq_length(p));
	freq_dump(p);
}

