#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "data.h"

int _search(char *a[], char *s, int start, int end){
	if(end-start <= 1){
		return strcmp(s,a[start]) == 0 ? start : -1;
	}
	else {
		int m = (start + end) / 2;
		int cmp = strcmp(s,a[m]);
		if(cmp == 0) return m;
		else if(cmp > 0) return _search(a,s,m,end);
		else return _search(a,s,start,m);
	}
}

int search(char *a[], char *s){
	int len;
	for(len=0;a[len];len++);
	return _search(a,s,0,len);
}

int isbn_ind(char *isbn){
	return search(isbns,isbn);
}

int shelf_ind(char *shelfname){
	return search(shelves,shelfname);
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

	// 増井の本棚に近いものをリストする
	int masuiind = shelf_ind("増井");
	FreqList *masuifl = shelf_books[masuiind];

	int masui_length = fl_length(masuifl);
	for(i=0;i<nshelves;i++){
		FreqList *fl = shelf_books[i];
		int length = fl_length(fl);
		printf("%f - %s\n",intersection_count(masuifl,fl)*1.0/(masui_length+length),shelves[i]);
	}
}


