#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"
#include "i8254.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
    int i;

    for (i = 0; i < 256; i++)
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);

    initlock(&tickslock, "time");
}

void
idtinit(void)
{
    lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
    if (tf->trapno == T_SYSCALL) {
        if (myproc()->killed)
            exit();
        myproc()->tf = tf;
        syscall();
        if (myproc()->killed)
            exit();
        return;
    }

    switch (tf->trapno) {
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
            acquire(&tickslock);
            ticks++;
            wakeup(&ticks);
            release(&tickslock);
        }
        lapiceoi();
        
        struct proc* p = myproc(); // 현재 프로세스 가져오기

        // 사용자 스케줄러 호출 조건 확인 및 실행
        if (p != 0 && p->state == RUNNING && (tf->cs & 3) == DPL_USER && p->scheduler != 0) {
            // 사용자 모드 실행 중, RUNNING 상태, 스케줄러 등록됨 -> 사용자 수준 선점 시도
            uint original_eip = tf->eip;
            uint user_esp = tf->esp;
            user_esp -= 4; // 복귀 주소 저장 공간 확보               

            if (copyout(p->pgdir, user_esp, &original_eip, sizeof(original_eip)) < 0) {
                // copyout 실패 시 오류 처리
                cprintf("KERN_ERR: trap.c: copyout failed for EIP save, pid=%d\n", p->pid);
                p->killed = 1;
                // 오류 발생 시 아래의 표준 종료/양보 로직으로 넘어감
            }
            else {
                // copyout 성공 시: 트랩 프레임 수정하여 스케줄러로 점프 준비
                tf->esp = user_esp;
                tf->eip = p->scheduler;

                // 사용자 스케줄러가 호출될 것이므로, 커널 수준의 yield()는 건너뜀
                // iret 명령어로 사용자 스케줄러로 바로 복귀하게 됨.
                // 이후 프로세스 종료 여부 확인은 여전히 필요.

                // 디버깅 로그 (필요시 유지)
                // cprintf("KERN_INFO: trap.c: Saved EIP 0x%x to user_esp 0x%x, jumping to scheduler 0x%x\n", original_eip, tf->esp, tf->eip);

                // ★★★★★: 사용자 스케줄러로 점프하므로 아래의 kernel yield 로직 실행 방지 ★★★★★
                goto check_exit; // 아래의 yield 건너뛰고 종료 확인으로 이동 (아래 check_exit 레이블 추가 필요)
            }
        }

        // 사용자 스케줄러가 호출되지 않은 경우 (커널 모드, 스케줄러 미등록 등)
        // 또는 copyout이 실패한 경우, 기존 커널 수준 yield 실행
        if (p && p->state == RUNNING && tf->trapno == T_IRQ0 + IRQ_TIMER) {
            yield();
        }

    check_exit: // goto 타겟 레이블
        // 프로세스 종료 여부 확인 (공통 로직)
        if (p && p->killed && (tf->cs & 3) == DPL_USER)
            exit();
        
        break;
    case T_IRQ0 + IRQ_IDE:
        ideintr();
        lapiceoi();
        break;
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
        lapiceoi();
        break;
    case T_IRQ0 + IRQ_COM1:
        uartintr();
        lapiceoi();
        break;
    case T_IRQ0 + 0xB:
        i8254_intr();
        lapiceoi();
        break;
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
        lapiceoi();
        break;

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
        exit();

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
        tf->trapno == T_IRQ0 + IRQ_TIMER)
        yield();

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
        exit();
}
