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
    printf(1, "[Sched START] current=0x%x state=%d\n", (int)current_thread, current_thread ? current_thread->state : -1);
    //로그 임시 추가
    thread_p t, found_next = 0;
    int i;
    thread_p current_save = current_thread;

    // printf(1, "thread_schedule called! (current=0x%x)\n", (int)current_save);

    for (i = 0; i < MAX_THREAD; i++) {
        t = &all_thread[i];
        // <<< 로그 추가: 각 스레드 상태 확인 >>>
        if (t->state != FREE) { // 불필요한 로그 방지 위해 FREE 상태 제외
            printf(1, "[Sched Check] Checking thread %d (0x%x), state=%d\n", i, (int)t, t->state);
        }
        // 스레드 0(main)과 자기 자신을 제외하고 RUNNABLE 스레드 검색
        if (t->state == RUNNABLE && t != current_save) {
            // <<< 로그 추가: 실행할 다음 스레드 찾음 >>>
			printf(1, "[Sched Found] Found runnable thread %d (addr=0x%x)\n", i, (int)t);// 로그 추가
            found_next = t;
            break;
        }
    }

    if (found_next != 0) {
        printf(1, "[Sched Switch] Switching: current(0x%x) state->RUNNABLE, next(0x%x) state->RUNNING\n", (int)current_save, (int)found_next); // 상태 변경 전 로그
        next_thread = found_next;
        // printf(1, "  Switching from 0x%x to 0x%x\n", (int)current_save, (int)next_thread);
        next_thread->state = RUNNING;
        if (current_save != 0 && current_save->state == RUNNING) {
            current_save->state = RUNNABLE;
        }
        else if (current_save != 0) {
            // 만약 현재 스레드 상태가 RUNNING이 아니라면 로그 남기기 (디버깅용)
            printf(1, "[Sched WARN] current_save(0x%x) state was %d, not RUNNING, when switching\n", (int)current_save, current_save->state);
        } //임시 로그 추가
        thread_switch();
    }
    else {
        printf(1, "[Sched NoSwitch] No other runnable thread found. Resuming 0x%x\n", (int)current_save);
        if (current_save == 0 || current_save->state == FREE) { // 또는 종료 상태 등
            printf(2, "thread_schedule: no runnable threads\n");
            exit();
        }
    }
    printf(1, "[Sched END]\n");
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
    //int my_addr = (int)current_thread;
    // printf(1, "my thread 0x%x running\n", my_addr); // 필요시 로그 활성화
    for (i = 0; i < 100; i++) { // 루프 횟수 원복 (또는 적절히 조절)
        //printf(1, "my thread 0x%x\n", my_addr); 임시로 주석처리
        printf(1, "my thread 0x%x loop %d\n", (int)current_thread, i);
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