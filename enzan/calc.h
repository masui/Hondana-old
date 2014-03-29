#ifndef _CALC_H_
#define _CALC_H_

#include "freq.h"

typedef enum {
	BOOK=1, SHELF
} Kind;

typedef enum {
	SEARCH, ADD, SUB, SIMILAR
} Command;

typedef struct {
	int ind;
	float score;
} ScoreEntry;

#define max(x,y) ((x) > (y) ? (x) : (y))
#define min(x,y) ((x) < (y) ? (x) : (y))

#define SIMILAR_LIMIT 20

static int compare(const void *p1, const void *p2);
struct Freq *calc(Command command, Kind inputkind, Kind outputkind, struct Freq *list1, struct Freq *list2);
struct Freq *shelves(int ind);
struct Freq *books(int ind);

#endif
