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

	if(inputkind == BOOK){
		if(outputkind == SHELF){
			if(command == SEARCH){ // この本を持っている本棚をリストする
				int len = fl_length(fl1);
				FreqList *shelflist = _book_shelves[(*fl1)[0][0]];
				for(i=0;i<len;i++){
					shelflist = fl_join(shelflist,_book_shelves[(*fl1)[i][0]]);
				}
				return shelflist;
			}
			if(command == ADD){
				FreqList *shelves1 = calc(SEARCH,BOOK,SHELF,fl1,NULL);
				FreqList *shelves2 = calc(SEARCH,BOOK,SHELF,fl2,NULL);
				return calc(ADD,SHELF,SHELF,shelves1,shelves2);
			}
			if(command == SIMILAR){ // 本リストに近い本棚リストを返す
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
				result = (FreqList*)malloc(sizeof(Freq)*(len+1));
				for(i=0;i<len;i++){
					(*result)[i][0] = entries[i].ind;
					(*result)[i][1] = 1;
				}
				(*result)[len][0] = -1;
				return result;
			}
		}
		if(outputkind == BOOK){
			if(command == SEARCH){ // 何もしない
				return fl1;
			}
			if(command == ADD){
				return fl_join(fl1,fl2);
			}
			if(command == SIMILAR){ // 本リストに近い本をリスト?
				FreqList *shelflist = calc(SEARCH,BOOK,SHELF,fl1,fl2);
				return calc(SIMILAR,SHELF,BOOK,shelflist,NULL);
			}
		}
	}
	if(inputkind == SHELF){
		if(outputkind == SHELF){
			if(command == SEARCH){
				return fl1;
			}
			if(command == ADD){
				return fl_join(fl1,fl2);
			}
			if(command == SIMILAR){ // 本棚リストに近い本棚をリスト
				FreqList *isbnlist = calc(SEARCH,SHELF,BOOK,fl1,fl2);
				return calc(SIMILAR,BOOK,SHELF,isbnlist,NULL);
			}
		}
		if(outputkind == BOOK){
			if(command == SEARCH){
				int len = fl_length(fl1);
				FreqList *booklist = _shelf_books[(*fl1)[0][0]];
				for(i=0;i<len;i++){
					booklist = fl_join(booklist,_shelf_books[(*fl1)[i][0]]);
				}
				return booklist;
			}
			if(command == ADD){ // 必要なのか?
				FreqList *books1 = calc(SEARCH,SHELF,BOOK,fl1,NULL);
				FreqList *books2 = calc(SEARCH,SHELF,BOOK,fl2,NULL);
				return calc(ADD,BOOK,BOOK,books1,books2);
			}
			if(command == SIMILAR){ // 本棚リストに近い本リストを返す
				int query_shelves_length = fl_length(fl1);
				ScoreEntry *entries = (ScoreEntry*)alloca(sizeof(ScoreEntry)*nshelves);
				for(i=0;i<nbooks;i++){
					FreqList *shelves = _book_shelves[i];
					int shelves_length = fl_length(shelves);
					entries[i].score = fl_intersection_count(fl1,shelves)*1.0/(query_shelves_length+shelves_length);
					entries[i].ind = i;
					
				}
				qsort(entries, nbooks, sizeof(ScoreEntry), compare);
				int len = min(nbooks,SIMILAR_LIMIT);
				result = (FreqList*)malloc(sizeof(Freq)*(len+1));
				for(i=0;i<len;i++){
					(*result)[i][0] = entries[i].ind;
					(*result)[i][1] = 1;
				}
				(*result)[len][0] = -1;
				return result;
			}
		}
	}

//	if(outputkind == BOOK){
//		if(inputkind == SHELF){
//			if(command == ADD){ // 必要なのか?
//				return NULL;
//			}
//			if(command == SIMILAR){ // 本棚に近い本をさがす? 単にリストするだけ?
//				int nshelves = fl_length(fl1);
//				int len = fl_length(fl1);
//				FreqList *booklist = _shelf_books[(*fl1)[0][0]];
//				for(i=0;i<len;i++){
//					booklist = fl_join(booklist,_shelf_books[(*fl1)[i][0]]);
//				}
//				return booklist;
//			}
//		}
//		if(inputkind == BOOK){
//			if(command == ADD){
//				return fl_join(fl1,fl2);
//			}
//			if(command == SIMILAR){ // 本リストに近い本をリスト?
//				FreqList *shelflist = calc(SIMILAR,BOOK,SHELF,fl1,fl2);
//				return calc(SIMILAR,SHELF,BOOK,shelflist,NULL);
//			}
//		}
//	}
//	if(outputkind == SHELF){
//		if(inputkind == SHELF){
//			if(command == ADD){
//				return fl_join(fl1,fl2);
//			}
//			if(command == SIMILAR){ // 本棚リストに近い本棚をリスト
//				FreqList *isbnlist = calc(SIMILAR,SHELF,BOOK,fl1,fl2);
//				return calc(SIMILAR,BOOK,SHELF,isbnlist,NULL);
//			}
//		}
//		if(inputkind == BOOK){
//			if(command == ADD){
//				return NULL;
//			}
//			if(command == SIMILAR){ // 本リストに近い本棚リストを返す
//				int query_books_length = fl_length(fl1);
//				ScoreEntry *entries = (ScoreEntry*)alloca(sizeof(ScoreEntry)*nshelves);
//				for(i=0;i<nshelves;i++){
//					FreqList *books = _shelf_books[i];
//					int books_length = fl_length(books);
//					entries[i].score = fl_intersection_count(fl1,books)*1.0/(query_books_length+books_length);
//					entries[i].ind = i;
//					
//				}
//				qsort(entries, nshelves, sizeof(ScoreEntry), compare);
//				int len = min(nshelves,SIMILAR_LIMIT);
//				result = (FreqList*)malloc(sizeof(Freq)*(len+1));
//				for(i=0;i<len;i++){
//					(*result)[i][0] = entries[i].ind;
//					(*result)[i][1] = 1;
//				}
//				(*result)[len][0] = -1;
//				return result;
//
//				/*
//				for(i=0;i<SIMILAR_LIMIT;i++){
//					printf("%d %f %s\n",entries[i].ind,entries[i].score,shelves[entries[i].ind]);
//				}
//				*/
//			}
//		}
//	}
}

FreqList *shelves(char *shelfname)
{
	FreqList *result = (FreqList*)malloc(sizeof(Freq)*2);
	(*result)[0][0] = shelf_ind(shelfname);
	(*result)[0][1] = 1;
	(*result)[1][0] = -1;
	return result;
}

FreqList *books(char *isbn)
{
	FreqList *result = (FreqList*)malloc(sizeof(Freq)*2);
	(*result)[0][0] = isbn_ind(isbn);
	(*result)[0][1] = 1;
	(*result)[1][0] = -1;
	return result;
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

	/*
	FreqList *shelflist1 = shelves("yuco");
	FreqList *shelflist2 = shelves("増井");
	FreqList *shelflist3 = calc(ADD,SHELF,SHELF,shelflist1,shelflist2);
	FreqList *list1 = calc(SIMILAR,SHELF,BOOK,shelflist3,NULL);
	*/
	FreqList *shelflist = shelves("増井");
	FreqList *list = calc(SIMILAR,SHELF,SHELF,shelflist,NULL);
	for(i=0;i<fl_length(list);i++){
		int ind = (*list)[i][0];
		printf("%d %s\n",ind,_shelves[ind]);
	}

	/*
	FreqList *list1 = shelf_books("yuco");                 // 'yuco' という本棚の本を取得
	*/
	/*
	FreqList *list2 = calc(SIMILAR,BOOK,SHELF,list1,NULL); // flという本リストに似た本棚リストを取得
	for(i=0;i<fl_length(list2);i++){
		int ind = (*list2)[i][0];
		printf("%d %s\n",ind,_shelves[ind]);
	}
	*/
}
