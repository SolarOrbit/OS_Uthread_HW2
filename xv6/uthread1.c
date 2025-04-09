#include "types.h"
#include "stat.h"
#include "user.h"

/* 스레드 상태 정의 */
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2

#define STACK_SIZE  8192
#define MAX_THREAD  4

typedef struct thread thread_t, * thread_p;

struct thread {
    int        sp;
    char stack[STACK_SIZE];
    int        state;
};
static thread_t all_thread[MAX_THREAD];
thread_p  current_thread;
thread_p  next_thread;
extern void thread_switch(void);

static void thread_schedule(void); // Forward declaration

// 스레드 종료 함수
void thread_exit(void) {
    current_thread->state = FREE;
    // printf(1, "thread 0x%x exiting...\n", (int)current_thread); // 로그 필요시 활성화
    thread_schedule();
    printf(2, "thread_exit: scheduler returned unexpectedly\n");
    exit();
}

// 스케줄러 함수 (최종 버전)
static void thread_schedule(void) {
    thread_p t, found_next = 0;
    int i;
    thread_p current_save = current_thread;

    // printf(1, "thread_schedule called! (current=0x%x)\n", (int)current_save);

    for (i = 0; i < MAX_THREAD; i++) {
        t = &all_thread[i];
        // 스레드 0(main)과 자기 자신을 제외하고 RUNNABLE 스레드 검색
        if (t->state == RUNNABLE && t != current_save && t != &all_thread[0]) {
            // printf(1, "  Found runnable thread %d (addr=0x%x)\n", i, (int)t);
            found_next = t;
            break;
        }
    }

    if (found_next != 0) {
        next_thread = found_next;
        // printf(1, "  Switching from 0x%x to 0x%x\n", (int)current_save, (int)next_thread);
        next_thread->state = RUNNING;
        if (current_save != 0 && current_save->state == RUNNING) {
            current_save->state = RUNNABLE;
        }
        thread_switch();
    }
    else {
        if (current_save != 0 && current_save->state == RUNNING) {
            // printf(1, "  No other runnable thread found, resuming current 0x%x\n", (int)current_save);
            next_thread = 0;
        }
        else {
            printf(2, "thread_schedule: no runnable threads\n"); // 최종 종료 메시지
            exit();
        }
    }
}

// 스레드 시스템 초기화 함수
void thread_init(void) {
    // 이제 uthread_init 호출 활성화!
    uthread_init((int)thread_schedule);

    current_thread = &all_thread[0];
    current_thread->state = RUNNING;
    for (int i = 1; i < MAX_THREAD; i++) {
        all_thread[i].state = FREE;
    }
}

// 새 스레드 생성 함수 (스택 할당 16 바이트로 수정)
void thread_create(void (*func)()) {
    thread_p t;
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
        if (t->state == FREE) break;
    }
    if (t >= all_thread + MAX_THREAD) {
        printf(2, "thread_create: too many threads\n");
        return;
    }
    t->sp = (int)(t->stack + STACK_SIZE);
    t->sp -= 4; // For return address (EIP)
    *(int*)(t->sp) = (int)func;
    t->sp -= 16; // For 4 registers (edi, esi, ebx, ebp)
    t->state = RUNNABLE;
    // printf(1, "Created thread %d (addr=0x%x) starting at sp=0x%x\n", t - all_thread, (int)t, t->sp);
}

// 스레드 실행 함수 (thread_exit 호출)
static void mythread(void) {
    int i;
    int my_addr = (int)current_thread;
    // printf(1, "my thread 0x%x running\n", my_addr); // 필요시 로그 활성화
    for (i = 0; i < 100; i++) { // 루프 횟수 원복 (또는 적절히 조절)
        printf(1, "my thread 0x%x\n", my_addr);
    }
    printf(1, "my thread: exit\n"); // 주소 없이 출력
    thread_exit(); // 정상 종료 처리
}

// 메인 함수
int main(int argc, char* argv[]) {
    // printf(1, "uthread1 starting\n"); // 로그 제거
    thread_init();
    thread_create(mythread);
    thread_create(mythread);
    thread_schedule();
    printf(2, "main: returned unexpectedly!\n"); // 여기로 오면 안됨
    return -1;
}