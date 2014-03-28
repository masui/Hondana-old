//
//
#ifndef FREQ_H
#define FREQ_H

struct Freq {
	int index;
	int freq;
};

int freq_length(struct Freq *fl);
int freq_join_count(struct Freq *a, struct Freq *b);
struct Freq *freq_join(struct Freq *a, struct Freq *b);
int freq_intersection_count(struct Freq *a, struct Freq *b);
struct Freq *freq_intersection(struct Freq *a, struct Freq *b);
void freq_dump(struct Freq *fl);

#endif
