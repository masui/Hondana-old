#include <stdio.h>
#include "data.h"

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
}

