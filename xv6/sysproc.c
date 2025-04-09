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
    // --- !!! 함수 진입 확인 로그 추가 !!! ---
    cprintf("KERN_SYSINIT_ENTRY: Reached sys_uthread_init for pid %d\n", myproc()->pid);
    // --- 여기까지 ---

    int scheduler_addr; // 사용자 스케줄러 주소를 저장할 변수
    struct proc* curproc = myproc(); // 현재 실행 중인 프로세스 정보 가져오기

    // 사용자 프로그램이 전달한 첫 번째 정수 인자를 읽어옴
    if (argint(0, &scheduler_addr) < 0) // 0번째 인자를 scheduler_addr 변수에 저장
        return -1; // 읽기 실패 시 -1 반환

    // 읽어온 주소(정수 값)를 현재 프로세스의 scheduler 필드에 저장
    curproc->scheduler = (uint)scheduler_addr;
    // cprintf("KERN: Registered scheduler for pid %d at 0x%x\n", curproc->pid, curproc->scheduler); // 확인용 로그 (선택 사항)

    return 0; // 성공 시 0 반환
}

