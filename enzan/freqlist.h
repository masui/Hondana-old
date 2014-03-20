//
//
typedef int Freq[2];
typedef int FreqList[][2];

int fl_length(FreqList *fl);
int join_count(FreqList *a, FreqList *b);
FreqList *join(FreqList *a, FreqList *b);
int intersection_count(FreqList *a, FreqList *b);
FreqList *intersection(FreqList *a, FreqList *b);
void dump_freqlist(FreqList *fl);
