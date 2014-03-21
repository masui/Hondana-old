//
//
//
#include <stdio.h>
#include <stdlib.h>

#include "freqlist.h"

/*
FreqList *make_freqlist(int *a){
	int i,len;
	for(len=0;a[len]>=0;len++);
	FreqList *fl = (FreqList*)malloc(sizeof(Freq)*(len+1));
	for(i=0;i<len;i++){
		(*fl)[i][0] = a[i];
		(*fl)[i][1] = 1;
	}
	(*fl)[len][0] = -1;
	return fl;
}
*/

int fl_length(FreqList *fl){
	int i;
	for(i=0;(*fl)[i][0] >= 0;i++);
	return i;
}

int fl_join_count(FreqList *a, FreqList *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	for(;;){
		int vala = (*a)[inda][0];
		int valb = (*b)[indb][0];
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

FreqList *fl_join(FreqList *a, FreqList *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	FreqList *fl = (FreqList*)malloc(sizeof(Freq)*(fl_join_count(a,b)+1));
	for(;;){
		int vala = (*a)[inda][0];
		int valb = (*b)[indb][0];
		if(vala == -1 && valb == -1){
			(*fl)[count][0] = -1;
			break;
		}
		if(vala == -1){
			(*fl)[count][0] = valb;
			(*fl)[count][1] = (*b)[indb++][1];
		}
		else if(valb == -1){
			(*fl)[count][0] = vala;
			(*fl)[count][1] = (*a)[inda++][1]; 
		}
		else {
			if(vala == valb){
				(*fl)[count][0] = vala;
				(*fl)[count][1] = (*a)[inda++][1] + (*b)[indb++][1]; 
			}
			else if(vala > valb){
				(*fl)[count][0] = valb;
				(*fl)[count][1] = (*b)[indb++][1]; 
			}
			else {
				(*fl)[count][0] = vala;
				(*fl)[count][1] = (*a)[inda++][1]; 
			}
		}
		count++;
	}
	(*fl)[count][0] = -1;

	return fl;
}

int fl_intersection_count(FreqList *a, FreqList *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	for(;;){
		int vala = (*a)[inda][0];
		int valb = (*b)[indb][0];
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

FreqList *fl_intersection(FreqList *a, FreqList *b){
	int count = 0;
	int inda = 0;
	int indb = 0;
	FreqList *fl = (FreqList*)malloc(sizeof(Freq)*(fl_intersection_count(a,b)+1));
	for(;;){
		int vala = (*a)[inda][0];
		int valb = (*b)[indb][0];
		if(vala == -1 && valb == -1){
			(*fl)[count][0] = -1;
			break;
		}
		if(vala == -1){
			(*fl)[count][0] = valb;
			(*fl)[count][1] = (*b)[indb++][1]; 
		}
		else if(valb == -1){
			(*fl)[count][0] = vala;
			(*fl)[count][1] = (*a)[inda++][1]; 
		}
		else {
			if(vala == valb){
				(*fl)[count][0] = vala;
				(*fl)[count][1] = (*a)[inda++][1] + (*b)[indb++][1]; 
				count++;
			}
			else if(vala > valb){
				(*fl)[count][0] = valb;
				(*fl)[count][1] = (*b)[indb++][1]; 
			}
			else {
				(*fl)[count][0] = vala;
				(*fl)[count][1] = (*a)[inda++][1]; 
			}
		}
	}
	(*fl)[count][0] = -1;
	return fl;
}

void fl_dump(FreqList *fl){
	//for(i=0;(*fl)[i][0] >= 0;i++){
	int i;
	for(i=0;i<fl_length(fl);i++){
		printf("freqlist[%d] = %d\n",(*fl)[i][0],(*fl)[i][1]);
	}
}
