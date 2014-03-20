//
//
//
#include <stdio.h>
#include <stdlib.h>

#include "freqlist.h"

int main(){
	// FreqList a = {{1,2},{3,4},{5,6},{7,8}};

	int a1[] = {1, 2, 3, 4, -1};
	FreqList *fl1 = make_freqlist(a1);

	int a2[] = {3, 4, 5, 6, -1};
	FreqList *fl2 = make_freqlist(a2);

	FreqList *fl = join(fl1,fl2);
	dump_freqlist(fl);

	int a3[] = {4, 5, 6, 7, 8, 9, 10, -1};
	FreqList *fl3 = make_freqlist(a3);

	FreqList *flx = join(fl,fl3);
	dump_freqlist(flx);
}

