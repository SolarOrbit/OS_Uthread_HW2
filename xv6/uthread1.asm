
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
   a:	a1 8c 8e 00 00       	mov    0x8e8c,%eax
   f:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
  16:	00 00 00 
    // printf(1, "thread 0x%x exiting...\n", (int)current_thread); // ∑Œ±◊ « ø‰Ω√ »∞º∫»≠
    thread_schedule();
  19:	e8 17 00 00 00       	call   35 <thread_schedule>
    printf(2, "thread_exit: scheduler returned unexpectedly\n");
  1e:	83 ec 08             	sub    $0x8,%esp
  21:	68 a4 0a 00 00       	push   $0xaa4
  26:	6a 02                	push   $0x2
  28:	e8 af 06 00 00       	call   6dc <printf>
  2d:	83 c4 10             	add    $0x10,%esp
    exit();
  30:	e8 23 05 00 00       	call   558 <exit>

00000035 <thread_schedule>:
}

// Ω∫ƒ…¡Ÿ∑Ø «‘ºˆ (√÷¡æ πˆ¿¸)
static void thread_schedule(void) {
  35:	f3 0f 1e fb          	endbr32 
  39:	55                   	push   %ebp
  3a:	89 e5                	mov    %esp,%ebp
  3c:	83 ec 18             	sub    $0x18,%esp
    thread_p t, found_next = 0;
  3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int i;
    thread_p current_save = current_thread;
  46:	a1 8c 8e 00 00       	mov    0x8e8c,%eax
  4b:	89 45 ec             	mov    %eax,-0x14(%ebp)

    // printf(1, "thread_schedule called! (current=0x%x)\n", (int)current_save);

    for (i = 0; i < MAX_THREAD; i++) {
  4e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  55:	eb 3c                	jmp    93 <thread_schedule+0x5e>
        t = &all_thread[i];
  57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  5a:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
  60:	05 60 0e 00 00       	add    $0xe60,%eax
  65:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // Ω∫∑πµÂ 0(main)∞˙ ¿⁄±‚ ¿⁄Ω≈¿ª ¡¶ø‹«œ∞Ì RUNNABLE Ω∫∑πµÂ ∞Àªˆ
        if (t->state == RUNNABLE && t != current_save && t != &all_thread[0]) {
  68:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  71:	83 f8 02             	cmp    $0x2,%eax
  74:	75 19                	jne    8f <thread_schedule+0x5a>
  76:	8b 45 e8             	mov    -0x18(%ebp),%eax
  79:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  7c:	74 11                	je     8f <thread_schedule+0x5a>
  7e:	81 7d e8 60 0e 00 00 	cmpl   $0xe60,-0x18(%ebp)
  85:	74 08                	je     8f <thread_schedule+0x5a>
            // printf(1, "  Found runnable thread %d (addr=0x%x)\n", i, (int)t);
            found_next = t;
  87:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  8d:	eb 0a                	jmp    99 <thread_schedule+0x64>
    for (i = 0; i < MAX_THREAD; i++) {
  8f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  93:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
  97:	7e be                	jle    57 <thread_schedule+0x22>
        }
    }

    if (found_next != 0) {
  99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  9d:	74 3f                	je     de <thread_schedule+0xa9>
        next_thread = found_next;
  9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a2:	a3 90 8e 00 00       	mov    %eax,0x8e90
        // printf(1, "  Switching from 0x%x to 0x%x\n", (int)current_save, (int)next_thread);
        next_thread->state = RUNNING;
  a7:	a1 90 8e 00 00       	mov    0x8e90,%eax
  ac:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  b3:	00 00 00 
        if (current_save != 0 && current_save->state == RUNNING) {
  b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  ba:	74 1b                	je     d7 <thread_schedule+0xa2>
  bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  bf:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  c5:	83 f8 01             	cmp    $0x1,%eax
  c8:	75 0d                	jne    d7 <thread_schedule+0xa2>
            current_save->state = RUNNABLE;
  ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  cd:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  d4:	00 00 00 
        }
        thread_switch();
  d7:	e8 e5 01 00 00       	call   2c1 <thread_switch>
        else {
            printf(2, "thread_schedule: no runnable threads\n"); // √÷¡æ ¡æ∑· ∏ﬁΩ√¡ˆ
            exit();
        }
    }
}
  dc:	eb 37                	jmp    115 <thread_schedule+0xe0>
        if (current_save != 0 && current_save->state == RUNNING) {
  de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  e2:	74 1a                	je     fe <thread_schedule+0xc9>
  e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  e7:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  ed:	83 f8 01             	cmp    $0x1,%eax
  f0:	75 0c                	jne    fe <thread_schedule+0xc9>
            next_thread = 0;
  f2:	c7 05 90 8e 00 00 00 	movl   $0x0,0x8e90
  f9:	00 00 00 
}
  fc:	eb 17                	jmp    115 <thread_schedule+0xe0>
            printf(2, "thread_schedule: no runnable threads\n"); // √÷¡æ ¡æ∑· ∏ﬁΩ√¡ˆ
  fe:	83 ec 08             	sub    $0x8,%esp
 101:	68 d4 0a 00 00       	push   $0xad4
 106:	6a 02                	push   $0x2
 108:	e8 cf 05 00 00       	call   6dc <printf>
 10d:	83 c4 10             	add    $0x10,%esp
            exit();
 110:	e8 43 04 00 00       	call   558 <exit>
}
 115:	c9                   	leave  
 116:	c3                   	ret    

00000117 <thread_init>:

// Ω∫∑πµÂ Ω√Ω∫≈€ √ ±‚»≠ «‘ºˆ
void thread_init(void) {
 117:	f3 0f 1e fb          	endbr32 
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
 11e:	83 ec 18             	sub    $0x18,%esp
    // ¿Ã¡¶ uthread_init »£√‚ »∞º∫»≠!
    uthread_init((int)thread_schedule);
 121:	b8 35 00 00 00       	mov    $0x35,%eax
 126:	83 ec 0c             	sub    $0xc,%esp
 129:	50                   	push   %eax
 12a:	e8 c9 04 00 00       	call   5f8 <uthread_init>
 12f:	83 c4 10             	add    $0x10,%esp

    current_thread = &all_thread[0];
 132:	c7 05 8c 8e 00 00 60 	movl   $0xe60,0x8e8c
 139:	0e 00 00 
    current_thread->state = RUNNING;
 13c:	a1 8c 8e 00 00       	mov    0x8e8c,%eax
 141:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 148:	00 00 00 
    for (int i = 1; i < MAX_THREAD; i++) {
 14b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 152:	eb 18                	jmp    16c <thread_init+0x55>
        all_thread[i].state = FREE;
 154:	8b 45 f4             	mov    -0xc(%ebp),%eax
 157:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 15d:	05 64 2e 00 00       	add    $0x2e64,%eax
 162:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 1; i < MAX_THREAD; i++) {
 168:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 16c:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 170:	7e e2                	jle    154 <thread_init+0x3d>
    }
}
 172:	90                   	nop
 173:	90                   	nop
 174:	c9                   	leave  
 175:	c3                   	ret    

00000176 <thread_create>:

// ªı Ω∫∑πµÂ ª˝º∫ «‘ºˆ (Ω∫≈√ «“¥Á 16 πŸ¿Ã∆Æ∑Œ ºˆ¡§)
void thread_create(void (*func)()) {
 176:	f3 0f 1e fb          	endbr32 
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	83 ec 18             	sub    $0x18,%esp
    thread_p t;
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 180:	c7 45 f4 60 0e 00 00 	movl   $0xe60,-0xc(%ebp)
 187:	eb 14                	jmp    19d <thread_create+0x27>
        if (t->state == FREE) break;
 189:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 192:	85 c0                	test   %eax,%eax
 194:	74 13                	je     1a9 <thread_create+0x33>
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 196:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 19d:	b8 80 8e 00 00       	mov    $0x8e80,%eax
 1a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 1a5:	72 e2                	jb     189 <thread_create+0x13>
 1a7:	eb 01                	jmp    1aa <thread_create+0x34>
        if (t->state == FREE) break;
 1a9:	90                   	nop
    }
    if (t >= all_thread + MAX_THREAD) {
 1aa:	b8 80 8e 00 00       	mov    $0x8e80,%eax
 1af:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 1b2:	72 14                	jb     1c8 <thread_create+0x52>
        printf(2, "thread_create: too many threads\n");
 1b4:	83 ec 08             	sub    $0x8,%esp
 1b7:	68 fc 0a 00 00       	push   $0xafc
 1bc:	6a 02                	push   $0x2
 1be:	e8 19 05 00 00       	call   6dc <printf>
 1c3:	83 c4 10             	add    $0x10,%esp
        return;
 1c6:	eb 45                	jmp    20d <thread_create+0x97>
    }
    t->sp = (int)(t->stack + STACK_SIZE);
 1c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cb:	83 c0 04             	add    $0x4,%eax
 1ce:	05 00 20 00 00       	add    $0x2000,%eax
 1d3:	89 c2                	mov    %eax,%edx
 1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d8:	89 10                	mov    %edx,(%eax)
    t->sp -= 4; // For return address (EIP)
 1da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dd:	8b 00                	mov    (%eax),%eax
 1df:	8d 50 fc             	lea    -0x4(%eax),%edx
 1e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e5:	89 10                	mov    %edx,(%eax)
    *(int*)(t->sp) = (int)func;
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	8b 00                	mov    (%eax),%eax
 1ec:	89 c2                	mov    %eax,%edx
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
 1f1:	89 02                	mov    %eax,(%edx)
    t->sp -= 16; // For 4 registers (edi, esi, ebx, ebp)
 1f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f6:	8b 00                	mov    (%eax),%eax
 1f8:	8d 50 f0             	lea    -0x10(%eax),%edx
 1fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fe:	89 10                	mov    %edx,(%eax)
    t->state = RUNNABLE;
 200:	8b 45 f4             	mov    -0xc(%ebp),%eax
 203:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 20a:	00 00 00 
    // printf(1, "Created thread %d (addr=0x%x) starting at sp=0x%x\n", t - all_thread, (int)t, t->sp);
}
 20d:	c9                   	leave  
 20e:	c3                   	ret    

0000020f <mythread>:

// Ω∫∑πµÂ Ω««‡ «‘ºˆ (thread_exit »£√‚)
static void mythread(void) {
 20f:	f3 0f 1e fb          	endbr32 
 213:	55                   	push   %ebp
 214:	89 e5                	mov    %esp,%ebp
 216:	83 ec 18             	sub    $0x18,%esp
    int i;
    int my_addr = (int)current_thread;
 219:	a1 8c 8e 00 00       	mov    0x8e8c,%eax
 21e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // printf(1, "my thread 0x%x running\n", my_addr); // « ø‰Ω√ ∑Œ±◊ »∞º∫»≠
    for (i = 0; i < 100; i++) { // ∑Á«¡ »Ωºˆ ø¯∫π (∂«¥¬ ¿˚¿˝»˜ ¡∂¿˝)
 221:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 228:	eb 19                	jmp    243 <mythread+0x34>
        printf(1, "my thread 0x%x\n", my_addr);
 22a:	83 ec 04             	sub    $0x4,%esp
 22d:	ff 75 f0             	pushl  -0x10(%ebp)
 230:	68 1d 0b 00 00       	push   $0xb1d
 235:	6a 01                	push   $0x1
 237:	e8 a0 04 00 00       	call   6dc <printf>
 23c:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < 100; i++) { // ∑Á«¡ »Ωºˆ ø¯∫π (∂«¥¬ ¿˚¿˝»˜ ¡∂¿˝)
 23f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 243:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 247:	7e e1                	jle    22a <mythread+0x1b>
    }
    printf(1, "my thread: exit\n"); // ¡÷º“ æ¯¿Ã √‚∑¬
 249:	83 ec 08             	sub    $0x8,%esp
 24c:	68 2d 0b 00 00       	push   $0xb2d
 251:	6a 01                	push   $0x1
 253:	e8 84 04 00 00       	call   6dc <printf>
 258:	83 c4 10             	add    $0x10,%esp
    thread_exit(); // ¡§ªÛ ¡æ∑· √≥∏Æ
 25b:	e8 a0 fd ff ff       	call   0 <thread_exit>
}
 260:	90                   	nop
 261:	c9                   	leave  
 262:	c3                   	ret    

00000263 <main>:

// ∏ﬁ¿Œ «‘ºˆ
int main(int argc, char* argv[]) {
 263:	f3 0f 1e fb          	endbr32 
 267:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 26b:	83 e4 f0             	and    $0xfffffff0,%esp
 26e:	ff 71 fc             	pushl  -0x4(%ecx)
 271:	55                   	push   %ebp
 272:	89 e5                	mov    %esp,%ebp
 274:	51                   	push   %ecx
 275:	83 ec 04             	sub    $0x4,%esp
    // printf(1, "uthread1 starting\n"); // ∑Œ±◊ ¡¶∞≈
    thread_init();
 278:	e8 9a fe ff ff       	call   117 <thread_init>
    thread_create(mythread);
 27d:	83 ec 0c             	sub    $0xc,%esp
 280:	68 0f 02 00 00       	push   $0x20f
 285:	e8 ec fe ff ff       	call   176 <thread_create>
 28a:	83 c4 10             	add    $0x10,%esp
    thread_create(mythread);
 28d:	83 ec 0c             	sub    $0xc,%esp
 290:	68 0f 02 00 00       	push   $0x20f
 295:	e8 dc fe ff ff       	call   176 <thread_create>
 29a:	83 c4 10             	add    $0x10,%esp
    thread_schedule();
 29d:	e8 93 fd ff ff       	call   35 <thread_schedule>
    printf(2, "main: returned unexpectedly!\n"); // ø©±‚∑Œ ø¿∏È æ»µ 
 2a2:	83 ec 08             	sub    $0x8,%esp
 2a5:	68 3e 0b 00 00       	push   $0xb3e
 2aa:	6a 02                	push   $0x2
 2ac:	e8 2b 04 00 00       	call   6dc <printf>
 2b1:	83 c4 10             	add    $0x10,%esp
    return -1;
 2b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b9:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2bc:	c9                   	leave  
 2bd:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2c0:	c3                   	ret    

000002c1 <thread_switch>:
# thread_switch Ìï®Ïàò Ï†ïÏùò
.globl thread_switch
thread_switch:
  # 1. ÌòÑÏû¨ Ïä§Î†àÎìúÏùò Callee-saved Î†àÏßÄÏä§ÌÑ∞ Ï†ÄÏû•
  #    (Ìï®Ïàò Ìò∏Ï∂ú Ïãú Ìò∏Ï∂úÎêú Ìï®Ïàò(callee)Í∞Ä Î≥¥Ï°¥Ìï¥Ïïº ÌïòÎäî Î†àÏßÄÏä§ÌÑ∞Îì§)
  pushl %ebp
 2c1:	55                   	push   %ebp
  pushl %ebx
 2c2:	53                   	push   %ebx
  pushl %esi
 2c3:	56                   	push   %esi
  pushl %edi
 2c4:	57                   	push   %edi
  
  # 2. ÌòÑÏû¨ Ïä§ÌÉù Ìè¨Ïù∏ÌÑ∞(ESP)Î•º current_thread->sp Ïóê Ï†ÄÏû•
  #    current_thread Î≥ÄÏàò(Ìè¨Ïù∏ÌÑ∞)Ïùò Ï£ºÏÜåÎ•º %eax Î°ú Í∞ÄÏ†∏Ïò¥
  movl current_thread, %eax 
 2c5:	a1 8c 8e 00 00       	mov    0x8e8c,%eax
  #    ÌòÑÏû¨ %esp Í∞íÏùÑ current_thread Íµ¨Ï°∞Ï≤¥Ïùò Ï≤´ Î≤àÏß∏ Î©§Î≤Ñ(sp ÌïÑÎìúÎ°ú Í∞ÄÏ†ï)Ïóê Ï†ÄÏû•
  movl %esp, (%eax)        
 2ca:	89 20                	mov    %esp,(%eax)
  
  # 3. Îã§Ïùå Ïä§Î†àÎìúÎ°ú Ï†ÑÌôò (current_thread Ìè¨Ïù∏ÌÑ∞ ÏóÖÎç∞Ïù¥Ìä∏)
  #    next_thread Î≥ÄÏàò(Ìè¨Ïù∏ÌÑ∞)Ïùò Ï£ºÏÜåÎ•º %eax Î°ú Í∞ÄÏ†∏Ïò¥
  movl next_thread, %eax
 2cc:	a1 90 8e 00 00       	mov    0x8e90,%eax
  #    current_thread Î≥ÄÏàòÍ∞Ä Ïù¥Ï†ú next_thread Î•º Í∞ÄÎ¶¨ÌÇ§ÎèÑÎ°ù ÏóÖÎç∞Ïù¥Ìä∏
  movl %eax, current_thread 
 2d1:	a3 8c 8e 00 00       	mov    %eax,0x8e8c
  
  # 4. Îã§Ïùå Ïä§Î†àÎìú(Ïù¥Ï†ú current_threadÍ∞Ä Í∞ÄÎ¶¨ÌÇ¥)Ïùò Ï†ÄÏû•Îêú Ïä§ÌÉù Ìè¨Ïù∏ÌÑ∞Î•º %esp Î°ú Î≥µÏõê
  #    current_thread Í∞Ä Í∞ÄÎ¶¨ÌÇ§Îäî Íµ¨Ï°∞Ï≤¥Ïùò Ï≤´ Î≤àÏß∏ Î©§Î≤Ñ(sp ÌïÑÎìú) Í∞íÏùÑ %esp Î°ú Î°úÎìú
  #    Ïù¥Ï†ú %esp Îäî Îã§ÏùåÏóê Ïã§ÌñâÎê† Ïä§Î†àÎìúÍ∞Ä ÎßàÏßÄÎßâÏúºÎ°ú Ï†ÄÏû•ÌñàÎçò Ïä§ÌÉù ÏÉÅÌÉúÎ•º Í∞ÄÎ¶¨ÌÇ¥
  #    (Ïä§ÌÉùÏùò ÏµúÏÉÅÎã®ÏóêÎäî Ï†ÄÏû•Îêú %edi Í∞íÏù¥ ÏûàÏùå)
  movl (%eax), %esp          
 2d6:	8b 20                	mov    (%eax),%esp
  
  # 5. Îã§Ïùå Ïä§Î†àÎìúÏùò Callee-saved Î†àÏßÄÏä§ÌÑ∞ Î≥µÏõê (Ï†ÄÏû• ÏàúÏÑúÏùò Ïó≠Ïàú)
  popl %edi
 2d8:	5f                   	pop    %edi
  popl %esi
 2d9:	5e                   	pop    %esi
  popl %ebx
 2da:	5b                   	pop    %ebx
  popl %ebp
 2db:	5d                   	pop    %ebp
  #    Ìï¥Îãπ Ï£ºÏÜåÎ°ú Ï†êÌîÑÌï©ÎãàÎã§.
  #    - Ïä§Î†àÎìúÍ∞Ä Ï≤òÏùå ÏÉùÏÑ±Îêú Í≤ΩÏö∞: thread_create ÏóêÏÑú ÏÑ§Ï†ïÌïú Ïä§Î†àÎìú Ìï®Ïàò ÏãúÏûë Ï£ºÏÜå (func)
  #    - Ïä§Î†àÎìúÍ∞Ä ÌòëÏ°∞Ï†ÅÏúºÎ°ú ÏñëÎ≥¥(yield)Ìïú Í≤ΩÏö∞: thread_schedule ÎÇ¥Ïùò 'call thread_switch' Îã§Ïùå Ï£ºÏÜå
  #    - Ïä§Î†àÎìúÍ∞Ä ÏÑ†Ï†ê(preempt)Îêú Í≤ΩÏö∞: trap.c Í∞Ä ÏÇ¨Ïö©Ïûê Ïä§ÌÉùÏóê Ï†ÄÏû•Ìïú ÏõêÎûò Ïã§Ìñâ ÏßÄÏ†ê (original_eip) Ïù¥Ïñ¥Ïïº Ìï®. 
  #                                  (Ïù¥ Î∂ÄÎ∂ÑÏù¥ Ïò¨Î∞îÎ•¥Í≤å ÎèôÏûëÌïòÎäîÏßÄÍ∞Ä ÏÑ†Ï†êÌòï Ïä§ÏºÄÏ§ÑÎßÅÏùò ÌïµÏã¨)
 2dc:	c3                   	ret    

000002dd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	57                   	push   %edi
 2e1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2e5:	8b 55 10             	mov    0x10(%ebp),%edx
 2e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2eb:	89 cb                	mov    %ecx,%ebx
 2ed:	89 df                	mov    %ebx,%edi
 2ef:	89 d1                	mov    %edx,%ecx
 2f1:	fc                   	cld    
 2f2:	f3 aa                	rep stos %al,%es:(%edi)
 2f4:	89 ca                	mov    %ecx,%edx
 2f6:	89 fb                	mov    %edi,%ebx
 2f8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2fb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2fe:	90                   	nop
 2ff:	5b                   	pop    %ebx
 300:	5f                   	pop    %edi
 301:	5d                   	pop    %ebp
 302:	c3                   	ret    

00000303 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 303:	f3 0f 1e fb          	endbr32 
 307:	55                   	push   %ebp
 308:	89 e5                	mov    %esp,%ebp
 30a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 313:	90                   	nop
 314:	8b 55 0c             	mov    0xc(%ebp),%edx
 317:	8d 42 01             	lea    0x1(%edx),%eax
 31a:	89 45 0c             	mov    %eax,0xc(%ebp)
 31d:	8b 45 08             	mov    0x8(%ebp),%eax
 320:	8d 48 01             	lea    0x1(%eax),%ecx
 323:	89 4d 08             	mov    %ecx,0x8(%ebp)
 326:	0f b6 12             	movzbl (%edx),%edx
 329:	88 10                	mov    %dl,(%eax)
 32b:	0f b6 00             	movzbl (%eax),%eax
 32e:	84 c0                	test   %al,%al
 330:	75 e2                	jne    314 <strcpy+0x11>
    ;
  return os;
 332:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 335:	c9                   	leave  
 336:	c3                   	ret    

00000337 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 337:	f3 0f 1e fb          	endbr32 
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 33e:	eb 08                	jmp    348 <strcmp+0x11>
    p++, q++;
 340:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 344:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	0f b6 00             	movzbl (%eax),%eax
 34e:	84 c0                	test   %al,%al
 350:	74 10                	je     362 <strcmp+0x2b>
 352:	8b 45 08             	mov    0x8(%ebp),%eax
 355:	0f b6 10             	movzbl (%eax),%edx
 358:	8b 45 0c             	mov    0xc(%ebp),%eax
 35b:	0f b6 00             	movzbl (%eax),%eax
 35e:	38 c2                	cmp    %al,%dl
 360:	74 de                	je     340 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	0f b6 00             	movzbl (%eax),%eax
 368:	0f b6 d0             	movzbl %al,%edx
 36b:	8b 45 0c             	mov    0xc(%ebp),%eax
 36e:	0f b6 00             	movzbl (%eax),%eax
 371:	0f b6 c0             	movzbl %al,%eax
 374:	29 c2                	sub    %eax,%edx
 376:	89 d0                	mov    %edx,%eax
}
 378:	5d                   	pop    %ebp
 379:	c3                   	ret    

0000037a <strlen>:

uint
strlen(char *s)
{
 37a:	f3 0f 1e fb          	endbr32 
 37e:	55                   	push   %ebp
 37f:	89 e5                	mov    %esp,%ebp
 381:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 384:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 38b:	eb 04                	jmp    391 <strlen+0x17>
 38d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 391:	8b 55 fc             	mov    -0x4(%ebp),%edx
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	01 d0                	add    %edx,%eax
 399:	0f b6 00             	movzbl (%eax),%eax
 39c:	84 c0                	test   %al,%al
 39e:	75 ed                	jne    38d <strlen+0x13>
    ;
  return n;
 3a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a3:	c9                   	leave  
 3a4:	c3                   	ret    

000003a5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3a5:	f3 0f 1e fb          	endbr32 
 3a9:	55                   	push   %ebp
 3aa:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3ac:	8b 45 10             	mov    0x10(%ebp),%eax
 3af:	50                   	push   %eax
 3b0:	ff 75 0c             	pushl  0xc(%ebp)
 3b3:	ff 75 08             	pushl  0x8(%ebp)
 3b6:	e8 22 ff ff ff       	call   2dd <stosb>
 3bb:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c1:	c9                   	leave  
 3c2:	c3                   	ret    

000003c3 <strchr>:

char*
strchr(const char *s, char c)
{
 3c3:	f3 0f 1e fb          	endbr32 
 3c7:	55                   	push   %ebp
 3c8:	89 e5                	mov    %esp,%ebp
 3ca:	83 ec 04             	sub    $0x4,%esp
 3cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3d3:	eb 14                	jmp    3e9 <strchr+0x26>
    if(*s == c)
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3de:	75 05                	jne    3e5 <strchr+0x22>
      return (char*)s;
 3e0:	8b 45 08             	mov    0x8(%ebp),%eax
 3e3:	eb 13                	jmp    3f8 <strchr+0x35>
  for(; *s; s++)
 3e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	0f b6 00             	movzbl (%eax),%eax
 3ef:	84 c0                	test   %al,%al
 3f1:	75 e2                	jne    3d5 <strchr+0x12>
  return 0;
 3f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3f8:	c9                   	leave  
 3f9:	c3                   	ret    

000003fa <gets>:

char*
gets(char *buf, int max)
{
 3fa:	f3 0f 1e fb          	endbr32 
 3fe:	55                   	push   %ebp
 3ff:	89 e5                	mov    %esp,%ebp
 401:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 40b:	eb 42                	jmp    44f <gets+0x55>
    cc = read(0, &c, 1);
 40d:	83 ec 04             	sub    $0x4,%esp
 410:	6a 01                	push   $0x1
 412:	8d 45 ef             	lea    -0x11(%ebp),%eax
 415:	50                   	push   %eax
 416:	6a 00                	push   $0x0
 418:	e8 53 01 00 00       	call   570 <read>
 41d:	83 c4 10             	add    $0x10,%esp
 420:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 423:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 427:	7e 33                	jle    45c <gets+0x62>
      break;
    buf[i++] = c;
 429:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42c:	8d 50 01             	lea    0x1(%eax),%edx
 42f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 432:	89 c2                	mov    %eax,%edx
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	01 c2                	add    %eax,%edx
 439:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 43d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 43f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 443:	3c 0a                	cmp    $0xa,%al
 445:	74 16                	je     45d <gets+0x63>
 447:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 44b:	3c 0d                	cmp    $0xd,%al
 44d:	74 0e                	je     45d <gets+0x63>
  for(i=0; i+1 < max; ){
 44f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 452:	83 c0 01             	add    $0x1,%eax
 455:	39 45 0c             	cmp    %eax,0xc(%ebp)
 458:	7f b3                	jg     40d <gets+0x13>
 45a:	eb 01                	jmp    45d <gets+0x63>
      break;
 45c:	90                   	nop
      break;
  }
  buf[i] = '\0';
 45d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 460:	8b 45 08             	mov    0x8(%ebp),%eax
 463:	01 d0                	add    %edx,%eax
 465:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 468:	8b 45 08             	mov    0x8(%ebp),%eax
}
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <stat>:

int
stat(char *n, struct stat *st)
{
 46d:	f3 0f 1e fb          	endbr32 
 471:	55                   	push   %ebp
 472:	89 e5                	mov    %esp,%ebp
 474:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 477:	83 ec 08             	sub    $0x8,%esp
 47a:	6a 00                	push   $0x0
 47c:	ff 75 08             	pushl  0x8(%ebp)
 47f:	e8 14 01 00 00       	call   598 <open>
 484:	83 c4 10             	add    $0x10,%esp
 487:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 48a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 48e:	79 07                	jns    497 <stat+0x2a>
    return -1;
 490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 495:	eb 25                	jmp    4bc <stat+0x4f>
  r = fstat(fd, st);
 497:	83 ec 08             	sub    $0x8,%esp
 49a:	ff 75 0c             	pushl  0xc(%ebp)
 49d:	ff 75 f4             	pushl  -0xc(%ebp)
 4a0:	e8 0b 01 00 00       	call   5b0 <fstat>
 4a5:	83 c4 10             	add    $0x10,%esp
 4a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4ab:	83 ec 0c             	sub    $0xc,%esp
 4ae:	ff 75 f4             	pushl  -0xc(%ebp)
 4b1:	e8 ca 00 00 00       	call   580 <close>
 4b6:	83 c4 10             	add    $0x10,%esp
  return r;
 4b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4bc:	c9                   	leave  
 4bd:	c3                   	ret    

000004be <atoi>:

int
atoi(const char *s)
{
 4be:	f3 0f 1e fb          	endbr32 
 4c2:	55                   	push   %ebp
 4c3:	89 e5                	mov    %esp,%ebp
 4c5:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4cf:	eb 25                	jmp    4f6 <atoi+0x38>
    n = n*10 + *s++ - '0';
 4d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4d4:	89 d0                	mov    %edx,%eax
 4d6:	c1 e0 02             	shl    $0x2,%eax
 4d9:	01 d0                	add    %edx,%eax
 4db:	01 c0                	add    %eax,%eax
 4dd:	89 c1                	mov    %eax,%ecx
 4df:	8b 45 08             	mov    0x8(%ebp),%eax
 4e2:	8d 50 01             	lea    0x1(%eax),%edx
 4e5:	89 55 08             	mov    %edx,0x8(%ebp)
 4e8:	0f b6 00             	movzbl (%eax),%eax
 4eb:	0f be c0             	movsbl %al,%eax
 4ee:	01 c8                	add    %ecx,%eax
 4f0:	83 e8 30             	sub    $0x30,%eax
 4f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	0f b6 00             	movzbl (%eax),%eax
 4fc:	3c 2f                	cmp    $0x2f,%al
 4fe:	7e 0a                	jle    50a <atoi+0x4c>
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	0f b6 00             	movzbl (%eax),%eax
 506:	3c 39                	cmp    $0x39,%al
 508:	7e c7                	jle    4d1 <atoi+0x13>
  return n;
 50a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 50d:	c9                   	leave  
 50e:	c3                   	ret    

0000050f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 50f:	f3 0f 1e fb          	endbr32 
 513:	55                   	push   %ebp
 514:	89 e5                	mov    %esp,%ebp
 516:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 51f:	8b 45 0c             	mov    0xc(%ebp),%eax
 522:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 525:	eb 17                	jmp    53e <memmove+0x2f>
    *dst++ = *src++;
 527:	8b 55 f8             	mov    -0x8(%ebp),%edx
 52a:	8d 42 01             	lea    0x1(%edx),%eax
 52d:	89 45 f8             	mov    %eax,-0x8(%ebp)
 530:	8b 45 fc             	mov    -0x4(%ebp),%eax
 533:	8d 48 01             	lea    0x1(%eax),%ecx
 536:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 539:	0f b6 12             	movzbl (%edx),%edx
 53c:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 53e:	8b 45 10             	mov    0x10(%ebp),%eax
 541:	8d 50 ff             	lea    -0x1(%eax),%edx
 544:	89 55 10             	mov    %edx,0x10(%ebp)
 547:	85 c0                	test   %eax,%eax
 549:	7f dc                	jg     527 <memmove+0x18>
  return vdst;
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 54e:	c9                   	leave  
 54f:	c3                   	ret    

00000550 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 550:	b8 01 00 00 00       	mov    $0x1,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <exit>:
SYSCALL(exit)
 558:	b8 02 00 00 00       	mov    $0x2,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <wait>:
SYSCALL(wait)
 560:	b8 03 00 00 00       	mov    $0x3,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <pipe>:
SYSCALL(pipe)
 568:	b8 04 00 00 00       	mov    $0x4,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <read>:
SYSCALL(read)
 570:	b8 05 00 00 00       	mov    $0x5,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <write>:
SYSCALL(write)
 578:	b8 10 00 00 00       	mov    $0x10,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <close>:
SYSCALL(close)
 580:	b8 15 00 00 00       	mov    $0x15,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <kill>:
SYSCALL(kill)
 588:	b8 06 00 00 00       	mov    $0x6,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <exec>:
SYSCALL(exec)
 590:	b8 07 00 00 00       	mov    $0x7,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <open>:
SYSCALL(open)
 598:	b8 0f 00 00 00       	mov    $0xf,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <mknod>:
SYSCALL(mknod)
 5a0:	b8 11 00 00 00       	mov    $0x11,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <unlink>:
SYSCALL(unlink)
 5a8:	b8 12 00 00 00       	mov    $0x12,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <fstat>:
SYSCALL(fstat)
 5b0:	b8 08 00 00 00       	mov    $0x8,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <link>:
SYSCALL(link)
 5b8:	b8 13 00 00 00       	mov    $0x13,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <mkdir>:
SYSCALL(mkdir)
 5c0:	b8 14 00 00 00       	mov    $0x14,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <chdir>:
SYSCALL(chdir)
 5c8:	b8 09 00 00 00       	mov    $0x9,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <dup>:
SYSCALL(dup)
 5d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <getpid>:
SYSCALL(getpid)
 5d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <sbrk>:
SYSCALL(sbrk)
 5e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <sleep>:
SYSCALL(sleep)
 5e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <uptime>:
SYSCALL(uptime)
 5f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <uthread_init>:
SYSCALL(uthread_init)
 5f8:	b8 16 00 00 00       	mov    $0x16,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 600:	f3 0f 1e fb          	endbr32 
 604:	55                   	push   %ebp
 605:	89 e5                	mov    %esp,%ebp
 607:	83 ec 18             	sub    $0x18,%esp
 60a:	8b 45 0c             	mov    0xc(%ebp),%eax
 60d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 610:	83 ec 04             	sub    $0x4,%esp
 613:	6a 01                	push   $0x1
 615:	8d 45 f4             	lea    -0xc(%ebp),%eax
 618:	50                   	push   %eax
 619:	ff 75 08             	pushl  0x8(%ebp)
 61c:	e8 57 ff ff ff       	call   578 <write>
 621:	83 c4 10             	add    $0x10,%esp
}
 624:	90                   	nop
 625:	c9                   	leave  
 626:	c3                   	ret    

00000627 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 627:	f3 0f 1e fb          	endbr32 
 62b:	55                   	push   %ebp
 62c:	89 e5                	mov    %esp,%ebp
 62e:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 631:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 638:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 63c:	74 17                	je     655 <printint+0x2e>
 63e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 642:	79 11                	jns    655 <printint+0x2e>
    neg = 1;
 644:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 64b:	8b 45 0c             	mov    0xc(%ebp),%eax
 64e:	f7 d8                	neg    %eax
 650:	89 45 ec             	mov    %eax,-0x14(%ebp)
 653:	eb 06                	jmp    65b <printint+0x34>
  } else {
    x = xx;
 655:	8b 45 0c             	mov    0xc(%ebp),%eax
 658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 65b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 662:	8b 4d 10             	mov    0x10(%ebp),%ecx
 665:	8b 45 ec             	mov    -0x14(%ebp),%eax
 668:	ba 00 00 00 00       	mov    $0x0,%edx
 66d:	f7 f1                	div    %ecx
 66f:	89 d1                	mov    %edx,%ecx
 671:	8b 45 f4             	mov    -0xc(%ebp),%eax
 674:	8d 50 01             	lea    0x1(%eax),%edx
 677:	89 55 f4             	mov    %edx,-0xc(%ebp)
 67a:	0f b6 91 4c 0e 00 00 	movzbl 0xe4c(%ecx),%edx
 681:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 685:	8b 4d 10             	mov    0x10(%ebp),%ecx
 688:	8b 45 ec             	mov    -0x14(%ebp),%eax
 68b:	ba 00 00 00 00       	mov    $0x0,%edx
 690:	f7 f1                	div    %ecx
 692:	89 45 ec             	mov    %eax,-0x14(%ebp)
 695:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 699:	75 c7                	jne    662 <printint+0x3b>
  if(neg)
 69b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 69f:	74 2d                	je     6ce <printint+0xa7>
    buf[i++] = '-';
 6a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a4:	8d 50 01             	lea    0x1(%eax),%edx
 6a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6aa:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6af:	eb 1d                	jmp    6ce <printint+0xa7>
    putc(fd, buf[i]);
 6b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b7:	01 d0                	add    %edx,%eax
 6b9:	0f b6 00             	movzbl (%eax),%eax
 6bc:	0f be c0             	movsbl %al,%eax
 6bf:	83 ec 08             	sub    $0x8,%esp
 6c2:	50                   	push   %eax
 6c3:	ff 75 08             	pushl  0x8(%ebp)
 6c6:	e8 35 ff ff ff       	call   600 <putc>
 6cb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d6:	79 d9                	jns    6b1 <printint+0x8a>
}
 6d8:	90                   	nop
 6d9:	90                   	nop
 6da:	c9                   	leave  
 6db:	c3                   	ret    

000006dc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6dc:	f3 0f 1e fb          	endbr32 
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6e6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6ed:	8d 45 0c             	lea    0xc(%ebp),%eax
 6f0:	83 c0 04             	add    $0x4,%eax
 6f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6fd:	e9 59 01 00 00       	jmp    85b <printf+0x17f>
    c = fmt[i] & 0xff;
 702:	8b 55 0c             	mov    0xc(%ebp),%edx
 705:	8b 45 f0             	mov    -0x10(%ebp),%eax
 708:	01 d0                	add    %edx,%eax
 70a:	0f b6 00             	movzbl (%eax),%eax
 70d:	0f be c0             	movsbl %al,%eax
 710:	25 ff 00 00 00       	and    $0xff,%eax
 715:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 718:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 71c:	75 2c                	jne    74a <printf+0x6e>
      if(c == '%'){
 71e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 722:	75 0c                	jne    730 <printf+0x54>
        state = '%';
 724:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 72b:	e9 27 01 00 00       	jmp    857 <printf+0x17b>
      } else {
        putc(fd, c);
 730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 733:	0f be c0             	movsbl %al,%eax
 736:	83 ec 08             	sub    $0x8,%esp
 739:	50                   	push   %eax
 73a:	ff 75 08             	pushl  0x8(%ebp)
 73d:	e8 be fe ff ff       	call   600 <putc>
 742:	83 c4 10             	add    $0x10,%esp
 745:	e9 0d 01 00 00       	jmp    857 <printf+0x17b>
      }
    } else if(state == '%'){
 74a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 74e:	0f 85 03 01 00 00    	jne    857 <printf+0x17b>
      if(c == 'd'){
 754:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 758:	75 1e                	jne    778 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 75a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75d:	8b 00                	mov    (%eax),%eax
 75f:	6a 01                	push   $0x1
 761:	6a 0a                	push   $0xa
 763:	50                   	push   %eax
 764:	ff 75 08             	pushl  0x8(%ebp)
 767:	e8 bb fe ff ff       	call   627 <printint>
 76c:	83 c4 10             	add    $0x10,%esp
        ap++;
 76f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 773:	e9 d8 00 00 00       	jmp    850 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 778:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 77c:	74 06                	je     784 <printf+0xa8>
 77e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 782:	75 1e                	jne    7a2 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 784:	8b 45 e8             	mov    -0x18(%ebp),%eax
 787:	8b 00                	mov    (%eax),%eax
 789:	6a 00                	push   $0x0
 78b:	6a 10                	push   $0x10
 78d:	50                   	push   %eax
 78e:	ff 75 08             	pushl  0x8(%ebp)
 791:	e8 91 fe ff ff       	call   627 <printint>
 796:	83 c4 10             	add    $0x10,%esp
        ap++;
 799:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 79d:	e9 ae 00 00 00       	jmp    850 <printf+0x174>
      } else if(c == 's'){
 7a2:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7a6:	75 43                	jne    7eb <printf+0x10f>
        s = (char*)*ap;
 7a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ab:	8b 00                	mov    (%eax),%eax
 7ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7b0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b8:	75 25                	jne    7df <printf+0x103>
          s = "(null)";
 7ba:	c7 45 f4 5c 0b 00 00 	movl   $0xb5c,-0xc(%ebp)
        while(*s != 0){
 7c1:	eb 1c                	jmp    7df <printf+0x103>
          putc(fd, *s);
 7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c6:	0f b6 00             	movzbl (%eax),%eax
 7c9:	0f be c0             	movsbl %al,%eax
 7cc:	83 ec 08             	sub    $0x8,%esp
 7cf:	50                   	push   %eax
 7d0:	ff 75 08             	pushl  0x8(%ebp)
 7d3:	e8 28 fe ff ff       	call   600 <putc>
 7d8:	83 c4 10             	add    $0x10,%esp
          s++;
 7db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e2:	0f b6 00             	movzbl (%eax),%eax
 7e5:	84 c0                	test   %al,%al
 7e7:	75 da                	jne    7c3 <printf+0xe7>
 7e9:	eb 65                	jmp    850 <printf+0x174>
        }
      } else if(c == 'c'){
 7eb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7ef:	75 1d                	jne    80e <printf+0x132>
        putc(fd, *ap);
 7f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	0f be c0             	movsbl %al,%eax
 7f9:	83 ec 08             	sub    $0x8,%esp
 7fc:	50                   	push   %eax
 7fd:	ff 75 08             	pushl  0x8(%ebp)
 800:	e8 fb fd ff ff       	call   600 <putc>
 805:	83 c4 10             	add    $0x10,%esp
        ap++;
 808:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 80c:	eb 42                	jmp    850 <printf+0x174>
      } else if(c == '%'){
 80e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 812:	75 17                	jne    82b <printf+0x14f>
        putc(fd, c);
 814:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 817:	0f be c0             	movsbl %al,%eax
 81a:	83 ec 08             	sub    $0x8,%esp
 81d:	50                   	push   %eax
 81e:	ff 75 08             	pushl  0x8(%ebp)
 821:	e8 da fd ff ff       	call   600 <putc>
 826:	83 c4 10             	add    $0x10,%esp
 829:	eb 25                	jmp    850 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 82b:	83 ec 08             	sub    $0x8,%esp
 82e:	6a 25                	push   $0x25
 830:	ff 75 08             	pushl  0x8(%ebp)
 833:	e8 c8 fd ff ff       	call   600 <putc>
 838:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 83b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83e:	0f be c0             	movsbl %al,%eax
 841:	83 ec 08             	sub    $0x8,%esp
 844:	50                   	push   %eax
 845:	ff 75 08             	pushl  0x8(%ebp)
 848:	e8 b3 fd ff ff       	call   600 <putc>
 84d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 850:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 857:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 85b:	8b 55 0c             	mov    0xc(%ebp),%edx
 85e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 861:	01 d0                	add    %edx,%eax
 863:	0f b6 00             	movzbl (%eax),%eax
 866:	84 c0                	test   %al,%al
 868:	0f 85 94 fe ff ff    	jne    702 <printf+0x26>
    }
  }
}
 86e:	90                   	nop
 86f:	90                   	nop
 870:	c9                   	leave  
 871:	c3                   	ret    

00000872 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 872:	f3 0f 1e fb          	endbr32 
 876:	55                   	push   %ebp
 877:	89 e5                	mov    %esp,%ebp
 879:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87c:	8b 45 08             	mov    0x8(%ebp),%eax
 87f:	83 e8 08             	sub    $0x8,%eax
 882:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 885:	a1 88 8e 00 00       	mov    0x8e88,%eax
 88a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 88d:	eb 24                	jmp    8b3 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 00                	mov    (%eax),%eax
 894:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 897:	72 12                	jb     8ab <free+0x39>
 899:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 89f:	77 24                	ja     8c5 <free+0x53>
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8a9:	72 1a                	jb     8c5 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	8b 00                	mov    (%eax),%eax
 8b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8b9:	76 d4                	jbe    88f <free+0x1d>
 8bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8be:	8b 00                	mov    (%eax),%eax
 8c0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c3:	73 ca                	jae    88f <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c8:	8b 40 04             	mov    0x4(%eax),%eax
 8cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d5:	01 c2                	add    %eax,%edx
 8d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8da:	8b 00                	mov    (%eax),%eax
 8dc:	39 c2                	cmp    %eax,%edx
 8de:	75 24                	jne    904 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 8e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e3:	8b 50 04             	mov    0x4(%eax),%edx
 8e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e9:	8b 00                	mov    (%eax),%eax
 8eb:	8b 40 04             	mov    0x4(%eax),%eax
 8ee:	01 c2                	add    %eax,%edx
 8f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f9:	8b 00                	mov    (%eax),%eax
 8fb:	8b 10                	mov    (%eax),%edx
 8fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 900:	89 10                	mov    %edx,(%eax)
 902:	eb 0a                	jmp    90e <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 904:	8b 45 fc             	mov    -0x4(%ebp),%eax
 907:	8b 10                	mov    (%eax),%edx
 909:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 90e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 911:	8b 40 04             	mov    0x4(%eax),%eax
 914:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	01 d0                	add    %edx,%eax
 920:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 923:	75 20                	jne    945 <free+0xd3>
    p->s.size += bp->s.size;
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 50 04             	mov    0x4(%eax),%edx
 92b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92e:	8b 40 04             	mov    0x4(%eax),%eax
 931:	01 c2                	add    %eax,%edx
 933:	8b 45 fc             	mov    -0x4(%ebp),%eax
 936:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 939:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93c:	8b 10                	mov    (%eax),%edx
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	89 10                	mov    %edx,(%eax)
 943:	eb 08                	jmp    94d <free+0xdb>
  } else
    p->s.ptr = bp;
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 55 f8             	mov    -0x8(%ebp),%edx
 94b:	89 10                	mov    %edx,(%eax)
  freep = p;
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	a3 88 8e 00 00       	mov    %eax,0x8e88
}
 955:	90                   	nop
 956:	c9                   	leave  
 957:	c3                   	ret    

00000958 <morecore>:

static Header*
morecore(uint nu)
{
 958:	f3 0f 1e fb          	endbr32 
 95c:	55                   	push   %ebp
 95d:	89 e5                	mov    %esp,%ebp
 95f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 962:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 969:	77 07                	ja     972 <morecore+0x1a>
    nu = 4096;
 96b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 972:	8b 45 08             	mov    0x8(%ebp),%eax
 975:	c1 e0 03             	shl    $0x3,%eax
 978:	83 ec 0c             	sub    $0xc,%esp
 97b:	50                   	push   %eax
 97c:	e8 5f fc ff ff       	call   5e0 <sbrk>
 981:	83 c4 10             	add    $0x10,%esp
 984:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 987:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 98b:	75 07                	jne    994 <morecore+0x3c>
    return 0;
 98d:	b8 00 00 00 00       	mov    $0x0,%eax
 992:	eb 26                	jmp    9ba <morecore+0x62>
  hp = (Header*)p;
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 99a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99d:	8b 55 08             	mov    0x8(%ebp),%edx
 9a0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a6:	83 c0 08             	add    $0x8,%eax
 9a9:	83 ec 0c             	sub    $0xc,%esp
 9ac:	50                   	push   %eax
 9ad:	e8 c0 fe ff ff       	call   872 <free>
 9b2:	83 c4 10             	add    $0x10,%esp
  return freep;
 9b5:	a1 88 8e 00 00       	mov    0x8e88,%eax
}
 9ba:	c9                   	leave  
 9bb:	c3                   	ret    

000009bc <malloc>:

void*
malloc(uint nbytes)
{
 9bc:	f3 0f 1e fb          	endbr32 
 9c0:	55                   	push   %ebp
 9c1:	89 e5                	mov    %esp,%ebp
 9c3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c6:	8b 45 08             	mov    0x8(%ebp),%eax
 9c9:	83 c0 07             	add    $0x7,%eax
 9cc:	c1 e8 03             	shr    $0x3,%eax
 9cf:	83 c0 01             	add    $0x1,%eax
 9d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9d5:	a1 88 8e 00 00       	mov    0x8e88,%eax
 9da:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9e1:	75 23                	jne    a06 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 9e3:	c7 45 f0 80 8e 00 00 	movl   $0x8e80,-0x10(%ebp)
 9ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ed:	a3 88 8e 00 00       	mov    %eax,0x8e88
 9f2:	a1 88 8e 00 00       	mov    0x8e88,%eax
 9f7:	a3 80 8e 00 00       	mov    %eax,0x8e80
    base.s.size = 0;
 9fc:	c7 05 84 8e 00 00 00 	movl   $0x0,0x8e84
 a03:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a09:	8b 00                	mov    (%eax),%eax
 a0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	8b 40 04             	mov    0x4(%eax),%eax
 a14:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a17:	77 4d                	ja     a66 <malloc+0xaa>
      if(p->s.size == nunits)
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	8b 40 04             	mov    0x4(%eax),%eax
 a1f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a22:	75 0c                	jne    a30 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 10                	mov    (%eax),%edx
 a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2c:	89 10                	mov    %edx,(%eax)
 a2e:	eb 26                	jmp    a56 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	8b 40 04             	mov    0x4(%eax),%eax
 a36:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a39:	89 c2                	mov    %eax,%edx
 a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a44:	8b 40 04             	mov    0x4(%eax),%eax
 a47:	c1 e0 03             	shl    $0x3,%eax
 a4a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a50:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a53:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a59:	a3 88 8e 00 00       	mov    %eax,0x8e88
      return (void*)(p + 1);
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	83 c0 08             	add    $0x8,%eax
 a64:	eb 3b                	jmp    aa1 <malloc+0xe5>
    }
    if(p == freep)
 a66:	a1 88 8e 00 00       	mov    0x8e88,%eax
 a6b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a6e:	75 1e                	jne    a8e <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a70:	83 ec 0c             	sub    $0xc,%esp
 a73:	ff 75 ec             	pushl  -0x14(%ebp)
 a76:	e8 dd fe ff ff       	call   958 <morecore>
 a7b:	83 c4 10             	add    $0x10,%esp
 a7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a85:	75 07                	jne    a8e <malloc+0xd2>
        return 0;
 a87:	b8 00 00 00 00       	mov    $0x0,%eax
 a8c:	eb 13                	jmp    aa1 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a91:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a97:	8b 00                	mov    (%eax),%eax
 a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a9c:	e9 6d ff ff ff       	jmp    a0e <malloc+0x52>
  }
}
 aa1:	c9                   	leave  
 aa2:	c3                   	ret    
