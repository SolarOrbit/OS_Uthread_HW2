
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_exit>:
extern void thread_switch(void);

static void thread_schedule(void); // Forward declaration

// Ω∫∑πµÂ ¡æ∑· «‘ºˆ
void thread_exit(void) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
    current_thread->state = FREE;
   a:	a1 ec 90 00 00       	mov    0x90ec,%eax
   f:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
  16:	00 00 00 
    // printf(1, "thread 0x%x exiting...\n", (int)current_thread); // ∑Œ±◊ « ø‰Ω√ »∞º∫»≠
    thread_schedule();
  19:	e8 17 00 00 00       	call   35 <thread_schedule>
    printf(2, "thread_exit: scheduler returned unexpectedly\n");
  1e:	83 ec 08             	sub    $0x8,%esp
  21:	68 68 0b 00 00       	push   $0xb68
  26:	6a 02                	push   $0x2
  28:	e8 71 07 00 00       	call   79e <printf>
  2d:	83 c4 10             	add    $0x10,%esp
    exit();
  30:	e8 e5 05 00 00       	call   61a <exit>

00000035 <thread_schedule>:
}

// Ω∫ƒ…¡Ÿ∑Ø «‘ºˆ (√÷¡æ πˆ¿¸)
static void thread_schedule(void) {
  35:	f3 0f 1e fb          	endbr32 
  39:	55                   	push   %ebp
  3a:	89 e5                	mov    %esp,%ebp
  3c:	83 ec 18             	sub    $0x18,%esp
    printf(1, "[Sched START] current=0x%x state=%d\n", (int)current_thread, current_thread ? current_thread->state : -1);
  3f:	a1 ec 90 00 00       	mov    0x90ec,%eax
  44:	85 c0                	test   %eax,%eax
  46:	74 0d                	je     55 <thread_schedule+0x20>
  48:	a1 ec 90 00 00       	mov    0x90ec,%eax
  4d:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  53:	eb 05                	jmp    5a <thread_schedule+0x25>
  55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  5a:	8b 15 ec 90 00 00    	mov    0x90ec,%edx
  60:	50                   	push   %eax
  61:	52                   	push   %edx
  62:	68 98 0b 00 00       	push   $0xb98
  67:	6a 01                	push   $0x1
  69:	e8 30 07 00 00       	call   79e <printf>
  6e:	83 c4 10             	add    $0x10,%esp
    //∑Œ±◊ ¿”Ω√ √ﬂ∞°
    thread_p t, found_next = 0;
  71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int i;
    thread_p current_save = current_thread;
  78:	a1 ec 90 00 00       	mov    0x90ec,%eax
  7d:	89 45 ec             	mov    %eax,-0x14(%ebp)

    // printf(1, "thread_schedule called! (current=0x%x)\n", (int)current_save);

    for (i = 0; i < MAX_THREAD; i++) {
  80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  87:	eb 79                	jmp    102 <thread_schedule+0xcd>
        t = &all_thread[i];
  89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8c:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
  92:	05 c0 10 00 00       	add    $0x10c0,%eax
  97:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // <<< ∑Œ±◊ √ﬂ∞°: ∞¢ Ω∫∑πµÂ ªÛ≈¬ »Æ¿Œ >>>
        if (t->state != FREE) { // ∫“« ø‰«— ∑Œ±◊ πÊ¡ˆ ¿ß«ÿ FREE ªÛ≈¬ ¡¶ø‹
  9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  9d:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  a3:	85 c0                	test   %eax,%eax
  a5:	74 23                	je     ca <thread_schedule+0x95>
            printf(1, "[Sched Check] Checking thread %d (0x%x), state=%d\n", i, (int)t, t->state);
  a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  aa:	8b 90 04 20 00 00    	mov    0x2004(%eax),%edx
  b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  b3:	83 ec 0c             	sub    $0xc,%esp
  b6:	52                   	push   %edx
  b7:	50                   	push   %eax
  b8:	ff 75 f0             	pushl  -0x10(%ebp)
  bb:	68 c0 0b 00 00       	push   $0xbc0
  c0:	6a 01                	push   $0x1
  c2:	e8 d7 06 00 00       	call   79e <printf>
  c7:	83 c4 20             	add    $0x20,%esp
        }
        // Ω∫∑πµÂ 0(main)∞˙ ¿⁄±‚ ¿⁄Ω≈¿ª ¡¶ø‹«œ∞Ì RUNNABLE Ω∫∑πµÂ ∞Àªˆ
        if (t->state == RUNNABLE && t != current_save) {
  ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  cd:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  d3:	83 f8 02             	cmp    $0x2,%eax
  d6:	75 26                	jne    fe <thread_schedule+0xc9>
  d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  db:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  de:	74 1e                	je     fe <thread_schedule+0xc9>
            // <<< ∑Œ±◊ √ﬂ∞°: Ω««‡«“ ¥Ÿ¿Ω Ω∫∑πµÂ √£¿Ω >>>
			printf(1, "[Sched Found] Found runnable thread %d (addr=0x%x)\n", i, (int)t);// ∑Œ±◊ √ﬂ∞°
  e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  e3:	50                   	push   %eax
  e4:	ff 75 f0             	pushl  -0x10(%ebp)
  e7:	68 f4 0b 00 00       	push   $0xbf4
  ec:	6a 01                	push   $0x1
  ee:	e8 ab 06 00 00       	call   79e <printf>
  f3:	83 c4 10             	add    $0x10,%esp
            found_next = t;
  f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  fc:	eb 0a                	jmp    108 <thread_schedule+0xd3>
    for (i = 0; i < MAX_THREAD; i++) {
  fe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 102:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 106:	7e 81                	jle    89 <thread_schedule+0x54>
        }
    }

    if (found_next != 0) {
 108:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 10c:	74 7b                	je     189 <thread_schedule+0x154>
        printf(1, "[Sched Switch] Switching: current(0x%x) state->RUNNABLE, next(0x%x) state->RUNNING\n", (int)current_save, (int)found_next); // ªÛ≈¬ ∫Ø∞Ê ¿¸ ∑Œ±◊
 10e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 111:	8b 45 ec             	mov    -0x14(%ebp),%eax
 114:	52                   	push   %edx
 115:	50                   	push   %eax
 116:	68 28 0c 00 00       	push   $0xc28
 11b:	6a 01                	push   $0x1
 11d:	e8 7c 06 00 00       	call   79e <printf>
 122:	83 c4 10             	add    $0x10,%esp
        next_thread = found_next;
 125:	8b 45 f4             	mov    -0xc(%ebp),%eax
 128:	a3 f0 90 00 00       	mov    %eax,0x90f0
        // printf(1, "  Switching from 0x%x to 0x%x\n", (int)current_save, (int)next_thread);
        next_thread->state = RUNNING;
 12d:	a1 f0 90 00 00       	mov    0x90f0,%eax
 132:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 139:	00 00 00 
        if (current_save != 0 && current_save->state == RUNNING) {
 13c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 140:	74 1d                	je     15f <thread_schedule+0x12a>
 142:	8b 45 ec             	mov    -0x14(%ebp),%eax
 145:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 14b:	83 f8 01             	cmp    $0x1,%eax
 14e:	75 0f                	jne    15f <thread_schedule+0x12a>
            current_save->state = RUNNABLE;
 150:	8b 45 ec             	mov    -0x14(%ebp),%eax
 153:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 15a:	00 00 00 
 15d:	eb 23                	jmp    182 <thread_schedule+0x14d>
        }
        else if (current_save != 0) {
 15f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 163:	74 1d                	je     182 <thread_schedule+0x14d>
            // ∏∏æ‡ «ˆ¿Á Ω∫∑πµÂ ªÛ≈¬∞° RUNNING¿Ã æ∆¥œ∂Û∏È ∑Œ±◊ ≥≤±‚±‚ (µπˆ±ÎøÎ)
            printf(1, "[Sched WARN] current_save(0x%x) state was %d, not RUNNING, when switching\n", (int)current_save, current_save->state);
 165:	8b 45 ec             	mov    -0x14(%ebp),%eax
 168:	8b 90 04 20 00 00    	mov    0x2004(%eax),%edx
 16e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 171:	52                   	push   %edx
 172:	50                   	push   %eax
 173:	68 7c 0c 00 00       	push   $0xc7c
 178:	6a 01                	push   $0x1
 17a:	e8 1f 06 00 00       	call   79e <printf>
 17f:	83 c4 10             	add    $0x10,%esp
        } //¿”Ω√ ∑Œ±◊ √ﬂ∞°
        thread_switch();
 182:	e8 fc 01 00 00       	call   383 <thread_switch>
 187:	eb 40                	jmp    1c9 <thread_schedule+0x194>
    }
    else {
        printf(1, "[Sched NoSwitch] No other runnable thread found. Resuming 0x%x\n", (int)current_save);
 189:	8b 45 ec             	mov    -0x14(%ebp),%eax
 18c:	83 ec 04             	sub    $0x4,%esp
 18f:	50                   	push   %eax
 190:	68 c8 0c 00 00       	push   $0xcc8
 195:	6a 01                	push   $0x1
 197:	e8 02 06 00 00       	call   79e <printf>
 19c:	83 c4 10             	add    $0x10,%esp
        if (current_save == 0 || current_save->state == FREE) { // ∂«¥¬ ¡æ∑· ªÛ≈¬ µÓ
 19f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1a3:	74 0d                	je     1b2 <thread_schedule+0x17d>
 1a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1a8:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 1ae:	85 c0                	test   %eax,%eax
 1b0:	75 17                	jne    1c9 <thread_schedule+0x194>
            printf(2, "thread_schedule: no runnable threads\n");
 1b2:	83 ec 08             	sub    $0x8,%esp
 1b5:	68 08 0d 00 00       	push   $0xd08
 1ba:	6a 02                	push   $0x2
 1bc:	e8 dd 05 00 00       	call   79e <printf>
 1c1:	83 c4 10             	add    $0x10,%esp
            exit();
 1c4:	e8 51 04 00 00       	call   61a <exit>
        }
    }
    printf(1, "[Sched END]\n");
 1c9:	83 ec 08             	sub    $0x8,%esp
 1cc:	68 2e 0d 00 00       	push   $0xd2e
 1d1:	6a 01                	push   $0x1
 1d3:	e8 c6 05 00 00       	call   79e <printf>
 1d8:	83 c4 10             	add    $0x10,%esp
}
 1db:	90                   	nop
 1dc:	c9                   	leave  
 1dd:	c3                   	ret    

000001de <thread_init>:

// Ω∫∑πµÂ Ω√Ω∫≈€ √ ±‚»≠ «‘ºˆ
void thread_init(void) {
 1de:	f3 0f 1e fb          	endbr32 
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	83 ec 18             	sub    $0x18,%esp
    // ¿Ã¡¶ uthread_init »£√‚ »∞º∫»≠!
    uthread_init((int)thread_schedule);
 1e8:	b8 35 00 00 00       	mov    $0x35,%eax
 1ed:	83 ec 0c             	sub    $0xc,%esp
 1f0:	50                   	push   %eax
 1f1:	e8 c4 04 00 00       	call   6ba <uthread_init>
 1f6:	83 c4 10             	add    $0x10,%esp

    current_thread = &all_thread[0];
 1f9:	c7 05 ec 90 00 00 c0 	movl   $0x10c0,0x90ec
 200:	10 00 00 
    current_thread->state = RUNNING;
 203:	a1 ec 90 00 00       	mov    0x90ec,%eax
 208:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 20f:	00 00 00 
    for (int i = 1; i < MAX_THREAD; i++) {
 212:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 219:	eb 18                	jmp    233 <thread_init+0x55>
        all_thread[i].state = FREE;
 21b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21e:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 224:	05 c4 30 00 00       	add    $0x30c4,%eax
 229:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 1; i < MAX_THREAD; i++) {
 22f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 233:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 237:	7e e2                	jle    21b <thread_init+0x3d>
    }
}
 239:	90                   	nop
 23a:	90                   	nop
 23b:	c9                   	leave  
 23c:	c3                   	ret    

0000023d <thread_create>:

// ªı Ω∫∑πµÂ ª˝º∫ «‘ºˆ (Ω∫≈√ «“¥Á 16 πŸ¿Ã∆Æ∑Œ ºˆ¡§)
void thread_create(void (*func)()) {
 23d:	f3 0f 1e fb          	endbr32 
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 18             	sub    $0x18,%esp
    thread_p t;
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 247:	c7 45 f4 c0 10 00 00 	movl   $0x10c0,-0xc(%ebp)
 24e:	eb 14                	jmp    264 <thread_create+0x27>
        if (t->state == FREE) break;
 250:	8b 45 f4             	mov    -0xc(%ebp),%eax
 253:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 259:	85 c0                	test   %eax,%eax
 25b:	74 13                	je     270 <thread_create+0x33>
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 25d:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 264:	b8 e0 90 00 00       	mov    $0x90e0,%eax
 269:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 26c:	72 e2                	jb     250 <thread_create+0x13>
 26e:	eb 01                	jmp    271 <thread_create+0x34>
        if (t->state == FREE) break;
 270:	90                   	nop
    }
    if (t >= all_thread + MAX_THREAD) {
 271:	b8 e0 90 00 00       	mov    $0x90e0,%eax
 276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 279:	72 14                	jb     28f <thread_create+0x52>
        printf(2, "thread_create: too many threads\n");
 27b:	83 ec 08             	sub    $0x8,%esp
 27e:	68 3c 0d 00 00       	push   $0xd3c
 283:	6a 02                	push   $0x2
 285:	e8 14 05 00 00       	call   79e <printf>
 28a:	83 c4 10             	add    $0x10,%esp
        return;
 28d:	eb 45                	jmp    2d4 <thread_create+0x97>
    }
    t->sp = (int)(t->stack + STACK_SIZE);
 28f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 292:	83 c0 04             	add    $0x4,%eax
 295:	05 00 20 00 00       	add    $0x2000,%eax
 29a:	89 c2                	mov    %eax,%edx
 29c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29f:	89 10                	mov    %edx,(%eax)
    t->sp -= 4; // For return address (EIP)
 2a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a4:	8b 00                	mov    (%eax),%eax
 2a6:	8d 50 fc             	lea    -0x4(%eax),%edx
 2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ac:	89 10                	mov    %edx,(%eax)
    *(int*)(t->sp) = (int)func;
 2ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b1:	8b 00                	mov    (%eax),%eax
 2b3:	89 c2                	mov    %eax,%edx
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	89 02                	mov    %eax,(%edx)
    t->sp -= 16; // For 4 registers (edi, esi, ebx, ebp)
 2ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bd:	8b 00                	mov    (%eax),%eax
 2bf:	8d 50 f0             	lea    -0x10(%eax),%edx
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	89 10                	mov    %edx,(%eax)
    t->state = RUNNABLE;
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 2d1:	00 00 00 
    // printf(1, "Created thread %d (addr=0x%x) starting at sp=0x%x\n", t - all_thread, (int)t, t->sp);
}
 2d4:	c9                   	leave  
 2d5:	c3                   	ret    

000002d6 <mythread>:

// Ω∫∑πµÂ Ω««‡ «‘ºˆ (thread_exit »£√‚)
static void mythread(void) {
 2d6:	f3 0f 1e fb          	endbr32 
 2da:	55                   	push   %ebp
 2db:	89 e5                	mov    %esp,%ebp
 2dd:	83 ec 18             	sub    $0x18,%esp
    int i;
    //int my_addr = (int)current_thread;
    // printf(1, "my thread 0x%x running\n", my_addr); // « ø‰Ω√ ∑Œ±◊ »∞º∫»≠
    for (i = 0; i < 100; i++) { // ∑Á«¡ »Ωºˆ ø¯∫π (∂«¥¬ ¿˚¿˝»˜ ¡∂¿˝)
 2e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e7:	eb 1c                	jmp    305 <mythread+0x2f>
        //printf(1, "my thread 0x%x\n", my_addr); ¿”Ω√∑Œ ¡÷ºÆ√≥∏Æ
        printf(1, "my thread 0x%x loop %d\n", (int)current_thread, i);
 2e9:	a1 ec 90 00 00       	mov    0x90ec,%eax
 2ee:	ff 75 f4             	pushl  -0xc(%ebp)
 2f1:	50                   	push   %eax
 2f2:	68 5d 0d 00 00       	push   $0xd5d
 2f7:	6a 01                	push   $0x1
 2f9:	e8 a0 04 00 00       	call   79e <printf>
 2fe:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < 100; i++) { // ∑Á«¡ »Ωºˆ ø¯∫π (∂«¥¬ ¿˚¿˝»˜ ¡∂¿˝)
 301:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 305:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 309:	7e de                	jle    2e9 <mythread+0x13>
    }
    printf(1, "my thread: exit\n"); // ¡÷º“ æ¯¿Ã √‚∑¬
 30b:	83 ec 08             	sub    $0x8,%esp
 30e:	68 75 0d 00 00       	push   $0xd75
 313:	6a 01                	push   $0x1
 315:	e8 84 04 00 00       	call   79e <printf>
 31a:	83 c4 10             	add    $0x10,%esp
    thread_exit(); // ¡§ªÛ ¡æ∑· √≥∏Æ
 31d:	e8 de fc ff ff       	call   0 <thread_exit>
}
 322:	90                   	nop
 323:	c9                   	leave  
 324:	c3                   	ret    

00000325 <main>:

// ∏ﬁ¿Œ «‘ºˆ
int main(int argc, char* argv[]) {
 325:	f3 0f 1e fb          	endbr32 
 329:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 32d:	83 e4 f0             	and    $0xfffffff0,%esp
 330:	ff 71 fc             	pushl  -0x4(%ecx)
 333:	55                   	push   %ebp
 334:	89 e5                	mov    %esp,%ebp
 336:	51                   	push   %ecx
 337:	83 ec 04             	sub    $0x4,%esp
    // printf(1, "uthread1 starting\n"); // ∑Œ±◊ ¡¶∞≈
    thread_init();
 33a:	e8 9f fe ff ff       	call   1de <thread_init>
    thread_create(mythread);
 33f:	83 ec 0c             	sub    $0xc,%esp
 342:	68 d6 02 00 00       	push   $0x2d6
 347:	e8 f1 fe ff ff       	call   23d <thread_create>
 34c:	83 c4 10             	add    $0x10,%esp
    thread_create(mythread);
 34f:	83 ec 0c             	sub    $0xc,%esp
 352:	68 d6 02 00 00       	push   $0x2d6
 357:	e8 e1 fe ff ff       	call   23d <thread_create>
 35c:	83 c4 10             	add    $0x10,%esp
    thread_schedule();
 35f:	e8 d1 fc ff ff       	call   35 <thread_schedule>
    printf(2, "main: returned unexpectedly!\n"); // ø©±‚∑Œ ø¿∏È æ»µ 
 364:	83 ec 08             	sub    $0x8,%esp
 367:	68 86 0d 00 00       	push   $0xd86
 36c:	6a 02                	push   $0x2
 36e:	e8 2b 04 00 00       	call   79e <printf>
 373:	83 c4 10             	add    $0x10,%esp
    return -1;
 376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 37b:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 37e:	c9                   	leave  
 37f:	8d 61 fc             	lea    -0x4(%ecx),%esp
 382:	c3                   	ret    

00000383 <thread_switch>:
# thread_switch Ìï®Ïàò Ï†ïÏùò
.globl thread_switch
thread_switch:
  # 1. ÌòÑÏû¨ Ïä§Î†àÎìúÏùò Callee-saved Î†àÏßÄÏä§ÌÑ∞ Ï†ÄÏû•
  #    (Ìï®Ïàò Ìò∏Ï∂ú Ïãú Ìò∏Ï∂úÎêú Ìï®Ïàò(callee)Í∞Ä Î≥¥Ï°¥Ìï¥Ïïº ÌïòÎäî Î†àÏßÄÏä§ÌÑ∞Îì§)
  pushl %ebp
 383:	55                   	push   %ebp
  pushl %ebx
 384:	53                   	push   %ebx
  pushl %esi
 385:	56                   	push   %esi
  pushl %edi
 386:	57                   	push   %edi
  
  # 2. ÌòÑÏû¨ Ïä§ÌÉù Ìè¨Ïù∏ÌÑ∞(ESP)Î•º current_thread->sp Ïóê Ï†ÄÏû•
  #    current_thread Î≥ÄÏàò(Ìè¨Ïù∏ÌÑ∞)Ïùò Ï£ºÏÜåÎ•º %eax Î°ú Í∞ÄÏ†∏Ïò¥
  movl current_thread, %eax 
 387:	a1 ec 90 00 00       	mov    0x90ec,%eax
  #    ÌòÑÏû¨ %esp Í∞íÏùÑ current_thread Íµ¨Ï°∞Ï≤¥Ïùò Ï≤´ Î≤àÏß∏ Î©§Î≤Ñ(sp ÌïÑÎìúÎ°ú Í∞ÄÏ†ï)Ïóê Ï†ÄÏû•
  movl %esp, (%eax)        
 38c:	89 20                	mov    %esp,(%eax)
  
  # 3. Îã§Ïùå Ïä§Î†àÎìúÎ°ú Ï†ÑÌôò (current_thread Ìè¨Ïù∏ÌÑ∞ ÏóÖÎç∞Ïù¥Ìä∏)
  #    next_thread Î≥ÄÏàò(Ìè¨Ïù∏ÌÑ∞)Ïùò Ï£ºÏÜåÎ•º %eax Î°ú Í∞ÄÏ†∏Ïò¥
  movl next_thread, %eax
 38e:	a1 f0 90 00 00       	mov    0x90f0,%eax
  #    current_thread Î≥ÄÏàòÍ∞Ä Ïù¥Ï†ú next_thread Î•º Í∞ÄÎ¶¨ÌÇ§ÎèÑÎ°ù ÏóÖÎç∞Ïù¥Ìä∏
  movl %eax, current_thread 
 393:	a3 ec 90 00 00       	mov    %eax,0x90ec
  
  # 4. Îã§Ïùå Ïä§Î†àÎìú(Ïù¥Ï†ú current_threadÍ∞Ä Í∞ÄÎ¶¨ÌÇ¥)Ïùò Ï†ÄÏû•Îêú Ïä§ÌÉù Ìè¨Ïù∏ÌÑ∞Î•º %esp Î°ú Î≥µÏõê
  #    current_thread Í∞Ä Í∞ÄÎ¶¨ÌÇ§Îäî Íµ¨Ï°∞Ï≤¥Ïùò Ï≤´ Î≤àÏß∏ Î©§Î≤Ñ(sp ÌïÑÎìú) Í∞íÏùÑ %esp Î°ú Î°úÎìú
  #    Ïù¥Ï†ú %esp Îäî Îã§ÏùåÏóê Ïã§ÌñâÎê† Ïä§Î†àÎìúÍ∞Ä ÎßàÏßÄÎßâÏúºÎ°ú Ï†ÄÏû•ÌñàÎçò Ïä§ÌÉù ÏÉÅÌÉúÎ•º Í∞ÄÎ¶¨ÌÇ¥
  #    (Ïä§ÌÉùÏùò ÏµúÏÉÅÎã®ÏóêÎäî Ï†ÄÏû•Îêú %edi Í∞íÏù¥ ÏûàÏùå)
  movl (%eax), %esp          
 398:	8b 20                	mov    (%eax),%esp
  
  # 5. Îã§Ïùå Ïä§Î†àÎìúÏùò Callee-saved Î†àÏßÄÏä§ÌÑ∞ Î≥µÏõê (Ï†ÄÏû• ÏàúÏÑúÏùò Ïó≠Ïàú)
  popl %edi
 39a:	5f                   	pop    %edi
  popl %esi
 39b:	5e                   	pop    %esi
  popl %ebx
 39c:	5b                   	pop    %ebx
  popl %ebp
 39d:	5d                   	pop    %ebp
  #    Ìï¥Îãπ Ï£ºÏÜåÎ°ú Ï†êÌîÑÌï©ÎãàÎã§.
  #    - Ïä§Î†àÎìúÍ∞Ä Ï≤òÏùå ÏÉùÏÑ±Îêú Í≤ΩÏö∞: thread_create ÏóêÏÑú ÏÑ§Ï†ïÌïú Ïä§Î†àÎìú Ìï®Ïàò ÏãúÏûë Ï£ºÏÜå (func)
  #    - Ïä§Î†àÎìúÍ∞Ä ÌòëÏ°∞Ï†ÅÏúºÎ°ú ÏñëÎ≥¥(yield)Ìïú Í≤ΩÏö∞: thread_schedule ÎÇ¥Ïùò 'call thread_switch' Îã§Ïùå Ï£ºÏÜå
  #    - Ïä§Î†àÎìúÍ∞Ä ÏÑ†Ï†ê(preempt)Îêú Í≤ΩÏö∞: trap.c Í∞Ä ÏÇ¨Ïö©Ïûê Ïä§ÌÉùÏóê Ï†ÄÏû•Ìïú ÏõêÎûò Ïã§Ìñâ ÏßÄÏ†ê (original_eip) Ïù¥Ïñ¥Ïïº Ìï®. 
  #                                  (Ïù¥ Î∂ÄÎ∂ÑÏù¥ Ïò¨Î∞îÎ•¥Í≤å ÎèôÏûëÌïòÎäîÏßÄÍ∞Ä ÏÑ†Ï†êÌòï Ïä§ÏºÄÏ§ÑÎßÅÏùò ÌïµÏã¨)
 39e:	c3                   	ret    

0000039f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 39f:	55                   	push   %ebp
 3a0:	89 e5                	mov    %esp,%ebp
 3a2:	57                   	push   %edi
 3a3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3a7:	8b 55 10             	mov    0x10(%ebp),%edx
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	89 cb                	mov    %ecx,%ebx
 3af:	89 df                	mov    %ebx,%edi
 3b1:	89 d1                	mov    %edx,%ecx
 3b3:	fc                   	cld    
 3b4:	f3 aa                	rep stos %al,%es:(%edi)
 3b6:	89 ca                	mov    %ecx,%edx
 3b8:	89 fb                	mov    %edi,%ebx
 3ba:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3bd:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3c0:	90                   	nop
 3c1:	5b                   	pop    %ebx
 3c2:	5f                   	pop    %edi
 3c3:	5d                   	pop    %ebp
 3c4:	c3                   	ret    

000003c5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3c5:	f3 0f 1e fb          	endbr32 
 3c9:	55                   	push   %ebp
 3ca:	89 e5                	mov    %esp,%ebp
 3cc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3d5:	90                   	nop
 3d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 3d9:	8d 42 01             	lea    0x1(%edx),%eax
 3dc:	89 45 0c             	mov    %eax,0xc(%ebp)
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	8d 48 01             	lea    0x1(%eax),%ecx
 3e5:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3e8:	0f b6 12             	movzbl (%edx),%edx
 3eb:	88 10                	mov    %dl,(%eax)
 3ed:	0f b6 00             	movzbl (%eax),%eax
 3f0:	84 c0                	test   %al,%al
 3f2:	75 e2                	jne    3d6 <strcpy+0x11>
    ;
  return os;
 3f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f7:	c9                   	leave  
 3f8:	c3                   	ret    

000003f9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3f9:	f3 0f 1e fb          	endbr32 
 3fd:	55                   	push   %ebp
 3fe:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 400:	eb 08                	jmp    40a <strcmp+0x11>
    p++, q++;
 402:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 406:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 40a:	8b 45 08             	mov    0x8(%ebp),%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	84 c0                	test   %al,%al
 412:	74 10                	je     424 <strcmp+0x2b>
 414:	8b 45 08             	mov    0x8(%ebp),%eax
 417:	0f b6 10             	movzbl (%eax),%edx
 41a:	8b 45 0c             	mov    0xc(%ebp),%eax
 41d:	0f b6 00             	movzbl (%eax),%eax
 420:	38 c2                	cmp    %al,%dl
 422:	74 de                	je     402 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	0f b6 00             	movzbl (%eax),%eax
 42a:	0f b6 d0             	movzbl %al,%edx
 42d:	8b 45 0c             	mov    0xc(%ebp),%eax
 430:	0f b6 00             	movzbl (%eax),%eax
 433:	0f b6 c0             	movzbl %al,%eax
 436:	29 c2                	sub    %eax,%edx
 438:	89 d0                	mov    %edx,%eax
}
 43a:	5d                   	pop    %ebp
 43b:	c3                   	ret    

0000043c <strlen>:

uint
strlen(char *s)
{
 43c:	f3 0f 1e fb          	endbr32 
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 446:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 44d:	eb 04                	jmp    453 <strlen+0x17>
 44f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 453:	8b 55 fc             	mov    -0x4(%ebp),%edx
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	01 d0                	add    %edx,%eax
 45b:	0f b6 00             	movzbl (%eax),%eax
 45e:	84 c0                	test   %al,%al
 460:	75 ed                	jne    44f <strlen+0x13>
    ;
  return n;
 462:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 465:	c9                   	leave  
 466:	c3                   	ret    

00000467 <memset>:

void*
memset(void *dst, int c, uint n)
{
 467:	f3 0f 1e fb          	endbr32 
 46b:	55                   	push   %ebp
 46c:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 46e:	8b 45 10             	mov    0x10(%ebp),%eax
 471:	50                   	push   %eax
 472:	ff 75 0c             	pushl  0xc(%ebp)
 475:	ff 75 08             	pushl  0x8(%ebp)
 478:	e8 22 ff ff ff       	call   39f <stosb>
 47d:	83 c4 0c             	add    $0xc,%esp
  return dst;
 480:	8b 45 08             	mov    0x8(%ebp),%eax
}
 483:	c9                   	leave  
 484:	c3                   	ret    

00000485 <strchr>:

char*
strchr(const char *s, char c)
{
 485:	f3 0f 1e fb          	endbr32 
 489:	55                   	push   %ebp
 48a:	89 e5                	mov    %esp,%ebp
 48c:	83 ec 04             	sub    $0x4,%esp
 48f:	8b 45 0c             	mov    0xc(%ebp),%eax
 492:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 495:	eb 14                	jmp    4ab <strchr+0x26>
    if(*s == c)
 497:	8b 45 08             	mov    0x8(%ebp),%eax
 49a:	0f b6 00             	movzbl (%eax),%eax
 49d:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4a0:	75 05                	jne    4a7 <strchr+0x22>
      return (char*)s;
 4a2:	8b 45 08             	mov    0x8(%ebp),%eax
 4a5:	eb 13                	jmp    4ba <strchr+0x35>
  for(; *s; s++)
 4a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	84 c0                	test   %al,%al
 4b3:	75 e2                	jne    497 <strchr+0x12>
  return 0;
 4b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4ba:	c9                   	leave  
 4bb:	c3                   	ret    

000004bc <gets>:

char*
gets(char *buf, int max)
{
 4bc:	f3 0f 1e fb          	endbr32 
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4cd:	eb 42                	jmp    511 <gets+0x55>
    cc = read(0, &c, 1);
 4cf:	83 ec 04             	sub    $0x4,%esp
 4d2:	6a 01                	push   $0x1
 4d4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4d7:	50                   	push   %eax
 4d8:	6a 00                	push   $0x0
 4da:	e8 53 01 00 00       	call   632 <read>
 4df:	83 c4 10             	add    $0x10,%esp
 4e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e9:	7e 33                	jle    51e <gets+0x62>
      break;
    buf[i++] = c;
 4eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ee:	8d 50 01             	lea    0x1(%eax),%edx
 4f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f4:	89 c2                	mov    %eax,%edx
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	01 c2                	add    %eax,%edx
 4fb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ff:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 501:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 505:	3c 0a                	cmp    $0xa,%al
 507:	74 16                	je     51f <gets+0x63>
 509:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 50d:	3c 0d                	cmp    $0xd,%al
 50f:	74 0e                	je     51f <gets+0x63>
  for(i=0; i+1 < max; ){
 511:	8b 45 f4             	mov    -0xc(%ebp),%eax
 514:	83 c0 01             	add    $0x1,%eax
 517:	39 45 0c             	cmp    %eax,0xc(%ebp)
 51a:	7f b3                	jg     4cf <gets+0x13>
 51c:	eb 01                	jmp    51f <gets+0x63>
      break;
 51e:	90                   	nop
      break;
  }
  buf[i] = '\0';
 51f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 522:	8b 45 08             	mov    0x8(%ebp),%eax
 525:	01 d0                	add    %edx,%eax
 527:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 52d:	c9                   	leave  
 52e:	c3                   	ret    

0000052f <stat>:

int
stat(char *n, struct stat *st)
{
 52f:	f3 0f 1e fb          	endbr32 
 533:	55                   	push   %ebp
 534:	89 e5                	mov    %esp,%ebp
 536:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 539:	83 ec 08             	sub    $0x8,%esp
 53c:	6a 00                	push   $0x0
 53e:	ff 75 08             	pushl  0x8(%ebp)
 541:	e8 14 01 00 00       	call   65a <open>
 546:	83 c4 10             	add    $0x10,%esp
 549:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 54c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 550:	79 07                	jns    559 <stat+0x2a>
    return -1;
 552:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 557:	eb 25                	jmp    57e <stat+0x4f>
  r = fstat(fd, st);
 559:	83 ec 08             	sub    $0x8,%esp
 55c:	ff 75 0c             	pushl  0xc(%ebp)
 55f:	ff 75 f4             	pushl  -0xc(%ebp)
 562:	e8 0b 01 00 00       	call   672 <fstat>
 567:	83 c4 10             	add    $0x10,%esp
 56a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 56d:	83 ec 0c             	sub    $0xc,%esp
 570:	ff 75 f4             	pushl  -0xc(%ebp)
 573:	e8 ca 00 00 00       	call   642 <close>
 578:	83 c4 10             	add    $0x10,%esp
  return r;
 57b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 57e:	c9                   	leave  
 57f:	c3                   	ret    

00000580 <atoi>:

int
atoi(const char *s)
{
 580:	f3 0f 1e fb          	endbr32 
 584:	55                   	push   %ebp
 585:	89 e5                	mov    %esp,%ebp
 587:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 58a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 591:	eb 25                	jmp    5b8 <atoi+0x38>
    n = n*10 + *s++ - '0';
 593:	8b 55 fc             	mov    -0x4(%ebp),%edx
 596:	89 d0                	mov    %edx,%eax
 598:	c1 e0 02             	shl    $0x2,%eax
 59b:	01 d0                	add    %edx,%eax
 59d:	01 c0                	add    %eax,%eax
 59f:	89 c1                	mov    %eax,%ecx
 5a1:	8b 45 08             	mov    0x8(%ebp),%eax
 5a4:	8d 50 01             	lea    0x1(%eax),%edx
 5a7:	89 55 08             	mov    %edx,0x8(%ebp)
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	0f be c0             	movsbl %al,%eax
 5b0:	01 c8                	add    %ecx,%eax
 5b2:	83 e8 30             	sub    $0x30,%eax
 5b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	0f b6 00             	movzbl (%eax),%eax
 5be:	3c 2f                	cmp    $0x2f,%al
 5c0:	7e 0a                	jle    5cc <atoi+0x4c>
 5c2:	8b 45 08             	mov    0x8(%ebp),%eax
 5c5:	0f b6 00             	movzbl (%eax),%eax
 5c8:	3c 39                	cmp    $0x39,%al
 5ca:	7e c7                	jle    593 <atoi+0x13>
  return n;
 5cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5cf:	c9                   	leave  
 5d0:	c3                   	ret    

000005d1 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5d1:	f3 0f 1e fb          	endbr32 
 5d5:	55                   	push   %ebp
 5d6:	89 e5                	mov    %esp,%ebp
 5d8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5e7:	eb 17                	jmp    600 <memmove+0x2f>
    *dst++ = *src++;
 5e9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5ec:	8d 42 01             	lea    0x1(%edx),%eax
 5ef:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f5:	8d 48 01             	lea    0x1(%eax),%ecx
 5f8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5fb:	0f b6 12             	movzbl (%edx),%edx
 5fe:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 600:	8b 45 10             	mov    0x10(%ebp),%eax
 603:	8d 50 ff             	lea    -0x1(%eax),%edx
 606:	89 55 10             	mov    %edx,0x10(%ebp)
 609:	85 c0                	test   %eax,%eax
 60b:	7f dc                	jg     5e9 <memmove+0x18>
  return vdst;
 60d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 610:	c9                   	leave  
 611:	c3                   	ret    

00000612 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 612:	b8 01 00 00 00       	mov    $0x1,%eax
 617:	cd 40                	int    $0x40
 619:	c3                   	ret    

0000061a <exit>:
SYSCALL(exit)
 61a:	b8 02 00 00 00       	mov    $0x2,%eax
 61f:	cd 40                	int    $0x40
 621:	c3                   	ret    

00000622 <wait>:
SYSCALL(wait)
 622:	b8 03 00 00 00       	mov    $0x3,%eax
 627:	cd 40                	int    $0x40
 629:	c3                   	ret    

0000062a <pipe>:
SYSCALL(pipe)
 62a:	b8 04 00 00 00       	mov    $0x4,%eax
 62f:	cd 40                	int    $0x40
 631:	c3                   	ret    

00000632 <read>:
SYSCALL(read)
 632:	b8 05 00 00 00       	mov    $0x5,%eax
 637:	cd 40                	int    $0x40
 639:	c3                   	ret    

0000063a <write>:
SYSCALL(write)
 63a:	b8 10 00 00 00       	mov    $0x10,%eax
 63f:	cd 40                	int    $0x40
 641:	c3                   	ret    

00000642 <close>:
SYSCALL(close)
 642:	b8 15 00 00 00       	mov    $0x15,%eax
 647:	cd 40                	int    $0x40
 649:	c3                   	ret    

0000064a <kill>:
SYSCALL(kill)
 64a:	b8 06 00 00 00       	mov    $0x6,%eax
 64f:	cd 40                	int    $0x40
 651:	c3                   	ret    

00000652 <exec>:
SYSCALL(exec)
 652:	b8 07 00 00 00       	mov    $0x7,%eax
 657:	cd 40                	int    $0x40
 659:	c3                   	ret    

0000065a <open>:
SYSCALL(open)
 65a:	b8 0f 00 00 00       	mov    $0xf,%eax
 65f:	cd 40                	int    $0x40
 661:	c3                   	ret    

00000662 <mknod>:
SYSCALL(mknod)
 662:	b8 11 00 00 00       	mov    $0x11,%eax
 667:	cd 40                	int    $0x40
 669:	c3                   	ret    

0000066a <unlink>:
SYSCALL(unlink)
 66a:	b8 12 00 00 00       	mov    $0x12,%eax
 66f:	cd 40                	int    $0x40
 671:	c3                   	ret    

00000672 <fstat>:
SYSCALL(fstat)
 672:	b8 08 00 00 00       	mov    $0x8,%eax
 677:	cd 40                	int    $0x40
 679:	c3                   	ret    

0000067a <link>:
SYSCALL(link)
 67a:	b8 13 00 00 00       	mov    $0x13,%eax
 67f:	cd 40                	int    $0x40
 681:	c3                   	ret    

00000682 <mkdir>:
SYSCALL(mkdir)
 682:	b8 14 00 00 00       	mov    $0x14,%eax
 687:	cd 40                	int    $0x40
 689:	c3                   	ret    

0000068a <chdir>:
SYSCALL(chdir)
 68a:	b8 09 00 00 00       	mov    $0x9,%eax
 68f:	cd 40                	int    $0x40
 691:	c3                   	ret    

00000692 <dup>:
SYSCALL(dup)
 692:	b8 0a 00 00 00       	mov    $0xa,%eax
 697:	cd 40                	int    $0x40
 699:	c3                   	ret    

0000069a <getpid>:
SYSCALL(getpid)
 69a:	b8 0b 00 00 00       	mov    $0xb,%eax
 69f:	cd 40                	int    $0x40
 6a1:	c3                   	ret    

000006a2 <sbrk>:
SYSCALL(sbrk)
 6a2:	b8 0c 00 00 00       	mov    $0xc,%eax
 6a7:	cd 40                	int    $0x40
 6a9:	c3                   	ret    

000006aa <sleep>:
SYSCALL(sleep)
 6aa:	b8 0d 00 00 00       	mov    $0xd,%eax
 6af:	cd 40                	int    $0x40
 6b1:	c3                   	ret    

000006b2 <uptime>:
SYSCALL(uptime)
 6b2:	b8 0e 00 00 00       	mov    $0xe,%eax
 6b7:	cd 40                	int    $0x40
 6b9:	c3                   	ret    

000006ba <uthread_init>:
SYSCALL(uthread_init)
 6ba:	b8 16 00 00 00       	mov    $0x16,%eax
 6bf:	cd 40                	int    $0x40
 6c1:	c3                   	ret    

000006c2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6c2:	f3 0f 1e fb          	endbr32 
 6c6:	55                   	push   %ebp
 6c7:	89 e5                	mov    %esp,%ebp
 6c9:	83 ec 18             	sub    $0x18,%esp
 6cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cf:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6d2:	83 ec 04             	sub    $0x4,%esp
 6d5:	6a 01                	push   $0x1
 6d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6da:	50                   	push   %eax
 6db:	ff 75 08             	pushl  0x8(%ebp)
 6de:	e8 57 ff ff ff       	call   63a <write>
 6e3:	83 c4 10             	add    $0x10,%esp
}
 6e6:	90                   	nop
 6e7:	c9                   	leave  
 6e8:	c3                   	ret    

000006e9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6e9:	f3 0f 1e fb          	endbr32 
 6ed:	55                   	push   %ebp
 6ee:	89 e5                	mov    %esp,%ebp
 6f0:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6fa:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6fe:	74 17                	je     717 <printint+0x2e>
 700:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 704:	79 11                	jns    717 <printint+0x2e>
    neg = 1;
 706:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 70d:	8b 45 0c             	mov    0xc(%ebp),%eax
 710:	f7 d8                	neg    %eax
 712:	89 45 ec             	mov    %eax,-0x14(%ebp)
 715:	eb 06                	jmp    71d <printint+0x34>
  } else {
    x = xx;
 717:	8b 45 0c             	mov    0xc(%ebp),%eax
 71a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 71d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 724:	8b 4d 10             	mov    0x10(%ebp),%ecx
 727:	8b 45 ec             	mov    -0x14(%ebp),%eax
 72a:	ba 00 00 00 00       	mov    $0x0,%edx
 72f:	f7 f1                	div    %ecx
 731:	89 d1                	mov    %edx,%ecx
 733:	8b 45 f4             	mov    -0xc(%ebp),%eax
 736:	8d 50 01             	lea    0x1(%eax),%edx
 739:	89 55 f4             	mov    %edx,-0xc(%ebp)
 73c:	0f b6 91 94 10 00 00 	movzbl 0x1094(%ecx),%edx
 743:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 747:	8b 4d 10             	mov    0x10(%ebp),%ecx
 74a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 74d:	ba 00 00 00 00       	mov    $0x0,%edx
 752:	f7 f1                	div    %ecx
 754:	89 45 ec             	mov    %eax,-0x14(%ebp)
 757:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 75b:	75 c7                	jne    724 <printint+0x3b>
  if(neg)
 75d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 761:	74 2d                	je     790 <printint+0xa7>
    buf[i++] = '-';
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	8d 50 01             	lea    0x1(%eax),%edx
 769:	89 55 f4             	mov    %edx,-0xc(%ebp)
 76c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 771:	eb 1d                	jmp    790 <printint+0xa7>
    putc(fd, buf[i]);
 773:	8d 55 dc             	lea    -0x24(%ebp),%edx
 776:	8b 45 f4             	mov    -0xc(%ebp),%eax
 779:	01 d0                	add    %edx,%eax
 77b:	0f b6 00             	movzbl (%eax),%eax
 77e:	0f be c0             	movsbl %al,%eax
 781:	83 ec 08             	sub    $0x8,%esp
 784:	50                   	push   %eax
 785:	ff 75 08             	pushl  0x8(%ebp)
 788:	e8 35 ff ff ff       	call   6c2 <putc>
 78d:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 790:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 794:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 798:	79 d9                	jns    773 <printint+0x8a>
}
 79a:	90                   	nop
 79b:	90                   	nop
 79c:	c9                   	leave  
 79d:	c3                   	ret    

0000079e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 79e:	f3 0f 1e fb          	endbr32 
 7a2:	55                   	push   %ebp
 7a3:	89 e5                	mov    %esp,%ebp
 7a5:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7af:	8d 45 0c             	lea    0xc(%ebp),%eax
 7b2:	83 c0 04             	add    $0x4,%eax
 7b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7bf:	e9 59 01 00 00       	jmp    91d <printf+0x17f>
    c = fmt[i] & 0xff;
 7c4:	8b 55 0c             	mov    0xc(%ebp),%edx
 7c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ca:	01 d0                	add    %edx,%eax
 7cc:	0f b6 00             	movzbl (%eax),%eax
 7cf:	0f be c0             	movsbl %al,%eax
 7d2:	25 ff 00 00 00       	and    $0xff,%eax
 7d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7da:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7de:	75 2c                	jne    80c <printf+0x6e>
      if(c == '%'){
 7e0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e4:	75 0c                	jne    7f2 <printf+0x54>
        state = '%';
 7e6:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7ed:	e9 27 01 00 00       	jmp    919 <printf+0x17b>
      } else {
        putc(fd, c);
 7f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f5:	0f be c0             	movsbl %al,%eax
 7f8:	83 ec 08             	sub    $0x8,%esp
 7fb:	50                   	push   %eax
 7fc:	ff 75 08             	pushl  0x8(%ebp)
 7ff:	e8 be fe ff ff       	call   6c2 <putc>
 804:	83 c4 10             	add    $0x10,%esp
 807:	e9 0d 01 00 00       	jmp    919 <printf+0x17b>
      }
    } else if(state == '%'){
 80c:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 810:	0f 85 03 01 00 00    	jne    919 <printf+0x17b>
      if(c == 'd'){
 816:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 81a:	75 1e                	jne    83a <printf+0x9c>
        printint(fd, *ap, 10, 1);
 81c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	6a 01                	push   $0x1
 823:	6a 0a                	push   $0xa
 825:	50                   	push   %eax
 826:	ff 75 08             	pushl  0x8(%ebp)
 829:	e8 bb fe ff ff       	call   6e9 <printint>
 82e:	83 c4 10             	add    $0x10,%esp
        ap++;
 831:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 835:	e9 d8 00 00 00       	jmp    912 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 83a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 83e:	74 06                	je     846 <printf+0xa8>
 840:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 844:	75 1e                	jne    864 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 846:	8b 45 e8             	mov    -0x18(%ebp),%eax
 849:	8b 00                	mov    (%eax),%eax
 84b:	6a 00                	push   $0x0
 84d:	6a 10                	push   $0x10
 84f:	50                   	push   %eax
 850:	ff 75 08             	pushl  0x8(%ebp)
 853:	e8 91 fe ff ff       	call   6e9 <printint>
 858:	83 c4 10             	add    $0x10,%esp
        ap++;
 85b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 85f:	e9 ae 00 00 00       	jmp    912 <printf+0x174>
      } else if(c == 's'){
 864:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 868:	75 43                	jne    8ad <printf+0x10f>
        s = (char*)*ap;
 86a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 86d:	8b 00                	mov    (%eax),%eax
 86f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 872:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 876:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 87a:	75 25                	jne    8a1 <printf+0x103>
          s = "(null)";
 87c:	c7 45 f4 a4 0d 00 00 	movl   $0xda4,-0xc(%ebp)
        while(*s != 0){
 883:	eb 1c                	jmp    8a1 <printf+0x103>
          putc(fd, *s);
 885:	8b 45 f4             	mov    -0xc(%ebp),%eax
 888:	0f b6 00             	movzbl (%eax),%eax
 88b:	0f be c0             	movsbl %al,%eax
 88e:	83 ec 08             	sub    $0x8,%esp
 891:	50                   	push   %eax
 892:	ff 75 08             	pushl  0x8(%ebp)
 895:	e8 28 fe ff ff       	call   6c2 <putc>
 89a:	83 c4 10             	add    $0x10,%esp
          s++;
 89d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 8a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a4:	0f b6 00             	movzbl (%eax),%eax
 8a7:	84 c0                	test   %al,%al
 8a9:	75 da                	jne    885 <printf+0xe7>
 8ab:	eb 65                	jmp    912 <printf+0x174>
        }
      } else if(c == 'c'){
 8ad:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8b1:	75 1d                	jne    8d0 <printf+0x132>
        putc(fd, *ap);
 8b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b6:	8b 00                	mov    (%eax),%eax
 8b8:	0f be c0             	movsbl %al,%eax
 8bb:	83 ec 08             	sub    $0x8,%esp
 8be:	50                   	push   %eax
 8bf:	ff 75 08             	pushl  0x8(%ebp)
 8c2:	e8 fb fd ff ff       	call   6c2 <putc>
 8c7:	83 c4 10             	add    $0x10,%esp
        ap++;
 8ca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8ce:	eb 42                	jmp    912 <printf+0x174>
      } else if(c == '%'){
 8d0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8d4:	75 17                	jne    8ed <printf+0x14f>
        putc(fd, c);
 8d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8d9:	0f be c0             	movsbl %al,%eax
 8dc:	83 ec 08             	sub    $0x8,%esp
 8df:	50                   	push   %eax
 8e0:	ff 75 08             	pushl  0x8(%ebp)
 8e3:	e8 da fd ff ff       	call   6c2 <putc>
 8e8:	83 c4 10             	add    $0x10,%esp
 8eb:	eb 25                	jmp    912 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8ed:	83 ec 08             	sub    $0x8,%esp
 8f0:	6a 25                	push   $0x25
 8f2:	ff 75 08             	pushl  0x8(%ebp)
 8f5:	e8 c8 fd ff ff       	call   6c2 <putc>
 8fa:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 900:	0f be c0             	movsbl %al,%eax
 903:	83 ec 08             	sub    $0x8,%esp
 906:	50                   	push   %eax
 907:	ff 75 08             	pushl  0x8(%ebp)
 90a:	e8 b3 fd ff ff       	call   6c2 <putc>
 90f:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 912:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 919:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 91d:	8b 55 0c             	mov    0xc(%ebp),%edx
 920:	8b 45 f0             	mov    -0x10(%ebp),%eax
 923:	01 d0                	add    %edx,%eax
 925:	0f b6 00             	movzbl (%eax),%eax
 928:	84 c0                	test   %al,%al
 92a:	0f 85 94 fe ff ff    	jne    7c4 <printf+0x26>
    }
  }
}
 930:	90                   	nop
 931:	90                   	nop
 932:	c9                   	leave  
 933:	c3                   	ret    

00000934 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 934:	f3 0f 1e fb          	endbr32 
 938:	55                   	push   %ebp
 939:	89 e5                	mov    %esp,%ebp
 93b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 93e:	8b 45 08             	mov    0x8(%ebp),%eax
 941:	83 e8 08             	sub    $0x8,%eax
 944:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 947:	a1 e8 90 00 00       	mov    0x90e8,%eax
 94c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 94f:	eb 24                	jmp    975 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 959:	72 12                	jb     96d <free+0x39>
 95b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 961:	77 24                	ja     987 <free+0x53>
 963:	8b 45 fc             	mov    -0x4(%ebp),%eax
 966:	8b 00                	mov    (%eax),%eax
 968:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 96b:	72 1a                	jb     987 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 96d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 970:	8b 00                	mov    (%eax),%eax
 972:	89 45 fc             	mov    %eax,-0x4(%ebp)
 975:	8b 45 f8             	mov    -0x8(%ebp),%eax
 978:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 97b:	76 d4                	jbe    951 <free+0x1d>
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	8b 00                	mov    (%eax),%eax
 982:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 985:	73 ca                	jae    951 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 987:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98a:	8b 40 04             	mov    0x4(%eax),%eax
 98d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 994:	8b 45 f8             	mov    -0x8(%ebp),%eax
 997:	01 c2                	add    %eax,%edx
 999:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99c:	8b 00                	mov    (%eax),%eax
 99e:	39 c2                	cmp    %eax,%edx
 9a0:	75 24                	jne    9c6 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 9a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a5:	8b 50 04             	mov    0x4(%eax),%edx
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	8b 00                	mov    (%eax),%eax
 9ad:	8b 40 04             	mov    0x4(%eax),%eax
 9b0:	01 c2                	add    %eax,%edx
 9b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	8b 00                	mov    (%eax),%eax
 9bd:	8b 10                	mov    (%eax),%edx
 9bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c2:	89 10                	mov    %edx,(%eax)
 9c4:	eb 0a                	jmp    9d0 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 9c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c9:	8b 10                	mov    (%eax),%edx
 9cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ce:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d3:	8b 40 04             	mov    0x4(%eax),%eax
 9d6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e0:	01 d0                	add    %edx,%eax
 9e2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9e5:	75 20                	jne    a07 <free+0xd3>
    p->s.size += bp->s.size;
 9e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ea:	8b 50 04             	mov    0x4(%eax),%edx
 9ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f0:	8b 40 04             	mov    0x4(%eax),%eax
 9f3:	01 c2                	add    %eax,%edx
 9f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fe:	8b 10                	mov    (%eax),%edx
 a00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a03:	89 10                	mov    %edx,(%eax)
 a05:	eb 08                	jmp    a0f <free+0xdb>
  } else
    p->s.ptr = bp;
 a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a0d:	89 10                	mov    %edx,(%eax)
  freep = p;
 a0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a12:	a3 e8 90 00 00       	mov    %eax,0x90e8
}
 a17:	90                   	nop
 a18:	c9                   	leave  
 a19:	c3                   	ret    

00000a1a <morecore>:

static Header*
morecore(uint nu)
{
 a1a:	f3 0f 1e fb          	endbr32 
 a1e:	55                   	push   %ebp
 a1f:	89 e5                	mov    %esp,%ebp
 a21:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a24:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a2b:	77 07                	ja     a34 <morecore+0x1a>
    nu = 4096;
 a2d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a34:	8b 45 08             	mov    0x8(%ebp),%eax
 a37:	c1 e0 03             	shl    $0x3,%eax
 a3a:	83 ec 0c             	sub    $0xc,%esp
 a3d:	50                   	push   %eax
 a3e:	e8 5f fc ff ff       	call   6a2 <sbrk>
 a43:	83 c4 10             	add    $0x10,%esp
 a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a49:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a4d:	75 07                	jne    a56 <morecore+0x3c>
    return 0;
 a4f:	b8 00 00 00 00       	mov    $0x0,%eax
 a54:	eb 26                	jmp    a7c <morecore+0x62>
  hp = (Header*)p;
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5f:	8b 55 08             	mov    0x8(%ebp),%edx
 a62:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a68:	83 c0 08             	add    $0x8,%eax
 a6b:	83 ec 0c             	sub    $0xc,%esp
 a6e:	50                   	push   %eax
 a6f:	e8 c0 fe ff ff       	call   934 <free>
 a74:	83 c4 10             	add    $0x10,%esp
  return freep;
 a77:	a1 e8 90 00 00       	mov    0x90e8,%eax
}
 a7c:	c9                   	leave  
 a7d:	c3                   	ret    

00000a7e <malloc>:

void*
malloc(uint nbytes)
{
 a7e:	f3 0f 1e fb          	endbr32 
 a82:	55                   	push   %ebp
 a83:	89 e5                	mov    %esp,%ebp
 a85:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a88:	8b 45 08             	mov    0x8(%ebp),%eax
 a8b:	83 c0 07             	add    $0x7,%eax
 a8e:	c1 e8 03             	shr    $0x3,%eax
 a91:	83 c0 01             	add    $0x1,%eax
 a94:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a97:	a1 e8 90 00 00       	mov    0x90e8,%eax
 a9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aa3:	75 23                	jne    ac8 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 aa5:	c7 45 f0 e0 90 00 00 	movl   $0x90e0,-0x10(%ebp)
 aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aaf:	a3 e8 90 00 00       	mov    %eax,0x90e8
 ab4:	a1 e8 90 00 00       	mov    0x90e8,%eax
 ab9:	a3 e0 90 00 00       	mov    %eax,0x90e0
    base.s.size = 0;
 abe:	c7 05 e4 90 00 00 00 	movl   $0x0,0x90e4
 ac5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acb:	8b 00                	mov    (%eax),%eax
 acd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad3:	8b 40 04             	mov    0x4(%eax),%eax
 ad6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ad9:	77 4d                	ja     b28 <malloc+0xaa>
      if(p->s.size == nunits)
 adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ade:	8b 40 04             	mov    0x4(%eax),%eax
 ae1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ae4:	75 0c                	jne    af2 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae9:	8b 10                	mov    (%eax),%edx
 aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aee:	89 10                	mov    %edx,(%eax)
 af0:	eb 26                	jmp    b18 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af5:	8b 40 04             	mov    0x4(%eax),%eax
 af8:	2b 45 ec             	sub    -0x14(%ebp),%eax
 afb:	89 c2                	mov    %eax,%edx
 afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b00:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b06:	8b 40 04             	mov    0x4(%eax),%eax
 b09:	c1 e0 03             	shl    $0x3,%eax
 b0c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b12:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b15:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b1b:	a3 e8 90 00 00       	mov    %eax,0x90e8
      return (void*)(p + 1);
 b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b23:	83 c0 08             	add    $0x8,%eax
 b26:	eb 3b                	jmp    b63 <malloc+0xe5>
    }
    if(p == freep)
 b28:	a1 e8 90 00 00       	mov    0x90e8,%eax
 b2d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b30:	75 1e                	jne    b50 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 b32:	83 ec 0c             	sub    $0xc,%esp
 b35:	ff 75 ec             	pushl  -0x14(%ebp)
 b38:	e8 dd fe ff ff       	call   a1a <morecore>
 b3d:	83 c4 10             	add    $0x10,%esp
 b40:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b47:	75 07                	jne    b50 <malloc+0xd2>
        return 0;
 b49:	b8 00 00 00 00       	mov    $0x0,%eax
 b4e:	eb 13                	jmp    b63 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b53:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b59:	8b 00                	mov    (%eax),%eax
 b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b5e:	e9 6d ff ff ff       	jmp    ad0 <malloc+0x52>
  }
}
 b63:	c9                   	leave  
 b64:	c3                   	ret    
