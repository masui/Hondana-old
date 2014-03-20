#include <stdio.h>
#include "data.h"

int search(char *a[], char *s){
	int len;
	for(len=0;a[len];len++);
	return _search(a,s,0,len);
}

int _search(char *a[], char *s, int start, int end){
	if(end - start <= 1){
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

main()
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
	printf("%d\n",search(isbns,"4106100037"));
	printf("%s\n",isbns[search(isbns,"4106100037")]);
	printf("%d\n",search(shelves,"増井"));
	printf("%s\n",shelves[search(shelves,"増井")]);
	printf("%d\n",search(shelves,"asdfasdfxxx"));
}

