#include "types.h"
#include "stat.h"
#include "user.h"

/* ������ ���� ���� */
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

// ������ ���� �Լ�
void thread_exit(void) {
    current_thread->state = FREE;
    // printf(1, "thread 0x%x exiting...\n", (int)current_thread); // �α� �ʿ�� Ȱ��ȭ
    thread_schedule();
    printf(2, "thread_exit: scheduler returned unexpectedly\n");
    exit();
}

// �����ٷ� �Լ� (���� ����)
static void thread_schedule(void) {
    printf(1, "[Sched START] current=0x%x state=%d\n", (int)current_thread, current_thread ? current_thread->state : -1);
    //�α� �ӽ� �߰�
    thread_p t, found_next = 0;
    int i;
    thread_p current_save = current_thread;

    // printf(1, "thread_schedule called! (current=0x%x)\n", (int)current_save);

    for (i = 0; i < MAX_THREAD; i++) {
        t = &all_thread[i];
        // <<< �α� �߰�: �� ������ ���� Ȯ�� >>>
        if (t->state != FREE) { // ���ʿ��� �α� ���� ���� FREE ���� ����
            printf(1, "[Sched Check] Checking thread %d (0x%x), state=%d\n", i, (int)t, t->state);
        }
        // ������ 0(main)�� �ڱ� �ڽ��� �����ϰ� RUNNABLE ������ �˻�
        if (t->state == RUNNABLE && t != current_save) {
            // <<< �α� �߰�: ������ ���� ������ ã�� >>>
			printf(1, "[Sched Found] Found runnable thread %d (addr=0x%x)\n", i, (int)t);// �α� �߰�
            found_next = t;
            break;
        }
    }

    if (found_next != 0) {
        printf(1, "[Sched Switch] Switching: current(0x%x) state->RUNNABLE, next(0x%x) state->RUNNING\n", (int)current_save, (int)found_next); // ���� ���� �� �α�
        next_thread = found_next;
        // printf(1, "  Switching from 0x%x to 0x%x\n", (int)current_save, (int)next_thread);
        next_thread->state = RUNNING;
        if (current_save != 0 && current_save->state == RUNNING) {
            current_save->state = RUNNABLE;
        }
        else if (current_save != 0) {
            // ���� ���� ������ ���°� RUNNING�� �ƴ϶�� �α� ����� (������)
            printf(1, "[Sched WARN] current_save(0x%x) state was %d, not RUNNING, when switching\n", (int)current_save, current_save->state);
        } //�ӽ� �α� �߰�
        thread_switch();
    }
    else {
        printf(1, "[Sched NoSwitch] No other runnable thread found. Resuming 0x%x\n", (int)current_save);
        if (current_save == 0 || current_save->state == FREE) { // �Ǵ� ���� ���� ��
            printf(2, "thread_schedule: no runnable threads\n");
            exit();
        }
    }
    printf(1, "[Sched END]\n");
}

// ������ �ý��� �ʱ�ȭ �Լ�
void thread_init(void) {
    // ���� uthread_init ȣ�� Ȱ��ȭ!
    uthread_init((int)thread_schedule);

    current_thread = &all_thread[0];
    current_thread->state = RUNNING;
    for (int i = 1; i < MAX_THREAD; i++) {
        all_thread[i].state = FREE;
    }
}

// �� ������ ���� �Լ� (���� �Ҵ� 16 ����Ʈ�� ����)
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

// ������ ���� �Լ� (thread_exit ȣ��)
static void mythread(void) {
    int i;
    //int my_addr = (int)current_thread;
    // printf(1, "my thread 0x%x running\n", my_addr); // �ʿ�� �α� Ȱ��ȭ
    for (i = 0; i < 100; i++) { // ���� Ƚ�� ���� (�Ǵ� ������ ����)
        //printf(1, "my thread 0x%x\n", my_addr); �ӽ÷� �ּ�ó��
        printf(1, "my thread 0x%x loop %d\n", (int)current_thread, i);
    }
    printf(1, "my thread: exit\n"); // �ּ� ���� ���
    thread_exit(); // ���� ���� ó��
}

// ���� �Լ�
int main(int argc, char* argv[]) {
    // printf(1, "uthread1 starting\n"); // �α� ����
    thread_init();
    thread_create(mythread);
    thread_create(mythread);
    thread_schedule();
    printf(2, "main: returned unexpectedly!\n"); // ����� ���� �ȵ�
    return -1;
}