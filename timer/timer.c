#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>
#include <string.h>

void timer_callback(int signum)
{
    struct timeval now;
    gettimeofday(&now, NULL);
    printf("Signal %d caught on %li.%03li\n", signum, now.tv_sec, now.tv_usec / 1000);
}

int main()
{
    unsigned int remaining = 3;

    struct itimerval new_timer;
    struct itimerval old_timer;

    new_timer.it_value.tv_sec = 1;
    new_timer.it_value.tv_usec = 0;
    new_timer.it_interval.tv_sec = 0;
    new_timer.it_interval.tv_usec = 900 * 1000;
   
    setitimer(ITIMER_REAL, &new_timer, &old_timer);
    signal(SIGALRM, timer_callback);

    while (sleep(remaining) != 0)
    {
        if (errno == EINTR)
        {
            printf("sleep interrupted by signal");
	        new_timer.it_value.tv_sec = 0;
            new_timer.it_value.tv_usec = 0;
            new_timer.it_interval.tv_sec = 0;
            new_timer.it_interval.tv_usec = 0;
            setitimer(ITIMER_REAL, &new_timer, &old_timer);
        }
        else
        {
            printf("sleep error %s", strerror(errno));
        }
    }
    return 0;
}