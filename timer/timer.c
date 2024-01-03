#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>
#include <string.h>

void startTimer(int msec,void (*tcall)(int)){
   struct itimerval new_timer;
   struct itimerval old_timer; 
   new_timer.it_value.tv_sec = 1;
   new_timer.it_value.tv_usec = 0;
   new_timer.it_interval.tv_sec = 0;
   new_timer.it_interval.tv_usec = msec;
   setitimer(ITIMER_REAL, &new_timer, &old_timer);
   signal(SIGALRM, tcall);
}
void stopTimer(){
   struct itimerval new_timer;
   struct itimerval old_timer; 
   new_timer.it_value.tv_sec = 0;
   new_timer.it_value.tv_usec = 0;
   new_timer.it_interval.tv_sec = 0;
   new_timer.it_interval.tv_usec = 0;
   setitimer(ITIMER_REAL, &new_timer, &old_timer);
}