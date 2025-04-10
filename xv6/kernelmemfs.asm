
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 60 e3 18 80       	mov    $0x8018e360,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba ae 34 10 80       	mov    $0x801034ae,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	f3 0f 1e fb          	endbr32 
8010006a:	55                   	push   %ebp
8010006b:	89 e5                	mov    %esp,%ebp
8010006d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
80100070:	83 ec 08             	sub    $0x8,%esp
80100073:	68 c0 a4 10 80       	push   $0x8010a4c0
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 27 48 00 00       	call   801048a9 <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 ac 2a 19 80 5c 	movl   $0x80192a5c,0x80192aac
8010008c:	2a 19 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 b0 2a 19 80 5c 	movl   $0x80192a5c,0x80192ab0
80100096:	2a 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 94 e3 18 80 	movl   $0x8018e394,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 c7 a4 10 80       	push   $0x8010a4c7
801000c6:	50                   	push   %eax
801000c7:	e8 70 46 00 00       	call   8010473c <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 5c 2a 19 80       	mov    $0x80192a5c,%eax
801000ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000f1:	72 af                	jb     801000a2 <binit+0x3c>
  }
}
801000f3:	90                   	nop
801000f4:	90                   	nop
801000f5:	c9                   	leave  
801000f6:	c3                   	ret    

801000f7 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f7:	f3 0f 1e fb          	endbr32 
801000fb:	55                   	push   %ebp
801000fc:	89 e5                	mov    %esp,%ebp
801000fe:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
80100101:	83 ec 0c             	sub    $0xc,%esp
80100104:	68 60 e3 18 80       	push   $0x8018e360
80100109:	e8 c1 47 00 00       	call   801048cf <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100116:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100119:	eb 58                	jmp    80100173 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
8010011b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011e:	8b 40 04             	mov    0x4(%eax),%eax
80100121:	39 45 08             	cmp    %eax,0x8(%ebp)
80100124:	75 44                	jne    8010016a <bget+0x73>
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 08             	mov    0x8(%eax),%eax
8010012c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010012f:	75 39                	jne    8010016a <bget+0x73>
      b->refcnt++;
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 4c             	mov    0x4c(%eax),%eax
80100137:	8d 50 01             	lea    0x1(%eax),%edx
8010013a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013d:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100140:	83 ec 0c             	sub    $0xc,%esp
80100143:	68 60 e3 18 80       	push   $0x8018e360
80100148:	e8 f4 47 00 00       	call   80104941 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 1d 46 00 00       	call   8010477c <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 ac 2a 19 80       	mov    0x80192aac,%eax
80100181:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100184:	eb 6b                	jmp    801001f1 <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 4c             	mov    0x4c(%eax),%eax
8010018c:	85 c0                	test   %eax,%eax
8010018e:	75 58                	jne    801001e8 <bget+0xf1>
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	8b 00                	mov    (%eax),%eax
80100195:	83 e0 04             	and    $0x4,%eax
80100198:	85 c0                	test   %eax,%eax
8010019a:	75 4c                	jne    801001e8 <bget+0xf1>
      b->dev = dev;
8010019c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019f:	8b 55 08             	mov    0x8(%ebp),%edx
801001a2:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
801001a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801001ab:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ba:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001c1:	83 ec 0c             	sub    $0xc,%esp
801001c4:	68 60 e3 18 80       	push   $0x8018e360
801001c9:	e8 73 47 00 00       	call   80104941 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 9c 45 00 00       	call   8010477c <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 ce a4 10 80       	push   $0x8010a4ce
80100202:	e8 be 03 00 00       	call   801005c5 <panic>
}
80100207:	c9                   	leave  
80100208:	c3                   	ret    

80100209 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100209:	f3 0f 1e fb          	endbr32 
8010020d:	55                   	push   %ebp
8010020e:	89 e5                	mov    %esp,%ebp
80100210:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100213:	83 ec 08             	sub    $0x8,%esp
80100216:	ff 75 0c             	pushl  0xc(%ebp)
80100219:	ff 75 08             	pushl  0x8(%ebp)
8010021c:	e8 d6 fe ff ff       	call   801000f7 <bget>
80100221:	83 c4 10             	add    $0x10,%esp
80100224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
80100227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010022a:	8b 00                	mov    (%eax),%eax
8010022c:	83 e0 02             	and    $0x2,%eax
8010022f:	85 c0                	test   %eax,%eax
80100231:	75 0e                	jne    80100241 <bread+0x38>
    iderw(b);
80100233:	83 ec 0c             	sub    $0xc,%esp
80100236:	ff 75 f4             	pushl  -0xc(%ebp)
80100239:	e8 8e a1 00 00       	call   8010a3cc <iderw>
8010023e:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100241:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100244:	c9                   	leave  
80100245:	c3                   	ret    

80100246 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100246:	f3 0f 1e fb          	endbr32 
8010024a:	55                   	push   %ebp
8010024b:	89 e5                	mov    %esp,%ebp
8010024d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	50                   	push   %eax
8010025a:	e8 d7 45 00 00       	call   80104836 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 df a4 10 80       	push   $0x8010a4df
8010026e:	e8 52 03 00 00       	call   801005c5 <panic>
  b->flags |= B_DIRTY;
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	8b 00                	mov    (%eax),%eax
80100278:	83 c8 04             	or     $0x4,%eax
8010027b:	89 c2                	mov    %eax,%edx
8010027d:	8b 45 08             	mov    0x8(%ebp),%eax
80100280:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100282:	83 ec 0c             	sub    $0xc,%esp
80100285:	ff 75 08             	pushl  0x8(%ebp)
80100288:	e8 3f a1 00 00       	call   8010a3cc <iderw>
8010028d:	83 c4 10             	add    $0x10,%esp
}
80100290:	90                   	nop
80100291:	c9                   	leave  
80100292:	c3                   	ret    

80100293 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100293:	f3 0f 1e fb          	endbr32 
80100297:	55                   	push   %ebp
80100298:	89 e5                	mov    %esp,%ebp
8010029a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	83 c0 0c             	add    $0xc,%eax
801002a3:	83 ec 0c             	sub    $0xc,%esp
801002a6:	50                   	push   %eax
801002a7:	e8 8a 45 00 00       	call   80104836 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 e6 a4 10 80       	push   $0x8010a4e6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 15 45 00 00       	call   801047e4 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 f0 45 00 00       	call   801048cf <acquire>
801002df:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002e2:	8b 45 08             	mov    0x8(%ebp),%eax
801002e5:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801002eb:	8b 45 08             	mov    0x8(%ebp),%eax
801002ee:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002f1:	8b 45 08             	mov    0x8(%ebp),%eax
801002f4:	8b 40 4c             	mov    0x4c(%eax),%eax
801002f7:	85 c0                	test   %eax,%eax
801002f9:	75 47                	jne    80100342 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002fb:	8b 45 08             	mov    0x8(%ebp),%eax
801002fe:	8b 40 54             	mov    0x54(%eax),%eax
80100301:	8b 55 08             	mov    0x8(%ebp),%edx
80100304:	8b 52 50             	mov    0x50(%edx),%edx
80100307:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	8b 40 50             	mov    0x50(%eax),%eax
80100310:	8b 55 08             	mov    0x8(%ebp),%edx
80100313:	8b 52 54             	mov    0x54(%edx),%edx
80100316:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100319:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 60 e3 18 80       	push   $0x8018e360
8010034a:	e8 f2 45 00 00       	call   80104941 <release>
8010034f:	83 c4 10             	add    $0x10,%esp
}
80100352:	90                   	nop
80100353:	c9                   	leave  
80100354:	c3                   	ret    

80100355 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100355:	55                   	push   %ebp
80100356:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100358:	fa                   	cli    
}
80100359:	90                   	nop
8010035a:	5d                   	pop    %ebp
8010035b:	c3                   	ret    

8010035c <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010035c:	f3 0f 1e fb          	endbr32 
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036a:	74 1c                	je     80100388 <printint+0x2c>
8010036c:	8b 45 08             	mov    0x8(%ebp),%eax
8010036f:	c1 e8 1f             	shr    $0x1f,%eax
80100372:	0f b6 c0             	movzbl %al,%eax
80100375:	89 45 10             	mov    %eax,0x10(%ebp)
80100378:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010037c:	74 0a                	je     80100388 <printint+0x2c>
    x = -xx;
8010037e:	8b 45 08             	mov    0x8(%ebp),%eax
80100381:	f7 d8                	neg    %eax
80100383:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100386:	eb 06                	jmp    8010038e <printint+0x32>
  else
    x = xx;
80100388:	8b 45 08             	mov    0x8(%ebp),%eax
8010038b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010038e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010039b:	ba 00 00 00 00       	mov    $0x0,%edx
801003a0:	f7 f1                	div    %ecx
801003a2:	89 d1                	mov    %edx,%ecx
801003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a7:	8d 50 01             	lea    0x1(%eax),%edx
801003aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003ad:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
801003b4:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003be:	ba 00 00 00 00       	mov    $0x0,%edx
801003c3:	f7 f1                	div    %ecx
801003c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003cc:	75 c7                	jne    80100395 <printint+0x39>

  if(sign)
801003ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003d2:	74 2a                	je     801003fe <printint+0xa2>
    buf[i++] = '-';
801003d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d7:	8d 50 01             	lea    0x1(%eax),%edx
801003da:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003dd:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003e2:	eb 1a                	jmp    801003fe <printint+0xa2>
    consputc(buf[i]);
801003e4:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003ea:	01 d0                	add    %edx,%eax
801003ec:	0f b6 00             	movzbl (%eax),%eax
801003ef:	0f be c0             	movsbl %al,%eax
801003f2:	83 ec 0c             	sub    $0xc,%esp
801003f5:	50                   	push   %eax
801003f6:	e8 9a 03 00 00       	call   80100795 <consputc>
801003fb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003fe:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100402:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100406:	79 dc                	jns    801003e4 <printint+0x88>
}
80100408:	90                   	nop
80100409:	90                   	nop
8010040a:	c9                   	leave  
8010040b:	c3                   	ret    

8010040c <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
8010040c:	f3 0f 1e fb          	endbr32 
80100410:	55                   	push   %ebp
80100411:	89 e5                	mov    %esp,%ebp
80100413:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100416:	a1 54 d0 18 80       	mov    0x8018d054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 d0 18 80       	push   $0x8018d020
8010042c:	e8 9e 44 00 00       	call   801048cf <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 ed a4 10 80       	push   $0x8010a4ed
80100443:	e8 7d 01 00 00       	call   801005c5 <panic>


  argp = (uint*)(void*)(&fmt + 1);
80100448:	8d 45 0c             	lea    0xc(%ebp),%eax
8010044b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010044e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100455:	e9 2f 01 00 00       	jmp    80100589 <cprintf+0x17d>
    if(c != '%'){
8010045a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010045e:	74 13                	je     80100473 <cprintf+0x67>
      consputc(c);
80100460:	83 ec 0c             	sub    $0xc,%esp
80100463:	ff 75 e4             	pushl  -0x1c(%ebp)
80100466:	e8 2a 03 00 00       	call   80100795 <consputc>
8010046b:	83 c4 10             	add    $0x10,%esp
      continue;
8010046e:	e9 12 01 00 00       	jmp    80100585 <cprintf+0x179>
    }
    c = fmt[++i] & 0xff;
80100473:	8b 55 08             	mov    0x8(%ebp),%edx
80100476:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010047a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010047d:	01 d0                	add    %edx,%eax
8010047f:	0f b6 00             	movzbl (%eax),%eax
80100482:	0f be c0             	movsbl %al,%eax
80100485:	25 ff 00 00 00       	and    $0xff,%eax
8010048a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010048d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100491:	0f 84 14 01 00 00    	je     801005ab <cprintf+0x19f>
      break;
    switch(c){
80100497:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010049b:	74 5e                	je     801004fb <cprintf+0xef>
8010049d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004a1:	0f 8f c2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004a7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004ab:	74 6b                	je     80100518 <cprintf+0x10c>
801004ad:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004b1:	0f 8f b2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004bb:	74 3e                	je     801004fb <cprintf+0xef>
801004bd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004c1:	0f 8f a2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004cb:	0f 84 89 00 00 00    	je     8010055a <cprintf+0x14e>
801004d1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004d5:	0f 85 8e 00 00 00    	jne    80100569 <cprintf+0x15d>
    case 'd':
      printint(*argp++, 10, 1);
801004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004de:	8d 50 04             	lea    0x4(%eax),%edx
801004e1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e4:	8b 00                	mov    (%eax),%eax
801004e6:	83 ec 04             	sub    $0x4,%esp
801004e9:	6a 01                	push   $0x1
801004eb:	6a 0a                	push   $0xa
801004ed:	50                   	push   %eax
801004ee:	e8 69 fe ff ff       	call   8010035c <printint>
801004f3:	83 c4 10             	add    $0x10,%esp
      break;
801004f6:	e9 8a 00 00 00       	jmp    80100585 <cprintf+0x179>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fe:	8d 50 04             	lea    0x4(%eax),%edx
80100501:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100504:	8b 00                	mov    (%eax),%eax
80100506:	83 ec 04             	sub    $0x4,%esp
80100509:	6a 00                	push   $0x0
8010050b:	6a 10                	push   $0x10
8010050d:	50                   	push   %eax
8010050e:	e8 49 fe ff ff       	call   8010035c <printint>
80100513:	83 c4 10             	add    $0x10,%esp
      break;
80100516:	eb 6d                	jmp    80100585 <cprintf+0x179>
    case 's':
      if((s = (char*)*argp++) == 0)
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010052a:	75 22                	jne    8010054e <cprintf+0x142>
        s = "(null)";
8010052c:	c7 45 ec f6 a4 10 80 	movl   $0x8010a4f6,-0x14(%ebp)
      for(; *s; s++)
80100533:	eb 19                	jmp    8010054e <cprintf+0x142>
        consputc(*s);
80100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100538:	0f b6 00             	movzbl (%eax),%eax
8010053b:	0f be c0             	movsbl %al,%eax
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	50                   	push   %eax
80100542:	e8 4e 02 00 00       	call   80100795 <consputc>
80100547:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010054a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100551:	0f b6 00             	movzbl (%eax),%eax
80100554:	84 c0                	test   %al,%al
80100556:	75 dd                	jne    80100535 <cprintf+0x129>
      break;
80100558:	eb 2b                	jmp    80100585 <cprintf+0x179>
    case '%':
      consputc('%');
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	6a 25                	push   $0x25
8010055f:	e8 31 02 00 00       	call   80100795 <consputc>
80100564:	83 c4 10             	add    $0x10,%esp
      break;
80100567:	eb 1c                	jmp    80100585 <cprintf+0x179>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100569:	83 ec 0c             	sub    $0xc,%esp
8010056c:	6a 25                	push   $0x25
8010056e:	e8 22 02 00 00       	call   80100795 <consputc>
80100573:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	ff 75 e4             	pushl  -0x1c(%ebp)
8010057c:	e8 14 02 00 00       	call   80100795 <consputc>
80100581:	83 c4 10             	add    $0x10,%esp
      break;
80100584:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100589:	8b 55 08             	mov    0x8(%ebp),%edx
8010058c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058f:	01 d0                	add    %edx,%eax
80100591:	0f b6 00             	movzbl (%eax),%eax
80100594:	0f be c0             	movsbl %al,%eax
80100597:	25 ff 00 00 00       	and    $0xff,%eax
8010059c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005a3:	0f 85 b1 fe ff ff    	jne    8010045a <cprintf+0x4e>
801005a9:	eb 01                	jmp    801005ac <cprintf+0x1a0>
      break;
801005ab:	90                   	nop
    }
  }

  if(locking)
801005ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005b0:	74 10                	je     801005c2 <cprintf+0x1b6>
    release(&cons.lock);
801005b2:	83 ec 0c             	sub    $0xc,%esp
801005b5:	68 20 d0 18 80       	push   $0x8018d020
801005ba:	e8 82 43 00 00       	call   80104941 <release>
801005bf:	83 c4 10             	add    $0x10,%esp
}
801005c2:	90                   	nop
801005c3:	c9                   	leave  
801005c4:	c3                   	ret    

801005c5 <panic>:

void
panic(char *s)
{
801005c5:	f3 0f 1e fb          	endbr32 
801005c9:	55                   	push   %ebp
801005ca:	89 e5                	mov    %esp,%ebp
801005cc:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005cf:	e8 81 fd ff ff       	call   80100355 <cli>
  cons.locking = 0;
801005d4:	c7 05 54 d0 18 80 00 	movl   $0x0,0x8018d054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 1c 26 00 00       	call   80102bff <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 fd a4 10 80       	push   $0x8010a4fd
801005ec:	e8 1b fe ff ff       	call   8010040c <cprintf>
801005f1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005f4:	8b 45 08             	mov    0x8(%ebp),%eax
801005f7:	83 ec 0c             	sub    $0xc,%esp
801005fa:	50                   	push   %eax
801005fb:	e8 0c fe ff ff       	call   8010040c <cprintf>
80100600:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100603:	83 ec 0c             	sub    $0xc,%esp
80100606:	68 11 a5 10 80       	push   $0x8010a511
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 74 43 00 00       	call   80104997 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 13 a5 10 80       	push   $0x8010a513
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 d0 18 80 01 	movl   $0x1,0x8018d000
80100658:	00 00 00 
  for(;;)
8010065b:	eb fe                	jmp    8010065b <panic+0x96>

8010065d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010065d:	f3 0f 1e fb          	endbr32 
80100661:	55                   	push   %ebp
80100662:	89 e5                	mov    %esp,%ebp
80100664:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100667:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010066b:	75 64                	jne    801006d1 <graphic_putc+0x74>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010066d:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100673:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	f7 ea                	imul   %edx
8010067c:	c1 fa 04             	sar    $0x4,%edx
8010067f:	89 c8                	mov    %ecx,%eax
80100681:	c1 f8 1f             	sar    $0x1f,%eax
80100684:	29 c2                	sub    %eax,%edx
80100686:	89 d0                	mov    %edx,%eax
80100688:	6b c0 35             	imul   $0x35,%eax,%eax
8010068b:	29 c1                	sub    %eax,%ecx
8010068d:	89 c8                	mov    %ecx,%eax
8010068f:	ba 35 00 00 00       	mov    $0x35,%edx
80100694:	29 c2                	sub    %eax,%edx
80100696:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006a2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006a7:	3d 23 04 00 00       	cmp    $0x423,%eax
801006ac:	0f 8e e0 00 00 00    	jle    80100792 <graphic_putc+0x135>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006b2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006b7:	83 e8 35             	sub    $0x35,%eax
801006ba:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006bf:	83 ec 0c             	sub    $0xc,%esp
801006c2:	6a 1e                	push   $0x1e
801006c4:	e8 97 7b 00 00       	call   80108260 <graphic_scroll_up>
801006c9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006cc:	e9 c1 00 00 00       	jmp    80100792 <graphic_putc+0x135>
  }else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 1f                	jne    801006f9 <graphic_putc+0x9c>
    if(console_pos>0) --console_pos;
801006da:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006df:	85 c0                	test   %eax,%eax
801006e1:	0f 8e ab 00 00 00    	jle    80100792 <graphic_putc+0x135>
801006e7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ec:	83 e8 01             	sub    $0x1,%eax
801006ef:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006f4:	e9 99 00 00 00       	jmp    80100792 <graphic_putc+0x135>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006f9:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006fe:	3d 23 04 00 00       	cmp    $0x423,%eax
80100703:	7e 1a                	jle    8010071f <graphic_putc+0xc2>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
80100705:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010070a:	83 e8 35             	sub    $0x35,%eax
8010070d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100712:	83 ec 0c             	sub    $0xc,%esp
80100715:	6a 1e                	push   $0x1e
80100717:	e8 44 7b 00 00       	call   80108260 <graphic_scroll_up>
8010071c:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8010071f:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100725:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010072a:	89 c8                	mov    %ecx,%eax
8010072c:	f7 ea                	imul   %edx
8010072e:	c1 fa 04             	sar    $0x4,%edx
80100731:	89 c8                	mov    %ecx,%eax
80100733:	c1 f8 1f             	sar    $0x1f,%eax
80100736:	29 c2                	sub    %eax,%edx
80100738:	89 d0                	mov    %edx,%eax
8010073a:	6b c0 35             	imul   $0x35,%eax,%eax
8010073d:	29 c1                	sub    %eax,%ecx
8010073f:	89 c8                	mov    %ecx,%eax
80100741:	89 c2                	mov    %eax,%edx
80100743:	c1 e2 04             	shl    $0x4,%edx
80100746:	29 c2                	sub    %eax,%edx
80100748:	89 d0                	mov    %edx,%eax
8010074a:	83 c0 02             	add    $0x2,%eax
8010074d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100750:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100756:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010075b:	89 c8                	mov    %ecx,%eax
8010075d:	f7 ea                	imul   %edx
8010075f:	c1 fa 04             	sar    $0x4,%edx
80100762:	89 c8                	mov    %ecx,%eax
80100764:	c1 f8 1f             	sar    $0x1f,%eax
80100767:	29 c2                	sub    %eax,%edx
80100769:	89 d0                	mov    %edx,%eax
8010076b:	6b c0 1e             	imul   $0x1e,%eax,%eax
8010076e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100771:	83 ec 04             	sub    $0x4,%esp
80100774:	ff 75 08             	pushl  0x8(%ebp)
80100777:	ff 75 f0             	pushl  -0x10(%ebp)
8010077a:	ff 75 f4             	pushl  -0xc(%ebp)
8010077d:	e8 52 7b 00 00       	call   801082d4 <font_render>
80100782:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100785:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010078a:	83 c0 01             	add    $0x1,%eax
8010078d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100792:	90                   	nop
80100793:	c9                   	leave  
80100794:	c3                   	ret    

80100795 <consputc>:


void
consputc(int c)
{
80100795:	f3 0f 1e fb          	endbr32 
80100799:	55                   	push   %ebp
8010079a:	89 e5                	mov    %esp,%ebp
8010079c:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010079f:	a1 00 d0 18 80       	mov    0x8018d000,%eax
801007a4:	85 c0                	test   %eax,%eax
801007a6:	74 07                	je     801007af <consputc+0x1a>
    cli();
801007a8:	e8 a8 fb ff ff       	call   80100355 <cli>
    for(;;)
801007ad:	eb fe                	jmp    801007ad <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
801007af:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007b6:	75 29                	jne    801007e1 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b8:	83 ec 0c             	sub    $0xc,%esp
801007bb:	6a 08                	push   $0x8
801007bd:	e8 b2 5e 00 00       	call   80106674 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 a5 5e 00 00       	call   80106674 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 98 5e 00 00       	call   80106674 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 88 5e 00 00       	call   80106674 <uartputc>
801007ec:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007ef:	83 ec 0c             	sub    $0xc,%esp
801007f2:	ff 75 08             	pushl  0x8(%ebp)
801007f5:	e8 63 fe ff ff       	call   8010065d <graphic_putc>
801007fa:	83 c4 10             	add    $0x10,%esp
}
801007fd:	90                   	nop
801007fe:	c9                   	leave  
801007ff:	c3                   	ret    

80100800 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100800:	f3 0f 1e fb          	endbr32 
80100804:	55                   	push   %ebp
80100805:	89 e5                	mov    %esp,%ebp
80100807:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010080a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100811:	83 ec 0c             	sub    $0xc,%esp
80100814:	68 20 d0 18 80       	push   $0x8018d020
80100819:	e8 b1 40 00 00       	call   801048cf <acquire>
8010081e:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100821:	e9 52 01 00 00       	jmp    80100978 <consoleintr+0x178>
    switch(c){
80100826:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010082a:	0f 84 81 00 00 00    	je     801008b1 <consoleintr+0xb1>
80100830:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100834:	0f 8f ac 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010083a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010083e:	74 43                	je     80100883 <consoleintr+0x83>
80100840:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100844:	0f 8f 9c 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010084a:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
8010084e:	74 61                	je     801008b1 <consoleintr+0xb1>
80100850:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100854:	0f 85 8c 00 00 00    	jne    801008e6 <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010085a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100861:	e9 12 01 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100866:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
80100889:	a1 44 2d 19 80       	mov    0x80192d44,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008b7:	a1 44 2d 19 80       	mov    0x80192d44,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 48 2d 19 80       	mov    0x80192d48,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
801008d1:	83 ec 0c             	sub    $0xc,%esp
801008d4:	68 00 01 00 00       	push   $0x100
801008d9:	e8 b7 fe ff ff       	call   80100795 <consputc>
801008de:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008e1:	e9 92 00 00 00       	jmp    80100978 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008ea:	0f 84 87 00 00 00    	je     80100977 <consoleintr+0x177>
801008f0:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008f6:	a1 40 2d 19 80       	mov    0x80192d40,%eax
801008fb:	29 c2                	sub    %eax,%edx
801008fd:	89 d0                	mov    %edx,%eax
801008ff:	83 f8 7f             	cmp    $0x7f,%eax
80100902:	77 73                	ja     80100977 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
80100904:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100908:	74 05                	je     8010090f <consoleintr+0x10f>
8010090a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010090d:	eb 05                	jmp    80100914 <consoleintr+0x114>
8010090f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100914:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100917:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 48 2d 19 80    	mov    %edx,0x80192d48
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 c0 2c 19 80    	mov    %dl,-0x7fe6d340(%eax)
        consputc(c);
80100931:	83 ec 0c             	sub    $0xc,%esp
80100934:	ff 75 f0             	pushl  -0x10(%ebp)
80100937:	e8 59 fe ff ff       	call   80100795 <consputc>
8010093c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010093f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100943:	74 18                	je     8010095d <consoleintr+0x15d>
80100945:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100949:	74 12                	je     8010095d <consoleintr+0x15d>
8010094b:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100950:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100962:	a3 44 2d 19 80       	mov    %eax,0x80192d44
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 40 2d 19 80       	push   $0x80192d40
8010096f:	e8 07 3c 00 00       	call   8010457b <wakeup>
80100974:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100977:	90                   	nop
  while((c = getc()) >= 0){
80100978:	8b 45 08             	mov    0x8(%ebp),%eax
8010097b:	ff d0                	call   *%eax
8010097d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100984:	0f 89 9c fe ff ff    	jns    80100826 <consoleintr+0x26>
    }
  }
  release(&cons.lock);
8010098a:	83 ec 0c             	sub    $0xc,%esp
8010098d:	68 20 d0 18 80       	push   $0x8018d020
80100992:	e8 aa 3f 00 00       	call   80104941 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 99 3c 00 00       	call   8010463e <procdump>
  }
}
801009a5:	90                   	nop
801009a6:	c9                   	leave  
801009a7:	c3                   	ret    

801009a8 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009a8:	f3 0f 1e fb          	endbr32 
801009ac:	55                   	push   %ebp
801009ad:	89 e5                	mov    %esp,%ebp
801009af:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009b2:	83 ec 0c             	sub    $0xc,%esp
801009b5:	ff 75 08             	pushl  0x8(%ebp)
801009b8:	e8 d6 11 00 00       	call   80101b93 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 d0 18 80       	push   $0x8018d020
801009ce:	e8 fc 3e 00 00       	call   801048cf <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 c9 31 00 00       	call   80103ba9 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 d0 18 80       	push   $0x8018d020
801009ef:	e8 4d 3f 00 00       	call   80104941 <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	pushl  0x8(%ebp)
801009fd:	e8 7a 10 00 00       	call   80101a7c <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 d0 18 80       	push   $0x8018d020
80100a17:	68 40 2d 19 80       	push   $0x80192d40
80100a1c:	e8 6b 3a 00 00       	call   8010448c <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100a2a:	a1 44 2d 19 80       	mov    0x80192d44,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 40 2d 19 80    	mov    %edx,0x80192d40
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a51:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a55:	75 17                	jne    80100a6e <consoleread+0xc6>
      if(n < target){
80100a57:	8b 45 10             	mov    0x10(%ebp),%eax
80100a5a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a5d:	76 2f                	jbe    80100a8e <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a5f:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 40 2d 19 80       	mov    %eax,0x80192d40
      }
      break;
80100a6c:	eb 20                	jmp    80100a8e <consoleread+0xe6>
    }
    *dst++ = c;
80100a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a71:	8d 50 01             	lea    0x1(%eax),%edx
80100a74:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a7a:	88 10                	mov    %dl,(%eax)
    --n;
80100a7c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a80:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a84:	74 0b                	je     80100a91 <consoleread+0xe9>
  while(n > 0){
80100a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a8a:	7f 98                	jg     80100a24 <consoleread+0x7c>
80100a8c:	eb 04                	jmp    80100a92 <consoleread+0xea>
      break;
80100a8e:	90                   	nop
80100a8f:	eb 01                	jmp    80100a92 <consoleread+0xea>
      break;
80100a91:	90                   	nop
  }
  release(&cons.lock);
80100a92:	83 ec 0c             	sub    $0xc,%esp
80100a95:	68 20 d0 18 80       	push   $0x8018d020
80100a9a:	e8 a2 3e 00 00       	call   80104941 <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	pushl  0x8(%ebp)
80100aa8:	e8 cf 0f 00 00       	call   80101a7c <ilock>
80100aad:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ab0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	29 c2                	sub    %eax,%edx
80100ab8:	89 d0                	mov    %edx,%eax
}
80100aba:	c9                   	leave  
80100abb:	c3                   	ret    

80100abc <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100abc:	f3 0f 1e fb          	endbr32 
80100ac0:	55                   	push   %ebp
80100ac1:	89 e5                	mov    %esp,%ebp
80100ac3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	ff 75 08             	pushl  0x8(%ebp)
80100acc:	e8 c2 10 00 00       	call   80101b93 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 d0 18 80       	push   $0x8018d020
80100adc:	e8 ee 3d 00 00       	call   801048cf <acquire>
80100ae1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ae4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100aeb:	eb 21                	jmp    80100b0e <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af3:	01 d0                	add    %edx,%eax
80100af5:	0f b6 00             	movzbl (%eax),%eax
80100af8:	0f be c0             	movsbl %al,%eax
80100afb:	0f b6 c0             	movzbl %al,%eax
80100afe:	83 ec 0c             	sub    $0xc,%esp
80100b01:	50                   	push   %eax
80100b02:	e8 8e fc ff ff       	call   80100795 <consputc>
80100b07:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b11:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b14:	7c d7                	jl     80100aed <consolewrite+0x31>
  release(&cons.lock);
80100b16:	83 ec 0c             	sub    $0xc,%esp
80100b19:	68 20 d0 18 80       	push   $0x8018d020
80100b1e:	e8 1e 3e 00 00       	call   80104941 <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	pushl  0x8(%ebp)
80100b2c:	e8 4b 0f 00 00       	call   80101a7c <ilock>
80100b31:	83 c4 10             	add    $0x10,%esp

  return n;
80100b34:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b37:	c9                   	leave  
80100b38:	c3                   	ret    

80100b39 <consoleinit>:

void
consoleinit(void)
{
80100b39:	f3 0f 1e fb          	endbr32 
80100b3d:	55                   	push   %ebp
80100b3e:	89 e5                	mov    %esp,%ebp
80100b40:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b43:	c7 05 00 d0 18 80 00 	movl   $0x0,0x8018d000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 17 a5 10 80       	push   $0x8010a517
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 4a 3d 00 00       	call   801048a9 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 1f a5 10 80 	movl   $0x8010a51f,-0xc(%ebp)
80100b7d:	eb 19                	jmp    80100b98 <consoleinit+0x5f>
    graphic_putc(*p);
80100b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b82:	0f b6 00             	movzbl (%eax),%eax
80100b85:	0f be c0             	movsbl %al,%eax
80100b88:	83 ec 0c             	sub    $0xc,%esp
80100b8b:	50                   	push   %eax
80100b8c:	e8 cc fa ff ff       	call   8010065d <graphic_putc>
80100b91:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b9b:	0f b6 00             	movzbl (%eax),%eax
80100b9e:	84 c0                	test   %al,%al
80100ba0:	75 dd                	jne    80100b7f <consoleinit+0x46>
  
  cons.locking = 1;
80100ba2:	c7 05 54 d0 18 80 01 	movl   $0x1,0x8018d054
80100ba9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bac:	83 ec 08             	sub    $0x8,%esp
80100baf:	6a 00                	push   $0x0
80100bb1:	6a 01                	push   $0x1
80100bb3:	e8 54 1b 00 00       	call   8010270c <ioapicenable>
80100bb8:	83 c4 10             	add    $0x10,%esp
}
80100bbb:	90                   	nop
80100bbc:	c9                   	leave  
80100bbd:	c3                   	ret    

80100bbe <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bbe:	f3 0f 1e fb          	endbr32 
80100bc2:	55                   	push   %ebp
80100bc3:	89 e5                	mov    %esp,%ebp
80100bc5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcb:	e8 d9 2f 00 00       	call   80103ba9 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 99 25 00 00       	call   80103171 <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 04 1a 00 00       	call   801025e7 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 0d 26 00 00       	call   80103201 <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 35 a5 10 80       	push   $0x8010a535
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 f1 03 00 00       	jmp    80100fff <exec+0x441>
  }
  ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	pushl  -0x28(%ebp)
80100c14:	e8 63 0e 00 00       	call   80101a7c <ilock>
80100c19:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2d:	50                   	push   %eax
80100c2e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c31:	e8 4e 13 00 00       	call   80101f84 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 66 03 00 00    	jne    80100fa8 <exec+0x3ea>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 58 03 00 00    	jne    80100fab <exec+0x3ed>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c53:	e8 30 6a 00 00       	call   80107688 <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 49 03 00 00    	je     80100fae <exec+0x3f0>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c65:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c73:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7c:	e9 de 00 00 00       	jmp    80100d5f <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c84:	6a 20                	push   $0x20
80100c86:	50                   	push   %eax
80100c87:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8d:	50                   	push   %eax
80100c8e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c91:	e8 ee 12 00 00       	call   80101f84 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 0f 03 00 00    	jne    80100fb1 <exec+0x3f3>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca2:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca8:	83 f8 01             	cmp    $0x1,%eax
80100cab:	0f 85 a0 00 00 00    	jne    80100d51 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cb1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb7:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbd:	39 c2                	cmp    %eax,%edx
80100cbf:	0f 82 ef 02 00 00    	jb     80100fb4 <exec+0x3f6>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 d6 02 00 00    	jb     80100fb7 <exec+0x3f9>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf9:	e8 9c 6d 00 00       	call   80107a9a <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 ac 02 00 00    	je     80100fba <exec+0x3fc>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 9c 02 00 00    	jne    80100fbd <exec+0x3ff>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d21:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d27:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d33:	83 ec 0c             	sub    $0xc,%esp
80100d36:	52                   	push   %edx
80100d37:	50                   	push   %eax
80100d38:	ff 75 d8             	pushl  -0x28(%ebp)
80100d3b:	51                   	push   %ecx
80100d3c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d3f:	e8 85 6c 00 00       	call   801079c9 <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 71 02 00 00    	js     80100fc0 <exec+0x402>
80100d4f:	eb 01                	jmp    80100d52 <exec+0x194>
      continue;
80100d51:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d52:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d59:	83 c0 20             	add    $0x20,%eax
80100d5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d5f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d66:	0f b7 c0             	movzwl %ax,%eax
80100d69:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6c:	0f 8c 0f ff ff ff    	jl     80100c81 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100d72:	83 ec 0c             	sub    $0xc,%esp
80100d75:	ff 75 d8             	pushl  -0x28(%ebp)
80100d78:	e8 3c 0f 00 00       	call   80101cb9 <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d80:	e8 7c 24 00 00       	call   80103201 <end_op>
  ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9f:	05 00 20 00 00       	add    $0x2000,%eax
80100da4:	83 ec 04             	sub    $0x4,%esp
80100da7:	50                   	push   %eax
80100da8:	ff 75 e0             	pushl  -0x20(%ebp)
80100dab:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dae:	e8 e7 6c 00 00       	call   80107a9a <allocuvm>
80100db3:	83 c4 10             	add    $0x10,%esp
80100db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100db9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbd:	0f 84 00 02 00 00    	je     80100fc3 <exec+0x405>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcb:	83 ec 08             	sub    $0x8,%esp
80100dce:	50                   	push   %eax
80100dcf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd2:	e8 31 6f 00 00       	call   80107d08 <clearpteu>
80100dd7:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddd:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de7:	e9 96 00 00 00       	jmp    80100e82 <exec+0x2c4>
    if(argc >= MAXARG)
80100dec:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df0:	0f 87 d0 01 00 00    	ja     80100fc6 <exec+0x408>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 d0                	add    %edx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	83 ec 0c             	sub    $0xc,%esp
80100e0a:	50                   	push   %eax
80100e0b:	e8 b7 3f 00 00       	call   80104dc7 <strlen>
80100e10:	83 c4 10             	add    $0x10,%esp
80100e13:	89 c2                	mov    %eax,%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	83 e8 01             	sub    $0x1,%eax
80100e1d:	83 e0 fc             	and    $0xfffffffc,%eax
80100e20:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e30:	01 d0                	add    %edx,%eax
80100e32:	8b 00                	mov    (%eax),%eax
80100e34:	83 ec 0c             	sub    $0xc,%esp
80100e37:	50                   	push   %eax
80100e38:	e8 8a 3f 00 00       	call   80104dc7 <strlen>
80100e3d:	83 c4 10             	add    $0x10,%esp
80100e40:	83 c0 01             	add    $0x1,%eax
80100e43:	89 c1                	mov    %eax,%ecx
80100e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e52:	01 d0                	add    %edx,%eax
80100e54:	8b 00                	mov    (%eax),%eax
80100e56:	51                   	push   %ecx
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 50 70 00 00       	call   80107eb3 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 5b 01 00 00    	js     80100fc9 <exec+0x40b>
      goto bad;
    ustack[3+argc] = sp;
80100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e71:	8d 50 03             	lea    0x3(%eax),%edx
80100e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e77:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8f:	01 d0                	add    %edx,%eax
80100e91:	8b 00                	mov    (%eax),%eax
80100e93:	85 c0                	test   %eax,%eax
80100e95:	0f 85 51 ff ff ff    	jne    80100dec <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	83 c0 03             	add    $0x3,%eax
80100ea1:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eac:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb3:	ff ff ff 
  ustack[1] = argc;
80100eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb9:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec2:	83 c0 01             	add    $0x1,%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ecf:	29 d0                	sub    %edx,%eax
80100ed1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eda:	83 c0 04             	add    $0x4,%eax
80100edd:	c1 e0 02             	shl    $0x2,%eax
80100ee0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee6:	83 c0 04             	add    $0x4,%eax
80100ee9:	c1 e0 02             	shl    $0x2,%eax
80100eec:	50                   	push   %eax
80100eed:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef3:	50                   	push   %eax
80100ef4:	ff 75 dc             	pushl  -0x24(%ebp)
80100ef7:	ff 75 d4             	pushl  -0x2c(%ebp)
80100efa:	e8 b4 6f 00 00       	call   80107eb3 <copyout>
80100eff:	83 c4 10             	add    $0x10,%esp
80100f02:	85 c0                	test   %eax,%eax
80100f04:	0f 88 c2 00 00 00    	js     80100fcc <exec+0x40e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f16:	eb 17                	jmp    80100f2f <exec+0x371>
    if(*s == '/')
80100f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1b:	0f b6 00             	movzbl (%eax),%eax
80100f1e:	3c 2f                	cmp    $0x2f,%al
80100f20:	75 09                	jne    80100f2b <exec+0x36d>
      last = s+1;
80100f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f25:	83 c0 01             	add    $0x1,%eax
80100f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	0f b6 00             	movzbl (%eax),%eax
80100f35:	84 c0                	test   %al,%al
80100f37:	75 df                	jne    80100f18 <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3c:	83 c0 6c             	add    $0x6c,%eax
80100f3f:	83 ec 04             	sub    $0x4,%esp
80100f42:	6a 10                	push   $0x10
80100f44:	ff 75 f0             	pushl  -0x10(%ebp)
80100f47:	50                   	push   %eax
80100f48:	e8 2c 3e 00 00       	call   80104d79 <safestrcpy>
80100f4d:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f50:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f53:	8b 40 04             	mov    0x4(%eax),%eax
80100f56:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f5f:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f62:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f65:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f68:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6d:	8b 40 18             	mov    0x18(%eax),%eax
80100f70:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f76:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7c:	8b 40 18             	mov    0x18(%eax),%eax
80100f7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f82:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 d0             	pushl  -0x30(%ebp)
80100f8b:	e8 22 68 00 00       	call   801077b2 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 cd 6c 00 00       	call   80107c6b <freevm>
80100f9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa6:	eb 57                	jmp    80100fff <exec+0x441>
    goto bad;
80100fa8:	90                   	nop
80100fa9:	eb 22                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fab:	90                   	nop
80100fac:	eb 1f                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fae:	90                   	nop
80100faf:	eb 1c                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb1:	90                   	nop
80100fb2:	eb 19                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb4:	90                   	nop
80100fb5:	eb 16                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb7:	90                   	nop
80100fb8:	eb 13                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fba:	90                   	nop
80100fbb:	eb 10                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fbd:	90                   	nop
80100fbe:	eb 0d                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 0a                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 07                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 04                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 01                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fcc:	90                   	nop

 bad:
  if(pgdir)
80100fcd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd1:	74 0e                	je     80100fe1 <exec+0x423>
    freevm(pgdir);
80100fd3:	83 ec 0c             	sub    $0xc,%esp
80100fd6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fd9:	e8 8d 6c 00 00       	call   80107c6b <freevm>
80100fde:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fe5:	74 13                	je     80100ffa <exec+0x43c>
    iunlockput(ip);
80100fe7:	83 ec 0c             	sub    $0xc,%esp
80100fea:	ff 75 d8             	pushl  -0x28(%ebp)
80100fed:	e8 c7 0c 00 00       	call   80101cb9 <iunlockput>
80100ff2:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ff5:	e8 07 22 00 00       	call   80103201 <end_op>
  }
  return -1;
80100ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fff:	c9                   	leave  
80101000:	c3                   	ret    

80101001 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101001:	f3 0f 1e fb          	endbr32 
80101005:	55                   	push   %ebp
80101006:	89 e5                	mov    %esp,%ebp
80101008:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010100b:	83 ec 08             	sub    $0x8,%esp
8010100e:	68 41 a5 10 80       	push   $0x8010a541
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 8c 38 00 00       	call   801048a9 <initlock>
8010101d:	83 c4 10             	add    $0x10,%esp
}
80101020:	90                   	nop
80101021:	c9                   	leave  
80101022:	c3                   	ret    

80101023 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101023:	f3 0f 1e fb          	endbr32 
80101027:	55                   	push   %ebp
80101028:	89 e5                	mov    %esp,%ebp
8010102a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 60 2d 19 80       	push   $0x80192d60
80101035:	e8 95 38 00 00       	call   801048cf <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101044:	eb 2d                	jmp    80101073 <filealloc+0x50>
    if(f->ref == 0){
80101046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101049:	8b 40 04             	mov    0x4(%eax),%eax
8010104c:	85 c0                	test   %eax,%eax
8010104e:	75 1f                	jne    8010106f <filealloc+0x4c>
      f->ref = 1;
80101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101053:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 60 2d 19 80       	push   $0x80192d60
80101062:	e8 da 38 00 00       	call   80104941 <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 60 2d 19 80       	push   $0x80192d60
80101085:	e8 b7 38 00 00       	call   80104941 <release>
8010108a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010108d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101092:	c9                   	leave  
80101093:	c3                   	ret    

80101094 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101094:	f3 0f 1e fb          	endbr32 
80101098:	55                   	push   %ebp
80101099:	89 e5                	mov    %esp,%ebp
8010109b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	68 60 2d 19 80       	push   $0x80192d60
801010a6:	e8 24 38 00 00       	call   801048cf <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 48 a5 10 80       	push   $0x8010a548
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 60 2d 19 80       	push   $0x80192d60
801010dc:	e8 60 38 00 00       	call   80104941 <release>
801010e1:	83 c4 10             	add    $0x10,%esp
  return f;
801010e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e7:	c9                   	leave  
801010e8:	c3                   	ret    

801010e9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e9:	f3 0f 1e fb          	endbr32 
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010f3:	83 ec 0c             	sub    $0xc,%esp
801010f6:	68 60 2d 19 80       	push   $0x80192d60
801010fb:	e8 cf 37 00 00       	call   801048cf <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 50 a5 10 80       	push   $0x8010a550
80101115:	e8 ab f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 04             	mov    0x4(%eax),%eax
80101120:	8d 50 ff             	lea    -0x1(%eax),%edx
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	89 50 04             	mov    %edx,0x4(%eax)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 40 04             	mov    0x4(%eax),%eax
8010112f:	85 c0                	test   %eax,%eax
80101131:	7e 15                	jle    80101148 <fileclose+0x5f>
    release(&ftable.lock);
80101133:	83 ec 0c             	sub    $0xc,%esp
80101136:	68 60 2d 19 80       	push   $0x80192d60
8010113b:	e8 01 38 00 00       	call   80104941 <release>
80101140:	83 c4 10             	add    $0x10,%esp
80101143:	e9 8b 00 00 00       	jmp    801011d3 <fileclose+0xea>
    return;
  }
  ff = *f;
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 10                	mov    (%eax),%edx
8010114d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101150:	8b 50 04             	mov    0x4(%eax),%edx
80101153:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101156:	8b 50 08             	mov    0x8(%eax),%edx
80101159:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010115c:	8b 50 0c             	mov    0xc(%eax),%edx
8010115f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101162:	8b 50 10             	mov    0x10(%eax),%edx
80101165:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101168:	8b 40 14             	mov    0x14(%eax),%eax
8010116b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010116e:	8b 45 08             	mov    0x8(%ebp),%eax
80101171:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 60 2d 19 80       	push   $0x80192d60
80101189:	e8 b3 37 00 00       	call   80104941 <release>
8010118e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101191:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101194:	83 f8 01             	cmp    $0x1,%eax
80101197:	75 19                	jne    801011b2 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101199:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010119d:	0f be d0             	movsbl %al,%edx
801011a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011a3:	83 ec 08             	sub    $0x8,%esp
801011a6:	52                   	push   %edx
801011a7:	50                   	push   %eax
801011a8:	e8 73 26 00 00       	call   80103820 <pipeclose>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	eb 21                	jmp    801011d3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b5:	83 f8 02             	cmp    $0x2,%eax
801011b8:	75 19                	jne    801011d3 <fileclose+0xea>
    begin_op();
801011ba:	e8 b2 1f 00 00       	call   80103171 <begin_op>
    iput(ff.ip);
801011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c2:	83 ec 0c             	sub    $0xc,%esp
801011c5:	50                   	push   %eax
801011c6:	e8 1a 0a 00 00       	call   80101be5 <iput>
801011cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ce:	e8 2e 20 00 00       	call   80103201 <end_op>
  }
}
801011d3:	c9                   	leave  
801011d4:	c3                   	ret    

801011d5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d5:	f3 0f 1e fb          	endbr32 
801011d9:	55                   	push   %ebp
801011da:	89 e5                	mov    %esp,%ebp
801011dc:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8b 00                	mov    (%eax),%eax
801011e4:	83 f8 02             	cmp    $0x2,%eax
801011e7:	75 40                	jne    80101229 <filestat+0x54>
    ilock(f->ip);
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 40 10             	mov    0x10(%eax),%eax
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	50                   	push   %eax
801011f3:	e8 84 08 00 00       	call   80101a7c <ilock>
801011f8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	8b 40 10             	mov    0x10(%eax),%eax
80101201:	83 ec 08             	sub    $0x8,%esp
80101204:	ff 75 0c             	pushl  0xc(%ebp)
80101207:	50                   	push   %eax
80101208:	e8 2d 0d 00 00       	call   80101f3a <stati>
8010120d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101210:	8b 45 08             	mov    0x8(%ebp),%eax
80101213:	8b 40 10             	mov    0x10(%eax),%eax
80101216:	83 ec 0c             	sub    $0xc,%esp
80101219:	50                   	push   %eax
8010121a:	e8 74 09 00 00       	call   80101b93 <iunlock>
8010121f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101222:	b8 00 00 00 00       	mov    $0x0,%eax
80101227:	eb 05                	jmp    8010122e <filestat+0x59>
  }
  return -1;
80101229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010122e:	c9                   	leave  
8010122f:	c3                   	ret    

80101230 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101230:	f3 0f 1e fb          	endbr32 
80101234:	55                   	push   %ebp
80101235:	89 e5                	mov    %esp,%ebp
80101237:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010123a:	8b 45 08             	mov    0x8(%ebp),%eax
8010123d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101241:	84 c0                	test   %al,%al
80101243:	75 0a                	jne    8010124f <fileread+0x1f>
    return -1;
80101245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010124a:	e9 9b 00 00 00       	jmp    801012ea <fileread+0xba>
  if(f->type == FD_PIPE)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 00                	mov    (%eax),%eax
80101254:	83 f8 01             	cmp    $0x1,%eax
80101257:	75 1a                	jne    80101273 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 0c             	mov    0xc(%eax),%eax
8010125f:	83 ec 04             	sub    $0x4,%esp
80101262:	ff 75 10             	pushl  0x10(%ebp)
80101265:	ff 75 0c             	pushl  0xc(%ebp)
80101268:	50                   	push   %eax
80101269:	e8 67 27 00 00       	call   801039d5 <piperead>
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	eb 77                	jmp    801012ea <fileread+0xba>
  if(f->type == FD_INODE){
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	8b 00                	mov    (%eax),%eax
80101278:	83 f8 02             	cmp    $0x2,%eax
8010127b:	75 60                	jne    801012dd <fileread+0xad>
    ilock(f->ip);
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 10             	mov    0x10(%eax),%eax
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	50                   	push   %eax
80101287:	e8 f0 07 00 00       	call   80101a7c <ilock>
8010128c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010128f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 50 14             	mov    0x14(%eax),%edx
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 40 10             	mov    0x10(%eax),%eax
8010129e:	51                   	push   %ecx
8010129f:	52                   	push   %edx
801012a0:	ff 75 0c             	pushl  0xc(%ebp)
801012a3:	50                   	push   %eax
801012a4:	e8 db 0c 00 00       	call   80101f84 <readi>
801012a9:	83 c4 10             	add    $0x10,%esp
801012ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012b3:	7e 11                	jle    801012c6 <fileread+0x96>
      f->off += r;
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 50 14             	mov    0x14(%eax),%edx
801012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012be:	01 c2                	add    %eax,%edx
801012c0:	8b 45 08             	mov    0x8(%ebp),%eax
801012c3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 40 10             	mov    0x10(%eax),%eax
801012cc:	83 ec 0c             	sub    $0xc,%esp
801012cf:	50                   	push   %eax
801012d0:	e8 be 08 00 00       	call   80101b93 <iunlock>
801012d5:	83 c4 10             	add    $0x10,%esp
    return r;
801012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012db:	eb 0d                	jmp    801012ea <fileread+0xba>
  }
  panic("fileread");
801012dd:	83 ec 0c             	sub    $0xc,%esp
801012e0:	68 5a a5 10 80       	push   $0x8010a55a
801012e5:	e8 db f2 ff ff       	call   801005c5 <panic>
}
801012ea:	c9                   	leave  
801012eb:	c3                   	ret    

801012ec <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012ec:	f3 0f 1e fb          	endbr32 
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	53                   	push   %ebx
801012f4:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012fe:	84 c0                	test   %al,%al
80101300:	75 0a                	jne    8010130c <filewrite+0x20>
    return -1;
80101302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101307:	e9 1b 01 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 00                	mov    (%eax),%eax
80101311:	83 f8 01             	cmp    $0x1,%eax
80101314:	75 1d                	jne    80101333 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	8b 40 0c             	mov    0xc(%eax),%eax
8010131c:	83 ec 04             	sub    $0x4,%esp
8010131f:	ff 75 10             	pushl  0x10(%ebp)
80101322:	ff 75 0c             	pushl  0xc(%ebp)
80101325:	50                   	push   %eax
80101326:	e8 a4 25 00 00       	call   801038cf <pipewrite>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	e9 f4 00 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 00                	mov    (%eax),%eax
80101338:	83 f8 02             	cmp    $0x2,%eax
8010133b:	0f 85 d9 00 00 00    	jne    8010141a <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101341:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010134f:	e9 a3 00 00 00       	jmp    801013f7 <filewrite+0x10b>
      int n1 = n - i;
80101354:	8b 45 10             	mov    0x10(%ebp),%eax
80101357:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010135a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101360:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101363:	7e 06                	jle    8010136b <filewrite+0x7f>
        n1 = max;
80101365:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101368:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010136b:	e8 01 1e 00 00       	call   80103171 <begin_op>
      ilock(f->ip);
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 40 10             	mov    0x10(%eax),%eax
80101376:	83 ec 0c             	sub    $0xc,%esp
80101379:	50                   	push   %eax
8010137a:	e8 fd 06 00 00       	call   80101a7c <ilock>
8010137f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101382:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8b 50 14             	mov    0x14(%eax),%edx
8010138b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010138e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101391:	01 c3                	add    %eax,%ebx
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 40 10             	mov    0x10(%eax),%eax
80101399:	51                   	push   %ecx
8010139a:	52                   	push   %edx
8010139b:	53                   	push   %ebx
8010139c:	50                   	push   %eax
8010139d:	e8 3b 0d 00 00       	call   801020dd <writei>
801013a2:	83 c4 10             	add    $0x10,%esp
801013a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ac:	7e 11                	jle    801013bf <filewrite+0xd3>
        f->off += r;
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 50 14             	mov    0x14(%eax),%edx
801013b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b7:	01 c2                	add    %eax,%edx
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 40 10             	mov    0x10(%eax),%eax
801013c5:	83 ec 0c             	sub    $0xc,%esp
801013c8:	50                   	push   %eax
801013c9:	e8 c5 07 00 00       	call   80101b93 <iunlock>
801013ce:	83 c4 10             	add    $0x10,%esp
      end_op();
801013d1:	e8 2b 1e 00 00       	call   80103201 <end_op>

      if(r < 0)
801013d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013da:	78 29                	js     80101405 <filewrite+0x119>
        break;
      if(r != n1)
801013dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013df:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013e2:	74 0d                	je     801013f1 <filewrite+0x105>
        panic("short filewrite");
801013e4:	83 ec 0c             	sub    $0xc,%esp
801013e7:	68 63 a5 10 80       	push   $0x8010a563
801013ec:	e8 d4 f1 ff ff       	call   801005c5 <panic>
      i += r;
801013f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fd:	0f 8c 51 ff ff ff    	jl     80101354 <filewrite+0x68>
80101403:	eb 01                	jmp    80101406 <filewrite+0x11a>
        break;
80101405:	90                   	nop
    }
    return i == n ? n : -1;
80101406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101409:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140c:	75 05                	jne    80101413 <filewrite+0x127>
8010140e:	8b 45 10             	mov    0x10(%ebp),%eax
80101411:	eb 14                	jmp    80101427 <filewrite+0x13b>
80101413:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101418:	eb 0d                	jmp    80101427 <filewrite+0x13b>
  }
  panic("filewrite");
8010141a:	83 ec 0c             	sub    $0xc,%esp
8010141d:	68 73 a5 10 80       	push   $0x8010a573
80101422:	e8 9e f1 ff ff       	call   801005c5 <panic>
}
80101427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010142a:	c9                   	leave  
8010142b:	c3                   	ret    

8010142c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010142c:	f3 0f 1e fb          	endbr32 
80101430:	55                   	push   %ebp
80101431:	89 e5                	mov    %esp,%ebp
80101433:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101436:	8b 45 08             	mov    0x8(%ebp),%eax
80101439:	83 ec 08             	sub    $0x8,%esp
8010143c:	6a 01                	push   $0x1
8010143e:	50                   	push   %eax
8010143f:	e8 c5 ed ff ff       	call   80100209 <bread>
80101444:	83 c4 10             	add    $0x10,%esp
80101447:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144d:	83 c0 5c             	add    $0x5c,%eax
80101450:	83 ec 04             	sub    $0x4,%esp
80101453:	6a 1c                	push   $0x1c
80101455:	50                   	push   %eax
80101456:	ff 75 0c             	pushl  0xc(%ebp)
80101459:	e8 c7 37 00 00       	call   80104c25 <memmove>
8010145e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101461:	83 ec 0c             	sub    $0xc,%esp
80101464:	ff 75 f4             	pushl  -0xc(%ebp)
80101467:	e8 27 ee ff ff       	call   80100293 <brelse>
8010146c:	83 c4 10             	add    $0x10,%esp
}
8010146f:	90                   	nop
80101470:	c9                   	leave  
80101471:	c3                   	ret    

80101472 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101472:	f3 0f 1e fb          	endbr32 
80101476:	55                   	push   %ebp
80101477:	89 e5                	mov    %esp,%ebp
80101479:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010147c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010147f:	8b 45 08             	mov    0x8(%ebp),%eax
80101482:	83 ec 08             	sub    $0x8,%esp
80101485:	52                   	push   %edx
80101486:	50                   	push   %eax
80101487:	e8 7d ed ff ff       	call   80100209 <bread>
8010148c:	83 c4 10             	add    $0x10,%esp
8010148f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101495:	83 c0 5c             	add    $0x5c,%eax
80101498:	83 ec 04             	sub    $0x4,%esp
8010149b:	68 00 02 00 00       	push   $0x200
801014a0:	6a 00                	push   $0x0
801014a2:	50                   	push   %eax
801014a3:	e8 b6 36 00 00       	call   80104b5e <memset>
801014a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 04 1f 00 00       	call   801033ba <log_write>
801014b6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014b9:	83 ec 0c             	sub    $0xc,%esp
801014bc:	ff 75 f4             	pushl  -0xc(%ebp)
801014bf:	e8 cf ed ff ff       	call   80100293 <brelse>
801014c4:	83 c4 10             	add    $0x10,%esp
}
801014c7:	90                   	nop
801014c8:	c9                   	leave  
801014c9:	c3                   	ret    

801014ca <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014ca:	f3 0f 1e fb          	endbr32 
801014ce:	55                   	push   %ebp
801014cf:	89 e5                	mov    %esp,%ebp
801014d1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014e2:	e9 13 01 00 00       	jmp    801015fa <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ea:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014f0:	85 c0                	test   %eax,%eax
801014f2:	0f 48 c2             	cmovs  %edx,%eax
801014f5:	c1 f8 0c             	sar    $0xc,%eax
801014f8:	89 c2                	mov    %eax,%edx
801014fa:	a1 78 37 19 80       	mov    0x80193778,%eax
801014ff:	01 d0                	add    %edx,%eax
80101501:	83 ec 08             	sub    $0x8,%esp
80101504:	50                   	push   %eax
80101505:	ff 75 08             	pushl  0x8(%ebp)
80101508:	e8 fc ec ff ff       	call   80100209 <bread>
8010150d:	83 c4 10             	add    $0x10,%esp
80101510:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101513:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010151a:	e9 a6 00 00 00       	jmp    801015c5 <balloc+0xfb>
      m = 1 << (bi % 8);
8010151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101522:	99                   	cltd   
80101523:	c1 ea 1d             	shr    $0x1d,%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	83 e0 07             	and    $0x7,%eax
8010152b:	29 d0                	sub    %edx,%eax
8010152d:	ba 01 00 00 00       	mov    $0x1,%edx
80101532:	89 c1                	mov    %eax,%ecx
80101534:	d3 e2                	shl    %cl,%edx
80101536:	89 d0                	mov    %edx,%eax
80101538:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153e:	8d 50 07             	lea    0x7(%eax),%edx
80101541:	85 c0                	test   %eax,%eax
80101543:	0f 48 c2             	cmovs  %edx,%eax
80101546:	c1 f8 03             	sar    $0x3,%eax
80101549:	89 c2                	mov    %eax,%edx
8010154b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101553:	0f b6 c0             	movzbl %al,%eax
80101556:	23 45 e8             	and    -0x18(%ebp),%eax
80101559:	85 c0                	test   %eax,%eax
8010155b:	75 64                	jne    801015c1 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101560:	8d 50 07             	lea    0x7(%eax),%edx
80101563:	85 c0                	test   %eax,%eax
80101565:	0f 48 c2             	cmovs  %edx,%eax
80101568:	c1 f8 03             	sar    $0x3,%eax
8010156b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101573:	89 d1                	mov    %edx,%ecx
80101575:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101578:	09 ca                	or     %ecx,%edx
8010157a:	89 d1                	mov    %edx,%ecx
8010157c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101583:	83 ec 0c             	sub    $0xc,%esp
80101586:	ff 75 ec             	pushl  -0x14(%ebp)
80101589:	e8 2c 1e 00 00       	call   801033ba <log_write>
8010158e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101591:	83 ec 0c             	sub    $0xc,%esp
80101594:	ff 75 ec             	pushl  -0x14(%ebp)
80101597:	e8 f7 ec ff ff       	call   80100293 <brelse>
8010159c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a5:	01 c2                	add    %eax,%edx
801015a7:	8b 45 08             	mov    0x8(%ebp),%eax
801015aa:	83 ec 08             	sub    $0x8,%esp
801015ad:	52                   	push   %edx
801015ae:	50                   	push   %eax
801015af:	e8 be fe ff ff       	call   80101472 <bzero>
801015b4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bd:	01 d0                	add    %edx,%eax
801015bf:	eb 57                	jmp    80101618 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015c5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015cc:	7f 17                	jg     801015e5 <balloc+0x11b>
801015ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d4:	01 d0                	add    %edx,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	a1 60 37 19 80       	mov    0x80193760,%eax
801015dd:	39 c2                	cmp    %eax,%edx
801015df:	0f 82 3a ff ff ff    	jb     8010151f <balloc+0x55>
      }
    }
    brelse(bp);
801015e5:	83 ec 0c             	sub    $0xc,%esp
801015e8:	ff 75 ec             	pushl  -0x14(%ebp)
801015eb:	e8 a3 ec ff ff       	call   80100293 <brelse>
801015f0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015fa:	8b 15 60 37 19 80    	mov    0x80193760,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 80 a5 10 80       	push   $0x8010a580
80101613:	e8 ad ef ff ff       	call   801005c5 <panic>
}
80101618:	c9                   	leave  
80101619:	c3                   	ret    

8010161a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010161a:	f3 0f 1e fb          	endbr32 
8010161e:	55                   	push   %ebp
8010161f:	89 e5                	mov    %esp,%ebp
80101621:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101624:	83 ec 08             	sub    $0x8,%esp
80101627:	68 60 37 19 80       	push   $0x80193760
8010162c:	ff 75 08             	pushl  0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 78 37 19 80       	mov    0x80193778,%eax
80101644:	01 c2                	add    %eax,%edx
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	83 ec 08             	sub    $0x8,%esp
8010164c:	52                   	push   %edx
8010164d:	50                   	push   %eax
8010164e:	e8 b6 eb ff ff       	call   80100209 <bread>
80101653:	83 c4 10             	add    $0x10,%esp
80101656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010165c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101661:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101667:	99                   	cltd   
80101668:	c1 ea 1d             	shr    $0x1d,%edx
8010166b:	01 d0                	add    %edx,%eax
8010166d:	83 e0 07             	and    $0x7,%eax
80101670:	29 d0                	sub    %edx,%eax
80101672:	ba 01 00 00 00       	mov    $0x1,%edx
80101677:	89 c1                	mov    %eax,%ecx
80101679:	d3 e2                	shl    %cl,%edx
8010167b:	89 d0                	mov    %edx,%eax
8010167d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101683:	8d 50 07             	lea    0x7(%eax),%edx
80101686:	85 c0                	test   %eax,%eax
80101688:	0f 48 c2             	cmovs  %edx,%eax
8010168b:	c1 f8 03             	sar    $0x3,%eax
8010168e:	89 c2                	mov    %eax,%edx
80101690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101693:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101698:	0f b6 c0             	movzbl %al,%eax
8010169b:	23 45 ec             	and    -0x14(%ebp),%eax
8010169e:	85 c0                	test   %eax,%eax
801016a0:	75 0d                	jne    801016af <bfree+0x95>
    panic("freeing free block");
801016a2:	83 ec 0c             	sub    $0xc,%esp
801016a5:	68 96 a5 10 80       	push   $0x8010a596
801016aa:	e8 16 ef ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
801016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b2:	8d 50 07             	lea    0x7(%eax),%edx
801016b5:	85 c0                	test   %eax,%eax
801016b7:	0f 48 c2             	cmovs  %edx,%eax
801016ba:	c1 f8 03             	sar    $0x3,%eax
801016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016c5:	89 d1                	mov    %edx,%ecx
801016c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ca:	f7 d2                	not    %edx
801016cc:	21 ca                	and    %ecx,%edx
801016ce:	89 d1                	mov    %edx,%ecx
801016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 f4             	pushl  -0xc(%ebp)
801016dd:	e8 d8 1c 00 00       	call   801033ba <log_write>
801016e2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016e5:	83 ec 0c             	sub    $0xc,%esp
801016e8:	ff 75 f4             	pushl  -0xc(%ebp)
801016eb:	e8 a3 eb ff ff       	call   80100293 <brelse>
801016f0:	83 c4 10             	add    $0x10,%esp
}
801016f3:	90                   	nop
801016f4:	c9                   	leave  
801016f5:	c3                   	ret    

801016f6 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016f6:	f3 0f 1e fb          	endbr32 
801016fa:	55                   	push   %ebp
801016fb:	89 e5                	mov    %esp,%ebp
801016fd:	57                   	push   %edi
801016fe:	56                   	push   %esi
801016ff:	53                   	push   %ebx
80101700:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010170a:	83 ec 08             	sub    $0x8,%esp
8010170d:	68 a9 a5 10 80       	push   $0x8010a5a9
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 8d 31 00 00       	call   801048a9 <initlock>
8010171c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010171f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101726:	eb 2d                	jmp    80101755 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101728:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010172b:	89 d0                	mov    %edx,%eax
8010172d:	c1 e0 03             	shl    $0x3,%eax
80101730:	01 d0                	add    %edx,%eax
80101732:	c1 e0 04             	shl    $0x4,%eax
80101735:	83 c0 30             	add    $0x30,%eax
80101738:	05 80 37 19 80       	add    $0x80193780,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 b0 a5 10 80       	push   $0x8010a5b0
80101748:	50                   	push   %eax
80101749:	e8 ee 2f 00 00       	call   8010473c <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 60 37 19 80       	push   $0x80193760
80101763:	ff 75 08             	pushl  0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 78 37 19 80       	mov    0x80193778,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
8010177c:	8b 35 70 37 19 80    	mov    0x80193770,%esi
80101782:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
80101788:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
8010178e:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101794:	a1 60 37 19 80       	mov    0x80193760,%eax
80101799:	ff 75 d4             	pushl  -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 b8 a5 10 80       	push   $0x8010a5b8
801017a7:	e8 60 ec ff ff       	call   8010040c <cprintf>
801017ac:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017af:	90                   	nop
801017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017b3:	5b                   	pop    %ebx
801017b4:	5e                   	pop    %esi
801017b5:	5f                   	pop    %edi
801017b6:	5d                   	pop    %ebp
801017b7:	c3                   	ret    

801017b8 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017b8:	f3 0f 1e fb          	endbr32 
801017bc:	55                   	push   %ebp
801017bd:	89 e5                	mov    %esp,%ebp
801017bf:	83 ec 28             	sub    $0x28,%esp
801017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801017c5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017d0:	e9 9e 00 00 00       	jmp    80101873 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	c1 e8 03             	shr    $0x3,%eax
801017db:	89 c2                	mov    %eax,%edx
801017dd:	a1 74 37 19 80       	mov    0x80193774,%eax
801017e2:	01 d0                	add    %edx,%eax
801017e4:	83 ec 08             	sub    $0x8,%esp
801017e7:	50                   	push   %eax
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	e8 19 ea ff ff       	call   80100209 <bread>
801017f0:	83 c4 10             	add    $0x10,%esp
801017f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	8d 50 5c             	lea    0x5c(%eax),%edx
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	83 e0 07             	and    $0x7,%eax
80101802:	c1 e0 06             	shl    $0x6,%eax
80101805:	01 d0                	add    %edx,%eax
80101807:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010180a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010180d:	0f b7 00             	movzwl (%eax),%eax
80101810:	66 85 c0             	test   %ax,%ax
80101813:	75 4c                	jne    80101861 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101815:	83 ec 04             	sub    $0x4,%esp
80101818:	6a 40                	push   $0x40
8010181a:	6a 00                	push   $0x0
8010181c:	ff 75 ec             	pushl  -0x14(%ebp)
8010181f:	e8 3a 33 00 00       	call   80104b5e <memset>
80101824:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010182e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	pushl  -0x10(%ebp)
80101837:	e8 7e 1b 00 00       	call   801033ba <log_write>
8010183c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010183f:	83 ec 0c             	sub    $0xc,%esp
80101842:	ff 75 f0             	pushl  -0x10(%ebp)
80101845:	e8 49 ea ff ff       	call   80100293 <brelse>
8010184a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	83 ec 08             	sub    $0x8,%esp
80101853:	50                   	push   %eax
80101854:	ff 75 08             	pushl  0x8(%ebp)
80101857:	e8 fc 00 00 00       	call   80101958 <iget>
8010185c:	83 c4 10             	add    $0x10,%esp
8010185f:	eb 30                	jmp    80101891 <ialloc+0xd9>
    }
    brelse(bp);
80101861:	83 ec 0c             	sub    $0xc,%esp
80101864:	ff 75 f0             	pushl  -0x10(%ebp)
80101867:	e8 27 ea ff ff       	call   80100293 <brelse>
8010186c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010186f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101873:	8b 15 68 37 19 80    	mov    0x80193768,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 0b a6 10 80       	push   $0x8010a60b
8010188c:	e8 34 ed ff ff       	call   801005c5 <panic>
}
80101891:	c9                   	leave  
80101892:	c3                   	ret    

80101893 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101893:	f3 0f 1e fb          	endbr32 
80101897:	55                   	push   %ebp
80101898:	89 e5                	mov    %esp,%ebp
8010189a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010189d:	8b 45 08             	mov    0x8(%ebp),%eax
801018a0:	8b 40 04             	mov    0x4(%eax),%eax
801018a3:	c1 e8 03             	shr    $0x3,%eax
801018a6:	89 c2                	mov    %eax,%edx
801018a8:	a1 74 37 19 80       	mov    0x80193774,%eax
801018ad:	01 c2                	add    %eax,%edx
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	8b 00                	mov    (%eax),%eax
801018b4:	83 ec 08             	sub    $0x8,%esp
801018b7:	52                   	push   %edx
801018b8:	50                   	push   %eax
801018b9:	e8 4b e9 ff ff       	call   80100209 <bread>
801018be:	83 c4 10             	add    $0x10,%esp
801018c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 40 04             	mov    0x4(%eax),%eax
801018d0:	83 e0 07             	and    $0x7,%eax
801018d3:	c1 e0 06             	shl    $0x6,%eax
801018d6:	01 d0                	add    %edx,%eax
801018d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018db:	8b 45 08             	mov    0x8(%ebp),%eax
801018de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101900:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101912:	8b 45 08             	mov    0x8(%ebp),%eax
80101915:	8b 50 58             	mov    0x58(%eax),%edx
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8d 50 5c             	lea    0x5c(%eax),%edx
80101924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101927:	83 c0 0c             	add    $0xc,%eax
8010192a:	83 ec 04             	sub    $0x4,%esp
8010192d:	6a 34                	push   $0x34
8010192f:	52                   	push   %edx
80101930:	50                   	push   %eax
80101931:	e8 ef 32 00 00       	call   80104c25 <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 76 1a 00 00       	call   801033ba <log_write>
80101944:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101947:	83 ec 0c             	sub    $0xc,%esp
8010194a:	ff 75 f4             	pushl  -0xc(%ebp)
8010194d:	e8 41 e9 ff ff       	call   80100293 <brelse>
80101952:	83 c4 10             	add    $0x10,%esp
}
80101955:	90                   	nop
80101956:	c9                   	leave  
80101957:	c3                   	ret    

80101958 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101958:	f3 0f 1e fb          	endbr32 
8010195c:	55                   	push   %ebp
8010195d:	89 e5                	mov    %esp,%ebp
8010195f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101962:	83 ec 0c             	sub    $0xc,%esp
80101965:	68 80 37 19 80       	push   $0x80193780
8010196a:	e8 60 2f 00 00       	call   801048cf <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
80101980:	eb 60                	jmp    801019e2 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101985:	8b 40 08             	mov    0x8(%eax),%eax
80101988:	85 c0                	test   %eax,%eax
8010198a:	7e 39                	jle    801019c5 <iget+0x6d>
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	8b 00                	mov    (%eax),%eax
80101991:	39 45 08             	cmp    %eax,0x8(%ebp)
80101994:	75 2f                	jne    801019c5 <iget+0x6d>
80101996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010199f:	75 24                	jne    801019c5 <iget+0x6d>
      ip->ref++;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a4:	8b 40 08             	mov    0x8(%eax),%eax
801019a7:	8d 50 01             	lea    0x1(%eax),%edx
801019aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ad:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019b0:	83 ec 0c             	sub    $0xc,%esp
801019b3:	68 80 37 19 80       	push   $0x80193780
801019b8:	e8 84 2f 00 00       	call   80104941 <release>
801019bd:	83 c4 10             	add    $0x10,%esp
      return ip;
801019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c3:	eb 77                	jmp    80101a3c <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019c9:	75 10                	jne    801019db <iget+0x83>
801019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ce:	8b 40 08             	mov    0x8(%eax),%eax
801019d1:	85 c0                	test   %eax,%eax
801019d3:	75 06                	jne    801019db <iget+0x83>
      empty = ip;
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019db:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019e2:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 1d a6 10 80       	push   $0x8010a61d
801019f9:	e8 c7 eb ff ff       	call   801005c5 <panic>

  ip = empty;
801019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	8b 55 08             	mov    0x8(%ebp),%edx
80101a0a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a12:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a22:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a29:	83 ec 0c             	sub    $0xc,%esp
80101a2c:	68 80 37 19 80       	push   $0x80193780
80101a31:	e8 0b 2f 00 00       	call   80104941 <release>
80101a36:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a3c:	c9                   	leave  
80101a3d:	c3                   	ret    

80101a3e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a3e:	f3 0f 1e fb          	endbr32 
80101a42:	55                   	push   %ebp
80101a43:	89 e5                	mov    %esp,%ebp
80101a45:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a48:	83 ec 0c             	sub    $0xc,%esp
80101a4b:	68 80 37 19 80       	push   $0x80193780
80101a50:	e8 7a 2e 00 00       	call   801048cf <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 80 37 19 80       	push   $0x80193780
80101a6f:	e8 cd 2e 00 00       	call   80104941 <release>
80101a74:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a7a:	c9                   	leave  
80101a7b:	c3                   	ret    

80101a7c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a7c:	f3 0f 1e fb          	endbr32 
80101a80:	55                   	push   %ebp
80101a81:	89 e5                	mov    %esp,%ebp
80101a83:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a8a:	74 0a                	je     80101a96 <ilock+0x1a>
80101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8f:	8b 40 08             	mov    0x8(%eax),%eax
80101a92:	85 c0                	test   %eax,%eax
80101a94:	7f 0d                	jg     80101aa3 <ilock+0x27>
    panic("ilock");
80101a96:	83 ec 0c             	sub    $0xc,%esp
80101a99:	68 2d a6 10 80       	push   $0x8010a62d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 ca 2c 00 00       	call   8010477c <acquiresleep>
80101ab2:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101abb:	85 c0                	test   %eax,%eax
80101abd:	0f 85 cd 00 00 00    	jne    80101b90 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	8b 40 04             	mov    0x4(%eax),%eax
80101ac9:	c1 e8 03             	shr    $0x3,%eax
80101acc:	89 c2                	mov    %eax,%edx
80101ace:	a1 74 37 19 80       	mov    0x80193774,%eax
80101ad3:	01 c2                	add    %eax,%edx
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad8:	8b 00                	mov    (%eax),%eax
80101ada:	83 ec 08             	sub    $0x8,%esp
80101add:	52                   	push   %edx
80101ade:	50                   	push   %eax
80101adf:	e8 25 e7 ff ff       	call   80100209 <bread>
80101ae4:	83 c4 10             	add    $0x10,%esp
80101ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aed:	8d 50 5c             	lea    0x5c(%eax),%edx
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	8b 40 04             	mov    0x4(%eax),%eax
80101af6:	83 e0 07             	and    $0x7,%eax
80101af9:	c1 e0 06             	shl    $0x6,%eax
80101afc:	01 d0                	add    %edx,%eax
80101afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b04:	0f b7 10             	movzwl (%eax),%edx
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b11:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3b:	8b 50 08             	mov    0x8(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b47:	8d 50 0c             	lea    0xc(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	83 c0 5c             	add    $0x5c,%eax
80101b50:	83 ec 04             	sub    $0x4,%esp
80101b53:	6a 34                	push   $0x34
80101b55:	52                   	push   %edx
80101b56:	50                   	push   %eax
80101b57:	e8 c9 30 00 00       	call   80104c25 <memmove>
80101b5c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	ff 75 f4             	pushl  -0xc(%ebp)
80101b65:	e8 29 e7 ff ff       	call   80100293 <brelse>
80101b6a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b7e:	66 85 c0             	test   %ax,%ax
80101b81:	75 0d                	jne    80101b90 <ilock+0x114>
      panic("ilock: no type");
80101b83:	83 ec 0c             	sub    $0xc,%esp
80101b86:	68 33 a6 10 80       	push   $0x8010a633
80101b8b:	e8 35 ea ff ff       	call   801005c5 <panic>
  }
}
80101b90:	90                   	nop
80101b91:	c9                   	leave  
80101b92:	c3                   	ret    

80101b93 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b93:	f3 0f 1e fb          	endbr32 
80101b97:	55                   	push   %ebp
80101b98:	89 e5                	mov    %esp,%ebp
80101b9a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ba1:	74 20                	je     80101bc3 <iunlock+0x30>
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	83 c0 0c             	add    $0xc,%eax
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	50                   	push   %eax
80101bad:	e8 84 2c 00 00       	call   80104836 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 42 a6 10 80       	push   $0x8010a642
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 05 2c 00 00       	call   801047e4 <releasesleep>
80101bdf:	83 c4 10             	add    $0x10,%esp
}
80101be2:	90                   	nop
80101be3:	c9                   	leave  
80101be4:	c3                   	ret    

80101be5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be5:	f3 0f 1e fb          	endbr32 
80101be9:	55                   	push   %ebp
80101bea:	89 e5                	mov    %esp,%ebp
80101bec:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	83 c0 0c             	add    $0xc,%eax
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	50                   	push   %eax
80101bf9:	e8 7e 2b 00 00       	call   8010477c <acquiresleep>
80101bfe:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c07:	85 c0                	test   %eax,%eax
80101c09:	74 6a                	je     80101c75 <iput+0x90>
80101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c12:	66 85 c0             	test   %ax,%ax
80101c15:	75 5e                	jne    80101c75 <iput+0x90>
    acquire(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 80 37 19 80       	push   $0x80193780
80101c1f:	e8 ab 2c 00 00       	call   801048cf <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 04 2d 00 00       	call   80104941 <release>
80101c3d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c40:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c44:	75 2f                	jne    80101c75 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c46:	83 ec 0c             	sub    $0xc,%esp
80101c49:	ff 75 08             	pushl  0x8(%ebp)
80101c4c:	e8 b5 01 00 00       	call   80101e06 <itrunc>
80101c51:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	pushl  0x8(%ebp)
80101c63:	e8 2b fc ff ff       	call   80101893 <iupdate>
80101c68:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	83 c0 0c             	add    $0xc,%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 60 2b 00 00       	call   801047e4 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 3b 2c 00 00       	call   801048cf <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 80 37 19 80       	push   $0x80193780
80101cae:	e8 8e 2c 00 00       	call   80104941 <release>
80101cb3:	83 c4 10             	add    $0x10,%esp
}
80101cb6:	90                   	nop
80101cb7:	c9                   	leave  
80101cb8:	c3                   	ret    

80101cb9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cb9:	f3 0f 1e fb          	endbr32 
80101cbd:	55                   	push   %ebp
80101cbe:	89 e5                	mov    %esp,%ebp
80101cc0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cc3:	83 ec 0c             	sub    $0xc,%esp
80101cc6:	ff 75 08             	pushl  0x8(%ebp)
80101cc9:	e8 c5 fe ff ff       	call   80101b93 <iunlock>
80101cce:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	ff 75 08             	pushl  0x8(%ebp)
80101cd7:	e8 09 ff ff ff       	call   80101be5 <iput>
80101cdc:	83 c4 10             	add    $0x10,%esp
}
80101cdf:	90                   	nop
80101ce0:	c9                   	leave  
80101ce1:	c3                   	ret    

80101ce2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ce2:	f3 0f 1e fb          	endbr32 
80101ce6:	55                   	push   %ebp
80101ce7:	89 e5                	mov    %esp,%ebp
80101ce9:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cec:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cf0:	77 42                	ja     80101d34 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf8:	83 c2 14             	add    $0x14,%edx
80101cfb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 24                	jne    80101d2c <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 b4 f7 ff ff       	call   801014ca <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d22:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	e9 d0 00 00 00       	jmp    80101e04 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d34:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d38:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d3c:	0f 87 b5 00 00 00    	ja     80101df7 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d52:	75 20                	jne    80101d74 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	8b 00                	mov    (%eax),%eax
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	50                   	push   %eax
80101d5d:	e8 68 f7 ff ff       	call   801014ca <balloc>
80101d62:	83 c4 10             	add    $0x10,%esp
80101d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 00                	mov    (%eax),%eax
80101d79:	83 ec 08             	sub    $0x8,%esp
80101d7c:	ff 75 f4             	pushl  -0xc(%ebp)
80101d7f:	50                   	push   %eax
80101d80:	e8 84 e4 ff ff       	call   80100209 <bread>
80101d85:	83 c4 10             	add    $0x10,%esp
80101d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8e:	83 c0 5c             	add    $0x5c,%eax
80101d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da1:	01 d0                	add    %edx,%eax
80101da3:	8b 00                	mov    (%eax),%eax
80101da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dac:	75 36                	jne    80101de4 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 00                	mov    (%eax),%eax
80101db3:	83 ec 0c             	sub    $0xc,%esp
80101db6:	50                   	push   %eax
80101db7:	e8 0e f7 ff ff       	call   801014ca <balloc>
80101dbc:	83 c4 10             	add    $0x10,%esp
80101dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dcf:	01 c2                	add    %eax,%edx
80101dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd4:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 f0             	pushl  -0x10(%ebp)
80101ddc:	e8 d9 15 00 00       	call   801033ba <log_write>
80101de1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101de4:	83 ec 0c             	sub    $0xc,%esp
80101de7:	ff 75 f0             	pushl  -0x10(%ebp)
80101dea:	e8 a4 e4 ff ff       	call   80100293 <brelse>
80101def:	83 c4 10             	add    $0x10,%esp
    return addr;
80101df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df5:	eb 0d                	jmp    80101e04 <bmap+0x122>
  }

  panic("bmap: out of range");
80101df7:	83 ec 0c             	sub    $0xc,%esp
80101dfa:	68 4a a6 10 80       	push   $0x8010a64a
80101dff:	e8 c1 e7 ff ff       	call   801005c5 <panic>
}
80101e04:	c9                   	leave  
80101e05:	c3                   	ret    

80101e06 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e06:	f3 0f 1e fb          	endbr32 
80101e0a:	55                   	push   %ebp
80101e0b:	89 e5                	mov    %esp,%ebp
80101e0d:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e17:	eb 45                	jmp    80101e5e <itrunc+0x58>
    if(ip->addrs[i]){
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e1f:	83 c2 14             	add    $0x14,%edx
80101e22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e26:	85 c0                	test   %eax,%eax
80101e28:	74 30                	je     80101e5a <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e30:	83 c2 14             	add    $0x14,%edx
80101e33:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e37:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3a:	8b 12                	mov    (%edx),%edx
80101e3c:	83 ec 08             	sub    $0x8,%esp
80101e3f:	50                   	push   %eax
80101e40:	52                   	push   %edx
80101e41:	e8 d4 f7 ff ff       	call   8010161a <bfree>
80101e46:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e49:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4f:	83 c2 14             	add    $0x14,%edx
80101e52:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e59:	00 
  for(i = 0; i < NDIRECT; i++){
80101e5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e5e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e62:	7e b5                	jle    80101e19 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e6d:	85 c0                	test   %eax,%eax
80101e6f:	0f 84 aa 00 00 00    	je     80101f1f <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	83 ec 08             	sub    $0x8,%esp
80101e86:	52                   	push   %edx
80101e87:	50                   	push   %eax
80101e88:	e8 7c e3 ff ff       	call   80100209 <bread>
80101e8d:	83 c4 10             	add    $0x10,%esp
80101e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e96:	83 c0 5c             	add    $0x5c,%eax
80101e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ea3:	eb 3c                	jmp    80101ee1 <itrunc+0xdb>
      if(a[j])
80101ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb2:	01 d0                	add    %edx,%eax
80101eb4:	8b 00                	mov    (%eax),%eax
80101eb6:	85 c0                	test   %eax,%eax
80101eb8:	74 23                	je     80101edd <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec7:	01 d0                	add    %edx,%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ece:	8b 12                	mov    (%edx),%edx
80101ed0:	83 ec 08             	sub    $0x8,%esp
80101ed3:	50                   	push   %eax
80101ed4:	52                   	push   %edx
80101ed5:	e8 40 f7 ff ff       	call   8010161a <bfree>
80101eda:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101edd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee4:	83 f8 7f             	cmp    $0x7f,%eax
80101ee7:	76 bc                	jbe    80101ea5 <itrunc+0x9f>
    }
    brelse(bp);
80101ee9:	83 ec 0c             	sub    $0xc,%esp
80101eec:	ff 75 ec             	pushl  -0x14(%ebp)
80101eef:	e8 9f e3 ff ff       	call   80100293 <brelse>
80101ef4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f00:	8b 55 08             	mov    0x8(%ebp),%edx
80101f03:	8b 12                	mov    (%edx),%edx
80101f05:	83 ec 08             	sub    $0x8,%esp
80101f08:	50                   	push   %eax
80101f09:	52                   	push   %edx
80101f0a:	e8 0b f7 ff ff       	call   8010161a <bfree>
80101f0f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f1c:	00 00 00 
  }

  ip->size = 0;
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f29:	83 ec 0c             	sub    $0xc,%esp
80101f2c:	ff 75 08             	pushl  0x8(%ebp)
80101f2f:	e8 5f f9 ff ff       	call   80101893 <iupdate>
80101f34:	83 c4 10             	add    $0x10,%esp
}
80101f37:	90                   	nop
80101f38:	c9                   	leave  
80101f39:	c3                   	ret    

80101f3a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f3a:	f3 0f 1e fb          	endbr32 
80101f3e:	55                   	push   %ebp
80101f3f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 00                	mov    (%eax),%eax
80101f46:	89 c2                	mov    %eax,%edx
80101f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	8b 50 04             	mov    0x4(%eax),%edx
80101f54:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f57:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f61:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f64:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f71:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 50 58             	mov    0x58(%eax),%edx
80101f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f81:	90                   	nop
80101f82:	5d                   	pop    %ebp
80101f83:	c3                   	ret    

80101f84 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f84:	f3 0f 1e fb          	endbr32 
80101f88:	55                   	push   %ebp
80101f89:	89 e5                	mov    %esp,%ebp
80101f8b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f95:	66 83 f8 03          	cmp    $0x3,%ax
80101f99:	75 5c                	jne    80101ff7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa2:	66 85 c0             	test   %ax,%ax
80101fa5:	78 20                	js     80101fc7 <readi+0x43>
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fae:	66 83 f8 09          	cmp    $0x9,%ax
80101fb2:	7f 13                	jg     80101fc7 <readi+0x43>
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fbb:	98                   	cwtl   
80101fbc:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl   
80101fd9:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fe0:	8b 55 14             	mov    0x14(%ebp),%edx
80101fe3:	83 ec 04             	sub    $0x4,%esp
80101fe6:	52                   	push   %edx
80101fe7:	ff 75 0c             	pushl  0xc(%ebp)
80101fea:	ff 75 08             	pushl  0x8(%ebp)
80101fed:	ff d0                	call   *%eax
80101fef:	83 c4 10             	add    $0x10,%esp
80101ff2:	e9 e4 00 00 00       	jmp    801020db <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 40 58             	mov    0x58(%eax),%eax
80101ffd:	39 45 10             	cmp    %eax,0x10(%ebp)
80102000:	77 0d                	ja     8010200f <readi+0x8b>
80102002:	8b 55 10             	mov    0x10(%ebp),%edx
80102005:	8b 45 14             	mov    0x14(%ebp),%eax
80102008:	01 d0                	add    %edx,%eax
8010200a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010200d:	76 0a                	jbe    80102019 <readi+0x95>
    return -1;
8010200f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102014:	e9 c2 00 00 00       	jmp    801020db <readi+0x157>
  if(off + n > ip->size)
80102019:	8b 55 10             	mov    0x10(%ebp),%edx
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
8010201f:	01 c2                	add    %eax,%edx
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	8b 40 58             	mov    0x58(%eax),%eax
80102027:	39 c2                	cmp    %eax,%edx
80102029:	76 0c                	jbe    80102037 <readi+0xb3>
    n = ip->size - off;
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 40 58             	mov    0x58(%eax),%eax
80102031:	2b 45 10             	sub    0x10(%ebp),%eax
80102034:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102037:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010203e:	e9 89 00 00 00       	jmp    801020cc <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102043:	8b 45 10             	mov    0x10(%ebp),%eax
80102046:	c1 e8 09             	shr    $0x9,%eax
80102049:	83 ec 08             	sub    $0x8,%esp
8010204c:	50                   	push   %eax
8010204d:	ff 75 08             	pushl  0x8(%ebp)
80102050:	e8 8d fc ff ff       	call   80101ce2 <bmap>
80102055:	83 c4 10             	add    $0x10,%esp
80102058:	8b 55 08             	mov    0x8(%ebp),%edx
8010205b:	8b 12                	mov    (%edx),%edx
8010205d:	83 ec 08             	sub    $0x8,%esp
80102060:	50                   	push   %eax
80102061:	52                   	push   %edx
80102062:	e8 a2 e1 ff ff       	call   80100209 <bread>
80102067:	83 c4 10             	add    $0x10,%esp
8010206a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010206d:	8b 45 10             	mov    0x10(%ebp),%eax
80102070:	25 ff 01 00 00       	and    $0x1ff,%eax
80102075:	ba 00 02 00 00       	mov    $0x200,%edx
8010207a:	29 c2                	sub    %eax,%edx
8010207c:	8b 45 14             	mov    0x14(%ebp),%eax
8010207f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102082:	39 c2                	cmp    %eax,%edx
80102084:	0f 46 c2             	cmovbe %edx,%eax
80102087:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010208a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102090:	8b 45 10             	mov    0x10(%ebp),%eax
80102093:	25 ff 01 00 00       	and    $0x1ff,%eax
80102098:	01 d0                	add    %edx,%eax
8010209a:	83 ec 04             	sub    $0x4,%esp
8010209d:	ff 75 ec             	pushl  -0x14(%ebp)
801020a0:	50                   	push   %eax
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	e8 7c 2b 00 00       	call   80104c25 <memmove>
801020a9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020ac:	83 ec 0c             	sub    $0xc,%esp
801020af:	ff 75 f0             	pushl  -0x10(%ebp)
801020b2:	e8 dc e1 ff ff       	call   80100293 <brelse>
801020b7:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bd:	01 45 f4             	add    %eax,-0xc(%ebp)
801020c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c3:	01 45 10             	add    %eax,0x10(%ebp)
801020c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c9:	01 45 0c             	add    %eax,0xc(%ebp)
801020cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020cf:	3b 45 14             	cmp    0x14(%ebp),%eax
801020d2:	0f 82 6b ff ff ff    	jb     80102043 <readi+0xbf>
  }
  return n;
801020d8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020db:	c9                   	leave  
801020dc:	c3                   	ret    

801020dd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020dd:	f3 0f 1e fb          	endbr32 
801020e1:	55                   	push   %ebp
801020e2:	89 e5                	mov    %esp,%ebp
801020e4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020e7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ea:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020ee:	66 83 f8 03          	cmp    $0x3,%ax
801020f2:	75 5c                	jne    80102150 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020f4:	8b 45 08             	mov    0x8(%ebp),%eax
801020f7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020fb:	66 85 c0             	test   %ax,%ax
801020fe:	78 20                	js     80102120 <writei+0x43>
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102107:	66 83 f8 09          	cmp    $0x9,%ax
8010210b:	7f 13                	jg     80102120 <writei+0x43>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102114:	98                   	cwtl   
80102115:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl   
80102132:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102139:	8b 55 14             	mov    0x14(%ebp),%edx
8010213c:	83 ec 04             	sub    $0x4,%esp
8010213f:	52                   	push   %edx
80102140:	ff 75 0c             	pushl  0xc(%ebp)
80102143:	ff 75 08             	pushl  0x8(%ebp)
80102146:	ff d0                	call   *%eax
80102148:	83 c4 10             	add    $0x10,%esp
8010214b:	e9 15 01 00 00       	jmp    80102265 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 58             	mov    0x58(%eax),%eax
80102156:	39 45 10             	cmp    %eax,0x10(%ebp)
80102159:	77 0d                	ja     80102168 <writei+0x8b>
8010215b:	8b 55 10             	mov    0x10(%ebp),%edx
8010215e:	8b 45 14             	mov    0x14(%ebp),%eax
80102161:	01 d0                	add    %edx,%eax
80102163:	39 45 10             	cmp    %eax,0x10(%ebp)
80102166:	76 0a                	jbe    80102172 <writei+0x95>
    return -1;
80102168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216d:	e9 f3 00 00 00       	jmp    80102265 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102172:	8b 55 10             	mov    0x10(%ebp),%edx
80102175:	8b 45 14             	mov    0x14(%ebp),%eax
80102178:	01 d0                	add    %edx,%eax
8010217a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217f:	76 0a                	jbe    8010218b <writei+0xae>
    return -1;
80102181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102186:	e9 da 00 00 00       	jmp    80102265 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102192:	e9 97 00 00 00       	jmp    8010222e <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102197:	8b 45 10             	mov    0x10(%ebp),%eax
8010219a:	c1 e8 09             	shr    $0x9,%eax
8010219d:	83 ec 08             	sub    $0x8,%esp
801021a0:	50                   	push   %eax
801021a1:	ff 75 08             	pushl  0x8(%ebp)
801021a4:	e8 39 fb ff ff       	call   80101ce2 <bmap>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	8b 55 08             	mov    0x8(%ebp),%edx
801021af:	8b 12                	mov    (%edx),%edx
801021b1:	83 ec 08             	sub    $0x8,%esp
801021b4:	50                   	push   %eax
801021b5:	52                   	push   %edx
801021b6:	e8 4e e0 ff ff       	call   80100209 <bread>
801021bb:	83 c4 10             	add    $0x10,%esp
801021be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021c1:	8b 45 10             	mov    0x10(%ebp),%eax
801021c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c9:	ba 00 02 00 00       	mov    $0x200,%edx
801021ce:	29 c2                	sub    %eax,%edx
801021d0:	8b 45 14             	mov    0x14(%ebp),%eax
801021d3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021d6:	39 c2                	cmp    %eax,%edx
801021d8:	0f 46 c2             	cmovbe %edx,%eax
801021db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e1:	8d 50 5c             	lea    0x5c(%eax),%edx
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ec:	01 d0                	add    %edx,%eax
801021ee:	83 ec 04             	sub    $0x4,%esp
801021f1:	ff 75 ec             	pushl  -0x14(%ebp)
801021f4:	ff 75 0c             	pushl  0xc(%ebp)
801021f7:	50                   	push   %eax
801021f8:	e8 28 2a 00 00       	call   80104c25 <memmove>
801021fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 af 11 00 00       	call   801033ba <log_write>
8010220b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	ff 75 f0             	pushl  -0x10(%ebp)
80102214:	e8 7a e0 ff ff       	call   80100293 <brelse>
80102219:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010221c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102225:	01 45 10             	add    %eax,0x10(%ebp)
80102228:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222b:	01 45 0c             	add    %eax,0xc(%ebp)
8010222e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102231:	3b 45 14             	cmp    0x14(%ebp),%eax
80102234:	0f 82 5d ff ff ff    	jb     80102197 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010223a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010223e:	74 22                	je     80102262 <writei+0x185>
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	8b 40 58             	mov    0x58(%eax),%eax
80102246:	39 45 10             	cmp    %eax,0x10(%ebp)
80102249:	76 17                	jbe    80102262 <writei+0x185>
    ip->size = off;
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	8b 55 10             	mov    0x10(%ebp),%edx
80102251:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102254:	83 ec 0c             	sub    $0xc,%esp
80102257:	ff 75 08             	pushl  0x8(%ebp)
8010225a:	e8 34 f6 ff ff       	call   80101893 <iupdate>
8010225f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102262:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102265:	c9                   	leave  
80102266:	c3                   	ret    

80102267 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102267:	f3 0f 1e fb          	endbr32 
8010226b:	55                   	push   %ebp
8010226c:	89 e5                	mov    %esp,%ebp
8010226e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102271:	83 ec 04             	sub    $0x4,%esp
80102274:	6a 0e                	push   $0xe
80102276:	ff 75 0c             	pushl  0xc(%ebp)
80102279:	ff 75 08             	pushl  0x8(%ebp)
8010227c:	e8 42 2a 00 00       	call   80104cc3 <strncmp>
80102281:	83 c4 10             	add    $0x10,%esp
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102286:	f3 0f 1e fb          	endbr32 
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102290:	8b 45 08             	mov    0x8(%ebp),%eax
80102293:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102297:	66 83 f8 01          	cmp    $0x1,%ax
8010229b:	74 0d                	je     801022aa <dirlookup+0x24>
    panic("dirlookup not DIR");
8010229d:	83 ec 0c             	sub    $0xc,%esp
801022a0:	68 5d a6 10 80       	push   $0x8010a65d
801022a5:	e8 1b e3 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b1:	eb 7b                	jmp    8010232e <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b3:	6a 10                	push   $0x10
801022b5:	ff 75 f4             	pushl  -0xc(%ebp)
801022b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bb:	50                   	push   %eax
801022bc:	ff 75 08             	pushl  0x8(%ebp)
801022bf:	e8 c0 fc ff ff       	call   80101f84 <readi>
801022c4:	83 c4 10             	add    $0x10,%esp
801022c7:	83 f8 10             	cmp    $0x10,%eax
801022ca:	74 0d                	je     801022d9 <dirlookup+0x53>
      panic("dirlookup read");
801022cc:	83 ec 0c             	sub    $0xc,%esp
801022cf:	68 6f a6 10 80       	push   $0x8010a66f
801022d4:	e8 ec e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801022d9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022dd:	66 85 c0             	test   %ax,%ax
801022e0:	74 47                	je     80102329 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022e2:	83 ec 08             	sub    $0x8,%esp
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	83 c0 02             	add    $0x2,%eax
801022eb:	50                   	push   %eax
801022ec:	ff 75 0c             	pushl  0xc(%ebp)
801022ef:	e8 73 ff ff ff       	call   80102267 <namecmp>
801022f4:	83 c4 10             	add    $0x10,%esp
801022f7:	85 c0                	test   %eax,%eax
801022f9:	75 2f                	jne    8010232a <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801022fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022ff:	74 08                	je     80102309 <dirlookup+0x83>
        *poff = off;
80102301:	8b 45 10             	mov    0x10(%ebp),%eax
80102304:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102307:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102309:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010230d:	0f b7 c0             	movzwl %ax,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 00                	mov    (%eax),%eax
80102318:	83 ec 08             	sub    $0x8,%esp
8010231b:	ff 75 f0             	pushl  -0x10(%ebp)
8010231e:	50                   	push   %eax
8010231f:	e8 34 f6 ff ff       	call   80101958 <iget>
80102324:	83 c4 10             	add    $0x10,%esp
80102327:	eb 19                	jmp    80102342 <dirlookup+0xbc>
      continue;
80102329:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010232a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010232e:	8b 45 08             	mov    0x8(%ebp),%eax
80102331:	8b 40 58             	mov    0x58(%eax),%eax
80102334:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102337:	0f 82 76 ff ff ff    	jb     801022b3 <dirlookup+0x2d>
    }
  }

  return 0;
8010233d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102342:	c9                   	leave  
80102343:	c3                   	ret    

80102344 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102344:	f3 0f 1e fb          	endbr32 
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010234e:	83 ec 04             	sub    $0x4,%esp
80102351:	6a 00                	push   $0x0
80102353:	ff 75 0c             	pushl  0xc(%ebp)
80102356:	ff 75 08             	pushl  0x8(%ebp)
80102359:	e8 28 ff ff ff       	call   80102286 <dirlookup>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102368:	74 18                	je     80102382 <dirlink+0x3e>
    iput(ip);
8010236a:	83 ec 0c             	sub    $0xc,%esp
8010236d:	ff 75 f0             	pushl  -0x10(%ebp)
80102370:	e8 70 f8 ff ff       	call   80101be5 <iput>
80102375:	83 c4 10             	add    $0x10,%esp
    return -1;
80102378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010237d:	e9 9c 00 00 00       	jmp    8010241e <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102389:	eb 39                	jmp    801023c4 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	6a 10                	push   $0x10
80102390:	50                   	push   %eax
80102391:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102394:	50                   	push   %eax
80102395:	ff 75 08             	pushl  0x8(%ebp)
80102398:	e8 e7 fb ff ff       	call   80101f84 <readi>
8010239d:	83 c4 10             	add    $0x10,%esp
801023a0:	83 f8 10             	cmp    $0x10,%eax
801023a3:	74 0d                	je     801023b2 <dirlink+0x6e>
      panic("dirlink read");
801023a5:	83 ec 0c             	sub    $0xc,%esp
801023a8:	68 7e a6 10 80       	push   $0x8010a67e
801023ad:	e8 13 e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023b2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b6:	66 85 c0             	test   %ax,%ax
801023b9:	74 18                	je     801023d3 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023be:	83 c0 10             	add    $0x10,%eax
801023c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c4:	8b 45 08             	mov    0x8(%ebp),%eax
801023c7:	8b 50 58             	mov    0x58(%eax),%edx
801023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cd:	39 c2                	cmp    %eax,%edx
801023cf:	77 ba                	ja     8010238b <dirlink+0x47>
801023d1:	eb 01                	jmp    801023d4 <dirlink+0x90>
      break;
801023d3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	6a 0e                	push   $0xe
801023d9:	ff 75 0c             	pushl  0xc(%ebp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	83 c0 02             	add    $0x2,%eax
801023e2:	50                   	push   %eax
801023e3:	e8 35 29 00 00       	call   80104d1d <strncpy>
801023e8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023eb:	8b 45 10             	mov    0x10(%ebp),%eax
801023ee:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f5:	6a 10                	push   $0x10
801023f7:	50                   	push   %eax
801023f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fb:	50                   	push   %eax
801023fc:	ff 75 08             	pushl  0x8(%ebp)
801023ff:	e8 d9 fc ff ff       	call   801020dd <writei>
80102404:	83 c4 10             	add    $0x10,%esp
80102407:	83 f8 10             	cmp    $0x10,%eax
8010240a:	74 0d                	je     80102419 <dirlink+0xd5>
    panic("dirlink");
8010240c:	83 ec 0c             	sub    $0xc,%esp
8010240f:	68 8b a6 10 80       	push   $0x8010a68b
80102414:	e8 ac e1 ff ff       	call   801005c5 <panic>

  return 0;
80102419:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241e:	c9                   	leave  
8010241f:	c3                   	ret    

80102420 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102420:	f3 0f 1e fb          	endbr32 
80102424:	55                   	push   %ebp
80102425:	89 e5                	mov    %esp,%ebp
80102427:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010242a:	eb 04                	jmp    80102430 <skipelem+0x10>
    path++;
8010242c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	0f b6 00             	movzbl (%eax),%eax
80102436:	3c 2f                	cmp    $0x2f,%al
80102438:	74 f2                	je     8010242c <skipelem+0xc>
  if(*path == 0)
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	0f b6 00             	movzbl (%eax),%eax
80102440:	84 c0                	test   %al,%al
80102442:	75 07                	jne    8010244b <skipelem+0x2b>
    return 0;
80102444:	b8 00 00 00 00       	mov    $0x0,%eax
80102449:	eb 77                	jmp    801024c2 <skipelem+0xa2>
  s = path;
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102451:	eb 04                	jmp    80102457 <skipelem+0x37>
    path++;
80102453:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	0f b6 00             	movzbl (%eax),%eax
8010245d:	3c 2f                	cmp    $0x2f,%al
8010245f:	74 0a                	je     8010246b <skipelem+0x4b>
80102461:	8b 45 08             	mov    0x8(%ebp),%eax
80102464:	0f b6 00             	movzbl (%eax),%eax
80102467:	84 c0                	test   %al,%al
80102469:	75 e8                	jne    80102453 <skipelem+0x33>
  len = path - s;
8010246b:	8b 45 08             	mov    0x8(%ebp),%eax
8010246e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102471:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102474:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102478:	7e 15                	jle    8010248f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010247a:	83 ec 04             	sub    $0x4,%esp
8010247d:	6a 0e                	push   $0xe
8010247f:	ff 75 f4             	pushl  -0xc(%ebp)
80102482:	ff 75 0c             	pushl  0xc(%ebp)
80102485:	e8 9b 27 00 00       	call   80104c25 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 84 27 00 00       	call   80104c25 <memmove>
801024a1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024aa:	01 d0                	add    %edx,%eax
801024ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024af:	eb 04                	jmp    801024b5 <skipelem+0x95>
    path++;
801024b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	0f b6 00             	movzbl (%eax),%eax
801024bb:	3c 2f                	cmp    $0x2f,%al
801024bd:	74 f2                	je     801024b1 <skipelem+0x91>
  return path;
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024c2:	c9                   	leave  
801024c3:	c3                   	ret    

801024c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c4:	f3 0f 1e fb          	endbr32 
801024c8:	55                   	push   %ebp
801024c9:	89 e5                	mov    %esp,%ebp
801024cb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	0f b6 00             	movzbl (%eax),%eax
801024d4:	3c 2f                	cmp    $0x2f,%al
801024d6:	75 17                	jne    801024ef <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024d8:	83 ec 08             	sub    $0x8,%esp
801024db:	6a 01                	push   $0x1
801024dd:	6a 01                	push   $0x1
801024df:	e8 74 f4 ff ff       	call   80101958 <iget>
801024e4:	83 c4 10             	add    $0x10,%esp
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ea:	e9 ba 00 00 00       	jmp    801025a9 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024ef:	e8 b5 16 00 00       	call   80103ba9 <myproc>
801024f4:	8b 40 68             	mov    0x68(%eax),%eax
801024f7:	83 ec 0c             	sub    $0xc,%esp
801024fa:	50                   	push   %eax
801024fb:	e8 3e f5 ff ff       	call   80101a3e <idup>
80102500:	83 c4 10             	add    $0x10,%esp
80102503:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102506:	e9 9e 00 00 00       	jmp    801025a9 <namex+0xe5>
    ilock(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	pushl  -0xc(%ebp)
80102511:	e8 66 f5 ff ff       	call   80101a7c <ilock>
80102516:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102520:	66 83 f8 01          	cmp    $0x1,%ax
80102524:	74 18                	je     8010253e <namex+0x7a>
      iunlockput(ip);
80102526:	83 ec 0c             	sub    $0xc,%esp
80102529:	ff 75 f4             	pushl  -0xc(%ebp)
8010252c:	e8 88 f7 ff ff       	call   80101cb9 <iunlockput>
80102531:	83 c4 10             	add    $0x10,%esp
      return 0;
80102534:	b8 00 00 00 00       	mov    $0x0,%eax
80102539:	e9 a7 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010253e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102542:	74 20                	je     80102564 <namex+0xa0>
80102544:	8b 45 08             	mov    0x8(%ebp),%eax
80102547:	0f b6 00             	movzbl (%eax),%eax
8010254a:	84 c0                	test   %al,%al
8010254c:	75 16                	jne    80102564 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010254e:	83 ec 0c             	sub    $0xc,%esp
80102551:	ff 75 f4             	pushl  -0xc(%ebp)
80102554:	e8 3a f6 ff ff       	call   80101b93 <iunlock>
80102559:	83 c4 10             	add    $0x10,%esp
      return ip;
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	e9 81 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102564:	83 ec 04             	sub    $0x4,%esp
80102567:	6a 00                	push   $0x0
80102569:	ff 75 10             	pushl  0x10(%ebp)
8010256c:	ff 75 f4             	pushl  -0xc(%ebp)
8010256f:	e8 12 fd ff ff       	call   80102286 <dirlookup>
80102574:	83 c4 10             	add    $0x10,%esp
80102577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010257a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010257e:	75 15                	jne    80102595 <namex+0xd1>
      iunlockput(ip);
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	ff 75 f4             	pushl  -0xc(%ebp)
80102586:	e8 2e f7 ff ff       	call   80101cb9 <iunlockput>
8010258b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010258e:	b8 00 00 00 00       	mov    $0x0,%eax
80102593:	eb 50                	jmp    801025e5 <namex+0x121>
    }
    iunlockput(ip);
80102595:	83 ec 0c             	sub    $0xc,%esp
80102598:	ff 75 f4             	pushl  -0xc(%ebp)
8010259b:	e8 19 f7 ff ff       	call   80101cb9 <iunlockput>
801025a0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025a9:	83 ec 08             	sub    $0x8,%esp
801025ac:	ff 75 10             	pushl  0x10(%ebp)
801025af:	ff 75 08             	pushl  0x8(%ebp)
801025b2:	e8 69 fe ff ff       	call   80102420 <skipelem>
801025b7:	83 c4 10             	add    $0x10,%esp
801025ba:	89 45 08             	mov    %eax,0x8(%ebp)
801025bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c1:	0f 85 44 ff ff ff    	jne    8010250b <namex+0x47>
  }
  if(nameiparent){
801025c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025cb:	74 15                	je     801025e2 <namex+0x11e>
    iput(ip);
801025cd:	83 ec 0c             	sub    $0xc,%esp
801025d0:	ff 75 f4             	pushl  -0xc(%ebp)
801025d3:	e8 0d f6 ff ff       	call   80101be5 <iput>
801025d8:	83 c4 10             	add    $0x10,%esp
    return 0;
801025db:	b8 00 00 00 00       	mov    $0x0,%eax
801025e0:	eb 03                	jmp    801025e5 <namex+0x121>
  }
  return ip;
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025e5:	c9                   	leave  
801025e6:	c3                   	ret    

801025e7 <namei>:

struct inode*
namei(char *path)
{
801025e7:	f3 0f 1e fb          	endbr32 
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025f1:	83 ec 04             	sub    $0x4,%esp
801025f4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025f7:	50                   	push   %eax
801025f8:	6a 00                	push   $0x0
801025fa:	ff 75 08             	pushl  0x8(%ebp)
801025fd:	e8 c2 fe ff ff       	call   801024c4 <namex>
80102602:	83 c4 10             	add    $0x10,%esp
}
80102605:	c9                   	leave  
80102606:	c3                   	ret    

80102607 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102607:	f3 0f 1e fb          	endbr32 
8010260b:	55                   	push   %ebp
8010260c:	89 e5                	mov    %esp,%ebp
8010260e:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102611:	83 ec 04             	sub    $0x4,%esp
80102614:	ff 75 0c             	pushl  0xc(%ebp)
80102617:	6a 01                	push   $0x1
80102619:	ff 75 08             	pushl  0x8(%ebp)
8010261c:	e8 a3 fe ff ff       	call   801024c4 <namex>
80102621:	83 c4 10             	add    $0x10,%esp
}
80102624:	c9                   	leave  
80102625:	c3                   	ret    

80102626 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102626:	f3 0f 1e fb          	endbr32 
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010262d:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102632:	8b 55 08             	mov    0x8(%ebp),%edx
80102635:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102637:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010263c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010263f:	5d                   	pop    %ebp
80102640:	c3                   	ret    

80102641 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102641:	f3 0f 1e fb          	endbr32 
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102648:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010264d:	8b 55 08             	mov    0x8(%ebp),%edx
80102650:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102652:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102657:	8b 55 0c             	mov    0xc(%ebp),%edx
8010265a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010265d:	90                   	nop
8010265e:	5d                   	pop    %ebp
8010265f:	c3                   	ret    

80102660 <ioapicinit>:

void
ioapicinit(void)
{
80102660:	f3 0f 1e fb          	endbr32 
80102664:	55                   	push   %ebp
80102665:	89 e5                	mov    %esp,%ebp
80102667:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010266a:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
80102671:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102674:	6a 01                	push   $0x1
80102676:	e8 ab ff ff ff       	call   80102626 <ioapicread>
8010267b:	83 c4 04             	add    $0x4,%esp
8010267e:	c1 e8 10             	shr    $0x10,%eax
80102681:	25 ff 00 00 00       	and    $0xff,%eax
80102686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102689:	6a 00                	push   $0x0
8010268b:	e8 96 ff ff ff       	call   80102626 <ioapicread>
80102690:	83 c4 04             	add    $0x4,%esp
80102693:	c1 e8 18             	shr    $0x18,%eax
80102696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102699:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 94 a6 10 80       	push   $0x8010a694
801026b0:	e8 57 dd ff ff       	call   8010040c <cprintf>
801026b5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026bf:	eb 3f                	jmp    80102700 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c4:	83 c0 20             	add    $0x20,%eax
801026c7:	0d 00 00 01 00       	or     $0x10000,%eax
801026cc:	89 c2                	mov    %eax,%edx
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	83 c0 08             	add    $0x8,%eax
801026d4:	01 c0                	add    %eax,%eax
801026d6:	83 ec 08             	sub    $0x8,%esp
801026d9:	52                   	push   %edx
801026da:	50                   	push   %eax
801026db:	e8 61 ff ff ff       	call   80102641 <ioapicwrite>
801026e0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801026e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e6:	83 c0 08             	add    $0x8,%eax
801026e9:	01 c0                	add    %eax,%eax
801026eb:	83 c0 01             	add    $0x1,%eax
801026ee:	83 ec 08             	sub    $0x8,%esp
801026f1:	6a 00                	push   $0x0
801026f3:	50                   	push   %eax
801026f4:	e8 48 ff ff ff       	call   80102641 <ioapicwrite>
801026f9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
801026fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102703:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102706:	7e b9                	jle    801026c1 <ioapicinit+0x61>
  }
}
80102708:	90                   	nop
80102709:	90                   	nop
8010270a:	c9                   	leave  
8010270b:	c3                   	ret    

8010270c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010270c:	f3 0f 1e fb          	endbr32 
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102713:	8b 45 08             	mov    0x8(%ebp),%eax
80102716:	83 c0 20             	add    $0x20,%eax
80102719:	89 c2                	mov    %eax,%edx
8010271b:	8b 45 08             	mov    0x8(%ebp),%eax
8010271e:	83 c0 08             	add    $0x8,%eax
80102721:	01 c0                	add    %eax,%eax
80102723:	52                   	push   %edx
80102724:	50                   	push   %eax
80102725:	e8 17 ff ff ff       	call   80102641 <ioapicwrite>
8010272a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010272d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102730:	c1 e0 18             	shl    $0x18,%eax
80102733:	89 c2                	mov    %eax,%edx
80102735:	8b 45 08             	mov    0x8(%ebp),%eax
80102738:	83 c0 08             	add    $0x8,%eax
8010273b:	01 c0                	add    %eax,%eax
8010273d:	83 c0 01             	add    $0x1,%eax
80102740:	52                   	push   %edx
80102741:	50                   	push   %eax
80102742:	e8 fa fe ff ff       	call   80102641 <ioapicwrite>
80102747:	83 c4 08             	add    $0x8,%esp
}
8010274a:	90                   	nop
8010274b:	c9                   	leave  
8010274c:	c3                   	ret    

8010274d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010274d:	f3 0f 1e fb          	endbr32 
80102751:	55                   	push   %ebp
80102752:	89 e5                	mov    %esp,%ebp
80102754:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	68 c6 a6 10 80       	push   $0x8010a6c6
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 40 21 00 00       	call   801048a9 <initlock>
80102769:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010276c:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
80102773:	00 00 00 
  freerange(vstart, vend);
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	ff 75 0c             	pushl  0xc(%ebp)
8010277c:	ff 75 08             	pushl  0x8(%ebp)
8010277f:	e8 2e 00 00 00       	call   801027b2 <freerange>
80102784:	83 c4 10             	add    $0x10,%esp
}
80102787:	90                   	nop
80102788:	c9                   	leave  
80102789:	c3                   	ret    

8010278a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010278a:	f3 0f 1e fb          	endbr32 
8010278e:	55                   	push   %ebp
8010278f:	89 e5                	mov    %esp,%ebp
80102791:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	ff 75 0c             	pushl  0xc(%ebp)
8010279a:	ff 75 08             	pushl  0x8(%ebp)
8010279d:	e8 10 00 00 00       	call   801027b2 <freerange>
801027a2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027a5:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
801027ac:	00 00 00 
}
801027af:	90                   	nop
801027b0:	c9                   	leave  
801027b1:	c3                   	ret    

801027b2 <freerange>:

void
freerange(void *vstart, void *vend)
{
801027b2:	f3 0f 1e fb          	endbr32 
801027b6:	55                   	push   %ebp
801027b7:	89 e5                	mov    %esp,%ebp
801027b9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027bc:	8b 45 08             	mov    0x8(%ebp),%eax
801027bf:	05 ff 0f 00 00       	add    $0xfff,%eax
801027c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801027c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027cc:	eb 15                	jmp    801027e3 <freerange+0x31>
    kfree(p);
801027ce:	83 ec 0c             	sub    $0xc,%esp
801027d1:	ff 75 f4             	pushl  -0xc(%ebp)
801027d4:	e8 1b 00 00 00       	call   801027f4 <kfree>
801027d9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e6:	05 00 10 00 00       	add    $0x1000,%eax
801027eb:	39 45 0c             	cmp    %eax,0xc(%ebp)
801027ee:	73 de                	jae    801027ce <freerange+0x1c>
}
801027f0:	90                   	nop
801027f1:	90                   	nop
801027f2:	c9                   	leave  
801027f3:	c3                   	ret    

801027f4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801027f4:	f3 0f 1e fb          	endbr32 
801027f8:	55                   	push   %ebp
801027f9:	89 e5                	mov    %esp,%ebp
801027fb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801027fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102801:	25 ff 0f 00 00       	and    $0xfff,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 18                	jne    80102822 <kfree+0x2e>
8010280a:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102811:	72 0f                	jb     80102822 <kfree+0x2e>
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	05 00 00 00 80       	add    $0x80000000,%eax
8010281b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102820:	76 0d                	jbe    8010282f <kfree+0x3b>
    panic("kfree");
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 cb a6 10 80       	push   $0x8010a6cb
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	pushl  0x8(%ebp)
8010283c:	e8 1d 23 00 00       	call   80104b5e <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 75 20 00 00       	call   801048cf <acquire>
8010285a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102863:	8b 15 18 54 19 80    	mov    0x80195418,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102876:	a1 14 54 19 80       	mov    0x80195414,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	74 10                	je     8010288f <kfree+0x9b>
    release(&kmem.lock);
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 e0 53 19 80       	push   $0x801953e0
80102887:	e8 b5 20 00 00       	call   80104941 <release>
8010288c:	83 c4 10             	add    $0x10,%esp
}
8010288f:	90                   	nop
80102890:	c9                   	leave  
80102891:	c3                   	ret    

80102892 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102892:	f3 0f 1e fb          	endbr32 
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010289c:	a1 14 54 19 80       	mov    0x80195414,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 10                	je     801028b5 <kalloc+0x23>
    acquire(&kmem.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 e0 53 19 80       	push   $0x801953e0
801028ad:	e8 1d 20 00 00       	call   801048cf <acquire>
801028b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028b5:	a1 18 54 19 80       	mov    0x80195418,%eax
801028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028c1:	74 0a                	je     801028cd <kalloc+0x3b>
    kmem.freelist = r->next;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028cd:	a1 14 54 19 80       	mov    0x80195414,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	74 10                	je     801028e6 <kalloc+0x54>
    release(&kmem.lock);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	68 e0 53 19 80       	push   $0x801953e0
801028de:	e8 5e 20 00 00       	call   80104941 <release>
801028e3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801028e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028e9:	c9                   	leave  
801028ea:	c3                   	ret    

801028eb <inb>:
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 14             	sub    $0x14,%esp
801028f1:	8b 45 08             	mov    0x8(%ebp),%eax
801028f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028fc:	89 c2                	mov    %eax,%edx
801028fe:	ec                   	in     (%dx),%al
801028ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102902:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102906:	c9                   	leave  
80102907:	c3                   	ret    

80102908 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102908:	f3 0f 1e fb          	endbr32 
8010290c:	55                   	push   %ebp
8010290d:	89 e5                	mov    %esp,%ebp
8010290f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102912:	6a 64                	push   $0x64
80102914:	e8 d2 ff ff ff       	call   801028eb <inb>
80102919:	83 c4 04             	add    $0x4,%esp
8010291c:	0f b6 c0             	movzbl %al,%eax
8010291f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102925:	83 e0 01             	and    $0x1,%eax
80102928:	85 c0                	test   %eax,%eax
8010292a:	75 0a                	jne    80102936 <kbdgetc+0x2e>
    return -1;
8010292c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102931:	e9 23 01 00 00       	jmp    80102a59 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102936:	6a 60                	push   $0x60
80102938:	e8 ae ff ff ff       	call   801028eb <inb>
8010293d:	83 c4 04             	add    $0x4,%esp
80102940:	0f b6 c0             	movzbl %al,%eax
80102943:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102946:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010294d:	75 17                	jne    80102966 <kbdgetc+0x5e>
    shift |= E0ESC;
8010294f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102954:	83 c8 40             	or     $0x40,%eax
80102957:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010295c:	b8 00 00 00 00       	mov    $0x0,%eax
80102961:	e9 f3 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(data & 0x80){
80102966:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102969:	25 80 00 00 00       	and    $0x80,%eax
8010296e:	85 c0                	test   %eax,%eax
80102970:	74 45                	je     801029b7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102972:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102977:	83 e0 40             	and    $0x40,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	75 08                	jne    80102986 <kbdgetc+0x7e>
8010297e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102981:	83 e0 7f             	and    $0x7f,%eax
80102984:	eb 03                	jmp    80102989 <kbdgetc+0x81>
80102986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102989:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010298c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010298f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102994:	0f b6 00             	movzbl (%eax),%eax
80102997:	83 c8 40             	or     $0x40,%eax
8010299a:	0f b6 c0             	movzbl %al,%eax
8010299d:	f7 d0                	not    %eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029a6:	21 d0                	and    %edx,%eax
801029a8:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ad:	b8 00 00 00 00       	mov    $0x0,%eax
801029b2:	e9 a2 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029b7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029bc:	83 e0 40             	and    $0x40,%eax
801029bf:	85 c0                	test   %eax,%eax
801029c1:	74 14                	je     801029d7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029c3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029ca:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029cf:	83 e0 bf             	and    $0xffffffbf,%eax
801029d2:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
801029d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029da:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029df:	0f b6 00             	movzbl (%eax),%eax
801029e2:	0f b6 d0             	movzbl %al,%edx
801029e5:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029ea:	09 d0                	or     %edx,%eax
801029ec:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
801029f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f4:	05 20 d1 10 80       	add    $0x8010d120,%eax
801029f9:	0f b6 00             	movzbl (%eax),%eax
801029fc:	0f b6 d0             	movzbl %al,%edx
801029ff:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a04:	31 d0                	xor    %edx,%eax
80102a06:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a0b:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a10:	83 e0 03             	and    $0x3,%eax
80102a13:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a1d:	01 d0                	add    %edx,%eax
80102a1f:	0f b6 00             	movzbl (%eax),%eax
80102a22:	0f b6 c0             	movzbl %al,%eax
80102a25:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a28:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a2d:	83 e0 08             	and    $0x8,%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	74 22                	je     80102a56 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a34:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a38:	76 0c                	jbe    80102a46 <kbdgetc+0x13e>
80102a3a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a3e:	77 06                	ja     80102a46 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a40:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a44:	eb 10                	jmp    80102a56 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a46:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a4a:	76 0a                	jbe    80102a56 <kbdgetc+0x14e>
80102a4c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a50:	77 04                	ja     80102a56 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a52:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a56:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a59:	c9                   	leave  
80102a5a:	c3                   	ret    

80102a5b <kbdintr>:

void
kbdintr(void)
{
80102a5b:	f3 0f 1e fb          	endbr32 
80102a5f:	55                   	push   %ebp
80102a60:	89 e5                	mov    %esp,%ebp
80102a62:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 08 29 10 80       	push   $0x80102908
80102a6d:	e8 8e dd ff ff       	call   80100800 <consoleintr>
80102a72:	83 c4 10             	add    $0x10,%esp
}
80102a75:	90                   	nop
80102a76:	c9                   	leave  
80102a77:	c3                   	ret    

80102a78 <inb>:
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
80102a7b:	83 ec 14             	sub    $0x14,%esp
80102a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a81:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a85:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102a89:	89 c2                	mov    %eax,%edx
80102a8b:	ec                   	in     (%dx),%al
80102a8c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102a8f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102a93:	c9                   	leave  
80102a94:	c3                   	ret    

80102a95 <outb>:
{
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
80102a98:	83 ec 08             	sub    $0x8,%esp
80102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102aa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102aa5:	89 d0                	mov    %edx,%eax
80102aa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aaa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102aae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ab2:	ee                   	out    %al,(%dx)
}
80102ab3:	90                   	nop
80102ab4:	c9                   	leave  
80102ab5:	c3                   	ret    

80102ab6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ab6:	f3 0f 1e fb          	endbr32 
80102aba:	55                   	push   %ebp
80102abb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102abd:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac5:	c1 e2 02             	shl    $0x2,%edx
80102ac8:	01 c2                	add    %eax,%edx
80102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102acd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102acf:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ad4:	83 c0 20             	add    $0x20,%eax
80102ad7:	8b 00                	mov    (%eax),%eax
}
80102ad9:	90                   	nop
80102ada:	5d                   	pop    %ebp
80102adb:	c3                   	ret    

80102adc <lapicinit>:

void
lapicinit(void)
{
80102adc:	f3 0f 1e fb          	endbr32 
80102ae0:	55                   	push   %ebp
80102ae1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ae3:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ae8:	85 c0                	test   %eax,%eax
80102aea:	0f 84 0c 01 00 00    	je     80102bfc <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102af0:	68 3f 01 00 00       	push   $0x13f
80102af5:	6a 3c                	push   $0x3c
80102af7:	e8 ba ff ff ff       	call   80102ab6 <lapicw>
80102afc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102aff:	6a 0b                	push   $0xb
80102b01:	68 f8 00 00 00       	push   $0xf8
80102b06:	e8 ab ff ff ff       	call   80102ab6 <lapicw>
80102b0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b0e:	68 20 00 02 00       	push   $0x20020
80102b13:	68 c8 00 00 00       	push   $0xc8
80102b18:	e8 99 ff ff ff       	call   80102ab6 <lapicw>
80102b1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b20:	68 80 96 98 00       	push   $0x989680
80102b25:	68 e0 00 00 00       	push   $0xe0
80102b2a:	e8 87 ff ff ff       	call   80102ab6 <lapicw>
80102b2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b32:	68 00 00 01 00       	push   $0x10000
80102b37:	68 d4 00 00 00       	push   $0xd4
80102b3c:	e8 75 ff ff ff       	call   80102ab6 <lapicw>
80102b41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b44:	68 00 00 01 00       	push   $0x10000
80102b49:	68 d8 00 00 00       	push   $0xd8
80102b4e:	e8 63 ff ff ff       	call   80102ab6 <lapicw>
80102b53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b56:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b5b:	83 c0 30             	add    $0x30,%eax
80102b5e:	8b 00                	mov    (%eax),%eax
80102b60:	c1 e8 10             	shr    $0x10,%eax
80102b63:	25 fc 00 00 00       	and    $0xfc,%eax
80102b68:	85 c0                	test   %eax,%eax
80102b6a:	74 12                	je     80102b7e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102b6c:	68 00 00 01 00       	push   $0x10000
80102b71:	68 d0 00 00 00       	push   $0xd0
80102b76:	e8 3b ff ff ff       	call   80102ab6 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102b7e:	6a 33                	push   $0x33
80102b80:	68 dc 00 00 00       	push   $0xdc
80102b85:	e8 2c ff ff ff       	call   80102ab6 <lapicw>
80102b8a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102b8d:	6a 00                	push   $0x0
80102b8f:	68 a0 00 00 00       	push   $0xa0
80102b94:	e8 1d ff ff ff       	call   80102ab6 <lapicw>
80102b99:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102b9c:	6a 00                	push   $0x0
80102b9e:	68 a0 00 00 00       	push   $0xa0
80102ba3:	e8 0e ff ff ff       	call   80102ab6 <lapicw>
80102ba8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102bab:	6a 00                	push   $0x0
80102bad:	6a 2c                	push   $0x2c
80102baf:	e8 02 ff ff ff       	call   80102ab6 <lapicw>
80102bb4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102bb7:	6a 00                	push   $0x0
80102bb9:	68 c4 00 00 00       	push   $0xc4
80102bbe:	e8 f3 fe ff ff       	call   80102ab6 <lapicw>
80102bc3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102bc6:	68 00 85 08 00       	push   $0x88500
80102bcb:	68 c0 00 00 00       	push   $0xc0
80102bd0:	e8 e1 fe ff ff       	call   80102ab6 <lapicw>
80102bd5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102bd8:	90                   	nop
80102bd9:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bde:	05 00 03 00 00       	add    $0x300,%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	25 00 10 00 00       	and    $0x1000,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 eb                	jne    80102bd9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102bee:	6a 00                	push   $0x0
80102bf0:	6a 20                	push   $0x20
80102bf2:	e8 bf fe ff ff       	call   80102ab6 <lapicw>
80102bf7:	83 c4 08             	add    $0x8,%esp
80102bfa:	eb 01                	jmp    80102bfd <lapicinit+0x121>
    return;
80102bfc:	90                   	nop
}
80102bfd:	c9                   	leave  
80102bfe:	c3                   	ret    

80102bff <lapicid>:

int
lapicid(void)
{
80102bff:	f3 0f 1e fb          	endbr32 
80102c03:	55                   	push   %ebp
80102c04:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c06:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 07                	jne    80102c16 <lapicid+0x17>
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	eb 0d                	jmp    80102c23 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c16:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c1b:	83 c0 20             	add    $0x20,%eax
80102c1e:	8b 00                	mov    (%eax),%eax
80102c20:	c1 e8 18             	shr    $0x18,%eax
}
80102c23:	5d                   	pop    %ebp
80102c24:	c3                   	ret    

80102c25 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c25:	f3 0f 1e fb          	endbr32 
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c2c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 0c                	je     80102c41 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c35:	6a 00                	push   $0x0
80102c37:	6a 2c                	push   $0x2c
80102c39:	e8 78 fe ff ff       	call   80102ab6 <lapicw>
80102c3e:	83 c4 08             	add    $0x8,%esp
}
80102c41:	90                   	nop
80102c42:	c9                   	leave  
80102c43:	c3                   	ret    

80102c44 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c44:	f3 0f 1e fb          	endbr32 
80102c48:	55                   	push   %ebp
80102c49:	89 e5                	mov    %esp,%ebp
}
80102c4b:	90                   	nop
80102c4c:	5d                   	pop    %ebp
80102c4d:	c3                   	ret    

80102c4e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c4e:	f3 0f 1e fb          	endbr32 
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
80102c55:	83 ec 14             	sub    $0x14,%esp
80102c58:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c5e:	6a 0f                	push   $0xf
80102c60:	6a 70                	push   $0x70
80102c62:	e8 2e fe ff ff       	call   80102a95 <outb>
80102c67:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102c6a:	6a 0a                	push   $0xa
80102c6c:	6a 71                	push   $0x71
80102c6e:	e8 22 fe ff ff       	call   80102a95 <outb>
80102c73:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102c76:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102c7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c80:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102c85:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c88:	c1 e8 04             	shr    $0x4,%eax
80102c8b:	89 c2                	mov    %eax,%edx
80102c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c90:	83 c0 02             	add    $0x2,%eax
80102c93:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c96:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102c9a:	c1 e0 18             	shl    $0x18,%eax
80102c9d:	50                   	push   %eax
80102c9e:	68 c4 00 00 00       	push   $0xc4
80102ca3:	e8 0e fe ff ff       	call   80102ab6 <lapicw>
80102ca8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102cab:	68 00 c5 00 00       	push   $0xc500
80102cb0:	68 c0 00 00 00       	push   $0xc0
80102cb5:	e8 fc fd ff ff       	call   80102ab6 <lapicw>
80102cba:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102cbd:	68 c8 00 00 00       	push   $0xc8
80102cc2:	e8 7d ff ff ff       	call   80102c44 <microdelay>
80102cc7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102cca:	68 00 85 00 00       	push   $0x8500
80102ccf:	68 c0 00 00 00       	push   $0xc0
80102cd4:	e8 dd fd ff ff       	call   80102ab6 <lapicw>
80102cd9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102cdc:	6a 64                	push   $0x64
80102cde:	e8 61 ff ff ff       	call   80102c44 <microdelay>
80102ce3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ce6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ced:	eb 3d                	jmp    80102d2c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102cef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cf3:	c1 e0 18             	shl    $0x18,%eax
80102cf6:	50                   	push   %eax
80102cf7:	68 c4 00 00 00       	push   $0xc4
80102cfc:	e8 b5 fd ff ff       	call   80102ab6 <lapicw>
80102d01:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d07:	c1 e8 0c             	shr    $0xc,%eax
80102d0a:	80 cc 06             	or     $0x6,%ah
80102d0d:	50                   	push   %eax
80102d0e:	68 c0 00 00 00       	push   $0xc0
80102d13:	e8 9e fd ff ff       	call   80102ab6 <lapicw>
80102d18:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d1b:	68 c8 00 00 00       	push   $0xc8
80102d20:	e8 1f ff ff ff       	call   80102c44 <microdelay>
80102d25:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d2c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d30:	7e bd                	jle    80102cef <lapicstartap+0xa1>
  }
}
80102d32:	90                   	nop
80102d33:	90                   	nop
80102d34:	c9                   	leave  
80102d35:	c3                   	ret    

80102d36 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d36:	f3 0f 1e fb          	endbr32 
80102d3a:	55                   	push   %ebp
80102d3b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d40:	0f b6 c0             	movzbl %al,%eax
80102d43:	50                   	push   %eax
80102d44:	6a 70                	push   $0x70
80102d46:	e8 4a fd ff ff       	call   80102a95 <outb>
80102d4b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d4e:	68 c8 00 00 00       	push   $0xc8
80102d53:	e8 ec fe ff ff       	call   80102c44 <microdelay>
80102d58:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d5b:	6a 71                	push   $0x71
80102d5d:	e8 16 fd ff ff       	call   80102a78 <inb>
80102d62:	83 c4 04             	add    $0x4,%esp
80102d65:	0f b6 c0             	movzbl %al,%eax
}
80102d68:	c9                   	leave  
80102d69:	c3                   	ret    

80102d6a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102d6a:	f3 0f 1e fb          	endbr32 
80102d6e:	55                   	push   %ebp
80102d6f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102d71:	6a 00                	push   $0x0
80102d73:	e8 be ff ff ff       	call   80102d36 <cmos_read>
80102d78:	83 c4 04             	add    $0x4,%esp
80102d7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d7e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102d80:	6a 02                	push   $0x2
80102d82:	e8 af ff ff ff       	call   80102d36 <cmos_read>
80102d87:	83 c4 04             	add    $0x4,%esp
80102d8a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102d90:	6a 04                	push   $0x4
80102d92:	e8 9f ff ff ff       	call   80102d36 <cmos_read>
80102d97:	83 c4 04             	add    $0x4,%esp
80102d9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102da0:	6a 07                	push   $0x7
80102da2:	e8 8f ff ff ff       	call   80102d36 <cmos_read>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	8b 55 08             	mov    0x8(%ebp),%edx
80102dad:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102db0:	6a 08                	push   $0x8
80102db2:	e8 7f ff ff ff       	call   80102d36 <cmos_read>
80102db7:	83 c4 04             	add    $0x4,%esp
80102dba:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbd:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102dc0:	6a 09                	push   $0x9
80102dc2:	e8 6f ff ff ff       	call   80102d36 <cmos_read>
80102dc7:	83 c4 04             	add    $0x4,%esp
80102dca:	8b 55 08             	mov    0x8(%ebp),%edx
80102dcd:	89 42 14             	mov    %eax,0x14(%edx)
}
80102dd0:	90                   	nop
80102dd1:	c9                   	leave  
80102dd2:	c3                   	ret    

80102dd3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102dd3:	f3 0f 1e fb          	endbr32 
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ddd:	6a 0b                	push   $0xb
80102ddf:	e8 52 ff ff ff       	call   80102d36 <cmos_read>
80102de4:	83 c4 04             	add    $0x4,%esp
80102de7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ded:	83 e0 04             	and    $0x4,%eax
80102df0:	85 c0                	test   %eax,%eax
80102df2:	0f 94 c0             	sete   %al
80102df5:	0f b6 c0             	movzbl %al,%eax
80102df8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102dfb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102dfe:	50                   	push   %eax
80102dff:	e8 66 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e04:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e07:	6a 0a                	push   $0xa
80102e09:	e8 28 ff ff ff       	call   80102d36 <cmos_read>
80102e0e:	83 c4 04             	add    $0x4,%esp
80102e11:	25 80 00 00 00       	and    $0x80,%eax
80102e16:	85 c0                	test   %eax,%eax
80102e18:	75 27                	jne    80102e41 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e1a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e1d:	50                   	push   %eax
80102e1e:	e8 47 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e23:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e26:	83 ec 04             	sub    $0x4,%esp
80102e29:	6a 18                	push   $0x18
80102e2b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e2e:	50                   	push   %eax
80102e2f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e32:	50                   	push   %eax
80102e33:	e8 91 1d 00 00       	call   80104bc9 <memcmp>
80102e38:	83 c4 10             	add    $0x10,%esp
80102e3b:	85 c0                	test   %eax,%eax
80102e3d:	74 05                	je     80102e44 <cmostime+0x71>
80102e3f:	eb ba                	jmp    80102dfb <cmostime+0x28>
        continue;
80102e41:	90                   	nop
    fill_rtcdate(&t1);
80102e42:	eb b7                	jmp    80102dfb <cmostime+0x28>
      break;
80102e44:	90                   	nop
  }

  // convert
  if(bcd) {
80102e45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e49:	0f 84 b4 00 00 00    	je     80102f03 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e52:	c1 e8 04             	shr    $0x4,%eax
80102e55:	89 c2                	mov    %eax,%edx
80102e57:	89 d0                	mov    %edx,%eax
80102e59:	c1 e0 02             	shl    $0x2,%eax
80102e5c:	01 d0                	add    %edx,%eax
80102e5e:	01 c0                	add    %eax,%eax
80102e60:	89 c2                	mov    %eax,%edx
80102e62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e65:	83 e0 0f             	and    $0xf,%eax
80102e68:	01 d0                	add    %edx,%eax
80102e6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e70:	c1 e8 04             	shr    $0x4,%eax
80102e73:	89 c2                	mov    %eax,%edx
80102e75:	89 d0                	mov    %edx,%eax
80102e77:	c1 e0 02             	shl    $0x2,%eax
80102e7a:	01 d0                	add    %edx,%eax
80102e7c:	01 c0                	add    %eax,%eax
80102e7e:	89 c2                	mov    %eax,%edx
80102e80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e83:	83 e0 0f             	and    $0xf,%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e8e:	c1 e8 04             	shr    $0x4,%eax
80102e91:	89 c2                	mov    %eax,%edx
80102e93:	89 d0                	mov    %edx,%eax
80102e95:	c1 e0 02             	shl    $0x2,%eax
80102e98:	01 d0                	add    %edx,%eax
80102e9a:	01 c0                	add    %eax,%eax
80102e9c:	89 c2                	mov    %eax,%edx
80102e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ea1:	83 e0 0f             	and    $0xf,%eax
80102ea4:	01 d0                	add    %edx,%eax
80102ea6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eac:	c1 e8 04             	shr    $0x4,%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	89 d0                	mov    %edx,%eax
80102eb3:	c1 e0 02             	shl    $0x2,%eax
80102eb6:	01 d0                	add    %edx,%eax
80102eb8:	01 c0                	add    %eax,%eax
80102eba:	89 c2                	mov    %eax,%edx
80102ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ebf:	83 e0 0f             	and    $0xf,%eax
80102ec2:	01 d0                	add    %edx,%eax
80102ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eca:	c1 e8 04             	shr    $0x4,%eax
80102ecd:	89 c2                	mov    %eax,%edx
80102ecf:	89 d0                	mov    %edx,%eax
80102ed1:	c1 e0 02             	shl    $0x2,%eax
80102ed4:	01 d0                	add    %edx,%eax
80102ed6:	01 c0                	add    %eax,%eax
80102ed8:	89 c2                	mov    %eax,%edx
80102eda:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102edd:	83 e0 0f             	and    $0xf,%eax
80102ee0:	01 d0                	add    %edx,%eax
80102ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ee8:	c1 e8 04             	shr    $0x4,%eax
80102eeb:	89 c2                	mov    %eax,%edx
80102eed:	89 d0                	mov    %edx,%eax
80102eef:	c1 e0 02             	shl    $0x2,%eax
80102ef2:	01 d0                	add    %edx,%eax
80102ef4:	01 c0                	add    %eax,%eax
80102ef6:	89 c2                	mov    %eax,%edx
80102ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102efb:	83 e0 0f             	and    $0xf,%eax
80102efe:	01 d0                	add    %edx,%eax
80102f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f03:	8b 45 08             	mov    0x8(%ebp),%eax
80102f06:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f09:	89 10                	mov    %edx,(%eax)
80102f0b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f0e:	89 50 04             	mov    %edx,0x4(%eax)
80102f11:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f14:	89 50 08             	mov    %edx,0x8(%eax)
80102f17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f1a:	89 50 0c             	mov    %edx,0xc(%eax)
80102f1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f20:	89 50 10             	mov    %edx,0x10(%eax)
80102f23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f26:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f29:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2c:	8b 40 14             	mov    0x14(%eax),%eax
80102f2f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f35:	8b 45 08             	mov    0x8(%ebp),%eax
80102f38:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f3b:	90                   	nop
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f3e:	f3 0f 1e fb          	endbr32 
80102f42:	55                   	push   %ebp
80102f43:	89 e5                	mov    %esp,%ebp
80102f45:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f48:	83 ec 08             	sub    $0x8,%esp
80102f4b:	68 d1 a6 10 80       	push   $0x8010a6d1
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 4f 19 00 00       	call   801048a9 <initlock>
80102f5a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f5d:	83 ec 08             	sub    $0x8,%esp
80102f60:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102f63:	50                   	push   %eax
80102f64:	ff 75 08             	pushl  0x8(%ebp)
80102f67:	e8 c0 e4 ff ff       	call   8010142c <readsb>
80102f6c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f72:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102f77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f7a:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102f87:	e8 bf 01 00 00       	call   8010314b <recover_from_log>
}
80102f8c:	90                   	nop
80102f8d:	c9                   	leave  
80102f8e:	c3                   	ret    

80102f8f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102f8f:	f3 0f 1e fb          	endbr32 
80102f93:	55                   	push   %ebp
80102f94:	89 e5                	mov    %esp,%ebp
80102f96:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fa0:	e9 95 00 00 00       	jmp    8010303a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102fa5:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fae:	01 d0                	add    %edx,%eax
80102fb0:	83 c0 01             	add    $0x1,%eax
80102fb3:	89 c2                	mov    %eax,%edx
80102fb5:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	52                   	push   %edx
80102fbe:	50                   	push   %eax
80102fbf:	e8 45 d2 ff ff       	call   80100209 <bread>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcd:	83 c0 10             	add    $0x10,%eax
80102fd0:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80102fd7:	89 c2                	mov    %eax,%edx
80102fd9:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fde:	83 ec 08             	sub    $0x8,%esp
80102fe1:	52                   	push   %edx
80102fe2:	50                   	push   %eax
80102fe3:	e8 21 d2 ff ff       	call   80100209 <bread>
80102fe8:	83 c4 10             	add    $0x10,%esp
80102feb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ff1:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ff7:	83 c0 5c             	add    $0x5c,%eax
80102ffa:	83 ec 04             	sub    $0x4,%esp
80102ffd:	68 00 02 00 00       	push   $0x200
80103002:	52                   	push   %edx
80103003:	50                   	push   %eax
80103004:	e8 1c 1c 00 00       	call   80104c25 <memmove>
80103009:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010300c:	83 ec 0c             	sub    $0xc,%esp
8010300f:	ff 75 ec             	pushl  -0x14(%ebp)
80103012:	e8 2f d2 ff ff       	call   80100246 <bwrite>
80103017:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010301a:	83 ec 0c             	sub    $0xc,%esp
8010301d:	ff 75 f0             	pushl  -0x10(%ebp)
80103020:	e8 6e d2 ff ff       	call   80100293 <brelse>
80103025:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103028:	83 ec 0c             	sub    $0xc,%esp
8010302b:	ff 75 ec             	pushl  -0x14(%ebp)
8010302e:	e8 60 d2 ff ff       	call   80100293 <brelse>
80103033:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103036:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010303a:	a1 68 54 19 80       	mov    0x80195468,%eax
8010303f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103042:	0f 8c 5d ff ff ff    	jl     80102fa5 <install_trans+0x16>
  }
}
80103048:	90                   	nop
80103049:	90                   	nop
8010304a:	c9                   	leave  
8010304b:	c3                   	ret    

8010304c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010304c:	f3 0f 1e fb          	endbr32 
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103056:	a1 54 54 19 80       	mov    0x80195454,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103062:	83 ec 08             	sub    $0x8,%esp
80103065:	52                   	push   %edx
80103066:	50                   	push   %eax
80103067:	e8 9d d1 ff ff       	call   80100209 <bread>
8010306c:	83 c4 10             	add    $0x10,%esp
8010306f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103075:	83 c0 5c             	add    $0x5c,%eax
80103078:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010307b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010307e:	8b 00                	mov    (%eax),%eax
80103080:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
80103085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010308c:	eb 1b                	jmp    801030a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103094:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010309b:	83 c2 10             	add    $0x10,%edx
8010309e:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a9:	a1 68 54 19 80       	mov    0x80195468,%eax
801030ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030b1:	7c db                	jl     8010308e <read_head+0x42>
  }
  brelse(buf);
801030b3:	83 ec 0c             	sub    $0xc,%esp
801030b6:	ff 75 f0             	pushl  -0x10(%ebp)
801030b9:	e8 d5 d1 ff ff       	call   80100293 <brelse>
801030be:	83 c4 10             	add    $0x10,%esp
}
801030c1:	90                   	nop
801030c2:	c9                   	leave  
801030c3:	c3                   	ret    

801030c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801030c4:	f3 0f 1e fb          	endbr32 
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ce:	a1 54 54 19 80       	mov    0x80195454,%eax
801030d3:	89 c2                	mov    %eax,%edx
801030d5:	a1 64 54 19 80       	mov    0x80195464,%eax
801030da:	83 ec 08             	sub    $0x8,%esp
801030dd:	52                   	push   %edx
801030de:	50                   	push   %eax
801030df:	e8 25 d1 ff ff       	call   80100209 <bread>
801030e4:	83 c4 10             	add    $0x10,%esp
801030e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801030ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030ed:	83 c0 5c             	add    $0x5c,%eax
801030f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801030f3:	8b 15 68 54 19 80    	mov    0x80195468,%edx
801030f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103105:	eb 1b                	jmp    80103122 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310a:	83 c0 10             	add    $0x10,%eax
8010310d:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010311e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103122:	a1 68 54 19 80       	mov    0x80195468,%eax
80103127:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010312a:	7c db                	jl     80103107 <write_head+0x43>
  }
  bwrite(buf);
8010312c:	83 ec 0c             	sub    $0xc,%esp
8010312f:	ff 75 f0             	pushl  -0x10(%ebp)
80103132:	e8 0f d1 ff ff       	call   80100246 <bwrite>
80103137:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010313a:	83 ec 0c             	sub    $0xc,%esp
8010313d:	ff 75 f0             	pushl  -0x10(%ebp)
80103140:	e8 4e d1 ff ff       	call   80100293 <brelse>
80103145:	83 c4 10             	add    $0x10,%esp
}
80103148:	90                   	nop
80103149:	c9                   	leave  
8010314a:	c3                   	ret    

8010314b <recover_from_log>:

static void
recover_from_log(void)
{
8010314b:	f3 0f 1e fb          	endbr32 
8010314f:	55                   	push   %ebp
80103150:	89 e5                	mov    %esp,%ebp
80103152:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103155:	e8 f2 fe ff ff       	call   8010304c <read_head>
  install_trans(); // if committed, copy from log to disk
8010315a:	e8 30 fe ff ff       	call   80102f8f <install_trans>
  log.lh.n = 0;
8010315f:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103166:	00 00 00 
  write_head(); // clear the log
80103169:	e8 56 ff ff ff       	call   801030c4 <write_head>
}
8010316e:	90                   	nop
8010316f:	c9                   	leave  
80103170:	c3                   	ret    

80103171 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103171:	f3 0f 1e fb          	endbr32 
80103175:	55                   	push   %ebp
80103176:	89 e5                	mov    %esp,%ebp
80103178:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 54 19 80       	push   $0x80195420
80103183:	e8 47 17 00 00       	call   801048cf <acquire>
80103188:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010318b:	a1 60 54 19 80       	mov    0x80195460,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	74 17                	je     801031ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103194:	83 ec 08             	sub    $0x8,%esp
80103197:	68 20 54 19 80       	push   $0x80195420
8010319c:	68 20 54 19 80       	push   $0x80195420
801031a1:	e8 e6 12 00 00       	call   8010448c <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb e0                	jmp    8010318b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031ab:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031b1:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031b6:	8d 50 01             	lea    0x1(%eax),%edx
801031b9:	89 d0                	mov    %edx,%eax
801031bb:	c1 e0 02             	shl    $0x2,%eax
801031be:	01 d0                	add    %edx,%eax
801031c0:	01 c0                	add    %eax,%eax
801031c2:	01 c8                	add    %ecx,%eax
801031c4:	83 f8 1e             	cmp    $0x1e,%eax
801031c7:	7e 17                	jle    801031e0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801031c9:	83 ec 08             	sub    $0x8,%esp
801031cc:	68 20 54 19 80       	push   $0x80195420
801031d1:	68 20 54 19 80       	push   $0x80195420
801031d6:	e8 b1 12 00 00       	call   8010448c <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	eb ab                	jmp    8010318b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031e0:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031e5:	83 c0 01             	add    $0x1,%eax
801031e8:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	68 20 54 19 80       	push   $0x80195420
801031f5:	e8 47 17 00 00       	call   80104941 <release>
801031fa:	83 c4 10             	add    $0x10,%esp
      break;
801031fd:	90                   	nop
    }
  }
}
801031fe:	90                   	nop
801031ff:	c9                   	leave  
80103200:	c3                   	ret    

80103201 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103201:	f3 0f 1e fb          	endbr32 
80103205:	55                   	push   %ebp
80103206:	89 e5                	mov    %esp,%ebp
80103208:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010320b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103212:	83 ec 0c             	sub    $0xc,%esp
80103215:	68 20 54 19 80       	push   $0x80195420
8010321a:	e8 b0 16 00 00       	call   801048cf <acquire>
8010321f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103222:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103227:	83 e8 01             	sub    $0x1,%eax
8010322a:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010322f:	a1 60 54 19 80       	mov    0x80195460,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	74 0d                	je     80103245 <end_op+0x44>
    panic("log.committing");
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 d5 a6 10 80       	push   $0x8010a6d5
80103240:	e8 80 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103245:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 13                	jne    80103261 <end_op+0x60>
    do_commit = 1;
8010324e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103255:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
8010325c:	00 00 00 
8010325f:	eb 10                	jmp    80103271 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 20 54 19 80       	push   $0x80195420
80103269:	e8 0d 13 00 00       	call   8010457b <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 c3 16 00 00       	call   80104941 <release>
8010327e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103285:	74 3f                	je     801032c6 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103287:	e8 fa 00 00 00       	call   80103386 <commit>
    acquire(&log.lock);
8010328c:	83 ec 0c             	sub    $0xc,%esp
8010328f:	68 20 54 19 80       	push   $0x80195420
80103294:	e8 36 16 00 00       	call   801048cf <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 20 54 19 80       	push   $0x80195420
801032ae:	e8 c8 12 00 00       	call   8010457b <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 7e 16 00 00       	call   80104941 <release>
801032c3:	83 c4 10             	add    $0x10,%esp
  }
}
801032c6:	90                   	nop
801032c7:	c9                   	leave  
801032c8:	c3                   	ret    

801032c9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801032c9:	f3 0f 1e fb          	endbr32 
801032cd:	55                   	push   %ebp
801032ce:	89 e5                	mov    %esp,%ebp
801032d0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032da:	e9 95 00 00 00       	jmp    80103374 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801032df:	8b 15 54 54 19 80    	mov    0x80195454,%edx
801032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e8:	01 d0                	add    %edx,%eax
801032ea:	83 c0 01             	add    $0x1,%eax
801032ed:	89 c2                	mov    %eax,%edx
801032ef:	a1 64 54 19 80       	mov    0x80195464,%eax
801032f4:	83 ec 08             	sub    $0x8,%esp
801032f7:	52                   	push   %edx
801032f8:	50                   	push   %eax
801032f9:	e8 0b cf ff ff       	call   80100209 <bread>
801032fe:	83 c4 10             	add    $0x10,%esp
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 64 54 19 80       	mov    0x80195464,%eax
80103318:	83 ec 08             	sub    $0x8,%esp
8010331b:	52                   	push   %edx
8010331c:	50                   	push   %eax
8010331d:	e8 e7 ce ff ff       	call   80100209 <bread>
80103322:	83 c4 10             	add    $0x10,%esp
80103325:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010332b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010332e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103331:	83 c0 5c             	add    $0x5c,%eax
80103334:	83 ec 04             	sub    $0x4,%esp
80103337:	68 00 02 00 00       	push   $0x200
8010333c:	52                   	push   %edx
8010333d:	50                   	push   %eax
8010333e:	e8 e2 18 00 00       	call   80104c25 <memmove>
80103343:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	ff 75 f0             	pushl  -0x10(%ebp)
8010334c:	e8 f5 ce ff ff       	call   80100246 <bwrite>
80103351:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103354:	83 ec 0c             	sub    $0xc,%esp
80103357:	ff 75 ec             	pushl  -0x14(%ebp)
8010335a:	e8 34 cf ff ff       	call   80100293 <brelse>
8010335f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103362:	83 ec 0c             	sub    $0xc,%esp
80103365:	ff 75 f0             	pushl  -0x10(%ebp)
80103368:	e8 26 cf ff ff       	call   80100293 <brelse>
8010336d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103374:	a1 68 54 19 80       	mov    0x80195468,%eax
80103379:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010337c:	0f 8c 5d ff ff ff    	jl     801032df <write_log+0x16>
  }
}
80103382:	90                   	nop
80103383:	90                   	nop
80103384:	c9                   	leave  
80103385:	c3                   	ret    

80103386 <commit>:

static void
commit()
{
80103386:	f3 0f 1e fb          	endbr32 
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103390:	a1 68 54 19 80       	mov    0x80195468,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	7e 1e                	jle    801033b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103399:	e8 2b ff ff ff       	call   801032c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010339e:	e8 21 fd ff ff       	call   801030c4 <write_head>
    install_trans(); // Now install writes to home locations
801033a3:	e8 e7 fb ff ff       	call   80102f8f <install_trans>
    log.lh.n = 0;
801033a8:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033af:	00 00 00 
    write_head();    // Erase the transaction from the log
801033b2:	e8 0d fd ff ff       	call   801030c4 <write_head>
  }
}
801033b7:	90                   	nop
801033b8:	c9                   	leave  
801033b9:	c3                   	ret    

801033ba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033ba:	f3 0f 1e fb          	endbr32 
801033be:	55                   	push   %ebp
801033bf:	89 e5                	mov    %esp,%ebp
801033c1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033c4:	a1 68 54 19 80       	mov    0x80195468,%eax
801033c9:	83 f8 1d             	cmp    $0x1d,%eax
801033cc:	7f 12                	jg     801033e0 <log_write+0x26>
801033ce:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d3:	8b 15 58 54 19 80    	mov    0x80195458,%edx
801033d9:	83 ea 01             	sub    $0x1,%edx
801033dc:	39 d0                	cmp    %edx,%eax
801033de:	7c 0d                	jl     801033ed <log_write+0x33>
    panic("too big a transaction");
801033e0:	83 ec 0c             	sub    $0xc,%esp
801033e3:	68 e4 a6 10 80       	push   $0x8010a6e4
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 fa a6 10 80       	push   $0x8010a6fa
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 bf 14 00 00       	call   801048cf <acquire>
80103410:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341a:	eb 1d                	jmp    80103439 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010341c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341f:	83 c0 10             	add    $0x10,%eax
80103422:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 08             	mov    0x8(%eax),%eax
80103431:	39 c2                	cmp    %eax,%edx
80103433:	74 10                	je     80103445 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103435:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103439:	a1 68 54 19 80       	mov    0x80195468,%eax
8010343e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103441:	7c d9                	jl     8010341c <log_write+0x62>
80103443:	eb 01                	jmp    80103446 <log_write+0x8c>
      break;
80103445:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103446:	8b 45 08             	mov    0x8(%ebp),%eax
80103449:	8b 40 08             	mov    0x8(%eax),%eax
8010344c:	89 c2                	mov    %eax,%edx
8010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103451:	83 c0 10             	add    $0x10,%eax
80103454:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
8010345b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103463:	75 0d                	jne    80103472 <log_write+0xb8>
    log.lh.n++;
80103465:	a1 68 54 19 80       	mov    0x80195468,%eax
8010346a:	83 c0 01             	add    $0x1,%eax
8010346d:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	8b 00                	mov    (%eax),%eax
80103477:	83 c8 04             	or     $0x4,%eax
8010347a:	89 c2                	mov    %eax,%edx
8010347c:	8b 45 08             	mov    0x8(%ebp),%eax
8010347f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 20 54 19 80       	push   $0x80195420
80103489:	e8 b3 14 00 00       	call   80104941 <release>
8010348e:	83 c4 10             	add    $0x10,%esp
}
80103491:	90                   	nop
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010349a:	8b 55 08             	mov    0x8(%ebp),%edx
8010349d:	8b 45 0c             	mov    0xc(%ebp),%eax
801034a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034a3:	f0 87 02             	lock xchg %eax,(%edx)
801034a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034ac:	c9                   	leave  
801034ad:	c3                   	ret    

801034ae <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034ae:	f3 0f 1e fb          	endbr32 
801034b2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034b6:	83 e4 f0             	and    $0xfffffff0,%esp
801034b9:	ff 71 fc             	pushl  -0x4(%ecx)
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	51                   	push   %ecx
801034c0:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801034c3:	e8 d4 4c 00 00       	call   8010819c <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 97 42 00 00       	call   80107779 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 6e 4a 00 00       	call   80107f55 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 0f 3d 00 00       	call   80107200 <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 84 30 00 00       	call   80106589 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 14 2b 00 00       	call   80106023 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 83 6e 00 00       	call   8010a3a1 <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 d2 4e 00 00       	call   8010840f <pci_init>
  arp_scan();
8010353d:	e8 4b 5c 00 00       	call   8010918d <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103542:	e8 a5 07 00 00       	call   80103cec <userinit>

  mpmain();        // finish this processor's setup
80103547:	e8 1e 00 00 00       	call   8010356a <mpmain>

8010354c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010354c:	f3 0f 1e fb          	endbr32 
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103556:	e8 3a 42 00 00       	call   80107795 <switchkvm>
  seginit();
8010355b:	e8 a0 3c 00 00       	call   80107200 <seginit>
  lapicinit();
80103560:	e8 77 f5 ff ff       	call   80102adc <lapicinit>
  mpmain();
80103565:	e8 00 00 00 00       	call   8010356a <mpmain>

8010356a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010356a:	f3 0f 1e fb          	endbr32 
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	53                   	push   %ebx
80103572:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103575:	e8 94 05 00 00       	call   80103b0e <cpuid>
8010357a:	89 c3                	mov    %eax,%ebx
8010357c:	e8 8d 05 00 00       	call   80103b0e <cpuid>
80103581:	83 ec 04             	sub    $0x4,%esp
80103584:	53                   	push   %ebx
80103585:	50                   	push   %eax
80103586:	68 15 a7 10 80       	push   $0x8010a715
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 05 2c 00 00       	call   8010619d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 d6 0c 00 00       	call   8010428b <scheduler>

801035b5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035b5:	f3 0f 1e fb          	endbr32 
801035b9:	55                   	push   %ebp
801035ba:	89 e5                	mov    %esp,%ebp
801035bc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035bf:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035c6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035cb:	83 ec 04             	sub    $0x4,%esp
801035ce:	50                   	push   %eax
801035cf:	68 18 f5 10 80       	push   $0x8010f518
801035d4:	ff 75 f0             	pushl  -0x10(%ebp)
801035d7:	e8 49 16 00 00       	call   80104c25 <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
801035e6:	eb 79                	jmp    80103661 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
801035e8:	e8 40 05 00 00       	call   80103b2d <mycpu>
801035ed:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035f0:	74 67                	je     80103659 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035f2:	e8 9b f2 ff ff       	call   80102892 <kalloc>
801035f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fd:	83 e8 04             	sub    $0x4,%eax
80103600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103603:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103609:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010360b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360e:	83 e8 08             	sub    $0x8,%eax
80103611:	c7 00 4c 35 10 80    	movl   $0x8010354c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103617:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010361c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103625:	83 e8 0c             	sub    $0xc,%eax
80103628:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
8010362a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010362d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103636:	0f b6 00             	movzbl (%eax),%eax
80103639:	0f b6 c0             	movzbl %al,%eax
8010363c:	83 ec 08             	sub    $0x8,%esp
8010363f:	52                   	push   %edx
80103640:	50                   	push   %eax
80103641:	e8 08 f6 ff ff       	call   80102c4e <lapicstartap>
80103646:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103649:	90                   	nop
8010364a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010364d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103653:	85 c0                	test   %eax,%eax
80103655:	74 f3                	je     8010364a <startothers+0x95>
80103657:	eb 01                	jmp    8010365a <startothers+0xa5>
      continue;
80103659:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010365a:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103661:	a1 80 80 19 80       	mov    0x80198080,%eax
80103666:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010366c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103671:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103674:	0f 82 6e ff ff ff    	jb     801035e8 <startothers+0x33>
      ;
  }
}
8010367a:	90                   	nop
8010367b:	90                   	nop
8010367c:	c9                   	leave  
8010367d:	c3                   	ret    

8010367e <outb>:
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 08             	sub    $0x8,%esp
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 55 0c             	mov    0xc(%ebp),%edx
8010368a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010368e:	89 d0                	mov    %edx,%eax
80103690:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103693:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103697:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010369b:	ee                   	out    %al,(%dx)
}
8010369c:	90                   	nop
8010369d:	c9                   	leave  
8010369e:	c3                   	ret    

8010369f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010369f:	f3 0f 1e fb          	endbr32 
801036a3:	55                   	push   %ebp
801036a4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036a6:	68 ff 00 00 00       	push   $0xff
801036ab:	6a 21                	push   $0x21
801036ad:	e8 cc ff ff ff       	call   8010367e <outb>
801036b2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036b5:	68 ff 00 00 00       	push   $0xff
801036ba:	68 a1 00 00 00       	push   $0xa1
801036bf:	e8 ba ff ff ff       	call   8010367e <outb>
801036c4:	83 c4 08             	add    $0x8,%esp
}
801036c7:	90                   	nop
801036c8:	c9                   	leave  
801036c9:	c3                   	ret    

801036ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036ca:	f3 0f 1e fb          	endbr32 
801036ce:	55                   	push   %ebp
801036cf:	89 e5                	mov    %esp,%ebp
801036d1:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801036d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801036db:	8b 45 0c             	mov    0xc(%ebp),%eax
801036de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801036e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801036e7:	8b 10                	mov    (%eax),%edx
801036e9:	8b 45 08             	mov    0x8(%ebp),%eax
801036ec:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801036ee:	e8 30 d9 ff ff       	call   80101023 <filealloc>
801036f3:	8b 55 08             	mov    0x8(%ebp),%edx
801036f6:	89 02                	mov    %eax,(%edx)
801036f8:	8b 45 08             	mov    0x8(%ebp),%eax
801036fb:	8b 00                	mov    (%eax),%eax
801036fd:	85 c0                	test   %eax,%eax
801036ff:	0f 84 c8 00 00 00    	je     801037cd <pipealloc+0x103>
80103705:	e8 19 d9 ff ff       	call   80101023 <filealloc>
8010370a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010370d:	89 02                	mov    %eax,(%edx)
8010370f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103712:	8b 00                	mov    (%eax),%eax
80103714:	85 c0                	test   %eax,%eax
80103716:	0f 84 b1 00 00 00    	je     801037cd <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010371c:	e8 71 f1 ff ff       	call   80102892 <kalloc>
80103721:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103724:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103728:	0f 84 a2 00 00 00    	je     801037d0 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010372e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103731:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103738:	00 00 00 
  p->writeopen = 1;
8010373b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103745:	00 00 00 
  p->nwrite = 0;
80103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103752:	00 00 00 
  p->nread = 0;
80103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103758:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010375f:	00 00 00 
  initlock(&p->lock, "pipe");
80103762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103765:	83 ec 08             	sub    $0x8,%esp
80103768:	68 29 a7 10 80       	push   $0x8010a729
8010376d:	50                   	push   %eax
8010376e:	e8 36 11 00 00       	call   801048a9 <initlock>
80103773:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103776:	8b 45 08             	mov    0x8(%ebp),%eax
80103779:	8b 00                	mov    (%eax),%eax
8010377b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103781:	8b 45 08             	mov    0x8(%ebp),%eax
80103784:	8b 00                	mov    (%eax),%eax
80103786:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010378a:	8b 45 08             	mov    0x8(%ebp),%eax
8010378d:	8b 00                	mov    (%eax),%eax
8010378f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103793:	8b 45 08             	mov    0x8(%ebp),%eax
80103796:	8b 00                	mov    (%eax),%eax
80103798:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010379b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010379e:	8b 45 0c             	mov    0xc(%ebp),%eax
801037a1:	8b 00                	mov    (%eax),%eax
801037a3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ac:	8b 00                	mov    (%eax),%eax
801037ae:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 00                	mov    (%eax),%eax
801037b7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801037be:	8b 00                	mov    (%eax),%eax
801037c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037c3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801037c6:	b8 00 00 00 00       	mov    $0x0,%eax
801037cb:	eb 51                	jmp    8010381e <pipealloc+0x154>
    goto bad;
801037cd:	90                   	nop
801037ce:	eb 01                	jmp    801037d1 <pipealloc+0x107>
    goto bad;
801037d0:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801037d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037d5:	74 0e                	je     801037e5 <pipealloc+0x11b>
    kfree((char*)p);
801037d7:	83 ec 0c             	sub    $0xc,%esp
801037da:	ff 75 f4             	pushl  -0xc(%ebp)
801037dd:	e8 12 f0 ff ff       	call   801027f4 <kfree>
801037e2:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801037e5:	8b 45 08             	mov    0x8(%ebp),%eax
801037e8:	8b 00                	mov    (%eax),%eax
801037ea:	85 c0                	test   %eax,%eax
801037ec:	74 11                	je     801037ff <pipealloc+0x135>
    fileclose(*f0);
801037ee:	8b 45 08             	mov    0x8(%ebp),%eax
801037f1:	8b 00                	mov    (%eax),%eax
801037f3:	83 ec 0c             	sub    $0xc,%esp
801037f6:	50                   	push   %eax
801037f7:	e8 ed d8 ff ff       	call   801010e9 <fileclose>
801037fc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103802:	8b 00                	mov    (%eax),%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	74 11                	je     80103819 <pipealloc+0x14f>
    fileclose(*f1);
80103808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380b:	8b 00                	mov    (%eax),%eax
8010380d:	83 ec 0c             	sub    $0xc,%esp
80103810:	50                   	push   %eax
80103811:	e8 d3 d8 ff ff       	call   801010e9 <fileclose>
80103816:	83 c4 10             	add    $0x10,%esp
  return -1;
80103819:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010381e:	c9                   	leave  
8010381f:	c3                   	ret    

80103820 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103820:	f3 0f 1e fb          	endbr32 
80103824:	55                   	push   %ebp
80103825:	89 e5                	mov    %esp,%ebp
80103827:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010382a:	8b 45 08             	mov    0x8(%ebp),%eax
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	50                   	push   %eax
80103831:	e8 99 10 00 00       	call   801048cf <acquire>
80103836:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103839:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010383d:	74 23                	je     80103862 <pipeclose+0x42>
    p->writeopen = 0;
8010383f:	8b 45 08             	mov    0x8(%ebp),%eax
80103842:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103849:	00 00 00 
    wakeup(&p->nread);
8010384c:	8b 45 08             	mov    0x8(%ebp),%eax
8010384f:	05 34 02 00 00       	add    $0x234,%eax
80103854:	83 ec 0c             	sub    $0xc,%esp
80103857:	50                   	push   %eax
80103858:	e8 1e 0d 00 00       	call   8010457b <wakeup>
8010385d:	83 c4 10             	add    $0x10,%esp
80103860:	eb 21                	jmp    80103883 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103862:	8b 45 08             	mov    0x8(%ebp),%eax
80103865:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010386c:	00 00 00 
    wakeup(&p->nwrite);
8010386f:	8b 45 08             	mov    0x8(%ebp),%eax
80103872:	05 38 02 00 00       	add    $0x238,%eax
80103877:	83 ec 0c             	sub    $0xc,%esp
8010387a:	50                   	push   %eax
8010387b:	e8 fb 0c 00 00       	call   8010457b <wakeup>
80103880:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103883:	8b 45 08             	mov    0x8(%ebp),%eax
80103886:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	75 2c                	jne    801038bc <pipeclose+0x9c>
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103899:	85 c0                	test   %eax,%eax
8010389b:	75 1f                	jne    801038bc <pipeclose+0x9c>
    release(&p->lock);
8010389d:	8b 45 08             	mov    0x8(%ebp),%eax
801038a0:	83 ec 0c             	sub    $0xc,%esp
801038a3:	50                   	push   %eax
801038a4:	e8 98 10 00 00       	call   80104941 <release>
801038a9:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801038ac:	83 ec 0c             	sub    $0xc,%esp
801038af:	ff 75 08             	pushl  0x8(%ebp)
801038b2:	e8 3d ef ff ff       	call   801027f4 <kfree>
801038b7:	83 c4 10             	add    $0x10,%esp
801038ba:	eb 10                	jmp    801038cc <pipeclose+0xac>
  } else
    release(&p->lock);
801038bc:	8b 45 08             	mov    0x8(%ebp),%eax
801038bf:	83 ec 0c             	sub    $0xc,%esp
801038c2:	50                   	push   %eax
801038c3:	e8 79 10 00 00       	call   80104941 <release>
801038c8:	83 c4 10             	add    $0x10,%esp
}
801038cb:	90                   	nop
801038cc:	90                   	nop
801038cd:	c9                   	leave  
801038ce:	c3                   	ret    

801038cf <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038cf:	f3 0f 1e fb          	endbr32 
801038d3:	55                   	push   %ebp
801038d4:	89 e5                	mov    %esp,%ebp
801038d6:	53                   	push   %ebx
801038d7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	83 ec 0c             	sub    $0xc,%esp
801038e0:	50                   	push   %eax
801038e1:	e8 e9 0f 00 00       	call   801048cf <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801038e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f0:	e9 ad 00 00 00       	jmp    801039a2 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801038f5:	8b 45 08             	mov    0x8(%ebp),%eax
801038f8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038fe:	85 c0                	test   %eax,%eax
80103900:	74 0c                	je     8010390e <pipewrite+0x3f>
80103902:	e8 a2 02 00 00       	call   80103ba9 <myproc>
80103907:	8b 40 24             	mov    0x24(%eax),%eax
8010390a:	85 c0                	test   %eax,%eax
8010390c:	74 19                	je     80103927 <pipewrite+0x58>
        release(&p->lock);
8010390e:	8b 45 08             	mov    0x8(%ebp),%eax
80103911:	83 ec 0c             	sub    $0xc,%esp
80103914:	50                   	push   %eax
80103915:	e8 27 10 00 00       	call   80104941 <release>
8010391a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010391d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103922:	e9 a9 00 00 00       	jmp    801039d0 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	05 34 02 00 00       	add    $0x234,%eax
8010392f:	83 ec 0c             	sub    $0xc,%esp
80103932:	50                   	push   %eax
80103933:	e8 43 0c 00 00       	call   8010457b <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 3b 0b 00 00       	call   8010448c <sleep>
80103951:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010395d:	8b 45 08             	mov    0x8(%ebp),%eax
80103960:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103966:	05 00 02 00 00       	add    $0x200,%eax
8010396b:	39 c2                	cmp    %eax,%edx
8010396d:	74 86                	je     801038f5 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010396f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103972:	8b 45 0c             	mov    0xc(%ebp),%eax
80103975:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103981:	8d 48 01             	lea    0x1(%eax),%ecx
80103984:	8b 55 08             	mov    0x8(%ebp),%edx
80103987:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010398d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103992:	89 c1                	mov    %eax,%ecx
80103994:	0f b6 13             	movzbl (%ebx),%edx
80103997:	8b 45 08             	mov    0x8(%ebp),%eax
8010399a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010399e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801039a8:	7c aa                	jl     80103954 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039aa:	8b 45 08             	mov    0x8(%ebp),%eax
801039ad:	05 34 02 00 00       	add    $0x234,%eax
801039b2:	83 ec 0c             	sub    $0xc,%esp
801039b5:	50                   	push   %eax
801039b6:	e8 c0 0b 00 00       	call   8010457b <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 77 0f 00 00       	call   80104941 <release>
801039ca:	83 c4 10             	add    $0x10,%esp
  return n;
801039cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801039d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039d3:	c9                   	leave  
801039d4:	c3                   	ret    

801039d5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039d5:	f3 0f 1e fb          	endbr32 
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801039df:	8b 45 08             	mov    0x8(%ebp),%eax
801039e2:	83 ec 0c             	sub    $0xc,%esp
801039e5:	50                   	push   %eax
801039e6:	e8 e4 0e 00 00       	call   801048cf <acquire>
801039eb:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039ee:	eb 3e                	jmp    80103a2e <piperead+0x59>
    if(myproc()->killed){
801039f0:	e8 b4 01 00 00       	call   80103ba9 <myproc>
801039f5:	8b 40 24             	mov    0x24(%eax),%eax
801039f8:	85 c0                	test   %eax,%eax
801039fa:	74 19                	je     80103a15 <piperead+0x40>
      release(&p->lock);
801039fc:	8b 45 08             	mov    0x8(%ebp),%eax
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	50                   	push   %eax
80103a03:	e8 39 0f 00 00       	call   80104941 <release>
80103a08:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a10:	e9 be 00 00 00       	jmp    80103ad3 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
80103a18:	8b 55 08             	mov    0x8(%ebp),%edx
80103a1b:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a21:	83 ec 08             	sub    $0x8,%esp
80103a24:	50                   	push   %eax
80103a25:	52                   	push   %edx
80103a26:	e8 61 0a 00 00       	call   8010448c <sleep>
80103a2b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a31:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a37:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a40:	39 c2                	cmp    %eax,%edx
80103a42:	75 0d                	jne    80103a51 <piperead+0x7c>
80103a44:	8b 45 08             	mov    0x8(%ebp),%eax
80103a47:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a4d:	85 c0                	test   %eax,%eax
80103a4f:	75 9f                	jne    801039f0 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a58:	eb 48                	jmp    80103aa2 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a6c:	39 c2                	cmp    %eax,%edx
80103a6e:	74 3c                	je     80103aac <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a70:	8b 45 08             	mov    0x8(%ebp),%eax
80103a73:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103a79:	8d 48 01             	lea    0x1(%eax),%ecx
80103a7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103a85:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a8a:	89 c1                	mov    %eax,%ecx
80103a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a92:	01 c2                	add    %eax,%edx
80103a94:	8b 45 08             	mov    0x8(%ebp),%eax
80103a97:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103a9c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa5:	3b 45 10             	cmp    0x10(%ebp),%eax
80103aa8:	7c b0                	jl     80103a5a <piperead+0x85>
80103aaa:	eb 01                	jmp    80103aad <piperead+0xd8>
      break;
80103aac:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103aad:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab0:	05 38 02 00 00       	add    $0x238,%eax
80103ab5:	83 ec 0c             	sub    $0xc,%esp
80103ab8:	50                   	push   %eax
80103ab9:	e8 bd 0a 00 00       	call   8010457b <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 74 0e 00 00       	call   80104941 <release>
80103acd:	83 c4 10             	add    $0x10,%esp
  return i;
80103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ad3:	c9                   	leave  
80103ad4:	c3                   	ret    

80103ad5 <readeflags>:
{
80103ad5:	55                   	push   %ebp
80103ad6:	89 e5                	mov    %esp,%ebp
80103ad8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103adb:	9c                   	pushf  
80103adc:	58                   	pop    %eax
80103add:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103ae3:	c9                   	leave  
80103ae4:	c3                   	ret    

80103ae5 <sti>:
{
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ae8:	fb                   	sti    
}
80103ae9:	90                   	nop
80103aea:	5d                   	pop    %ebp
80103aeb:	c3                   	ret    

80103aec <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103aec:	f3 0f 1e fb          	endbr32 
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	68 30 a7 10 80       	push   $0x8010a730
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 a1 0d 00 00       	call   801048a9 <initlock>
80103b08:	83 c4 10             	add    $0x10,%esp
}
80103b0b:	90                   	nop
80103b0c:	c9                   	leave  
80103b0d:	c3                   	ret    

80103b0e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b0e:	f3 0f 1e fb          	endbr32 
80103b12:	55                   	push   %ebp
80103b13:	89 e5                	mov    %esp,%ebp
80103b15:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b18:	e8 10 00 00 00       	call   80103b2d <mycpu>
80103b1d:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b22:	c1 f8 04             	sar    $0x4,%eax
80103b25:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b2b:	c9                   	leave  
80103b2c:	c3                   	ret    

80103b2d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b2d:	f3 0f 1e fb          	endbr32 
80103b31:	55                   	push   %ebp
80103b32:	89 e5                	mov    %esp,%ebp
80103b34:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b37:	e8 99 ff ff ff       	call   80103ad5 <readeflags>
80103b3c:	25 00 02 00 00       	and    $0x200,%eax
80103b41:	85 c0                	test   %eax,%eax
80103b43:	74 0d                	je     80103b52 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b45:	83 ec 0c             	sub    $0xc,%esp
80103b48:	68 38 a7 10 80       	push   $0x8010a738
80103b4d:	e8 73 ca ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80103b52:	e8 a8 f0 ff ff       	call   80102bff <lapicid>
80103b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b61:	eb 2d                	jmp    80103b90 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b66:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b6c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b85:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 80 80 19 80       	mov    0x80198080,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 5e a7 10 80       	push   $0x8010a75e
80103ba2:	e8 1e ca ff ff       	call   801005c5 <panic>
}
80103ba7:	c9                   	leave  
80103ba8:	c3                   	ret    

80103ba9 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103ba9:	f3 0f 1e fb          	endbr32 
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bb3:	e8 93 0e 00 00       	call   80104a4b <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 cb 0e 00 00       	call   80104a9c <popcli>
  return p;
80103bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bd4:	c9                   	leave  
80103bd5:	c3                   	ret    

80103bd6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103bd6:	f3 0f 1e fb          	endbr32 
80103bda:	55                   	push   %ebp
80103bdb:	89 e5                	mov    %esp,%ebp
80103bdd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103be0:	83 ec 0c             	sub    $0xc,%esp
80103be3:	68 00 55 19 80       	push   $0x80195500
80103be8:	e8 e2 0c 00 00       	call   801048cf <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103bf7:	eb 0e                	jmp    80103c07 <allocproc+0x31>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 27                	je     80103c2a <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c07:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c0e:	72 e9                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c10:	83 ec 0c             	sub    $0xc,%esp
80103c13:	68 00 55 19 80       	push   $0x80195500
80103c18:	e8 24 0d 00 00       	call   80104941 <release>
80103c1d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c20:	b8 00 00 00 00       	mov    $0x0,%eax
80103c25:	e9 c0 00 00 00       	jmp    80103cea <allocproc+0x114>
      goto found;
80103c2a:	90                   	nop
80103c2b:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c32:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c39:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c3e:	8d 50 01             	lea    0x1(%eax),%edx
80103c41:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c4a:	89 42 10             	mov    %eax,0x10(%edx)
  p->scheduler = 0;         // scheduler 필드를 0으로 초기화
80103c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c50:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  release(&ptable.lock);
80103c57:	83 ec 0c             	sub    $0xc,%esp
80103c5a:	68 00 55 19 80       	push   $0x80195500
80103c5f:	e8 dd 0c 00 00       	call   80104941 <release>
80103c64:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c67:	e8 26 ec ff ff       	call   80102892 <kalloc>
80103c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c6f:	89 42 08             	mov    %eax,0x8(%edx)
80103c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c75:	8b 40 08             	mov    0x8(%eax),%eax
80103c78:	85 c0                	test   %eax,%eax
80103c7a:	75 11                	jne    80103c8d <allocproc+0xb7>
    p->state = UNUSED;
80103c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103c86:	b8 00 00 00 00       	mov    $0x0,%eax
80103c8b:	eb 5d                	jmp    80103cea <allocproc+0x114>
  }
  sp = p->kstack + KSTACKSIZE;
80103c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c90:	8b 40 08             	mov    0x8(%eax),%eax
80103c93:	05 00 10 00 00       	add    $0x1000,%eax
80103c98:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103c9b:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ca5:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ca8:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103cac:	ba dd 5f 10 80       	mov    $0x80105fdd,%edx
80103cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb4:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103cb6:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cc0:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc6:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cc9:	83 ec 04             	sub    $0x4,%esp
80103ccc:	6a 14                	push   $0x14
80103cce:	6a 00                	push   $0x0
80103cd0:	50                   	push   %eax
80103cd1:	e8 88 0e 00 00       	call   80104b5e <memset>
80103cd6:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdc:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cdf:	ba 42 44 10 80       	mov    $0x80104442,%edx
80103ce4:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103cea:	c9                   	leave  
80103ceb:	c3                   	ret    

80103cec <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103cec:	f3 0f 1e fb          	endbr32 
80103cf0:	55                   	push   %ebp
80103cf1:	89 e5                	mov    %esp,%ebp
80103cf3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103cf6:	e8 db fe ff ff       	call   80103bd6 <allocproc>
80103cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d01:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d06:	e8 7d 39 00 00       	call   80107688 <setupkvm>
80103d0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d0e:	89 42 04             	mov    %eax,0x4(%edx)
80103d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d14:	8b 40 04             	mov    0x4(%eax),%eax
80103d17:	85 c0                	test   %eax,%eax
80103d19:	75 0d                	jne    80103d28 <userinit+0x3c>
    panic("userinit: out of memory?");
80103d1b:	83 ec 0c             	sub    $0xc,%esp
80103d1e:	68 6e a7 10 80       	push   $0x8010a76e
80103d23:	e8 9d c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d28:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d30:	8b 40 04             	mov    0x4(%eax),%eax
80103d33:	83 ec 04             	sub    $0x4,%esp
80103d36:	52                   	push   %edx
80103d37:	68 ec f4 10 80       	push   $0x8010f4ec
80103d3c:	50                   	push   %eax
80103d3d:	e8 13 3c 00 00       	call   80107955 <inituvm>
80103d42:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d48:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d51:	8b 40 18             	mov    0x18(%eax),%eax
80103d54:	83 ec 04             	sub    $0x4,%esp
80103d57:	6a 4c                	push   $0x4c
80103d59:	6a 00                	push   $0x0
80103d5b:	50                   	push   %eax
80103d5c:	e8 fd 0d 00 00       	call   80104b5e <memset>
80103d61:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d67:	8b 40 18             	mov    0x18(%eax),%eax
80103d6a:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d73:	8b 40 18             	mov    0x18(%eax),%eax
80103d76:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7f:	8b 50 18             	mov    0x18(%eax),%edx
80103d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d85:	8b 40 18             	mov    0x18(%eax),%eax
80103d88:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d8c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d93:	8b 50 18             	mov    0x18(%eax),%edx
80103d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d99:	8b 40 18             	mov    0x18(%eax),%eax
80103d9c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103da0:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da7:	8b 40 18             	mov    0x18(%eax),%eax
80103daa:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db4:	8b 40 18             	mov    0x18(%eax),%eax
80103db7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc1:	8b 40 18             	mov    0x18(%eax),%eax
80103dc4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dce:	83 c0 6c             	add    $0x6c,%eax
80103dd1:	83 ec 04             	sub    $0x4,%esp
80103dd4:	6a 10                	push   $0x10
80103dd6:	68 87 a7 10 80       	push   $0x8010a787
80103ddb:	50                   	push   %eax
80103ddc:	e8 98 0f 00 00       	call   80104d79 <safestrcpy>
80103de1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103de4:	83 ec 0c             	sub    $0xc,%esp
80103de7:	68 90 a7 10 80       	push   $0x8010a790
80103dec:	e8 f6 e7 ff ff       	call   801025e7 <namei>
80103df1:	83 c4 10             	add    $0x10,%esp
80103df4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103df7:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103dfa:	83 ec 0c             	sub    $0xc,%esp
80103dfd:	68 00 55 19 80       	push   $0x80195500
80103e02:	e8 c8 0a 00 00       	call   801048cf <acquire>
80103e07:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	68 00 55 19 80       	push   $0x80195500
80103e1c:	e8 20 0b 00 00       	call   80104941 <release>
80103e21:	83 c4 10             	add    $0x10,%esp
}
80103e24:	90                   	nop
80103e25:	c9                   	leave  
80103e26:	c3                   	ret    

80103e27 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e27:	f3 0f 1e fb          	endbr32 
80103e2b:	55                   	push   %ebp
80103e2c:	89 e5                	mov    %esp,%ebp
80103e2e:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e31:	e8 73 fd ff ff       	call   80103ba9 <myproc>
80103e36:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e3c:	8b 00                	mov    (%eax),%eax
80103e3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e45:	7e 2e                	jle    80103e75 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e47:	8b 55 08             	mov    0x8(%ebp),%edx
80103e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e4d:	01 c2                	add    %eax,%edx
80103e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e52:	8b 40 04             	mov    0x4(%eax),%eax
80103e55:	83 ec 04             	sub    $0x4,%esp
80103e58:	52                   	push   %edx
80103e59:	ff 75 f4             	pushl  -0xc(%ebp)
80103e5c:	50                   	push   %eax
80103e5d:	e8 38 3c 00 00       	call   80107a9a <allocuvm>
80103e62:	83 c4 10             	add    $0x10,%esp
80103e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e6c:	75 3b                	jne    80103ea9 <growproc+0x82>
      return -1;
80103e6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e73:	eb 4f                	jmp    80103ec4 <growproc+0x9d>
  } else if(n < 0){
80103e75:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e79:	79 2e                	jns    80103ea9 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e7b:	8b 55 08             	mov    0x8(%ebp),%edx
80103e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e81:	01 c2                	add    %eax,%edx
80103e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e86:	8b 40 04             	mov    0x4(%eax),%eax
80103e89:	83 ec 04             	sub    $0x4,%esp
80103e8c:	52                   	push   %edx
80103e8d:	ff 75 f4             	pushl  -0xc(%ebp)
80103e90:	50                   	push   %eax
80103e91:	e8 0d 3d 00 00       	call   80107ba3 <deallocuvm>
80103e96:	83 c4 10             	add    $0x10,%esp
80103e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ea0:	75 07                	jne    80103ea9 <growproc+0x82>
      return -1;
80103ea2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ea7:	eb 1b                	jmp    80103ec4 <growproc+0x9d>
  }
  curproc->sz = sz;
80103ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eaf:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103eb1:	83 ec 0c             	sub    $0xc,%esp
80103eb4:	ff 75 f0             	pushl  -0x10(%ebp)
80103eb7:	e8 f6 38 00 00       	call   801077b2 <switchuvm>
80103ebc:	83 c4 10             	add    $0x10,%esp
  return 0;
80103ebf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ec4:	c9                   	leave  
80103ec5:	c3                   	ret    

80103ec6 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103ec6:	f3 0f 1e fb          	endbr32 
80103eca:	55                   	push   %ebp
80103ecb:	89 e5                	mov    %esp,%ebp
80103ecd:	57                   	push   %edi
80103ece:	56                   	push   %esi
80103ecf:	53                   	push   %ebx
80103ed0:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103ed3:	e8 d1 fc ff ff       	call   80103ba9 <myproc>
80103ed8:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103edb:	e8 f6 fc ff ff       	call   80103bd6 <allocproc>
80103ee0:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103ee3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103ee7:	75 0a                	jne    80103ef3 <fork+0x2d>
    return -1;
80103ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eee:	e9 48 01 00 00       	jmp    8010403b <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103ef3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef6:	8b 10                	mov    (%eax),%edx
80103ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103efb:	8b 40 04             	mov    0x4(%eax),%eax
80103efe:	83 ec 08             	sub    $0x8,%esp
80103f01:	52                   	push   %edx
80103f02:	50                   	push   %eax
80103f03:	e8 45 3e 00 00       	call   80107d4d <copyuvm>
80103f08:	83 c4 10             	add    $0x10,%esp
80103f0b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f0e:	89 42 04             	mov    %eax,0x4(%edx)
80103f11:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f14:	8b 40 04             	mov    0x4(%eax),%eax
80103f17:	85 c0                	test   %eax,%eax
80103f19:	75 30                	jne    80103f4b <fork+0x85>
    kfree(np->kstack);
80103f1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f1e:	8b 40 08             	mov    0x8(%eax),%eax
80103f21:	83 ec 0c             	sub    $0xc,%esp
80103f24:	50                   	push   %eax
80103f25:	e8 ca e8 ff ff       	call   801027f4 <kfree>
80103f2a:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f30:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f37:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f3a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f46:	e9 f0 00 00 00       	jmp    8010403b <fork+0x175>
  }
  np->sz = curproc->sz;
80103f4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f4e:	8b 10                	mov    (%eax),%edx
80103f50:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f53:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f58:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f5b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f61:	8b 48 18             	mov    0x18(%eax),%ecx
80103f64:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f67:	8b 40 18             	mov    0x18(%eax),%eax
80103f6a:	89 c2                	mov    %eax,%edx
80103f6c:	89 cb                	mov    %ecx,%ebx
80103f6e:	b8 13 00 00 00       	mov    $0x13,%eax
80103f73:	89 d7                	mov    %edx,%edi
80103f75:	89 de                	mov    %ebx,%esi
80103f77:	89 c1                	mov    %eax,%ecx
80103f79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f7e:	8b 40 18             	mov    0x18(%eax),%eax
80103f81:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103f88:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f8f:	eb 3b                	jmp    80103fcc <fork+0x106>
    if(curproc->ofile[i])
80103f91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f97:	83 c2 08             	add    $0x8,%edx
80103f9a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f9e:	85 c0                	test   %eax,%eax
80103fa0:	74 26                	je     80103fc8 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103fa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fa5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fa8:	83 c2 08             	add    $0x8,%edx
80103fab:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103faf:	83 ec 0c             	sub    $0xc,%esp
80103fb2:	50                   	push   %eax
80103fb3:	e8 dc d0 ff ff       	call   80101094 <filedup>
80103fb8:	83 c4 10             	add    $0x10,%esp
80103fbb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fbe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fc1:	83 c1 08             	add    $0x8,%ecx
80103fc4:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fc8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fcc:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fd0:	7e bf                	jle    80103f91 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80103fd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fd5:	8b 40 68             	mov    0x68(%eax),%eax
80103fd8:	83 ec 0c             	sub    $0xc,%esp
80103fdb:	50                   	push   %eax
80103fdc:	e8 5d da ff ff       	call   80101a3e <idup>
80103fe1:	83 c4 10             	add    $0x10,%esp
80103fe4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fe7:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103fea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fed:	8d 50 6c             	lea    0x6c(%eax),%edx
80103ff0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ff3:	83 c0 6c             	add    $0x6c,%eax
80103ff6:	83 ec 04             	sub    $0x4,%esp
80103ff9:	6a 10                	push   $0x10
80103ffb:	52                   	push   %edx
80103ffc:	50                   	push   %eax
80103ffd:	e8 77 0d 00 00       	call   80104d79 <safestrcpy>
80104002:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104005:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104008:	8b 40 10             	mov    0x10(%eax),%eax
8010400b:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010400e:	83 ec 0c             	sub    $0xc,%esp
80104011:	68 00 55 19 80       	push   $0x80195500
80104016:	e8 b4 08 00 00       	call   801048cf <acquire>
8010401b:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010401e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104021:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104028:	83 ec 0c             	sub    $0xc,%esp
8010402b:	68 00 55 19 80       	push   $0x80195500
80104030:	e8 0c 09 00 00       	call   80104941 <release>
80104035:	83 c4 10             	add    $0x10,%esp

  return pid;
80104038:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010403b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010403e:	5b                   	pop    %ebx
8010403f:	5e                   	pop    %esi
80104040:	5f                   	pop    %edi
80104041:	5d                   	pop    %ebp
80104042:	c3                   	ret    

80104043 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104043:	f3 0f 1e fb          	endbr32 
80104047:	55                   	push   %ebp
80104048:	89 e5                	mov    %esp,%ebp
8010404a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010404d:	e8 57 fb ff ff       	call   80103ba9 <myproc>
80104052:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104055:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010405a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010405d:	75 0d                	jne    8010406c <exit+0x29>
    panic("init exiting");
8010405f:	83 ec 0c             	sub    $0xc,%esp
80104062:	68 92 a7 10 80       	push   $0x8010a792
80104067:	e8 59 c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010406c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104073:	eb 3f                	jmp    801040b4 <exit+0x71>
    if(curproc->ofile[fd]){
80104075:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104078:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010407b:	83 c2 08             	add    $0x8,%edx
8010407e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104082:	85 c0                	test   %eax,%eax
80104084:	74 2a                	je     801040b0 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104086:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104089:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010408c:	83 c2 08             	add    $0x8,%edx
8010408f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104093:	83 ec 0c             	sub    $0xc,%esp
80104096:	50                   	push   %eax
80104097:	e8 4d d0 ff ff       	call   801010e9 <fileclose>
8010409c:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010409f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040a5:	83 c2 08             	add    $0x8,%edx
801040a8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040af:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040b0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040b4:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040b8:	7e bb                	jle    80104075 <exit+0x32>
    }
  }

  begin_op();
801040ba:	e8 b2 f0 ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801040bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040c2:	8b 40 68             	mov    0x68(%eax),%eax
801040c5:	83 ec 0c             	sub    $0xc,%esp
801040c8:	50                   	push   %eax
801040c9:	e8 17 db ff ff       	call   80101be5 <iput>
801040ce:	83 c4 10             	add    $0x10,%esp
  end_op();
801040d1:	e8 2b f1 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
801040d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040d9:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040e0:	83 ec 0c             	sub    $0xc,%esp
801040e3:	68 00 55 19 80       	push   $0x80195500
801040e8:	e8 e2 07 00 00       	call   801048cf <acquire>
801040ed:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040f3:	8b 40 14             	mov    0x14(%eax),%eax
801040f6:	83 ec 0c             	sub    $0xc,%esp
801040f9:	50                   	push   %eax
801040fa:	e8 38 04 00 00       	call   80104537 <wakeup1>
801040ff:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104102:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104109:	eb 37                	jmp    80104142 <exit+0xff>
    if(p->parent == curproc){
8010410b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410e:	8b 40 14             	mov    0x14(%eax),%eax
80104111:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104114:	75 28                	jne    8010413e <exit+0xfb>
      p->parent = initproc;
80104116:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104125:	8b 40 0c             	mov    0xc(%eax),%eax
80104128:	83 f8 05             	cmp    $0x5,%eax
8010412b:	75 11                	jne    8010413e <exit+0xfb>
        wakeup1(initproc);
8010412d:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104132:	83 ec 0c             	sub    $0xc,%esp
80104135:	50                   	push   %eax
80104136:	e8 fc 03 00 00       	call   80104537 <wakeup1>
8010413b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010413e:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104142:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104149:	72 c0                	jb     8010410b <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010414b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010414e:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104155:	e8 ed 01 00 00       	call   80104347 <sched>
  panic("zombie exit");
8010415a:	83 ec 0c             	sub    $0xc,%esp
8010415d:	68 9f a7 10 80       	push   $0x8010a79f
80104162:	e8 5e c4 ff ff       	call   801005c5 <panic>

80104167 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104167:	f3 0f 1e fb          	endbr32 
8010416b:	55                   	push   %ebp
8010416c:	89 e5                	mov    %esp,%ebp
8010416e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104171:	e8 33 fa ff ff       	call   80103ba9 <myproc>
80104176:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104179:	83 ec 0c             	sub    $0xc,%esp
8010417c:	68 00 55 19 80       	push   $0x80195500
80104181:	e8 49 07 00 00       	call   801048cf <acquire>
80104186:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104189:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104190:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104197:	e9 a1 00 00 00       	jmp    8010423d <wait+0xd6>
      if(p->parent != curproc)
8010419c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419f:	8b 40 14             	mov    0x14(%eax),%eax
801041a2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041a5:	0f 85 8d 00 00 00    	jne    80104238 <wait+0xd1>
        continue;
      havekids = 1;
801041ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801041b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b5:	8b 40 0c             	mov    0xc(%eax),%eax
801041b8:	83 f8 05             	cmp    $0x5,%eax
801041bb:	75 7c                	jne    80104239 <wait+0xd2>
        // Found one.
        pid = p->pid;
801041bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c0:	8b 40 10             	mov    0x10(%eax),%eax
801041c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801041c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c9:	8b 40 08             	mov    0x8(%eax),%eax
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	50                   	push   %eax
801041d0:	e8 1f e6 ff ff       	call   801027f4 <kfree>
801041d5:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801041d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801041e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e5:	8b 40 04             	mov    0x4(%eax),%eax
801041e8:	83 ec 0c             	sub    $0xc,%esp
801041eb:	50                   	push   %eax
801041ec:	e8 7a 3a 00 00       	call   80107c6b <freevm>
801041f1:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801041f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104212:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104223:	83 ec 0c             	sub    $0xc,%esp
80104226:	68 00 55 19 80       	push   $0x80195500
8010422b:	e8 11 07 00 00       	call   80104941 <release>
80104230:	83 c4 10             	add    $0x10,%esp
        return pid;
80104233:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104236:	eb 51                	jmp    80104289 <wait+0x122>
        continue;
80104238:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104239:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010423d:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104244:	0f 82 52 ff ff ff    	jb     8010419c <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010424a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010424e:	74 0a                	je     8010425a <wait+0xf3>
80104250:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104253:	8b 40 24             	mov    0x24(%eax),%eax
80104256:	85 c0                	test   %eax,%eax
80104258:	74 17                	je     80104271 <wait+0x10a>
      release(&ptable.lock);
8010425a:	83 ec 0c             	sub    $0xc,%esp
8010425d:	68 00 55 19 80       	push   $0x80195500
80104262:	e8 da 06 00 00       	call   80104941 <release>
80104267:	83 c4 10             	add    $0x10,%esp
      return -1;
8010426a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010426f:	eb 18                	jmp    80104289 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104271:	83 ec 08             	sub    $0x8,%esp
80104274:	68 00 55 19 80       	push   $0x80195500
80104279:	ff 75 ec             	pushl  -0x14(%ebp)
8010427c:	e8 0b 02 00 00       	call   8010448c <sleep>
80104281:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104284:	e9 00 ff ff ff       	jmp    80104189 <wait+0x22>
  }
}
80104289:	c9                   	leave  
8010428a:	c3                   	ret    

8010428b <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010428b:	f3 0f 1e fb          	endbr32 
8010428f:	55                   	push   %ebp
80104290:	89 e5                	mov    %esp,%ebp
80104292:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104295:	e8 93 f8 ff ff       	call   80103b2d <mycpu>
8010429a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010429d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042a0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042a7:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801042aa:	e8 36 f8 ff ff       	call   80103ae5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801042af:	83 ec 0c             	sub    $0xc,%esp
801042b2:	68 00 55 19 80       	push   $0x80195500
801042b7:	e8 13 06 00 00       	call   801048cf <acquire>
801042bc:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042bf:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042c6:	eb 61                	jmp    80104329 <scheduler+0x9e>
      if(p->state != RUNNABLE)
801042c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cb:	8b 40 0c             	mov    0xc(%eax),%eax
801042ce:	83 f8 03             	cmp    $0x3,%eax
801042d1:	75 51                	jne    80104324 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801042d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d9:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801042df:	83 ec 0c             	sub    $0xc,%esp
801042e2:	ff 75 f4             	pushl  -0xc(%ebp)
801042e5:	e8 c8 34 00 00       	call   801077b2 <switchuvm>
801042ea:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801042ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f0:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801042f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fa:	8b 40 1c             	mov    0x1c(%eax),%eax
801042fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104300:	83 c2 04             	add    $0x4,%edx
80104303:	83 ec 08             	sub    $0x8,%esp
80104306:	50                   	push   %eax
80104307:	52                   	push   %edx
80104308:	e8 e5 0a 00 00       	call   80104df2 <swtch>
8010430d:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104310:	e8 80 34 00 00       	call   80107795 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104318:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010431f:	00 00 00 
80104322:	eb 01                	jmp    80104325 <scheduler+0x9a>
        continue;
80104324:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104325:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104329:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104330:	72 96                	jb     801042c8 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	68 00 55 19 80       	push   $0x80195500
8010433a:	e8 02 06 00 00       	call   80104941 <release>
8010433f:	83 c4 10             	add    $0x10,%esp
    sti();
80104342:	e9 63 ff ff ff       	jmp    801042aa <scheduler+0x1f>

80104347 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104347:	f3 0f 1e fb          	endbr32 
8010434b:	55                   	push   %ebp
8010434c:	89 e5                	mov    %esp,%ebp
8010434e:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104351:	e8 53 f8 ff ff       	call   80103ba9 <myproc>
80104356:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104359:	83 ec 0c             	sub    $0xc,%esp
8010435c:	68 00 55 19 80       	push   $0x80195500
80104361:	e8 b0 06 00 00       	call   80104a16 <holding>
80104366:	83 c4 10             	add    $0x10,%esp
80104369:	85 c0                	test   %eax,%eax
8010436b:	75 0d                	jne    8010437a <sched+0x33>
    panic("sched ptable.lock");
8010436d:	83 ec 0c             	sub    $0xc,%esp
80104370:	68 ab a7 10 80       	push   $0x8010a7ab
80104375:	e8 4b c2 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
8010437a:	e8 ae f7 ff ff       	call   80103b2d <mycpu>
8010437f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104385:	83 f8 01             	cmp    $0x1,%eax
80104388:	74 0d                	je     80104397 <sched+0x50>
    panic("sched locks");
8010438a:	83 ec 0c             	sub    $0xc,%esp
8010438d:	68 bd a7 10 80       	push   $0x8010a7bd
80104392:	e8 2e c2 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439a:	8b 40 0c             	mov    0xc(%eax),%eax
8010439d:	83 f8 04             	cmp    $0x4,%eax
801043a0:	75 0d                	jne    801043af <sched+0x68>
    panic("sched running");
801043a2:	83 ec 0c             	sub    $0xc,%esp
801043a5:	68 c9 a7 10 80       	push   $0x8010a7c9
801043aa:	e8 16 c2 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
801043af:	e8 21 f7 ff ff       	call   80103ad5 <readeflags>
801043b4:	25 00 02 00 00       	and    $0x200,%eax
801043b9:	85 c0                	test   %eax,%eax
801043bb:	74 0d                	je     801043ca <sched+0x83>
    panic("sched interruptible");
801043bd:	83 ec 0c             	sub    $0xc,%esp
801043c0:	68 d7 a7 10 80       	push   $0x8010a7d7
801043c5:	e8 fb c1 ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801043ca:	e8 5e f7 ff ff       	call   80103b2d <mycpu>
801043cf:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801043d8:	e8 50 f7 ff ff       	call   80103b2d <mycpu>
801043dd:	8b 40 04             	mov    0x4(%eax),%eax
801043e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e3:	83 c2 1c             	add    $0x1c,%edx
801043e6:	83 ec 08             	sub    $0x8,%esp
801043e9:	50                   	push   %eax
801043ea:	52                   	push   %edx
801043eb:	e8 02 0a 00 00       	call   80104df2 <swtch>
801043f0:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801043f3:	e8 35 f7 ff ff       	call   80103b2d <mycpu>
801043f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043fb:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104401:	90                   	nop
80104402:	c9                   	leave  
80104403:	c3                   	ret    

80104404 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104404:	f3 0f 1e fb          	endbr32 
80104408:	55                   	push   %ebp
80104409:	89 e5                	mov    %esp,%ebp
8010440b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010440e:	83 ec 0c             	sub    $0xc,%esp
80104411:	68 00 55 19 80       	push   $0x80195500
80104416:	e8 b4 04 00 00       	call   801048cf <acquire>
8010441b:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010441e:	e8 86 f7 ff ff       	call   80103ba9 <myproc>
80104423:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010442a:	e8 18 ff ff ff       	call   80104347 <sched>
  release(&ptable.lock);
8010442f:	83 ec 0c             	sub    $0xc,%esp
80104432:	68 00 55 19 80       	push   $0x80195500
80104437:	e8 05 05 00 00       	call   80104941 <release>
8010443c:	83 c4 10             	add    $0x10,%esp
}
8010443f:	90                   	nop
80104440:	c9                   	leave  
80104441:	c3                   	ret    

80104442 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104442:	f3 0f 1e fb          	endbr32 
80104446:	55                   	push   %ebp
80104447:	89 e5                	mov    %esp,%ebp
80104449:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010444c:	83 ec 0c             	sub    $0xc,%esp
8010444f:	68 00 55 19 80       	push   $0x80195500
80104454:	e8 e8 04 00 00       	call   80104941 <release>
80104459:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010445c:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104461:	85 c0                	test   %eax,%eax
80104463:	74 24                	je     80104489 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104465:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010446c:	00 00 00 
    iinit(ROOTDEV);
8010446f:	83 ec 0c             	sub    $0xc,%esp
80104472:	6a 01                	push   $0x1
80104474:	e8 7d d2 ff ff       	call   801016f6 <iinit>
80104479:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010447c:	83 ec 0c             	sub    $0xc,%esp
8010447f:	6a 01                	push   $0x1
80104481:	e8 b8 ea ff ff       	call   80102f3e <initlog>
80104486:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104489:	90                   	nop
8010448a:	c9                   	leave  
8010448b:	c3                   	ret    

8010448c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010448c:	f3 0f 1e fb          	endbr32 
80104490:	55                   	push   %ebp
80104491:	89 e5                	mov    %esp,%ebp
80104493:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104496:	e8 0e f7 ff ff       	call   80103ba9 <myproc>
8010449b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010449e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044a2:	75 0d                	jne    801044b1 <sleep+0x25>
    panic("sleep");
801044a4:	83 ec 0c             	sub    $0xc,%esp
801044a7:	68 eb a7 10 80       	push   $0x8010a7eb
801044ac:	e8 14 c1 ff ff       	call   801005c5 <panic>

  if(lk == 0)
801044b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044b5:	75 0d                	jne    801044c4 <sleep+0x38>
    panic("sleep without lk");
801044b7:	83 ec 0c             	sub    $0xc,%esp
801044ba:	68 f1 a7 10 80       	push   $0x8010a7f1
801044bf:	e8 01 c1 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044c4:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801044cb:	74 1e                	je     801044eb <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801044cd:	83 ec 0c             	sub    $0xc,%esp
801044d0:	68 00 55 19 80       	push   $0x80195500
801044d5:	e8 f5 03 00 00       	call   801048cf <acquire>
801044da:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044dd:	83 ec 0c             	sub    $0xc,%esp
801044e0:	ff 75 0c             	pushl  0xc(%ebp)
801044e3:	e8 59 04 00 00       	call   80104941 <release>
801044e8:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801044eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ee:	8b 55 08             	mov    0x8(%ebp),%edx
801044f1:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801044fe:	e8 44 fe ff ff       	call   80104347 <sched>

  // Tidy up.
  p->chan = 0;
80104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104506:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010450d:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104514:	74 1e                	je     80104534 <sleep+0xa8>
    release(&ptable.lock);
80104516:	83 ec 0c             	sub    $0xc,%esp
80104519:	68 00 55 19 80       	push   $0x80195500
8010451e:	e8 1e 04 00 00       	call   80104941 <release>
80104523:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104526:	83 ec 0c             	sub    $0xc,%esp
80104529:	ff 75 0c             	pushl  0xc(%ebp)
8010452c:	e8 9e 03 00 00       	call   801048cf <acquire>
80104531:	83 c4 10             	add    $0x10,%esp
  }
}
80104534:	90                   	nop
80104535:	c9                   	leave  
80104536:	c3                   	ret    

80104537 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104537:	f3 0f 1e fb          	endbr32 
8010453b:	55                   	push   %ebp
8010453c:	89 e5                	mov    %esp,%ebp
8010453e:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104541:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
80104548:	eb 24                	jmp    8010456e <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
8010454a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010454d:	8b 40 0c             	mov    0xc(%eax),%eax
80104550:	83 f8 02             	cmp    $0x2,%eax
80104553:	75 15                	jne    8010456a <wakeup1+0x33>
80104555:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104558:	8b 40 20             	mov    0x20(%eax),%eax
8010455b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010455e:	75 0a                	jne    8010456a <wakeup1+0x33>
      p->state = RUNNABLE;
80104560:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104563:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010456a:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
8010456e:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
80104575:	72 d3                	jb     8010454a <wakeup1+0x13>
}
80104577:	90                   	nop
80104578:	90                   	nop
80104579:	c9                   	leave  
8010457a:	c3                   	ret    

8010457b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010457b:	f3 0f 1e fb          	endbr32 
8010457f:	55                   	push   %ebp
80104580:	89 e5                	mov    %esp,%ebp
80104582:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104585:	83 ec 0c             	sub    $0xc,%esp
80104588:	68 00 55 19 80       	push   $0x80195500
8010458d:	e8 3d 03 00 00       	call   801048cf <acquire>
80104592:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104595:	83 ec 0c             	sub    $0xc,%esp
80104598:	ff 75 08             	pushl  0x8(%ebp)
8010459b:	e8 97 ff ff ff       	call   80104537 <wakeup1>
801045a0:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801045a3:	83 ec 0c             	sub    $0xc,%esp
801045a6:	68 00 55 19 80       	push   $0x80195500
801045ab:	e8 91 03 00 00       	call   80104941 <release>
801045b0:	83 c4 10             	add    $0x10,%esp
}
801045b3:	90                   	nop
801045b4:	c9                   	leave  
801045b5:	c3                   	ret    

801045b6 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045b6:	f3 0f 1e fb          	endbr32 
801045ba:	55                   	push   %ebp
801045bb:	89 e5                	mov    %esp,%ebp
801045bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801045c0:	83 ec 0c             	sub    $0xc,%esp
801045c3:	68 00 55 19 80       	push   $0x80195500
801045c8:	e8 02 03 00 00       	call   801048cf <acquire>
801045cd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045d0:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801045d7:	eb 45                	jmp    8010461e <kill+0x68>
    if(p->pid == pid){
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	8b 40 10             	mov    0x10(%eax),%eax
801045df:	39 45 08             	cmp    %eax,0x8(%ebp)
801045e2:	75 36                	jne    8010461a <kill+0x64>
      p->killed = 1;
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801045ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f1:	8b 40 0c             	mov    0xc(%eax),%eax
801045f4:	83 f8 02             	cmp    $0x2,%eax
801045f7:	75 0a                	jne    80104603 <kill+0x4d>
        p->state = RUNNABLE;
801045f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104603:	83 ec 0c             	sub    $0xc,%esp
80104606:	68 00 55 19 80       	push   $0x80195500
8010460b:	e8 31 03 00 00       	call   80104941 <release>
80104610:	83 c4 10             	add    $0x10,%esp
      return 0;
80104613:	b8 00 00 00 00       	mov    $0x0,%eax
80104618:	eb 22                	jmp    8010463c <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010461a:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010461e:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104625:	72 b2                	jb     801045d9 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104627:	83 ec 0c             	sub    $0xc,%esp
8010462a:	68 00 55 19 80       	push   $0x80195500
8010462f:	e8 0d 03 00 00       	call   80104941 <release>
80104634:	83 c4 10             	add    $0x10,%esp
  return -1;
80104637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010463c:	c9                   	leave  
8010463d:	c3                   	ret    

8010463e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010463e:	f3 0f 1e fb          	endbr32 
80104642:	55                   	push   %ebp
80104643:	89 e5                	mov    %esp,%ebp
80104645:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104648:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
8010464f:	e9 d7 00 00 00       	jmp    8010472b <procdump+0xed>
    if(p->state == UNUSED)
80104654:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104657:	8b 40 0c             	mov    0xc(%eax),%eax
8010465a:	85 c0                	test   %eax,%eax
8010465c:	0f 84 c4 00 00 00    	je     80104726 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104662:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104665:	8b 40 0c             	mov    0xc(%eax),%eax
80104668:	83 f8 05             	cmp    $0x5,%eax
8010466b:	77 23                	ja     80104690 <procdump+0x52>
8010466d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104670:	8b 40 0c             	mov    0xc(%eax),%eax
80104673:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010467a:	85 c0                	test   %eax,%eax
8010467c:	74 12                	je     80104690 <procdump+0x52>
      state = states[p->state];
8010467e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104681:	8b 40 0c             	mov    0xc(%eax),%eax
80104684:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010468b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010468e:	eb 07                	jmp    80104697 <procdump+0x59>
    else
      state = "???";
80104690:	c7 45 ec 02 a8 10 80 	movl   $0x8010a802,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010469a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010469d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a0:	8b 40 10             	mov    0x10(%eax),%eax
801046a3:	52                   	push   %edx
801046a4:	ff 75 ec             	pushl  -0x14(%ebp)
801046a7:	50                   	push   %eax
801046a8:	68 06 a8 10 80       	push   $0x8010a806
801046ad:	e8 5a bd ff ff       	call   8010040c <cprintf>
801046b2:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b8:	8b 40 0c             	mov    0xc(%eax),%eax
801046bb:	83 f8 02             	cmp    $0x2,%eax
801046be:	75 54                	jne    80104714 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046c3:	8b 40 1c             	mov    0x1c(%eax),%eax
801046c6:	8b 40 0c             	mov    0xc(%eax),%eax
801046c9:	83 c0 08             	add    $0x8,%eax
801046cc:	89 c2                	mov    %eax,%edx
801046ce:	83 ec 08             	sub    $0x8,%esp
801046d1:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046d4:	50                   	push   %eax
801046d5:	52                   	push   %edx
801046d6:	e8 bc 02 00 00       	call   80104997 <getcallerpcs>
801046db:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046e5:	eb 1c                	jmp    80104703 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801046e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ea:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046ee:	83 ec 08             	sub    $0x8,%esp
801046f1:	50                   	push   %eax
801046f2:	68 0f a8 10 80       	push   $0x8010a80f
801046f7:	e8 10 bd ff ff       	call   8010040c <cprintf>
801046fc:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104703:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104707:	7f 0b                	jg     80104714 <procdump+0xd6>
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104710:	85 c0                	test   %eax,%eax
80104712:	75 d3                	jne    801046e7 <procdump+0xa9>
    }
    cprintf("\n");
80104714:	83 ec 0c             	sub    $0xc,%esp
80104717:	68 13 a8 10 80       	push   $0x8010a813
8010471c:	e8 eb bc ff ff       	call   8010040c <cprintf>
80104721:	83 c4 10             	add    $0x10,%esp
80104724:	eb 01                	jmp    80104727 <procdump+0xe9>
      continue;
80104726:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104727:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
8010472b:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
80104732:	0f 82 1c ff ff ff    	jb     80104654 <procdump+0x16>
  }
}
80104738:	90                   	nop
80104739:	90                   	nop
8010473a:	c9                   	leave  
8010473b:	c3                   	ret    

8010473c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010473c:	f3 0f 1e fb          	endbr32 
80104740:	55                   	push   %ebp
80104741:	89 e5                	mov    %esp,%ebp
80104743:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104746:	8b 45 08             	mov    0x8(%ebp),%eax
80104749:	83 c0 04             	add    $0x4,%eax
8010474c:	83 ec 08             	sub    $0x8,%esp
8010474f:	68 3f a8 10 80       	push   $0x8010a83f
80104754:	50                   	push   %eax
80104755:	e8 4f 01 00 00       	call   801048a9 <initlock>
8010475a:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010475d:	8b 45 08             	mov    0x8(%ebp),%eax
80104760:	8b 55 0c             	mov    0xc(%ebp),%edx
80104763:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104766:	8b 45 08             	mov    0x8(%ebp),%eax
80104769:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010476f:	8b 45 08             	mov    0x8(%ebp),%eax
80104772:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104779:	90                   	nop
8010477a:	c9                   	leave  
8010477b:	c3                   	ret    

8010477c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010477c:	f3 0f 1e fb          	endbr32 
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104786:	8b 45 08             	mov    0x8(%ebp),%eax
80104789:	83 c0 04             	add    $0x4,%eax
8010478c:	83 ec 0c             	sub    $0xc,%esp
8010478f:	50                   	push   %eax
80104790:	e8 3a 01 00 00       	call   801048cf <acquire>
80104795:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104798:	eb 15                	jmp    801047af <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010479a:	8b 45 08             	mov    0x8(%ebp),%eax
8010479d:	83 c0 04             	add    $0x4,%eax
801047a0:	83 ec 08             	sub    $0x8,%esp
801047a3:	50                   	push   %eax
801047a4:	ff 75 08             	pushl  0x8(%ebp)
801047a7:	e8 e0 fc ff ff       	call   8010448c <sleep>
801047ac:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047af:	8b 45 08             	mov    0x8(%ebp),%eax
801047b2:	8b 00                	mov    (%eax),%eax
801047b4:	85 c0                	test   %eax,%eax
801047b6:	75 e2                	jne    8010479a <acquiresleep+0x1e>
  }
  lk->locked = 1;
801047b8:	8b 45 08             	mov    0x8(%ebp),%eax
801047bb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801047c1:	e8 e3 f3 ff ff       	call   80103ba9 <myproc>
801047c6:	8b 50 10             	mov    0x10(%eax),%edx
801047c9:	8b 45 08             	mov    0x8(%ebp),%eax
801047cc:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801047cf:	8b 45 08             	mov    0x8(%ebp),%eax
801047d2:	83 c0 04             	add    $0x4,%eax
801047d5:	83 ec 0c             	sub    $0xc,%esp
801047d8:	50                   	push   %eax
801047d9:	e8 63 01 00 00       	call   80104941 <release>
801047de:	83 c4 10             	add    $0x10,%esp
}
801047e1:	90                   	nop
801047e2:	c9                   	leave  
801047e3:	c3                   	ret    

801047e4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801047e4:	f3 0f 1e fb          	endbr32 
801047e8:	55                   	push   %ebp
801047e9:	89 e5                	mov    %esp,%ebp
801047eb:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801047ee:	8b 45 08             	mov    0x8(%ebp),%eax
801047f1:	83 c0 04             	add    $0x4,%eax
801047f4:	83 ec 0c             	sub    $0xc,%esp
801047f7:	50                   	push   %eax
801047f8:	e8 d2 00 00 00       	call   801048cf <acquire>
801047fd:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104800:	8b 45 08             	mov    0x8(%ebp),%eax
80104803:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104809:	8b 45 08             	mov    0x8(%ebp),%eax
8010480c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104813:	83 ec 0c             	sub    $0xc,%esp
80104816:	ff 75 08             	pushl  0x8(%ebp)
80104819:	e8 5d fd ff ff       	call   8010457b <wakeup>
8010481e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104821:	8b 45 08             	mov    0x8(%ebp),%eax
80104824:	83 c0 04             	add    $0x4,%eax
80104827:	83 ec 0c             	sub    $0xc,%esp
8010482a:	50                   	push   %eax
8010482b:	e8 11 01 00 00       	call   80104941 <release>
80104830:	83 c4 10             	add    $0x10,%esp
}
80104833:	90                   	nop
80104834:	c9                   	leave  
80104835:	c3                   	ret    

80104836 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104836:	f3 0f 1e fb          	endbr32 
8010483a:	55                   	push   %ebp
8010483b:	89 e5                	mov    %esp,%ebp
8010483d:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104840:	8b 45 08             	mov    0x8(%ebp),%eax
80104843:	83 c0 04             	add    $0x4,%eax
80104846:	83 ec 0c             	sub    $0xc,%esp
80104849:	50                   	push   %eax
8010484a:	e8 80 00 00 00       	call   801048cf <acquire>
8010484f:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104852:	8b 45 08             	mov    0x8(%ebp),%eax
80104855:	8b 00                	mov    (%eax),%eax
80104857:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010485a:	8b 45 08             	mov    0x8(%ebp),%eax
8010485d:	83 c0 04             	add    $0x4,%eax
80104860:	83 ec 0c             	sub    $0xc,%esp
80104863:	50                   	push   %eax
80104864:	e8 d8 00 00 00       	call   80104941 <release>
80104869:	83 c4 10             	add    $0x10,%esp
  return r;
8010486c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010486f:	c9                   	leave  
80104870:	c3                   	ret    

80104871 <readeflags>:
{
80104871:	55                   	push   %ebp
80104872:	89 e5                	mov    %esp,%ebp
80104874:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104877:	9c                   	pushf  
80104878:	58                   	pop    %eax
80104879:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010487c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010487f:	c9                   	leave  
80104880:	c3                   	ret    

80104881 <cli>:
{
80104881:	55                   	push   %ebp
80104882:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104884:	fa                   	cli    
}
80104885:	90                   	nop
80104886:	5d                   	pop    %ebp
80104887:	c3                   	ret    

80104888 <sti>:
{
80104888:	55                   	push   %ebp
80104889:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010488b:	fb                   	sti    
}
8010488c:	90                   	nop
8010488d:	5d                   	pop    %ebp
8010488e:	c3                   	ret    

8010488f <xchg>:
{
8010488f:	55                   	push   %ebp
80104890:	89 e5                	mov    %esp,%ebp
80104892:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104895:	8b 55 08             	mov    0x8(%ebp),%edx
80104898:	8b 45 0c             	mov    0xc(%ebp),%eax
8010489b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010489e:	f0 87 02             	lock xchg %eax,(%edx)
801048a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801048a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801048a7:	c9                   	leave  
801048a8:	c3                   	ret    

801048a9 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801048a9:	f3 0f 1e fb          	endbr32 
801048ad:	55                   	push   %ebp
801048ae:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801048b0:	8b 45 08             	mov    0x8(%ebp),%eax
801048b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801048b6:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801048b9:	8b 45 08             	mov    0x8(%ebp),%eax
801048bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801048c2:	8b 45 08             	mov    0x8(%ebp),%eax
801048c5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801048cc:	90                   	nop
801048cd:	5d                   	pop    %ebp
801048ce:	c3                   	ret    

801048cf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801048cf:	f3 0f 1e fb          	endbr32 
801048d3:	55                   	push   %ebp
801048d4:	89 e5                	mov    %esp,%ebp
801048d6:	53                   	push   %ebx
801048d7:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801048da:	e8 6c 01 00 00       	call   80104a4b <pushcli>
  if(holding(lk)){
801048df:	8b 45 08             	mov    0x8(%ebp),%eax
801048e2:	83 ec 0c             	sub    $0xc,%esp
801048e5:	50                   	push   %eax
801048e6:	e8 2b 01 00 00       	call   80104a16 <holding>
801048eb:	83 c4 10             	add    $0x10,%esp
801048ee:	85 c0                	test   %eax,%eax
801048f0:	74 0d                	je     801048ff <acquire+0x30>
    panic("acquire");
801048f2:	83 ec 0c             	sub    $0xc,%esp
801048f5:	68 4a a8 10 80       	push   $0x8010a84a
801048fa:	e8 c6 bc ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801048ff:	90                   	nop
80104900:	8b 45 08             	mov    0x8(%ebp),%eax
80104903:	83 ec 08             	sub    $0x8,%esp
80104906:	6a 01                	push   $0x1
80104908:	50                   	push   %eax
80104909:	e8 81 ff ff ff       	call   8010488f <xchg>
8010490e:	83 c4 10             	add    $0x10,%esp
80104911:	85 c0                	test   %eax,%eax
80104913:	75 eb                	jne    80104900 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104915:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010491a:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010491d:	e8 0b f2 ff ff       	call   80103b2d <mycpu>
80104922:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104925:	8b 45 08             	mov    0x8(%ebp),%eax
80104928:	83 c0 0c             	add    $0xc,%eax
8010492b:	83 ec 08             	sub    $0x8,%esp
8010492e:	50                   	push   %eax
8010492f:	8d 45 08             	lea    0x8(%ebp),%eax
80104932:	50                   	push   %eax
80104933:	e8 5f 00 00 00       	call   80104997 <getcallerpcs>
80104938:	83 c4 10             	add    $0x10,%esp
}
8010493b:	90                   	nop
8010493c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010493f:	c9                   	leave  
80104940:	c3                   	ret    

80104941 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104941:	f3 0f 1e fb          	endbr32 
80104945:	55                   	push   %ebp
80104946:	89 e5                	mov    %esp,%ebp
80104948:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010494b:	83 ec 0c             	sub    $0xc,%esp
8010494e:	ff 75 08             	pushl  0x8(%ebp)
80104951:	e8 c0 00 00 00       	call   80104a16 <holding>
80104956:	83 c4 10             	add    $0x10,%esp
80104959:	85 c0                	test   %eax,%eax
8010495b:	75 0d                	jne    8010496a <release+0x29>
    panic("release");
8010495d:	83 ec 0c             	sub    $0xc,%esp
80104960:	68 52 a8 10 80       	push   $0x8010a852
80104965:	e8 5b bc ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
8010496a:	8b 45 08             	mov    0x8(%ebp),%eax
8010496d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104974:	8b 45 08             	mov    0x8(%ebp),%eax
80104977:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010497e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104983:	8b 45 08             	mov    0x8(%ebp),%eax
80104986:	8b 55 08             	mov    0x8(%ebp),%edx
80104989:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010498f:	e8 08 01 00 00       	call   80104a9c <popcli>
}
80104994:	90                   	nop
80104995:	c9                   	leave  
80104996:	c3                   	ret    

80104997 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104997:	f3 0f 1e fb          	endbr32 
8010499b:	55                   	push   %ebp
8010499c:	89 e5                	mov    %esp,%ebp
8010499e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801049a1:	8b 45 08             	mov    0x8(%ebp),%eax
801049a4:	83 e8 08             	sub    $0x8,%eax
801049a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049aa:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801049b1:	eb 38                	jmp    801049eb <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801049b3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801049b7:	74 53                	je     80104a0c <getcallerpcs+0x75>
801049b9:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801049c0:	76 4a                	jbe    80104a0c <getcallerpcs+0x75>
801049c2:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801049c6:	74 44                	je     80104a0c <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801049c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801049d5:	01 c2                	add    %eax,%edx
801049d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049da:	8b 40 04             	mov    0x4(%eax),%eax
801049dd:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801049df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049e2:	8b 00                	mov    (%eax),%eax
801049e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049e7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801049eb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801049ef:	7e c2                	jle    801049b3 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801049f1:	eb 19                	jmp    80104a0c <getcallerpcs+0x75>
    pcs[i] = 0;
801049f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a00:	01 d0                	add    %edx,%eax
80104a02:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a08:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a0c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a10:	7e e1                	jle    801049f3 <getcallerpcs+0x5c>
}
80104a12:	90                   	nop
80104a13:	90                   	nop
80104a14:	c9                   	leave  
80104a15:	c3                   	ret    

80104a16 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104a16:	f3 0f 1e fb          	endbr32 
80104a1a:	55                   	push   %ebp
80104a1b:	89 e5                	mov    %esp,%ebp
80104a1d:	53                   	push   %ebx
80104a1e:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104a21:	8b 45 08             	mov    0x8(%ebp),%eax
80104a24:	8b 00                	mov    (%eax),%eax
80104a26:	85 c0                	test   %eax,%eax
80104a28:	74 16                	je     80104a40 <holding+0x2a>
80104a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2d:	8b 58 08             	mov    0x8(%eax),%ebx
80104a30:	e8 f8 f0 ff ff       	call   80103b2d <mycpu>
80104a35:	39 c3                	cmp    %eax,%ebx
80104a37:	75 07                	jne    80104a40 <holding+0x2a>
80104a39:	b8 01 00 00 00       	mov    $0x1,%eax
80104a3e:	eb 05                	jmp    80104a45 <holding+0x2f>
80104a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a45:	83 c4 04             	add    $0x4,%esp
80104a48:	5b                   	pop    %ebx
80104a49:	5d                   	pop    %ebp
80104a4a:	c3                   	ret    

80104a4b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a4b:	f3 0f 1e fb          	endbr32 
80104a4f:	55                   	push   %ebp
80104a50:	89 e5                	mov    %esp,%ebp
80104a52:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104a55:	e8 17 fe ff ff       	call   80104871 <readeflags>
80104a5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104a5d:	e8 1f fe ff ff       	call   80104881 <cli>
  if(mycpu()->ncli == 0)
80104a62:	e8 c6 f0 ff ff       	call   80103b2d <mycpu>
80104a67:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a6d:	85 c0                	test   %eax,%eax
80104a6f:	75 14                	jne    80104a85 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104a71:	e8 b7 f0 ff ff       	call   80103b2d <mycpu>
80104a76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a79:	81 e2 00 02 00 00    	and    $0x200,%edx
80104a7f:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104a85:	e8 a3 f0 ff ff       	call   80103b2d <mycpu>
80104a8a:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a90:	83 c2 01             	add    $0x1,%edx
80104a93:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a99:	90                   	nop
80104a9a:	c9                   	leave  
80104a9b:	c3                   	ret    

80104a9c <popcli>:

void
popcli(void)
{
80104a9c:	f3 0f 1e fb          	endbr32 
80104aa0:	55                   	push   %ebp
80104aa1:	89 e5                	mov    %esp,%ebp
80104aa3:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104aa6:	e8 c6 fd ff ff       	call   80104871 <readeflags>
80104aab:	25 00 02 00 00       	and    $0x200,%eax
80104ab0:	85 c0                	test   %eax,%eax
80104ab2:	74 0d                	je     80104ac1 <popcli+0x25>
    panic("popcli - interruptible");
80104ab4:	83 ec 0c             	sub    $0xc,%esp
80104ab7:	68 5a a8 10 80       	push   $0x8010a85a
80104abc:	e8 04 bb ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104ac1:	e8 67 f0 ff ff       	call   80103b2d <mycpu>
80104ac6:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104acc:	83 ea 01             	sub    $0x1,%edx
80104acf:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104ad5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104adb:	85 c0                	test   %eax,%eax
80104add:	79 0d                	jns    80104aec <popcli+0x50>
    panic("popcli");
80104adf:	83 ec 0c             	sub    $0xc,%esp
80104ae2:	68 71 a8 10 80       	push   $0x8010a871
80104ae7:	e8 d9 ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104aec:	e8 3c f0 ff ff       	call   80103b2d <mycpu>
80104af1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104af7:	85 c0                	test   %eax,%eax
80104af9:	75 14                	jne    80104b0f <popcli+0x73>
80104afb:	e8 2d f0 ff ff       	call   80103b2d <mycpu>
80104b00:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b06:	85 c0                	test   %eax,%eax
80104b08:	74 05                	je     80104b0f <popcli+0x73>
    sti();
80104b0a:	e8 79 fd ff ff       	call   80104888 <sti>
}
80104b0f:	90                   	nop
80104b10:	c9                   	leave  
80104b11:	c3                   	ret    

80104b12 <stosb>:
{
80104b12:	55                   	push   %ebp
80104b13:	89 e5                	mov    %esp,%ebp
80104b15:	57                   	push   %edi
80104b16:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104b17:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b1a:	8b 55 10             	mov    0x10(%ebp),%edx
80104b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b20:	89 cb                	mov    %ecx,%ebx
80104b22:	89 df                	mov    %ebx,%edi
80104b24:	89 d1                	mov    %edx,%ecx
80104b26:	fc                   	cld    
80104b27:	f3 aa                	rep stos %al,%es:(%edi)
80104b29:	89 ca                	mov    %ecx,%edx
80104b2b:	89 fb                	mov    %edi,%ebx
80104b2d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b30:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b33:	90                   	nop
80104b34:	5b                   	pop    %ebx
80104b35:	5f                   	pop    %edi
80104b36:	5d                   	pop    %ebp
80104b37:	c3                   	ret    

80104b38 <stosl>:
{
80104b38:	55                   	push   %ebp
80104b39:	89 e5                	mov    %esp,%ebp
80104b3b:	57                   	push   %edi
80104b3c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b40:	8b 55 10             	mov    0x10(%ebp),%edx
80104b43:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b46:	89 cb                	mov    %ecx,%ebx
80104b48:	89 df                	mov    %ebx,%edi
80104b4a:	89 d1                	mov    %edx,%ecx
80104b4c:	fc                   	cld    
80104b4d:	f3 ab                	rep stos %eax,%es:(%edi)
80104b4f:	89 ca                	mov    %ecx,%edx
80104b51:	89 fb                	mov    %edi,%ebx
80104b53:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b56:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b59:	90                   	nop
80104b5a:	5b                   	pop    %ebx
80104b5b:	5f                   	pop    %edi
80104b5c:	5d                   	pop    %ebp
80104b5d:	c3                   	ret    

80104b5e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104b5e:	f3 0f 1e fb          	endbr32 
80104b62:	55                   	push   %ebp
80104b63:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104b65:	8b 45 08             	mov    0x8(%ebp),%eax
80104b68:	83 e0 03             	and    $0x3,%eax
80104b6b:	85 c0                	test   %eax,%eax
80104b6d:	75 43                	jne    80104bb2 <memset+0x54>
80104b6f:	8b 45 10             	mov    0x10(%ebp),%eax
80104b72:	83 e0 03             	and    $0x3,%eax
80104b75:	85 c0                	test   %eax,%eax
80104b77:	75 39                	jne    80104bb2 <memset+0x54>
    c &= 0xFF;
80104b79:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b80:	8b 45 10             	mov    0x10(%ebp),%eax
80104b83:	c1 e8 02             	shr    $0x2,%eax
80104b86:	89 c1                	mov    %eax,%ecx
80104b88:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b8b:	c1 e0 18             	shl    $0x18,%eax
80104b8e:	89 c2                	mov    %eax,%edx
80104b90:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b93:	c1 e0 10             	shl    $0x10,%eax
80104b96:	09 c2                	or     %eax,%edx
80104b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9b:	c1 e0 08             	shl    $0x8,%eax
80104b9e:	09 d0                	or     %edx,%eax
80104ba0:	0b 45 0c             	or     0xc(%ebp),%eax
80104ba3:	51                   	push   %ecx
80104ba4:	50                   	push   %eax
80104ba5:	ff 75 08             	pushl  0x8(%ebp)
80104ba8:	e8 8b ff ff ff       	call   80104b38 <stosl>
80104bad:	83 c4 0c             	add    $0xc,%esp
80104bb0:	eb 12                	jmp    80104bc4 <memset+0x66>
  } else
    stosb(dst, c, n);
80104bb2:	8b 45 10             	mov    0x10(%ebp),%eax
80104bb5:	50                   	push   %eax
80104bb6:	ff 75 0c             	pushl  0xc(%ebp)
80104bb9:	ff 75 08             	pushl  0x8(%ebp)
80104bbc:	e8 51 ff ff ff       	call   80104b12 <stosb>
80104bc1:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104bc4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104bc7:	c9                   	leave  
80104bc8:	c3                   	ret    

80104bc9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104bc9:	f3 0f 1e fb          	endbr32 
80104bcd:	55                   	push   %ebp
80104bce:	89 e5                	mov    %esp,%ebp
80104bd0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bdc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104bdf:	eb 30                	jmp    80104c11 <memcmp+0x48>
    if(*s1 != *s2)
80104be1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104be4:	0f b6 10             	movzbl (%eax),%edx
80104be7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bea:	0f b6 00             	movzbl (%eax),%eax
80104bed:	38 c2                	cmp    %al,%dl
80104bef:	74 18                	je     80104c09 <memcmp+0x40>
      return *s1 - *s2;
80104bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bf4:	0f b6 00             	movzbl (%eax),%eax
80104bf7:	0f b6 d0             	movzbl %al,%edx
80104bfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bfd:	0f b6 00             	movzbl (%eax),%eax
80104c00:	0f b6 c0             	movzbl %al,%eax
80104c03:	29 c2                	sub    %eax,%edx
80104c05:	89 d0                	mov    %edx,%eax
80104c07:	eb 1a                	jmp    80104c23 <memcmp+0x5a>
    s1++, s2++;
80104c09:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c0d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104c11:	8b 45 10             	mov    0x10(%ebp),%eax
80104c14:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c17:	89 55 10             	mov    %edx,0x10(%ebp)
80104c1a:	85 c0                	test   %eax,%eax
80104c1c:	75 c3                	jne    80104be1 <memcmp+0x18>
  }

  return 0;
80104c1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c23:	c9                   	leave  
80104c24:	c3                   	ret    

80104c25 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104c25:	f3 0f 1e fb          	endbr32 
80104c29:	55                   	push   %ebp
80104c2a:	89 e5                	mov    %esp,%ebp
80104c2c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104c35:	8b 45 08             	mov    0x8(%ebp),%eax
80104c38:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104c3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c3e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104c41:	73 54                	jae    80104c97 <memmove+0x72>
80104c43:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c46:	8b 45 10             	mov    0x10(%ebp),%eax
80104c49:	01 d0                	add    %edx,%eax
80104c4b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104c4e:	73 47                	jae    80104c97 <memmove+0x72>
    s += n;
80104c50:	8b 45 10             	mov    0x10(%ebp),%eax
80104c53:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104c56:	8b 45 10             	mov    0x10(%ebp),%eax
80104c59:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104c5c:	eb 13                	jmp    80104c71 <memmove+0x4c>
      *--d = *--s;
80104c5e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104c62:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104c66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c69:	0f b6 10             	movzbl (%eax),%edx
80104c6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c6f:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c71:	8b 45 10             	mov    0x10(%ebp),%eax
80104c74:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c77:	89 55 10             	mov    %edx,0x10(%ebp)
80104c7a:	85 c0                	test   %eax,%eax
80104c7c:	75 e0                	jne    80104c5e <memmove+0x39>
  if(s < d && s + n > d){
80104c7e:	eb 24                	jmp    80104ca4 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104c80:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c83:	8d 42 01             	lea    0x1(%edx),%eax
80104c86:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c89:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c8c:	8d 48 01             	lea    0x1(%eax),%ecx
80104c8f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104c92:	0f b6 12             	movzbl (%edx),%edx
80104c95:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c97:	8b 45 10             	mov    0x10(%ebp),%eax
80104c9a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c9d:	89 55 10             	mov    %edx,0x10(%ebp)
80104ca0:	85 c0                	test   %eax,%eax
80104ca2:	75 dc                	jne    80104c80 <memmove+0x5b>

  return dst;
80104ca4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ca7:	c9                   	leave  
80104ca8:	c3                   	ret    

80104ca9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ca9:	f3 0f 1e fb          	endbr32 
80104cad:	55                   	push   %ebp
80104cae:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104cb0:	ff 75 10             	pushl  0x10(%ebp)
80104cb3:	ff 75 0c             	pushl  0xc(%ebp)
80104cb6:	ff 75 08             	pushl  0x8(%ebp)
80104cb9:	e8 67 ff ff ff       	call   80104c25 <memmove>
80104cbe:	83 c4 0c             	add    $0xc,%esp
}
80104cc1:	c9                   	leave  
80104cc2:	c3                   	ret    

80104cc3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104cc3:	f3 0f 1e fb          	endbr32 
80104cc7:	55                   	push   %ebp
80104cc8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104cca:	eb 0c                	jmp    80104cd8 <strncmp+0x15>
    n--, p++, q++;
80104ccc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cd0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104cd4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104cd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cdc:	74 1a                	je     80104cf8 <strncmp+0x35>
80104cde:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce1:	0f b6 00             	movzbl (%eax),%eax
80104ce4:	84 c0                	test   %al,%al
80104ce6:	74 10                	je     80104cf8 <strncmp+0x35>
80104ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ceb:	0f b6 10             	movzbl (%eax),%edx
80104cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cf1:	0f b6 00             	movzbl (%eax),%eax
80104cf4:	38 c2                	cmp    %al,%dl
80104cf6:	74 d4                	je     80104ccc <strncmp+0x9>
  if(n == 0)
80104cf8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cfc:	75 07                	jne    80104d05 <strncmp+0x42>
    return 0;
80104cfe:	b8 00 00 00 00       	mov    $0x0,%eax
80104d03:	eb 16                	jmp    80104d1b <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104d05:	8b 45 08             	mov    0x8(%ebp),%eax
80104d08:	0f b6 00             	movzbl (%eax),%eax
80104d0b:	0f b6 d0             	movzbl %al,%edx
80104d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d11:	0f b6 00             	movzbl (%eax),%eax
80104d14:	0f b6 c0             	movzbl %al,%eax
80104d17:	29 c2                	sub    %eax,%edx
80104d19:	89 d0                	mov    %edx,%eax
}
80104d1b:	5d                   	pop    %ebp
80104d1c:	c3                   	ret    

80104d1d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d1d:	f3 0f 1e fb          	endbr32 
80104d21:	55                   	push   %ebp
80104d22:	89 e5                	mov    %esp,%ebp
80104d24:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d27:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d2d:	90                   	nop
80104d2e:	8b 45 10             	mov    0x10(%ebp),%eax
80104d31:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d34:	89 55 10             	mov    %edx,0x10(%ebp)
80104d37:	85 c0                	test   %eax,%eax
80104d39:	7e 2c                	jle    80104d67 <strncpy+0x4a>
80104d3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d3e:	8d 42 01             	lea    0x1(%edx),%eax
80104d41:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d44:	8b 45 08             	mov    0x8(%ebp),%eax
80104d47:	8d 48 01             	lea    0x1(%eax),%ecx
80104d4a:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d4d:	0f b6 12             	movzbl (%edx),%edx
80104d50:	88 10                	mov    %dl,(%eax)
80104d52:	0f b6 00             	movzbl (%eax),%eax
80104d55:	84 c0                	test   %al,%al
80104d57:	75 d5                	jne    80104d2e <strncpy+0x11>
    ;
  while(n-- > 0)
80104d59:	eb 0c                	jmp    80104d67 <strncpy+0x4a>
    *s++ = 0;
80104d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5e:	8d 50 01             	lea    0x1(%eax),%edx
80104d61:	89 55 08             	mov    %edx,0x8(%ebp)
80104d64:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104d67:	8b 45 10             	mov    0x10(%ebp),%eax
80104d6a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d6d:	89 55 10             	mov    %edx,0x10(%ebp)
80104d70:	85 c0                	test   %eax,%eax
80104d72:	7f e7                	jg     80104d5b <strncpy+0x3e>
  return os;
80104d74:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d77:	c9                   	leave  
80104d78:	c3                   	ret    

80104d79 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104d79:	f3 0f 1e fb          	endbr32 
80104d7d:	55                   	push   %ebp
80104d7e:	89 e5                	mov    %esp,%ebp
80104d80:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d83:	8b 45 08             	mov    0x8(%ebp),%eax
80104d86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104d89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d8d:	7f 05                	jg     80104d94 <safestrcpy+0x1b>
    return os;
80104d8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d92:	eb 31                	jmp    80104dc5 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104d94:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d9c:	7e 1e                	jle    80104dbc <safestrcpy+0x43>
80104d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104da1:	8d 42 01             	lea    0x1(%edx),%eax
80104da4:	89 45 0c             	mov    %eax,0xc(%ebp)
80104da7:	8b 45 08             	mov    0x8(%ebp),%eax
80104daa:	8d 48 01             	lea    0x1(%eax),%ecx
80104dad:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104db0:	0f b6 12             	movzbl (%edx),%edx
80104db3:	88 10                	mov    %dl,(%eax)
80104db5:	0f b6 00             	movzbl (%eax),%eax
80104db8:	84 c0                	test   %al,%al
80104dba:	75 d8                	jne    80104d94 <safestrcpy+0x1b>
    ;
  *s = 0;
80104dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbf:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dc5:	c9                   	leave  
80104dc6:	c3                   	ret    

80104dc7 <strlen>:

int
strlen(const char *s)
{
80104dc7:	f3 0f 1e fb          	endbr32 
80104dcb:	55                   	push   %ebp
80104dcc:	89 e5                	mov    %esp,%ebp
80104dce:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104dd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104dd8:	eb 04                	jmp    80104dde <strlen+0x17>
80104dda:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104dde:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104de1:	8b 45 08             	mov    0x8(%ebp),%eax
80104de4:	01 d0                	add    %edx,%eax
80104de6:	0f b6 00             	movzbl (%eax),%eax
80104de9:	84 c0                	test   %al,%al
80104deb:	75 ed                	jne    80104dda <strlen+0x13>
    ;
  return n;
80104ded:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104df0:	c9                   	leave  
80104df1:	c3                   	ret    

80104df2 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104df2:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104df6:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104dfa:	55                   	push   %ebp
  pushl %ebx
80104dfb:	53                   	push   %ebx
  pushl %esi
80104dfc:	56                   	push   %esi
  pushl %edi
80104dfd:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104dfe:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e00:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104e02:	5f                   	pop    %edi
  popl %esi
80104e03:	5e                   	pop    %esi
  popl %ebx
80104e04:	5b                   	pop    %ebx
  popl %ebp
80104e05:	5d                   	pop    %ebp
  ret
80104e06:	c3                   	ret    

80104e07 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e07:	f3 0f 1e fb          	endbr32 
80104e0b:	55                   	push   %ebp
80104e0c:	89 e5                	mov    %esp,%ebp
80104e0e:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104e11:	e8 93 ed ff ff       	call   80103ba9 <myproc>
80104e16:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1c:	8b 00                	mov    (%eax),%eax
80104e1e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e21:	73 0f                	jae    80104e32 <fetchint+0x2b>
80104e23:	8b 45 08             	mov    0x8(%ebp),%eax
80104e26:	8d 50 04             	lea    0x4(%eax),%edx
80104e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2c:	8b 00                	mov    (%eax),%eax
80104e2e:	39 c2                	cmp    %eax,%edx
80104e30:	76 07                	jbe    80104e39 <fetchint+0x32>
    return -1;
80104e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e37:	eb 0f                	jmp    80104e48 <fetchint+0x41>
  *ip = *(int*)(addr);
80104e39:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3c:	8b 10                	mov    (%eax),%edx
80104e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e41:	89 10                	mov    %edx,(%eax)
  return 0;
80104e43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e48:	c9                   	leave  
80104e49:	c3                   	ret    

80104e4a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104e4a:	f3 0f 1e fb          	endbr32 
80104e4e:	55                   	push   %ebp
80104e4f:	89 e5                	mov    %esp,%ebp
80104e51:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104e54:	e8 50 ed ff ff       	call   80103ba9 <myproc>
80104e59:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e5f:	8b 00                	mov    (%eax),%eax
80104e61:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e64:	72 07                	jb     80104e6d <fetchstr+0x23>
    return -1;
80104e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e6b:	eb 43                	jmp    80104eb0 <fetchstr+0x66>
  *pp = (char*)addr;
80104e6d:	8b 55 08             	mov    0x8(%ebp),%edx
80104e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e73:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e78:	8b 00                	mov    (%eax),%eax
80104e7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e80:	8b 00                	mov    (%eax),%eax
80104e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e85:	eb 1c                	jmp    80104ea3 <fetchstr+0x59>
    if(*s == 0)
80104e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8a:	0f b6 00             	movzbl (%eax),%eax
80104e8d:	84 c0                	test   %al,%al
80104e8f:	75 0e                	jne    80104e9f <fetchstr+0x55>
      return s - *pp;
80104e91:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e94:	8b 00                	mov    (%eax),%eax
80104e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e99:	29 c2                	sub    %eax,%edx
80104e9b:	89 d0                	mov    %edx,%eax
80104e9d:	eb 11                	jmp    80104eb0 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80104e9f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104ea9:	72 dc                	jb     80104e87 <fetchstr+0x3d>
  }
  return -1;
80104eab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eb0:	c9                   	leave  
80104eb1:	c3                   	ret    

80104eb2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104eb2:	f3 0f 1e fb          	endbr32 
80104eb6:	55                   	push   %ebp
80104eb7:	89 e5                	mov    %esp,%ebp
80104eb9:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ebc:	e8 e8 ec ff ff       	call   80103ba9 <myproc>
80104ec1:	8b 40 18             	mov    0x18(%eax),%eax
80104ec4:	8b 40 44             	mov    0x44(%eax),%eax
80104ec7:	8b 55 08             	mov    0x8(%ebp),%edx
80104eca:	c1 e2 02             	shl    $0x2,%edx
80104ecd:	01 d0                	add    %edx,%eax
80104ecf:	83 c0 04             	add    $0x4,%eax
80104ed2:	83 ec 08             	sub    $0x8,%esp
80104ed5:	ff 75 0c             	pushl  0xc(%ebp)
80104ed8:	50                   	push   %eax
80104ed9:	e8 29 ff ff ff       	call   80104e07 <fetchint>
80104ede:	83 c4 10             	add    $0x10,%esp
}
80104ee1:	c9                   	leave  
80104ee2:	c3                   	ret    

80104ee3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ee3:	f3 0f 1e fb          	endbr32 
80104ee7:	55                   	push   %ebp
80104ee8:	89 e5                	mov    %esp,%ebp
80104eea:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104eed:	e8 b7 ec ff ff       	call   80103ba9 <myproc>
80104ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104ef5:	83 ec 08             	sub    $0x8,%esp
80104ef8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104efb:	50                   	push   %eax
80104efc:	ff 75 08             	pushl  0x8(%ebp)
80104eff:	e8 ae ff ff ff       	call   80104eb2 <argint>
80104f04:	83 c4 10             	add    $0x10,%esp
80104f07:	85 c0                	test   %eax,%eax
80104f09:	79 07                	jns    80104f12 <argptr+0x2f>
    return -1;
80104f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f10:	eb 3b                	jmp    80104f4d <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f16:	78 1f                	js     80104f37 <argptr+0x54>
80104f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1b:	8b 00                	mov    (%eax),%eax
80104f1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f20:	39 d0                	cmp    %edx,%eax
80104f22:	76 13                	jbe    80104f37 <argptr+0x54>
80104f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f27:	89 c2                	mov    %eax,%edx
80104f29:	8b 45 10             	mov    0x10(%ebp),%eax
80104f2c:	01 c2                	add    %eax,%edx
80104f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f31:	8b 00                	mov    (%eax),%eax
80104f33:	39 c2                	cmp    %eax,%edx
80104f35:	76 07                	jbe    80104f3e <argptr+0x5b>
    return -1;
80104f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f3c:	eb 0f                	jmp    80104f4d <argptr+0x6a>
  *pp = (char*)i;
80104f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f41:	89 c2                	mov    %eax,%edx
80104f43:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f46:	89 10                	mov    %edx,(%eax)
  return 0;
80104f48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f4d:	c9                   	leave  
80104f4e:	c3                   	ret    

80104f4f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104f4f:	f3 0f 1e fb          	endbr32 
80104f53:	55                   	push   %ebp
80104f54:	89 e5                	mov    %esp,%ebp
80104f56:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104f59:	83 ec 08             	sub    $0x8,%esp
80104f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f5f:	50                   	push   %eax
80104f60:	ff 75 08             	pushl  0x8(%ebp)
80104f63:	e8 4a ff ff ff       	call   80104eb2 <argint>
80104f68:	83 c4 10             	add    $0x10,%esp
80104f6b:	85 c0                	test   %eax,%eax
80104f6d:	79 07                	jns    80104f76 <argstr+0x27>
    return -1;
80104f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f74:	eb 12                	jmp    80104f88 <argstr+0x39>
  return fetchstr(addr, pp);
80104f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f79:	83 ec 08             	sub    $0x8,%esp
80104f7c:	ff 75 0c             	pushl  0xc(%ebp)
80104f7f:	50                   	push   %eax
80104f80:	e8 c5 fe ff ff       	call   80104e4a <fetchstr>
80104f85:	83 c4 10             	add    $0x10,%esp
}
80104f88:	c9                   	leave  
80104f89:	c3                   	ret    

80104f8a <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80104f8a:	f3 0f 1e fb          	endbr32 
80104f8e:	55                   	push   %ebp
80104f8f:	89 e5                	mov    %esp,%ebp
80104f91:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104f94:	e8 10 ec ff ff       	call   80103ba9 <myproc>
80104f99:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9f:	8b 40 18             	mov    0x18(%eax),%eax
80104fa2:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104fa8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104fac:	7e 2f                	jle    80104fdd <syscall+0x53>
80104fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb1:	83 f8 16             	cmp    $0x16,%eax
80104fb4:	77 27                	ja     80104fdd <syscall+0x53>
80104fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb9:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fc0:	85 c0                	test   %eax,%eax
80104fc2:	74 19                	je     80104fdd <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80104fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc7:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fce:	ff d0                	call   *%eax
80104fd0:	89 c2                	mov    %eax,%edx
80104fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd5:	8b 40 18             	mov    0x18(%eax),%eax
80104fd8:	89 50 1c             	mov    %edx,0x1c(%eax)
80104fdb:	eb 2c                	jmp    80105009 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe0:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe6:	8b 40 10             	mov    0x10(%eax),%eax
80104fe9:	ff 75 f0             	pushl  -0x10(%ebp)
80104fec:	52                   	push   %edx
80104fed:	50                   	push   %eax
80104fee:	68 78 a8 10 80       	push   $0x8010a878
80104ff3:	e8 14 b4 ff ff       	call   8010040c <cprintf>
80104ff8:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ffe:	8b 40 18             	mov    0x18(%eax),%eax
80105001:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105008:	90                   	nop
80105009:	90                   	nop
8010500a:	c9                   	leave  
8010500b:	c3                   	ret    

8010500c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010500c:	f3 0f 1e fb          	endbr32 
80105010:	55                   	push   %ebp
80105011:	89 e5                	mov    %esp,%ebp
80105013:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105016:	83 ec 08             	sub    $0x8,%esp
80105019:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010501c:	50                   	push   %eax
8010501d:	ff 75 08             	pushl  0x8(%ebp)
80105020:	e8 8d fe ff ff       	call   80104eb2 <argint>
80105025:	83 c4 10             	add    $0x10,%esp
80105028:	85 c0                	test   %eax,%eax
8010502a:	79 07                	jns    80105033 <argfd+0x27>
    return -1;
8010502c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105031:	eb 4f                	jmp    80105082 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105036:	85 c0                	test   %eax,%eax
80105038:	78 20                	js     8010505a <argfd+0x4e>
8010503a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010503d:	83 f8 0f             	cmp    $0xf,%eax
80105040:	7f 18                	jg     8010505a <argfd+0x4e>
80105042:	e8 62 eb ff ff       	call   80103ba9 <myproc>
80105047:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010504a:	83 c2 08             	add    $0x8,%edx
8010504d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105051:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105054:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105058:	75 07                	jne    80105061 <argfd+0x55>
    return -1;
8010505a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010505f:	eb 21                	jmp    80105082 <argfd+0x76>
  if(pfd)
80105061:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105065:	74 08                	je     8010506f <argfd+0x63>
    *pfd = fd;
80105067:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010506a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506d:	89 10                	mov    %edx,(%eax)
  if(pf)
8010506f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105073:	74 08                	je     8010507d <argfd+0x71>
    *pf = f;
80105075:	8b 45 10             	mov    0x10(%ebp),%eax
80105078:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010507b:	89 10                	mov    %edx,(%eax)
  return 0;
8010507d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105082:	c9                   	leave  
80105083:	c3                   	ret    

80105084 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105084:	f3 0f 1e fb          	endbr32 
80105088:	55                   	push   %ebp
80105089:	89 e5                	mov    %esp,%ebp
8010508b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010508e:	e8 16 eb ff ff       	call   80103ba9 <myproc>
80105093:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105096:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010509d:	eb 2a                	jmp    801050c9 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010509f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050a5:	83 c2 08             	add    $0x8,%edx
801050a8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050ac:	85 c0                	test   %eax,%eax
801050ae:	75 15                	jne    801050c5 <fdalloc+0x41>
      curproc->ofile[fd] = f;
801050b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050b6:	8d 4a 08             	lea    0x8(%edx),%ecx
801050b9:	8b 55 08             	mov    0x8(%ebp),%edx
801050bc:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801050c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c3:	eb 0f                	jmp    801050d4 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801050c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050c9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801050cd:	7e d0                	jle    8010509f <fdalloc+0x1b>
    }
  }
  return -1;
801050cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050d4:	c9                   	leave  
801050d5:	c3                   	ret    

801050d6 <sys_dup>:

int
sys_dup(void)
{
801050d6:	f3 0f 1e fb          	endbr32 
801050da:	55                   	push   %ebp
801050db:	89 e5                	mov    %esp,%ebp
801050dd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801050e0:	83 ec 04             	sub    $0x4,%esp
801050e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050e6:	50                   	push   %eax
801050e7:	6a 00                	push   $0x0
801050e9:	6a 00                	push   $0x0
801050eb:	e8 1c ff ff ff       	call   8010500c <argfd>
801050f0:	83 c4 10             	add    $0x10,%esp
801050f3:	85 c0                	test   %eax,%eax
801050f5:	79 07                	jns    801050fe <sys_dup+0x28>
    return -1;
801050f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050fc:	eb 31                	jmp    8010512f <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801050fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105101:	83 ec 0c             	sub    $0xc,%esp
80105104:	50                   	push   %eax
80105105:	e8 7a ff ff ff       	call   80105084 <fdalloc>
8010510a:	83 c4 10             	add    $0x10,%esp
8010510d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105110:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105114:	79 07                	jns    8010511d <sys_dup+0x47>
    return -1;
80105116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511b:	eb 12                	jmp    8010512f <sys_dup+0x59>
  filedup(f);
8010511d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105120:	83 ec 0c             	sub    $0xc,%esp
80105123:	50                   	push   %eax
80105124:	e8 6b bf ff ff       	call   80101094 <filedup>
80105129:	83 c4 10             	add    $0x10,%esp
  return fd;
8010512c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010512f:	c9                   	leave  
80105130:	c3                   	ret    

80105131 <sys_read>:

int
sys_read(void)
{
80105131:	f3 0f 1e fb          	endbr32 
80105135:	55                   	push   %ebp
80105136:	89 e5                	mov    %esp,%ebp
80105138:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010513b:	83 ec 04             	sub    $0x4,%esp
8010513e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105141:	50                   	push   %eax
80105142:	6a 00                	push   $0x0
80105144:	6a 00                	push   $0x0
80105146:	e8 c1 fe ff ff       	call   8010500c <argfd>
8010514b:	83 c4 10             	add    $0x10,%esp
8010514e:	85 c0                	test   %eax,%eax
80105150:	78 2e                	js     80105180 <sys_read+0x4f>
80105152:	83 ec 08             	sub    $0x8,%esp
80105155:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105158:	50                   	push   %eax
80105159:	6a 02                	push   $0x2
8010515b:	e8 52 fd ff ff       	call   80104eb2 <argint>
80105160:	83 c4 10             	add    $0x10,%esp
80105163:	85 c0                	test   %eax,%eax
80105165:	78 19                	js     80105180 <sys_read+0x4f>
80105167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010516a:	83 ec 04             	sub    $0x4,%esp
8010516d:	50                   	push   %eax
8010516e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105171:	50                   	push   %eax
80105172:	6a 01                	push   $0x1
80105174:	e8 6a fd ff ff       	call   80104ee3 <argptr>
80105179:	83 c4 10             	add    $0x10,%esp
8010517c:	85 c0                	test   %eax,%eax
8010517e:	79 07                	jns    80105187 <sys_read+0x56>
    return -1;
80105180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105185:	eb 17                	jmp    8010519e <sys_read+0x6d>
  return fileread(f, p, n);
80105187:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010518a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010518d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105190:	83 ec 04             	sub    $0x4,%esp
80105193:	51                   	push   %ecx
80105194:	52                   	push   %edx
80105195:	50                   	push   %eax
80105196:	e8 95 c0 ff ff       	call   80101230 <fileread>
8010519b:	83 c4 10             	add    $0x10,%esp
}
8010519e:	c9                   	leave  
8010519f:	c3                   	ret    

801051a0 <sys_write>:

int
sys_write(void)
{
801051a0:	f3 0f 1e fb          	endbr32 
801051a4:	55                   	push   %ebp
801051a5:	89 e5                	mov    %esp,%ebp
801051a7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801051aa:	83 ec 04             	sub    $0x4,%esp
801051ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051b0:	50                   	push   %eax
801051b1:	6a 00                	push   $0x0
801051b3:	6a 00                	push   $0x0
801051b5:	e8 52 fe ff ff       	call   8010500c <argfd>
801051ba:	83 c4 10             	add    $0x10,%esp
801051bd:	85 c0                	test   %eax,%eax
801051bf:	78 2e                	js     801051ef <sys_write+0x4f>
801051c1:	83 ec 08             	sub    $0x8,%esp
801051c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051c7:	50                   	push   %eax
801051c8:	6a 02                	push   $0x2
801051ca:	e8 e3 fc ff ff       	call   80104eb2 <argint>
801051cf:	83 c4 10             	add    $0x10,%esp
801051d2:	85 c0                	test   %eax,%eax
801051d4:	78 19                	js     801051ef <sys_write+0x4f>
801051d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d9:	83 ec 04             	sub    $0x4,%esp
801051dc:	50                   	push   %eax
801051dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051e0:	50                   	push   %eax
801051e1:	6a 01                	push   $0x1
801051e3:	e8 fb fc ff ff       	call   80104ee3 <argptr>
801051e8:	83 c4 10             	add    $0x10,%esp
801051eb:	85 c0                	test   %eax,%eax
801051ed:	79 07                	jns    801051f6 <sys_write+0x56>
    return -1;
801051ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f4:	eb 17                	jmp    8010520d <sys_write+0x6d>
  return filewrite(f, p, n);
801051f6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801051f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ff:	83 ec 04             	sub    $0x4,%esp
80105202:	51                   	push   %ecx
80105203:	52                   	push   %edx
80105204:	50                   	push   %eax
80105205:	e8 e2 c0 ff ff       	call   801012ec <filewrite>
8010520a:	83 c4 10             	add    $0x10,%esp
}
8010520d:	c9                   	leave  
8010520e:	c3                   	ret    

8010520f <sys_close>:

int
sys_close(void)
{
8010520f:	f3 0f 1e fb          	endbr32 
80105213:	55                   	push   %ebp
80105214:	89 e5                	mov    %esp,%ebp
80105216:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105219:	83 ec 04             	sub    $0x4,%esp
8010521c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010521f:	50                   	push   %eax
80105220:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105223:	50                   	push   %eax
80105224:	6a 00                	push   $0x0
80105226:	e8 e1 fd ff ff       	call   8010500c <argfd>
8010522b:	83 c4 10             	add    $0x10,%esp
8010522e:	85 c0                	test   %eax,%eax
80105230:	79 07                	jns    80105239 <sys_close+0x2a>
    return -1;
80105232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105237:	eb 27                	jmp    80105260 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105239:	e8 6b e9 ff ff       	call   80103ba9 <myproc>
8010523e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105241:	83 c2 08             	add    $0x8,%edx
80105244:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010524b:	00 
  fileclose(f);
8010524c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524f:	83 ec 0c             	sub    $0xc,%esp
80105252:	50                   	push   %eax
80105253:	e8 91 be ff ff       	call   801010e9 <fileclose>
80105258:	83 c4 10             	add    $0x10,%esp
  return 0;
8010525b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105260:	c9                   	leave  
80105261:	c3                   	ret    

80105262 <sys_fstat>:

int
sys_fstat(void)
{
80105262:	f3 0f 1e fb          	endbr32 
80105266:	55                   	push   %ebp
80105267:	89 e5                	mov    %esp,%ebp
80105269:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010526c:	83 ec 04             	sub    $0x4,%esp
8010526f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105272:	50                   	push   %eax
80105273:	6a 00                	push   $0x0
80105275:	6a 00                	push   $0x0
80105277:	e8 90 fd ff ff       	call   8010500c <argfd>
8010527c:	83 c4 10             	add    $0x10,%esp
8010527f:	85 c0                	test   %eax,%eax
80105281:	78 17                	js     8010529a <sys_fstat+0x38>
80105283:	83 ec 04             	sub    $0x4,%esp
80105286:	6a 14                	push   $0x14
80105288:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010528b:	50                   	push   %eax
8010528c:	6a 01                	push   $0x1
8010528e:	e8 50 fc ff ff       	call   80104ee3 <argptr>
80105293:	83 c4 10             	add    $0x10,%esp
80105296:	85 c0                	test   %eax,%eax
80105298:	79 07                	jns    801052a1 <sys_fstat+0x3f>
    return -1;
8010529a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010529f:	eb 13                	jmp    801052b4 <sys_fstat+0x52>
  return filestat(f, st);
801052a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a7:	83 ec 08             	sub    $0x8,%esp
801052aa:	52                   	push   %edx
801052ab:	50                   	push   %eax
801052ac:	e8 24 bf ff ff       	call   801011d5 <filestat>
801052b1:	83 c4 10             	add    $0x10,%esp
}
801052b4:	c9                   	leave  
801052b5:	c3                   	ret    

801052b6 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801052b6:	f3 0f 1e fb          	endbr32 
801052ba:	55                   	push   %ebp
801052bb:	89 e5                	mov    %esp,%ebp
801052bd:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801052c0:	83 ec 08             	sub    $0x8,%esp
801052c3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801052c6:	50                   	push   %eax
801052c7:	6a 00                	push   $0x0
801052c9:	e8 81 fc ff ff       	call   80104f4f <argstr>
801052ce:	83 c4 10             	add    $0x10,%esp
801052d1:	85 c0                	test   %eax,%eax
801052d3:	78 15                	js     801052ea <sys_link+0x34>
801052d5:	83 ec 08             	sub    $0x8,%esp
801052d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801052db:	50                   	push   %eax
801052dc:	6a 01                	push   $0x1
801052de:	e8 6c fc ff ff       	call   80104f4f <argstr>
801052e3:	83 c4 10             	add    $0x10,%esp
801052e6:	85 c0                	test   %eax,%eax
801052e8:	79 0a                	jns    801052f4 <sys_link+0x3e>
    return -1;
801052ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ef:	e9 68 01 00 00       	jmp    8010545c <sys_link+0x1a6>

  begin_op();
801052f4:	e8 78 de ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
801052f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801052fc:	83 ec 0c             	sub    $0xc,%esp
801052ff:	50                   	push   %eax
80105300:	e8 e2 d2 ff ff       	call   801025e7 <namei>
80105305:	83 c4 10             	add    $0x10,%esp
80105308:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010530b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010530f:	75 0f                	jne    80105320 <sys_link+0x6a>
    end_op();
80105311:	e8 eb de ff ff       	call   80103201 <end_op>
    return -1;
80105316:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531b:	e9 3c 01 00 00       	jmp    8010545c <sys_link+0x1a6>
  }

  ilock(ip);
80105320:	83 ec 0c             	sub    $0xc,%esp
80105323:	ff 75 f4             	pushl  -0xc(%ebp)
80105326:	e8 51 c7 ff ff       	call   80101a7c <ilock>
8010532b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010532e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105331:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105335:	66 83 f8 01          	cmp    $0x1,%ax
80105339:	75 1d                	jne    80105358 <sys_link+0xa2>
    iunlockput(ip);
8010533b:	83 ec 0c             	sub    $0xc,%esp
8010533e:	ff 75 f4             	pushl  -0xc(%ebp)
80105341:	e8 73 c9 ff ff       	call   80101cb9 <iunlockput>
80105346:	83 c4 10             	add    $0x10,%esp
    end_op();
80105349:	e8 b3 de ff ff       	call   80103201 <end_op>
    return -1;
8010534e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105353:	e9 04 01 00 00       	jmp    8010545c <sys_link+0x1a6>
  }

  ip->nlink++;
80105358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010535f:	83 c0 01             	add    $0x1,%eax
80105362:	89 c2                	mov    %eax,%edx
80105364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105367:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010536b:	83 ec 0c             	sub    $0xc,%esp
8010536e:	ff 75 f4             	pushl  -0xc(%ebp)
80105371:	e8 1d c5 ff ff       	call   80101893 <iupdate>
80105376:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105379:	83 ec 0c             	sub    $0xc,%esp
8010537c:	ff 75 f4             	pushl  -0xc(%ebp)
8010537f:	e8 0f c8 ff ff       	call   80101b93 <iunlock>
80105384:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105387:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010538a:	83 ec 08             	sub    $0x8,%esp
8010538d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105390:	52                   	push   %edx
80105391:	50                   	push   %eax
80105392:	e8 70 d2 ff ff       	call   80102607 <nameiparent>
80105397:	83 c4 10             	add    $0x10,%esp
8010539a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010539d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053a1:	74 71                	je     80105414 <sys_link+0x15e>
    goto bad;
  ilock(dp);
801053a3:	83 ec 0c             	sub    $0xc,%esp
801053a6:	ff 75 f0             	pushl  -0x10(%ebp)
801053a9:	e8 ce c6 ff ff       	call   80101a7c <ilock>
801053ae:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801053b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b4:	8b 10                	mov    (%eax),%edx
801053b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b9:	8b 00                	mov    (%eax),%eax
801053bb:	39 c2                	cmp    %eax,%edx
801053bd:	75 1d                	jne    801053dc <sys_link+0x126>
801053bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c2:	8b 40 04             	mov    0x4(%eax),%eax
801053c5:	83 ec 04             	sub    $0x4,%esp
801053c8:	50                   	push   %eax
801053c9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801053cc:	50                   	push   %eax
801053cd:	ff 75 f0             	pushl  -0x10(%ebp)
801053d0:	e8 6f cf ff ff       	call   80102344 <dirlink>
801053d5:	83 c4 10             	add    $0x10,%esp
801053d8:	85 c0                	test   %eax,%eax
801053da:	79 10                	jns    801053ec <sys_link+0x136>
    iunlockput(dp);
801053dc:	83 ec 0c             	sub    $0xc,%esp
801053df:	ff 75 f0             	pushl  -0x10(%ebp)
801053e2:	e8 d2 c8 ff ff       	call   80101cb9 <iunlockput>
801053e7:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053ea:	eb 29                	jmp    80105415 <sys_link+0x15f>
  }
  iunlockput(dp);
801053ec:	83 ec 0c             	sub    $0xc,%esp
801053ef:	ff 75 f0             	pushl  -0x10(%ebp)
801053f2:	e8 c2 c8 ff ff       	call   80101cb9 <iunlockput>
801053f7:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801053fa:	83 ec 0c             	sub    $0xc,%esp
801053fd:	ff 75 f4             	pushl  -0xc(%ebp)
80105400:	e8 e0 c7 ff ff       	call   80101be5 <iput>
80105405:	83 c4 10             	add    $0x10,%esp

  end_op();
80105408:	e8 f4 dd ff ff       	call   80103201 <end_op>

  return 0;
8010540d:	b8 00 00 00 00       	mov    $0x0,%eax
80105412:	eb 48                	jmp    8010545c <sys_link+0x1a6>
    goto bad;
80105414:	90                   	nop

bad:
  ilock(ip);
80105415:	83 ec 0c             	sub    $0xc,%esp
80105418:	ff 75 f4             	pushl  -0xc(%ebp)
8010541b:	e8 5c c6 ff ff       	call   80101a7c <ilock>
80105420:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105426:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010542a:	83 e8 01             	sub    $0x1,%eax
8010542d:	89 c2                	mov    %eax,%edx
8010542f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105432:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105436:	83 ec 0c             	sub    $0xc,%esp
80105439:	ff 75 f4             	pushl  -0xc(%ebp)
8010543c:	e8 52 c4 ff ff       	call   80101893 <iupdate>
80105441:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105444:	83 ec 0c             	sub    $0xc,%esp
80105447:	ff 75 f4             	pushl  -0xc(%ebp)
8010544a:	e8 6a c8 ff ff       	call   80101cb9 <iunlockput>
8010544f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105452:	e8 aa dd ff ff       	call   80103201 <end_op>
  return -1;
80105457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010545c:	c9                   	leave  
8010545d:	c3                   	ret    

8010545e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010545e:	f3 0f 1e fb          	endbr32 
80105462:	55                   	push   %ebp
80105463:	89 e5                	mov    %esp,%ebp
80105465:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105468:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010546f:	eb 40                	jmp    801054b1 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105474:	6a 10                	push   $0x10
80105476:	50                   	push   %eax
80105477:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010547a:	50                   	push   %eax
8010547b:	ff 75 08             	pushl  0x8(%ebp)
8010547e:	e8 01 cb ff ff       	call   80101f84 <readi>
80105483:	83 c4 10             	add    $0x10,%esp
80105486:	83 f8 10             	cmp    $0x10,%eax
80105489:	74 0d                	je     80105498 <isdirempty+0x3a>
      panic("isdirempty: readi");
8010548b:	83 ec 0c             	sub    $0xc,%esp
8010548e:	68 94 a8 10 80       	push   $0x8010a894
80105493:	e8 2d b1 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105498:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010549c:	66 85 c0             	test   %ax,%ax
8010549f:	74 07                	je     801054a8 <isdirempty+0x4a>
      return 0;
801054a1:	b8 00 00 00 00       	mov    $0x0,%eax
801054a6:	eb 1b                	jmp    801054c3 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801054a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ab:	83 c0 10             	add    $0x10,%eax
801054ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054b1:	8b 45 08             	mov    0x8(%ebp),%eax
801054b4:	8b 50 58             	mov    0x58(%eax),%edx
801054b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ba:	39 c2                	cmp    %eax,%edx
801054bc:	77 b3                	ja     80105471 <isdirempty+0x13>
  }
  return 1;
801054be:	b8 01 00 00 00       	mov    $0x1,%eax
}
801054c3:	c9                   	leave  
801054c4:	c3                   	ret    

801054c5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801054c5:	f3 0f 1e fb          	endbr32 
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801054cf:	83 ec 08             	sub    $0x8,%esp
801054d2:	8d 45 cc             	lea    -0x34(%ebp),%eax
801054d5:	50                   	push   %eax
801054d6:	6a 00                	push   $0x0
801054d8:	e8 72 fa ff ff       	call   80104f4f <argstr>
801054dd:	83 c4 10             	add    $0x10,%esp
801054e0:	85 c0                	test   %eax,%eax
801054e2:	79 0a                	jns    801054ee <sys_unlink+0x29>
    return -1;
801054e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e9:	e9 bf 01 00 00       	jmp    801056ad <sys_unlink+0x1e8>

  begin_op();
801054ee:	e8 7e dc ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801054f3:	8b 45 cc             	mov    -0x34(%ebp),%eax
801054f6:	83 ec 08             	sub    $0x8,%esp
801054f9:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801054fc:	52                   	push   %edx
801054fd:	50                   	push   %eax
801054fe:	e8 04 d1 ff ff       	call   80102607 <nameiparent>
80105503:	83 c4 10             	add    $0x10,%esp
80105506:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105509:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010550d:	75 0f                	jne    8010551e <sys_unlink+0x59>
    end_op();
8010550f:	e8 ed dc ff ff       	call   80103201 <end_op>
    return -1;
80105514:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105519:	e9 8f 01 00 00       	jmp    801056ad <sys_unlink+0x1e8>
  }

  ilock(dp);
8010551e:	83 ec 0c             	sub    $0xc,%esp
80105521:	ff 75 f4             	pushl  -0xc(%ebp)
80105524:	e8 53 c5 ff ff       	call   80101a7c <ilock>
80105529:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010552c:	83 ec 08             	sub    $0x8,%esp
8010552f:	68 a6 a8 10 80       	push   $0x8010a8a6
80105534:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105537:	50                   	push   %eax
80105538:	e8 2a cd ff ff       	call   80102267 <namecmp>
8010553d:	83 c4 10             	add    $0x10,%esp
80105540:	85 c0                	test   %eax,%eax
80105542:	0f 84 49 01 00 00    	je     80105691 <sys_unlink+0x1cc>
80105548:	83 ec 08             	sub    $0x8,%esp
8010554b:	68 a8 a8 10 80       	push   $0x8010a8a8
80105550:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105553:	50                   	push   %eax
80105554:	e8 0e cd ff ff       	call   80102267 <namecmp>
80105559:	83 c4 10             	add    $0x10,%esp
8010555c:	85 c0                	test   %eax,%eax
8010555e:	0f 84 2d 01 00 00    	je     80105691 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105564:	83 ec 04             	sub    $0x4,%esp
80105567:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010556a:	50                   	push   %eax
8010556b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010556e:	50                   	push   %eax
8010556f:	ff 75 f4             	pushl  -0xc(%ebp)
80105572:	e8 0f cd ff ff       	call   80102286 <dirlookup>
80105577:	83 c4 10             	add    $0x10,%esp
8010557a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010557d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105581:	0f 84 0d 01 00 00    	je     80105694 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105587:	83 ec 0c             	sub    $0xc,%esp
8010558a:	ff 75 f0             	pushl  -0x10(%ebp)
8010558d:	e8 ea c4 ff ff       	call   80101a7c <ilock>
80105592:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105598:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010559c:	66 85 c0             	test   %ax,%ax
8010559f:	7f 0d                	jg     801055ae <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
801055a1:	83 ec 0c             	sub    $0xc,%esp
801055a4:	68 ab a8 10 80       	push   $0x8010a8ab
801055a9:	e8 17 b0 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801055ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055b5:	66 83 f8 01          	cmp    $0x1,%ax
801055b9:	75 25                	jne    801055e0 <sys_unlink+0x11b>
801055bb:	83 ec 0c             	sub    $0xc,%esp
801055be:	ff 75 f0             	pushl  -0x10(%ebp)
801055c1:	e8 98 fe ff ff       	call   8010545e <isdirempty>
801055c6:	83 c4 10             	add    $0x10,%esp
801055c9:	85 c0                	test   %eax,%eax
801055cb:	75 13                	jne    801055e0 <sys_unlink+0x11b>
    iunlockput(ip);
801055cd:	83 ec 0c             	sub    $0xc,%esp
801055d0:	ff 75 f0             	pushl  -0x10(%ebp)
801055d3:	e8 e1 c6 ff ff       	call   80101cb9 <iunlockput>
801055d8:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055db:	e9 b5 00 00 00       	jmp    80105695 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801055e0:	83 ec 04             	sub    $0x4,%esp
801055e3:	6a 10                	push   $0x10
801055e5:	6a 00                	push   $0x0
801055e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801055ea:	50                   	push   %eax
801055eb:	e8 6e f5 ff ff       	call   80104b5e <memset>
801055f0:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801055f6:	6a 10                	push   $0x10
801055f8:	50                   	push   %eax
801055f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801055fc:	50                   	push   %eax
801055fd:	ff 75 f4             	pushl  -0xc(%ebp)
80105600:	e8 d8 ca ff ff       	call   801020dd <writei>
80105605:	83 c4 10             	add    $0x10,%esp
80105608:	83 f8 10             	cmp    $0x10,%eax
8010560b:	74 0d                	je     8010561a <sys_unlink+0x155>
    panic("unlink: writei");
8010560d:	83 ec 0c             	sub    $0xc,%esp
80105610:	68 bd a8 10 80       	push   $0x8010a8bd
80105615:	e8 ab af ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
8010561a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105621:	66 83 f8 01          	cmp    $0x1,%ax
80105625:	75 21                	jne    80105648 <sys_unlink+0x183>
    dp->nlink--;
80105627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010562e:	83 e8 01             	sub    $0x1,%eax
80105631:	89 c2                	mov    %eax,%edx
80105633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105636:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010563a:	83 ec 0c             	sub    $0xc,%esp
8010563d:	ff 75 f4             	pushl  -0xc(%ebp)
80105640:	e8 4e c2 ff ff       	call   80101893 <iupdate>
80105645:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105648:	83 ec 0c             	sub    $0xc,%esp
8010564b:	ff 75 f4             	pushl  -0xc(%ebp)
8010564e:	e8 66 c6 ff ff       	call   80101cb9 <iunlockput>
80105653:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105659:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010565d:	83 e8 01             	sub    $0x1,%eax
80105660:	89 c2                	mov    %eax,%edx
80105662:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105665:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105669:	83 ec 0c             	sub    $0xc,%esp
8010566c:	ff 75 f0             	pushl  -0x10(%ebp)
8010566f:	e8 1f c2 ff ff       	call   80101893 <iupdate>
80105674:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105677:	83 ec 0c             	sub    $0xc,%esp
8010567a:	ff 75 f0             	pushl  -0x10(%ebp)
8010567d:	e8 37 c6 ff ff       	call   80101cb9 <iunlockput>
80105682:	83 c4 10             	add    $0x10,%esp

  end_op();
80105685:	e8 77 db ff ff       	call   80103201 <end_op>

  return 0;
8010568a:	b8 00 00 00 00       	mov    $0x0,%eax
8010568f:	eb 1c                	jmp    801056ad <sys_unlink+0x1e8>
    goto bad;
80105691:	90                   	nop
80105692:	eb 01                	jmp    80105695 <sys_unlink+0x1d0>
    goto bad;
80105694:	90                   	nop

bad:
  iunlockput(dp);
80105695:	83 ec 0c             	sub    $0xc,%esp
80105698:	ff 75 f4             	pushl  -0xc(%ebp)
8010569b:	e8 19 c6 ff ff       	call   80101cb9 <iunlockput>
801056a0:	83 c4 10             	add    $0x10,%esp
  end_op();
801056a3:	e8 59 db ff ff       	call   80103201 <end_op>
  return -1;
801056a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056ad:	c9                   	leave  
801056ae:	c3                   	ret    

801056af <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801056af:	f3 0f 1e fb          	endbr32 
801056b3:	55                   	push   %ebp
801056b4:	89 e5                	mov    %esp,%ebp
801056b6:	83 ec 38             	sub    $0x38,%esp
801056b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801056bc:	8b 55 10             	mov    0x10(%ebp),%edx
801056bf:	8b 45 14             	mov    0x14(%ebp),%eax
801056c2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801056c6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801056ca:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801056ce:	83 ec 08             	sub    $0x8,%esp
801056d1:	8d 45 de             	lea    -0x22(%ebp),%eax
801056d4:	50                   	push   %eax
801056d5:	ff 75 08             	pushl  0x8(%ebp)
801056d8:	e8 2a cf ff ff       	call   80102607 <nameiparent>
801056dd:	83 c4 10             	add    $0x10,%esp
801056e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056e7:	75 0a                	jne    801056f3 <create+0x44>
    return 0;
801056e9:	b8 00 00 00 00       	mov    $0x0,%eax
801056ee:	e9 90 01 00 00       	jmp    80105883 <create+0x1d4>
  ilock(dp);
801056f3:	83 ec 0c             	sub    $0xc,%esp
801056f6:	ff 75 f4             	pushl  -0xc(%ebp)
801056f9:	e8 7e c3 ff ff       	call   80101a7c <ilock>
801056fe:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105701:	83 ec 04             	sub    $0x4,%esp
80105704:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105707:	50                   	push   %eax
80105708:	8d 45 de             	lea    -0x22(%ebp),%eax
8010570b:	50                   	push   %eax
8010570c:	ff 75 f4             	pushl  -0xc(%ebp)
8010570f:	e8 72 cb ff ff       	call   80102286 <dirlookup>
80105714:	83 c4 10             	add    $0x10,%esp
80105717:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010571a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010571e:	74 50                	je     80105770 <create+0xc1>
    iunlockput(dp);
80105720:	83 ec 0c             	sub    $0xc,%esp
80105723:	ff 75 f4             	pushl  -0xc(%ebp)
80105726:	e8 8e c5 ff ff       	call   80101cb9 <iunlockput>
8010572b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010572e:	83 ec 0c             	sub    $0xc,%esp
80105731:	ff 75 f0             	pushl  -0x10(%ebp)
80105734:	e8 43 c3 ff ff       	call   80101a7c <ilock>
80105739:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010573c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105741:	75 15                	jne    80105758 <create+0xa9>
80105743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105746:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010574a:	66 83 f8 02          	cmp    $0x2,%ax
8010574e:	75 08                	jne    80105758 <create+0xa9>
      return ip;
80105750:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105753:	e9 2b 01 00 00       	jmp    80105883 <create+0x1d4>
    iunlockput(ip);
80105758:	83 ec 0c             	sub    $0xc,%esp
8010575b:	ff 75 f0             	pushl  -0x10(%ebp)
8010575e:	e8 56 c5 ff ff       	call   80101cb9 <iunlockput>
80105763:	83 c4 10             	add    $0x10,%esp
    return 0;
80105766:	b8 00 00 00 00       	mov    $0x0,%eax
8010576b:	e9 13 01 00 00       	jmp    80105883 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105770:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105777:	8b 00                	mov    (%eax),%eax
80105779:	83 ec 08             	sub    $0x8,%esp
8010577c:	52                   	push   %edx
8010577d:	50                   	push   %eax
8010577e:	e8 35 c0 ff ff       	call   801017b8 <ialloc>
80105783:	83 c4 10             	add    $0x10,%esp
80105786:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105789:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010578d:	75 0d                	jne    8010579c <create+0xed>
    panic("create: ialloc");
8010578f:	83 ec 0c             	sub    $0xc,%esp
80105792:	68 cc a8 10 80       	push   $0x8010a8cc
80105797:	e8 29 ae ff ff       	call   801005c5 <panic>

  ilock(ip);
8010579c:	83 ec 0c             	sub    $0xc,%esp
8010579f:	ff 75 f0             	pushl  -0x10(%ebp)
801057a2:	e8 d5 c2 ff ff       	call   80101a7c <ilock>
801057a7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801057aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ad:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801057b1:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801057b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801057bc:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801057c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c3:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801057c9:	83 ec 0c             	sub    $0xc,%esp
801057cc:	ff 75 f0             	pushl  -0x10(%ebp)
801057cf:	e8 bf c0 ff ff       	call   80101893 <iupdate>
801057d4:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801057d7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801057dc:	75 6a                	jne    80105848 <create+0x199>
    dp->nlink++;  // for ".."
801057de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057e5:	83 c0 01             	add    $0x1,%eax
801057e8:	89 c2                	mov    %eax,%edx
801057ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ed:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057f1:	83 ec 0c             	sub    $0xc,%esp
801057f4:	ff 75 f4             	pushl  -0xc(%ebp)
801057f7:	e8 97 c0 ff ff       	call   80101893 <iupdate>
801057fc:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801057ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105802:	8b 40 04             	mov    0x4(%eax),%eax
80105805:	83 ec 04             	sub    $0x4,%esp
80105808:	50                   	push   %eax
80105809:	68 a6 a8 10 80       	push   $0x8010a8a6
8010580e:	ff 75 f0             	pushl  -0x10(%ebp)
80105811:	e8 2e cb ff ff       	call   80102344 <dirlink>
80105816:	83 c4 10             	add    $0x10,%esp
80105819:	85 c0                	test   %eax,%eax
8010581b:	78 1e                	js     8010583b <create+0x18c>
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	8b 40 04             	mov    0x4(%eax),%eax
80105823:	83 ec 04             	sub    $0x4,%esp
80105826:	50                   	push   %eax
80105827:	68 a8 a8 10 80       	push   $0x8010a8a8
8010582c:	ff 75 f0             	pushl  -0x10(%ebp)
8010582f:	e8 10 cb ff ff       	call   80102344 <dirlink>
80105834:	83 c4 10             	add    $0x10,%esp
80105837:	85 c0                	test   %eax,%eax
80105839:	79 0d                	jns    80105848 <create+0x199>
      panic("create dots");
8010583b:	83 ec 0c             	sub    $0xc,%esp
8010583e:	68 db a8 10 80       	push   $0x8010a8db
80105843:	e8 7d ad ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584b:	8b 40 04             	mov    0x4(%eax),%eax
8010584e:	83 ec 04             	sub    $0x4,%esp
80105851:	50                   	push   %eax
80105852:	8d 45 de             	lea    -0x22(%ebp),%eax
80105855:	50                   	push   %eax
80105856:	ff 75 f4             	pushl  -0xc(%ebp)
80105859:	e8 e6 ca ff ff       	call   80102344 <dirlink>
8010585e:	83 c4 10             	add    $0x10,%esp
80105861:	85 c0                	test   %eax,%eax
80105863:	79 0d                	jns    80105872 <create+0x1c3>
    panic("create: dirlink");
80105865:	83 ec 0c             	sub    $0xc,%esp
80105868:	68 e7 a8 10 80       	push   $0x8010a8e7
8010586d:	e8 53 ad ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105872:	83 ec 0c             	sub    $0xc,%esp
80105875:	ff 75 f4             	pushl  -0xc(%ebp)
80105878:	e8 3c c4 ff ff       	call   80101cb9 <iunlockput>
8010587d:	83 c4 10             	add    $0x10,%esp

  return ip;
80105880:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105883:	c9                   	leave  
80105884:	c3                   	ret    

80105885 <sys_open>:

int
sys_open(void)
{
80105885:	f3 0f 1e fb          	endbr32 
80105889:	55                   	push   %ebp
8010588a:	89 e5                	mov    %esp,%ebp
8010588c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010588f:	83 ec 08             	sub    $0x8,%esp
80105892:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105895:	50                   	push   %eax
80105896:	6a 00                	push   $0x0
80105898:	e8 b2 f6 ff ff       	call   80104f4f <argstr>
8010589d:	83 c4 10             	add    $0x10,%esp
801058a0:	85 c0                	test   %eax,%eax
801058a2:	78 15                	js     801058b9 <sys_open+0x34>
801058a4:	83 ec 08             	sub    $0x8,%esp
801058a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058aa:	50                   	push   %eax
801058ab:	6a 01                	push   $0x1
801058ad:	e8 00 f6 ff ff       	call   80104eb2 <argint>
801058b2:	83 c4 10             	add    $0x10,%esp
801058b5:	85 c0                	test   %eax,%eax
801058b7:	79 0a                	jns    801058c3 <sys_open+0x3e>
    return -1;
801058b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058be:	e9 61 01 00 00       	jmp    80105a24 <sys_open+0x19f>

  begin_op();
801058c3:	e8 a9 d8 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
801058c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058cb:	25 00 02 00 00       	and    $0x200,%eax
801058d0:	85 c0                	test   %eax,%eax
801058d2:	74 2a                	je     801058fe <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801058d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058d7:	6a 00                	push   $0x0
801058d9:	6a 00                	push   $0x0
801058db:	6a 02                	push   $0x2
801058dd:	50                   	push   %eax
801058de:	e8 cc fd ff ff       	call   801056af <create>
801058e3:	83 c4 10             	add    $0x10,%esp
801058e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801058e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ed:	75 75                	jne    80105964 <sys_open+0xdf>
      end_op();
801058ef:	e8 0d d9 ff ff       	call   80103201 <end_op>
      return -1;
801058f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f9:	e9 26 01 00 00       	jmp    80105a24 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801058fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105901:	83 ec 0c             	sub    $0xc,%esp
80105904:	50                   	push   %eax
80105905:	e8 dd cc ff ff       	call   801025e7 <namei>
8010590a:	83 c4 10             	add    $0x10,%esp
8010590d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105910:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105914:	75 0f                	jne    80105925 <sys_open+0xa0>
      end_op();
80105916:	e8 e6 d8 ff ff       	call   80103201 <end_op>
      return -1;
8010591b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105920:	e9 ff 00 00 00       	jmp    80105a24 <sys_open+0x19f>
    }
    ilock(ip);
80105925:	83 ec 0c             	sub    $0xc,%esp
80105928:	ff 75 f4             	pushl  -0xc(%ebp)
8010592b:	e8 4c c1 ff ff       	call   80101a7c <ilock>
80105930:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105936:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010593a:	66 83 f8 01          	cmp    $0x1,%ax
8010593e:	75 24                	jne    80105964 <sys_open+0xdf>
80105940:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105943:	85 c0                	test   %eax,%eax
80105945:	74 1d                	je     80105964 <sys_open+0xdf>
      iunlockput(ip);
80105947:	83 ec 0c             	sub    $0xc,%esp
8010594a:	ff 75 f4             	pushl  -0xc(%ebp)
8010594d:	e8 67 c3 ff ff       	call   80101cb9 <iunlockput>
80105952:	83 c4 10             	add    $0x10,%esp
      end_op();
80105955:	e8 a7 d8 ff ff       	call   80103201 <end_op>
      return -1;
8010595a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595f:	e9 c0 00 00 00       	jmp    80105a24 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105964:	e8 ba b6 ff ff       	call   80101023 <filealloc>
80105969:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010596c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105970:	74 17                	je     80105989 <sys_open+0x104>
80105972:	83 ec 0c             	sub    $0xc,%esp
80105975:	ff 75 f0             	pushl  -0x10(%ebp)
80105978:	e8 07 f7 ff ff       	call   80105084 <fdalloc>
8010597d:	83 c4 10             	add    $0x10,%esp
80105980:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105983:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105987:	79 2e                	jns    801059b7 <sys_open+0x132>
    if(f)
80105989:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010598d:	74 0e                	je     8010599d <sys_open+0x118>
      fileclose(f);
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	ff 75 f0             	pushl  -0x10(%ebp)
80105995:	e8 4f b7 ff ff       	call   801010e9 <fileclose>
8010599a:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010599d:	83 ec 0c             	sub    $0xc,%esp
801059a0:	ff 75 f4             	pushl  -0xc(%ebp)
801059a3:	e8 11 c3 ff ff       	call   80101cb9 <iunlockput>
801059a8:	83 c4 10             	add    $0x10,%esp
    end_op();
801059ab:	e8 51 d8 ff ff       	call   80103201 <end_op>
    return -1;
801059b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b5:	eb 6d                	jmp    80105a24 <sys_open+0x19f>
  }
  iunlock(ip);
801059b7:	83 ec 0c             	sub    $0xc,%esp
801059ba:	ff 75 f4             	pushl  -0xc(%ebp)
801059bd:	e8 d1 c1 ff ff       	call   80101b93 <iunlock>
801059c2:	83 c4 10             	add    $0x10,%esp
  end_op();
801059c5:	e8 37 d8 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
801059ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cd:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801059d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059d9:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801059dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059df:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801059e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059e9:	83 e0 01             	and    $0x1,%eax
801059ec:	85 c0                	test   %eax,%eax
801059ee:	0f 94 c0             	sete   %al
801059f1:	89 c2                	mov    %eax,%edx
801059f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f6:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801059f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059fc:	83 e0 01             	and    $0x1,%eax
801059ff:	85 c0                	test   %eax,%eax
80105a01:	75 0a                	jne    80105a0d <sys_open+0x188>
80105a03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a06:	83 e0 02             	and    $0x2,%eax
80105a09:	85 c0                	test   %eax,%eax
80105a0b:	74 07                	je     80105a14 <sys_open+0x18f>
80105a0d:	b8 01 00 00 00       	mov    $0x1,%eax
80105a12:	eb 05                	jmp    80105a19 <sys_open+0x194>
80105a14:	b8 00 00 00 00       	mov    $0x0,%eax
80105a19:	89 c2                	mov    %eax,%edx
80105a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1e:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105a21:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105a24:	c9                   	leave  
80105a25:	c3                   	ret    

80105a26 <sys_mkdir>:

int
sys_mkdir(void)
{
80105a26:	f3 0f 1e fb          	endbr32 
80105a2a:	55                   	push   %ebp
80105a2b:	89 e5                	mov    %esp,%ebp
80105a2d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105a30:	e8 3c d7 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105a35:	83 ec 08             	sub    $0x8,%esp
80105a38:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a3b:	50                   	push   %eax
80105a3c:	6a 00                	push   $0x0
80105a3e:	e8 0c f5 ff ff       	call   80104f4f <argstr>
80105a43:	83 c4 10             	add    $0x10,%esp
80105a46:	85 c0                	test   %eax,%eax
80105a48:	78 1b                	js     80105a65 <sys_mkdir+0x3f>
80105a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4d:	6a 00                	push   $0x0
80105a4f:	6a 00                	push   $0x0
80105a51:	6a 01                	push   $0x1
80105a53:	50                   	push   %eax
80105a54:	e8 56 fc ff ff       	call   801056af <create>
80105a59:	83 c4 10             	add    $0x10,%esp
80105a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a63:	75 0c                	jne    80105a71 <sys_mkdir+0x4b>
    end_op();
80105a65:	e8 97 d7 ff ff       	call   80103201 <end_op>
    return -1;
80105a6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6f:	eb 18                	jmp    80105a89 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105a71:	83 ec 0c             	sub    $0xc,%esp
80105a74:	ff 75 f4             	pushl  -0xc(%ebp)
80105a77:	e8 3d c2 ff ff       	call   80101cb9 <iunlockput>
80105a7c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a7f:	e8 7d d7 ff ff       	call   80103201 <end_op>
  return 0;
80105a84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a89:	c9                   	leave  
80105a8a:	c3                   	ret    

80105a8b <sys_mknod>:

int
sys_mknod(void)
{
80105a8b:	f3 0f 1e fb          	endbr32 
80105a8f:	55                   	push   %ebp
80105a90:	89 e5                	mov    %esp,%ebp
80105a92:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105a95:	e8 d7 d6 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105a9a:	83 ec 08             	sub    $0x8,%esp
80105a9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aa0:	50                   	push   %eax
80105aa1:	6a 00                	push   $0x0
80105aa3:	e8 a7 f4 ff ff       	call   80104f4f <argstr>
80105aa8:	83 c4 10             	add    $0x10,%esp
80105aab:	85 c0                	test   %eax,%eax
80105aad:	78 4f                	js     80105afe <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105aaf:	83 ec 08             	sub    $0x8,%esp
80105ab2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ab5:	50                   	push   %eax
80105ab6:	6a 01                	push   $0x1
80105ab8:	e8 f5 f3 ff ff       	call   80104eb2 <argint>
80105abd:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105ac0:	85 c0                	test   %eax,%eax
80105ac2:	78 3a                	js     80105afe <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105ac4:	83 ec 08             	sub    $0x8,%esp
80105ac7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105aca:	50                   	push   %eax
80105acb:	6a 02                	push   $0x2
80105acd:	e8 e0 f3 ff ff       	call   80104eb2 <argint>
80105ad2:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105ad5:	85 c0                	test   %eax,%eax
80105ad7:	78 25                	js     80105afe <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ad9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105adc:	0f bf c8             	movswl %ax,%ecx
80105adf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ae2:	0f bf d0             	movswl %ax,%edx
80105ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae8:	51                   	push   %ecx
80105ae9:	52                   	push   %edx
80105aea:	6a 03                	push   $0x3
80105aec:	50                   	push   %eax
80105aed:	e8 bd fb ff ff       	call   801056af <create>
80105af2:	83 c4 10             	add    $0x10,%esp
80105af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105af8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105afc:	75 0c                	jne    80105b0a <sys_mknod+0x7f>
    end_op();
80105afe:	e8 fe d6 ff ff       	call   80103201 <end_op>
    return -1;
80105b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b08:	eb 18                	jmp    80105b22 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105b0a:	83 ec 0c             	sub    $0xc,%esp
80105b0d:	ff 75 f4             	pushl  -0xc(%ebp)
80105b10:	e8 a4 c1 ff ff       	call   80101cb9 <iunlockput>
80105b15:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b18:	e8 e4 d6 ff ff       	call   80103201 <end_op>
  return 0;
80105b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b22:	c9                   	leave  
80105b23:	c3                   	ret    

80105b24 <sys_chdir>:

int
sys_chdir(void)
{
80105b24:	f3 0f 1e fb          	endbr32 
80105b28:	55                   	push   %ebp
80105b29:	89 e5                	mov    %esp,%ebp
80105b2b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105b2e:	e8 76 e0 ff ff       	call   80103ba9 <myproc>
80105b33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105b36:	e8 36 d6 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105b3b:	83 ec 08             	sub    $0x8,%esp
80105b3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b41:	50                   	push   %eax
80105b42:	6a 00                	push   $0x0
80105b44:	e8 06 f4 ff ff       	call   80104f4f <argstr>
80105b49:	83 c4 10             	add    $0x10,%esp
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	78 18                	js     80105b68 <sys_chdir+0x44>
80105b50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b53:	83 ec 0c             	sub    $0xc,%esp
80105b56:	50                   	push   %eax
80105b57:	e8 8b ca ff ff       	call   801025e7 <namei>
80105b5c:	83 c4 10             	add    $0x10,%esp
80105b5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b66:	75 0c                	jne    80105b74 <sys_chdir+0x50>
    end_op();
80105b68:	e8 94 d6 ff ff       	call   80103201 <end_op>
    return -1;
80105b6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b72:	eb 68                	jmp    80105bdc <sys_chdir+0xb8>
  }
  ilock(ip);
80105b74:	83 ec 0c             	sub    $0xc,%esp
80105b77:	ff 75 f0             	pushl  -0x10(%ebp)
80105b7a:	e8 fd be ff ff       	call   80101a7c <ilock>
80105b7f:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b85:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b89:	66 83 f8 01          	cmp    $0x1,%ax
80105b8d:	74 1a                	je     80105ba9 <sys_chdir+0x85>
    iunlockput(ip);
80105b8f:	83 ec 0c             	sub    $0xc,%esp
80105b92:	ff 75 f0             	pushl  -0x10(%ebp)
80105b95:	e8 1f c1 ff ff       	call   80101cb9 <iunlockput>
80105b9a:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b9d:	e8 5f d6 ff ff       	call   80103201 <end_op>
    return -1;
80105ba2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba7:	eb 33                	jmp    80105bdc <sys_chdir+0xb8>
  }
  iunlock(ip);
80105ba9:	83 ec 0c             	sub    $0xc,%esp
80105bac:	ff 75 f0             	pushl  -0x10(%ebp)
80105baf:	e8 df bf ff ff       	call   80101b93 <iunlock>
80105bb4:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bba:	8b 40 68             	mov    0x68(%eax),%eax
80105bbd:	83 ec 0c             	sub    $0xc,%esp
80105bc0:	50                   	push   %eax
80105bc1:	e8 1f c0 ff ff       	call   80101be5 <iput>
80105bc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bc9:	e8 33 d6 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80105bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bd4:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105bd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bdc:	c9                   	leave  
80105bdd:	c3                   	ret    

80105bde <sys_exec>:

int
sys_exec(void)
{
80105bde:	f3 0f 1e fb          	endbr32 
80105be2:	55                   	push   %ebp
80105be3:	89 e5                	mov    %esp,%ebp
80105be5:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105beb:	83 ec 08             	sub    $0x8,%esp
80105bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bf1:	50                   	push   %eax
80105bf2:	6a 00                	push   $0x0
80105bf4:	e8 56 f3 ff ff       	call   80104f4f <argstr>
80105bf9:	83 c4 10             	add    $0x10,%esp
80105bfc:	85 c0                	test   %eax,%eax
80105bfe:	78 18                	js     80105c18 <sys_exec+0x3a>
80105c00:	83 ec 08             	sub    $0x8,%esp
80105c03:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105c09:	50                   	push   %eax
80105c0a:	6a 01                	push   $0x1
80105c0c:	e8 a1 f2 ff ff       	call   80104eb2 <argint>
80105c11:	83 c4 10             	add    $0x10,%esp
80105c14:	85 c0                	test   %eax,%eax
80105c16:	79 0a                	jns    80105c22 <sys_exec+0x44>
    return -1;
80105c18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1d:	e9 c6 00 00 00       	jmp    80105ce8 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105c22:	83 ec 04             	sub    $0x4,%esp
80105c25:	68 80 00 00 00       	push   $0x80
80105c2a:	6a 00                	push   $0x0
80105c2c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105c32:	50                   	push   %eax
80105c33:	e8 26 ef ff ff       	call   80104b5e <memset>
80105c38:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105c3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c45:	83 f8 1f             	cmp    $0x1f,%eax
80105c48:	76 0a                	jbe    80105c54 <sys_exec+0x76>
      return -1;
80105c4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4f:	e9 94 00 00 00       	jmp    80105ce8 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c57:	c1 e0 02             	shl    $0x2,%eax
80105c5a:	89 c2                	mov    %eax,%edx
80105c5c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105c62:	01 c2                	add    %eax,%edx
80105c64:	83 ec 08             	sub    $0x8,%esp
80105c67:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105c6d:	50                   	push   %eax
80105c6e:	52                   	push   %edx
80105c6f:	e8 93 f1 ff ff       	call   80104e07 <fetchint>
80105c74:	83 c4 10             	add    $0x10,%esp
80105c77:	85 c0                	test   %eax,%eax
80105c79:	79 07                	jns    80105c82 <sys_exec+0xa4>
      return -1;
80105c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c80:	eb 66                	jmp    80105ce8 <sys_exec+0x10a>
    if(uarg == 0){
80105c82:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105c88:	85 c0                	test   %eax,%eax
80105c8a:	75 27                	jne    80105cb3 <sys_exec+0xd5>
      argv[i] = 0;
80105c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c8f:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105c96:	00 00 00 00 
      break;
80105c9a:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9e:	83 ec 08             	sub    $0x8,%esp
80105ca1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ca7:	52                   	push   %edx
80105ca8:	50                   	push   %eax
80105ca9:	e8 10 af ff ff       	call   80100bbe <exec>
80105cae:	83 c4 10             	add    $0x10,%esp
80105cb1:	eb 35                	jmp    80105ce8 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105cb3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105cb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cbc:	c1 e2 02             	shl    $0x2,%edx
80105cbf:	01 c2                	add    %eax,%edx
80105cc1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105cc7:	83 ec 08             	sub    $0x8,%esp
80105cca:	52                   	push   %edx
80105ccb:	50                   	push   %eax
80105ccc:	e8 79 f1 ff ff       	call   80104e4a <fetchstr>
80105cd1:	83 c4 10             	add    $0x10,%esp
80105cd4:	85 c0                	test   %eax,%eax
80105cd6:	79 07                	jns    80105cdf <sys_exec+0x101>
      return -1;
80105cd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cdd:	eb 09                	jmp    80105ce8 <sys_exec+0x10a>
  for(i=0;; i++){
80105cdf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ce3:	e9 5a ff ff ff       	jmp    80105c42 <sys_exec+0x64>
}
80105ce8:	c9                   	leave  
80105ce9:	c3                   	ret    

80105cea <sys_pipe>:

int
sys_pipe(void)
{
80105cea:	f3 0f 1e fb          	endbr32 
80105cee:	55                   	push   %ebp
80105cef:	89 e5                	mov    %esp,%ebp
80105cf1:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105cf4:	83 ec 04             	sub    $0x4,%esp
80105cf7:	6a 08                	push   $0x8
80105cf9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cfc:	50                   	push   %eax
80105cfd:	6a 00                	push   $0x0
80105cff:	e8 df f1 ff ff       	call   80104ee3 <argptr>
80105d04:	83 c4 10             	add    $0x10,%esp
80105d07:	85 c0                	test   %eax,%eax
80105d09:	79 0a                	jns    80105d15 <sys_pipe+0x2b>
    return -1;
80105d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d10:	e9 ae 00 00 00       	jmp    80105dc3 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105d15:	83 ec 08             	sub    $0x8,%esp
80105d18:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d1b:	50                   	push   %eax
80105d1c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d1f:	50                   	push   %eax
80105d20:	e8 a5 d9 ff ff       	call   801036ca <pipealloc>
80105d25:	83 c4 10             	add    $0x10,%esp
80105d28:	85 c0                	test   %eax,%eax
80105d2a:	79 0a                	jns    80105d36 <sys_pipe+0x4c>
    return -1;
80105d2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d31:	e9 8d 00 00 00       	jmp    80105dc3 <sys_pipe+0xd9>
  fd0 = -1;
80105d36:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105d3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d40:	83 ec 0c             	sub    $0xc,%esp
80105d43:	50                   	push   %eax
80105d44:	e8 3b f3 ff ff       	call   80105084 <fdalloc>
80105d49:	83 c4 10             	add    $0x10,%esp
80105d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d53:	78 18                	js     80105d6d <sys_pipe+0x83>
80105d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d58:	83 ec 0c             	sub    $0xc,%esp
80105d5b:	50                   	push   %eax
80105d5c:	e8 23 f3 ff ff       	call   80105084 <fdalloc>
80105d61:	83 c4 10             	add    $0x10,%esp
80105d64:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d6b:	79 3e                	jns    80105dab <sys_pipe+0xc1>
    if(fd0 >= 0)
80105d6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d71:	78 13                	js     80105d86 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105d73:	e8 31 de ff ff       	call   80103ba9 <myproc>
80105d78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d7b:	83 c2 08             	add    $0x8,%edx
80105d7e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d85:	00 
    fileclose(rf);
80105d86:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d89:	83 ec 0c             	sub    $0xc,%esp
80105d8c:	50                   	push   %eax
80105d8d:	e8 57 b3 ff ff       	call   801010e9 <fileclose>
80105d92:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d98:	83 ec 0c             	sub    $0xc,%esp
80105d9b:	50                   	push   %eax
80105d9c:	e8 48 b3 ff ff       	call   801010e9 <fileclose>
80105da1:	83 c4 10             	add    $0x10,%esp
    return -1;
80105da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da9:	eb 18                	jmp    80105dc3 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105dab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105db1:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105db3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105db6:	8d 50 04             	lea    0x4(%eax),%edx
80105db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbc:	89 02                	mov    %eax,(%edx)
  return 0;
80105dbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dc3:	c9                   	leave  
80105dc4:	c3                   	ret    

80105dc5 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105dc5:	f3 0f 1e fb          	endbr32 
80105dc9:	55                   	push   %ebp
80105dca:	89 e5                	mov    %esp,%ebp
80105dcc:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105dcf:	e8 f2 e0 ff ff       	call   80103ec6 <fork>
}
80105dd4:	c9                   	leave  
80105dd5:	c3                   	ret    

80105dd6 <sys_exit>:

int
sys_exit(void)
{
80105dd6:	f3 0f 1e fb          	endbr32 
80105dda:	55                   	push   %ebp
80105ddb:	89 e5                	mov    %esp,%ebp
80105ddd:	83 ec 08             	sub    $0x8,%esp
  exit();
80105de0:	e8 5e e2 ff ff       	call   80104043 <exit>
  return 0;  // not reached
80105de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dea:	c9                   	leave  
80105deb:	c3                   	ret    

80105dec <sys_wait>:

int
sys_wait(void)
{
80105dec:	f3 0f 1e fb          	endbr32 
80105df0:	55                   	push   %ebp
80105df1:	89 e5                	mov    %esp,%ebp
80105df3:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105df6:	e8 6c e3 ff ff       	call   80104167 <wait>
}
80105dfb:	c9                   	leave  
80105dfc:	c3                   	ret    

80105dfd <sys_kill>:

int
sys_kill(void)
{
80105dfd:	f3 0f 1e fb          	endbr32 
80105e01:	55                   	push   %ebp
80105e02:	89 e5                	mov    %esp,%ebp
80105e04:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105e07:	83 ec 08             	sub    $0x8,%esp
80105e0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e0d:	50                   	push   %eax
80105e0e:	6a 00                	push   $0x0
80105e10:	e8 9d f0 ff ff       	call   80104eb2 <argint>
80105e15:	83 c4 10             	add    $0x10,%esp
80105e18:	85 c0                	test   %eax,%eax
80105e1a:	79 07                	jns    80105e23 <sys_kill+0x26>
    return -1;
80105e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e21:	eb 0f                	jmp    80105e32 <sys_kill+0x35>
  return kill(pid);
80105e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e26:	83 ec 0c             	sub    $0xc,%esp
80105e29:	50                   	push   %eax
80105e2a:	e8 87 e7 ff ff       	call   801045b6 <kill>
80105e2f:	83 c4 10             	add    $0x10,%esp
}
80105e32:	c9                   	leave  
80105e33:	c3                   	ret    

80105e34 <sys_getpid>:

int
sys_getpid(void)
{
80105e34:	f3 0f 1e fb          	endbr32 
80105e38:	55                   	push   %ebp
80105e39:	89 e5                	mov    %esp,%ebp
80105e3b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105e3e:	e8 66 dd ff ff       	call   80103ba9 <myproc>
80105e43:	8b 40 10             	mov    0x10(%eax),%eax
}
80105e46:	c9                   	leave  
80105e47:	c3                   	ret    

80105e48 <sys_sbrk>:

int
sys_sbrk(void)
{
80105e48:	f3 0f 1e fb          	endbr32 
80105e4c:	55                   	push   %ebp
80105e4d:	89 e5                	mov    %esp,%ebp
80105e4f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105e52:	83 ec 08             	sub    $0x8,%esp
80105e55:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e58:	50                   	push   %eax
80105e59:	6a 00                	push   $0x0
80105e5b:	e8 52 f0 ff ff       	call   80104eb2 <argint>
80105e60:	83 c4 10             	add    $0x10,%esp
80105e63:	85 c0                	test   %eax,%eax
80105e65:	79 07                	jns    80105e6e <sys_sbrk+0x26>
    return -1;
80105e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e6c:	eb 27                	jmp    80105e95 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80105e6e:	e8 36 dd ff ff       	call   80103ba9 <myproc>
80105e73:	8b 00                	mov    (%eax),%eax
80105e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7b:	83 ec 0c             	sub    $0xc,%esp
80105e7e:	50                   	push   %eax
80105e7f:	e8 a3 df ff ff       	call   80103e27 <growproc>
80105e84:	83 c4 10             	add    $0x10,%esp
80105e87:	85 c0                	test   %eax,%eax
80105e89:	79 07                	jns    80105e92 <sys_sbrk+0x4a>
    return -1;
80105e8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e90:	eb 03                	jmp    80105e95 <sys_sbrk+0x4d>
  return addr;
80105e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e95:	c9                   	leave  
80105e96:	c3                   	ret    

80105e97 <sys_sleep>:

int
sys_sleep(void)
{
80105e97:	f3 0f 1e fb          	endbr32 
80105e9b:	55                   	push   %ebp
80105e9c:	89 e5                	mov    %esp,%ebp
80105e9e:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105ea1:	83 ec 08             	sub    $0x8,%esp
80105ea4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ea7:	50                   	push   %eax
80105ea8:	6a 00                	push   $0x0
80105eaa:	e8 03 f0 ff ff       	call   80104eb2 <argint>
80105eaf:	83 c4 10             	add    $0x10,%esp
80105eb2:	85 c0                	test   %eax,%eax
80105eb4:	79 07                	jns    80105ebd <sys_sleep+0x26>
    return -1;
80105eb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebb:	eb 76                	jmp    80105f33 <sys_sleep+0x9c>
  acquire(&tickslock);
80105ebd:	83 ec 0c             	sub    $0xc,%esp
80105ec0:	68 40 75 19 80       	push   $0x80197540
80105ec5:	e8 05 ea ff ff       	call   801048cf <acquire>
80105eca:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105ecd:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80105ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105ed5:	eb 38                	jmp    80105f0f <sys_sleep+0x78>
    if(myproc()->killed){
80105ed7:	e8 cd dc ff ff       	call   80103ba9 <myproc>
80105edc:	8b 40 24             	mov    0x24(%eax),%eax
80105edf:	85 c0                	test   %eax,%eax
80105ee1:	74 17                	je     80105efa <sys_sleep+0x63>
      release(&tickslock);
80105ee3:	83 ec 0c             	sub    $0xc,%esp
80105ee6:	68 40 75 19 80       	push   $0x80197540
80105eeb:	e8 51 ea ff ff       	call   80104941 <release>
80105ef0:	83 c4 10             	add    $0x10,%esp
      return -1;
80105ef3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef8:	eb 39                	jmp    80105f33 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80105efa:	83 ec 08             	sub    $0x8,%esp
80105efd:	68 40 75 19 80       	push   $0x80197540
80105f02:	68 80 7d 19 80       	push   $0x80197d80
80105f07:	e8 80 e5 ff ff       	call   8010448c <sleep>
80105f0c:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105f0f:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80105f14:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105f17:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f1a:	39 d0                	cmp    %edx,%eax
80105f1c:	72 b9                	jb     80105ed7 <sys_sleep+0x40>
  }
  release(&tickslock);
80105f1e:	83 ec 0c             	sub    $0xc,%esp
80105f21:	68 40 75 19 80       	push   $0x80197540
80105f26:	e8 16 ea ff ff       	call   80104941 <release>
80105f2b:	83 c4 10             	add    $0x10,%esp
  return 0;
80105f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f33:	c9                   	leave  
80105f34:	c3                   	ret    

80105f35 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105f35:	f3 0f 1e fb          	endbr32 
80105f39:	55                   	push   %ebp
80105f3a:	89 e5                	mov    %esp,%ebp
80105f3c:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105f3f:	83 ec 0c             	sub    $0xc,%esp
80105f42:	68 40 75 19 80       	push   $0x80197540
80105f47:	e8 83 e9 ff ff       	call   801048cf <acquire>
80105f4c:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105f4f:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80105f54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105f57:	83 ec 0c             	sub    $0xc,%esp
80105f5a:	68 40 75 19 80       	push   $0x80197540
80105f5f:	e8 dd e9 ff ff       	call   80104941 <release>
80105f64:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f6a:	c9                   	leave  
80105f6b:	c3                   	ret    

80105f6c <sys_uthread_init>:

int sys_uthread_init(void)
{
80105f6c:	f3 0f 1e fb          	endbr32 
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
80105f73:	83 ec 18             	sub    $0x18,%esp
    // --- !!! 함수 진입 확인 로그 추가 !!! ---
    cprintf("KERN_SYSINIT_ENTRY: Reached sys_uthread_init for pid %d\n", myproc()->pid);
80105f76:	e8 2e dc ff ff       	call   80103ba9 <myproc>
80105f7b:	8b 40 10             	mov    0x10(%eax),%eax
80105f7e:	83 ec 08             	sub    $0x8,%esp
80105f81:	50                   	push   %eax
80105f82:	68 f8 a8 10 80       	push   $0x8010a8f8
80105f87:	e8 80 a4 ff ff       	call   8010040c <cprintf>
80105f8c:	83 c4 10             	add    $0x10,%esp
    // --- 여기까지 ---

    int scheduler_addr; // 사용자 스케줄러 주소를 저장할 변수
    struct proc* curproc = myproc(); // 현재 실행 중인 프로세스 정보 가져오기
80105f8f:	e8 15 dc ff ff       	call   80103ba9 <myproc>
80105f94:	89 45 f4             	mov    %eax,-0xc(%ebp)

    // 사용자 프로그램이 전달한 첫 번째 정수 인자를 읽어옴
    if (argint(0, &scheduler_addr) < 0) // 0번째 인자를 scheduler_addr 변수에 저장
80105f97:	83 ec 08             	sub    $0x8,%esp
80105f9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f9d:	50                   	push   %eax
80105f9e:	6a 00                	push   $0x0
80105fa0:	e8 0d ef ff ff       	call   80104eb2 <argint>
80105fa5:	83 c4 10             	add    $0x10,%esp
80105fa8:	85 c0                	test   %eax,%eax
80105faa:	79 07                	jns    80105fb3 <sys_uthread_init+0x47>
        return -1; // 읽기 실패 시 -1 반환
80105fac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb1:	eb 10                	jmp    80105fc3 <sys_uthread_init+0x57>

    // 읽어온 주소(정수 값)를 현재 프로세스의 scheduler 필드에 저장
    curproc->scheduler = (uint)scheduler_addr;
80105fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb6:	89 c2                	mov    %eax,%edx
80105fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbb:	89 50 7c             	mov    %edx,0x7c(%eax)
    // cprintf("KERN: Registered scheduler for pid %d at 0x%x\n", curproc->pid, curproc->scheduler); // 확인용 로그 (선택 사항)

    return 0; // 성공 시 0 반환
80105fbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fc3:	c9                   	leave  
80105fc4:	c3                   	ret    

80105fc5 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105fc5:	1e                   	push   %ds
  pushl %es
80105fc6:	06                   	push   %es
  pushl %fs
80105fc7:	0f a0                	push   %fs
  pushl %gs
80105fc9:	0f a8                	push   %gs
  pushal
80105fcb:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105fcc:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105fd0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105fd2:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105fd4:	54                   	push   %esp
  call trap
80105fd5:	e8 df 01 00 00       	call   801061b9 <trap>
  addl $4, %esp
80105fda:	83 c4 04             	add    $0x4,%esp

80105fdd <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105fdd:	61                   	popa   
  popl %gs
80105fde:	0f a9                	pop    %gs
  popl %fs
80105fe0:	0f a1                	pop    %fs
  popl %es
80105fe2:	07                   	pop    %es
  popl %ds
80105fe3:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105fe4:	83 c4 08             	add    $0x8,%esp
  iret
80105fe7:	cf                   	iret   

80105fe8 <lidt>:
{
80105fe8:	55                   	push   %ebp
80105fe9:	89 e5                	mov    %esp,%ebp
80105feb:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ff1:	83 e8 01             	sub    $0x1,%eax
80105ff4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80105ffb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105fff:	8b 45 08             	mov    0x8(%ebp),%eax
80106002:	c1 e8 10             	shr    $0x10,%eax
80106005:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106009:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010600c:	0f 01 18             	lidtl  (%eax)
}
8010600f:	90                   	nop
80106010:	c9                   	leave  
80106011:	c3                   	ret    

80106012 <rcr2>:

static inline uint
rcr2(void)
{
80106012:	55                   	push   %ebp
80106013:	89 e5                	mov    %esp,%ebp
80106015:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106018:	0f 20 d0             	mov    %cr2,%eax
8010601b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010601e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106021:	c9                   	leave  
80106022:	c3                   	ret    

80106023 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106023:	f3 0f 1e fb          	endbr32 
80106027:	55                   	push   %ebp
80106028:	89 e5                	mov    %esp,%ebp
8010602a:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
8010602d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106034:	e9 c3 00 00 00       	jmp    801060fc <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
80106039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603c:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106043:	89 c2                	mov    %eax,%edx
80106045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106048:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
8010604f:	80 
80106050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106053:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
8010605a:	80 08 00 
8010605d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106060:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106067:	80 
80106068:	83 e2 e0             	and    $0xffffffe0,%edx
8010606b:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106075:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
8010607c:	80 
8010607d:	83 e2 1f             	and    $0x1f,%edx
80106080:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608a:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106091:	80 
80106092:	83 e2 f0             	and    $0xfffffff0,%edx
80106095:	83 ca 0e             	or     $0xe,%edx
80106098:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010609f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a2:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801060a9:	80 
801060aa:	83 e2 ef             	and    $0xffffffef,%edx
801060ad:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801060b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b7:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801060be:	80 
801060bf:	83 e2 9f             	and    $0xffffff9f,%edx
801060c2:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801060c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cc:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801060d3:	80 
801060d4:	83 ca 80             	or     $0xffffff80,%edx
801060d7:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801060de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e1:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
801060e8:	c1 e8 10             	shr    $0x10,%eax
801060eb:	89 c2                	mov    %eax,%edx
801060ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f0:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801060f7:	80 
    for (i = 0; i < 256; i++)
801060f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801060fc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106103:	0f 8e 30 ff ff ff    	jle    80106039 <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106109:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
8010610e:	66 a3 80 77 19 80    	mov    %ax,0x80197780
80106114:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
8010611b:	08 00 
8010611d:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106124:	83 e0 e0             	and    $0xffffffe0,%eax
80106127:	a2 84 77 19 80       	mov    %al,0x80197784
8010612c:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106133:	83 e0 1f             	and    $0x1f,%eax
80106136:	a2 84 77 19 80       	mov    %al,0x80197784
8010613b:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106142:	83 c8 0f             	or     $0xf,%eax
80106145:	a2 85 77 19 80       	mov    %al,0x80197785
8010614a:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106151:	83 e0 ef             	and    $0xffffffef,%eax
80106154:	a2 85 77 19 80       	mov    %al,0x80197785
80106159:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106160:	83 c8 60             	or     $0x60,%eax
80106163:	a2 85 77 19 80       	mov    %al,0x80197785
80106168:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
8010616f:	83 c8 80             	or     $0xffffff80,%eax
80106172:	a2 85 77 19 80       	mov    %al,0x80197785
80106177:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
8010617c:	c1 e8 10             	shr    $0x10,%eax
8010617f:	66 a3 86 77 19 80    	mov    %ax,0x80197786

    initlock(&tickslock, "time");
80106185:	83 ec 08             	sub    $0x8,%esp
80106188:	68 34 a9 10 80       	push   $0x8010a934
8010618d:	68 40 75 19 80       	push   $0x80197540
80106192:	e8 12 e7 ff ff       	call   801048a9 <initlock>
80106197:	83 c4 10             	add    $0x10,%esp
}
8010619a:	90                   	nop
8010619b:	c9                   	leave  
8010619c:	c3                   	ret    

8010619d <idtinit>:

void
idtinit(void)
{
8010619d:	f3 0f 1e fb          	endbr32 
801061a1:	55                   	push   %ebp
801061a2:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
801061a4:	68 00 08 00 00       	push   $0x800
801061a9:	68 80 75 19 80       	push   $0x80197580
801061ae:	e8 35 fe ff ff       	call   80105fe8 <lidt>
801061b3:	83 c4 08             	add    $0x8,%esp
}
801061b6:	90                   	nop
801061b7:	c9                   	leave  
801061b8:	c3                   	ret    

801061b9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
801061b9:	f3 0f 1e fb          	endbr32 
801061bd:	55                   	push   %ebp
801061be:	89 e5                	mov    %esp,%ebp
801061c0:	57                   	push   %edi
801061c1:	56                   	push   %esi
801061c2:	53                   	push   %ebx
801061c3:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
801061c6:	8b 45 08             	mov    0x8(%ebp),%eax
801061c9:	8b 40 30             	mov    0x30(%eax),%eax
801061cc:	83 f8 40             	cmp    $0x40,%eax
801061cf:	75 3b                	jne    8010620c <trap+0x53>
        if (myproc()->killed)
801061d1:	e8 d3 d9 ff ff       	call   80103ba9 <myproc>
801061d6:	8b 40 24             	mov    0x24(%eax),%eax
801061d9:	85 c0                	test   %eax,%eax
801061db:	74 05                	je     801061e2 <trap+0x29>
            exit();
801061dd:	e8 61 de ff ff       	call   80104043 <exit>
        myproc()->tf = tf;
801061e2:	e8 c2 d9 ff ff       	call   80103ba9 <myproc>
801061e7:	8b 55 08             	mov    0x8(%ebp),%edx
801061ea:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
801061ed:	e8 98 ed ff ff       	call   80104f8a <syscall>
        if (myproc()->killed)
801061f2:	e8 b2 d9 ff ff       	call   80103ba9 <myproc>
801061f7:	8b 40 24             	mov    0x24(%eax),%eax
801061fa:	85 c0                	test   %eax,%eax
801061fc:	0f 84 40 03 00 00    	je     80106542 <trap+0x389>
            exit();
80106202:	e8 3c de ff ff       	call   80104043 <exit>
        return;
80106207:	e9 36 03 00 00       	jmp    80106542 <trap+0x389>
    }

    switch (tf->trapno) {
8010620c:	8b 45 08             	mov    0x8(%ebp),%eax
8010620f:	8b 40 30             	mov    0x30(%eax),%eax
80106212:	83 e8 20             	sub    $0x20,%eax
80106215:	83 f8 1f             	cmp    $0x1f,%eax
80106218:	0f 87 ec 01 00 00    	ja     8010640a <trap+0x251>
8010621e:	8b 04 85 64 aa 10 80 	mov    -0x7fef559c(,%eax,4),%eax
80106225:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
80106228:	e8 e1 d8 ff ff       	call   80103b0e <cpuid>
8010622d:	85 c0                	test   %eax,%eax
8010622f:	75 3d                	jne    8010626e <trap+0xb5>
            acquire(&tickslock);
80106231:	83 ec 0c             	sub    $0xc,%esp
80106234:	68 40 75 19 80       	push   $0x80197540
80106239:	e8 91 e6 ff ff       	call   801048cf <acquire>
8010623e:	83 c4 10             	add    $0x10,%esp
            ticks++;
80106241:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106246:	83 c0 01             	add    $0x1,%eax
80106249:	a3 80 7d 19 80       	mov    %eax,0x80197d80
            wakeup(&ticks);
8010624e:	83 ec 0c             	sub    $0xc,%esp
80106251:	68 80 7d 19 80       	push   $0x80197d80
80106256:	e8 20 e3 ff ff       	call   8010457b <wakeup>
8010625b:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
8010625e:	83 ec 0c             	sub    $0xc,%esp
80106261:	68 40 75 19 80       	push   $0x80197540
80106266:	e8 d6 e6 ff ff       	call   80104941 <release>
8010626b:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();
8010626e:	e8 b2 c9 ff ff       	call   80102c25 <lapiceoi>
        
        struct proc* p = myproc(); // 현재 프로세스 가져오기
80106273:	e8 31 d9 ff ff       	call   80103ba9 <myproc>
80106278:	89 45 e4             	mov    %eax,-0x1c(%ebp)

        // 사용자 스케줄러 호출 조건 확인 및 실행
        if (p != 0 && p->state == RUNNING && (tf->cs & 3) == DPL_USER && p->scheduler != 0) {
8010627b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010627f:	0f 84 be 00 00 00    	je     80106343 <trap+0x18a>
80106285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106288:	8b 40 0c             	mov    0xc(%eax),%eax
8010628b:	83 f8 04             	cmp    $0x4,%eax
8010628e:	0f 85 af 00 00 00    	jne    80106343 <trap+0x18a>
80106294:	8b 45 08             	mov    0x8(%ebp),%eax
80106297:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010629b:	0f b7 c0             	movzwl %ax,%eax
8010629e:	83 e0 03             	and    $0x3,%eax
801062a1:	83 f8 03             	cmp    $0x3,%eax
801062a4:	0f 85 99 00 00 00    	jne    80106343 <trap+0x18a>
801062aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062ad:	8b 40 7c             	mov    0x7c(%eax),%eax
801062b0:	85 c0                	test   %eax,%eax
801062b2:	0f 84 8b 00 00 00    	je     80106343 <trap+0x18a>
            // 사용자 모드 실행 중, RUNNING 상태, 스케줄러 등록됨 -> 사용자 수준 선점 시도
            uint original_eip = tf->eip;
801062b8:	8b 45 08             	mov    0x8(%ebp),%eax
801062bb:	8b 40 38             	mov    0x38(%eax),%eax
801062be:	89 45 dc             	mov    %eax,-0x24(%ebp)
            uint user_esp = tf->esp;
801062c1:	8b 45 08             	mov    0x8(%ebp),%eax
801062c4:	8b 40 44             	mov    0x44(%eax),%eax
801062c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
            user_esp -= 4; // 복귀 주소 저장 공간 확보               
801062ca:	83 6d e0 04          	subl   $0x4,-0x20(%ebp)

            if (copyout(p->pgdir, user_esp, &original_eip, sizeof(original_eip)) < 0) {
801062ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d1:	8b 40 04             	mov    0x4(%eax),%eax
801062d4:	6a 04                	push   $0x4
801062d6:	8d 55 dc             	lea    -0x24(%ebp),%edx
801062d9:	52                   	push   %edx
801062da:	ff 75 e0             	pushl  -0x20(%ebp)
801062dd:	50                   	push   %eax
801062de:	e8 d0 1b 00 00       	call   80107eb3 <copyout>
801062e3:	83 c4 10             	add    $0x10,%esp
801062e6:	85 c0                	test   %eax,%eax
801062e8:	79 23                	jns    8010630d <trap+0x154>
                // copyout 실패 시 오류 처리
                cprintf("KERN_ERR: trap.c: copyout failed for EIP save, pid=%d\n", p->pid);
801062ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062ed:	8b 40 10             	mov    0x10(%eax),%eax
801062f0:	83 ec 08             	sub    $0x8,%esp
801062f3:	50                   	push   %eax
801062f4:	68 3c a9 10 80       	push   $0x8010a93c
801062f9:	e8 0e a1 ff ff       	call   8010040c <cprintf>
801062fe:	83 c4 10             	add    $0x10,%esp
                p->killed = 1;
80106301:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106304:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010630b:	eb 36                	jmp    80106343 <trap+0x18a>
                // 오류 발생 시 아래의 표준 종료/양보 로직으로 넘어감
            }
            else {
                // copyout 성공 시: 트랩 프레임 수정하여 스케줄러로 점프 준비
                tf->esp = user_esp;
8010630d:	8b 45 08             	mov    0x8(%ebp),%eax
80106310:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106313:	89 50 44             	mov    %edx,0x44(%eax)
                tf->eip = p->scheduler;
80106316:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106319:	8b 50 7c             	mov    0x7c(%eax),%edx
8010631c:	8b 45 08             	mov    0x8(%ebp),%eax
8010631f:	89 50 38             	mov    %edx,0x38(%eax)
                // 사용자 스케줄러가 호출될 것이므로, 커널 수준의 yield()는 건너뜀
                // iret 명령어로 사용자 스케줄러로 바로 복귀하게 됨.
                // 이후 프로세스 종료 여부 확인은 여전히 필요.

                // 디버깅 로그 (필요시 유지)
                cprintf("KERN_INFO: trap.c: Saved EIP 0x%x to user_esp 0x%x, jumping to scheduler 0x%x\n", original_eip, tf->esp, tf->eip);
80106322:	8b 45 08             	mov    0x8(%ebp),%eax
80106325:	8b 48 38             	mov    0x38(%eax),%ecx
80106328:	8b 45 08             	mov    0x8(%ebp),%eax
8010632b:	8b 50 44             	mov    0x44(%eax),%edx
8010632e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106331:	51                   	push   %ecx
80106332:	52                   	push   %edx
80106333:	50                   	push   %eax
80106334:	68 74 a9 10 80       	push   $0x8010a974
80106339:	e8 ce a0 ff ff       	call   8010040c <cprintf>
8010633e:	83 c4 10             	add    $0x10,%esp
80106341:	eb 24                	jmp    80106367 <trap+0x1ae>
            }
        }

        // 사용자 스케줄러가 호출되지 않은 경우 (커널 모드, 스케줄러 미등록 등)
        // 또는 copyout이 실패한 경우, 기존 커널 수준 yield 실행
        if (p && p->state == RUNNING && tf->trapno == T_IRQ0 + IRQ_TIMER) {
80106343:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106347:	74 1d                	je     80106366 <trap+0x1ad>
80106349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010634c:	8b 40 0c             	mov    0xc(%eax),%eax
8010634f:	83 f8 04             	cmp    $0x4,%eax
80106352:	75 12                	jne    80106366 <trap+0x1ad>
80106354:	8b 45 08             	mov    0x8(%ebp),%eax
80106357:	8b 40 30             	mov    0x30(%eax),%eax
8010635a:	83 f8 20             	cmp    $0x20,%eax
8010635d:	75 07                	jne    80106366 <trap+0x1ad>
            yield();
8010635f:	e8 a0 e0 ff ff       	call   80104404 <yield>
80106364:	eb 01                	jmp    80106367 <trap+0x1ae>
        }

    check_exit: // goto 타겟 레이블
80106366:	90                   	nop
        // 프로세스 종료 여부 확인 (공통 로직)
        if (p && p->killed && (tf->cs & 3) == DPL_USER)
80106367:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010636b:	0f 84 50 01 00 00    	je     801064c1 <trap+0x308>
80106371:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106374:	8b 40 24             	mov    0x24(%eax),%eax
80106377:	85 c0                	test   %eax,%eax
80106379:	0f 84 42 01 00 00    	je     801064c1 <trap+0x308>
8010637f:	8b 45 08             	mov    0x8(%ebp),%eax
80106382:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106386:	0f b7 c0             	movzwl %ax,%eax
80106389:	83 e0 03             	and    $0x3,%eax
8010638c:	83 f8 03             	cmp    $0x3,%eax
8010638f:	0f 85 2c 01 00 00    	jne    801064c1 <trap+0x308>
            exit();
80106395:	e8 a9 dc ff ff       	call   80104043 <exit>
        
        break;
8010639a:	e9 22 01 00 00       	jmp    801064c1 <trap+0x308>
    case T_IRQ0 + IRQ_IDE:
        ideintr();
8010639f:	e8 1e 40 00 00       	call   8010a3c2 <ideintr>
        lapiceoi();
801063a4:	e8 7c c8 ff ff       	call   80102c25 <lapiceoi>
        break;
801063a9:	e9 14 01 00 00       	jmp    801064c2 <trap+0x309>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
801063ae:	e8 a8 c6 ff ff       	call   80102a5b <kbdintr>
        lapiceoi();
801063b3:	e8 6d c8 ff ff       	call   80102c25 <lapiceoi>
        break;
801063b8:	e9 05 01 00 00       	jmp    801064c2 <trap+0x309>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
801063bd:	e8 62 03 00 00       	call   80106724 <uartintr>
        lapiceoi();
801063c2:	e8 5e c8 ff ff       	call   80102c25 <lapiceoi>
        break;
801063c7:	e9 f6 00 00 00       	jmp    801064c2 <trap+0x309>
    case T_IRQ0 + 0xB:
        i8254_intr();
801063cc:	e8 30 2c 00 00       	call   80109001 <i8254_intr>
        lapiceoi();
801063d1:	e8 4f c8 ff ff       	call   80102c25 <lapiceoi>
        break;
801063d6:	e9 e7 00 00 00       	jmp    801064c2 <trap+0x309>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063db:	8b 45 08             	mov    0x8(%ebp),%eax
801063de:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801063e1:	8b 45 08             	mov    0x8(%ebp),%eax
801063e4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063e8:	0f b7 d8             	movzwl %ax,%ebx
801063eb:	e8 1e d7 ff ff       	call   80103b0e <cpuid>
801063f0:	56                   	push   %esi
801063f1:	53                   	push   %ebx
801063f2:	50                   	push   %eax
801063f3:	68 c4 a9 10 80       	push   $0x8010a9c4
801063f8:	e8 0f a0 ff ff       	call   8010040c <cprintf>
801063fd:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
80106400:	e8 20 c8 ff ff       	call   80102c25 <lapiceoi>
        break;
80106405:	e9 b8 00 00 00       	jmp    801064c2 <trap+0x309>

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
8010640a:	e8 9a d7 ff ff       	call   80103ba9 <myproc>
8010640f:	85 c0                	test   %eax,%eax
80106411:	74 11                	je     80106424 <trap+0x26b>
80106413:	8b 45 08             	mov    0x8(%ebp),%eax
80106416:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010641a:	0f b7 c0             	movzwl %ax,%eax
8010641d:	83 e0 03             	and    $0x3,%eax
80106420:	85 c0                	test   %eax,%eax
80106422:	75 39                	jne    8010645d <trap+0x2a4>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106424:	e8 e9 fb ff ff       	call   80106012 <rcr2>
80106429:	89 c3                	mov    %eax,%ebx
8010642b:	8b 45 08             	mov    0x8(%ebp),%eax
8010642e:	8b 70 38             	mov    0x38(%eax),%esi
80106431:	e8 d8 d6 ff ff       	call   80103b0e <cpuid>
80106436:	8b 55 08             	mov    0x8(%ebp),%edx
80106439:	8b 52 30             	mov    0x30(%edx),%edx
8010643c:	83 ec 0c             	sub    $0xc,%esp
8010643f:	53                   	push   %ebx
80106440:	56                   	push   %esi
80106441:	50                   	push   %eax
80106442:	52                   	push   %edx
80106443:	68 e8 a9 10 80       	push   $0x8010a9e8
80106448:	e8 bf 9f ff ff       	call   8010040c <cprintf>
8010644d:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
80106450:	83 ec 0c             	sub    $0xc,%esp
80106453:	68 1a aa 10 80       	push   $0x8010aa1a
80106458:	e8 68 a1 ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
8010645d:	e8 b0 fb ff ff       	call   80106012 <rcr2>
80106462:	89 c6                	mov    %eax,%esi
80106464:	8b 45 08             	mov    0x8(%ebp),%eax
80106467:	8b 40 38             	mov    0x38(%eax),%eax
8010646a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010646d:	e8 9c d6 ff ff       	call   80103b0e <cpuid>
80106472:	89 c3                	mov    %eax,%ebx
80106474:	8b 45 08             	mov    0x8(%ebp),%eax
80106477:	8b 48 34             	mov    0x34(%eax),%ecx
8010647a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010647d:	8b 45 08             	mov    0x8(%ebp),%eax
80106480:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106483:	e8 21 d7 ff ff       	call   80103ba9 <myproc>
80106488:	8d 50 6c             	lea    0x6c(%eax),%edx
8010648b:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010648e:	e8 16 d7 ff ff       	call   80103ba9 <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106493:	8b 40 10             	mov    0x10(%eax),%eax
80106496:	56                   	push   %esi
80106497:	ff 75 d4             	pushl  -0x2c(%ebp)
8010649a:	53                   	push   %ebx
8010649b:	ff 75 d0             	pushl  -0x30(%ebp)
8010649e:	57                   	push   %edi
8010649f:	ff 75 cc             	pushl  -0x34(%ebp)
801064a2:	50                   	push   %eax
801064a3:	68 20 aa 10 80       	push   $0x8010aa20
801064a8:	e8 5f 9f ff ff       	call   8010040c <cprintf>
801064ad:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
801064b0:	e8 f4 d6 ff ff       	call   80103ba9 <myproc>
801064b5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801064bc:	eb 04                	jmp    801064c2 <trap+0x309>
        break;
801064be:	90                   	nop
801064bf:	eb 01                	jmp    801064c2 <trap+0x309>
        break;
801064c1:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
801064c2:	e8 e2 d6 ff ff       	call   80103ba9 <myproc>
801064c7:	85 c0                	test   %eax,%eax
801064c9:	74 23                	je     801064ee <trap+0x335>
801064cb:	e8 d9 d6 ff ff       	call   80103ba9 <myproc>
801064d0:	8b 40 24             	mov    0x24(%eax),%eax
801064d3:	85 c0                	test   %eax,%eax
801064d5:	74 17                	je     801064ee <trap+0x335>
801064d7:	8b 45 08             	mov    0x8(%ebp),%eax
801064da:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064de:	0f b7 c0             	movzwl %ax,%eax
801064e1:	83 e0 03             	and    $0x3,%eax
801064e4:	83 f8 03             	cmp    $0x3,%eax
801064e7:	75 05                	jne    801064ee <trap+0x335>
        exit();
801064e9:	e8 55 db ff ff       	call   80104043 <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
801064ee:	e8 b6 d6 ff ff       	call   80103ba9 <myproc>
801064f3:	85 c0                	test   %eax,%eax
801064f5:	74 1d                	je     80106514 <trap+0x35b>
801064f7:	e8 ad d6 ff ff       	call   80103ba9 <myproc>
801064fc:	8b 40 0c             	mov    0xc(%eax),%eax
801064ff:	83 f8 04             	cmp    $0x4,%eax
80106502:	75 10                	jne    80106514 <trap+0x35b>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
80106504:	8b 45 08             	mov    0x8(%ebp),%eax
80106507:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
8010650a:	83 f8 20             	cmp    $0x20,%eax
8010650d:	75 05                	jne    80106514 <trap+0x35b>
        yield();
8010650f:	e8 f0 de ff ff       	call   80104404 <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106514:	e8 90 d6 ff ff       	call   80103ba9 <myproc>
80106519:	85 c0                	test   %eax,%eax
8010651b:	74 26                	je     80106543 <trap+0x38a>
8010651d:	e8 87 d6 ff ff       	call   80103ba9 <myproc>
80106522:	8b 40 24             	mov    0x24(%eax),%eax
80106525:	85 c0                	test   %eax,%eax
80106527:	74 1a                	je     80106543 <trap+0x38a>
80106529:	8b 45 08             	mov    0x8(%ebp),%eax
8010652c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106530:	0f b7 c0             	movzwl %ax,%eax
80106533:	83 e0 03             	and    $0x3,%eax
80106536:	83 f8 03             	cmp    $0x3,%eax
80106539:	75 08                	jne    80106543 <trap+0x38a>
        exit();
8010653b:	e8 03 db ff ff       	call   80104043 <exit>
80106540:	eb 01                	jmp    80106543 <trap+0x38a>
        return;
80106542:	90                   	nop
}
80106543:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106546:	5b                   	pop    %ebx
80106547:	5e                   	pop    %esi
80106548:	5f                   	pop    %edi
80106549:	5d                   	pop    %ebp
8010654a:	c3                   	ret    

8010654b <inb>:
{
8010654b:	55                   	push   %ebp
8010654c:	89 e5                	mov    %esp,%ebp
8010654e:	83 ec 14             	sub    $0x14,%esp
80106551:	8b 45 08             	mov    0x8(%ebp),%eax
80106554:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106558:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010655c:	89 c2                	mov    %eax,%edx
8010655e:	ec                   	in     (%dx),%al
8010655f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106562:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106566:	c9                   	leave  
80106567:	c3                   	ret    

80106568 <outb>:
{
80106568:	55                   	push   %ebp
80106569:	89 e5                	mov    %esp,%ebp
8010656b:	83 ec 08             	sub    $0x8,%esp
8010656e:	8b 45 08             	mov    0x8(%ebp),%eax
80106571:	8b 55 0c             	mov    0xc(%ebp),%edx
80106574:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106578:	89 d0                	mov    %edx,%eax
8010657a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010657d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106581:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106585:	ee                   	out    %al,(%dx)
}
80106586:	90                   	nop
80106587:	c9                   	leave  
80106588:	c3                   	ret    

80106589 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106589:	f3 0f 1e fb          	endbr32 
8010658d:	55                   	push   %ebp
8010658e:	89 e5                	mov    %esp,%ebp
80106590:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106593:	6a 00                	push   $0x0
80106595:	68 fa 03 00 00       	push   $0x3fa
8010659a:	e8 c9 ff ff ff       	call   80106568 <outb>
8010659f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801065a2:	68 80 00 00 00       	push   $0x80
801065a7:	68 fb 03 00 00       	push   $0x3fb
801065ac:	e8 b7 ff ff ff       	call   80106568 <outb>
801065b1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801065b4:	6a 0c                	push   $0xc
801065b6:	68 f8 03 00 00       	push   $0x3f8
801065bb:	e8 a8 ff ff ff       	call   80106568 <outb>
801065c0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801065c3:	6a 00                	push   $0x0
801065c5:	68 f9 03 00 00       	push   $0x3f9
801065ca:	e8 99 ff ff ff       	call   80106568 <outb>
801065cf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801065d2:	6a 03                	push   $0x3
801065d4:	68 fb 03 00 00       	push   $0x3fb
801065d9:	e8 8a ff ff ff       	call   80106568 <outb>
801065de:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801065e1:	6a 00                	push   $0x0
801065e3:	68 fc 03 00 00       	push   $0x3fc
801065e8:	e8 7b ff ff ff       	call   80106568 <outb>
801065ed:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801065f0:	6a 01                	push   $0x1
801065f2:	68 f9 03 00 00       	push   $0x3f9
801065f7:	e8 6c ff ff ff       	call   80106568 <outb>
801065fc:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801065ff:	68 fd 03 00 00       	push   $0x3fd
80106604:	e8 42 ff ff ff       	call   8010654b <inb>
80106609:	83 c4 04             	add    $0x4,%esp
8010660c:	3c ff                	cmp    $0xff,%al
8010660e:	74 61                	je     80106671 <uartinit+0xe8>
    return;
  uart = 1;
80106610:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106617:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010661a:	68 fa 03 00 00       	push   $0x3fa
8010661f:	e8 27 ff ff ff       	call   8010654b <inb>
80106624:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106627:	68 f8 03 00 00       	push   $0x3f8
8010662c:	e8 1a ff ff ff       	call   8010654b <inb>
80106631:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106634:	83 ec 08             	sub    $0x8,%esp
80106637:	6a 00                	push   $0x0
80106639:	6a 04                	push   $0x4
8010663b:	e8 cc c0 ff ff       	call   8010270c <ioapicenable>
80106640:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106643:	c7 45 f4 e4 aa 10 80 	movl   $0x8010aae4,-0xc(%ebp)
8010664a:	eb 19                	jmp    80106665 <uartinit+0xdc>
    uartputc(*p);
8010664c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664f:	0f b6 00             	movzbl (%eax),%eax
80106652:	0f be c0             	movsbl %al,%eax
80106655:	83 ec 0c             	sub    $0xc,%esp
80106658:	50                   	push   %eax
80106659:	e8 16 00 00 00       	call   80106674 <uartputc>
8010665e:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106661:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106668:	0f b6 00             	movzbl (%eax),%eax
8010666b:	84 c0                	test   %al,%al
8010666d:	75 dd                	jne    8010664c <uartinit+0xc3>
8010666f:	eb 01                	jmp    80106672 <uartinit+0xe9>
    return;
80106671:	90                   	nop
}
80106672:	c9                   	leave  
80106673:	c3                   	ret    

80106674 <uartputc>:

void
uartputc(int c)
{
80106674:	f3 0f 1e fb          	endbr32 
80106678:	55                   	push   %ebp
80106679:	89 e5                	mov    %esp,%ebp
8010667b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010667e:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106683:	85 c0                	test   %eax,%eax
80106685:	74 53                	je     801066da <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106687:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010668e:	eb 11                	jmp    801066a1 <uartputc+0x2d>
    microdelay(10);
80106690:	83 ec 0c             	sub    $0xc,%esp
80106693:	6a 0a                	push   $0xa
80106695:	e8 aa c5 ff ff       	call   80102c44 <microdelay>
8010669a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010669d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066a1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801066a5:	7f 1a                	jg     801066c1 <uartputc+0x4d>
801066a7:	83 ec 0c             	sub    $0xc,%esp
801066aa:	68 fd 03 00 00       	push   $0x3fd
801066af:	e8 97 fe ff ff       	call   8010654b <inb>
801066b4:	83 c4 10             	add    $0x10,%esp
801066b7:	0f b6 c0             	movzbl %al,%eax
801066ba:	83 e0 20             	and    $0x20,%eax
801066bd:	85 c0                	test   %eax,%eax
801066bf:	74 cf                	je     80106690 <uartputc+0x1c>
  outb(COM1+0, c);
801066c1:	8b 45 08             	mov    0x8(%ebp),%eax
801066c4:	0f b6 c0             	movzbl %al,%eax
801066c7:	83 ec 08             	sub    $0x8,%esp
801066ca:	50                   	push   %eax
801066cb:	68 f8 03 00 00       	push   $0x3f8
801066d0:	e8 93 fe ff ff       	call   80106568 <outb>
801066d5:	83 c4 10             	add    $0x10,%esp
801066d8:	eb 01                	jmp    801066db <uartputc+0x67>
    return;
801066da:	90                   	nop
}
801066db:	c9                   	leave  
801066dc:	c3                   	ret    

801066dd <uartgetc>:

static int
uartgetc(void)
{
801066dd:	f3 0f 1e fb          	endbr32 
801066e1:	55                   	push   %ebp
801066e2:	89 e5                	mov    %esp,%ebp
  if(!uart)
801066e4:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801066e9:	85 c0                	test   %eax,%eax
801066eb:	75 07                	jne    801066f4 <uartgetc+0x17>
    return -1;
801066ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f2:	eb 2e                	jmp    80106722 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801066f4:	68 fd 03 00 00       	push   $0x3fd
801066f9:	e8 4d fe ff ff       	call   8010654b <inb>
801066fe:	83 c4 04             	add    $0x4,%esp
80106701:	0f b6 c0             	movzbl %al,%eax
80106704:	83 e0 01             	and    $0x1,%eax
80106707:	85 c0                	test   %eax,%eax
80106709:	75 07                	jne    80106712 <uartgetc+0x35>
    return -1;
8010670b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106710:	eb 10                	jmp    80106722 <uartgetc+0x45>
  return inb(COM1+0);
80106712:	68 f8 03 00 00       	push   $0x3f8
80106717:	e8 2f fe ff ff       	call   8010654b <inb>
8010671c:	83 c4 04             	add    $0x4,%esp
8010671f:	0f b6 c0             	movzbl %al,%eax
}
80106722:	c9                   	leave  
80106723:	c3                   	ret    

80106724 <uartintr>:

void
uartintr(void)
{
80106724:	f3 0f 1e fb          	endbr32 
80106728:	55                   	push   %ebp
80106729:	89 e5                	mov    %esp,%ebp
8010672b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010672e:	83 ec 0c             	sub    $0xc,%esp
80106731:	68 dd 66 10 80       	push   $0x801066dd
80106736:	e8 c5 a0 ff ff       	call   80100800 <consoleintr>
8010673b:	83 c4 10             	add    $0x10,%esp
}
8010673e:	90                   	nop
8010673f:	c9                   	leave  
80106740:	c3                   	ret    

80106741 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106741:	6a 00                	push   $0x0
  pushl $0
80106743:	6a 00                	push   $0x0
  jmp alltraps
80106745:	e9 7b f8 ff ff       	jmp    80105fc5 <alltraps>

8010674a <vector1>:
.globl vector1
vector1:
  pushl $0
8010674a:	6a 00                	push   $0x0
  pushl $1
8010674c:	6a 01                	push   $0x1
  jmp alltraps
8010674e:	e9 72 f8 ff ff       	jmp    80105fc5 <alltraps>

80106753 <vector2>:
.globl vector2
vector2:
  pushl $0
80106753:	6a 00                	push   $0x0
  pushl $2
80106755:	6a 02                	push   $0x2
  jmp alltraps
80106757:	e9 69 f8 ff ff       	jmp    80105fc5 <alltraps>

8010675c <vector3>:
.globl vector3
vector3:
  pushl $0
8010675c:	6a 00                	push   $0x0
  pushl $3
8010675e:	6a 03                	push   $0x3
  jmp alltraps
80106760:	e9 60 f8 ff ff       	jmp    80105fc5 <alltraps>

80106765 <vector4>:
.globl vector4
vector4:
  pushl $0
80106765:	6a 00                	push   $0x0
  pushl $4
80106767:	6a 04                	push   $0x4
  jmp alltraps
80106769:	e9 57 f8 ff ff       	jmp    80105fc5 <alltraps>

8010676e <vector5>:
.globl vector5
vector5:
  pushl $0
8010676e:	6a 00                	push   $0x0
  pushl $5
80106770:	6a 05                	push   $0x5
  jmp alltraps
80106772:	e9 4e f8 ff ff       	jmp    80105fc5 <alltraps>

80106777 <vector6>:
.globl vector6
vector6:
  pushl $0
80106777:	6a 00                	push   $0x0
  pushl $6
80106779:	6a 06                	push   $0x6
  jmp alltraps
8010677b:	e9 45 f8 ff ff       	jmp    80105fc5 <alltraps>

80106780 <vector7>:
.globl vector7
vector7:
  pushl $0
80106780:	6a 00                	push   $0x0
  pushl $7
80106782:	6a 07                	push   $0x7
  jmp alltraps
80106784:	e9 3c f8 ff ff       	jmp    80105fc5 <alltraps>

80106789 <vector8>:
.globl vector8
vector8:
  pushl $8
80106789:	6a 08                	push   $0x8
  jmp alltraps
8010678b:	e9 35 f8 ff ff       	jmp    80105fc5 <alltraps>

80106790 <vector9>:
.globl vector9
vector9:
  pushl $0
80106790:	6a 00                	push   $0x0
  pushl $9
80106792:	6a 09                	push   $0x9
  jmp alltraps
80106794:	e9 2c f8 ff ff       	jmp    80105fc5 <alltraps>

80106799 <vector10>:
.globl vector10
vector10:
  pushl $10
80106799:	6a 0a                	push   $0xa
  jmp alltraps
8010679b:	e9 25 f8 ff ff       	jmp    80105fc5 <alltraps>

801067a0 <vector11>:
.globl vector11
vector11:
  pushl $11
801067a0:	6a 0b                	push   $0xb
  jmp alltraps
801067a2:	e9 1e f8 ff ff       	jmp    80105fc5 <alltraps>

801067a7 <vector12>:
.globl vector12
vector12:
  pushl $12
801067a7:	6a 0c                	push   $0xc
  jmp alltraps
801067a9:	e9 17 f8 ff ff       	jmp    80105fc5 <alltraps>

801067ae <vector13>:
.globl vector13
vector13:
  pushl $13
801067ae:	6a 0d                	push   $0xd
  jmp alltraps
801067b0:	e9 10 f8 ff ff       	jmp    80105fc5 <alltraps>

801067b5 <vector14>:
.globl vector14
vector14:
  pushl $14
801067b5:	6a 0e                	push   $0xe
  jmp alltraps
801067b7:	e9 09 f8 ff ff       	jmp    80105fc5 <alltraps>

801067bc <vector15>:
.globl vector15
vector15:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $15
801067be:	6a 0f                	push   $0xf
  jmp alltraps
801067c0:	e9 00 f8 ff ff       	jmp    80105fc5 <alltraps>

801067c5 <vector16>:
.globl vector16
vector16:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $16
801067c7:	6a 10                	push   $0x10
  jmp alltraps
801067c9:	e9 f7 f7 ff ff       	jmp    80105fc5 <alltraps>

801067ce <vector17>:
.globl vector17
vector17:
  pushl $17
801067ce:	6a 11                	push   $0x11
  jmp alltraps
801067d0:	e9 f0 f7 ff ff       	jmp    80105fc5 <alltraps>

801067d5 <vector18>:
.globl vector18
vector18:
  pushl $0
801067d5:	6a 00                	push   $0x0
  pushl $18
801067d7:	6a 12                	push   $0x12
  jmp alltraps
801067d9:	e9 e7 f7 ff ff       	jmp    80105fc5 <alltraps>

801067de <vector19>:
.globl vector19
vector19:
  pushl $0
801067de:	6a 00                	push   $0x0
  pushl $19
801067e0:	6a 13                	push   $0x13
  jmp alltraps
801067e2:	e9 de f7 ff ff       	jmp    80105fc5 <alltraps>

801067e7 <vector20>:
.globl vector20
vector20:
  pushl $0
801067e7:	6a 00                	push   $0x0
  pushl $20
801067e9:	6a 14                	push   $0x14
  jmp alltraps
801067eb:	e9 d5 f7 ff ff       	jmp    80105fc5 <alltraps>

801067f0 <vector21>:
.globl vector21
vector21:
  pushl $0
801067f0:	6a 00                	push   $0x0
  pushl $21
801067f2:	6a 15                	push   $0x15
  jmp alltraps
801067f4:	e9 cc f7 ff ff       	jmp    80105fc5 <alltraps>

801067f9 <vector22>:
.globl vector22
vector22:
  pushl $0
801067f9:	6a 00                	push   $0x0
  pushl $22
801067fb:	6a 16                	push   $0x16
  jmp alltraps
801067fd:	e9 c3 f7 ff ff       	jmp    80105fc5 <alltraps>

80106802 <vector23>:
.globl vector23
vector23:
  pushl $0
80106802:	6a 00                	push   $0x0
  pushl $23
80106804:	6a 17                	push   $0x17
  jmp alltraps
80106806:	e9 ba f7 ff ff       	jmp    80105fc5 <alltraps>

8010680b <vector24>:
.globl vector24
vector24:
  pushl $0
8010680b:	6a 00                	push   $0x0
  pushl $24
8010680d:	6a 18                	push   $0x18
  jmp alltraps
8010680f:	e9 b1 f7 ff ff       	jmp    80105fc5 <alltraps>

80106814 <vector25>:
.globl vector25
vector25:
  pushl $0
80106814:	6a 00                	push   $0x0
  pushl $25
80106816:	6a 19                	push   $0x19
  jmp alltraps
80106818:	e9 a8 f7 ff ff       	jmp    80105fc5 <alltraps>

8010681d <vector26>:
.globl vector26
vector26:
  pushl $0
8010681d:	6a 00                	push   $0x0
  pushl $26
8010681f:	6a 1a                	push   $0x1a
  jmp alltraps
80106821:	e9 9f f7 ff ff       	jmp    80105fc5 <alltraps>

80106826 <vector27>:
.globl vector27
vector27:
  pushl $0
80106826:	6a 00                	push   $0x0
  pushl $27
80106828:	6a 1b                	push   $0x1b
  jmp alltraps
8010682a:	e9 96 f7 ff ff       	jmp    80105fc5 <alltraps>

8010682f <vector28>:
.globl vector28
vector28:
  pushl $0
8010682f:	6a 00                	push   $0x0
  pushl $28
80106831:	6a 1c                	push   $0x1c
  jmp alltraps
80106833:	e9 8d f7 ff ff       	jmp    80105fc5 <alltraps>

80106838 <vector29>:
.globl vector29
vector29:
  pushl $0
80106838:	6a 00                	push   $0x0
  pushl $29
8010683a:	6a 1d                	push   $0x1d
  jmp alltraps
8010683c:	e9 84 f7 ff ff       	jmp    80105fc5 <alltraps>

80106841 <vector30>:
.globl vector30
vector30:
  pushl $0
80106841:	6a 00                	push   $0x0
  pushl $30
80106843:	6a 1e                	push   $0x1e
  jmp alltraps
80106845:	e9 7b f7 ff ff       	jmp    80105fc5 <alltraps>

8010684a <vector31>:
.globl vector31
vector31:
  pushl $0
8010684a:	6a 00                	push   $0x0
  pushl $31
8010684c:	6a 1f                	push   $0x1f
  jmp alltraps
8010684e:	e9 72 f7 ff ff       	jmp    80105fc5 <alltraps>

80106853 <vector32>:
.globl vector32
vector32:
  pushl $0
80106853:	6a 00                	push   $0x0
  pushl $32
80106855:	6a 20                	push   $0x20
  jmp alltraps
80106857:	e9 69 f7 ff ff       	jmp    80105fc5 <alltraps>

8010685c <vector33>:
.globl vector33
vector33:
  pushl $0
8010685c:	6a 00                	push   $0x0
  pushl $33
8010685e:	6a 21                	push   $0x21
  jmp alltraps
80106860:	e9 60 f7 ff ff       	jmp    80105fc5 <alltraps>

80106865 <vector34>:
.globl vector34
vector34:
  pushl $0
80106865:	6a 00                	push   $0x0
  pushl $34
80106867:	6a 22                	push   $0x22
  jmp alltraps
80106869:	e9 57 f7 ff ff       	jmp    80105fc5 <alltraps>

8010686e <vector35>:
.globl vector35
vector35:
  pushl $0
8010686e:	6a 00                	push   $0x0
  pushl $35
80106870:	6a 23                	push   $0x23
  jmp alltraps
80106872:	e9 4e f7 ff ff       	jmp    80105fc5 <alltraps>

80106877 <vector36>:
.globl vector36
vector36:
  pushl $0
80106877:	6a 00                	push   $0x0
  pushl $36
80106879:	6a 24                	push   $0x24
  jmp alltraps
8010687b:	e9 45 f7 ff ff       	jmp    80105fc5 <alltraps>

80106880 <vector37>:
.globl vector37
vector37:
  pushl $0
80106880:	6a 00                	push   $0x0
  pushl $37
80106882:	6a 25                	push   $0x25
  jmp alltraps
80106884:	e9 3c f7 ff ff       	jmp    80105fc5 <alltraps>

80106889 <vector38>:
.globl vector38
vector38:
  pushl $0
80106889:	6a 00                	push   $0x0
  pushl $38
8010688b:	6a 26                	push   $0x26
  jmp alltraps
8010688d:	e9 33 f7 ff ff       	jmp    80105fc5 <alltraps>

80106892 <vector39>:
.globl vector39
vector39:
  pushl $0
80106892:	6a 00                	push   $0x0
  pushl $39
80106894:	6a 27                	push   $0x27
  jmp alltraps
80106896:	e9 2a f7 ff ff       	jmp    80105fc5 <alltraps>

8010689b <vector40>:
.globl vector40
vector40:
  pushl $0
8010689b:	6a 00                	push   $0x0
  pushl $40
8010689d:	6a 28                	push   $0x28
  jmp alltraps
8010689f:	e9 21 f7 ff ff       	jmp    80105fc5 <alltraps>

801068a4 <vector41>:
.globl vector41
vector41:
  pushl $0
801068a4:	6a 00                	push   $0x0
  pushl $41
801068a6:	6a 29                	push   $0x29
  jmp alltraps
801068a8:	e9 18 f7 ff ff       	jmp    80105fc5 <alltraps>

801068ad <vector42>:
.globl vector42
vector42:
  pushl $0
801068ad:	6a 00                	push   $0x0
  pushl $42
801068af:	6a 2a                	push   $0x2a
  jmp alltraps
801068b1:	e9 0f f7 ff ff       	jmp    80105fc5 <alltraps>

801068b6 <vector43>:
.globl vector43
vector43:
  pushl $0
801068b6:	6a 00                	push   $0x0
  pushl $43
801068b8:	6a 2b                	push   $0x2b
  jmp alltraps
801068ba:	e9 06 f7 ff ff       	jmp    80105fc5 <alltraps>

801068bf <vector44>:
.globl vector44
vector44:
  pushl $0
801068bf:	6a 00                	push   $0x0
  pushl $44
801068c1:	6a 2c                	push   $0x2c
  jmp alltraps
801068c3:	e9 fd f6 ff ff       	jmp    80105fc5 <alltraps>

801068c8 <vector45>:
.globl vector45
vector45:
  pushl $0
801068c8:	6a 00                	push   $0x0
  pushl $45
801068ca:	6a 2d                	push   $0x2d
  jmp alltraps
801068cc:	e9 f4 f6 ff ff       	jmp    80105fc5 <alltraps>

801068d1 <vector46>:
.globl vector46
vector46:
  pushl $0
801068d1:	6a 00                	push   $0x0
  pushl $46
801068d3:	6a 2e                	push   $0x2e
  jmp alltraps
801068d5:	e9 eb f6 ff ff       	jmp    80105fc5 <alltraps>

801068da <vector47>:
.globl vector47
vector47:
  pushl $0
801068da:	6a 00                	push   $0x0
  pushl $47
801068dc:	6a 2f                	push   $0x2f
  jmp alltraps
801068de:	e9 e2 f6 ff ff       	jmp    80105fc5 <alltraps>

801068e3 <vector48>:
.globl vector48
vector48:
  pushl $0
801068e3:	6a 00                	push   $0x0
  pushl $48
801068e5:	6a 30                	push   $0x30
  jmp alltraps
801068e7:	e9 d9 f6 ff ff       	jmp    80105fc5 <alltraps>

801068ec <vector49>:
.globl vector49
vector49:
  pushl $0
801068ec:	6a 00                	push   $0x0
  pushl $49
801068ee:	6a 31                	push   $0x31
  jmp alltraps
801068f0:	e9 d0 f6 ff ff       	jmp    80105fc5 <alltraps>

801068f5 <vector50>:
.globl vector50
vector50:
  pushl $0
801068f5:	6a 00                	push   $0x0
  pushl $50
801068f7:	6a 32                	push   $0x32
  jmp alltraps
801068f9:	e9 c7 f6 ff ff       	jmp    80105fc5 <alltraps>

801068fe <vector51>:
.globl vector51
vector51:
  pushl $0
801068fe:	6a 00                	push   $0x0
  pushl $51
80106900:	6a 33                	push   $0x33
  jmp alltraps
80106902:	e9 be f6 ff ff       	jmp    80105fc5 <alltraps>

80106907 <vector52>:
.globl vector52
vector52:
  pushl $0
80106907:	6a 00                	push   $0x0
  pushl $52
80106909:	6a 34                	push   $0x34
  jmp alltraps
8010690b:	e9 b5 f6 ff ff       	jmp    80105fc5 <alltraps>

80106910 <vector53>:
.globl vector53
vector53:
  pushl $0
80106910:	6a 00                	push   $0x0
  pushl $53
80106912:	6a 35                	push   $0x35
  jmp alltraps
80106914:	e9 ac f6 ff ff       	jmp    80105fc5 <alltraps>

80106919 <vector54>:
.globl vector54
vector54:
  pushl $0
80106919:	6a 00                	push   $0x0
  pushl $54
8010691b:	6a 36                	push   $0x36
  jmp alltraps
8010691d:	e9 a3 f6 ff ff       	jmp    80105fc5 <alltraps>

80106922 <vector55>:
.globl vector55
vector55:
  pushl $0
80106922:	6a 00                	push   $0x0
  pushl $55
80106924:	6a 37                	push   $0x37
  jmp alltraps
80106926:	e9 9a f6 ff ff       	jmp    80105fc5 <alltraps>

8010692b <vector56>:
.globl vector56
vector56:
  pushl $0
8010692b:	6a 00                	push   $0x0
  pushl $56
8010692d:	6a 38                	push   $0x38
  jmp alltraps
8010692f:	e9 91 f6 ff ff       	jmp    80105fc5 <alltraps>

80106934 <vector57>:
.globl vector57
vector57:
  pushl $0
80106934:	6a 00                	push   $0x0
  pushl $57
80106936:	6a 39                	push   $0x39
  jmp alltraps
80106938:	e9 88 f6 ff ff       	jmp    80105fc5 <alltraps>

8010693d <vector58>:
.globl vector58
vector58:
  pushl $0
8010693d:	6a 00                	push   $0x0
  pushl $58
8010693f:	6a 3a                	push   $0x3a
  jmp alltraps
80106941:	e9 7f f6 ff ff       	jmp    80105fc5 <alltraps>

80106946 <vector59>:
.globl vector59
vector59:
  pushl $0
80106946:	6a 00                	push   $0x0
  pushl $59
80106948:	6a 3b                	push   $0x3b
  jmp alltraps
8010694a:	e9 76 f6 ff ff       	jmp    80105fc5 <alltraps>

8010694f <vector60>:
.globl vector60
vector60:
  pushl $0
8010694f:	6a 00                	push   $0x0
  pushl $60
80106951:	6a 3c                	push   $0x3c
  jmp alltraps
80106953:	e9 6d f6 ff ff       	jmp    80105fc5 <alltraps>

80106958 <vector61>:
.globl vector61
vector61:
  pushl $0
80106958:	6a 00                	push   $0x0
  pushl $61
8010695a:	6a 3d                	push   $0x3d
  jmp alltraps
8010695c:	e9 64 f6 ff ff       	jmp    80105fc5 <alltraps>

80106961 <vector62>:
.globl vector62
vector62:
  pushl $0
80106961:	6a 00                	push   $0x0
  pushl $62
80106963:	6a 3e                	push   $0x3e
  jmp alltraps
80106965:	e9 5b f6 ff ff       	jmp    80105fc5 <alltraps>

8010696a <vector63>:
.globl vector63
vector63:
  pushl $0
8010696a:	6a 00                	push   $0x0
  pushl $63
8010696c:	6a 3f                	push   $0x3f
  jmp alltraps
8010696e:	e9 52 f6 ff ff       	jmp    80105fc5 <alltraps>

80106973 <vector64>:
.globl vector64
vector64:
  pushl $0
80106973:	6a 00                	push   $0x0
  pushl $64
80106975:	6a 40                	push   $0x40
  jmp alltraps
80106977:	e9 49 f6 ff ff       	jmp    80105fc5 <alltraps>

8010697c <vector65>:
.globl vector65
vector65:
  pushl $0
8010697c:	6a 00                	push   $0x0
  pushl $65
8010697e:	6a 41                	push   $0x41
  jmp alltraps
80106980:	e9 40 f6 ff ff       	jmp    80105fc5 <alltraps>

80106985 <vector66>:
.globl vector66
vector66:
  pushl $0
80106985:	6a 00                	push   $0x0
  pushl $66
80106987:	6a 42                	push   $0x42
  jmp alltraps
80106989:	e9 37 f6 ff ff       	jmp    80105fc5 <alltraps>

8010698e <vector67>:
.globl vector67
vector67:
  pushl $0
8010698e:	6a 00                	push   $0x0
  pushl $67
80106990:	6a 43                	push   $0x43
  jmp alltraps
80106992:	e9 2e f6 ff ff       	jmp    80105fc5 <alltraps>

80106997 <vector68>:
.globl vector68
vector68:
  pushl $0
80106997:	6a 00                	push   $0x0
  pushl $68
80106999:	6a 44                	push   $0x44
  jmp alltraps
8010699b:	e9 25 f6 ff ff       	jmp    80105fc5 <alltraps>

801069a0 <vector69>:
.globl vector69
vector69:
  pushl $0
801069a0:	6a 00                	push   $0x0
  pushl $69
801069a2:	6a 45                	push   $0x45
  jmp alltraps
801069a4:	e9 1c f6 ff ff       	jmp    80105fc5 <alltraps>

801069a9 <vector70>:
.globl vector70
vector70:
  pushl $0
801069a9:	6a 00                	push   $0x0
  pushl $70
801069ab:	6a 46                	push   $0x46
  jmp alltraps
801069ad:	e9 13 f6 ff ff       	jmp    80105fc5 <alltraps>

801069b2 <vector71>:
.globl vector71
vector71:
  pushl $0
801069b2:	6a 00                	push   $0x0
  pushl $71
801069b4:	6a 47                	push   $0x47
  jmp alltraps
801069b6:	e9 0a f6 ff ff       	jmp    80105fc5 <alltraps>

801069bb <vector72>:
.globl vector72
vector72:
  pushl $0
801069bb:	6a 00                	push   $0x0
  pushl $72
801069bd:	6a 48                	push   $0x48
  jmp alltraps
801069bf:	e9 01 f6 ff ff       	jmp    80105fc5 <alltraps>

801069c4 <vector73>:
.globl vector73
vector73:
  pushl $0
801069c4:	6a 00                	push   $0x0
  pushl $73
801069c6:	6a 49                	push   $0x49
  jmp alltraps
801069c8:	e9 f8 f5 ff ff       	jmp    80105fc5 <alltraps>

801069cd <vector74>:
.globl vector74
vector74:
  pushl $0
801069cd:	6a 00                	push   $0x0
  pushl $74
801069cf:	6a 4a                	push   $0x4a
  jmp alltraps
801069d1:	e9 ef f5 ff ff       	jmp    80105fc5 <alltraps>

801069d6 <vector75>:
.globl vector75
vector75:
  pushl $0
801069d6:	6a 00                	push   $0x0
  pushl $75
801069d8:	6a 4b                	push   $0x4b
  jmp alltraps
801069da:	e9 e6 f5 ff ff       	jmp    80105fc5 <alltraps>

801069df <vector76>:
.globl vector76
vector76:
  pushl $0
801069df:	6a 00                	push   $0x0
  pushl $76
801069e1:	6a 4c                	push   $0x4c
  jmp alltraps
801069e3:	e9 dd f5 ff ff       	jmp    80105fc5 <alltraps>

801069e8 <vector77>:
.globl vector77
vector77:
  pushl $0
801069e8:	6a 00                	push   $0x0
  pushl $77
801069ea:	6a 4d                	push   $0x4d
  jmp alltraps
801069ec:	e9 d4 f5 ff ff       	jmp    80105fc5 <alltraps>

801069f1 <vector78>:
.globl vector78
vector78:
  pushl $0
801069f1:	6a 00                	push   $0x0
  pushl $78
801069f3:	6a 4e                	push   $0x4e
  jmp alltraps
801069f5:	e9 cb f5 ff ff       	jmp    80105fc5 <alltraps>

801069fa <vector79>:
.globl vector79
vector79:
  pushl $0
801069fa:	6a 00                	push   $0x0
  pushl $79
801069fc:	6a 4f                	push   $0x4f
  jmp alltraps
801069fe:	e9 c2 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a03 <vector80>:
.globl vector80
vector80:
  pushl $0
80106a03:	6a 00                	push   $0x0
  pushl $80
80106a05:	6a 50                	push   $0x50
  jmp alltraps
80106a07:	e9 b9 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a0c <vector81>:
.globl vector81
vector81:
  pushl $0
80106a0c:	6a 00                	push   $0x0
  pushl $81
80106a0e:	6a 51                	push   $0x51
  jmp alltraps
80106a10:	e9 b0 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a15 <vector82>:
.globl vector82
vector82:
  pushl $0
80106a15:	6a 00                	push   $0x0
  pushl $82
80106a17:	6a 52                	push   $0x52
  jmp alltraps
80106a19:	e9 a7 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a1e <vector83>:
.globl vector83
vector83:
  pushl $0
80106a1e:	6a 00                	push   $0x0
  pushl $83
80106a20:	6a 53                	push   $0x53
  jmp alltraps
80106a22:	e9 9e f5 ff ff       	jmp    80105fc5 <alltraps>

80106a27 <vector84>:
.globl vector84
vector84:
  pushl $0
80106a27:	6a 00                	push   $0x0
  pushl $84
80106a29:	6a 54                	push   $0x54
  jmp alltraps
80106a2b:	e9 95 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a30 <vector85>:
.globl vector85
vector85:
  pushl $0
80106a30:	6a 00                	push   $0x0
  pushl $85
80106a32:	6a 55                	push   $0x55
  jmp alltraps
80106a34:	e9 8c f5 ff ff       	jmp    80105fc5 <alltraps>

80106a39 <vector86>:
.globl vector86
vector86:
  pushl $0
80106a39:	6a 00                	push   $0x0
  pushl $86
80106a3b:	6a 56                	push   $0x56
  jmp alltraps
80106a3d:	e9 83 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a42 <vector87>:
.globl vector87
vector87:
  pushl $0
80106a42:	6a 00                	push   $0x0
  pushl $87
80106a44:	6a 57                	push   $0x57
  jmp alltraps
80106a46:	e9 7a f5 ff ff       	jmp    80105fc5 <alltraps>

80106a4b <vector88>:
.globl vector88
vector88:
  pushl $0
80106a4b:	6a 00                	push   $0x0
  pushl $88
80106a4d:	6a 58                	push   $0x58
  jmp alltraps
80106a4f:	e9 71 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a54 <vector89>:
.globl vector89
vector89:
  pushl $0
80106a54:	6a 00                	push   $0x0
  pushl $89
80106a56:	6a 59                	push   $0x59
  jmp alltraps
80106a58:	e9 68 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a5d <vector90>:
.globl vector90
vector90:
  pushl $0
80106a5d:	6a 00                	push   $0x0
  pushl $90
80106a5f:	6a 5a                	push   $0x5a
  jmp alltraps
80106a61:	e9 5f f5 ff ff       	jmp    80105fc5 <alltraps>

80106a66 <vector91>:
.globl vector91
vector91:
  pushl $0
80106a66:	6a 00                	push   $0x0
  pushl $91
80106a68:	6a 5b                	push   $0x5b
  jmp alltraps
80106a6a:	e9 56 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a6f <vector92>:
.globl vector92
vector92:
  pushl $0
80106a6f:	6a 00                	push   $0x0
  pushl $92
80106a71:	6a 5c                	push   $0x5c
  jmp alltraps
80106a73:	e9 4d f5 ff ff       	jmp    80105fc5 <alltraps>

80106a78 <vector93>:
.globl vector93
vector93:
  pushl $0
80106a78:	6a 00                	push   $0x0
  pushl $93
80106a7a:	6a 5d                	push   $0x5d
  jmp alltraps
80106a7c:	e9 44 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a81 <vector94>:
.globl vector94
vector94:
  pushl $0
80106a81:	6a 00                	push   $0x0
  pushl $94
80106a83:	6a 5e                	push   $0x5e
  jmp alltraps
80106a85:	e9 3b f5 ff ff       	jmp    80105fc5 <alltraps>

80106a8a <vector95>:
.globl vector95
vector95:
  pushl $0
80106a8a:	6a 00                	push   $0x0
  pushl $95
80106a8c:	6a 5f                	push   $0x5f
  jmp alltraps
80106a8e:	e9 32 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a93 <vector96>:
.globl vector96
vector96:
  pushl $0
80106a93:	6a 00                	push   $0x0
  pushl $96
80106a95:	6a 60                	push   $0x60
  jmp alltraps
80106a97:	e9 29 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a9c <vector97>:
.globl vector97
vector97:
  pushl $0
80106a9c:	6a 00                	push   $0x0
  pushl $97
80106a9e:	6a 61                	push   $0x61
  jmp alltraps
80106aa0:	e9 20 f5 ff ff       	jmp    80105fc5 <alltraps>

80106aa5 <vector98>:
.globl vector98
vector98:
  pushl $0
80106aa5:	6a 00                	push   $0x0
  pushl $98
80106aa7:	6a 62                	push   $0x62
  jmp alltraps
80106aa9:	e9 17 f5 ff ff       	jmp    80105fc5 <alltraps>

80106aae <vector99>:
.globl vector99
vector99:
  pushl $0
80106aae:	6a 00                	push   $0x0
  pushl $99
80106ab0:	6a 63                	push   $0x63
  jmp alltraps
80106ab2:	e9 0e f5 ff ff       	jmp    80105fc5 <alltraps>

80106ab7 <vector100>:
.globl vector100
vector100:
  pushl $0
80106ab7:	6a 00                	push   $0x0
  pushl $100
80106ab9:	6a 64                	push   $0x64
  jmp alltraps
80106abb:	e9 05 f5 ff ff       	jmp    80105fc5 <alltraps>

80106ac0 <vector101>:
.globl vector101
vector101:
  pushl $0
80106ac0:	6a 00                	push   $0x0
  pushl $101
80106ac2:	6a 65                	push   $0x65
  jmp alltraps
80106ac4:	e9 fc f4 ff ff       	jmp    80105fc5 <alltraps>

80106ac9 <vector102>:
.globl vector102
vector102:
  pushl $0
80106ac9:	6a 00                	push   $0x0
  pushl $102
80106acb:	6a 66                	push   $0x66
  jmp alltraps
80106acd:	e9 f3 f4 ff ff       	jmp    80105fc5 <alltraps>

80106ad2 <vector103>:
.globl vector103
vector103:
  pushl $0
80106ad2:	6a 00                	push   $0x0
  pushl $103
80106ad4:	6a 67                	push   $0x67
  jmp alltraps
80106ad6:	e9 ea f4 ff ff       	jmp    80105fc5 <alltraps>

80106adb <vector104>:
.globl vector104
vector104:
  pushl $0
80106adb:	6a 00                	push   $0x0
  pushl $104
80106add:	6a 68                	push   $0x68
  jmp alltraps
80106adf:	e9 e1 f4 ff ff       	jmp    80105fc5 <alltraps>

80106ae4 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ae4:	6a 00                	push   $0x0
  pushl $105
80106ae6:	6a 69                	push   $0x69
  jmp alltraps
80106ae8:	e9 d8 f4 ff ff       	jmp    80105fc5 <alltraps>

80106aed <vector106>:
.globl vector106
vector106:
  pushl $0
80106aed:	6a 00                	push   $0x0
  pushl $106
80106aef:	6a 6a                	push   $0x6a
  jmp alltraps
80106af1:	e9 cf f4 ff ff       	jmp    80105fc5 <alltraps>

80106af6 <vector107>:
.globl vector107
vector107:
  pushl $0
80106af6:	6a 00                	push   $0x0
  pushl $107
80106af8:	6a 6b                	push   $0x6b
  jmp alltraps
80106afa:	e9 c6 f4 ff ff       	jmp    80105fc5 <alltraps>

80106aff <vector108>:
.globl vector108
vector108:
  pushl $0
80106aff:	6a 00                	push   $0x0
  pushl $108
80106b01:	6a 6c                	push   $0x6c
  jmp alltraps
80106b03:	e9 bd f4 ff ff       	jmp    80105fc5 <alltraps>

80106b08 <vector109>:
.globl vector109
vector109:
  pushl $0
80106b08:	6a 00                	push   $0x0
  pushl $109
80106b0a:	6a 6d                	push   $0x6d
  jmp alltraps
80106b0c:	e9 b4 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b11 <vector110>:
.globl vector110
vector110:
  pushl $0
80106b11:	6a 00                	push   $0x0
  pushl $110
80106b13:	6a 6e                	push   $0x6e
  jmp alltraps
80106b15:	e9 ab f4 ff ff       	jmp    80105fc5 <alltraps>

80106b1a <vector111>:
.globl vector111
vector111:
  pushl $0
80106b1a:	6a 00                	push   $0x0
  pushl $111
80106b1c:	6a 6f                	push   $0x6f
  jmp alltraps
80106b1e:	e9 a2 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b23 <vector112>:
.globl vector112
vector112:
  pushl $0
80106b23:	6a 00                	push   $0x0
  pushl $112
80106b25:	6a 70                	push   $0x70
  jmp alltraps
80106b27:	e9 99 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b2c <vector113>:
.globl vector113
vector113:
  pushl $0
80106b2c:	6a 00                	push   $0x0
  pushl $113
80106b2e:	6a 71                	push   $0x71
  jmp alltraps
80106b30:	e9 90 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b35 <vector114>:
.globl vector114
vector114:
  pushl $0
80106b35:	6a 00                	push   $0x0
  pushl $114
80106b37:	6a 72                	push   $0x72
  jmp alltraps
80106b39:	e9 87 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b3e <vector115>:
.globl vector115
vector115:
  pushl $0
80106b3e:	6a 00                	push   $0x0
  pushl $115
80106b40:	6a 73                	push   $0x73
  jmp alltraps
80106b42:	e9 7e f4 ff ff       	jmp    80105fc5 <alltraps>

80106b47 <vector116>:
.globl vector116
vector116:
  pushl $0
80106b47:	6a 00                	push   $0x0
  pushl $116
80106b49:	6a 74                	push   $0x74
  jmp alltraps
80106b4b:	e9 75 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b50 <vector117>:
.globl vector117
vector117:
  pushl $0
80106b50:	6a 00                	push   $0x0
  pushl $117
80106b52:	6a 75                	push   $0x75
  jmp alltraps
80106b54:	e9 6c f4 ff ff       	jmp    80105fc5 <alltraps>

80106b59 <vector118>:
.globl vector118
vector118:
  pushl $0
80106b59:	6a 00                	push   $0x0
  pushl $118
80106b5b:	6a 76                	push   $0x76
  jmp alltraps
80106b5d:	e9 63 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b62 <vector119>:
.globl vector119
vector119:
  pushl $0
80106b62:	6a 00                	push   $0x0
  pushl $119
80106b64:	6a 77                	push   $0x77
  jmp alltraps
80106b66:	e9 5a f4 ff ff       	jmp    80105fc5 <alltraps>

80106b6b <vector120>:
.globl vector120
vector120:
  pushl $0
80106b6b:	6a 00                	push   $0x0
  pushl $120
80106b6d:	6a 78                	push   $0x78
  jmp alltraps
80106b6f:	e9 51 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b74 <vector121>:
.globl vector121
vector121:
  pushl $0
80106b74:	6a 00                	push   $0x0
  pushl $121
80106b76:	6a 79                	push   $0x79
  jmp alltraps
80106b78:	e9 48 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b7d <vector122>:
.globl vector122
vector122:
  pushl $0
80106b7d:	6a 00                	push   $0x0
  pushl $122
80106b7f:	6a 7a                	push   $0x7a
  jmp alltraps
80106b81:	e9 3f f4 ff ff       	jmp    80105fc5 <alltraps>

80106b86 <vector123>:
.globl vector123
vector123:
  pushl $0
80106b86:	6a 00                	push   $0x0
  pushl $123
80106b88:	6a 7b                	push   $0x7b
  jmp alltraps
80106b8a:	e9 36 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b8f <vector124>:
.globl vector124
vector124:
  pushl $0
80106b8f:	6a 00                	push   $0x0
  pushl $124
80106b91:	6a 7c                	push   $0x7c
  jmp alltraps
80106b93:	e9 2d f4 ff ff       	jmp    80105fc5 <alltraps>

80106b98 <vector125>:
.globl vector125
vector125:
  pushl $0
80106b98:	6a 00                	push   $0x0
  pushl $125
80106b9a:	6a 7d                	push   $0x7d
  jmp alltraps
80106b9c:	e9 24 f4 ff ff       	jmp    80105fc5 <alltraps>

80106ba1 <vector126>:
.globl vector126
vector126:
  pushl $0
80106ba1:	6a 00                	push   $0x0
  pushl $126
80106ba3:	6a 7e                	push   $0x7e
  jmp alltraps
80106ba5:	e9 1b f4 ff ff       	jmp    80105fc5 <alltraps>

80106baa <vector127>:
.globl vector127
vector127:
  pushl $0
80106baa:	6a 00                	push   $0x0
  pushl $127
80106bac:	6a 7f                	push   $0x7f
  jmp alltraps
80106bae:	e9 12 f4 ff ff       	jmp    80105fc5 <alltraps>

80106bb3 <vector128>:
.globl vector128
vector128:
  pushl $0
80106bb3:	6a 00                	push   $0x0
  pushl $128
80106bb5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106bba:	e9 06 f4 ff ff       	jmp    80105fc5 <alltraps>

80106bbf <vector129>:
.globl vector129
vector129:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $129
80106bc1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106bc6:	e9 fa f3 ff ff       	jmp    80105fc5 <alltraps>

80106bcb <vector130>:
.globl vector130
vector130:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $130
80106bcd:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106bd2:	e9 ee f3 ff ff       	jmp    80105fc5 <alltraps>

80106bd7 <vector131>:
.globl vector131
vector131:
  pushl $0
80106bd7:	6a 00                	push   $0x0
  pushl $131
80106bd9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106bde:	e9 e2 f3 ff ff       	jmp    80105fc5 <alltraps>

80106be3 <vector132>:
.globl vector132
vector132:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $132
80106be5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106bea:	e9 d6 f3 ff ff       	jmp    80105fc5 <alltraps>

80106bef <vector133>:
.globl vector133
vector133:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $133
80106bf1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106bf6:	e9 ca f3 ff ff       	jmp    80105fc5 <alltraps>

80106bfb <vector134>:
.globl vector134
vector134:
  pushl $0
80106bfb:	6a 00                	push   $0x0
  pushl $134
80106bfd:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106c02:	e9 be f3 ff ff       	jmp    80105fc5 <alltraps>

80106c07 <vector135>:
.globl vector135
vector135:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $135
80106c09:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106c0e:	e9 b2 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c13 <vector136>:
.globl vector136
vector136:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $136
80106c15:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106c1a:	e9 a6 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c1f <vector137>:
.globl vector137
vector137:
  pushl $0
80106c1f:	6a 00                	push   $0x0
  pushl $137
80106c21:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106c26:	e9 9a f3 ff ff       	jmp    80105fc5 <alltraps>

80106c2b <vector138>:
.globl vector138
vector138:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $138
80106c2d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106c32:	e9 8e f3 ff ff       	jmp    80105fc5 <alltraps>

80106c37 <vector139>:
.globl vector139
vector139:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $139
80106c39:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106c3e:	e9 82 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c43 <vector140>:
.globl vector140
vector140:
  pushl $0
80106c43:	6a 00                	push   $0x0
  pushl $140
80106c45:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106c4a:	e9 76 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c4f <vector141>:
.globl vector141
vector141:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $141
80106c51:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106c56:	e9 6a f3 ff ff       	jmp    80105fc5 <alltraps>

80106c5b <vector142>:
.globl vector142
vector142:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $142
80106c5d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106c62:	e9 5e f3 ff ff       	jmp    80105fc5 <alltraps>

80106c67 <vector143>:
.globl vector143
vector143:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $143
80106c69:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106c6e:	e9 52 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c73 <vector144>:
.globl vector144
vector144:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $144
80106c75:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106c7a:	e9 46 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c7f <vector145>:
.globl vector145
vector145:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $145
80106c81:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106c86:	e9 3a f3 ff ff       	jmp    80105fc5 <alltraps>

80106c8b <vector146>:
.globl vector146
vector146:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $146
80106c8d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106c92:	e9 2e f3 ff ff       	jmp    80105fc5 <alltraps>

80106c97 <vector147>:
.globl vector147
vector147:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $147
80106c99:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106c9e:	e9 22 f3 ff ff       	jmp    80105fc5 <alltraps>

80106ca3 <vector148>:
.globl vector148
vector148:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $148
80106ca5:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106caa:	e9 16 f3 ff ff       	jmp    80105fc5 <alltraps>

80106caf <vector149>:
.globl vector149
vector149:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $149
80106cb1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106cb6:	e9 0a f3 ff ff       	jmp    80105fc5 <alltraps>

80106cbb <vector150>:
.globl vector150
vector150:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $150
80106cbd:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106cc2:	e9 fe f2 ff ff       	jmp    80105fc5 <alltraps>

80106cc7 <vector151>:
.globl vector151
vector151:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $151
80106cc9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106cce:	e9 f2 f2 ff ff       	jmp    80105fc5 <alltraps>

80106cd3 <vector152>:
.globl vector152
vector152:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $152
80106cd5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106cda:	e9 e6 f2 ff ff       	jmp    80105fc5 <alltraps>

80106cdf <vector153>:
.globl vector153
vector153:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $153
80106ce1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106ce6:	e9 da f2 ff ff       	jmp    80105fc5 <alltraps>

80106ceb <vector154>:
.globl vector154
vector154:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $154
80106ced:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106cf2:	e9 ce f2 ff ff       	jmp    80105fc5 <alltraps>

80106cf7 <vector155>:
.globl vector155
vector155:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $155
80106cf9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106cfe:	e9 c2 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d03 <vector156>:
.globl vector156
vector156:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $156
80106d05:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106d0a:	e9 b6 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d0f <vector157>:
.globl vector157
vector157:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $157
80106d11:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106d16:	e9 aa f2 ff ff       	jmp    80105fc5 <alltraps>

80106d1b <vector158>:
.globl vector158
vector158:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $158
80106d1d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106d22:	e9 9e f2 ff ff       	jmp    80105fc5 <alltraps>

80106d27 <vector159>:
.globl vector159
vector159:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $159
80106d29:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106d2e:	e9 92 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d33 <vector160>:
.globl vector160
vector160:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $160
80106d35:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106d3a:	e9 86 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d3f <vector161>:
.globl vector161
vector161:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $161
80106d41:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106d46:	e9 7a f2 ff ff       	jmp    80105fc5 <alltraps>

80106d4b <vector162>:
.globl vector162
vector162:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $162
80106d4d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106d52:	e9 6e f2 ff ff       	jmp    80105fc5 <alltraps>

80106d57 <vector163>:
.globl vector163
vector163:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $163
80106d59:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106d5e:	e9 62 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d63 <vector164>:
.globl vector164
vector164:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $164
80106d65:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106d6a:	e9 56 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d6f <vector165>:
.globl vector165
vector165:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $165
80106d71:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106d76:	e9 4a f2 ff ff       	jmp    80105fc5 <alltraps>

80106d7b <vector166>:
.globl vector166
vector166:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $166
80106d7d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106d82:	e9 3e f2 ff ff       	jmp    80105fc5 <alltraps>

80106d87 <vector167>:
.globl vector167
vector167:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $167
80106d89:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106d8e:	e9 32 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d93 <vector168>:
.globl vector168
vector168:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $168
80106d95:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106d9a:	e9 26 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d9f <vector169>:
.globl vector169
vector169:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $169
80106da1:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106da6:	e9 1a f2 ff ff       	jmp    80105fc5 <alltraps>

80106dab <vector170>:
.globl vector170
vector170:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $170
80106dad:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106db2:	e9 0e f2 ff ff       	jmp    80105fc5 <alltraps>

80106db7 <vector171>:
.globl vector171
vector171:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $171
80106db9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106dbe:	e9 02 f2 ff ff       	jmp    80105fc5 <alltraps>

80106dc3 <vector172>:
.globl vector172
vector172:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $172
80106dc5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106dca:	e9 f6 f1 ff ff       	jmp    80105fc5 <alltraps>

80106dcf <vector173>:
.globl vector173
vector173:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $173
80106dd1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106dd6:	e9 ea f1 ff ff       	jmp    80105fc5 <alltraps>

80106ddb <vector174>:
.globl vector174
vector174:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $174
80106ddd:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106de2:	e9 de f1 ff ff       	jmp    80105fc5 <alltraps>

80106de7 <vector175>:
.globl vector175
vector175:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $175
80106de9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106dee:	e9 d2 f1 ff ff       	jmp    80105fc5 <alltraps>

80106df3 <vector176>:
.globl vector176
vector176:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $176
80106df5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106dfa:	e9 c6 f1 ff ff       	jmp    80105fc5 <alltraps>

80106dff <vector177>:
.globl vector177
vector177:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $177
80106e01:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106e06:	e9 ba f1 ff ff       	jmp    80105fc5 <alltraps>

80106e0b <vector178>:
.globl vector178
vector178:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $178
80106e0d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106e12:	e9 ae f1 ff ff       	jmp    80105fc5 <alltraps>

80106e17 <vector179>:
.globl vector179
vector179:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $179
80106e19:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106e1e:	e9 a2 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e23 <vector180>:
.globl vector180
vector180:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $180
80106e25:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106e2a:	e9 96 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e2f <vector181>:
.globl vector181
vector181:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $181
80106e31:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106e36:	e9 8a f1 ff ff       	jmp    80105fc5 <alltraps>

80106e3b <vector182>:
.globl vector182
vector182:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $182
80106e3d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106e42:	e9 7e f1 ff ff       	jmp    80105fc5 <alltraps>

80106e47 <vector183>:
.globl vector183
vector183:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $183
80106e49:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106e4e:	e9 72 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e53 <vector184>:
.globl vector184
vector184:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $184
80106e55:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106e5a:	e9 66 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e5f <vector185>:
.globl vector185
vector185:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $185
80106e61:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106e66:	e9 5a f1 ff ff       	jmp    80105fc5 <alltraps>

80106e6b <vector186>:
.globl vector186
vector186:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $186
80106e6d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106e72:	e9 4e f1 ff ff       	jmp    80105fc5 <alltraps>

80106e77 <vector187>:
.globl vector187
vector187:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $187
80106e79:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106e7e:	e9 42 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e83 <vector188>:
.globl vector188
vector188:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $188
80106e85:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106e8a:	e9 36 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e8f <vector189>:
.globl vector189
vector189:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $189
80106e91:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106e96:	e9 2a f1 ff ff       	jmp    80105fc5 <alltraps>

80106e9b <vector190>:
.globl vector190
vector190:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $190
80106e9d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ea2:	e9 1e f1 ff ff       	jmp    80105fc5 <alltraps>

80106ea7 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $191
80106ea9:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106eae:	e9 12 f1 ff ff       	jmp    80105fc5 <alltraps>

80106eb3 <vector192>:
.globl vector192
vector192:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $192
80106eb5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106eba:	e9 06 f1 ff ff       	jmp    80105fc5 <alltraps>

80106ebf <vector193>:
.globl vector193
vector193:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $193
80106ec1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106ec6:	e9 fa f0 ff ff       	jmp    80105fc5 <alltraps>

80106ecb <vector194>:
.globl vector194
vector194:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $194
80106ecd:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106ed2:	e9 ee f0 ff ff       	jmp    80105fc5 <alltraps>

80106ed7 <vector195>:
.globl vector195
vector195:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $195
80106ed9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106ede:	e9 e2 f0 ff ff       	jmp    80105fc5 <alltraps>

80106ee3 <vector196>:
.globl vector196
vector196:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $196
80106ee5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106eea:	e9 d6 f0 ff ff       	jmp    80105fc5 <alltraps>

80106eef <vector197>:
.globl vector197
vector197:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $197
80106ef1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106ef6:	e9 ca f0 ff ff       	jmp    80105fc5 <alltraps>

80106efb <vector198>:
.globl vector198
vector198:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $198
80106efd:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106f02:	e9 be f0 ff ff       	jmp    80105fc5 <alltraps>

80106f07 <vector199>:
.globl vector199
vector199:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $199
80106f09:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106f0e:	e9 b2 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f13 <vector200>:
.globl vector200
vector200:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $200
80106f15:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106f1a:	e9 a6 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f1f <vector201>:
.globl vector201
vector201:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $201
80106f21:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106f26:	e9 9a f0 ff ff       	jmp    80105fc5 <alltraps>

80106f2b <vector202>:
.globl vector202
vector202:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $202
80106f2d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106f32:	e9 8e f0 ff ff       	jmp    80105fc5 <alltraps>

80106f37 <vector203>:
.globl vector203
vector203:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $203
80106f39:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106f3e:	e9 82 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f43 <vector204>:
.globl vector204
vector204:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $204
80106f45:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106f4a:	e9 76 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f4f <vector205>:
.globl vector205
vector205:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $205
80106f51:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106f56:	e9 6a f0 ff ff       	jmp    80105fc5 <alltraps>

80106f5b <vector206>:
.globl vector206
vector206:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $206
80106f5d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106f62:	e9 5e f0 ff ff       	jmp    80105fc5 <alltraps>

80106f67 <vector207>:
.globl vector207
vector207:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $207
80106f69:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106f6e:	e9 52 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f73 <vector208>:
.globl vector208
vector208:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $208
80106f75:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106f7a:	e9 46 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f7f <vector209>:
.globl vector209
vector209:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $209
80106f81:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106f86:	e9 3a f0 ff ff       	jmp    80105fc5 <alltraps>

80106f8b <vector210>:
.globl vector210
vector210:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $210
80106f8d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106f92:	e9 2e f0 ff ff       	jmp    80105fc5 <alltraps>

80106f97 <vector211>:
.globl vector211
vector211:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $211
80106f99:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106f9e:	e9 22 f0 ff ff       	jmp    80105fc5 <alltraps>

80106fa3 <vector212>:
.globl vector212
vector212:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $212
80106fa5:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106faa:	e9 16 f0 ff ff       	jmp    80105fc5 <alltraps>

80106faf <vector213>:
.globl vector213
vector213:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $213
80106fb1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106fb6:	e9 0a f0 ff ff       	jmp    80105fc5 <alltraps>

80106fbb <vector214>:
.globl vector214
vector214:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $214
80106fbd:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106fc2:	e9 fe ef ff ff       	jmp    80105fc5 <alltraps>

80106fc7 <vector215>:
.globl vector215
vector215:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $215
80106fc9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106fce:	e9 f2 ef ff ff       	jmp    80105fc5 <alltraps>

80106fd3 <vector216>:
.globl vector216
vector216:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $216
80106fd5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106fda:	e9 e6 ef ff ff       	jmp    80105fc5 <alltraps>

80106fdf <vector217>:
.globl vector217
vector217:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $217
80106fe1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106fe6:	e9 da ef ff ff       	jmp    80105fc5 <alltraps>

80106feb <vector218>:
.globl vector218
vector218:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $218
80106fed:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106ff2:	e9 ce ef ff ff       	jmp    80105fc5 <alltraps>

80106ff7 <vector219>:
.globl vector219
vector219:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $219
80106ff9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106ffe:	e9 c2 ef ff ff       	jmp    80105fc5 <alltraps>

80107003 <vector220>:
.globl vector220
vector220:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $220
80107005:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010700a:	e9 b6 ef ff ff       	jmp    80105fc5 <alltraps>

8010700f <vector221>:
.globl vector221
vector221:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $221
80107011:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107016:	e9 aa ef ff ff       	jmp    80105fc5 <alltraps>

8010701b <vector222>:
.globl vector222
vector222:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $222
8010701d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107022:	e9 9e ef ff ff       	jmp    80105fc5 <alltraps>

80107027 <vector223>:
.globl vector223
vector223:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $223
80107029:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010702e:	e9 92 ef ff ff       	jmp    80105fc5 <alltraps>

80107033 <vector224>:
.globl vector224
vector224:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $224
80107035:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010703a:	e9 86 ef ff ff       	jmp    80105fc5 <alltraps>

8010703f <vector225>:
.globl vector225
vector225:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $225
80107041:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107046:	e9 7a ef ff ff       	jmp    80105fc5 <alltraps>

8010704b <vector226>:
.globl vector226
vector226:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $226
8010704d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107052:	e9 6e ef ff ff       	jmp    80105fc5 <alltraps>

80107057 <vector227>:
.globl vector227
vector227:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $227
80107059:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010705e:	e9 62 ef ff ff       	jmp    80105fc5 <alltraps>

80107063 <vector228>:
.globl vector228
vector228:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $228
80107065:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010706a:	e9 56 ef ff ff       	jmp    80105fc5 <alltraps>

8010706f <vector229>:
.globl vector229
vector229:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $229
80107071:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107076:	e9 4a ef ff ff       	jmp    80105fc5 <alltraps>

8010707b <vector230>:
.globl vector230
vector230:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $230
8010707d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107082:	e9 3e ef ff ff       	jmp    80105fc5 <alltraps>

80107087 <vector231>:
.globl vector231
vector231:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $231
80107089:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010708e:	e9 32 ef ff ff       	jmp    80105fc5 <alltraps>

80107093 <vector232>:
.globl vector232
vector232:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $232
80107095:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010709a:	e9 26 ef ff ff       	jmp    80105fc5 <alltraps>

8010709f <vector233>:
.globl vector233
vector233:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $233
801070a1:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801070a6:	e9 1a ef ff ff       	jmp    80105fc5 <alltraps>

801070ab <vector234>:
.globl vector234
vector234:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $234
801070ad:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801070b2:	e9 0e ef ff ff       	jmp    80105fc5 <alltraps>

801070b7 <vector235>:
.globl vector235
vector235:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $235
801070b9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801070be:	e9 02 ef ff ff       	jmp    80105fc5 <alltraps>

801070c3 <vector236>:
.globl vector236
vector236:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $236
801070c5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801070ca:	e9 f6 ee ff ff       	jmp    80105fc5 <alltraps>

801070cf <vector237>:
.globl vector237
vector237:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $237
801070d1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801070d6:	e9 ea ee ff ff       	jmp    80105fc5 <alltraps>

801070db <vector238>:
.globl vector238
vector238:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $238
801070dd:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801070e2:	e9 de ee ff ff       	jmp    80105fc5 <alltraps>

801070e7 <vector239>:
.globl vector239
vector239:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $239
801070e9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801070ee:	e9 d2 ee ff ff       	jmp    80105fc5 <alltraps>

801070f3 <vector240>:
.globl vector240
vector240:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $240
801070f5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801070fa:	e9 c6 ee ff ff       	jmp    80105fc5 <alltraps>

801070ff <vector241>:
.globl vector241
vector241:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $241
80107101:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107106:	e9 ba ee ff ff       	jmp    80105fc5 <alltraps>

8010710b <vector242>:
.globl vector242
vector242:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $242
8010710d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107112:	e9 ae ee ff ff       	jmp    80105fc5 <alltraps>

80107117 <vector243>:
.globl vector243
vector243:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $243
80107119:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010711e:	e9 a2 ee ff ff       	jmp    80105fc5 <alltraps>

80107123 <vector244>:
.globl vector244
vector244:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $244
80107125:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010712a:	e9 96 ee ff ff       	jmp    80105fc5 <alltraps>

8010712f <vector245>:
.globl vector245
vector245:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $245
80107131:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107136:	e9 8a ee ff ff       	jmp    80105fc5 <alltraps>

8010713b <vector246>:
.globl vector246
vector246:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $246
8010713d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107142:	e9 7e ee ff ff       	jmp    80105fc5 <alltraps>

80107147 <vector247>:
.globl vector247
vector247:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $247
80107149:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010714e:	e9 72 ee ff ff       	jmp    80105fc5 <alltraps>

80107153 <vector248>:
.globl vector248
vector248:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $248
80107155:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010715a:	e9 66 ee ff ff       	jmp    80105fc5 <alltraps>

8010715f <vector249>:
.globl vector249
vector249:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $249
80107161:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107166:	e9 5a ee ff ff       	jmp    80105fc5 <alltraps>

8010716b <vector250>:
.globl vector250
vector250:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $250
8010716d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107172:	e9 4e ee ff ff       	jmp    80105fc5 <alltraps>

80107177 <vector251>:
.globl vector251
vector251:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $251
80107179:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010717e:	e9 42 ee ff ff       	jmp    80105fc5 <alltraps>

80107183 <vector252>:
.globl vector252
vector252:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $252
80107185:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010718a:	e9 36 ee ff ff       	jmp    80105fc5 <alltraps>

8010718f <vector253>:
.globl vector253
vector253:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $253
80107191:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107196:	e9 2a ee ff ff       	jmp    80105fc5 <alltraps>

8010719b <vector254>:
.globl vector254
vector254:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $254
8010719d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801071a2:	e9 1e ee ff ff       	jmp    80105fc5 <alltraps>

801071a7 <vector255>:
.globl vector255
vector255:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $255
801071a9:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801071ae:	e9 12 ee ff ff       	jmp    80105fc5 <alltraps>

801071b3 <lgdt>:
{
801071b3:	55                   	push   %ebp
801071b4:	89 e5                	mov    %esp,%ebp
801071b6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801071b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801071bc:	83 e8 01             	sub    $0x1,%eax
801071bf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071c3:	8b 45 08             	mov    0x8(%ebp),%eax
801071c6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071ca:	8b 45 08             	mov    0x8(%ebp),%eax
801071cd:	c1 e8 10             	shr    $0x10,%eax
801071d0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801071d4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071d7:	0f 01 10             	lgdtl  (%eax)
}
801071da:	90                   	nop
801071db:	c9                   	leave  
801071dc:	c3                   	ret    

801071dd <ltr>:
{
801071dd:	55                   	push   %ebp
801071de:	89 e5                	mov    %esp,%ebp
801071e0:	83 ec 04             	sub    $0x4,%esp
801071e3:	8b 45 08             	mov    0x8(%ebp),%eax
801071e6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801071ea:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801071ee:	0f 00 d8             	ltr    %ax
}
801071f1:	90                   	nop
801071f2:	c9                   	leave  
801071f3:	c3                   	ret    

801071f4 <lcr3>:

static inline void
lcr3(uint val)
{
801071f4:	55                   	push   %ebp
801071f5:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801071f7:	8b 45 08             	mov    0x8(%ebp),%eax
801071fa:	0f 22 d8             	mov    %eax,%cr3
}
801071fd:	90                   	nop
801071fe:	5d                   	pop    %ebp
801071ff:	c3                   	ret    

80107200 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107200:	f3 0f 1e fb          	endbr32 
80107204:	55                   	push   %ebp
80107205:	89 e5                	mov    %esp,%ebp
80107207:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010720a:	e8 ff c8 ff ff       	call   80103b0e <cpuid>
8010720f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107215:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
8010721a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010721d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107220:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107229:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010722f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107232:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107239:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010723d:	83 e2 f0             	and    $0xfffffff0,%edx
80107240:	83 ca 0a             	or     $0xa,%edx
80107243:	88 50 7d             	mov    %dl,0x7d(%eax)
80107246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107249:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010724d:	83 ca 10             	or     $0x10,%edx
80107250:	88 50 7d             	mov    %dl,0x7d(%eax)
80107253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107256:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010725a:	83 e2 9f             	and    $0xffffff9f,%edx
8010725d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107263:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107267:	83 ca 80             	or     $0xffffff80,%edx
8010726a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010726d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107270:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107274:	83 ca 0f             	or     $0xf,%edx
80107277:	88 50 7e             	mov    %dl,0x7e(%eax)
8010727a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107281:	83 e2 ef             	and    $0xffffffef,%edx
80107284:	88 50 7e             	mov    %dl,0x7e(%eax)
80107287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010728e:	83 e2 df             	and    $0xffffffdf,%edx
80107291:	88 50 7e             	mov    %dl,0x7e(%eax)
80107294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107297:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010729b:	83 ca 40             	or     $0x40,%edx
8010729e:	88 50 7e             	mov    %dl,0x7e(%eax)
801072a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072a8:	83 ca 80             	or     $0xffffff80,%edx
801072ab:	88 50 7e             	mov    %dl,0x7e(%eax)
801072ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b1:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801072b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b8:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801072bf:	ff ff 
801072c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c4:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801072cb:	00 00 
801072cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d0:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801072d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072da:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072e1:	83 e2 f0             	and    $0xfffffff0,%edx
801072e4:	83 ca 02             	or     $0x2,%edx
801072e7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072f7:	83 ca 10             	or     $0x10,%edx
801072fa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107303:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010730a:	83 e2 9f             	and    $0xffffff9f,%edx
8010730d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107316:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010731d:	83 ca 80             	or     $0xffffff80,%edx
80107320:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107329:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107330:	83 ca 0f             	or     $0xf,%edx
80107333:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107343:	83 e2 ef             	and    $0xffffffef,%edx
80107346:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010734c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107356:	83 e2 df             	and    $0xffffffdf,%edx
80107359:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010735f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107362:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107369:	83 ca 40             	or     $0x40,%edx
8010736c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107375:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010737c:	83 ca 80             	or     $0xffffff80,%edx
8010737f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107388:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010738f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107392:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107399:	ff ff 
8010739b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739e:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801073a5:	00 00 
801073a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073aa:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801073b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073bb:	83 e2 f0             	and    $0xfffffff0,%edx
801073be:	83 ca 0a             	or     $0xa,%edx
801073c1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ca:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073d1:	83 ca 10             	or     $0x10,%edx
801073d4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073dd:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073e4:	83 ca 60             	or     $0x60,%edx
801073e7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073f7:	83 ca 80             	or     $0xffffff80,%edx
801073fa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107403:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010740a:	83 ca 0f             	or     $0xf,%edx
8010740d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107416:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010741d:	83 e2 ef             	and    $0xffffffef,%edx
80107420:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107429:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107430:	83 e2 df             	and    $0xffffffdf,%edx
80107433:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107443:	83 ca 40             	or     $0x40,%edx
80107446:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010744c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107456:	83 ca 80             	or     $0xffffff80,%edx
80107459:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010745f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107462:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107473:	ff ff 
80107475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107478:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010747f:	00 00 
80107481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107484:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010748b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107495:	83 e2 f0             	and    $0xfffffff0,%edx
80107498:	83 ca 02             	or     $0x2,%edx
8010749b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074ab:	83 ca 10             	or     $0x10,%edx
801074ae:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074be:	83 ca 60             	or     $0x60,%edx
801074c1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ca:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074d1:	83 ca 80             	or     $0xffffff80,%edx
801074d4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074e4:	83 ca 0f             	or     $0xf,%edx
801074e7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074f7:	83 e2 ef             	and    $0xffffffef,%edx
801074fa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107503:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010750a:	83 e2 df             	and    $0xffffffdf,%edx
8010750d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107516:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010751d:	83 ca 40             	or     $0x40,%edx
80107520:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107529:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107530:	83 ca 80             	or     $0xffffff80,%edx
80107533:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107546:	83 c0 70             	add    $0x70,%eax
80107549:	83 ec 08             	sub    $0x8,%esp
8010754c:	6a 30                	push   $0x30
8010754e:	50                   	push   %eax
8010754f:	e8 5f fc ff ff       	call   801071b3 <lgdt>
80107554:	83 c4 10             	add    $0x10,%esp
}
80107557:	90                   	nop
80107558:	c9                   	leave  
80107559:	c3                   	ret    

8010755a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010755a:	f3 0f 1e fb          	endbr32 
8010755e:	55                   	push   %ebp
8010755f:	89 e5                	mov    %esp,%ebp
80107561:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107564:	8b 45 0c             	mov    0xc(%ebp),%eax
80107567:	c1 e8 16             	shr    $0x16,%eax
8010756a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107571:	8b 45 08             	mov    0x8(%ebp),%eax
80107574:	01 d0                	add    %edx,%eax
80107576:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010757c:	8b 00                	mov    (%eax),%eax
8010757e:	83 e0 01             	and    $0x1,%eax
80107581:	85 c0                	test   %eax,%eax
80107583:	74 14                	je     80107599 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107588:	8b 00                	mov    (%eax),%eax
8010758a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010758f:	05 00 00 00 80       	add    $0x80000000,%eax
80107594:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107597:	eb 42                	jmp    801075db <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107599:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010759d:	74 0e                	je     801075ad <walkpgdir+0x53>
8010759f:	e8 ee b2 ff ff       	call   80102892 <kalloc>
801075a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801075ab:	75 07                	jne    801075b4 <walkpgdir+0x5a>
      return 0;
801075ad:	b8 00 00 00 00       	mov    $0x0,%eax
801075b2:	eb 3e                	jmp    801075f2 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801075b4:	83 ec 04             	sub    $0x4,%esp
801075b7:	68 00 10 00 00       	push   $0x1000
801075bc:	6a 00                	push   $0x0
801075be:	ff 75 f4             	pushl  -0xc(%ebp)
801075c1:	e8 98 d5 ff ff       	call   80104b5e <memset>
801075c6:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cc:	05 00 00 00 80       	add    $0x80000000,%eax
801075d1:	83 c8 07             	or     $0x7,%eax
801075d4:	89 c2                	mov    %eax,%edx
801075d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075d9:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801075db:	8b 45 0c             	mov    0xc(%ebp),%eax
801075de:	c1 e8 0c             	shr    $0xc,%eax
801075e1:	25 ff 03 00 00       	and    $0x3ff,%eax
801075e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801075ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f0:	01 d0                	add    %edx,%eax
}
801075f2:	c9                   	leave  
801075f3:	c3                   	ret    

801075f4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801075f4:	f3 0f 1e fb          	endbr32 
801075f8:	55                   	push   %ebp
801075f9:	89 e5                	mov    %esp,%ebp
801075fb:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801075fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107601:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107606:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107609:	8b 55 0c             	mov    0xc(%ebp),%edx
8010760c:	8b 45 10             	mov    0x10(%ebp),%eax
8010760f:	01 d0                	add    %edx,%eax
80107611:	83 e8 01             	sub    $0x1,%eax
80107614:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107619:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010761c:	83 ec 04             	sub    $0x4,%esp
8010761f:	6a 01                	push   $0x1
80107621:	ff 75 f4             	pushl  -0xc(%ebp)
80107624:	ff 75 08             	pushl  0x8(%ebp)
80107627:	e8 2e ff ff ff       	call   8010755a <walkpgdir>
8010762c:	83 c4 10             	add    $0x10,%esp
8010762f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107632:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107636:	75 07                	jne    8010763f <mappages+0x4b>
      return -1;
80107638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010763d:	eb 47                	jmp    80107686 <mappages+0x92>
    if(*pte & PTE_P)
8010763f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107642:	8b 00                	mov    (%eax),%eax
80107644:	83 e0 01             	and    $0x1,%eax
80107647:	85 c0                	test   %eax,%eax
80107649:	74 0d                	je     80107658 <mappages+0x64>
      panic("remap");
8010764b:	83 ec 0c             	sub    $0xc,%esp
8010764e:	68 ec aa 10 80       	push   $0x8010aaec
80107653:	e8 6d 8f ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107658:	8b 45 18             	mov    0x18(%ebp),%eax
8010765b:	0b 45 14             	or     0x14(%ebp),%eax
8010765e:	83 c8 01             	or     $0x1,%eax
80107661:	89 c2                	mov    %eax,%edx
80107663:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107666:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010766e:	74 10                	je     80107680 <mappages+0x8c>
      break;
    a += PGSIZE;
80107670:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107677:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010767e:	eb 9c                	jmp    8010761c <mappages+0x28>
      break;
80107680:	90                   	nop
  }
  return 0;
80107681:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107686:	c9                   	leave  
80107687:	c3                   	ret    

80107688 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107688:	f3 0f 1e fb          	endbr32 
8010768c:	55                   	push   %ebp
8010768d:	89 e5                	mov    %esp,%ebp
8010768f:	53                   	push   %ebx
80107690:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107693:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010769a:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010769f:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801076a4:	29 c2                	sub    %eax,%edx
801076a6:	89 d0                	mov    %edx,%eax
801076a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801076ab:	a1 84 80 19 80       	mov    0x80198084,%eax
801076b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801076b3:	8b 15 84 80 19 80    	mov    0x80198084,%edx
801076b9:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801076be:	01 d0                	add    %edx,%eax
801076c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801076c3:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801076ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cd:	83 c0 30             	add    $0x30,%eax
801076d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801076d3:	89 10                	mov    %edx,(%eax)
801076d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801076d8:	89 50 04             	mov    %edx,0x4(%eax)
801076db:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076de:	89 50 08             	mov    %edx,0x8(%eax)
801076e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801076e4:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801076e7:	e8 a6 b1 ff ff       	call   80102892 <kalloc>
801076ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076f3:	75 07                	jne    801076fc <setupkvm+0x74>
    return 0;
801076f5:	b8 00 00 00 00       	mov    $0x0,%eax
801076fa:	eb 78                	jmp    80107774 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801076fc:	83 ec 04             	sub    $0x4,%esp
801076ff:	68 00 10 00 00       	push   $0x1000
80107704:	6a 00                	push   $0x0
80107706:	ff 75 f0             	pushl  -0x10(%ebp)
80107709:	e8 50 d4 ff ff       	call   80104b5e <memset>
8010770e:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107711:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107718:	eb 4e                	jmp    80107768 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010771a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771d:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107723:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107729:	8b 58 08             	mov    0x8(%eax),%ebx
8010772c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772f:	8b 40 04             	mov    0x4(%eax),%eax
80107732:	29 c3                	sub    %eax,%ebx
80107734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107737:	8b 00                	mov    (%eax),%eax
80107739:	83 ec 0c             	sub    $0xc,%esp
8010773c:	51                   	push   %ecx
8010773d:	52                   	push   %edx
8010773e:	53                   	push   %ebx
8010773f:	50                   	push   %eax
80107740:	ff 75 f0             	pushl  -0x10(%ebp)
80107743:	e8 ac fe ff ff       	call   801075f4 <mappages>
80107748:	83 c4 20             	add    $0x20,%esp
8010774b:	85 c0                	test   %eax,%eax
8010774d:	79 15                	jns    80107764 <setupkvm+0xdc>
      freevm(pgdir);
8010774f:	83 ec 0c             	sub    $0xc,%esp
80107752:	ff 75 f0             	pushl  -0x10(%ebp)
80107755:	e8 11 05 00 00       	call   80107c6b <freevm>
8010775a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010775d:	b8 00 00 00 00       	mov    $0x0,%eax
80107762:	eb 10                	jmp    80107774 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107764:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107768:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010776f:	72 a9                	jb     8010771a <setupkvm+0x92>
    }
  return pgdir;
80107771:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107777:	c9                   	leave  
80107778:	c3                   	ret    

80107779 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107779:	f3 0f 1e fb          	endbr32 
8010777d:	55                   	push   %ebp
8010777e:	89 e5                	mov    %esp,%ebp
80107780:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107783:	e8 00 ff ff ff       	call   80107688 <setupkvm>
80107788:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
8010778d:	e8 03 00 00 00       	call   80107795 <switchkvm>
}
80107792:	90                   	nop
80107793:	c9                   	leave  
80107794:	c3                   	ret    

80107795 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107795:	f3 0f 1e fb          	endbr32 
80107799:	55                   	push   %ebp
8010779a:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010779c:	a1 84 7d 19 80       	mov    0x80197d84,%eax
801077a1:	05 00 00 00 80       	add    $0x80000000,%eax
801077a6:	50                   	push   %eax
801077a7:	e8 48 fa ff ff       	call   801071f4 <lcr3>
801077ac:	83 c4 04             	add    $0x4,%esp
}
801077af:	90                   	nop
801077b0:	c9                   	leave  
801077b1:	c3                   	ret    

801077b2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801077b2:	f3 0f 1e fb          	endbr32 
801077b6:	55                   	push   %ebp
801077b7:	89 e5                	mov    %esp,%ebp
801077b9:	56                   	push   %esi
801077ba:	53                   	push   %ebx
801077bb:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801077be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801077c2:	75 0d                	jne    801077d1 <switchuvm+0x1f>
    panic("switchuvm: no process");
801077c4:	83 ec 0c             	sub    $0xc,%esp
801077c7:	68 f2 aa 10 80       	push   $0x8010aaf2
801077cc:	e8 f4 8d ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
801077d1:	8b 45 08             	mov    0x8(%ebp),%eax
801077d4:	8b 40 08             	mov    0x8(%eax),%eax
801077d7:	85 c0                	test   %eax,%eax
801077d9:	75 0d                	jne    801077e8 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801077db:	83 ec 0c             	sub    $0xc,%esp
801077de:	68 08 ab 10 80       	push   $0x8010ab08
801077e3:	e8 dd 8d ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
801077e8:	8b 45 08             	mov    0x8(%ebp),%eax
801077eb:	8b 40 04             	mov    0x4(%eax),%eax
801077ee:	85 c0                	test   %eax,%eax
801077f0:	75 0d                	jne    801077ff <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801077f2:	83 ec 0c             	sub    $0xc,%esp
801077f5:	68 1d ab 10 80       	push   $0x8010ab1d
801077fa:	e8 c6 8d ff ff       	call   801005c5 <panic>

  pushcli();
801077ff:	e8 47 d2 ff ff       	call   80104a4b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107804:	e8 24 c3 ff ff       	call   80103b2d <mycpu>
80107809:	89 c3                	mov    %eax,%ebx
8010780b:	e8 1d c3 ff ff       	call   80103b2d <mycpu>
80107810:	83 c0 08             	add    $0x8,%eax
80107813:	89 c6                	mov    %eax,%esi
80107815:	e8 13 c3 ff ff       	call   80103b2d <mycpu>
8010781a:	83 c0 08             	add    $0x8,%eax
8010781d:	c1 e8 10             	shr    $0x10,%eax
80107820:	88 45 f7             	mov    %al,-0x9(%ebp)
80107823:	e8 05 c3 ff ff       	call   80103b2d <mycpu>
80107828:	83 c0 08             	add    $0x8,%eax
8010782b:	c1 e8 18             	shr    $0x18,%eax
8010782e:	89 c2                	mov    %eax,%edx
80107830:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107837:	67 00 
80107839:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107840:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107844:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010784a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107851:	83 e0 f0             	and    $0xfffffff0,%eax
80107854:	83 c8 09             	or     $0x9,%eax
80107857:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010785d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107864:	83 c8 10             	or     $0x10,%eax
80107867:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010786d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107874:	83 e0 9f             	and    $0xffffff9f,%eax
80107877:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010787d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107884:	83 c8 80             	or     $0xffffff80,%eax
80107887:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010788d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107894:	83 e0 f0             	and    $0xfffffff0,%eax
80107897:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010789d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078a4:	83 e0 ef             	and    $0xffffffef,%eax
801078a7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078ad:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078b4:	83 e0 df             	and    $0xffffffdf,%eax
801078b7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078bd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078c4:	83 c8 40             	or     $0x40,%eax
801078c7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078cd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078d4:	83 e0 7f             	and    $0x7f,%eax
801078d7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078dd:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801078e3:	e8 45 c2 ff ff       	call   80103b2d <mycpu>
801078e8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801078ef:	83 e2 ef             	and    $0xffffffef,%edx
801078f2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801078f8:	e8 30 c2 ff ff       	call   80103b2d <mycpu>
801078fd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107903:	8b 45 08             	mov    0x8(%ebp),%eax
80107906:	8b 40 08             	mov    0x8(%eax),%eax
80107909:	89 c3                	mov    %eax,%ebx
8010790b:	e8 1d c2 ff ff       	call   80103b2d <mycpu>
80107910:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107916:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107919:	e8 0f c2 ff ff       	call   80103b2d <mycpu>
8010791e:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107924:	83 ec 0c             	sub    $0xc,%esp
80107927:	6a 28                	push   $0x28
80107929:	e8 af f8 ff ff       	call   801071dd <ltr>
8010792e:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107931:	8b 45 08             	mov    0x8(%ebp),%eax
80107934:	8b 40 04             	mov    0x4(%eax),%eax
80107937:	05 00 00 00 80       	add    $0x80000000,%eax
8010793c:	83 ec 0c             	sub    $0xc,%esp
8010793f:	50                   	push   %eax
80107940:	e8 af f8 ff ff       	call   801071f4 <lcr3>
80107945:	83 c4 10             	add    $0x10,%esp
  popcli();
80107948:	e8 4f d1 ff ff       	call   80104a9c <popcli>
}
8010794d:	90                   	nop
8010794e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107951:	5b                   	pop    %ebx
80107952:	5e                   	pop    %esi
80107953:	5d                   	pop    %ebp
80107954:	c3                   	ret    

80107955 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107955:	f3 0f 1e fb          	endbr32 
80107959:	55                   	push   %ebp
8010795a:	89 e5                	mov    %esp,%ebp
8010795c:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010795f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107966:	76 0d                	jbe    80107975 <inituvm+0x20>
    panic("inituvm: more than a page");
80107968:	83 ec 0c             	sub    $0xc,%esp
8010796b:	68 31 ab 10 80       	push   $0x8010ab31
80107970:	e8 50 8c ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107975:	e8 18 af ff ff       	call   80102892 <kalloc>
8010797a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010797d:	83 ec 04             	sub    $0x4,%esp
80107980:	68 00 10 00 00       	push   $0x1000
80107985:	6a 00                	push   $0x0
80107987:	ff 75 f4             	pushl  -0xc(%ebp)
8010798a:	e8 cf d1 ff ff       	call   80104b5e <memset>
8010798f:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	05 00 00 00 80       	add    $0x80000000,%eax
8010799a:	83 ec 0c             	sub    $0xc,%esp
8010799d:	6a 06                	push   $0x6
8010799f:	50                   	push   %eax
801079a0:	68 00 10 00 00       	push   $0x1000
801079a5:	6a 00                	push   $0x0
801079a7:	ff 75 08             	pushl  0x8(%ebp)
801079aa:	e8 45 fc ff ff       	call   801075f4 <mappages>
801079af:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801079b2:	83 ec 04             	sub    $0x4,%esp
801079b5:	ff 75 10             	pushl  0x10(%ebp)
801079b8:	ff 75 0c             	pushl  0xc(%ebp)
801079bb:	ff 75 f4             	pushl  -0xc(%ebp)
801079be:	e8 62 d2 ff ff       	call   80104c25 <memmove>
801079c3:	83 c4 10             	add    $0x10,%esp
}
801079c6:	90                   	nop
801079c7:	c9                   	leave  
801079c8:	c3                   	ret    

801079c9 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801079c9:	f3 0f 1e fb          	endbr32 
801079cd:	55                   	push   %ebp
801079ce:	89 e5                	mov    %esp,%ebp
801079d0:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801079d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801079d6:	25 ff 0f 00 00       	and    $0xfff,%eax
801079db:	85 c0                	test   %eax,%eax
801079dd:	74 0d                	je     801079ec <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801079df:	83 ec 0c             	sub    $0xc,%esp
801079e2:	68 4c ab 10 80       	push   $0x8010ab4c
801079e7:	e8 d9 8b ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801079ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079f3:	e9 8f 00 00 00       	jmp    80107a87 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801079f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801079fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fe:	01 d0                	add    %edx,%eax
80107a00:	83 ec 04             	sub    $0x4,%esp
80107a03:	6a 00                	push   $0x0
80107a05:	50                   	push   %eax
80107a06:	ff 75 08             	pushl  0x8(%ebp)
80107a09:	e8 4c fb ff ff       	call   8010755a <walkpgdir>
80107a0e:	83 c4 10             	add    $0x10,%esp
80107a11:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a14:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a18:	75 0d                	jne    80107a27 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107a1a:	83 ec 0c             	sub    $0xc,%esp
80107a1d:	68 6f ab 10 80       	push   $0x8010ab6f
80107a22:	e8 9e 8b ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a2a:	8b 00                	mov    (%eax),%eax
80107a2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a31:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107a34:	8b 45 18             	mov    0x18(%ebp),%eax
80107a37:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a3a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107a3f:	77 0b                	ja     80107a4c <loaduvm+0x83>
      n = sz - i;
80107a41:	8b 45 18             	mov    0x18(%ebp),%eax
80107a44:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a47:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a4a:	eb 07                	jmp    80107a53 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107a4c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107a53:	8b 55 14             	mov    0x14(%ebp),%edx
80107a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a59:	01 d0                	add    %edx,%eax
80107a5b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a5e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107a64:	ff 75 f0             	pushl  -0x10(%ebp)
80107a67:	50                   	push   %eax
80107a68:	52                   	push   %edx
80107a69:	ff 75 10             	pushl  0x10(%ebp)
80107a6c:	e8 13 a5 ff ff       	call   80101f84 <readi>
80107a71:	83 c4 10             	add    $0x10,%esp
80107a74:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107a77:	74 07                	je     80107a80 <loaduvm+0xb7>
      return -1;
80107a79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a7e:	eb 18                	jmp    80107a98 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107a80:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8a:	3b 45 18             	cmp    0x18(%ebp),%eax
80107a8d:	0f 82 65 ff ff ff    	jb     801079f8 <loaduvm+0x2f>
  }
  return 0;
80107a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a98:	c9                   	leave  
80107a99:	c3                   	ret    

80107a9a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a9a:	f3 0f 1e fb          	endbr32 
80107a9e:	55                   	push   %ebp
80107a9f:	89 e5                	mov    %esp,%ebp
80107aa1:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107aa4:	8b 45 10             	mov    0x10(%ebp),%eax
80107aa7:	85 c0                	test   %eax,%eax
80107aa9:	79 0a                	jns    80107ab5 <allocuvm+0x1b>
    return 0;
80107aab:	b8 00 00 00 00       	mov    $0x0,%eax
80107ab0:	e9 ec 00 00 00       	jmp    80107ba1 <allocuvm+0x107>
  if(newsz < oldsz)
80107ab5:	8b 45 10             	mov    0x10(%ebp),%eax
80107ab8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107abb:	73 08                	jae    80107ac5 <allocuvm+0x2b>
    return oldsz;
80107abd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ac0:	e9 dc 00 00 00       	jmp    80107ba1 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ac8:	05 ff 0f 00 00       	add    $0xfff,%eax
80107acd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107ad5:	e9 b8 00 00 00       	jmp    80107b92 <allocuvm+0xf8>
    mem = kalloc();
80107ada:	e8 b3 ad ff ff       	call   80102892 <kalloc>
80107adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107ae2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ae6:	75 2e                	jne    80107b16 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107ae8:	83 ec 0c             	sub    $0xc,%esp
80107aeb:	68 8d ab 10 80       	push   $0x8010ab8d
80107af0:	e8 17 89 ff ff       	call   8010040c <cprintf>
80107af5:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107af8:	83 ec 04             	sub    $0x4,%esp
80107afb:	ff 75 0c             	pushl  0xc(%ebp)
80107afe:	ff 75 10             	pushl  0x10(%ebp)
80107b01:	ff 75 08             	pushl  0x8(%ebp)
80107b04:	e8 9a 00 00 00       	call   80107ba3 <deallocuvm>
80107b09:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b0c:	b8 00 00 00 00       	mov    $0x0,%eax
80107b11:	e9 8b 00 00 00       	jmp    80107ba1 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107b16:	83 ec 04             	sub    $0x4,%esp
80107b19:	68 00 10 00 00       	push   $0x1000
80107b1e:	6a 00                	push   $0x0
80107b20:	ff 75 f0             	pushl  -0x10(%ebp)
80107b23:	e8 36 d0 ff ff       	call   80104b5e <memset>
80107b28:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b2e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b37:	83 ec 0c             	sub    $0xc,%esp
80107b3a:	6a 06                	push   $0x6
80107b3c:	52                   	push   %edx
80107b3d:	68 00 10 00 00       	push   $0x1000
80107b42:	50                   	push   %eax
80107b43:	ff 75 08             	pushl  0x8(%ebp)
80107b46:	e8 a9 fa ff ff       	call   801075f4 <mappages>
80107b4b:	83 c4 20             	add    $0x20,%esp
80107b4e:	85 c0                	test   %eax,%eax
80107b50:	79 39                	jns    80107b8b <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107b52:	83 ec 0c             	sub    $0xc,%esp
80107b55:	68 a5 ab 10 80       	push   $0x8010aba5
80107b5a:	e8 ad 88 ff ff       	call   8010040c <cprintf>
80107b5f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107b62:	83 ec 04             	sub    $0x4,%esp
80107b65:	ff 75 0c             	pushl  0xc(%ebp)
80107b68:	ff 75 10             	pushl  0x10(%ebp)
80107b6b:	ff 75 08             	pushl  0x8(%ebp)
80107b6e:	e8 30 00 00 00       	call   80107ba3 <deallocuvm>
80107b73:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107b76:	83 ec 0c             	sub    $0xc,%esp
80107b79:	ff 75 f0             	pushl  -0x10(%ebp)
80107b7c:	e8 73 ac ff ff       	call   801027f4 <kfree>
80107b81:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b84:	b8 00 00 00 00       	mov    $0x0,%eax
80107b89:	eb 16                	jmp    80107ba1 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107b8b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b95:	3b 45 10             	cmp    0x10(%ebp),%eax
80107b98:	0f 82 3c ff ff ff    	jb     80107ada <allocuvm+0x40>
    }
  }
  return newsz;
80107b9e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ba1:	c9                   	leave  
80107ba2:	c3                   	ret    

80107ba3 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ba3:	f3 0f 1e fb          	endbr32 
80107ba7:	55                   	push   %ebp
80107ba8:	89 e5                	mov    %esp,%ebp
80107baa:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107bad:	8b 45 10             	mov    0x10(%ebp),%eax
80107bb0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bb3:	72 08                	jb     80107bbd <deallocuvm+0x1a>
    return oldsz;
80107bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bb8:	e9 ac 00 00 00       	jmp    80107c69 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107bbd:	8b 45 10             	mov    0x10(%ebp),%eax
80107bc0:	05 ff 0f 00 00       	add    $0xfff,%eax
80107bc5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107bcd:	e9 88 00 00 00       	jmp    80107c5a <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd5:	83 ec 04             	sub    $0x4,%esp
80107bd8:	6a 00                	push   $0x0
80107bda:	50                   	push   %eax
80107bdb:	ff 75 08             	pushl  0x8(%ebp)
80107bde:	e8 77 f9 ff ff       	call   8010755a <walkpgdir>
80107be3:	83 c4 10             	add    $0x10,%esp
80107be6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107be9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bed:	75 16                	jne    80107c05 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf2:	c1 e8 16             	shr    $0x16,%eax
80107bf5:	83 c0 01             	add    $0x1,%eax
80107bf8:	c1 e0 16             	shl    $0x16,%eax
80107bfb:	2d 00 10 00 00       	sub    $0x1000,%eax
80107c00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c03:	eb 4e                	jmp    80107c53 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c08:	8b 00                	mov    (%eax),%eax
80107c0a:	83 e0 01             	and    $0x1,%eax
80107c0d:	85 c0                	test   %eax,%eax
80107c0f:	74 42                	je     80107c53 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c14:	8b 00                	mov    (%eax),%eax
80107c16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107c1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c22:	75 0d                	jne    80107c31 <deallocuvm+0x8e>
        panic("kfree");
80107c24:	83 ec 0c             	sub    $0xc,%esp
80107c27:	68 c1 ab 10 80       	push   $0x8010abc1
80107c2c:	e8 94 89 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c34:	05 00 00 00 80       	add    $0x80000000,%eax
80107c39:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107c3c:	83 ec 0c             	sub    $0xc,%esp
80107c3f:	ff 75 e8             	pushl  -0x18(%ebp)
80107c42:	e8 ad ab ff ff       	call   801027f4 <kfree>
80107c47:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107c53:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c60:	0f 82 6c ff ff ff    	jb     80107bd2 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107c66:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107c69:	c9                   	leave  
80107c6a:	c3                   	ret    

80107c6b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107c6b:	f3 0f 1e fb          	endbr32 
80107c6f:	55                   	push   %ebp
80107c70:	89 e5                	mov    %esp,%ebp
80107c72:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107c75:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c79:	75 0d                	jne    80107c88 <freevm+0x1d>
    panic("freevm: no pgdir");
80107c7b:	83 ec 0c             	sub    $0xc,%esp
80107c7e:	68 c7 ab 10 80       	push   $0x8010abc7
80107c83:	e8 3d 89 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107c88:	83 ec 04             	sub    $0x4,%esp
80107c8b:	6a 00                	push   $0x0
80107c8d:	68 00 00 00 80       	push   $0x80000000
80107c92:	ff 75 08             	pushl  0x8(%ebp)
80107c95:	e8 09 ff ff ff       	call   80107ba3 <deallocuvm>
80107c9a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107c9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ca4:	eb 48                	jmp    80107cee <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb3:	01 d0                	add    %edx,%eax
80107cb5:	8b 00                	mov    (%eax),%eax
80107cb7:	83 e0 01             	and    $0x1,%eax
80107cba:	85 c0                	test   %eax,%eax
80107cbc:	74 2c                	je     80107cea <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cc8:	8b 45 08             	mov    0x8(%ebp),%eax
80107ccb:	01 d0                	add    %edx,%eax
80107ccd:	8b 00                	mov    (%eax),%eax
80107ccf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cd4:	05 00 00 00 80       	add    $0x80000000,%eax
80107cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107cdc:	83 ec 0c             	sub    $0xc,%esp
80107cdf:	ff 75 f0             	pushl  -0x10(%ebp)
80107ce2:	e8 0d ab ff ff       	call   801027f4 <kfree>
80107ce7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107cea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cee:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107cf5:	76 af                	jbe    80107ca6 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107cf7:	83 ec 0c             	sub    $0xc,%esp
80107cfa:	ff 75 08             	pushl  0x8(%ebp)
80107cfd:	e8 f2 aa ff ff       	call   801027f4 <kfree>
80107d02:	83 c4 10             	add    $0x10,%esp
}
80107d05:	90                   	nop
80107d06:	c9                   	leave  
80107d07:	c3                   	ret    

80107d08 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107d08:	f3 0f 1e fb          	endbr32 
80107d0c:	55                   	push   %ebp
80107d0d:	89 e5                	mov    %esp,%ebp
80107d0f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107d12:	83 ec 04             	sub    $0x4,%esp
80107d15:	6a 00                	push   $0x0
80107d17:	ff 75 0c             	pushl  0xc(%ebp)
80107d1a:	ff 75 08             	pushl  0x8(%ebp)
80107d1d:	e8 38 f8 ff ff       	call   8010755a <walkpgdir>
80107d22:	83 c4 10             	add    $0x10,%esp
80107d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107d28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d2c:	75 0d                	jne    80107d3b <clearpteu+0x33>
    panic("clearpteu");
80107d2e:	83 ec 0c             	sub    $0xc,%esp
80107d31:	68 d8 ab 10 80       	push   $0x8010abd8
80107d36:	e8 8a 88 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3e:	8b 00                	mov    (%eax),%eax
80107d40:	83 e0 fb             	and    $0xfffffffb,%eax
80107d43:	89 c2                	mov    %eax,%edx
80107d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d48:	89 10                	mov    %edx,(%eax)
}
80107d4a:	90                   	nop
80107d4b:	c9                   	leave  
80107d4c:	c3                   	ret    

80107d4d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107d4d:	f3 0f 1e fb          	endbr32 
80107d51:	55                   	push   %ebp
80107d52:	89 e5                	mov    %esp,%ebp
80107d54:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107d57:	e8 2c f9 ff ff       	call   80107688 <setupkvm>
80107d5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d63:	75 0a                	jne    80107d6f <copyuvm+0x22>
    return 0;
80107d65:	b8 00 00 00 00       	mov    $0x0,%eax
80107d6a:	e9 eb 00 00 00       	jmp    80107e5a <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80107d6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d76:	e9 b7 00 00 00       	jmp    80107e32 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	83 ec 04             	sub    $0x4,%esp
80107d81:	6a 00                	push   $0x0
80107d83:	50                   	push   %eax
80107d84:	ff 75 08             	pushl  0x8(%ebp)
80107d87:	e8 ce f7 ff ff       	call   8010755a <walkpgdir>
80107d8c:	83 c4 10             	add    $0x10,%esp
80107d8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d92:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d96:	75 0d                	jne    80107da5 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80107d98:	83 ec 0c             	sub    $0xc,%esp
80107d9b:	68 e2 ab 10 80       	push   $0x8010abe2
80107da0:	e8 20 88 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80107da5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107da8:	8b 00                	mov    (%eax),%eax
80107daa:	83 e0 01             	and    $0x1,%eax
80107dad:	85 c0                	test   %eax,%eax
80107daf:	75 0d                	jne    80107dbe <copyuvm+0x71>
      panic("copyuvm: page not present");
80107db1:	83 ec 0c             	sub    $0xc,%esp
80107db4:	68 fc ab 10 80       	push   $0x8010abfc
80107db9:	e8 07 88 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107dbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dc1:	8b 00                	mov    (%eax),%eax
80107dc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dce:	8b 00                	mov    (%eax),%eax
80107dd0:	25 ff 0f 00 00       	and    $0xfff,%eax
80107dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107dd8:	e8 b5 aa ff ff       	call   80102892 <kalloc>
80107ddd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107de0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107de4:	74 5d                	je     80107e43 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107de6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107de9:	05 00 00 00 80       	add    $0x80000000,%eax
80107dee:	83 ec 04             	sub    $0x4,%esp
80107df1:	68 00 10 00 00       	push   $0x1000
80107df6:	50                   	push   %eax
80107df7:	ff 75 e0             	pushl  -0x20(%ebp)
80107dfa:	e8 26 ce ff ff       	call   80104c25 <memmove>
80107dff:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107e02:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107e05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e08:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e11:	83 ec 0c             	sub    $0xc,%esp
80107e14:	52                   	push   %edx
80107e15:	51                   	push   %ecx
80107e16:	68 00 10 00 00       	push   $0x1000
80107e1b:	50                   	push   %eax
80107e1c:	ff 75 f0             	pushl  -0x10(%ebp)
80107e1f:	e8 d0 f7 ff ff       	call   801075f4 <mappages>
80107e24:	83 c4 20             	add    $0x20,%esp
80107e27:	85 c0                	test   %eax,%eax
80107e29:	78 1b                	js     80107e46 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80107e2b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e35:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e38:	0f 82 3d ff ff ff    	jb     80107d7b <copyuvm+0x2e>
      goto bad;
  }
  return d;
80107e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e41:	eb 17                	jmp    80107e5a <copyuvm+0x10d>
      goto bad;
80107e43:	90                   	nop
80107e44:	eb 01                	jmp    80107e47 <copyuvm+0xfa>
      goto bad;
80107e46:	90                   	nop

bad:
  freevm(d);
80107e47:	83 ec 0c             	sub    $0xc,%esp
80107e4a:	ff 75 f0             	pushl  -0x10(%ebp)
80107e4d:	e8 19 fe ff ff       	call   80107c6b <freevm>
80107e52:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e55:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e5a:	c9                   	leave  
80107e5b:	c3                   	ret    

80107e5c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107e5c:	f3 0f 1e fb          	endbr32 
80107e60:	55                   	push   %ebp
80107e61:	89 e5                	mov    %esp,%ebp
80107e63:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e66:	83 ec 04             	sub    $0x4,%esp
80107e69:	6a 00                	push   $0x0
80107e6b:	ff 75 0c             	pushl  0xc(%ebp)
80107e6e:	ff 75 08             	pushl  0x8(%ebp)
80107e71:	e8 e4 f6 ff ff       	call   8010755a <walkpgdir>
80107e76:	83 c4 10             	add    $0x10,%esp
80107e79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7f:	8b 00                	mov    (%eax),%eax
80107e81:	83 e0 01             	and    $0x1,%eax
80107e84:	85 c0                	test   %eax,%eax
80107e86:	75 07                	jne    80107e8f <uva2ka+0x33>
    return 0;
80107e88:	b8 00 00 00 00       	mov    $0x0,%eax
80107e8d:	eb 22                	jmp    80107eb1 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80107e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e92:	8b 00                	mov    (%eax),%eax
80107e94:	83 e0 04             	and    $0x4,%eax
80107e97:	85 c0                	test   %eax,%eax
80107e99:	75 07                	jne    80107ea2 <uva2ka+0x46>
    return 0;
80107e9b:	b8 00 00 00 00       	mov    $0x0,%eax
80107ea0:	eb 0f                	jmp    80107eb1 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80107ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea5:	8b 00                	mov    (%eax),%eax
80107ea7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eac:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107eb1:	c9                   	leave  
80107eb2:	c3                   	ret    

80107eb3 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107eb3:	f3 0f 1e fb          	endbr32 
80107eb7:	55                   	push   %ebp
80107eb8:	89 e5                	mov    %esp,%ebp
80107eba:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107ebd:	8b 45 10             	mov    0x10(%ebp),%eax
80107ec0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107ec3:	eb 7f                	jmp    80107f44 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80107ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ec8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ecd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ed3:	83 ec 08             	sub    $0x8,%esp
80107ed6:	50                   	push   %eax
80107ed7:	ff 75 08             	pushl  0x8(%ebp)
80107eda:	e8 7d ff ff ff       	call   80107e5c <uva2ka>
80107edf:	83 c4 10             	add    $0x10,%esp
80107ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107ee5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107ee9:	75 07                	jne    80107ef2 <copyout+0x3f>
      return -1;
80107eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ef0:	eb 61                	jmp    80107f53 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80107ef2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef5:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ef8:	05 00 10 00 00       	add    $0x1000,%eax
80107efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f03:	3b 45 14             	cmp    0x14(%ebp),%eax
80107f06:	76 06                	jbe    80107f0e <copyout+0x5b>
      n = len;
80107f08:	8b 45 14             	mov    0x14(%ebp),%eax
80107f0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f11:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107f14:	89 c2                	mov    %eax,%edx
80107f16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f19:	01 d0                	add    %edx,%eax
80107f1b:	83 ec 04             	sub    $0x4,%esp
80107f1e:	ff 75 f0             	pushl  -0x10(%ebp)
80107f21:	ff 75 f4             	pushl  -0xc(%ebp)
80107f24:	50                   	push   %eax
80107f25:	e8 fb cc ff ff       	call   80104c25 <memmove>
80107f2a:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f30:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f36:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107f39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f3c:	05 00 10 00 00       	add    $0x1000,%eax
80107f41:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107f44:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107f48:	0f 85 77 ff ff ff    	jne    80107ec5 <copyout+0x12>
  }
  return 0;
80107f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f53:	c9                   	leave  
80107f54:	c3                   	ret    

80107f55 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107f55:	f3 0f 1e fb          	endbr32 
80107f59:	55                   	push   %ebp
80107f5a:	89 e5                	mov    %esp,%ebp
80107f5c:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107f5f:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107f66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f69:	8b 40 08             	mov    0x8(%eax),%eax
80107f6c:	05 00 00 00 80       	add    $0x80000000,%eax
80107f71:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107f74:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7e:	8b 40 24             	mov    0x24(%eax),%eax
80107f81:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80107f86:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
80107f8d:	00 00 00 

  while(i<madt->len){
80107f90:	90                   	nop
80107f91:	e9 be 00 00 00       	jmp    80108054 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80107f96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f9c:	01 d0                	add    %edx,%eax
80107f9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa4:	0f b6 00             	movzbl (%eax),%eax
80107fa7:	0f b6 c0             	movzbl %al,%eax
80107faa:	83 f8 05             	cmp    $0x5,%eax
80107fad:	0f 87 a1 00 00 00    	ja     80108054 <mpinit_uefi+0xff>
80107fb3:	8b 04 85 18 ac 10 80 	mov    -0x7fef53e8(,%eax,4),%eax
80107fba:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107fc3:	a1 80 80 19 80       	mov    0x80198080,%eax
80107fc8:	83 f8 03             	cmp    $0x3,%eax
80107fcb:	7f 28                	jg     80107ff5 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107fcd:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80107fd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fd6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107fda:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107fe0:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80107fe6:	88 02                	mov    %al,(%edx)
          ncpu++;
80107fe8:	a1 80 80 19 80       	mov    0x80198080,%eax
80107fed:	83 c0 01             	add    $0x1,%eax
80107ff0:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
80107ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107ff8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ffc:	0f b6 c0             	movzbl %al,%eax
80107fff:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108002:	eb 50                	jmp    80108054 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108007:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010800a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010800d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108011:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
80108016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108019:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010801d:	0f b6 c0             	movzbl %al,%eax
80108020:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108023:	eb 2f                	jmp    80108054 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108028:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010802b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010802e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108032:	0f b6 c0             	movzbl %al,%eax
80108035:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108038:	eb 1a                	jmp    80108054 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010803a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010803d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108040:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108043:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108047:	0f b6 c0             	movzbl %al,%eax
8010804a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010804d:	eb 05                	jmp    80108054 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
8010804f:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108053:	90                   	nop
  while(i<madt->len){
80108054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108057:	8b 40 04             	mov    0x4(%eax),%eax
8010805a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010805d:	0f 82 33 ff ff ff    	jb     80107f96 <mpinit_uefi+0x41>
    }
  }

}
80108063:	90                   	nop
80108064:	90                   	nop
80108065:	c9                   	leave  
80108066:	c3                   	ret    

80108067 <inb>:
{
80108067:	55                   	push   %ebp
80108068:	89 e5                	mov    %esp,%ebp
8010806a:	83 ec 14             	sub    $0x14,%esp
8010806d:	8b 45 08             	mov    0x8(%ebp),%eax
80108070:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108074:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108078:	89 c2                	mov    %eax,%edx
8010807a:	ec                   	in     (%dx),%al
8010807b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010807e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108082:	c9                   	leave  
80108083:	c3                   	ret    

80108084 <outb>:
{
80108084:	55                   	push   %ebp
80108085:	89 e5                	mov    %esp,%ebp
80108087:	83 ec 08             	sub    $0x8,%esp
8010808a:	8b 45 08             	mov    0x8(%ebp),%eax
8010808d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108090:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108094:	89 d0                	mov    %edx,%eax
80108096:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108099:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010809d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801080a1:	ee                   	out    %al,(%dx)
}
801080a2:	90                   	nop
801080a3:	c9                   	leave  
801080a4:	c3                   	ret    

801080a5 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801080a5:	f3 0f 1e fb          	endbr32 
801080a9:	55                   	push   %ebp
801080aa:	89 e5                	mov    %esp,%ebp
801080ac:	83 ec 28             	sub    $0x28,%esp
801080af:	8b 45 08             	mov    0x8(%ebp),%eax
801080b2:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801080b5:	6a 00                	push   $0x0
801080b7:	68 fa 03 00 00       	push   $0x3fa
801080bc:	e8 c3 ff ff ff       	call   80108084 <outb>
801080c1:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801080c4:	68 80 00 00 00       	push   $0x80
801080c9:	68 fb 03 00 00       	push   $0x3fb
801080ce:	e8 b1 ff ff ff       	call   80108084 <outb>
801080d3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801080d6:	6a 0c                	push   $0xc
801080d8:	68 f8 03 00 00       	push   $0x3f8
801080dd:	e8 a2 ff ff ff       	call   80108084 <outb>
801080e2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801080e5:	6a 00                	push   $0x0
801080e7:	68 f9 03 00 00       	push   $0x3f9
801080ec:	e8 93 ff ff ff       	call   80108084 <outb>
801080f1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801080f4:	6a 03                	push   $0x3
801080f6:	68 fb 03 00 00       	push   $0x3fb
801080fb:	e8 84 ff ff ff       	call   80108084 <outb>
80108100:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108103:	6a 00                	push   $0x0
80108105:	68 fc 03 00 00       	push   $0x3fc
8010810a:	e8 75 ff ff ff       	call   80108084 <outb>
8010810f:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108112:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108119:	eb 11                	jmp    8010812c <uart_debug+0x87>
8010811b:	83 ec 0c             	sub    $0xc,%esp
8010811e:	6a 0a                	push   $0xa
80108120:	e8 1f ab ff ff       	call   80102c44 <microdelay>
80108125:	83 c4 10             	add    $0x10,%esp
80108128:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010812c:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108130:	7f 1a                	jg     8010814c <uart_debug+0xa7>
80108132:	83 ec 0c             	sub    $0xc,%esp
80108135:	68 fd 03 00 00       	push   $0x3fd
8010813a:	e8 28 ff ff ff       	call   80108067 <inb>
8010813f:	83 c4 10             	add    $0x10,%esp
80108142:	0f b6 c0             	movzbl %al,%eax
80108145:	83 e0 20             	and    $0x20,%eax
80108148:	85 c0                	test   %eax,%eax
8010814a:	74 cf                	je     8010811b <uart_debug+0x76>
  outb(COM1+0, p);
8010814c:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108150:	0f b6 c0             	movzbl %al,%eax
80108153:	83 ec 08             	sub    $0x8,%esp
80108156:	50                   	push   %eax
80108157:	68 f8 03 00 00       	push   $0x3f8
8010815c:	e8 23 ff ff ff       	call   80108084 <outb>
80108161:	83 c4 10             	add    $0x10,%esp
}
80108164:	90                   	nop
80108165:	c9                   	leave  
80108166:	c3                   	ret    

80108167 <uart_debugs>:

void uart_debugs(char *p){
80108167:	f3 0f 1e fb          	endbr32 
8010816b:	55                   	push   %ebp
8010816c:	89 e5                	mov    %esp,%ebp
8010816e:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108171:	eb 1b                	jmp    8010818e <uart_debugs+0x27>
    uart_debug(*p++);
80108173:	8b 45 08             	mov    0x8(%ebp),%eax
80108176:	8d 50 01             	lea    0x1(%eax),%edx
80108179:	89 55 08             	mov    %edx,0x8(%ebp)
8010817c:	0f b6 00             	movzbl (%eax),%eax
8010817f:	0f be c0             	movsbl %al,%eax
80108182:	83 ec 0c             	sub    $0xc,%esp
80108185:	50                   	push   %eax
80108186:	e8 1a ff ff ff       	call   801080a5 <uart_debug>
8010818b:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010818e:	8b 45 08             	mov    0x8(%ebp),%eax
80108191:	0f b6 00             	movzbl (%eax),%eax
80108194:	84 c0                	test   %al,%al
80108196:	75 db                	jne    80108173 <uart_debugs+0xc>
  }
}
80108198:	90                   	nop
80108199:	90                   	nop
8010819a:	c9                   	leave  
8010819b:	c3                   	ret    

8010819c <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010819c:	f3 0f 1e fb          	endbr32 
801081a0:	55                   	push   %ebp
801081a1:	89 e5                	mov    %esp,%ebp
801081a3:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801081a6:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801081ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081b0:	8b 50 14             	mov    0x14(%eax),%edx
801081b3:	8b 40 10             	mov    0x10(%eax),%eax
801081b6:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
801081bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081be:	8b 50 1c             	mov    0x1c(%eax),%edx
801081c1:	8b 40 18             	mov    0x18(%eax),%eax
801081c4:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801081c9:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801081ce:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801081d3:	29 c2                	sub    %eax,%edx
801081d5:	89 d0                	mov    %edx,%eax
801081d7:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801081dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081df:	8b 50 24             	mov    0x24(%eax),%edx
801081e2:	8b 40 20             	mov    0x20(%eax),%eax
801081e5:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801081ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081ed:	8b 50 2c             	mov    0x2c(%eax),%edx
801081f0:	8b 40 28             	mov    0x28(%eax),%eax
801081f3:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801081f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081fb:	8b 50 34             	mov    0x34(%eax),%edx
801081fe:	8b 40 30             	mov    0x30(%eax),%eax
80108201:	a3 98 80 19 80       	mov    %eax,0x80198098
}
80108206:	90                   	nop
80108207:	c9                   	leave  
80108208:	c3                   	ret    

80108209 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108209:	f3 0f 1e fb          	endbr32 
8010820d:	55                   	push   %ebp
8010820e:	89 e5                	mov    %esp,%ebp
80108210:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108213:	8b 15 98 80 19 80    	mov    0x80198098,%edx
80108219:	8b 45 0c             	mov    0xc(%ebp),%eax
8010821c:	0f af d0             	imul   %eax,%edx
8010821f:	8b 45 08             	mov    0x8(%ebp),%eax
80108222:	01 d0                	add    %edx,%eax
80108224:	c1 e0 02             	shl    $0x2,%eax
80108227:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010822a:	8b 15 88 80 19 80    	mov    0x80198088,%edx
80108230:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108233:	01 d0                	add    %edx,%eax
80108235:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108238:	8b 45 10             	mov    0x10(%ebp),%eax
8010823b:	0f b6 10             	movzbl (%eax),%edx
8010823e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108241:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108243:	8b 45 10             	mov    0x10(%ebp),%eax
80108246:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010824a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010824d:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108250:	8b 45 10             	mov    0x10(%ebp),%eax
80108253:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108257:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010825a:	88 50 02             	mov    %dl,0x2(%eax)
}
8010825d:	90                   	nop
8010825e:	c9                   	leave  
8010825f:	c3                   	ret    

80108260 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108260:	f3 0f 1e fb          	endbr32 
80108264:	55                   	push   %ebp
80108265:	89 e5                	mov    %esp,%ebp
80108267:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010826a:	8b 15 98 80 19 80    	mov    0x80198098,%edx
80108270:	8b 45 08             	mov    0x8(%ebp),%eax
80108273:	0f af c2             	imul   %edx,%eax
80108276:	c1 e0 02             	shl    $0x2,%eax
80108279:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010827c:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108285:	29 c2                	sub    %eax,%edx
80108287:	89 d0                	mov    %edx,%eax
80108289:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010828f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108292:	01 ca                	add    %ecx,%edx
80108294:	89 d1                	mov    %edx,%ecx
80108296:	8b 15 88 80 19 80    	mov    0x80198088,%edx
8010829c:	83 ec 04             	sub    $0x4,%esp
8010829f:	50                   	push   %eax
801082a0:	51                   	push   %ecx
801082a1:	52                   	push   %edx
801082a2:	e8 7e c9 ff ff       	call   80104c25 <memmove>
801082a7:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801082aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ad:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
801082b3:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
801082b9:	01 d1                	add    %edx,%ecx
801082bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082be:	29 d1                	sub    %edx,%ecx
801082c0:	89 ca                	mov    %ecx,%edx
801082c2:	83 ec 04             	sub    $0x4,%esp
801082c5:	50                   	push   %eax
801082c6:	6a 00                	push   $0x0
801082c8:	52                   	push   %edx
801082c9:	e8 90 c8 ff ff       	call   80104b5e <memset>
801082ce:	83 c4 10             	add    $0x10,%esp
}
801082d1:	90                   	nop
801082d2:	c9                   	leave  
801082d3:	c3                   	ret    

801082d4 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801082d4:	f3 0f 1e fb          	endbr32 
801082d8:	55                   	push   %ebp
801082d9:	89 e5                	mov    %esp,%ebp
801082db:	53                   	push   %ebx
801082dc:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801082df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082e6:	e9 b1 00 00 00       	jmp    8010839c <font_render+0xc8>
    for(int j=14;j>-1;j--){
801082eb:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801082f2:	e9 97 00 00 00       	jmp    8010838e <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801082f7:	8b 45 10             	mov    0x10(%ebp),%eax
801082fa:	83 e8 20             	sub    $0x20,%eax
801082fd:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108303:	01 d0                	add    %edx,%eax
80108305:	0f b7 84 00 40 ac 10 	movzwl -0x7fef53c0(%eax,%eax,1),%eax
8010830c:	80 
8010830d:	0f b7 d0             	movzwl %ax,%edx
80108310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108313:	bb 01 00 00 00       	mov    $0x1,%ebx
80108318:	89 c1                	mov    %eax,%ecx
8010831a:	d3 e3                	shl    %cl,%ebx
8010831c:	89 d8                	mov    %ebx,%eax
8010831e:	21 d0                	and    %edx,%eax
80108320:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108323:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108326:	ba 01 00 00 00       	mov    $0x1,%edx
8010832b:	89 c1                	mov    %eax,%ecx
8010832d:	d3 e2                	shl    %cl,%edx
8010832f:	89 d0                	mov    %edx,%eax
80108331:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108334:	75 2b                	jne    80108361 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108336:	8b 55 0c             	mov    0xc(%ebp),%edx
80108339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833c:	01 c2                	add    %eax,%edx
8010833e:	b8 0e 00 00 00       	mov    $0xe,%eax
80108343:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108346:	89 c1                	mov    %eax,%ecx
80108348:	8b 45 08             	mov    0x8(%ebp),%eax
8010834b:	01 c8                	add    %ecx,%eax
8010834d:	83 ec 04             	sub    $0x4,%esp
80108350:	68 e0 f4 10 80       	push   $0x8010f4e0
80108355:	52                   	push   %edx
80108356:	50                   	push   %eax
80108357:	e8 ad fe ff ff       	call   80108209 <graphic_draw_pixel>
8010835c:	83 c4 10             	add    $0x10,%esp
8010835f:	eb 29                	jmp    8010838a <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108361:	8b 55 0c             	mov    0xc(%ebp),%edx
80108364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108367:	01 c2                	add    %eax,%edx
80108369:	b8 0e 00 00 00       	mov    $0xe,%eax
8010836e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108371:	89 c1                	mov    %eax,%ecx
80108373:	8b 45 08             	mov    0x8(%ebp),%eax
80108376:	01 c8                	add    %ecx,%eax
80108378:	83 ec 04             	sub    $0x4,%esp
8010837b:	68 64 d0 18 80       	push   $0x8018d064
80108380:	52                   	push   %edx
80108381:	50                   	push   %eax
80108382:	e8 82 fe ff ff       	call   80108209 <graphic_draw_pixel>
80108387:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010838a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010838e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108392:	0f 89 5f ff ff ff    	jns    801082f7 <font_render+0x23>
  for(int i=0;i<30;i++){
80108398:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010839c:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801083a0:	0f 8e 45 ff ff ff    	jle    801082eb <font_render+0x17>
      }
    }
  }
}
801083a6:	90                   	nop
801083a7:	90                   	nop
801083a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083ab:	c9                   	leave  
801083ac:	c3                   	ret    

801083ad <font_render_string>:

void font_render_string(char *string,int row){
801083ad:	f3 0f 1e fb          	endbr32 
801083b1:	55                   	push   %ebp
801083b2:	89 e5                	mov    %esp,%ebp
801083b4:	53                   	push   %ebx
801083b5:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801083b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801083bf:	eb 33                	jmp    801083f4 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
801083c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083c4:	8b 45 08             	mov    0x8(%ebp),%eax
801083c7:	01 d0                	add    %edx,%eax
801083c9:	0f b6 00             	movzbl (%eax),%eax
801083cc:	0f be d8             	movsbl %al,%ebx
801083cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d2:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801083d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083d8:	89 d0                	mov    %edx,%eax
801083da:	c1 e0 04             	shl    $0x4,%eax
801083dd:	29 d0                	sub    %edx,%eax
801083df:	83 c0 02             	add    $0x2,%eax
801083e2:	83 ec 04             	sub    $0x4,%esp
801083e5:	53                   	push   %ebx
801083e6:	51                   	push   %ecx
801083e7:	50                   	push   %eax
801083e8:	e8 e7 fe ff ff       	call   801082d4 <font_render>
801083ed:	83 c4 10             	add    $0x10,%esp
    i++;
801083f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801083f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083f7:	8b 45 08             	mov    0x8(%ebp),%eax
801083fa:	01 d0                	add    %edx,%eax
801083fc:	0f b6 00             	movzbl (%eax),%eax
801083ff:	84 c0                	test   %al,%al
80108401:	74 06                	je     80108409 <font_render_string+0x5c>
80108403:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108407:	7e b8                	jle    801083c1 <font_render_string+0x14>
  }
}
80108409:	90                   	nop
8010840a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010840d:	c9                   	leave  
8010840e:	c3                   	ret    

8010840f <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010840f:	f3 0f 1e fb          	endbr32 
80108413:	55                   	push   %ebp
80108414:	89 e5                	mov    %esp,%ebp
80108416:	53                   	push   %ebx
80108417:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010841a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108421:	eb 6b                	jmp    8010848e <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108423:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010842a:	eb 58                	jmp    80108484 <pci_init+0x75>
      for(int k=0;k<8;k++){
8010842c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108433:	eb 45                	jmp    8010847a <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108435:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108438:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010843b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843e:	83 ec 0c             	sub    $0xc,%esp
80108441:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108444:	53                   	push   %ebx
80108445:	6a 00                	push   $0x0
80108447:	51                   	push   %ecx
80108448:	52                   	push   %edx
80108449:	50                   	push   %eax
8010844a:	e8 c0 00 00 00       	call   8010850f <pci_access_config>
8010844f:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108452:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108455:	0f b7 c0             	movzwl %ax,%eax
80108458:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010845d:	74 17                	je     80108476 <pci_init+0x67>
        pci_init_device(i,j,k);
8010845f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108462:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108468:	83 ec 04             	sub    $0x4,%esp
8010846b:	51                   	push   %ecx
8010846c:	52                   	push   %edx
8010846d:	50                   	push   %eax
8010846e:	e8 4f 01 00 00       	call   801085c2 <pci_init_device>
80108473:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108476:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010847a:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010847e:	7e b5                	jle    80108435 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108480:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108484:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108488:	7e a2                	jle    8010842c <pci_init+0x1d>
  for(int i=0;i<256;i++){
8010848a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010848e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108495:	7e 8c                	jle    80108423 <pci_init+0x14>
      }
      }
    }
  }
}
80108497:	90                   	nop
80108498:	90                   	nop
80108499:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010849c:	c9                   	leave  
8010849d:	c3                   	ret    

8010849e <pci_write_config>:

void pci_write_config(uint config){
8010849e:	f3 0f 1e fb          	endbr32 
801084a2:	55                   	push   %ebp
801084a3:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801084a5:	8b 45 08             	mov    0x8(%ebp),%eax
801084a8:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801084ad:	89 c0                	mov    %eax,%eax
801084af:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801084b0:	90                   	nop
801084b1:	5d                   	pop    %ebp
801084b2:	c3                   	ret    

801084b3 <pci_write_data>:

void pci_write_data(uint config){
801084b3:	f3 0f 1e fb          	endbr32 
801084b7:	55                   	push   %ebp
801084b8:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801084ba:	8b 45 08             	mov    0x8(%ebp),%eax
801084bd:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801084c2:	89 c0                	mov    %eax,%eax
801084c4:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801084c5:	90                   	nop
801084c6:	5d                   	pop    %ebp
801084c7:	c3                   	ret    

801084c8 <pci_read_config>:
uint pci_read_config(){
801084c8:	f3 0f 1e fb          	endbr32 
801084cc:	55                   	push   %ebp
801084cd:	89 e5                	mov    %esp,%ebp
801084cf:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801084d2:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801084d7:	ed                   	in     (%dx),%eax
801084d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801084db:	83 ec 0c             	sub    $0xc,%esp
801084de:	68 c8 00 00 00       	push   $0xc8
801084e3:	e8 5c a7 ff ff       	call   80102c44 <microdelay>
801084e8:	83 c4 10             	add    $0x10,%esp
  return data;
801084eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801084ee:	c9                   	leave  
801084ef:	c3                   	ret    

801084f0 <pci_test>:


void pci_test(){
801084f0:	f3 0f 1e fb          	endbr32 
801084f4:	55                   	push   %ebp
801084f5:	89 e5                	mov    %esp,%ebp
801084f7:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801084fa:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108501:	ff 75 fc             	pushl  -0x4(%ebp)
80108504:	e8 95 ff ff ff       	call   8010849e <pci_write_config>
80108509:	83 c4 04             	add    $0x4,%esp
}
8010850c:	90                   	nop
8010850d:	c9                   	leave  
8010850e:	c3                   	ret    

8010850f <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010850f:	f3 0f 1e fb          	endbr32 
80108513:	55                   	push   %ebp
80108514:	89 e5                	mov    %esp,%ebp
80108516:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108519:	8b 45 08             	mov    0x8(%ebp),%eax
8010851c:	c1 e0 10             	shl    $0x10,%eax
8010851f:	25 00 00 ff 00       	and    $0xff0000,%eax
80108524:	89 c2                	mov    %eax,%edx
80108526:	8b 45 0c             	mov    0xc(%ebp),%eax
80108529:	c1 e0 0b             	shl    $0xb,%eax
8010852c:	0f b7 c0             	movzwl %ax,%eax
8010852f:	09 c2                	or     %eax,%edx
80108531:	8b 45 10             	mov    0x10(%ebp),%eax
80108534:	c1 e0 08             	shl    $0x8,%eax
80108537:	25 00 07 00 00       	and    $0x700,%eax
8010853c:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010853e:	8b 45 14             	mov    0x14(%ebp),%eax
80108541:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108546:	09 d0                	or     %edx,%eax
80108548:	0d 00 00 00 80       	or     $0x80000000,%eax
8010854d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108550:	ff 75 f4             	pushl  -0xc(%ebp)
80108553:	e8 46 ff ff ff       	call   8010849e <pci_write_config>
80108558:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010855b:	e8 68 ff ff ff       	call   801084c8 <pci_read_config>
80108560:	8b 55 18             	mov    0x18(%ebp),%edx
80108563:	89 02                	mov    %eax,(%edx)
}
80108565:	90                   	nop
80108566:	c9                   	leave  
80108567:	c3                   	ret    

80108568 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108568:	f3 0f 1e fb          	endbr32 
8010856c:	55                   	push   %ebp
8010856d:	89 e5                	mov    %esp,%ebp
8010856f:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108572:	8b 45 08             	mov    0x8(%ebp),%eax
80108575:	c1 e0 10             	shl    $0x10,%eax
80108578:	25 00 00 ff 00       	and    $0xff0000,%eax
8010857d:	89 c2                	mov    %eax,%edx
8010857f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108582:	c1 e0 0b             	shl    $0xb,%eax
80108585:	0f b7 c0             	movzwl %ax,%eax
80108588:	09 c2                	or     %eax,%edx
8010858a:	8b 45 10             	mov    0x10(%ebp),%eax
8010858d:	c1 e0 08             	shl    $0x8,%eax
80108590:	25 00 07 00 00       	and    $0x700,%eax
80108595:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108597:	8b 45 14             	mov    0x14(%ebp),%eax
8010859a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010859f:	09 d0                	or     %edx,%eax
801085a1:	0d 00 00 00 80       	or     $0x80000000,%eax
801085a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801085a9:	ff 75 fc             	pushl  -0x4(%ebp)
801085ac:	e8 ed fe ff ff       	call   8010849e <pci_write_config>
801085b1:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801085b4:	ff 75 18             	pushl  0x18(%ebp)
801085b7:	e8 f7 fe ff ff       	call   801084b3 <pci_write_data>
801085bc:	83 c4 04             	add    $0x4,%esp
}
801085bf:	90                   	nop
801085c0:	c9                   	leave  
801085c1:	c3                   	ret    

801085c2 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801085c2:	f3 0f 1e fb          	endbr32 
801085c6:	55                   	push   %ebp
801085c7:	89 e5                	mov    %esp,%ebp
801085c9:	53                   	push   %ebx
801085ca:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801085cd:	8b 45 08             	mov    0x8(%ebp),%eax
801085d0:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
801085d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d8:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
801085dd:	8b 45 10             	mov    0x10(%ebp),%eax
801085e0:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801085e5:	ff 75 10             	pushl  0x10(%ebp)
801085e8:	ff 75 0c             	pushl  0xc(%ebp)
801085eb:	ff 75 08             	pushl  0x8(%ebp)
801085ee:	68 84 c2 10 80       	push   $0x8010c284
801085f3:	e8 14 7e ff ff       	call   8010040c <cprintf>
801085f8:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801085fb:	83 ec 0c             	sub    $0xc,%esp
801085fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108601:	50                   	push   %eax
80108602:	6a 00                	push   $0x0
80108604:	ff 75 10             	pushl  0x10(%ebp)
80108607:	ff 75 0c             	pushl  0xc(%ebp)
8010860a:	ff 75 08             	pushl  0x8(%ebp)
8010860d:	e8 fd fe ff ff       	call   8010850f <pci_access_config>
80108612:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108615:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108618:	c1 e8 10             	shr    $0x10,%eax
8010861b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010861e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108621:	25 ff ff 00 00       	and    $0xffff,%eax
80108626:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862c:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
80108631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108634:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108639:	83 ec 04             	sub    $0x4,%esp
8010863c:	ff 75 f0             	pushl  -0x10(%ebp)
8010863f:	ff 75 f4             	pushl  -0xc(%ebp)
80108642:	68 b8 c2 10 80       	push   $0x8010c2b8
80108647:	e8 c0 7d ff ff       	call   8010040c <cprintf>
8010864c:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010864f:	83 ec 0c             	sub    $0xc,%esp
80108652:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108655:	50                   	push   %eax
80108656:	6a 08                	push   $0x8
80108658:	ff 75 10             	pushl  0x10(%ebp)
8010865b:	ff 75 0c             	pushl  0xc(%ebp)
8010865e:	ff 75 08             	pushl  0x8(%ebp)
80108661:	e8 a9 fe ff ff       	call   8010850f <pci_access_config>
80108666:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108669:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010866c:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010866f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108672:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108675:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108678:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010867b:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010867e:	0f b6 c0             	movzbl %al,%eax
80108681:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108684:	c1 eb 18             	shr    $0x18,%ebx
80108687:	83 ec 0c             	sub    $0xc,%esp
8010868a:	51                   	push   %ecx
8010868b:	52                   	push   %edx
8010868c:	50                   	push   %eax
8010868d:	53                   	push   %ebx
8010868e:	68 dc c2 10 80       	push   $0x8010c2dc
80108693:	e8 74 7d ff ff       	call   8010040c <cprintf>
80108698:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010869b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010869e:	c1 e8 18             	shr    $0x18,%eax
801086a1:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
801086a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086a9:	c1 e8 10             	shr    $0x10,%eax
801086ac:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
801086b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086b4:	c1 e8 08             	shr    $0x8,%eax
801086b7:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
801086bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086bf:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801086c4:	83 ec 0c             	sub    $0xc,%esp
801086c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086ca:	50                   	push   %eax
801086cb:	6a 10                	push   $0x10
801086cd:	ff 75 10             	pushl  0x10(%ebp)
801086d0:	ff 75 0c             	pushl  0xc(%ebp)
801086d3:	ff 75 08             	pushl  0x8(%ebp)
801086d6:	e8 34 fe ff ff       	call   8010850f <pci_access_config>
801086db:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801086de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e1:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801086e6:	83 ec 0c             	sub    $0xc,%esp
801086e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086ec:	50                   	push   %eax
801086ed:	6a 14                	push   $0x14
801086ef:	ff 75 10             	pushl  0x10(%ebp)
801086f2:	ff 75 0c             	pushl  0xc(%ebp)
801086f5:	ff 75 08             	pushl  0x8(%ebp)
801086f8:	e8 12 fe ff ff       	call   8010850f <pci_access_config>
801086fd:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108700:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108703:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108708:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010870f:	75 5a                	jne    8010876b <pci_init_device+0x1a9>
80108711:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108718:	75 51                	jne    8010876b <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
8010871a:	83 ec 0c             	sub    $0xc,%esp
8010871d:	68 21 c3 10 80       	push   $0x8010c321
80108722:	e8 e5 7c ff ff       	call   8010040c <cprintf>
80108727:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010872a:	83 ec 0c             	sub    $0xc,%esp
8010872d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108730:	50                   	push   %eax
80108731:	68 f0 00 00 00       	push   $0xf0
80108736:	ff 75 10             	pushl  0x10(%ebp)
80108739:	ff 75 0c             	pushl  0xc(%ebp)
8010873c:	ff 75 08             	pushl  0x8(%ebp)
8010873f:	e8 cb fd ff ff       	call   8010850f <pci_access_config>
80108744:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108747:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874a:	83 ec 08             	sub    $0x8,%esp
8010874d:	50                   	push   %eax
8010874e:	68 3b c3 10 80       	push   $0x8010c33b
80108753:	e8 b4 7c ff ff       	call   8010040c <cprintf>
80108758:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010875b:	83 ec 0c             	sub    $0xc,%esp
8010875e:	68 9c 80 19 80       	push   $0x8019809c
80108763:	e8 09 00 00 00       	call   80108771 <i8254_init>
80108768:	83 c4 10             	add    $0x10,%esp
  }
}
8010876b:	90                   	nop
8010876c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010876f:	c9                   	leave  
80108770:	c3                   	ret    

80108771 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108771:	f3 0f 1e fb          	endbr32 
80108775:	55                   	push   %ebp
80108776:	89 e5                	mov    %esp,%ebp
80108778:	53                   	push   %ebx
80108779:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010877c:	8b 45 08             	mov    0x8(%ebp),%eax
8010877f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108783:	0f b6 c8             	movzbl %al,%ecx
80108786:	8b 45 08             	mov    0x8(%ebp),%eax
80108789:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010878d:	0f b6 d0             	movzbl %al,%edx
80108790:	8b 45 08             	mov    0x8(%ebp),%eax
80108793:	0f b6 00             	movzbl (%eax),%eax
80108796:	0f b6 c0             	movzbl %al,%eax
80108799:	83 ec 0c             	sub    $0xc,%esp
8010879c:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010879f:	53                   	push   %ebx
801087a0:	6a 04                	push   $0x4
801087a2:	51                   	push   %ecx
801087a3:	52                   	push   %edx
801087a4:	50                   	push   %eax
801087a5:	e8 65 fd ff ff       	call   8010850f <pci_access_config>
801087aa:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801087ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b0:	83 c8 04             	or     $0x4,%eax
801087b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801087b6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801087b9:	8b 45 08             	mov    0x8(%ebp),%eax
801087bc:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801087c0:	0f b6 c8             	movzbl %al,%ecx
801087c3:	8b 45 08             	mov    0x8(%ebp),%eax
801087c6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087ca:	0f b6 d0             	movzbl %al,%edx
801087cd:	8b 45 08             	mov    0x8(%ebp),%eax
801087d0:	0f b6 00             	movzbl (%eax),%eax
801087d3:	0f b6 c0             	movzbl %al,%eax
801087d6:	83 ec 0c             	sub    $0xc,%esp
801087d9:	53                   	push   %ebx
801087da:	6a 04                	push   $0x4
801087dc:	51                   	push   %ecx
801087dd:	52                   	push   %edx
801087de:	50                   	push   %eax
801087df:	e8 84 fd ff ff       	call   80108568 <pci_write_config_register>
801087e4:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801087e7:	8b 45 08             	mov    0x8(%ebp),%eax
801087ea:	8b 40 10             	mov    0x10(%eax),%eax
801087ed:	05 00 00 00 40       	add    $0x40000000,%eax
801087f2:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
801087f7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801087fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801087ff:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108804:	05 d8 00 00 00       	add    $0xd8,%eax
80108809:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010880c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010880f:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108818:	8b 00                	mov    (%eax),%eax
8010881a:	0d 00 00 00 04       	or     $0x4000000,%eax
8010881f:	89 c2                	mov    %eax,%edx
80108821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108824:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108829:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010882f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108832:	8b 00                	mov    (%eax),%eax
80108834:	83 c8 40             	or     $0x40,%eax
80108837:	89 c2                	mov    %eax,%edx
80108839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883c:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010883e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108841:	8b 10                	mov    (%eax),%edx
80108843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108846:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108848:	83 ec 0c             	sub    $0xc,%esp
8010884b:	68 50 c3 10 80       	push   $0x8010c350
80108850:	e8 b7 7b ff ff       	call   8010040c <cprintf>
80108855:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108858:	e8 35 a0 ff ff       	call   80102892 <kalloc>
8010885d:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
80108862:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108867:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010886d:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108872:	83 ec 08             	sub    $0x8,%esp
80108875:	50                   	push   %eax
80108876:	68 72 c3 10 80       	push   $0x8010c372
8010887b:	e8 8c 7b ff ff       	call   8010040c <cprintf>
80108880:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108883:	e8 50 00 00 00       	call   801088d8 <i8254_init_recv>
  i8254_init_send();
80108888:	e8 6d 03 00 00       	call   80108bfa <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010888d:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108894:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108897:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010889e:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801088a1:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801088a8:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801088ab:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801088b2:	0f b6 c0             	movzbl %al,%eax
801088b5:	83 ec 0c             	sub    $0xc,%esp
801088b8:	53                   	push   %ebx
801088b9:	51                   	push   %ecx
801088ba:	52                   	push   %edx
801088bb:	50                   	push   %eax
801088bc:	68 80 c3 10 80       	push   $0x8010c380
801088c1:	e8 46 7b ff ff       	call   8010040c <cprintf>
801088c6:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801088c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801088d2:	90                   	nop
801088d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088d6:	c9                   	leave  
801088d7:	c3                   	ret    

801088d8 <i8254_init_recv>:

void i8254_init_recv(){
801088d8:	f3 0f 1e fb          	endbr32 
801088dc:	55                   	push   %ebp
801088dd:	89 e5                	mov    %esp,%ebp
801088df:	57                   	push   %edi
801088e0:	56                   	push   %esi
801088e1:	53                   	push   %ebx
801088e2:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801088e5:	83 ec 0c             	sub    $0xc,%esp
801088e8:	6a 00                	push   $0x0
801088ea:	e8 ec 04 00 00       	call   80108ddb <i8254_read_eeprom>
801088ef:	83 c4 10             	add    $0x10,%esp
801088f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801088f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801088f8:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
801088fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108900:	c1 e8 08             	shr    $0x8,%eax
80108903:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108908:	83 ec 0c             	sub    $0xc,%esp
8010890b:	6a 01                	push   $0x1
8010890d:	e8 c9 04 00 00       	call   80108ddb <i8254_read_eeprom>
80108912:	83 c4 10             	add    $0x10,%esp
80108915:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108918:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010891b:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108920:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108923:	c1 e8 08             	shr    $0x8,%eax
80108926:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
8010892b:	83 ec 0c             	sub    $0xc,%esp
8010892e:	6a 02                	push   $0x2
80108930:	e8 a6 04 00 00       	call   80108ddb <i8254_read_eeprom>
80108935:	83 c4 10             	add    $0x10,%esp
80108938:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010893b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010893e:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108943:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108946:	c1 e8 08             	shr    $0x8,%eax
80108949:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010894e:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108955:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108958:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010895f:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108962:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108969:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010896c:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108973:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108976:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010897d:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108980:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108987:	0f b6 c0             	movzbl %al,%eax
8010898a:	83 ec 04             	sub    $0x4,%esp
8010898d:	57                   	push   %edi
8010898e:	56                   	push   %esi
8010898f:	53                   	push   %ebx
80108990:	51                   	push   %ecx
80108991:	52                   	push   %edx
80108992:	50                   	push   %eax
80108993:	68 98 c3 10 80       	push   $0x8010c398
80108998:	e8 6f 7a ff ff       	call   8010040c <cprintf>
8010899d:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801089a0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089a5:	05 00 54 00 00       	add    $0x5400,%eax
801089aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801089ad:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089b2:	05 04 54 00 00       	add    $0x5404,%eax
801089b7:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801089ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089bd:	c1 e0 10             	shl    $0x10,%eax
801089c0:	0b 45 d8             	or     -0x28(%ebp),%eax
801089c3:	89 c2                	mov    %eax,%edx
801089c5:	8b 45 cc             	mov    -0x34(%ebp),%eax
801089c8:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801089ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089cd:	0d 00 00 00 80       	or     $0x80000000,%eax
801089d2:	89 c2                	mov    %eax,%edx
801089d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
801089d7:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801089d9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089de:	05 00 52 00 00       	add    $0x5200,%eax
801089e3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801089e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801089ed:	eb 19                	jmp    80108a08 <i8254_init_recv+0x130>
    mta[i] = 0;
801089ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801089f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089f9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801089fc:	01 d0                	add    %edx,%eax
801089fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108a04:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108a08:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108a0c:	7e e1                	jle    801089ef <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108a0e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a13:	05 d0 00 00 00       	add    $0xd0,%eax
80108a18:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108a1b:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108a1e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108a24:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a29:	05 c8 00 00 00       	add    $0xc8,%eax
80108a2e:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108a31:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108a34:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108a3a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a3f:	05 28 28 00 00       	add    $0x2828,%eax
80108a44:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108a47:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108a4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108a50:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a55:	05 00 01 00 00       	add    $0x100,%eax
80108a5a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108a5d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a60:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108a66:	e8 27 9e ff ff       	call   80102892 <kalloc>
80108a6b:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a6e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a73:	05 00 28 00 00       	add    $0x2800,%eax
80108a78:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108a7b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a80:	05 04 28 00 00       	add    $0x2804,%eax
80108a85:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108a88:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a8d:	05 08 28 00 00       	add    $0x2808,%eax
80108a92:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a95:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a9a:	05 10 28 00 00       	add    $0x2810,%eax
80108a9f:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108aa2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108aa7:	05 18 28 00 00       	add    $0x2818,%eax
80108aac:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108aaf:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108ab2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ab8:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108abb:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108abd:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108ac0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108ac6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108ac9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108acf:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108ad2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108ad8:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108adb:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108ae1:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108ae4:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ae7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108aee:	eb 73                	jmp    80108b63 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108af3:	c1 e0 04             	shl    $0x4,%eax
80108af6:	89 c2                	mov    %eax,%edx
80108af8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108afb:	01 d0                	add    %edx,%eax
80108afd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108b04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b07:	c1 e0 04             	shl    $0x4,%eax
80108b0a:	89 c2                	mov    %eax,%edx
80108b0c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b0f:	01 d0                	add    %edx,%eax
80108b11:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108b17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b1a:	c1 e0 04             	shl    $0x4,%eax
80108b1d:	89 c2                	mov    %eax,%edx
80108b1f:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b22:	01 d0                	add    %edx,%eax
80108b24:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108b2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b2d:	c1 e0 04             	shl    $0x4,%eax
80108b30:	89 c2                	mov    %eax,%edx
80108b32:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b35:	01 d0                	add    %edx,%eax
80108b37:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b3e:	c1 e0 04             	shl    $0x4,%eax
80108b41:	89 c2                	mov    %eax,%edx
80108b43:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b46:	01 d0                	add    %edx,%eax
80108b48:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108b4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b4f:	c1 e0 04             	shl    $0x4,%eax
80108b52:	89 c2                	mov    %eax,%edx
80108b54:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b57:	01 d0                	add    %edx,%eax
80108b59:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108b5f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108b63:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108b6a:	7e 84                	jle    80108af0 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b6c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108b73:	eb 57                	jmp    80108bcc <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108b75:	e8 18 9d ff ff       	call   80102892 <kalloc>
80108b7a:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108b7d:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108b81:	75 12                	jne    80108b95 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108b83:	83 ec 0c             	sub    $0xc,%esp
80108b86:	68 b8 c3 10 80       	push   $0x8010c3b8
80108b8b:	e8 7c 78 ff ff       	call   8010040c <cprintf>
80108b90:	83 c4 10             	add    $0x10,%esp
      break;
80108b93:	eb 3d                	jmp    80108bd2 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108b95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b98:	c1 e0 04             	shl    $0x4,%eax
80108b9b:	89 c2                	mov    %eax,%edx
80108b9d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ba0:	01 d0                	add    %edx,%eax
80108ba2:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108ba5:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108bab:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108bad:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108bb0:	83 c0 01             	add    $0x1,%eax
80108bb3:	c1 e0 04             	shl    $0x4,%eax
80108bb6:	89 c2                	mov    %eax,%edx
80108bb8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bbb:	01 d0                	add    %edx,%eax
80108bbd:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108bc0:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108bc6:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108bc8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108bcc:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108bd0:	7e a3                	jle    80108b75 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108bd2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bd5:	8b 00                	mov    (%eax),%eax
80108bd7:	83 c8 02             	or     $0x2,%eax
80108bda:	89 c2                	mov    %eax,%edx
80108bdc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bdf:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108be1:	83 ec 0c             	sub    $0xc,%esp
80108be4:	68 d8 c3 10 80       	push   $0x8010c3d8
80108be9:	e8 1e 78 ff ff       	call   8010040c <cprintf>
80108bee:	83 c4 10             	add    $0x10,%esp
}
80108bf1:	90                   	nop
80108bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108bf5:	5b                   	pop    %ebx
80108bf6:	5e                   	pop    %esi
80108bf7:	5f                   	pop    %edi
80108bf8:	5d                   	pop    %ebp
80108bf9:	c3                   	ret    

80108bfa <i8254_init_send>:

void i8254_init_send(){
80108bfa:	f3 0f 1e fb          	endbr32 
80108bfe:	55                   	push   %ebp
80108bff:	89 e5                	mov    %esp,%ebp
80108c01:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108c04:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c09:	05 28 38 00 00       	add    $0x3828,%eax
80108c0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108c11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c14:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108c1a:	e8 73 9c ff ff       	call   80102892 <kalloc>
80108c1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108c22:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c27:	05 00 38 00 00       	add    $0x3800,%eax
80108c2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108c2f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c34:	05 04 38 00 00       	add    $0x3804,%eax
80108c39:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108c3c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c41:	05 08 38 00 00       	add    $0x3808,%eax
80108c46:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c4c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c55:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108c57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108c60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c63:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108c69:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c6e:	05 10 38 00 00       	add    $0x3810,%eax
80108c73:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108c76:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c7b:	05 18 38 00 00       	add    $0x3818,%eax
80108c80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108c83:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108c8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108c95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c98:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108c9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ca2:	e9 82 00 00 00       	jmp    80108d29 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108caa:	c1 e0 04             	shl    $0x4,%eax
80108cad:	89 c2                	mov    %eax,%edx
80108caf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cb2:	01 d0                	add    %edx,%eax
80108cb4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cbe:	c1 e0 04             	shl    $0x4,%eax
80108cc1:	89 c2                	mov    %eax,%edx
80108cc3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cc6:	01 d0                	add    %edx,%eax
80108cc8:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd1:	c1 e0 04             	shl    $0x4,%eax
80108cd4:	89 c2                	mov    %eax,%edx
80108cd6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cd9:	01 d0                	add    %edx,%eax
80108cdb:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce2:	c1 e0 04             	shl    $0x4,%eax
80108ce5:	89 c2                	mov    %eax,%edx
80108ce7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cea:	01 d0                	add    %edx,%eax
80108cec:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf3:	c1 e0 04             	shl    $0x4,%eax
80108cf6:	89 c2                	mov    %eax,%edx
80108cf8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cfb:	01 d0                	add    %edx,%eax
80108cfd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d04:	c1 e0 04             	shl    $0x4,%eax
80108d07:	89 c2                	mov    %eax,%edx
80108d09:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d0c:	01 d0                	add    %edx,%eax
80108d0e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d15:	c1 e0 04             	shl    $0x4,%eax
80108d18:	89 c2                	mov    %eax,%edx
80108d1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d1d:	01 d0                	add    %edx,%eax
80108d1f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d29:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108d30:	0f 8e 71 ff ff ff    	jle    80108ca7 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d36:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d3d:	eb 57                	jmp    80108d96 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108d3f:	e8 4e 9b ff ff       	call   80102892 <kalloc>
80108d44:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108d47:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108d4b:	75 12                	jne    80108d5f <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108d4d:	83 ec 0c             	sub    $0xc,%esp
80108d50:	68 b8 c3 10 80       	push   $0x8010c3b8
80108d55:	e8 b2 76 ff ff       	call   8010040c <cprintf>
80108d5a:	83 c4 10             	add    $0x10,%esp
      break;
80108d5d:	eb 3d                	jmp    80108d9c <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d62:	c1 e0 04             	shl    $0x4,%eax
80108d65:	89 c2                	mov    %eax,%edx
80108d67:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d6a:	01 d0                	add    %edx,%eax
80108d6c:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d6f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d75:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d7a:	83 c0 01             	add    $0x1,%eax
80108d7d:	c1 e0 04             	shl    $0x4,%eax
80108d80:	89 c2                	mov    %eax,%edx
80108d82:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d85:	01 d0                	add    %edx,%eax
80108d87:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d8a:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d90:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d92:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d96:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108d9a:	7e a3                	jle    80108d3f <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108d9c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108da1:	05 00 04 00 00       	add    $0x400,%eax
80108da6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108da9:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108dac:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108db2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108db7:	05 10 04 00 00       	add    $0x410,%eax
80108dbc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108dbf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108dc2:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108dc8:	83 ec 0c             	sub    $0xc,%esp
80108dcb:	68 f8 c3 10 80       	push   $0x8010c3f8
80108dd0:	e8 37 76 ff ff       	call   8010040c <cprintf>
80108dd5:	83 c4 10             	add    $0x10,%esp

}
80108dd8:	90                   	nop
80108dd9:	c9                   	leave  
80108dda:	c3                   	ret    

80108ddb <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108ddb:	f3 0f 1e fb          	endbr32 
80108ddf:	55                   	push   %ebp
80108de0:	89 e5                	mov    %esp,%ebp
80108de2:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108de5:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dea:	83 c0 14             	add    $0x14,%eax
80108ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108df0:	8b 45 08             	mov    0x8(%ebp),%eax
80108df3:	c1 e0 08             	shl    $0x8,%eax
80108df6:	0f b7 c0             	movzwl %ax,%eax
80108df9:	83 c8 01             	or     $0x1,%eax
80108dfc:	89 c2                	mov    %eax,%edx
80108dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e01:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108e03:	83 ec 0c             	sub    $0xc,%esp
80108e06:	68 18 c4 10 80       	push   $0x8010c418
80108e0b:	e8 fc 75 ff ff       	call   8010040c <cprintf>
80108e10:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e16:	8b 00                	mov    (%eax),%eax
80108e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e1e:	83 e0 10             	and    $0x10,%eax
80108e21:	85 c0                	test   %eax,%eax
80108e23:	75 02                	jne    80108e27 <i8254_read_eeprom+0x4c>
  while(1){
80108e25:	eb dc                	jmp    80108e03 <i8254_read_eeprom+0x28>
      break;
80108e27:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2b:	8b 00                	mov    (%eax),%eax
80108e2d:	c1 e8 10             	shr    $0x10,%eax
}
80108e30:	c9                   	leave  
80108e31:	c3                   	ret    

80108e32 <i8254_recv>:
void i8254_recv(){
80108e32:	f3 0f 1e fb          	endbr32 
80108e36:	55                   	push   %ebp
80108e37:	89 e5                	mov    %esp,%ebp
80108e39:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108e3c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e41:	05 10 28 00 00       	add    $0x2810,%eax
80108e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108e49:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e4e:	05 18 28 00 00       	add    $0x2818,%eax
80108e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108e56:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e5b:	05 00 28 00 00       	add    $0x2800,%eax
80108e60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108e63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e66:	8b 00                	mov    (%eax),%eax
80108e68:	05 00 00 00 80       	add    $0x80000000,%eax
80108e6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e73:	8b 10                	mov    (%eax),%edx
80108e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e78:	8b 00                	mov    (%eax),%eax
80108e7a:	29 c2                	sub    %eax,%edx
80108e7c:	89 d0                	mov    %edx,%eax
80108e7e:	25 ff 00 00 00       	and    $0xff,%eax
80108e83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108e86:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e8a:	7e 37                	jle    80108ec3 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e8f:	8b 00                	mov    (%eax),%eax
80108e91:	c1 e0 04             	shl    $0x4,%eax
80108e94:	89 c2                	mov    %eax,%edx
80108e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e99:	01 d0                	add    %edx,%eax
80108e9b:	8b 00                	mov    (%eax),%eax
80108e9d:	05 00 00 00 80       	add    $0x80000000,%eax
80108ea2:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea8:	8b 00                	mov    (%eax),%eax
80108eaa:	83 c0 01             	add    $0x1,%eax
80108ead:	0f b6 d0             	movzbl %al,%edx
80108eb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb3:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108eb5:	83 ec 0c             	sub    $0xc,%esp
80108eb8:	ff 75 e0             	pushl  -0x20(%ebp)
80108ebb:	e8 47 09 00 00       	call   80109807 <eth_proc>
80108ec0:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec6:	8b 10                	mov    (%eax),%edx
80108ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ecb:	8b 00                	mov    (%eax),%eax
80108ecd:	39 c2                	cmp    %eax,%edx
80108ecf:	75 9f                	jne    80108e70 <i8254_recv+0x3e>
      (*rdt)--;
80108ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ed4:	8b 00                	mov    (%eax),%eax
80108ed6:	8d 50 ff             	lea    -0x1(%eax),%edx
80108ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108edc:	89 10                	mov    %edx,(%eax)
  while(1){
80108ede:	eb 90                	jmp    80108e70 <i8254_recv+0x3e>

80108ee0 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108ee0:	f3 0f 1e fb          	endbr32 
80108ee4:	55                   	push   %ebp
80108ee5:	89 e5                	mov    %esp,%ebp
80108ee7:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108eea:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108eef:	05 10 38 00 00       	add    $0x3810,%eax
80108ef4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ef7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108efc:	05 18 38 00 00       	add    $0x3818,%eax
80108f01:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f04:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f09:	05 00 38 00 00       	add    $0x3800,%eax
80108f0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f14:	8b 00                	mov    (%eax),%eax
80108f16:	05 00 00 00 80       	add    $0x80000000,%eax
80108f1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f21:	8b 10                	mov    (%eax),%edx
80108f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f26:	8b 00                	mov    (%eax),%eax
80108f28:	29 c2                	sub    %eax,%edx
80108f2a:	89 d0                	mov    %edx,%eax
80108f2c:	0f b6 c0             	movzbl %al,%eax
80108f2f:	ba 00 01 00 00       	mov    $0x100,%edx
80108f34:	29 c2                	sub    %eax,%edx
80108f36:	89 d0                	mov    %edx,%eax
80108f38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f3e:	8b 00                	mov    (%eax),%eax
80108f40:	25 ff 00 00 00       	and    $0xff,%eax
80108f45:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108f48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f4c:	0f 8e a8 00 00 00    	jle    80108ffa <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108f52:	8b 45 08             	mov    0x8(%ebp),%eax
80108f55:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108f58:	89 d1                	mov    %edx,%ecx
80108f5a:	c1 e1 04             	shl    $0x4,%ecx
80108f5d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108f60:	01 ca                	add    %ecx,%edx
80108f62:	8b 12                	mov    (%edx),%edx
80108f64:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f6a:	83 ec 04             	sub    $0x4,%esp
80108f6d:	ff 75 0c             	pushl  0xc(%ebp)
80108f70:	50                   	push   %eax
80108f71:	52                   	push   %edx
80108f72:	e8 ae bc ff ff       	call   80104c25 <memmove>
80108f77:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108f7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f7d:	c1 e0 04             	shl    $0x4,%eax
80108f80:	89 c2                	mov    %eax,%edx
80108f82:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f85:	01 d0                	add    %edx,%eax
80108f87:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f8a:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108f8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f91:	c1 e0 04             	shl    $0x4,%eax
80108f94:	89 c2                	mov    %eax,%edx
80108f96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f99:	01 d0                	add    %edx,%eax
80108f9b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108f9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fa2:	c1 e0 04             	shl    $0x4,%eax
80108fa5:	89 c2                	mov    %eax,%edx
80108fa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108faa:	01 d0                	add    %edx,%eax
80108fac:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108fb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fb3:	c1 e0 04             	shl    $0x4,%eax
80108fb6:	89 c2                	mov    %eax,%edx
80108fb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fbb:	01 d0                	add    %edx,%eax
80108fbd:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108fc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fc4:	c1 e0 04             	shl    $0x4,%eax
80108fc7:	89 c2                	mov    %eax,%edx
80108fc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fcc:	01 d0                	add    %edx,%eax
80108fce:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108fd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fd7:	c1 e0 04             	shl    $0x4,%eax
80108fda:	89 c2                	mov    %eax,%edx
80108fdc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fdf:	01 d0                	add    %edx,%eax
80108fe1:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe8:	8b 00                	mov    (%eax),%eax
80108fea:	83 c0 01             	add    $0x1,%eax
80108fed:	0f b6 d0             	movzbl %al,%edx
80108ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff3:	89 10                	mov    %edx,(%eax)
    return len;
80108ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ff8:	eb 05                	jmp    80108fff <i8254_send+0x11f>
  }else{
    return -1;
80108ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108fff:	c9                   	leave  
80109000:	c3                   	ret    

80109001 <i8254_intr>:

void i8254_intr(){
80109001:	f3 0f 1e fb          	endbr32 
80109005:	55                   	push   %ebp
80109006:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109008:	a1 b8 80 19 80       	mov    0x801980b8,%eax
8010900d:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109013:	90                   	nop
80109014:	5d                   	pop    %ebp
80109015:	c3                   	ret    

80109016 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109016:	f3 0f 1e fb          	endbr32 
8010901a:	55                   	push   %ebp
8010901b:	89 e5                	mov    %esp,%ebp
8010901d:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109020:	8b 45 08             	mov    0x8(%ebp),%eax
80109023:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109029:	0f b7 00             	movzwl (%eax),%eax
8010902c:	66 3d 00 01          	cmp    $0x100,%ax
80109030:	74 0a                	je     8010903c <arp_proc+0x26>
80109032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109037:	e9 4f 01 00 00       	jmp    8010918b <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
8010903c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010903f:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109043:	66 83 f8 08          	cmp    $0x8,%ax
80109047:	74 0a                	je     80109053 <arp_proc+0x3d>
80109049:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010904e:	e9 38 01 00 00       	jmp    8010918b <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109056:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010905a:	3c 06                	cmp    $0x6,%al
8010905c:	74 0a                	je     80109068 <arp_proc+0x52>
8010905e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109063:	e9 23 01 00 00       	jmp    8010918b <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906b:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010906f:	3c 04                	cmp    $0x4,%al
80109071:	74 0a                	je     8010907d <arp_proc+0x67>
80109073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109078:	e9 0e 01 00 00       	jmp    8010918b <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010907d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109080:	83 c0 18             	add    $0x18,%eax
80109083:	83 ec 04             	sub    $0x4,%esp
80109086:	6a 04                	push   $0x4
80109088:	50                   	push   %eax
80109089:	68 e4 f4 10 80       	push   $0x8010f4e4
8010908e:	e8 36 bb ff ff       	call   80104bc9 <memcmp>
80109093:	83 c4 10             	add    $0x10,%esp
80109096:	85 c0                	test   %eax,%eax
80109098:	74 27                	je     801090c1 <arp_proc+0xab>
8010909a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909d:	83 c0 0e             	add    $0xe,%eax
801090a0:	83 ec 04             	sub    $0x4,%esp
801090a3:	6a 04                	push   $0x4
801090a5:	50                   	push   %eax
801090a6:	68 e4 f4 10 80       	push   $0x8010f4e4
801090ab:	e8 19 bb ff ff       	call   80104bc9 <memcmp>
801090b0:	83 c4 10             	add    $0x10,%esp
801090b3:	85 c0                	test   %eax,%eax
801090b5:	74 0a                	je     801090c1 <arp_proc+0xab>
801090b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090bc:	e9 ca 00 00 00       	jmp    8010918b <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801090c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801090c8:	66 3d 00 01          	cmp    $0x100,%ax
801090cc:	75 69                	jne    80109137 <arp_proc+0x121>
801090ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d1:	83 c0 18             	add    $0x18,%eax
801090d4:	83 ec 04             	sub    $0x4,%esp
801090d7:	6a 04                	push   $0x4
801090d9:	50                   	push   %eax
801090da:	68 e4 f4 10 80       	push   $0x8010f4e4
801090df:	e8 e5 ba ff ff       	call   80104bc9 <memcmp>
801090e4:	83 c4 10             	add    $0x10,%esp
801090e7:	85 c0                	test   %eax,%eax
801090e9:	75 4c                	jne    80109137 <arp_proc+0x121>
    uint send = (uint)kalloc();
801090eb:	e8 a2 97 ff ff       	call   80102892 <kalloc>
801090f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801090f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801090fa:	83 ec 04             	sub    $0x4,%esp
801090fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109100:	50                   	push   %eax
80109101:	ff 75 f0             	pushl  -0x10(%ebp)
80109104:	ff 75 f4             	pushl  -0xc(%ebp)
80109107:	e8 33 04 00 00       	call   8010953f <arp_reply_pkt_create>
8010910c:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010910f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109112:	83 ec 08             	sub    $0x8,%esp
80109115:	50                   	push   %eax
80109116:	ff 75 f0             	pushl  -0x10(%ebp)
80109119:	e8 c2 fd ff ff       	call   80108ee0 <i8254_send>
8010911e:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109124:	83 ec 0c             	sub    $0xc,%esp
80109127:	50                   	push   %eax
80109128:	e8 c7 96 ff ff       	call   801027f4 <kfree>
8010912d:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109130:	b8 02 00 00 00       	mov    $0x2,%eax
80109135:	eb 54                	jmp    8010918b <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010913e:	66 3d 00 02          	cmp    $0x200,%ax
80109142:	75 42                	jne    80109186 <arp_proc+0x170>
80109144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109147:	83 c0 18             	add    $0x18,%eax
8010914a:	83 ec 04             	sub    $0x4,%esp
8010914d:	6a 04                	push   $0x4
8010914f:	50                   	push   %eax
80109150:	68 e4 f4 10 80       	push   $0x8010f4e4
80109155:	e8 6f ba ff ff       	call   80104bc9 <memcmp>
8010915a:	83 c4 10             	add    $0x10,%esp
8010915d:	85 c0                	test   %eax,%eax
8010915f:	75 25                	jne    80109186 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109161:	83 ec 0c             	sub    $0xc,%esp
80109164:	68 1c c4 10 80       	push   $0x8010c41c
80109169:	e8 9e 72 ff ff       	call   8010040c <cprintf>
8010916e:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109171:	83 ec 0c             	sub    $0xc,%esp
80109174:	ff 75 f4             	pushl  -0xc(%ebp)
80109177:	e8 b7 01 00 00       	call   80109333 <arp_table_update>
8010917c:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010917f:	b8 01 00 00 00       	mov    $0x1,%eax
80109184:	eb 05                	jmp    8010918b <arp_proc+0x175>
  }else{
    return -1;
80109186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010918b:	c9                   	leave  
8010918c:	c3                   	ret    

8010918d <arp_scan>:

void arp_scan(){
8010918d:	f3 0f 1e fb          	endbr32 
80109191:	55                   	push   %ebp
80109192:	89 e5                	mov    %esp,%ebp
80109194:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109197:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010919e:	eb 6f                	jmp    8010920f <arp_scan+0x82>
    uint send = (uint)kalloc();
801091a0:	e8 ed 96 ff ff       	call   80102892 <kalloc>
801091a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801091a8:	83 ec 04             	sub    $0x4,%esp
801091ab:	ff 75 f4             	pushl  -0xc(%ebp)
801091ae:	8d 45 e8             	lea    -0x18(%ebp),%eax
801091b1:	50                   	push   %eax
801091b2:	ff 75 ec             	pushl  -0x14(%ebp)
801091b5:	e8 62 00 00 00       	call   8010921c <arp_broadcast>
801091ba:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801091bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091c0:	83 ec 08             	sub    $0x8,%esp
801091c3:	50                   	push   %eax
801091c4:	ff 75 ec             	pushl  -0x14(%ebp)
801091c7:	e8 14 fd ff ff       	call   80108ee0 <i8254_send>
801091cc:	83 c4 10             	add    $0x10,%esp
801091cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801091d2:	eb 22                	jmp    801091f6 <arp_scan+0x69>
      microdelay(1);
801091d4:	83 ec 0c             	sub    $0xc,%esp
801091d7:	6a 01                	push   $0x1
801091d9:	e8 66 9a ff ff       	call   80102c44 <microdelay>
801091de:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801091e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091e4:	83 ec 08             	sub    $0x8,%esp
801091e7:	50                   	push   %eax
801091e8:	ff 75 ec             	pushl  -0x14(%ebp)
801091eb:	e8 f0 fc ff ff       	call   80108ee0 <i8254_send>
801091f0:	83 c4 10             	add    $0x10,%esp
801091f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801091f6:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801091fa:	74 d8                	je     801091d4 <arp_scan+0x47>
    }
    kfree((char *)send);
801091fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091ff:	83 ec 0c             	sub    $0xc,%esp
80109202:	50                   	push   %eax
80109203:	e8 ec 95 ff ff       	call   801027f4 <kfree>
80109208:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010920b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010920f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109216:	7e 88                	jle    801091a0 <arp_scan+0x13>
  }
}
80109218:	90                   	nop
80109219:	90                   	nop
8010921a:	c9                   	leave  
8010921b:	c3                   	ret    

8010921c <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010921c:	f3 0f 1e fb          	endbr32 
80109220:	55                   	push   %ebp
80109221:	89 e5                	mov    %esp,%ebp
80109223:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109226:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010922a:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010922e:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109232:	8b 45 10             	mov    0x10(%ebp),%eax
80109235:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109238:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010923f:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109245:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010924c:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109252:	8b 45 0c             	mov    0xc(%ebp),%eax
80109255:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010925b:	8b 45 08             	mov    0x8(%ebp),%eax
8010925e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109261:	8b 45 08             	mov    0x8(%ebp),%eax
80109264:	83 c0 0e             	add    $0xe,%eax
80109267:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010926a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010926d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109274:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010927b:	83 ec 04             	sub    $0x4,%esp
8010927e:	6a 06                	push   $0x6
80109280:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109283:	52                   	push   %edx
80109284:	50                   	push   %eax
80109285:	e8 9b b9 ff ff       	call   80104c25 <memmove>
8010928a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010928d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109290:	83 c0 06             	add    $0x6,%eax
80109293:	83 ec 04             	sub    $0x4,%esp
80109296:	6a 06                	push   $0x6
80109298:	68 68 d0 18 80       	push   $0x8018d068
8010929d:	50                   	push   %eax
8010929e:	e8 82 b9 ff ff       	call   80104c25 <memmove>
801092a3:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801092a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a9:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801092ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b1:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801092b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092ba:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801092be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c1:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801092c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c8:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801092ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092d1:	8d 50 12             	lea    0x12(%eax),%edx
801092d4:	83 ec 04             	sub    $0x4,%esp
801092d7:	6a 06                	push   $0x6
801092d9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801092dc:	50                   	push   %eax
801092dd:	52                   	push   %edx
801092de:	e8 42 b9 ff ff       	call   80104c25 <memmove>
801092e3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801092e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e9:	8d 50 18             	lea    0x18(%eax),%edx
801092ec:	83 ec 04             	sub    $0x4,%esp
801092ef:	6a 04                	push   $0x4
801092f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801092f4:	50                   	push   %eax
801092f5:	52                   	push   %edx
801092f6:	e8 2a b9 ff ff       	call   80104c25 <memmove>
801092fb:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801092fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109301:	83 c0 08             	add    $0x8,%eax
80109304:	83 ec 04             	sub    $0x4,%esp
80109307:	6a 06                	push   $0x6
80109309:	68 68 d0 18 80       	push   $0x8018d068
8010930e:	50                   	push   %eax
8010930f:	e8 11 b9 ff ff       	call   80104c25 <memmove>
80109314:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010931a:	83 c0 0e             	add    $0xe,%eax
8010931d:	83 ec 04             	sub    $0x4,%esp
80109320:	6a 04                	push   $0x4
80109322:	68 e4 f4 10 80       	push   $0x8010f4e4
80109327:	50                   	push   %eax
80109328:	e8 f8 b8 ff ff       	call   80104c25 <memmove>
8010932d:	83 c4 10             	add    $0x10,%esp
}
80109330:	90                   	nop
80109331:	c9                   	leave  
80109332:	c3                   	ret    

80109333 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109333:	f3 0f 1e fb          	endbr32 
80109337:	55                   	push   %ebp
80109338:	89 e5                	mov    %esp,%ebp
8010933a:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010933d:	8b 45 08             	mov    0x8(%ebp),%eax
80109340:	83 c0 0e             	add    $0xe,%eax
80109343:	83 ec 0c             	sub    $0xc,%esp
80109346:	50                   	push   %eax
80109347:	e8 bc 00 00 00       	call   80109408 <arp_table_search>
8010934c:	83 c4 10             	add    $0x10,%esp
8010934f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109352:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109356:	78 2d                	js     80109385 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109358:	8b 45 08             	mov    0x8(%ebp),%eax
8010935b:	8d 48 08             	lea    0x8(%eax),%ecx
8010935e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109361:	89 d0                	mov    %edx,%eax
80109363:	c1 e0 02             	shl    $0x2,%eax
80109366:	01 d0                	add    %edx,%eax
80109368:	01 c0                	add    %eax,%eax
8010936a:	01 d0                	add    %edx,%eax
8010936c:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109371:	83 c0 04             	add    $0x4,%eax
80109374:	83 ec 04             	sub    $0x4,%esp
80109377:	6a 06                	push   $0x6
80109379:	51                   	push   %ecx
8010937a:	50                   	push   %eax
8010937b:	e8 a5 b8 ff ff       	call   80104c25 <memmove>
80109380:	83 c4 10             	add    $0x10,%esp
80109383:	eb 70                	jmp    801093f5 <arp_table_update+0xc2>
  }else{
    index += 1;
80109385:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109389:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010938c:	8b 45 08             	mov    0x8(%ebp),%eax
8010938f:	8d 48 08             	lea    0x8(%eax),%ecx
80109392:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109395:	89 d0                	mov    %edx,%eax
80109397:	c1 e0 02             	shl    $0x2,%eax
8010939a:	01 d0                	add    %edx,%eax
8010939c:	01 c0                	add    %eax,%eax
8010939e:	01 d0                	add    %edx,%eax
801093a0:	05 80 d0 18 80       	add    $0x8018d080,%eax
801093a5:	83 c0 04             	add    $0x4,%eax
801093a8:	83 ec 04             	sub    $0x4,%esp
801093ab:	6a 06                	push   $0x6
801093ad:	51                   	push   %ecx
801093ae:	50                   	push   %eax
801093af:	e8 71 b8 ff ff       	call   80104c25 <memmove>
801093b4:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801093b7:	8b 45 08             	mov    0x8(%ebp),%eax
801093ba:	8d 48 0e             	lea    0xe(%eax),%ecx
801093bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093c0:	89 d0                	mov    %edx,%eax
801093c2:	c1 e0 02             	shl    $0x2,%eax
801093c5:	01 d0                	add    %edx,%eax
801093c7:	01 c0                	add    %eax,%eax
801093c9:	01 d0                	add    %edx,%eax
801093cb:	05 80 d0 18 80       	add    $0x8018d080,%eax
801093d0:	83 ec 04             	sub    $0x4,%esp
801093d3:	6a 04                	push   $0x4
801093d5:	51                   	push   %ecx
801093d6:	50                   	push   %eax
801093d7:	e8 49 b8 ff ff       	call   80104c25 <memmove>
801093dc:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801093df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093e2:	89 d0                	mov    %edx,%eax
801093e4:	c1 e0 02             	shl    $0x2,%eax
801093e7:	01 d0                	add    %edx,%eax
801093e9:	01 c0                	add    %eax,%eax
801093eb:	01 d0                	add    %edx,%eax
801093ed:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801093f2:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801093f5:	83 ec 0c             	sub    $0xc,%esp
801093f8:	68 80 d0 18 80       	push   $0x8018d080
801093fd:	e8 87 00 00 00       	call   80109489 <print_arp_table>
80109402:	83 c4 10             	add    $0x10,%esp
}
80109405:	90                   	nop
80109406:	c9                   	leave  
80109407:	c3                   	ret    

80109408 <arp_table_search>:

int arp_table_search(uchar *ip){
80109408:	f3 0f 1e fb          	endbr32 
8010940c:	55                   	push   %ebp
8010940d:	89 e5                	mov    %esp,%ebp
8010940f:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109412:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109419:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109420:	eb 59                	jmp    8010947b <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109422:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109425:	89 d0                	mov    %edx,%eax
80109427:	c1 e0 02             	shl    $0x2,%eax
8010942a:	01 d0                	add    %edx,%eax
8010942c:	01 c0                	add    %eax,%eax
8010942e:	01 d0                	add    %edx,%eax
80109430:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109435:	83 ec 04             	sub    $0x4,%esp
80109438:	6a 04                	push   $0x4
8010943a:	ff 75 08             	pushl  0x8(%ebp)
8010943d:	50                   	push   %eax
8010943e:	e8 86 b7 ff ff       	call   80104bc9 <memcmp>
80109443:	83 c4 10             	add    $0x10,%esp
80109446:	85 c0                	test   %eax,%eax
80109448:	75 05                	jne    8010944f <arp_table_search+0x47>
      return i;
8010944a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944d:	eb 38                	jmp    80109487 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010944f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109452:	89 d0                	mov    %edx,%eax
80109454:	c1 e0 02             	shl    $0x2,%eax
80109457:	01 d0                	add    %edx,%eax
80109459:	01 c0                	add    %eax,%eax
8010945b:	01 d0                	add    %edx,%eax
8010945d:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109462:	0f b6 00             	movzbl (%eax),%eax
80109465:	84 c0                	test   %al,%al
80109467:	75 0e                	jne    80109477 <arp_table_search+0x6f>
80109469:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010946d:	75 08                	jne    80109477 <arp_table_search+0x6f>
      empty = -i;
8010946f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109472:	f7 d8                	neg    %eax
80109474:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109477:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010947b:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010947f:	7e a1                	jle    80109422 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109484:	83 e8 01             	sub    $0x1,%eax
}
80109487:	c9                   	leave  
80109488:	c3                   	ret    

80109489 <print_arp_table>:

void print_arp_table(){
80109489:	f3 0f 1e fb          	endbr32 
8010948d:	55                   	push   %ebp
8010948e:	89 e5                	mov    %esp,%ebp
80109490:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109493:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010949a:	e9 92 00 00 00       	jmp    80109531 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010949f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094a2:	89 d0                	mov    %edx,%eax
801094a4:	c1 e0 02             	shl    $0x2,%eax
801094a7:	01 d0                	add    %edx,%eax
801094a9:	01 c0                	add    %eax,%eax
801094ab:	01 d0                	add    %edx,%eax
801094ad:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801094b2:	0f b6 00             	movzbl (%eax),%eax
801094b5:	84 c0                	test   %al,%al
801094b7:	74 74                	je     8010952d <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
801094b9:	83 ec 08             	sub    $0x8,%esp
801094bc:	ff 75 f4             	pushl  -0xc(%ebp)
801094bf:	68 2f c4 10 80       	push   $0x8010c42f
801094c4:	e8 43 6f ff ff       	call   8010040c <cprintf>
801094c9:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801094cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094cf:	89 d0                	mov    %edx,%eax
801094d1:	c1 e0 02             	shl    $0x2,%eax
801094d4:	01 d0                	add    %edx,%eax
801094d6:	01 c0                	add    %eax,%eax
801094d8:	01 d0                	add    %edx,%eax
801094da:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094df:	83 ec 0c             	sub    $0xc,%esp
801094e2:	50                   	push   %eax
801094e3:	e8 5c 02 00 00       	call   80109744 <print_ipv4>
801094e8:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801094eb:	83 ec 0c             	sub    $0xc,%esp
801094ee:	68 3e c4 10 80       	push   $0x8010c43e
801094f3:	e8 14 6f ff ff       	call   8010040c <cprintf>
801094f8:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801094fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094fe:	89 d0                	mov    %edx,%eax
80109500:	c1 e0 02             	shl    $0x2,%eax
80109503:	01 d0                	add    %edx,%eax
80109505:	01 c0                	add    %eax,%eax
80109507:	01 d0                	add    %edx,%eax
80109509:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010950e:	83 c0 04             	add    $0x4,%eax
80109511:	83 ec 0c             	sub    $0xc,%esp
80109514:	50                   	push   %eax
80109515:	e8 7c 02 00 00       	call   80109796 <print_mac>
8010951a:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010951d:	83 ec 0c             	sub    $0xc,%esp
80109520:	68 40 c4 10 80       	push   $0x8010c440
80109525:	e8 e2 6e ff ff       	call   8010040c <cprintf>
8010952a:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010952d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109531:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109535:	0f 8e 64 ff ff ff    	jle    8010949f <print_arp_table+0x16>
    }
  }
}
8010953b:	90                   	nop
8010953c:	90                   	nop
8010953d:	c9                   	leave  
8010953e:	c3                   	ret    

8010953f <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010953f:	f3 0f 1e fb          	endbr32 
80109543:	55                   	push   %ebp
80109544:	89 e5                	mov    %esp,%ebp
80109546:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109549:	8b 45 10             	mov    0x10(%ebp),%eax
8010954c:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109552:	8b 45 0c             	mov    0xc(%ebp),%eax
80109555:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109558:	8b 45 0c             	mov    0xc(%ebp),%eax
8010955b:	83 c0 0e             	add    $0xe,%eax
8010955e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109564:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010956b:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010956f:	8b 45 08             	mov    0x8(%ebp),%eax
80109572:	8d 50 08             	lea    0x8(%eax),%edx
80109575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109578:	83 ec 04             	sub    $0x4,%esp
8010957b:	6a 06                	push   $0x6
8010957d:	52                   	push   %edx
8010957e:	50                   	push   %eax
8010957f:	e8 a1 b6 ff ff       	call   80104c25 <memmove>
80109584:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958a:	83 c0 06             	add    $0x6,%eax
8010958d:	83 ec 04             	sub    $0x4,%esp
80109590:	6a 06                	push   $0x6
80109592:	68 68 d0 18 80       	push   $0x8018d068
80109597:	50                   	push   %eax
80109598:	e8 88 b6 ff ff       	call   80104c25 <memmove>
8010959d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801095a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095a3:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801095a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ab:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801095b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095b4:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801095b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095bb:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801095bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c2:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801095c8:	8b 45 08             	mov    0x8(%ebp),%eax
801095cb:	8d 50 08             	lea    0x8(%eax),%edx
801095ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d1:	83 c0 12             	add    $0x12,%eax
801095d4:	83 ec 04             	sub    $0x4,%esp
801095d7:	6a 06                	push   $0x6
801095d9:	52                   	push   %edx
801095da:	50                   	push   %eax
801095db:	e8 45 b6 ff ff       	call   80104c25 <memmove>
801095e0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801095e3:	8b 45 08             	mov    0x8(%ebp),%eax
801095e6:	8d 50 0e             	lea    0xe(%eax),%edx
801095e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ec:	83 c0 18             	add    $0x18,%eax
801095ef:	83 ec 04             	sub    $0x4,%esp
801095f2:	6a 04                	push   $0x4
801095f4:	52                   	push   %edx
801095f5:	50                   	push   %eax
801095f6:	e8 2a b6 ff ff       	call   80104c25 <memmove>
801095fb:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801095fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109601:	83 c0 08             	add    $0x8,%eax
80109604:	83 ec 04             	sub    $0x4,%esp
80109607:	6a 06                	push   $0x6
80109609:	68 68 d0 18 80       	push   $0x8018d068
8010960e:	50                   	push   %eax
8010960f:	e8 11 b6 ff ff       	call   80104c25 <memmove>
80109614:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961a:	83 c0 0e             	add    $0xe,%eax
8010961d:	83 ec 04             	sub    $0x4,%esp
80109620:	6a 04                	push   $0x4
80109622:	68 e4 f4 10 80       	push   $0x8010f4e4
80109627:	50                   	push   %eax
80109628:	e8 f8 b5 ff ff       	call   80104c25 <memmove>
8010962d:	83 c4 10             	add    $0x10,%esp
}
80109630:	90                   	nop
80109631:	c9                   	leave  
80109632:	c3                   	ret    

80109633 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109633:	f3 0f 1e fb          	endbr32 
80109637:	55                   	push   %ebp
80109638:	89 e5                	mov    %esp,%ebp
8010963a:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010963d:	83 ec 0c             	sub    $0xc,%esp
80109640:	68 42 c4 10 80       	push   $0x8010c442
80109645:	e8 c2 6d ff ff       	call   8010040c <cprintf>
8010964a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010964d:	8b 45 08             	mov    0x8(%ebp),%eax
80109650:	83 c0 0e             	add    $0xe,%eax
80109653:	83 ec 0c             	sub    $0xc,%esp
80109656:	50                   	push   %eax
80109657:	e8 e8 00 00 00       	call   80109744 <print_ipv4>
8010965c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010965f:	83 ec 0c             	sub    $0xc,%esp
80109662:	68 40 c4 10 80       	push   $0x8010c440
80109667:	e8 a0 6d ff ff       	call   8010040c <cprintf>
8010966c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010966f:	8b 45 08             	mov    0x8(%ebp),%eax
80109672:	83 c0 08             	add    $0x8,%eax
80109675:	83 ec 0c             	sub    $0xc,%esp
80109678:	50                   	push   %eax
80109679:	e8 18 01 00 00       	call   80109796 <print_mac>
8010967e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109681:	83 ec 0c             	sub    $0xc,%esp
80109684:	68 40 c4 10 80       	push   $0x8010c440
80109689:	e8 7e 6d ff ff       	call   8010040c <cprintf>
8010968e:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109691:	83 ec 0c             	sub    $0xc,%esp
80109694:	68 59 c4 10 80       	push   $0x8010c459
80109699:	e8 6e 6d ff ff       	call   8010040c <cprintf>
8010969e:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801096a1:	8b 45 08             	mov    0x8(%ebp),%eax
801096a4:	83 c0 18             	add    $0x18,%eax
801096a7:	83 ec 0c             	sub    $0xc,%esp
801096aa:	50                   	push   %eax
801096ab:	e8 94 00 00 00       	call   80109744 <print_ipv4>
801096b0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096b3:	83 ec 0c             	sub    $0xc,%esp
801096b6:	68 40 c4 10 80       	push   $0x8010c440
801096bb:	e8 4c 6d ff ff       	call   8010040c <cprintf>
801096c0:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801096c3:	8b 45 08             	mov    0x8(%ebp),%eax
801096c6:	83 c0 12             	add    $0x12,%eax
801096c9:	83 ec 0c             	sub    $0xc,%esp
801096cc:	50                   	push   %eax
801096cd:	e8 c4 00 00 00       	call   80109796 <print_mac>
801096d2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096d5:	83 ec 0c             	sub    $0xc,%esp
801096d8:	68 40 c4 10 80       	push   $0x8010c440
801096dd:	e8 2a 6d ff ff       	call   8010040c <cprintf>
801096e2:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801096e5:	83 ec 0c             	sub    $0xc,%esp
801096e8:	68 70 c4 10 80       	push   $0x8010c470
801096ed:	e8 1a 6d ff ff       	call   8010040c <cprintf>
801096f2:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801096f5:	8b 45 08             	mov    0x8(%ebp),%eax
801096f8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096fc:	66 3d 00 01          	cmp    $0x100,%ax
80109700:	75 12                	jne    80109714 <print_arp_info+0xe1>
80109702:	83 ec 0c             	sub    $0xc,%esp
80109705:	68 7c c4 10 80       	push   $0x8010c47c
8010970a:	e8 fd 6c ff ff       	call   8010040c <cprintf>
8010970f:	83 c4 10             	add    $0x10,%esp
80109712:	eb 1d                	jmp    80109731 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109714:	8b 45 08             	mov    0x8(%ebp),%eax
80109717:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010971b:	66 3d 00 02          	cmp    $0x200,%ax
8010971f:	75 10                	jne    80109731 <print_arp_info+0xfe>
    cprintf("Reply\n");
80109721:	83 ec 0c             	sub    $0xc,%esp
80109724:	68 85 c4 10 80       	push   $0x8010c485
80109729:	e8 de 6c ff ff       	call   8010040c <cprintf>
8010972e:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109731:	83 ec 0c             	sub    $0xc,%esp
80109734:	68 40 c4 10 80       	push   $0x8010c440
80109739:	e8 ce 6c ff ff       	call   8010040c <cprintf>
8010973e:	83 c4 10             	add    $0x10,%esp
}
80109741:	90                   	nop
80109742:	c9                   	leave  
80109743:	c3                   	ret    

80109744 <print_ipv4>:

void print_ipv4(uchar *ip){
80109744:	f3 0f 1e fb          	endbr32 
80109748:	55                   	push   %ebp
80109749:	89 e5                	mov    %esp,%ebp
8010974b:	53                   	push   %ebx
8010974c:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010974f:	8b 45 08             	mov    0x8(%ebp),%eax
80109752:	83 c0 03             	add    $0x3,%eax
80109755:	0f b6 00             	movzbl (%eax),%eax
80109758:	0f b6 d8             	movzbl %al,%ebx
8010975b:	8b 45 08             	mov    0x8(%ebp),%eax
8010975e:	83 c0 02             	add    $0x2,%eax
80109761:	0f b6 00             	movzbl (%eax),%eax
80109764:	0f b6 c8             	movzbl %al,%ecx
80109767:	8b 45 08             	mov    0x8(%ebp),%eax
8010976a:	83 c0 01             	add    $0x1,%eax
8010976d:	0f b6 00             	movzbl (%eax),%eax
80109770:	0f b6 d0             	movzbl %al,%edx
80109773:	8b 45 08             	mov    0x8(%ebp),%eax
80109776:	0f b6 00             	movzbl (%eax),%eax
80109779:	0f b6 c0             	movzbl %al,%eax
8010977c:	83 ec 0c             	sub    $0xc,%esp
8010977f:	53                   	push   %ebx
80109780:	51                   	push   %ecx
80109781:	52                   	push   %edx
80109782:	50                   	push   %eax
80109783:	68 8c c4 10 80       	push   $0x8010c48c
80109788:	e8 7f 6c ff ff       	call   8010040c <cprintf>
8010978d:	83 c4 20             	add    $0x20,%esp
}
80109790:	90                   	nop
80109791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109794:	c9                   	leave  
80109795:	c3                   	ret    

80109796 <print_mac>:

void print_mac(uchar *mac){
80109796:	f3 0f 1e fb          	endbr32 
8010979a:	55                   	push   %ebp
8010979b:	89 e5                	mov    %esp,%ebp
8010979d:	57                   	push   %edi
8010979e:	56                   	push   %esi
8010979f:	53                   	push   %ebx
801097a0:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801097a3:	8b 45 08             	mov    0x8(%ebp),%eax
801097a6:	83 c0 05             	add    $0x5,%eax
801097a9:	0f b6 00             	movzbl (%eax),%eax
801097ac:	0f b6 f8             	movzbl %al,%edi
801097af:	8b 45 08             	mov    0x8(%ebp),%eax
801097b2:	83 c0 04             	add    $0x4,%eax
801097b5:	0f b6 00             	movzbl (%eax),%eax
801097b8:	0f b6 f0             	movzbl %al,%esi
801097bb:	8b 45 08             	mov    0x8(%ebp),%eax
801097be:	83 c0 03             	add    $0x3,%eax
801097c1:	0f b6 00             	movzbl (%eax),%eax
801097c4:	0f b6 d8             	movzbl %al,%ebx
801097c7:	8b 45 08             	mov    0x8(%ebp),%eax
801097ca:	83 c0 02             	add    $0x2,%eax
801097cd:	0f b6 00             	movzbl (%eax),%eax
801097d0:	0f b6 c8             	movzbl %al,%ecx
801097d3:	8b 45 08             	mov    0x8(%ebp),%eax
801097d6:	83 c0 01             	add    $0x1,%eax
801097d9:	0f b6 00             	movzbl (%eax),%eax
801097dc:	0f b6 d0             	movzbl %al,%edx
801097df:	8b 45 08             	mov    0x8(%ebp),%eax
801097e2:	0f b6 00             	movzbl (%eax),%eax
801097e5:	0f b6 c0             	movzbl %al,%eax
801097e8:	83 ec 04             	sub    $0x4,%esp
801097eb:	57                   	push   %edi
801097ec:	56                   	push   %esi
801097ed:	53                   	push   %ebx
801097ee:	51                   	push   %ecx
801097ef:	52                   	push   %edx
801097f0:	50                   	push   %eax
801097f1:	68 a4 c4 10 80       	push   $0x8010c4a4
801097f6:	e8 11 6c ff ff       	call   8010040c <cprintf>
801097fb:	83 c4 20             	add    $0x20,%esp
}
801097fe:	90                   	nop
801097ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109802:	5b                   	pop    %ebx
80109803:	5e                   	pop    %esi
80109804:	5f                   	pop    %edi
80109805:	5d                   	pop    %ebp
80109806:	c3                   	ret    

80109807 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109807:	f3 0f 1e fb          	endbr32 
8010980b:	55                   	push   %ebp
8010980c:	89 e5                	mov    %esp,%ebp
8010980e:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109811:	8b 45 08             	mov    0x8(%ebp),%eax
80109814:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109817:	8b 45 08             	mov    0x8(%ebp),%eax
8010981a:	83 c0 0e             	add    $0xe,%eax
8010981d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109823:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109827:	3c 08                	cmp    $0x8,%al
80109829:	75 1b                	jne    80109846 <eth_proc+0x3f>
8010982b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109832:	3c 06                	cmp    $0x6,%al
80109834:	75 10                	jne    80109846 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109836:	83 ec 0c             	sub    $0xc,%esp
80109839:	ff 75 f0             	pushl  -0x10(%ebp)
8010983c:	e8 d5 f7 ff ff       	call   80109016 <arp_proc>
80109841:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109844:	eb 24                	jmp    8010986a <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109849:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010984d:	3c 08                	cmp    $0x8,%al
8010984f:	75 19                	jne    8010986a <eth_proc+0x63>
80109851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109854:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109858:	84 c0                	test   %al,%al
8010985a:	75 0e                	jne    8010986a <eth_proc+0x63>
    ipv4_proc(buffer_addr);
8010985c:	83 ec 0c             	sub    $0xc,%esp
8010985f:	ff 75 08             	pushl  0x8(%ebp)
80109862:	e8 b3 00 00 00       	call   8010991a <ipv4_proc>
80109867:	83 c4 10             	add    $0x10,%esp
}
8010986a:	90                   	nop
8010986b:	c9                   	leave  
8010986c:	c3                   	ret    

8010986d <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010986d:	f3 0f 1e fb          	endbr32 
80109871:	55                   	push   %ebp
80109872:	89 e5                	mov    %esp,%ebp
80109874:	83 ec 04             	sub    $0x4,%esp
80109877:	8b 45 08             	mov    0x8(%ebp),%eax
8010987a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010987e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109882:	c1 e0 08             	shl    $0x8,%eax
80109885:	89 c2                	mov    %eax,%edx
80109887:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010988b:	66 c1 e8 08          	shr    $0x8,%ax
8010988f:	01 d0                	add    %edx,%eax
}
80109891:	c9                   	leave  
80109892:	c3                   	ret    

80109893 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109893:	f3 0f 1e fb          	endbr32 
80109897:	55                   	push   %ebp
80109898:	89 e5                	mov    %esp,%ebp
8010989a:	83 ec 04             	sub    $0x4,%esp
8010989d:	8b 45 08             	mov    0x8(%ebp),%eax
801098a0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801098a4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098a8:	c1 e0 08             	shl    $0x8,%eax
801098ab:	89 c2                	mov    %eax,%edx
801098ad:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098b1:	66 c1 e8 08          	shr    $0x8,%ax
801098b5:	01 d0                	add    %edx,%eax
}
801098b7:	c9                   	leave  
801098b8:	c3                   	ret    

801098b9 <H2N_uint>:

uint H2N_uint(uint value){
801098b9:	f3 0f 1e fb          	endbr32 
801098bd:	55                   	push   %ebp
801098be:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801098c0:	8b 45 08             	mov    0x8(%ebp),%eax
801098c3:	c1 e0 18             	shl    $0x18,%eax
801098c6:	25 00 00 00 0f       	and    $0xf000000,%eax
801098cb:	89 c2                	mov    %eax,%edx
801098cd:	8b 45 08             	mov    0x8(%ebp),%eax
801098d0:	c1 e0 08             	shl    $0x8,%eax
801098d3:	25 00 f0 00 00       	and    $0xf000,%eax
801098d8:	09 c2                	or     %eax,%edx
801098da:	8b 45 08             	mov    0x8(%ebp),%eax
801098dd:	c1 e8 08             	shr    $0x8,%eax
801098e0:	83 e0 0f             	and    $0xf,%eax
801098e3:	01 d0                	add    %edx,%eax
}
801098e5:	5d                   	pop    %ebp
801098e6:	c3                   	ret    

801098e7 <N2H_uint>:

uint N2H_uint(uint value){
801098e7:	f3 0f 1e fb          	endbr32 
801098eb:	55                   	push   %ebp
801098ec:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801098ee:	8b 45 08             	mov    0x8(%ebp),%eax
801098f1:	c1 e0 18             	shl    $0x18,%eax
801098f4:	89 c2                	mov    %eax,%edx
801098f6:	8b 45 08             	mov    0x8(%ebp),%eax
801098f9:	c1 e0 08             	shl    $0x8,%eax
801098fc:	25 00 00 ff 00       	and    $0xff0000,%eax
80109901:	01 c2                	add    %eax,%edx
80109903:	8b 45 08             	mov    0x8(%ebp),%eax
80109906:	c1 e8 08             	shr    $0x8,%eax
80109909:	25 00 ff 00 00       	and    $0xff00,%eax
8010990e:	01 c2                	add    %eax,%edx
80109910:	8b 45 08             	mov    0x8(%ebp),%eax
80109913:	c1 e8 18             	shr    $0x18,%eax
80109916:	01 d0                	add    %edx,%eax
}
80109918:	5d                   	pop    %ebp
80109919:	c3                   	ret    

8010991a <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010991a:	f3 0f 1e fb          	endbr32 
8010991e:	55                   	push   %ebp
8010991f:	89 e5                	mov    %esp,%ebp
80109921:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109924:	8b 45 08             	mov    0x8(%ebp),%eax
80109927:	83 c0 0e             	add    $0xe,%eax
8010992a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010992d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109930:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109934:	0f b7 d0             	movzwl %ax,%edx
80109937:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
8010993c:	39 c2                	cmp    %eax,%edx
8010993e:	74 60                	je     801099a0 <ipv4_proc+0x86>
80109940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109943:	83 c0 0c             	add    $0xc,%eax
80109946:	83 ec 04             	sub    $0x4,%esp
80109949:	6a 04                	push   $0x4
8010994b:	50                   	push   %eax
8010994c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109951:	e8 73 b2 ff ff       	call   80104bc9 <memcmp>
80109956:	83 c4 10             	add    $0x10,%esp
80109959:	85 c0                	test   %eax,%eax
8010995b:	74 43                	je     801099a0 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010995d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109960:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109964:	0f b7 c0             	movzwl %ax,%eax
80109967:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010996c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010996f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109973:	3c 01                	cmp    $0x1,%al
80109975:	75 10                	jne    80109987 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109977:	83 ec 0c             	sub    $0xc,%esp
8010997a:	ff 75 08             	pushl  0x8(%ebp)
8010997d:	e8 a7 00 00 00       	call   80109a29 <icmp_proc>
80109982:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109985:	eb 19                	jmp    801099a0 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010998a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010998e:	3c 06                	cmp    $0x6,%al
80109990:	75 0e                	jne    801099a0 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109992:	83 ec 0c             	sub    $0xc,%esp
80109995:	ff 75 08             	pushl  0x8(%ebp)
80109998:	e8 c7 03 00 00       	call   80109d64 <tcp_proc>
8010999d:	83 c4 10             	add    $0x10,%esp
}
801099a0:	90                   	nop
801099a1:	c9                   	leave  
801099a2:	c3                   	ret    

801099a3 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801099a3:	f3 0f 1e fb          	endbr32 
801099a7:	55                   	push   %ebp
801099a8:	89 e5                	mov    %esp,%ebp
801099aa:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801099ad:	8b 45 08             	mov    0x8(%ebp),%eax
801099b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801099b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b6:	0f b6 00             	movzbl (%eax),%eax
801099b9:	83 e0 0f             	and    $0xf,%eax
801099bc:	01 c0                	add    %eax,%eax
801099be:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801099c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801099c8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801099cf:	eb 48                	jmp    80109a19 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801099d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099d4:	01 c0                	add    %eax,%eax
801099d6:	89 c2                	mov    %eax,%edx
801099d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099db:	01 d0                	add    %edx,%eax
801099dd:	0f b6 00             	movzbl (%eax),%eax
801099e0:	0f b6 c0             	movzbl %al,%eax
801099e3:	c1 e0 08             	shl    $0x8,%eax
801099e6:	89 c2                	mov    %eax,%edx
801099e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099eb:	01 c0                	add    %eax,%eax
801099ed:	8d 48 01             	lea    0x1(%eax),%ecx
801099f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f3:	01 c8                	add    %ecx,%eax
801099f5:	0f b6 00             	movzbl (%eax),%eax
801099f8:	0f b6 c0             	movzbl %al,%eax
801099fb:	01 d0                	add    %edx,%eax
801099fd:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a00:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a07:	76 0c                	jbe    80109a15 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a0c:	0f b7 c0             	movzwl %ax,%eax
80109a0f:	83 c0 01             	add    $0x1,%eax
80109a12:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a15:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a19:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109a1d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109a20:	7c af                	jl     801099d1 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a25:	f7 d0                	not    %eax
}
80109a27:	c9                   	leave  
80109a28:	c3                   	ret    

80109a29 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109a29:	f3 0f 1e fb          	endbr32 
80109a2d:	55                   	push   %ebp
80109a2e:	89 e5                	mov    %esp,%ebp
80109a30:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109a33:	8b 45 08             	mov    0x8(%ebp),%eax
80109a36:	83 c0 0e             	add    $0xe,%eax
80109a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a3f:	0f b6 00             	movzbl (%eax),%eax
80109a42:	0f b6 c0             	movzbl %al,%eax
80109a45:	83 e0 0f             	and    $0xf,%eax
80109a48:	c1 e0 02             	shl    $0x2,%eax
80109a4b:	89 c2                	mov    %eax,%edx
80109a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a50:	01 d0                	add    %edx,%eax
80109a52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a58:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109a5c:	84 c0                	test   %al,%al
80109a5e:	75 4f                	jne    80109aaf <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a63:	0f b6 00             	movzbl (%eax),%eax
80109a66:	3c 08                	cmp    $0x8,%al
80109a68:	75 45                	jne    80109aaf <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109a6a:	e8 23 8e ff ff       	call   80102892 <kalloc>
80109a6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109a72:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109a79:	83 ec 04             	sub    $0x4,%esp
80109a7c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109a7f:	50                   	push   %eax
80109a80:	ff 75 ec             	pushl  -0x14(%ebp)
80109a83:	ff 75 08             	pushl  0x8(%ebp)
80109a86:	e8 7c 00 00 00       	call   80109b07 <icmp_reply_pkt_create>
80109a8b:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109a8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a91:	83 ec 08             	sub    $0x8,%esp
80109a94:	50                   	push   %eax
80109a95:	ff 75 ec             	pushl  -0x14(%ebp)
80109a98:	e8 43 f4 ff ff       	call   80108ee0 <i8254_send>
80109a9d:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109aa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109aa3:	83 ec 0c             	sub    $0xc,%esp
80109aa6:	50                   	push   %eax
80109aa7:	e8 48 8d ff ff       	call   801027f4 <kfree>
80109aac:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109aaf:	90                   	nop
80109ab0:	c9                   	leave  
80109ab1:	c3                   	ret    

80109ab2 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109ab2:	f3 0f 1e fb          	endbr32 
80109ab6:	55                   	push   %ebp
80109ab7:	89 e5                	mov    %esp,%ebp
80109ab9:	53                   	push   %ebx
80109aba:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109abd:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109ac4:	0f b7 c0             	movzwl %ax,%eax
80109ac7:	83 ec 0c             	sub    $0xc,%esp
80109aca:	50                   	push   %eax
80109acb:	e8 9d fd ff ff       	call   8010986d <N2H_ushort>
80109ad0:	83 c4 10             	add    $0x10,%esp
80109ad3:	0f b7 d8             	movzwl %ax,%ebx
80109ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109add:	0f b7 c0             	movzwl %ax,%eax
80109ae0:	83 ec 0c             	sub    $0xc,%esp
80109ae3:	50                   	push   %eax
80109ae4:	e8 84 fd ff ff       	call   8010986d <N2H_ushort>
80109ae9:	83 c4 10             	add    $0x10,%esp
80109aec:	0f b7 c0             	movzwl %ax,%eax
80109aef:	83 ec 04             	sub    $0x4,%esp
80109af2:	53                   	push   %ebx
80109af3:	50                   	push   %eax
80109af4:	68 c3 c4 10 80       	push   $0x8010c4c3
80109af9:	e8 0e 69 ff ff       	call   8010040c <cprintf>
80109afe:	83 c4 10             	add    $0x10,%esp
}
80109b01:	90                   	nop
80109b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b05:	c9                   	leave  
80109b06:	c3                   	ret    

80109b07 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b07:	f3 0f 1e fb          	endbr32 
80109b0b:	55                   	push   %ebp
80109b0c:	89 e5                	mov    %esp,%ebp
80109b0e:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b11:	8b 45 08             	mov    0x8(%ebp),%eax
80109b14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b17:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1a:	83 c0 0e             	add    $0xe,%eax
80109b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b23:	0f b6 00             	movzbl (%eax),%eax
80109b26:	0f b6 c0             	movzbl %al,%eax
80109b29:	83 e0 0f             	and    $0xf,%eax
80109b2c:	c1 e0 02             	shl    $0x2,%eax
80109b2f:	89 c2                	mov    %eax,%edx
80109b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b34:	01 d0                	add    %edx,%eax
80109b36:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b39:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b42:	83 c0 0e             	add    $0xe,%eax
80109b45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109b48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b4b:	83 c0 14             	add    $0x14,%eax
80109b4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109b51:	8b 45 10             	mov    0x10(%ebp),%eax
80109b54:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b5d:	8d 50 06             	lea    0x6(%eax),%edx
80109b60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b63:	83 ec 04             	sub    $0x4,%esp
80109b66:	6a 06                	push   $0x6
80109b68:	52                   	push   %edx
80109b69:	50                   	push   %eax
80109b6a:	e8 b6 b0 ff ff       	call   80104c25 <memmove>
80109b6f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b75:	83 c0 06             	add    $0x6,%eax
80109b78:	83 ec 04             	sub    $0x4,%esp
80109b7b:	6a 06                	push   $0x6
80109b7d:	68 68 d0 18 80       	push   $0x8018d068
80109b82:	50                   	push   %eax
80109b83:	e8 9d b0 ff ff       	call   80104c25 <memmove>
80109b88:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b8e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b92:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b95:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b9c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ba2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109ba6:	83 ec 0c             	sub    $0xc,%esp
80109ba9:	6a 54                	push   $0x54
80109bab:	e8 e3 fc ff ff       	call   80109893 <H2N_ushort>
80109bb0:	83 c4 10             	add    $0x10,%esp
80109bb3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bb6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109bba:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109bc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc4:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109bc8:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109bcf:	83 c0 01             	add    $0x1,%eax
80109bd2:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109bd8:	83 ec 0c             	sub    $0xc,%esp
80109bdb:	68 00 40 00 00       	push   $0x4000
80109be0:	e8 ae fc ff ff       	call   80109893 <H2N_ushort>
80109be5:	83 c4 10             	add    $0x10,%esp
80109be8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109beb:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109bef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf2:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c00:	83 c0 0c             	add    $0xc,%eax
80109c03:	83 ec 04             	sub    $0x4,%esp
80109c06:	6a 04                	push   $0x4
80109c08:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c0d:	50                   	push   %eax
80109c0e:	e8 12 b0 ff ff       	call   80104c25 <memmove>
80109c13:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c19:	8d 50 0c             	lea    0xc(%eax),%edx
80109c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c1f:	83 c0 10             	add    $0x10,%eax
80109c22:	83 ec 04             	sub    $0x4,%esp
80109c25:	6a 04                	push   $0x4
80109c27:	52                   	push   %edx
80109c28:	50                   	push   %eax
80109c29:	e8 f7 af ff ff       	call   80104c25 <memmove>
80109c2e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c34:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c3d:	83 ec 0c             	sub    $0xc,%esp
80109c40:	50                   	push   %eax
80109c41:	e8 5d fd ff ff       	call   801099a3 <ipv4_chksum>
80109c46:	83 c4 10             	add    $0x10,%esp
80109c49:	0f b7 c0             	movzwl %ax,%eax
80109c4c:	83 ec 0c             	sub    $0xc,%esp
80109c4f:	50                   	push   %eax
80109c50:	e8 3e fc ff ff       	call   80109893 <H2N_ushort>
80109c55:	83 c4 10             	add    $0x10,%esp
80109c58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c5b:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109c5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c62:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109c65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c68:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c6f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109c73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c76:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c7d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109c81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c84:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109c88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c8b:	8d 50 08             	lea    0x8(%eax),%edx
80109c8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c91:	83 c0 08             	add    $0x8,%eax
80109c94:	83 ec 04             	sub    $0x4,%esp
80109c97:	6a 08                	push   $0x8
80109c99:	52                   	push   %edx
80109c9a:	50                   	push   %eax
80109c9b:	e8 85 af ff ff       	call   80104c25 <memmove>
80109ca0:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ca6:	8d 50 10             	lea    0x10(%eax),%edx
80109ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cac:	83 c0 10             	add    $0x10,%eax
80109caf:	83 ec 04             	sub    $0x4,%esp
80109cb2:	6a 30                	push   $0x30
80109cb4:	52                   	push   %edx
80109cb5:	50                   	push   %eax
80109cb6:	e8 6a af ff ff       	call   80104c25 <memmove>
80109cbb:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109cbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cc1:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cca:	83 ec 0c             	sub    $0xc,%esp
80109ccd:	50                   	push   %eax
80109cce:	e8 1c 00 00 00       	call   80109cef <icmp_chksum>
80109cd3:	83 c4 10             	add    $0x10,%esp
80109cd6:	0f b7 c0             	movzwl %ax,%eax
80109cd9:	83 ec 0c             	sub    $0xc,%esp
80109cdc:	50                   	push   %eax
80109cdd:	e8 b1 fb ff ff       	call   80109893 <H2N_ushort>
80109ce2:	83 c4 10             	add    $0x10,%esp
80109ce5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ce8:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109cec:	90                   	nop
80109ced:	c9                   	leave  
80109cee:	c3                   	ret    

80109cef <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109cef:	f3 0f 1e fb          	endbr32 
80109cf3:	55                   	push   %ebp
80109cf4:	89 e5                	mov    %esp,%ebp
80109cf6:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80109cfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109cff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d06:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d0d:	eb 48                	jmp    80109d57 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d12:	01 c0                	add    %eax,%eax
80109d14:	89 c2                	mov    %eax,%edx
80109d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d19:	01 d0                	add    %edx,%eax
80109d1b:	0f b6 00             	movzbl (%eax),%eax
80109d1e:	0f b6 c0             	movzbl %al,%eax
80109d21:	c1 e0 08             	shl    $0x8,%eax
80109d24:	89 c2                	mov    %eax,%edx
80109d26:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d29:	01 c0                	add    %eax,%eax
80109d2b:	8d 48 01             	lea    0x1(%eax),%ecx
80109d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d31:	01 c8                	add    %ecx,%eax
80109d33:	0f b6 00             	movzbl (%eax),%eax
80109d36:	0f b6 c0             	movzbl %al,%eax
80109d39:	01 d0                	add    %edx,%eax
80109d3b:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d3e:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d45:	76 0c                	jbe    80109d53 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d4a:	0f b7 c0             	movzwl %ax,%eax
80109d4d:	83 c0 01             	add    $0x1,%eax
80109d50:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d53:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d57:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109d5b:	7e b2                	jle    80109d0f <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109d5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d60:	f7 d0                	not    %eax
}
80109d62:	c9                   	leave  
80109d63:	c3                   	ret    

80109d64 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109d64:	f3 0f 1e fb          	endbr32 
80109d68:	55                   	push   %ebp
80109d69:	89 e5                	mov    %esp,%ebp
80109d6b:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d71:	83 c0 0e             	add    $0xe,%eax
80109d74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d7a:	0f b6 00             	movzbl (%eax),%eax
80109d7d:	0f b6 c0             	movzbl %al,%eax
80109d80:	83 e0 0f             	and    $0xf,%eax
80109d83:	c1 e0 02             	shl    $0x2,%eax
80109d86:	89 c2                	mov    %eax,%edx
80109d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d8b:	01 d0                	add    %edx,%eax
80109d8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d93:	83 c0 14             	add    $0x14,%eax
80109d96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109d99:	e8 f4 8a ff ff       	call   80102892 <kalloc>
80109d9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109da1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dab:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109daf:	0f b6 c0             	movzbl %al,%eax
80109db2:	83 e0 02             	and    $0x2,%eax
80109db5:	85 c0                	test   %eax,%eax
80109db7:	74 3d                	je     80109df6 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109db9:	83 ec 0c             	sub    $0xc,%esp
80109dbc:	6a 00                	push   $0x0
80109dbe:	6a 12                	push   $0x12
80109dc0:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109dc3:	50                   	push   %eax
80109dc4:	ff 75 e8             	pushl  -0x18(%ebp)
80109dc7:	ff 75 08             	pushl  0x8(%ebp)
80109dca:	e8 a2 01 00 00       	call   80109f71 <tcp_pkt_create>
80109dcf:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109dd2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109dd5:	83 ec 08             	sub    $0x8,%esp
80109dd8:	50                   	push   %eax
80109dd9:	ff 75 e8             	pushl  -0x18(%ebp)
80109ddc:	e8 ff f0 ff ff       	call   80108ee0 <i8254_send>
80109de1:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109de4:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109de9:	83 c0 01             	add    $0x1,%eax
80109dec:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109df1:	e9 69 01 00 00       	jmp    80109f5f <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109df9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109dfd:	3c 18                	cmp    $0x18,%al
80109dff:	0f 85 10 01 00 00    	jne    80109f15 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109e05:	83 ec 04             	sub    $0x4,%esp
80109e08:	6a 03                	push   $0x3
80109e0a:	68 de c4 10 80       	push   $0x8010c4de
80109e0f:	ff 75 ec             	pushl  -0x14(%ebp)
80109e12:	e8 b2 ad ff ff       	call   80104bc9 <memcmp>
80109e17:	83 c4 10             	add    $0x10,%esp
80109e1a:	85 c0                	test   %eax,%eax
80109e1c:	74 74                	je     80109e92 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109e1e:	83 ec 0c             	sub    $0xc,%esp
80109e21:	68 e2 c4 10 80       	push   $0x8010c4e2
80109e26:	e8 e1 65 ff ff       	call   8010040c <cprintf>
80109e2b:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e2e:	83 ec 0c             	sub    $0xc,%esp
80109e31:	6a 00                	push   $0x0
80109e33:	6a 10                	push   $0x10
80109e35:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e38:	50                   	push   %eax
80109e39:	ff 75 e8             	pushl  -0x18(%ebp)
80109e3c:	ff 75 08             	pushl  0x8(%ebp)
80109e3f:	e8 2d 01 00 00       	call   80109f71 <tcp_pkt_create>
80109e44:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e4a:	83 ec 08             	sub    $0x8,%esp
80109e4d:	50                   	push   %eax
80109e4e:	ff 75 e8             	pushl  -0x18(%ebp)
80109e51:	e8 8a f0 ff ff       	call   80108ee0 <i8254_send>
80109e56:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e5c:	83 c0 36             	add    $0x36,%eax
80109e5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e62:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109e65:	50                   	push   %eax
80109e66:	ff 75 e0             	pushl  -0x20(%ebp)
80109e69:	6a 00                	push   $0x0
80109e6b:	6a 00                	push   $0x0
80109e6d:	e8 66 04 00 00       	call   8010a2d8 <http_proc>
80109e72:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109e75:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109e78:	83 ec 0c             	sub    $0xc,%esp
80109e7b:	50                   	push   %eax
80109e7c:	6a 18                	push   $0x18
80109e7e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e81:	50                   	push   %eax
80109e82:	ff 75 e8             	pushl  -0x18(%ebp)
80109e85:	ff 75 08             	pushl  0x8(%ebp)
80109e88:	e8 e4 00 00 00       	call   80109f71 <tcp_pkt_create>
80109e8d:	83 c4 20             	add    $0x20,%esp
80109e90:	eb 62                	jmp    80109ef4 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e92:	83 ec 0c             	sub    $0xc,%esp
80109e95:	6a 00                	push   $0x0
80109e97:	6a 10                	push   $0x10
80109e99:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e9c:	50                   	push   %eax
80109e9d:	ff 75 e8             	pushl  -0x18(%ebp)
80109ea0:	ff 75 08             	pushl  0x8(%ebp)
80109ea3:	e8 c9 00 00 00       	call   80109f71 <tcp_pkt_create>
80109ea8:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109eab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109eae:	83 ec 08             	sub    $0x8,%esp
80109eb1:	50                   	push   %eax
80109eb2:	ff 75 e8             	pushl  -0x18(%ebp)
80109eb5:	e8 26 f0 ff ff       	call   80108ee0 <i8254_send>
80109eba:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ec0:	83 c0 36             	add    $0x36,%eax
80109ec3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ec6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109ec9:	50                   	push   %eax
80109eca:	ff 75 e4             	pushl  -0x1c(%ebp)
80109ecd:	6a 00                	push   $0x0
80109ecf:	6a 00                	push   $0x0
80109ed1:	e8 02 04 00 00       	call   8010a2d8 <http_proc>
80109ed6:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ed9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109edc:	83 ec 0c             	sub    $0xc,%esp
80109edf:	50                   	push   %eax
80109ee0:	6a 18                	push   $0x18
80109ee2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ee5:	50                   	push   %eax
80109ee6:	ff 75 e8             	pushl  -0x18(%ebp)
80109ee9:	ff 75 08             	pushl  0x8(%ebp)
80109eec:	e8 80 00 00 00       	call   80109f71 <tcp_pkt_create>
80109ef1:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109ef4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ef7:	83 ec 08             	sub    $0x8,%esp
80109efa:	50                   	push   %eax
80109efb:	ff 75 e8             	pushl  -0x18(%ebp)
80109efe:	e8 dd ef ff ff       	call   80108ee0 <i8254_send>
80109f03:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f06:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109f0b:	83 c0 01             	add    $0x1,%eax
80109f0e:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109f13:	eb 4a                	jmp    80109f5f <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f18:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f1c:	3c 10                	cmp    $0x10,%al
80109f1e:	75 3f                	jne    80109f5f <tcp_proc+0x1fb>
    if(fin_flag == 1){
80109f20:	a1 48 d3 18 80       	mov    0x8018d348,%eax
80109f25:	83 f8 01             	cmp    $0x1,%eax
80109f28:	75 35                	jne    80109f5f <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f2a:	83 ec 0c             	sub    $0xc,%esp
80109f2d:	6a 00                	push   $0x0
80109f2f:	6a 01                	push   $0x1
80109f31:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f34:	50                   	push   %eax
80109f35:	ff 75 e8             	pushl  -0x18(%ebp)
80109f38:	ff 75 08             	pushl  0x8(%ebp)
80109f3b:	e8 31 00 00 00       	call   80109f71 <tcp_pkt_create>
80109f40:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f46:	83 ec 08             	sub    $0x8,%esp
80109f49:	50                   	push   %eax
80109f4a:	ff 75 e8             	pushl  -0x18(%ebp)
80109f4d:	e8 8e ef ff ff       	call   80108ee0 <i8254_send>
80109f52:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109f55:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
80109f5c:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109f5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f62:	83 ec 0c             	sub    $0xc,%esp
80109f65:	50                   	push   %eax
80109f66:	e8 89 88 ff ff       	call   801027f4 <kfree>
80109f6b:	83 c4 10             	add    $0x10,%esp
}
80109f6e:	90                   	nop
80109f6f:	c9                   	leave  
80109f70:	c3                   	ret    

80109f71 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109f71:	f3 0f 1e fb          	endbr32 
80109f75:	55                   	push   %ebp
80109f76:	89 e5                	mov    %esp,%ebp
80109f78:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109f81:	8b 45 08             	mov    0x8(%ebp),%eax
80109f84:	83 c0 0e             	add    $0xe,%eax
80109f87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f8d:	0f b6 00             	movzbl (%eax),%eax
80109f90:	0f b6 c0             	movzbl %al,%eax
80109f93:	83 e0 0f             	and    $0xf,%eax
80109f96:	c1 e0 02             	shl    $0x2,%eax
80109f99:	89 c2                	mov    %eax,%edx
80109f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f9e:	01 d0                	add    %edx,%eax
80109fa0:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fa6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fac:	83 c0 0e             	add    $0xe,%eax
80109faf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fb5:	83 c0 14             	add    $0x14,%eax
80109fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109fbb:	8b 45 18             	mov    0x18(%ebp),%eax
80109fbe:	8d 50 36             	lea    0x36(%eax),%edx
80109fc1:	8b 45 10             	mov    0x10(%ebp),%eax
80109fc4:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc9:	8d 50 06             	lea    0x6(%eax),%edx
80109fcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fcf:	83 ec 04             	sub    $0x4,%esp
80109fd2:	6a 06                	push   $0x6
80109fd4:	52                   	push   %edx
80109fd5:	50                   	push   %eax
80109fd6:	e8 4a ac ff ff       	call   80104c25 <memmove>
80109fdb:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109fde:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fe1:	83 c0 06             	add    $0x6,%eax
80109fe4:	83 ec 04             	sub    $0x4,%esp
80109fe7:	6a 06                	push   $0x6
80109fe9:	68 68 d0 18 80       	push   $0x8018d068
80109fee:	50                   	push   %eax
80109fef:	e8 31 ac ff ff       	call   80104c25 <memmove>
80109ff4:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109ff7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ffa:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109ffe:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a001:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a005:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a008:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a00b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a00e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a012:	8b 45 18             	mov    0x18(%ebp),%eax
8010a015:	83 c0 28             	add    $0x28,%eax
8010a018:	0f b7 c0             	movzwl %ax,%eax
8010a01b:	83 ec 0c             	sub    $0xc,%esp
8010a01e:	50                   	push   %eax
8010a01f:	e8 6f f8 ff ff       	call   80109893 <H2N_ushort>
8010a024:	83 c4 10             	add    $0x10,%esp
8010a027:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a02a:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a02e:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a035:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a038:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a03c:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a043:	83 c0 01             	add    $0x1,%eax
8010a046:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a04c:	83 ec 0c             	sub    $0xc,%esp
8010a04f:	6a 00                	push   $0x0
8010a051:	e8 3d f8 ff ff       	call   80109893 <H2N_ushort>
8010a056:	83 c4 10             	add    $0x10,%esp
8010a059:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a05c:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a060:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a063:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a067:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a06a:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a06e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a071:	83 c0 0c             	add    $0xc,%eax
8010a074:	83 ec 04             	sub    $0x4,%esp
8010a077:	6a 04                	push   $0x4
8010a079:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a07e:	50                   	push   %eax
8010a07f:	e8 a1 ab ff ff       	call   80104c25 <memmove>
8010a084:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a08a:	8d 50 0c             	lea    0xc(%eax),%edx
8010a08d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a090:	83 c0 10             	add    $0x10,%eax
8010a093:	83 ec 04             	sub    $0x4,%esp
8010a096:	6a 04                	push   $0x4
8010a098:	52                   	push   %edx
8010a099:	50                   	push   %eax
8010a09a:	e8 86 ab ff ff       	call   80104c25 <memmove>
8010a09f:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0a5:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ae:	83 ec 0c             	sub    $0xc,%esp
8010a0b1:	50                   	push   %eax
8010a0b2:	e8 ec f8 ff ff       	call   801099a3 <ipv4_chksum>
8010a0b7:	83 c4 10             	add    $0x10,%esp
8010a0ba:	0f b7 c0             	movzwl %ax,%eax
8010a0bd:	83 ec 0c             	sub    $0xc,%esp
8010a0c0:	50                   	push   %eax
8010a0c1:	e8 cd f7 ff ff       	call   80109893 <H2N_ushort>
8010a0c6:	83 c4 10             	add    $0x10,%esp
8010a0c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0cc:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a0d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0d3:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a0d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0da:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a0dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0e0:	0f b7 10             	movzwl (%eax),%edx
8010a0e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0e6:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a0ea:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a0ef:	83 ec 0c             	sub    $0xc,%esp
8010a0f2:	50                   	push   %eax
8010a0f3:	e8 c1 f7 ff ff       	call   801098b9 <H2N_uint>
8010a0f8:	83 c4 10             	add    $0x10,%esp
8010a0fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a0fe:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a101:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a104:	8b 40 04             	mov    0x4(%eax),%eax
8010a107:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a10d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a110:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a113:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a116:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a11a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a11d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a121:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a124:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a128:	8b 45 14             	mov    0x14(%ebp),%eax
8010a12b:	89 c2                	mov    %eax,%edx
8010a12d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a130:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a133:	83 ec 0c             	sub    $0xc,%esp
8010a136:	68 90 38 00 00       	push   $0x3890
8010a13b:	e8 53 f7 ff ff       	call   80109893 <H2N_ushort>
8010a140:	83 c4 10             	add    $0x10,%esp
8010a143:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a146:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a14a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14d:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a153:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a156:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a15c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a15f:	83 ec 0c             	sub    $0xc,%esp
8010a162:	50                   	push   %eax
8010a163:	e8 1f 00 00 00       	call   8010a187 <tcp_chksum>
8010a168:	83 c4 10             	add    $0x10,%esp
8010a16b:	83 c0 08             	add    $0x8,%eax
8010a16e:	0f b7 c0             	movzwl %ax,%eax
8010a171:	83 ec 0c             	sub    $0xc,%esp
8010a174:	50                   	push   %eax
8010a175:	e8 19 f7 ff ff       	call   80109893 <H2N_ushort>
8010a17a:	83 c4 10             	add    $0x10,%esp
8010a17d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a180:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a184:	90                   	nop
8010a185:	c9                   	leave  
8010a186:	c3                   	ret    

8010a187 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a187:	f3 0f 1e fb          	endbr32 
8010a18b:	55                   	push   %ebp
8010a18c:	89 e5                	mov    %esp,%ebp
8010a18e:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a191:	8b 45 08             	mov    0x8(%ebp),%eax
8010a194:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a197:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a19a:	83 c0 14             	add    $0x14,%eax
8010a19d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a1a0:	83 ec 04             	sub    $0x4,%esp
8010a1a3:	6a 04                	push   $0x4
8010a1a5:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a1aa:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1ad:	50                   	push   %eax
8010a1ae:	e8 72 aa ff ff       	call   80104c25 <memmove>
8010a1b3:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1b9:	83 c0 0c             	add    $0xc,%eax
8010a1bc:	83 ec 04             	sub    $0x4,%esp
8010a1bf:	6a 04                	push   $0x4
8010a1c1:	50                   	push   %eax
8010a1c2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1c5:	83 c0 04             	add    $0x4,%eax
8010a1c8:	50                   	push   %eax
8010a1c9:	e8 57 aa ff ff       	call   80104c25 <memmove>
8010a1ce:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a1d1:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a1d5:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a1d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1dc:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a1e0:	0f b7 c0             	movzwl %ax,%eax
8010a1e3:	83 ec 0c             	sub    $0xc,%esp
8010a1e6:	50                   	push   %eax
8010a1e7:	e8 81 f6 ff ff       	call   8010986d <N2H_ushort>
8010a1ec:	83 c4 10             	add    $0x10,%esp
8010a1ef:	83 e8 14             	sub    $0x14,%eax
8010a1f2:	0f b7 c0             	movzwl %ax,%eax
8010a1f5:	83 ec 0c             	sub    $0xc,%esp
8010a1f8:	50                   	push   %eax
8010a1f9:	e8 95 f6 ff ff       	call   80109893 <H2N_ushort>
8010a1fe:	83 c4 10             	add    $0x10,%esp
8010a201:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a205:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a20c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a20f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a212:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a219:	eb 33                	jmp    8010a24e <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a21b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a21e:	01 c0                	add    %eax,%eax
8010a220:	89 c2                	mov    %eax,%edx
8010a222:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a225:	01 d0                	add    %edx,%eax
8010a227:	0f b6 00             	movzbl (%eax),%eax
8010a22a:	0f b6 c0             	movzbl %al,%eax
8010a22d:	c1 e0 08             	shl    $0x8,%eax
8010a230:	89 c2                	mov    %eax,%edx
8010a232:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a235:	01 c0                	add    %eax,%eax
8010a237:	8d 48 01             	lea    0x1(%eax),%ecx
8010a23a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a23d:	01 c8                	add    %ecx,%eax
8010a23f:	0f b6 00             	movzbl (%eax),%eax
8010a242:	0f b6 c0             	movzbl %al,%eax
8010a245:	01 d0                	add    %edx,%eax
8010a247:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a24a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a24e:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a252:	7e c7                	jle    8010a21b <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a254:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a25a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a261:	eb 33                	jmp    8010a296 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a263:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a266:	01 c0                	add    %eax,%eax
8010a268:	89 c2                	mov    %eax,%edx
8010a26a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a26d:	01 d0                	add    %edx,%eax
8010a26f:	0f b6 00             	movzbl (%eax),%eax
8010a272:	0f b6 c0             	movzbl %al,%eax
8010a275:	c1 e0 08             	shl    $0x8,%eax
8010a278:	89 c2                	mov    %eax,%edx
8010a27a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a27d:	01 c0                	add    %eax,%eax
8010a27f:	8d 48 01             	lea    0x1(%eax),%ecx
8010a282:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a285:	01 c8                	add    %ecx,%eax
8010a287:	0f b6 00             	movzbl (%eax),%eax
8010a28a:	0f b6 c0             	movzbl %al,%eax
8010a28d:	01 d0                	add    %edx,%eax
8010a28f:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a292:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a296:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a29a:	0f b7 c0             	movzwl %ax,%eax
8010a29d:	83 ec 0c             	sub    $0xc,%esp
8010a2a0:	50                   	push   %eax
8010a2a1:	e8 c7 f5 ff ff       	call   8010986d <N2H_ushort>
8010a2a6:	83 c4 10             	add    $0x10,%esp
8010a2a9:	66 d1 e8             	shr    %ax
8010a2ac:	0f b7 c0             	movzwl %ax,%eax
8010a2af:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a2b2:	7c af                	jl     8010a263 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a2b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2b7:	c1 e8 10             	shr    $0x10,%eax
8010a2ba:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a2bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2c0:	f7 d0                	not    %eax
}
8010a2c2:	c9                   	leave  
8010a2c3:	c3                   	ret    

8010a2c4 <tcp_fin>:

void tcp_fin(){
8010a2c4:	f3 0f 1e fb          	endbr32 
8010a2c8:	55                   	push   %ebp
8010a2c9:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a2cb:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a2d2:	00 00 00 
}
8010a2d5:	90                   	nop
8010a2d6:	5d                   	pop    %ebp
8010a2d7:	c3                   	ret    

8010a2d8 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a2d8:	f3 0f 1e fb          	endbr32 
8010a2dc:	55                   	push   %ebp
8010a2dd:	89 e5                	mov    %esp,%ebp
8010a2df:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a2e2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2e5:	83 ec 04             	sub    $0x4,%esp
8010a2e8:	6a 00                	push   $0x0
8010a2ea:	68 eb c4 10 80       	push   $0x8010c4eb
8010a2ef:	50                   	push   %eax
8010a2f0:	e8 65 00 00 00       	call   8010a35a <http_strcpy>
8010a2f5:	83 c4 10             	add    $0x10,%esp
8010a2f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a2fb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2fe:	83 ec 04             	sub    $0x4,%esp
8010a301:	ff 75 f4             	pushl  -0xc(%ebp)
8010a304:	68 fe c4 10 80       	push   $0x8010c4fe
8010a309:	50                   	push   %eax
8010a30a:	e8 4b 00 00 00       	call   8010a35a <http_strcpy>
8010a30f:	83 c4 10             	add    $0x10,%esp
8010a312:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a315:	8b 45 10             	mov    0x10(%ebp),%eax
8010a318:	83 ec 04             	sub    $0x4,%esp
8010a31b:	ff 75 f4             	pushl  -0xc(%ebp)
8010a31e:	68 19 c5 10 80       	push   $0x8010c519
8010a323:	50                   	push   %eax
8010a324:	e8 31 00 00 00       	call   8010a35a <http_strcpy>
8010a329:	83 c4 10             	add    $0x10,%esp
8010a32c:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a32f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a332:	83 e0 01             	and    $0x1,%eax
8010a335:	85 c0                	test   %eax,%eax
8010a337:	74 11                	je     8010a34a <http_proc+0x72>
    char *payload = (char *)send;
8010a339:	8b 45 10             	mov    0x10(%ebp),%eax
8010a33c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a33f:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a342:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a345:	01 d0                	add    %edx,%eax
8010a347:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a34a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a34d:	8b 45 14             	mov    0x14(%ebp),%eax
8010a350:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a352:	e8 6d ff ff ff       	call   8010a2c4 <tcp_fin>
}
8010a357:	90                   	nop
8010a358:	c9                   	leave  
8010a359:	c3                   	ret    

8010a35a <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a35a:	f3 0f 1e fb          	endbr32 
8010a35e:	55                   	push   %ebp
8010a35f:	89 e5                	mov    %esp,%ebp
8010a361:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a364:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a36b:	eb 20                	jmp    8010a38d <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a36d:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a370:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a373:	01 d0                	add    %edx,%eax
8010a375:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a378:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a37b:	01 ca                	add    %ecx,%edx
8010a37d:	89 d1                	mov    %edx,%ecx
8010a37f:	8b 55 08             	mov    0x8(%ebp),%edx
8010a382:	01 ca                	add    %ecx,%edx
8010a384:	0f b6 00             	movzbl (%eax),%eax
8010a387:	88 02                	mov    %al,(%edx)
    i++;
8010a389:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a38d:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a390:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a393:	01 d0                	add    %edx,%eax
8010a395:	0f b6 00             	movzbl (%eax),%eax
8010a398:	84 c0                	test   %al,%al
8010a39a:	75 d1                	jne    8010a36d <http_strcpy+0x13>
  }
  return i;
8010a39c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a39f:	c9                   	leave  
8010a3a0:	c3                   	ret    

8010a3a1 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a3a1:	f3 0f 1e fb          	endbr32 
8010a3a5:	55                   	push   %ebp
8010a3a6:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a3a8:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a3af:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a3b2:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a3b7:	c1 e8 09             	shr    $0x9,%eax
8010a3ba:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a3bf:	90                   	nop
8010a3c0:	5d                   	pop    %ebp
8010a3c1:	c3                   	ret    

8010a3c2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a3c2:	f3 0f 1e fb          	endbr32 
8010a3c6:	55                   	push   %ebp
8010a3c7:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a3c9:	90                   	nop
8010a3ca:	5d                   	pop    %ebp
8010a3cb:	c3                   	ret    

8010a3cc <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a3cc:	f3 0f 1e fb          	endbr32 
8010a3d0:	55                   	push   %ebp
8010a3d1:	89 e5                	mov    %esp,%ebp
8010a3d3:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a3d6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3d9:	83 c0 0c             	add    $0xc,%eax
8010a3dc:	83 ec 0c             	sub    $0xc,%esp
8010a3df:	50                   	push   %eax
8010a3e0:	e8 51 a4 ff ff       	call   80104836 <holdingsleep>
8010a3e5:	83 c4 10             	add    $0x10,%esp
8010a3e8:	85 c0                	test   %eax,%eax
8010a3ea:	75 0d                	jne    8010a3f9 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a3ec:	83 ec 0c             	sub    $0xc,%esp
8010a3ef:	68 2a c5 10 80       	push   $0x8010c52a
8010a3f4:	e8 cc 61 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a3f9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3fc:	8b 00                	mov    (%eax),%eax
8010a3fe:	83 e0 06             	and    $0x6,%eax
8010a401:	83 f8 02             	cmp    $0x2,%eax
8010a404:	75 0d                	jne    8010a413 <iderw+0x47>
    panic("iderw: nothing to do");
8010a406:	83 ec 0c             	sub    $0xc,%esp
8010a409:	68 40 c5 10 80       	push   $0x8010c540
8010a40e:	e8 b2 61 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a413:	8b 45 08             	mov    0x8(%ebp),%eax
8010a416:	8b 40 04             	mov    0x4(%eax),%eax
8010a419:	83 f8 01             	cmp    $0x1,%eax
8010a41c:	74 0d                	je     8010a42b <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a41e:	83 ec 0c             	sub    $0xc,%esp
8010a421:	68 55 c5 10 80       	push   $0x8010c555
8010a426:	e8 9a 61 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a42b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a42e:	8b 40 08             	mov    0x8(%eax),%eax
8010a431:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a437:	39 d0                	cmp    %edx,%eax
8010a439:	72 0d                	jb     8010a448 <iderw+0x7c>
    panic("iderw: block out of range");
8010a43b:	83 ec 0c             	sub    $0xc,%esp
8010a43e:	68 73 c5 10 80       	push   $0x8010c573
8010a443:	e8 7d 61 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a448:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a44e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a451:	8b 40 08             	mov    0x8(%eax),%eax
8010a454:	c1 e0 09             	shl    $0x9,%eax
8010a457:	01 d0                	add    %edx,%eax
8010a459:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a45c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a45f:	8b 00                	mov    (%eax),%eax
8010a461:	83 e0 04             	and    $0x4,%eax
8010a464:	85 c0                	test   %eax,%eax
8010a466:	74 2b                	je     8010a493 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a468:	8b 45 08             	mov    0x8(%ebp),%eax
8010a46b:	8b 00                	mov    (%eax),%eax
8010a46d:	83 e0 fb             	and    $0xfffffffb,%eax
8010a470:	89 c2                	mov    %eax,%edx
8010a472:	8b 45 08             	mov    0x8(%ebp),%eax
8010a475:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a477:	8b 45 08             	mov    0x8(%ebp),%eax
8010a47a:	83 c0 5c             	add    $0x5c,%eax
8010a47d:	83 ec 04             	sub    $0x4,%esp
8010a480:	68 00 02 00 00       	push   $0x200
8010a485:	50                   	push   %eax
8010a486:	ff 75 f4             	pushl  -0xc(%ebp)
8010a489:	e8 97 a7 ff ff       	call   80104c25 <memmove>
8010a48e:	83 c4 10             	add    $0x10,%esp
8010a491:	eb 1a                	jmp    8010a4ad <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a493:	8b 45 08             	mov    0x8(%ebp),%eax
8010a496:	83 c0 5c             	add    $0x5c,%eax
8010a499:	83 ec 04             	sub    $0x4,%esp
8010a49c:	68 00 02 00 00       	push   $0x200
8010a4a1:	ff 75 f4             	pushl  -0xc(%ebp)
8010a4a4:	50                   	push   %eax
8010a4a5:	e8 7b a7 ff ff       	call   80104c25 <memmove>
8010a4aa:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a4ad:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4b0:	8b 00                	mov    (%eax),%eax
8010a4b2:	83 c8 02             	or     $0x2,%eax
8010a4b5:	89 c2                	mov    %eax,%edx
8010a4b7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ba:	89 10                	mov    %edx,(%eax)
}
8010a4bc:	90                   	nop
8010a4bd:	c9                   	leave  
8010a4be:	c3                   	ret    
