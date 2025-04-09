#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

int sys_uthread_init(void)
{
    // --- !!! �Լ� ���� Ȯ�� �α� �߰� !!! ---
    cprintf("KERN_SYSINIT_ENTRY: Reached sys_uthread_init for pid %d\n", myproc()->pid);
    // --- ������� ---

    int scheduler_addr; // ����� �����ٷ� �ּҸ� ������ ����
    struct proc* curproc = myproc(); // ���� ���� ���� ���μ��� ���� ��������

    // ����� ���α׷��� ������ ù ��° ���� ���ڸ� �о��
    if (argint(0, &scheduler_addr) < 0) // 0��° ���ڸ� scheduler_addr ������ ����
        return -1; // �б� ���� �� -1 ��ȯ

    // �о�� �ּ�(���� ��)�� ���� ���μ����� scheduler �ʵ忡 ����
    curproc->scheduler = (uint)scheduler_addr;
    // cprintf("KERN: Registered scheduler for pid %d at 0x%x\n", curproc->pid, curproc->scheduler); // Ȯ�ο� �α� (���� ����)

    return 0; // ���� �� 0 ��ȯ
}

