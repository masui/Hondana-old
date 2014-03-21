//
//
#define FREQLIST_H

typedef int Freq[2];
typedef int FreqList[][2];

int fl_length(FreqList *fl);
int fl_join_count(FreqList *a, FreqList *b);
FreqList *fl_join(FreqList *a, FreqList *b);
int fl_intersection_count(FreqList *a, FreqList *b);
FreqList *fl_intersection(FreqList *a, FreqList *b);
void fl_dump(FreqList *fl);
