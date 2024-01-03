#ifndef timer_h
#define timer_h

void startTimer(int msec,void (*tcall)(int));
void stopTimer();
#endif