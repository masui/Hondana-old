//
//
#ifndef FREQLIST_H
#define FREQLIST_H

struct Freq {
	int index;
	int freq;
};

//typedef int Freq[2];
//typedef int FreqList[][2];

int fl_length(struct Freq *fl);
int fl_join_count(struct Freq *a, struct Freq *b);
struct Freq *fl_join(struct Freq *a, struct Freq *b);
int fl_intersection_count(struct Freq *a, struct Freq *b);
struct Freq *fl_intersection(struct Freq *a, struct Freq *b);
void fl_dump(struct Freq *fl);

#endif
