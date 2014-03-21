#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "freqlist.h"
#include "data.h"
#include "search.h"

FreqList *similar_shelves(char *shelf){
	// shelfの本棚に近いものをリストする
	FreqList *query_books = shelf_books[shelf_ind(shelf)];
	int query_books_length = fl_length(query_books);
	int i;
	for(i=0;i<nshelves;i++){
		char *shelfname = shelves[i];
		FreqList *books = shelf_books[i];
		int books_length = fl_length(books);
		printf("%f - %s\n",intersection_count(query_books,books)*1.0/(query_books_length+books_length),shelfname);
	}
	return NULL;
}

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

	similar_shelves("増井");
}
