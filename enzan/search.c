#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "data.h"

//
// shelves[], isbns[]からエントリをさがす
//
static int _search(char *a[], char *s, int start, int end){
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

static int search(char *a[], char *s){
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
