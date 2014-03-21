#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "freqlist.h"
#include "data.h"
#include "search.h"

typedef enum {
	BOOK, SHELF
} Kind;

typedef enum {
	SEARCH, ADD, SUB, SIMILAR
} Command;


typedef struct {
	int ind;
	float score;
} Entry;

int compare(const void *a, const void *b)
{
	float aa = ((Entry*)a)->score;
	float bb = ((Entry*)b)->score;
	return bb > aa ? 1 : aa == bb ? 0 : -1;
}

FreqList *calc(Command command, Kind inputkind, Kind outputkind, FreqList *fl)
{
	int i;
	FreqList *result;
	if(outputkind == BOOK){
		if(inputkind == SHELF){
			if(command == SEARCH){
				return shelf_books[(*fl)[0][0]];
			}
		}
	}
	if(outputkind == SHELF){
		//if(command == SEARCH){
		//	return book_shelves[book_ind(arg.name)];
		//}
		if(inputkind == BOOK){
			if(command == SIMILAR){
				int query_books_length = fl_length(fl);
				Entry *entries = (Entry*)alloca(sizeof(Entry)*nshelves);
				for(i=0;i<nshelves;i++){
					FreqList *books = shelf_books[i];
					int books_length = fl_length(books);
					entries[i].score = intersection_count(fl,books)*1.0/(query_books_length+books_length);
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

/*
FreqList *calc(FLArg arg)
{
	int i;
	FreqList *result;
	if(arg.output == BOOK){
		if(arg.input == SHELF){
			if(arg.command == SEARCH){
				//return shelf_books[(*arg.list[0])[0]];
			}
		}
		//if(arg.input == BOOK){
		//	if(arg.command == SEARCH){
		//		return shelf_books[shelf_ind(arg.name)];
		//	}
		//}
	}
	if(arg.output == SHELF){
		if(arg.command == SEARCH){
			return book_shelves[book_ind(arg.name)];
		}
		if(arg.command == SIMILAR){
			int query_books_length = fl_length(*arg.list);
			score = (float*)alloca(sizeof(float)*nshelves);
			int *ind = (int*)alloca(sizeof(int)*nshelves);
			for(i=0;i<nshelves;i++){
				FreqList *books = shelf_books[i];
				int books_length = fl_length(books);
				score[i] = intersection_count(*arg.list,books)*1.0/(query_books_length+books_length);
				ind[i] = i;
				
			}
			qsort(ind, nshelves, sizeof(int), compare);
			for(i=0;i<10;i++){
				printf("%d %f %s\n",ind[i],score[ind[i]],shelves[ind[i]]);
			}
		}
	}
}
*/

 /*
FreqList *similar_shelves(char *shelf){
	// shelfの本棚に近いものをリストする
	int i;
	FreqList *query_books = shelf_books[shelf_ind(shelf)];
	int query_books_length = fl_length(query_books);
	score = (float*)alloca(sizeof(float)*nshelves);
	int *ind = (int*)alloca(sizeof(int)*nshelves);
	for(i=0;i<nshelves;i++){
		char *shelfname = shelves[i];
		FreqList *books = shelf_books[i];
		int books_length = fl_length(books);
		score[i] = intersection_count(query_books,books)*1.0/(query_books_length+books_length);
		ind[i] = i;
		// printf("%f - %s\n",intersection_count(query_books,books)*1.0/(query_books_length+books_length),shelfname);
	}

	qsort(ind, nshelves, sizeof(int), compare);
	for(i=0;i<10;i++){
		printf("%d %f %s\n",ind[i],score[ind[i]],shelves[ind[i]]);
	}

	return NULL;
}
 */

int main()
{
	int i,j;

	/*
	for(i=0;i<nshelves;i++){
		if(strcmp(shelfnames[i],"増井") == 0){
			break;
		}
	}
	printf("%d\n",i);
	int *bookinds = shelf_books[i];
	for(j=0;bookinds[j]>=0;j++){
		printf("%s\n",isbns[bookinds[j]]);
	}
	*/

    /*
    for(i=0;i<nbooks;i++){
        if(strcmp(isbns[i],"4106100037") == 0){
            break;
        }
    }
    printf("%d\n",i);
    int *shelfinds = book_shelves[i];
    for(j=0;shelfinds[j]>=0;j++){
        printf("%d\n",j);
        printf("%d\n",shelfinds[j]);
        printf("%s\n",shelfnames[shelfinds[j]]);
    }
    */

    /*
    printf("%d\n",search(isbns,"4106100037"));
    printf("%s\n",isbns[search(isbns,"4106100037")]);
    printf("%d\n",search(shelves,"増井"));
    printf("%s\n",shelves[search(shelves,"増井")]);
    printf("%d\n",search(shelves,"asdfasdfxxx"));
    */

    /*
    int bakaind = isbn_ind("4106100037");
    FreqList *bakafl = book_shelves[bakaind];
    */

    /*
    //FreqList *bakafl = make_freqlist(bakashelves);
    dump_freqlist(bakashelves);
    */

    /*
    int webind = isbn_ind("4480062858");
    FreqList *webfl = book_shelves[webind];

    FreqList *ufl = join(webfl,bakafl);

    for(i=0;(*ufl)[i][0]>0;i++){
        int ind = (*ufl)[i][0];
        printf("%s %d\n",shelves[ind],(*ufl)[i][1]);
    }

    printf("%d\n",intersection_count(bakafl,webfl));
    */

    /*
    int masuiind = shelf_ind("増井");
    FreqList *masuifl = shelf_books[masuiind];
    for(i=0;i<fl_length(masuifl);i++){
        int ind = (*masuifl)[i][0];
        int freq = (*masuifl)[i][1];
        printf("%s %d\n",isbns[ind],freq);
    }
    */

	/*
	// 増井の本棚に近いものをリストする
	int masuiind = shelf_ind("増井");
	FreqList *masuifl = shelf_books[masuiind];
	
	int masui_length = fl_length(masuifl);
	for(i=0;i<nshelves;i++){
		FreqList *fl = shelf_books[i];
		int length = fl_length(fl);
		printf("%f - %s\n",intersection_count(masuifl,fl)*1.0/(masui_length+length),shelves[i]);
	}
	*/

	FreqList *fl;

	int ind = shelf_ind("増井");
	Freq freq[2];
	freq[0][0] = ind;
	freq[0][1] = 1;
	freq[1][0] = -1;
	fl = calc(SEARCH,SHELF,BOOK,&freq); // 増井の本棚の本リスト

	fl = calc(SIMILAR,BOOK,SHELF,fl); // 増井の本棚の本リストに近い本棚

	fl = calc(SIMILAR,BOOK,SHELF,shelf_books[shelf_ind("増井")]);
}
