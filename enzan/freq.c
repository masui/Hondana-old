//
//
//
#include <stdio.h>
#include <stdlib.h>

#include "freq.h"

int freq_length(struct Freq *list){
	int i;
	for(i=0;list[i].index >= 0;i++);
	return i;
}

int freq_join_count(struct Freq *a, struct Freq *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	for(;;){
		int vala = a[inda].index;
		int valb = b[indb].index;
		if(vala == -1 && valb == -1) break;
		if(vala == -1){
			indb++;
		}
		else if(valb == -1){
			inda++;
		}
		else {
			if(vala == valb){
				inda++;
				indb++;
			}
			else if(vala > valb){
				indb++;
			}
			else {
				inda++;
			}
		}
		count++;
	}
	return count;
}

struct Freq *freq_join(struct Freq *a, struct Freq *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	struct Freq *list = (struct Freq*)malloc(sizeof(struct Freq)*(freq_join_count(a,b)+1));
	for(;;){
		int vala = a[inda].index;
		int valb = b[indb].index;
		if(vala == -1 && valb == -1){
			list[count].index = -1;
			break;
		}
		if(vala == -1){
			list[count].index = valb;
			list[count].freq = b[indb++].freq;
		}
		else if(valb == -1){
			list[count].index = vala;
			list[count].freq = a[inda++].freq; 
		}
		else {
			if(vala == valb){
				list[count].index = vala;
				list[count].freq = a[inda++].freq + b[indb++].freq; 
			}
			else if(vala > valb){
				list[count].index = valb;
				list[count].freq = b[indb++].freq; 
			}
			else {
				list[count].index = vala;
				list[count].freq = a[inda++].freq; 
			}
		}
		count++;
	}
	list[count].index = -1;

	return list;
}

int freq_intersection_count(struct Freq *a, struct Freq *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	for(;;){
		int vala = a[inda].index;
		int valb = b[indb].index;
		if(vala == -1 && valb == -1) break;
		if(vala == -1){
			indb++;
		}
		else if(valb == -1){
			inda++;
		}
		else {
			if(vala == valb){
				inda++;
				indb++;
				count++;
			}
			else if(vala > valb){
				indb++;
			}
			else {
				inda++;
			}
		}
	}
	return count;
}

struct Freq *freq_intersection(struct Freq *a, struct Freq *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	struct Freq *list = (struct Freq*)malloc(sizeof(struct Freq)*(freq_intersection_count(a,b)+1));
	for(;;){
		int vala = a[inda].index;
		int valb = b[indb].index;
		if(vala == -1 && valb == -1){
			list[count].index = -1;
			break;
		}
		if(vala == -1){
			list[count].index = valb;
			list[count].freq = b[indb++].freq; 
		}
		else if(valb == -1){
			list[count].index = vala;
			list[count].freq = a[inda++].freq; 
		}
		else {
			if(vala == valb){
				list[count].index = vala;
				list[count].freq = a[inda++].freq + b[indb++].freq; 
				count++;
			}
			else if(vala > valb){
				list[count].index = valb;
				list[count].freq = b[indb++].freq; 
			}
			else {
				list[count].index = vala;
				list[count].freq = a[inda++].freq; 
			}
		}
	}
	list[count].index = -1;
	return list;
}

void freq_dump(struct Freq *list){
	int i;
	for(i=0;i<freq_length(list);i++){
		printf("freqlist[%d] = %d\n",list[i].index,list[i].freq);
	}
}

#ifdef TEST_FREQ
struct Freq list1[] = {
	{35867, 1},
	{71169, 1},
	{88674, 1},
	{190893, 1},
	{190894, 1},
	{-1, 0}
};

struct Freq list2[] = {
	{5867, 1},
	{1169, 1},
	{8674, 1},
	{190893, 1},
	{190894, 1},
	{-1, 0}
};

main()
{
	//freq_dump(list1);
	//freq_dump(list2);
	struct Freq *list;
	list = freq_join(list1,list2);
	freq_dump(list);
	printf("length = %d\n",freq_length(list));
	printf("-----\n");
	list = freq_intersection(list1,list2);
	freq_dump(list);
	printf("length = %d\n",freq_length(list));
}
#endif
