//
// 本棚演算をCで高速化する実験
//
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "freq.h"
#include "data.h"
#include "calc.h"

int main()
{
	int i,j;

	/*
	Freq *shelflist1 = shelves("yuco");
	Freq *shelflist2 = shelves("増井");
	Freq *shelflist3 = calc(ADD,SHELF,SHELF,shelflist1,shelflist2);
	Freq *list1 = calc(SIMILAR,SHELF,BOOK,shelflist3,NULL);
	*/
	/*
	Freq *shelflist = shelves("増井");
	Freq *list = calc(SIMILAR,SHELF,SHELF,shelflist,NULL);
	*/
	//Freq *masuishelf = shelves("増井");
	//Freq *yucoshelf = shelves("yuco");
	struct Freq *masuishelf = shelves(100);
	struct Freq *yucoshelf = shelves(200);
	struct Freq *merged = calc(ADD,SHELF,SHELF,masuishelf,yucoshelf);
	struct Freq *masuibooks = calc(SEARCH,SHELF,BOOK,merged,NULL);
	struct Freq *list = calc(SIMILAR,BOOK,SHELF,masuibooks,NULL);
	for(i=0;i<freq_length(list);i++){
		int ind = list[i].index;
		printf("%d %d\n",ind,ind);
	}

	/*
	struct Freq *list1 = shelf_books("yuco");                 // 'yuco' という本棚の本を取得
	*/
	/*
	struct Freq *list2 = calc(SIMILAR,BOOK,SHELF,list1,NULL); // flという本リストに似た本棚リストを取得
	for(i=0;i<freq_length(list2);i++){
		int ind = (*list2)[i][0];
		printf("%d %s\n",ind,_shelves[ind]);
	}
	*/
}
