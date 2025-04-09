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
        
        struct proc* p = myproc(); // ���� ���μ��� ��������

        // ����� �����ٷ� ȣ�� ���� Ȯ�� �� ����
        if (p != 0 && p->state == RUNNING && (tf->cs & 3) == DPL_USER && p->scheduler != 0) {
            // ����� ��� ���� ��, RUNNING ����, �����ٷ� ��ϵ� -> ����� ���� ���� �õ�
            uint original_eip = tf->eip;
            uint user_esp = tf->esp;
            user_esp -= 4; // ���� �ּ� ���� ���� Ȯ��               

            if (copyout(p->pgdir, user_esp, &original_eip, sizeof(original_eip)) < 0) {
                // copyout ���� �� ���� ó��
                cprintf("KERN_ERR: trap.c: copyout failed for EIP save, pid=%d\n", p->pid);
                p->killed = 1;
                // ���� �߻� �� �Ʒ��� ǥ�� ����/�纸 �������� �Ѿ
            }
            else {
                // copyout ���� ��: Ʈ�� ������ �����Ͽ� �����ٷ��� ���� �غ�
                tf->esp = user_esp;
                tf->eip = p->scheduler;

                // ����� �����ٷ��� ȣ��� ���̹Ƿ�, Ŀ�� ������ yield()�� �ǳʶ�
                // iret ��ɾ�� ����� �����ٷ��� �ٷ� �����ϰ� ��.
                // ���� ���μ��� ���� ���� Ȯ���� ������ �ʿ�.

                // ����� �α� (�ʿ�� ����)
                // cprintf("KERN_INFO: trap.c: Saved EIP 0x%x to user_esp 0x%x, jumping to scheduler 0x%x\n", original_eip, tf->esp, tf->eip);

                // �ڡڡڡڡ�: ����� �����ٷ��� �����ϹǷ� �Ʒ��� kernel yield ���� ���� ���� �ڡڡڡڡ�
                goto check_exit; // �Ʒ��� yield �ǳʶٰ� ���� Ȯ������ �̵� (�Ʒ� check_exit ���̺� �߰� �ʿ�)
            }
        }

        // ����� �����ٷ��� ȣ����� ���� ��� (Ŀ�� ���, �����ٷ� �̵�� ��)
        // �Ǵ� copyout�� ������ ���, ���� Ŀ�� ���� yield ����
        if (p && p->state == RUNNING && tf->trapno == T_IRQ0 + IRQ_TIMER) {
            yield();
        }

    check_exit: // goto Ÿ�� ���̺�
        // ���μ��� ���� ���� Ȯ�� (���� ����)
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
