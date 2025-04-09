
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
80100073:	68 a0 a4 10 80       	push   $0x8010a4a0
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
801000c1:	68 a7 a4 10 80       	push   $0x8010a4a7
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
801001fd:	68 ae a4 10 80       	push   $0x8010a4ae
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
80100239:	e8 67 a1 00 00       	call   8010a3a5 <iderw>
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
80100269:	68 bf a4 10 80       	push   $0x8010a4bf
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
80100288:	e8 18 a1 00 00       	call   8010a3a5 <iderw>
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
801002b6:	68 c6 a4 10 80       	push   $0x8010a4c6
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
8010043e:	68 cd a4 10 80       	push   $0x8010a4cd
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
8010052c:	c7 45 ec d6 a4 10 80 	movl   $0x8010a4d6,-0x14(%ebp)
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
801005e7:	68 dd a4 10 80       	push   $0x8010a4dd
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
80100606:	68 f1 a4 10 80       	push   $0x8010a4f1
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
8010063a:	68 f3 a4 10 80       	push   $0x8010a4f3
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
801006c4:	e8 70 7b 00 00       	call   80108239 <graphic_scroll_up>
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
80100717:	e8 1d 7b 00 00       	call   80108239 <graphic_scroll_up>
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
8010077d:	e8 2b 7b 00 00       	call   801082ad <font_render>
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
801007bd:	e8 8b 5e 00 00       	call   8010664d <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 7e 5e 00 00       	call   8010664d <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 71 5e 00 00       	call   8010664d <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 61 5e 00 00       	call   8010664d <uartputc>
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
80100b50:	68 f7 a4 10 80       	push   $0x8010a4f7
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
80100b76:	c7 45 f4 ff a4 10 80 	movl   $0x8010a4ff,-0xc(%ebp)
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
80100bf7:	68 15 a5 10 80       	push   $0x8010a515
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
80100c53:	e8 09 6a 00 00       	call   80107661 <setupkvm>
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
80100cf9:	e8 75 6d 00 00       	call   80107a73 <allocuvm>
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
80100d3f:	e8 5e 6c 00 00       	call   801079a2 <loaduvm>
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
80100dae:	e8 c0 6c 00 00       	call   80107a73 <allocuvm>
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
80100dd2:	e8 0a 6f 00 00       	call   80107ce1 <clearpteu>
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
80100e5e:	e8 29 70 00 00       	call   80107e8c <copyout>
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
80100efa:	e8 8d 6f 00 00       	call   80107e8c <copyout>
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
80100f8b:	e8 fb 67 00 00       	call   8010778b <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 a6 6c 00 00       	call   80107c44 <freevm>
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
80100fd9:	e8 66 6c 00 00       	call   80107c44 <freevm>
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
8010100e:	68 21 a5 10 80       	push   $0x8010a521
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
801010bb:	68 28 a5 10 80       	push   $0x8010a528
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
80101110:	68 30 a5 10 80       	push   $0x8010a530
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
801012e0:	68 3a a5 10 80       	push   $0x8010a53a
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
801013e7:	68 43 a5 10 80       	push   $0x8010a543
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
8010141d:	68 53 a5 10 80       	push   $0x8010a553
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
8010160e:	68 60 a5 10 80       	push   $0x8010a560
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
801016a5:	68 76 a5 10 80       	push   $0x8010a576
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
8010170d:	68 89 a5 10 80       	push   $0x8010a589
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
80101743:	68 90 a5 10 80       	push   $0x8010a590
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
801017a2:	68 98 a5 10 80       	push   $0x8010a598
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
80101887:	68 eb a5 10 80       	push   $0x8010a5eb
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
801019f4:	68 fd a5 10 80       	push   $0x8010a5fd
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
80101a99:	68 0d a6 10 80       	push   $0x8010a60d
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
80101b86:	68 13 a6 10 80       	push   $0x8010a613
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
80101bc6:	68 22 a6 10 80       	push   $0x8010a622
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
80101dfa:	68 2a a6 10 80       	push   $0x8010a62a
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
801022a0:	68 3d a6 10 80       	push   $0x8010a63d
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
801022cf:	68 4f a6 10 80       	push   $0x8010a64f
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
801023a8:	68 5e a6 10 80       	push   $0x8010a65e
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
8010240f:	68 6b a6 10 80       	push   $0x8010a66b
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
801026ab:	68 74 a6 10 80       	push   $0x8010a674
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
8010275a:	68 a6 a6 10 80       	push   $0x8010a6a6
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
80102825:	68 ab a6 10 80       	push   $0x8010a6ab
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
80102f4b:	68 b1 a6 10 80       	push   $0x8010a6b1
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
8010323b:	68 b5 a6 10 80       	push   $0x8010a6b5
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
801033e3:	68 c4 a6 10 80       	push   $0x8010a6c4
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 da a6 10 80       	push   $0x8010a6da
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
801034c3:	e8 ad 4c 00 00       	call   80108175 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 70 42 00 00       	call   80107752 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 47 4a 00 00       	call   80107f2e <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 e8 3c 00 00       	call   801071d9 <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 5d 30 00 00       	call   80106562 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 14 2b 00 00       	call   80106023 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 5c 6e 00 00       	call   8010a37a <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 ab 4e 00 00       	call   801083e8 <pci_init>
  arp_scan();
8010353d:	e8 24 5c 00 00       	call   80109166 <arp_scan>
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
80103556:	e8 13 42 00 00       	call   8010776e <switchkvm>
  seginit();
8010355b:	e8 79 3c 00 00       	call   801071d9 <seginit>
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
80103586:	68 f5 a6 10 80       	push   $0x8010a6f5
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
80103768:	68 09 a7 10 80       	push   $0x8010a709
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
80103af9:	68 10 a7 10 80       	push   $0x8010a710
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
80103b48:	68 18 a7 10 80       	push   $0x8010a718
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
80103b9d:	68 3e a7 10 80       	push   $0x8010a73e
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
80103d06:	e8 56 39 00 00       	call   80107661 <setupkvm>
80103d0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d0e:	89 42 04             	mov    %eax,0x4(%edx)
80103d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d14:	8b 40 04             	mov    0x4(%eax),%eax
80103d17:	85 c0                	test   %eax,%eax
80103d19:	75 0d                	jne    80103d28 <userinit+0x3c>
    panic("userinit: out of memory?");
80103d1b:	83 ec 0c             	sub    $0xc,%esp
80103d1e:	68 4e a7 10 80       	push   $0x8010a74e
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
80103d3d:	e8 ec 3b 00 00       	call   8010792e <inituvm>
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
80103dd6:	68 67 a7 10 80       	push   $0x8010a767
80103ddb:	50                   	push   %eax
80103ddc:	e8 98 0f 00 00       	call   80104d79 <safestrcpy>
80103de1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103de4:	83 ec 0c             	sub    $0xc,%esp
80103de7:	68 70 a7 10 80       	push   $0x8010a770
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
80103e5d:	e8 11 3c 00 00       	call   80107a73 <allocuvm>
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
80103e91:	e8 e6 3c 00 00       	call   80107b7c <deallocuvm>
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
80103eb7:	e8 cf 38 00 00       	call   8010778b <switchuvm>
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
80103f03:	e8 1e 3e 00 00       	call   80107d26 <copyuvm>
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
80104062:	68 72 a7 10 80       	push   $0x8010a772
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
8010415d:	68 7f a7 10 80       	push   $0x8010a77f
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
801041ec:	e8 53 3a 00 00       	call   80107c44 <freevm>
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
801042e5:	e8 a1 34 00 00       	call   8010778b <switchuvm>
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
80104310:	e8 59 34 00 00       	call   8010776e <switchkvm>

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
80104370:	68 8b a7 10 80       	push   $0x8010a78b
80104375:	e8 4b c2 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
8010437a:	e8 ae f7 ff ff       	call   80103b2d <mycpu>
8010437f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104385:	83 f8 01             	cmp    $0x1,%eax
80104388:	74 0d                	je     80104397 <sched+0x50>
    panic("sched locks");
8010438a:	83 ec 0c             	sub    $0xc,%esp
8010438d:	68 9d a7 10 80       	push   $0x8010a79d
80104392:	e8 2e c2 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439a:	8b 40 0c             	mov    0xc(%eax),%eax
8010439d:	83 f8 04             	cmp    $0x4,%eax
801043a0:	75 0d                	jne    801043af <sched+0x68>
    panic("sched running");
801043a2:	83 ec 0c             	sub    $0xc,%esp
801043a5:	68 a9 a7 10 80       	push   $0x8010a7a9
801043aa:	e8 16 c2 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
801043af:	e8 21 f7 ff ff       	call   80103ad5 <readeflags>
801043b4:	25 00 02 00 00       	and    $0x200,%eax
801043b9:	85 c0                	test   %eax,%eax
801043bb:	74 0d                	je     801043ca <sched+0x83>
    panic("sched interruptible");
801043bd:	83 ec 0c             	sub    $0xc,%esp
801043c0:	68 b7 a7 10 80       	push   $0x8010a7b7
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
801044a7:	68 cb a7 10 80       	push   $0x8010a7cb
801044ac:	e8 14 c1 ff ff       	call   801005c5 <panic>

  if(lk == 0)
801044b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044b5:	75 0d                	jne    801044c4 <sleep+0x38>
    panic("sleep without lk");
801044b7:	83 ec 0c             	sub    $0xc,%esp
801044ba:	68 d1 a7 10 80       	push   $0x8010a7d1
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
80104690:	c7 45 ec e2 a7 10 80 	movl   $0x8010a7e2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010469a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010469d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a0:	8b 40 10             	mov    0x10(%eax),%eax
801046a3:	52                   	push   %edx
801046a4:	ff 75 ec             	pushl  -0x14(%ebp)
801046a7:	50                   	push   %eax
801046a8:	68 e6 a7 10 80       	push   $0x8010a7e6
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
801046f2:	68 ef a7 10 80       	push   $0x8010a7ef
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
80104717:	68 f3 a7 10 80       	push   $0x8010a7f3
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
8010474f:	68 1f a8 10 80       	push   $0x8010a81f
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
801048f5:	68 2a a8 10 80       	push   $0x8010a82a
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
80104960:	68 32 a8 10 80       	push   $0x8010a832
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
80104ab7:	68 3a a8 10 80       	push   $0x8010a83a
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
80104ae2:	68 51 a8 10 80       	push   $0x8010a851
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
80104fee:	68 58 a8 10 80       	push   $0x8010a858
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
8010548e:	68 74 a8 10 80       	push   $0x8010a874
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
8010552f:	68 86 a8 10 80       	push   $0x8010a886
80105534:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105537:	50                   	push   %eax
80105538:	e8 2a cd ff ff       	call   80102267 <namecmp>
8010553d:	83 c4 10             	add    $0x10,%esp
80105540:	85 c0                	test   %eax,%eax
80105542:	0f 84 49 01 00 00    	je     80105691 <sys_unlink+0x1cc>
80105548:	83 ec 08             	sub    $0x8,%esp
8010554b:	68 88 a8 10 80       	push   $0x8010a888
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
801055a4:	68 8b a8 10 80       	push   $0x8010a88b
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
80105610:	68 9d a8 10 80       	push   $0x8010a89d
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
80105792:	68 ac a8 10 80       	push   $0x8010a8ac
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
80105809:	68 86 a8 10 80       	push   $0x8010a886
8010580e:	ff 75 f0             	pushl  -0x10(%ebp)
80105811:	e8 2e cb ff ff       	call   80102344 <dirlink>
80105816:	83 c4 10             	add    $0x10,%esp
80105819:	85 c0                	test   %eax,%eax
8010581b:	78 1e                	js     8010583b <create+0x18c>
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	8b 40 04             	mov    0x4(%eax),%eax
80105823:	83 ec 04             	sub    $0x4,%esp
80105826:	50                   	push   %eax
80105827:	68 88 a8 10 80       	push   $0x8010a888
8010582c:	ff 75 f0             	pushl  -0x10(%ebp)
8010582f:	e8 10 cb ff ff       	call   80102344 <dirlink>
80105834:	83 c4 10             	add    $0x10,%esp
80105837:	85 c0                	test   %eax,%eax
80105839:	79 0d                	jns    80105848 <create+0x199>
      panic("create dots");
8010583b:	83 ec 0c             	sub    $0xc,%esp
8010583e:	68 bb a8 10 80       	push   $0x8010a8bb
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
80105868:	68 c7 a8 10 80       	push   $0x8010a8c7
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
80105f82:	68 d8 a8 10 80       	push   $0x8010a8d8
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
80106188:	68 14 a9 10 80       	push   $0x8010a914
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
801061fc:	0f 84 19 03 00 00    	je     8010651b <trap+0x362>
            exit();
80106202:	e8 3c de ff ff       	call   80104043 <exit>
        return;
80106207:	e9 0f 03 00 00       	jmp    8010651b <trap+0x362>
    }

    switch (tf->trapno) {
8010620c:	8b 45 08             	mov    0x8(%ebp),%eax
8010620f:	8b 40 30             	mov    0x30(%eax),%eax
80106212:	83 e8 20             	sub    $0x20,%eax
80106215:	83 f8 1f             	cmp    $0x1f,%eax
80106218:	0f 87 c5 01 00 00    	ja     801063e3 <trap+0x22a>
8010621e:	8b 04 85 f4 a9 10 80 	mov    -0x7fef560c(,%eax,4),%eax
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
8010627f:	0f 84 97 00 00 00    	je     8010631c <trap+0x163>
80106285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106288:	8b 40 0c             	mov    0xc(%eax),%eax
8010628b:	83 f8 04             	cmp    $0x4,%eax
8010628e:	0f 85 88 00 00 00    	jne    8010631c <trap+0x163>
80106294:	8b 45 08             	mov    0x8(%ebp),%eax
80106297:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010629b:	0f b7 c0             	movzwl %ax,%eax
8010629e:	83 e0 03             	and    $0x3,%eax
801062a1:	83 f8 03             	cmp    $0x3,%eax
801062a4:	75 76                	jne    8010631c <trap+0x163>
801062a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062a9:	8b 40 7c             	mov    0x7c(%eax),%eax
801062ac:	85 c0                	test   %eax,%eax
801062ae:	74 6c                	je     8010631c <trap+0x163>
            // 사용자 모드 실행 중, RUNNING 상태, 스케줄러 등록됨 -> 사용자 수준 선점 시도
            uint original_eip = tf->eip;
801062b0:	8b 45 08             	mov    0x8(%ebp),%eax
801062b3:	8b 40 38             	mov    0x38(%eax),%eax
801062b6:	89 45 dc             	mov    %eax,-0x24(%ebp)
            uint user_esp = tf->esp;
801062b9:	8b 45 08             	mov    0x8(%ebp),%eax
801062bc:	8b 40 44             	mov    0x44(%eax),%eax
801062bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
            user_esp -= 4; // 복귀 주소 저장 공간 확보               
801062c2:	83 6d e0 04          	subl   $0x4,-0x20(%ebp)

            if (copyout(p->pgdir, user_esp, &original_eip, sizeof(original_eip)) < 0) {
801062c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062c9:	8b 40 04             	mov    0x4(%eax),%eax
801062cc:	6a 04                	push   $0x4
801062ce:	8d 55 dc             	lea    -0x24(%ebp),%edx
801062d1:	52                   	push   %edx
801062d2:	ff 75 e0             	pushl  -0x20(%ebp)
801062d5:	50                   	push   %eax
801062d6:	e8 b1 1b 00 00       	call   80107e8c <copyout>
801062db:	83 c4 10             	add    $0x10,%esp
801062de:	85 c0                	test   %eax,%eax
801062e0:	79 23                	jns    80106305 <trap+0x14c>
                // copyout 실패 시 오류 처리
                cprintf("KERN_ERR: trap.c: copyout failed for EIP save, pid=%d\n", p->pid);
801062e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e5:	8b 40 10             	mov    0x10(%eax),%eax
801062e8:	83 ec 08             	sub    $0x8,%esp
801062eb:	50                   	push   %eax
801062ec:	68 1c a9 10 80       	push   $0x8010a91c
801062f1:	e8 16 a1 ff ff       	call   8010040c <cprintf>
801062f6:	83 c4 10             	add    $0x10,%esp
                p->killed = 1;
801062f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062fc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106303:	eb 17                	jmp    8010631c <trap+0x163>
                // 오류 발생 시 아래의 표준 종료/양보 로직으로 넘어감
            }
            else {
                // copyout 성공 시: 트랩 프레임 수정하여 스케줄러로 점프 준비
                tf->esp = user_esp;
80106305:	8b 45 08             	mov    0x8(%ebp),%eax
80106308:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010630b:	89 50 44             	mov    %edx,0x44(%eax)
                tf->eip = p->scheduler;
8010630e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106311:	8b 50 7c             	mov    0x7c(%eax),%edx
80106314:	8b 45 08             	mov    0x8(%ebp),%eax
80106317:	89 50 38             	mov    %edx,0x38(%eax)
8010631a:	eb 24                	jmp    80106340 <trap+0x187>
            }
        }

        // 사용자 스케줄러가 호출되지 않은 경우 (커널 모드, 스케줄러 미등록 등)
        // 또는 copyout이 실패한 경우, 기존 커널 수준 yield 실행
        if (p && p->state == RUNNING && tf->trapno == T_IRQ0 + IRQ_TIMER) {
8010631c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106320:	74 1d                	je     8010633f <trap+0x186>
80106322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106325:	8b 40 0c             	mov    0xc(%eax),%eax
80106328:	83 f8 04             	cmp    $0x4,%eax
8010632b:	75 12                	jne    8010633f <trap+0x186>
8010632d:	8b 45 08             	mov    0x8(%ebp),%eax
80106330:	8b 40 30             	mov    0x30(%eax),%eax
80106333:	83 f8 20             	cmp    $0x20,%eax
80106336:	75 07                	jne    8010633f <trap+0x186>
            yield();
80106338:	e8 c7 e0 ff ff       	call   80104404 <yield>
8010633d:	eb 01                	jmp    80106340 <trap+0x187>
        }

    check_exit: // goto 타겟 레이블
8010633f:	90                   	nop
        // 프로세스 종료 여부 확인 (공통 로직)
        if (p && p->killed && (tf->cs & 3) == DPL_USER)
80106340:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106344:	0f 84 50 01 00 00    	je     8010649a <trap+0x2e1>
8010634a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010634d:	8b 40 24             	mov    0x24(%eax),%eax
80106350:	85 c0                	test   %eax,%eax
80106352:	0f 84 42 01 00 00    	je     8010649a <trap+0x2e1>
80106358:	8b 45 08             	mov    0x8(%ebp),%eax
8010635b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010635f:	0f b7 c0             	movzwl %ax,%eax
80106362:	83 e0 03             	and    $0x3,%eax
80106365:	83 f8 03             	cmp    $0x3,%eax
80106368:	0f 85 2c 01 00 00    	jne    8010649a <trap+0x2e1>
            exit();
8010636e:	e8 d0 dc ff ff       	call   80104043 <exit>
        
        break;
80106373:	e9 22 01 00 00       	jmp    8010649a <trap+0x2e1>
    case T_IRQ0 + IRQ_IDE:
        ideintr();
80106378:	e8 1e 40 00 00       	call   8010a39b <ideintr>
        lapiceoi();
8010637d:	e8 a3 c8 ff ff       	call   80102c25 <lapiceoi>
        break;
80106382:	e9 14 01 00 00       	jmp    8010649b <trap+0x2e2>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
80106387:	e8 cf c6 ff ff       	call   80102a5b <kbdintr>
        lapiceoi();
8010638c:	e8 94 c8 ff ff       	call   80102c25 <lapiceoi>
        break;
80106391:	e9 05 01 00 00       	jmp    8010649b <trap+0x2e2>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
80106396:	e8 62 03 00 00       	call   801066fd <uartintr>
        lapiceoi();
8010639b:	e8 85 c8 ff ff       	call   80102c25 <lapiceoi>
        break;
801063a0:	e9 f6 00 00 00       	jmp    8010649b <trap+0x2e2>
    case T_IRQ0 + 0xB:
        i8254_intr();
801063a5:	e8 30 2c 00 00       	call   80108fda <i8254_intr>
        lapiceoi();
801063aa:	e8 76 c8 ff ff       	call   80102c25 <lapiceoi>
        break;
801063af:	e9 e7 00 00 00       	jmp    8010649b <trap+0x2e2>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063b4:	8b 45 08             	mov    0x8(%ebp),%eax
801063b7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801063ba:	8b 45 08             	mov    0x8(%ebp),%eax
801063bd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063c1:	0f b7 d8             	movzwl %ax,%ebx
801063c4:	e8 45 d7 ff ff       	call   80103b0e <cpuid>
801063c9:	56                   	push   %esi
801063ca:	53                   	push   %ebx
801063cb:	50                   	push   %eax
801063cc:	68 54 a9 10 80       	push   $0x8010a954
801063d1:	e8 36 a0 ff ff       	call   8010040c <cprintf>
801063d6:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
801063d9:	e8 47 c8 ff ff       	call   80102c25 <lapiceoi>
        break;
801063de:	e9 b8 00 00 00       	jmp    8010649b <trap+0x2e2>

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
801063e3:	e8 c1 d7 ff ff       	call   80103ba9 <myproc>
801063e8:	85 c0                	test   %eax,%eax
801063ea:	74 11                	je     801063fd <trap+0x244>
801063ec:	8b 45 08             	mov    0x8(%ebp),%eax
801063ef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801063f3:	0f b7 c0             	movzwl %ax,%eax
801063f6:	83 e0 03             	and    $0x3,%eax
801063f9:	85 c0                	test   %eax,%eax
801063fb:	75 39                	jne    80106436 <trap+0x27d>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801063fd:	e8 10 fc ff ff       	call   80106012 <rcr2>
80106402:	89 c3                	mov    %eax,%ebx
80106404:	8b 45 08             	mov    0x8(%ebp),%eax
80106407:	8b 70 38             	mov    0x38(%eax),%esi
8010640a:	e8 ff d6 ff ff       	call   80103b0e <cpuid>
8010640f:	8b 55 08             	mov    0x8(%ebp),%edx
80106412:	8b 52 30             	mov    0x30(%edx),%edx
80106415:	83 ec 0c             	sub    $0xc,%esp
80106418:	53                   	push   %ebx
80106419:	56                   	push   %esi
8010641a:	50                   	push   %eax
8010641b:	52                   	push   %edx
8010641c:	68 78 a9 10 80       	push   $0x8010a978
80106421:	e8 e6 9f ff ff       	call   8010040c <cprintf>
80106426:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
80106429:	83 ec 0c             	sub    $0xc,%esp
8010642c:	68 aa a9 10 80       	push   $0x8010a9aa
80106431:	e8 8f a1 ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106436:	e8 d7 fb ff ff       	call   80106012 <rcr2>
8010643b:	89 c6                	mov    %eax,%esi
8010643d:	8b 45 08             	mov    0x8(%ebp),%eax
80106440:	8b 40 38             	mov    0x38(%eax),%eax
80106443:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106446:	e8 c3 d6 ff ff       	call   80103b0e <cpuid>
8010644b:	89 c3                	mov    %eax,%ebx
8010644d:	8b 45 08             	mov    0x8(%ebp),%eax
80106450:	8b 48 34             	mov    0x34(%eax),%ecx
80106453:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106456:	8b 45 08             	mov    0x8(%ebp),%eax
80106459:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010645c:	e8 48 d7 ff ff       	call   80103ba9 <myproc>
80106461:	8d 50 6c             	lea    0x6c(%eax),%edx
80106464:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106467:	e8 3d d7 ff ff       	call   80103ba9 <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
8010646c:	8b 40 10             	mov    0x10(%eax),%eax
8010646f:	56                   	push   %esi
80106470:	ff 75 d4             	pushl  -0x2c(%ebp)
80106473:	53                   	push   %ebx
80106474:	ff 75 d0             	pushl  -0x30(%ebp)
80106477:	57                   	push   %edi
80106478:	ff 75 cc             	pushl  -0x34(%ebp)
8010647b:	50                   	push   %eax
8010647c:	68 b0 a9 10 80       	push   $0x8010a9b0
80106481:	e8 86 9f ff ff       	call   8010040c <cprintf>
80106486:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
80106489:	e8 1b d7 ff ff       	call   80103ba9 <myproc>
8010648e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106495:	eb 04                	jmp    8010649b <trap+0x2e2>
        break;
80106497:	90                   	nop
80106498:	eb 01                	jmp    8010649b <trap+0x2e2>
        break;
8010649a:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
8010649b:	e8 09 d7 ff ff       	call   80103ba9 <myproc>
801064a0:	85 c0                	test   %eax,%eax
801064a2:	74 23                	je     801064c7 <trap+0x30e>
801064a4:	e8 00 d7 ff ff       	call   80103ba9 <myproc>
801064a9:	8b 40 24             	mov    0x24(%eax),%eax
801064ac:	85 c0                	test   %eax,%eax
801064ae:	74 17                	je     801064c7 <trap+0x30e>
801064b0:	8b 45 08             	mov    0x8(%ebp),%eax
801064b3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064b7:	0f b7 c0             	movzwl %ax,%eax
801064ba:	83 e0 03             	and    $0x3,%eax
801064bd:	83 f8 03             	cmp    $0x3,%eax
801064c0:	75 05                	jne    801064c7 <trap+0x30e>
        exit();
801064c2:	e8 7c db ff ff       	call   80104043 <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
801064c7:	e8 dd d6 ff ff       	call   80103ba9 <myproc>
801064cc:	85 c0                	test   %eax,%eax
801064ce:	74 1d                	je     801064ed <trap+0x334>
801064d0:	e8 d4 d6 ff ff       	call   80103ba9 <myproc>
801064d5:	8b 40 0c             	mov    0xc(%eax),%eax
801064d8:	83 f8 04             	cmp    $0x4,%eax
801064db:	75 10                	jne    801064ed <trap+0x334>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
801064dd:	8b 45 08             	mov    0x8(%ebp),%eax
801064e0:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
801064e3:	83 f8 20             	cmp    $0x20,%eax
801064e6:	75 05                	jne    801064ed <trap+0x334>
        yield();
801064e8:	e8 17 df ff ff       	call   80104404 <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
801064ed:	e8 b7 d6 ff ff       	call   80103ba9 <myproc>
801064f2:	85 c0                	test   %eax,%eax
801064f4:	74 26                	je     8010651c <trap+0x363>
801064f6:	e8 ae d6 ff ff       	call   80103ba9 <myproc>
801064fb:	8b 40 24             	mov    0x24(%eax),%eax
801064fe:	85 c0                	test   %eax,%eax
80106500:	74 1a                	je     8010651c <trap+0x363>
80106502:	8b 45 08             	mov    0x8(%ebp),%eax
80106505:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106509:	0f b7 c0             	movzwl %ax,%eax
8010650c:	83 e0 03             	and    $0x3,%eax
8010650f:	83 f8 03             	cmp    $0x3,%eax
80106512:	75 08                	jne    8010651c <trap+0x363>
        exit();
80106514:	e8 2a db ff ff       	call   80104043 <exit>
80106519:	eb 01                	jmp    8010651c <trap+0x363>
        return;
8010651b:	90                   	nop
}
8010651c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010651f:	5b                   	pop    %ebx
80106520:	5e                   	pop    %esi
80106521:	5f                   	pop    %edi
80106522:	5d                   	pop    %ebp
80106523:	c3                   	ret    

80106524 <inb>:
{
80106524:	55                   	push   %ebp
80106525:	89 e5                	mov    %esp,%ebp
80106527:	83 ec 14             	sub    $0x14,%esp
8010652a:	8b 45 08             	mov    0x8(%ebp),%eax
8010652d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106531:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106535:	89 c2                	mov    %eax,%edx
80106537:	ec                   	in     (%dx),%al
80106538:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010653b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010653f:	c9                   	leave  
80106540:	c3                   	ret    

80106541 <outb>:
{
80106541:	55                   	push   %ebp
80106542:	89 e5                	mov    %esp,%ebp
80106544:	83 ec 08             	sub    $0x8,%esp
80106547:	8b 45 08             	mov    0x8(%ebp),%eax
8010654a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010654d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106551:	89 d0                	mov    %edx,%eax
80106553:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106556:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010655a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010655e:	ee                   	out    %al,(%dx)
}
8010655f:	90                   	nop
80106560:	c9                   	leave  
80106561:	c3                   	ret    

80106562 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106562:	f3 0f 1e fb          	endbr32 
80106566:	55                   	push   %ebp
80106567:	89 e5                	mov    %esp,%ebp
80106569:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010656c:	6a 00                	push   $0x0
8010656e:	68 fa 03 00 00       	push   $0x3fa
80106573:	e8 c9 ff ff ff       	call   80106541 <outb>
80106578:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010657b:	68 80 00 00 00       	push   $0x80
80106580:	68 fb 03 00 00       	push   $0x3fb
80106585:	e8 b7 ff ff ff       	call   80106541 <outb>
8010658a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010658d:	6a 0c                	push   $0xc
8010658f:	68 f8 03 00 00       	push   $0x3f8
80106594:	e8 a8 ff ff ff       	call   80106541 <outb>
80106599:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010659c:	6a 00                	push   $0x0
8010659e:	68 f9 03 00 00       	push   $0x3f9
801065a3:	e8 99 ff ff ff       	call   80106541 <outb>
801065a8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801065ab:	6a 03                	push   $0x3
801065ad:	68 fb 03 00 00       	push   $0x3fb
801065b2:	e8 8a ff ff ff       	call   80106541 <outb>
801065b7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801065ba:	6a 00                	push   $0x0
801065bc:	68 fc 03 00 00       	push   $0x3fc
801065c1:	e8 7b ff ff ff       	call   80106541 <outb>
801065c6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801065c9:	6a 01                	push   $0x1
801065cb:	68 f9 03 00 00       	push   $0x3f9
801065d0:	e8 6c ff ff ff       	call   80106541 <outb>
801065d5:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801065d8:	68 fd 03 00 00       	push   $0x3fd
801065dd:	e8 42 ff ff ff       	call   80106524 <inb>
801065e2:	83 c4 04             	add    $0x4,%esp
801065e5:	3c ff                	cmp    $0xff,%al
801065e7:	74 61                	je     8010664a <uartinit+0xe8>
    return;
  uart = 1;
801065e9:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
801065f0:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801065f3:	68 fa 03 00 00       	push   $0x3fa
801065f8:	e8 27 ff ff ff       	call   80106524 <inb>
801065fd:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106600:	68 f8 03 00 00       	push   $0x3f8
80106605:	e8 1a ff ff ff       	call   80106524 <inb>
8010660a:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010660d:	83 ec 08             	sub    $0x8,%esp
80106610:	6a 00                	push   $0x0
80106612:	6a 04                	push   $0x4
80106614:	e8 f3 c0 ff ff       	call   8010270c <ioapicenable>
80106619:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010661c:	c7 45 f4 74 aa 10 80 	movl   $0x8010aa74,-0xc(%ebp)
80106623:	eb 19                	jmp    8010663e <uartinit+0xdc>
    uartputc(*p);
80106625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106628:	0f b6 00             	movzbl (%eax),%eax
8010662b:	0f be c0             	movsbl %al,%eax
8010662e:	83 ec 0c             	sub    $0xc,%esp
80106631:	50                   	push   %eax
80106632:	e8 16 00 00 00       	call   8010664d <uartputc>
80106637:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010663a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010663e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106641:	0f b6 00             	movzbl (%eax),%eax
80106644:	84 c0                	test   %al,%al
80106646:	75 dd                	jne    80106625 <uartinit+0xc3>
80106648:	eb 01                	jmp    8010664b <uartinit+0xe9>
    return;
8010664a:	90                   	nop
}
8010664b:	c9                   	leave  
8010664c:	c3                   	ret    

8010664d <uartputc>:

void
uartputc(int c)
{
8010664d:	f3 0f 1e fb          	endbr32 
80106651:	55                   	push   %ebp
80106652:	89 e5                	mov    %esp,%ebp
80106654:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106657:	a1 60 d0 18 80       	mov    0x8018d060,%eax
8010665c:	85 c0                	test   %eax,%eax
8010665e:	74 53                	je     801066b3 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106660:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106667:	eb 11                	jmp    8010667a <uartputc+0x2d>
    microdelay(10);
80106669:	83 ec 0c             	sub    $0xc,%esp
8010666c:	6a 0a                	push   $0xa
8010666e:	e8 d1 c5 ff ff       	call   80102c44 <microdelay>
80106673:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106676:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010667a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010667e:	7f 1a                	jg     8010669a <uartputc+0x4d>
80106680:	83 ec 0c             	sub    $0xc,%esp
80106683:	68 fd 03 00 00       	push   $0x3fd
80106688:	e8 97 fe ff ff       	call   80106524 <inb>
8010668d:	83 c4 10             	add    $0x10,%esp
80106690:	0f b6 c0             	movzbl %al,%eax
80106693:	83 e0 20             	and    $0x20,%eax
80106696:	85 c0                	test   %eax,%eax
80106698:	74 cf                	je     80106669 <uartputc+0x1c>
  outb(COM1+0, c);
8010669a:	8b 45 08             	mov    0x8(%ebp),%eax
8010669d:	0f b6 c0             	movzbl %al,%eax
801066a0:	83 ec 08             	sub    $0x8,%esp
801066a3:	50                   	push   %eax
801066a4:	68 f8 03 00 00       	push   $0x3f8
801066a9:	e8 93 fe ff ff       	call   80106541 <outb>
801066ae:	83 c4 10             	add    $0x10,%esp
801066b1:	eb 01                	jmp    801066b4 <uartputc+0x67>
    return;
801066b3:	90                   	nop
}
801066b4:	c9                   	leave  
801066b5:	c3                   	ret    

801066b6 <uartgetc>:

static int
uartgetc(void)
{
801066b6:	f3 0f 1e fb          	endbr32 
801066ba:	55                   	push   %ebp
801066bb:	89 e5                	mov    %esp,%ebp
  if(!uart)
801066bd:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801066c2:	85 c0                	test   %eax,%eax
801066c4:	75 07                	jne    801066cd <uartgetc+0x17>
    return -1;
801066c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cb:	eb 2e                	jmp    801066fb <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801066cd:	68 fd 03 00 00       	push   $0x3fd
801066d2:	e8 4d fe ff ff       	call   80106524 <inb>
801066d7:	83 c4 04             	add    $0x4,%esp
801066da:	0f b6 c0             	movzbl %al,%eax
801066dd:	83 e0 01             	and    $0x1,%eax
801066e0:	85 c0                	test   %eax,%eax
801066e2:	75 07                	jne    801066eb <uartgetc+0x35>
    return -1;
801066e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e9:	eb 10                	jmp    801066fb <uartgetc+0x45>
  return inb(COM1+0);
801066eb:	68 f8 03 00 00       	push   $0x3f8
801066f0:	e8 2f fe ff ff       	call   80106524 <inb>
801066f5:	83 c4 04             	add    $0x4,%esp
801066f8:	0f b6 c0             	movzbl %al,%eax
}
801066fb:	c9                   	leave  
801066fc:	c3                   	ret    

801066fd <uartintr>:

void
uartintr(void)
{
801066fd:	f3 0f 1e fb          	endbr32 
80106701:	55                   	push   %ebp
80106702:	89 e5                	mov    %esp,%ebp
80106704:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106707:	83 ec 0c             	sub    $0xc,%esp
8010670a:	68 b6 66 10 80       	push   $0x801066b6
8010670f:	e8 ec a0 ff ff       	call   80100800 <consoleintr>
80106714:	83 c4 10             	add    $0x10,%esp
}
80106717:	90                   	nop
80106718:	c9                   	leave  
80106719:	c3                   	ret    

8010671a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010671a:	6a 00                	push   $0x0
  pushl $0
8010671c:	6a 00                	push   $0x0
  jmp alltraps
8010671e:	e9 a2 f8 ff ff       	jmp    80105fc5 <alltraps>

80106723 <vector1>:
.globl vector1
vector1:
  pushl $0
80106723:	6a 00                	push   $0x0
  pushl $1
80106725:	6a 01                	push   $0x1
  jmp alltraps
80106727:	e9 99 f8 ff ff       	jmp    80105fc5 <alltraps>

8010672c <vector2>:
.globl vector2
vector2:
  pushl $0
8010672c:	6a 00                	push   $0x0
  pushl $2
8010672e:	6a 02                	push   $0x2
  jmp alltraps
80106730:	e9 90 f8 ff ff       	jmp    80105fc5 <alltraps>

80106735 <vector3>:
.globl vector3
vector3:
  pushl $0
80106735:	6a 00                	push   $0x0
  pushl $3
80106737:	6a 03                	push   $0x3
  jmp alltraps
80106739:	e9 87 f8 ff ff       	jmp    80105fc5 <alltraps>

8010673e <vector4>:
.globl vector4
vector4:
  pushl $0
8010673e:	6a 00                	push   $0x0
  pushl $4
80106740:	6a 04                	push   $0x4
  jmp alltraps
80106742:	e9 7e f8 ff ff       	jmp    80105fc5 <alltraps>

80106747 <vector5>:
.globl vector5
vector5:
  pushl $0
80106747:	6a 00                	push   $0x0
  pushl $5
80106749:	6a 05                	push   $0x5
  jmp alltraps
8010674b:	e9 75 f8 ff ff       	jmp    80105fc5 <alltraps>

80106750 <vector6>:
.globl vector6
vector6:
  pushl $0
80106750:	6a 00                	push   $0x0
  pushl $6
80106752:	6a 06                	push   $0x6
  jmp alltraps
80106754:	e9 6c f8 ff ff       	jmp    80105fc5 <alltraps>

80106759 <vector7>:
.globl vector7
vector7:
  pushl $0
80106759:	6a 00                	push   $0x0
  pushl $7
8010675b:	6a 07                	push   $0x7
  jmp alltraps
8010675d:	e9 63 f8 ff ff       	jmp    80105fc5 <alltraps>

80106762 <vector8>:
.globl vector8
vector8:
  pushl $8
80106762:	6a 08                	push   $0x8
  jmp alltraps
80106764:	e9 5c f8 ff ff       	jmp    80105fc5 <alltraps>

80106769 <vector9>:
.globl vector9
vector9:
  pushl $0
80106769:	6a 00                	push   $0x0
  pushl $9
8010676b:	6a 09                	push   $0x9
  jmp alltraps
8010676d:	e9 53 f8 ff ff       	jmp    80105fc5 <alltraps>

80106772 <vector10>:
.globl vector10
vector10:
  pushl $10
80106772:	6a 0a                	push   $0xa
  jmp alltraps
80106774:	e9 4c f8 ff ff       	jmp    80105fc5 <alltraps>

80106779 <vector11>:
.globl vector11
vector11:
  pushl $11
80106779:	6a 0b                	push   $0xb
  jmp alltraps
8010677b:	e9 45 f8 ff ff       	jmp    80105fc5 <alltraps>

80106780 <vector12>:
.globl vector12
vector12:
  pushl $12
80106780:	6a 0c                	push   $0xc
  jmp alltraps
80106782:	e9 3e f8 ff ff       	jmp    80105fc5 <alltraps>

80106787 <vector13>:
.globl vector13
vector13:
  pushl $13
80106787:	6a 0d                	push   $0xd
  jmp alltraps
80106789:	e9 37 f8 ff ff       	jmp    80105fc5 <alltraps>

8010678e <vector14>:
.globl vector14
vector14:
  pushl $14
8010678e:	6a 0e                	push   $0xe
  jmp alltraps
80106790:	e9 30 f8 ff ff       	jmp    80105fc5 <alltraps>

80106795 <vector15>:
.globl vector15
vector15:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $15
80106797:	6a 0f                	push   $0xf
  jmp alltraps
80106799:	e9 27 f8 ff ff       	jmp    80105fc5 <alltraps>

8010679e <vector16>:
.globl vector16
vector16:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $16
801067a0:	6a 10                	push   $0x10
  jmp alltraps
801067a2:	e9 1e f8 ff ff       	jmp    80105fc5 <alltraps>

801067a7 <vector17>:
.globl vector17
vector17:
  pushl $17
801067a7:	6a 11                	push   $0x11
  jmp alltraps
801067a9:	e9 17 f8 ff ff       	jmp    80105fc5 <alltraps>

801067ae <vector18>:
.globl vector18
vector18:
  pushl $0
801067ae:	6a 00                	push   $0x0
  pushl $18
801067b0:	6a 12                	push   $0x12
  jmp alltraps
801067b2:	e9 0e f8 ff ff       	jmp    80105fc5 <alltraps>

801067b7 <vector19>:
.globl vector19
vector19:
  pushl $0
801067b7:	6a 00                	push   $0x0
  pushl $19
801067b9:	6a 13                	push   $0x13
  jmp alltraps
801067bb:	e9 05 f8 ff ff       	jmp    80105fc5 <alltraps>

801067c0 <vector20>:
.globl vector20
vector20:
  pushl $0
801067c0:	6a 00                	push   $0x0
  pushl $20
801067c2:	6a 14                	push   $0x14
  jmp alltraps
801067c4:	e9 fc f7 ff ff       	jmp    80105fc5 <alltraps>

801067c9 <vector21>:
.globl vector21
vector21:
  pushl $0
801067c9:	6a 00                	push   $0x0
  pushl $21
801067cb:	6a 15                	push   $0x15
  jmp alltraps
801067cd:	e9 f3 f7 ff ff       	jmp    80105fc5 <alltraps>

801067d2 <vector22>:
.globl vector22
vector22:
  pushl $0
801067d2:	6a 00                	push   $0x0
  pushl $22
801067d4:	6a 16                	push   $0x16
  jmp alltraps
801067d6:	e9 ea f7 ff ff       	jmp    80105fc5 <alltraps>

801067db <vector23>:
.globl vector23
vector23:
  pushl $0
801067db:	6a 00                	push   $0x0
  pushl $23
801067dd:	6a 17                	push   $0x17
  jmp alltraps
801067df:	e9 e1 f7 ff ff       	jmp    80105fc5 <alltraps>

801067e4 <vector24>:
.globl vector24
vector24:
  pushl $0
801067e4:	6a 00                	push   $0x0
  pushl $24
801067e6:	6a 18                	push   $0x18
  jmp alltraps
801067e8:	e9 d8 f7 ff ff       	jmp    80105fc5 <alltraps>

801067ed <vector25>:
.globl vector25
vector25:
  pushl $0
801067ed:	6a 00                	push   $0x0
  pushl $25
801067ef:	6a 19                	push   $0x19
  jmp alltraps
801067f1:	e9 cf f7 ff ff       	jmp    80105fc5 <alltraps>

801067f6 <vector26>:
.globl vector26
vector26:
  pushl $0
801067f6:	6a 00                	push   $0x0
  pushl $26
801067f8:	6a 1a                	push   $0x1a
  jmp alltraps
801067fa:	e9 c6 f7 ff ff       	jmp    80105fc5 <alltraps>

801067ff <vector27>:
.globl vector27
vector27:
  pushl $0
801067ff:	6a 00                	push   $0x0
  pushl $27
80106801:	6a 1b                	push   $0x1b
  jmp alltraps
80106803:	e9 bd f7 ff ff       	jmp    80105fc5 <alltraps>

80106808 <vector28>:
.globl vector28
vector28:
  pushl $0
80106808:	6a 00                	push   $0x0
  pushl $28
8010680a:	6a 1c                	push   $0x1c
  jmp alltraps
8010680c:	e9 b4 f7 ff ff       	jmp    80105fc5 <alltraps>

80106811 <vector29>:
.globl vector29
vector29:
  pushl $0
80106811:	6a 00                	push   $0x0
  pushl $29
80106813:	6a 1d                	push   $0x1d
  jmp alltraps
80106815:	e9 ab f7 ff ff       	jmp    80105fc5 <alltraps>

8010681a <vector30>:
.globl vector30
vector30:
  pushl $0
8010681a:	6a 00                	push   $0x0
  pushl $30
8010681c:	6a 1e                	push   $0x1e
  jmp alltraps
8010681e:	e9 a2 f7 ff ff       	jmp    80105fc5 <alltraps>

80106823 <vector31>:
.globl vector31
vector31:
  pushl $0
80106823:	6a 00                	push   $0x0
  pushl $31
80106825:	6a 1f                	push   $0x1f
  jmp alltraps
80106827:	e9 99 f7 ff ff       	jmp    80105fc5 <alltraps>

8010682c <vector32>:
.globl vector32
vector32:
  pushl $0
8010682c:	6a 00                	push   $0x0
  pushl $32
8010682e:	6a 20                	push   $0x20
  jmp alltraps
80106830:	e9 90 f7 ff ff       	jmp    80105fc5 <alltraps>

80106835 <vector33>:
.globl vector33
vector33:
  pushl $0
80106835:	6a 00                	push   $0x0
  pushl $33
80106837:	6a 21                	push   $0x21
  jmp alltraps
80106839:	e9 87 f7 ff ff       	jmp    80105fc5 <alltraps>

8010683e <vector34>:
.globl vector34
vector34:
  pushl $0
8010683e:	6a 00                	push   $0x0
  pushl $34
80106840:	6a 22                	push   $0x22
  jmp alltraps
80106842:	e9 7e f7 ff ff       	jmp    80105fc5 <alltraps>

80106847 <vector35>:
.globl vector35
vector35:
  pushl $0
80106847:	6a 00                	push   $0x0
  pushl $35
80106849:	6a 23                	push   $0x23
  jmp alltraps
8010684b:	e9 75 f7 ff ff       	jmp    80105fc5 <alltraps>

80106850 <vector36>:
.globl vector36
vector36:
  pushl $0
80106850:	6a 00                	push   $0x0
  pushl $36
80106852:	6a 24                	push   $0x24
  jmp alltraps
80106854:	e9 6c f7 ff ff       	jmp    80105fc5 <alltraps>

80106859 <vector37>:
.globl vector37
vector37:
  pushl $0
80106859:	6a 00                	push   $0x0
  pushl $37
8010685b:	6a 25                	push   $0x25
  jmp alltraps
8010685d:	e9 63 f7 ff ff       	jmp    80105fc5 <alltraps>

80106862 <vector38>:
.globl vector38
vector38:
  pushl $0
80106862:	6a 00                	push   $0x0
  pushl $38
80106864:	6a 26                	push   $0x26
  jmp alltraps
80106866:	e9 5a f7 ff ff       	jmp    80105fc5 <alltraps>

8010686b <vector39>:
.globl vector39
vector39:
  pushl $0
8010686b:	6a 00                	push   $0x0
  pushl $39
8010686d:	6a 27                	push   $0x27
  jmp alltraps
8010686f:	e9 51 f7 ff ff       	jmp    80105fc5 <alltraps>

80106874 <vector40>:
.globl vector40
vector40:
  pushl $0
80106874:	6a 00                	push   $0x0
  pushl $40
80106876:	6a 28                	push   $0x28
  jmp alltraps
80106878:	e9 48 f7 ff ff       	jmp    80105fc5 <alltraps>

8010687d <vector41>:
.globl vector41
vector41:
  pushl $0
8010687d:	6a 00                	push   $0x0
  pushl $41
8010687f:	6a 29                	push   $0x29
  jmp alltraps
80106881:	e9 3f f7 ff ff       	jmp    80105fc5 <alltraps>

80106886 <vector42>:
.globl vector42
vector42:
  pushl $0
80106886:	6a 00                	push   $0x0
  pushl $42
80106888:	6a 2a                	push   $0x2a
  jmp alltraps
8010688a:	e9 36 f7 ff ff       	jmp    80105fc5 <alltraps>

8010688f <vector43>:
.globl vector43
vector43:
  pushl $0
8010688f:	6a 00                	push   $0x0
  pushl $43
80106891:	6a 2b                	push   $0x2b
  jmp alltraps
80106893:	e9 2d f7 ff ff       	jmp    80105fc5 <alltraps>

80106898 <vector44>:
.globl vector44
vector44:
  pushl $0
80106898:	6a 00                	push   $0x0
  pushl $44
8010689a:	6a 2c                	push   $0x2c
  jmp alltraps
8010689c:	e9 24 f7 ff ff       	jmp    80105fc5 <alltraps>

801068a1 <vector45>:
.globl vector45
vector45:
  pushl $0
801068a1:	6a 00                	push   $0x0
  pushl $45
801068a3:	6a 2d                	push   $0x2d
  jmp alltraps
801068a5:	e9 1b f7 ff ff       	jmp    80105fc5 <alltraps>

801068aa <vector46>:
.globl vector46
vector46:
  pushl $0
801068aa:	6a 00                	push   $0x0
  pushl $46
801068ac:	6a 2e                	push   $0x2e
  jmp alltraps
801068ae:	e9 12 f7 ff ff       	jmp    80105fc5 <alltraps>

801068b3 <vector47>:
.globl vector47
vector47:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $47
801068b5:	6a 2f                	push   $0x2f
  jmp alltraps
801068b7:	e9 09 f7 ff ff       	jmp    80105fc5 <alltraps>

801068bc <vector48>:
.globl vector48
vector48:
  pushl $0
801068bc:	6a 00                	push   $0x0
  pushl $48
801068be:	6a 30                	push   $0x30
  jmp alltraps
801068c0:	e9 00 f7 ff ff       	jmp    80105fc5 <alltraps>

801068c5 <vector49>:
.globl vector49
vector49:
  pushl $0
801068c5:	6a 00                	push   $0x0
  pushl $49
801068c7:	6a 31                	push   $0x31
  jmp alltraps
801068c9:	e9 f7 f6 ff ff       	jmp    80105fc5 <alltraps>

801068ce <vector50>:
.globl vector50
vector50:
  pushl $0
801068ce:	6a 00                	push   $0x0
  pushl $50
801068d0:	6a 32                	push   $0x32
  jmp alltraps
801068d2:	e9 ee f6 ff ff       	jmp    80105fc5 <alltraps>

801068d7 <vector51>:
.globl vector51
vector51:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $51
801068d9:	6a 33                	push   $0x33
  jmp alltraps
801068db:	e9 e5 f6 ff ff       	jmp    80105fc5 <alltraps>

801068e0 <vector52>:
.globl vector52
vector52:
  pushl $0
801068e0:	6a 00                	push   $0x0
  pushl $52
801068e2:	6a 34                	push   $0x34
  jmp alltraps
801068e4:	e9 dc f6 ff ff       	jmp    80105fc5 <alltraps>

801068e9 <vector53>:
.globl vector53
vector53:
  pushl $0
801068e9:	6a 00                	push   $0x0
  pushl $53
801068eb:	6a 35                	push   $0x35
  jmp alltraps
801068ed:	e9 d3 f6 ff ff       	jmp    80105fc5 <alltraps>

801068f2 <vector54>:
.globl vector54
vector54:
  pushl $0
801068f2:	6a 00                	push   $0x0
  pushl $54
801068f4:	6a 36                	push   $0x36
  jmp alltraps
801068f6:	e9 ca f6 ff ff       	jmp    80105fc5 <alltraps>

801068fb <vector55>:
.globl vector55
vector55:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $55
801068fd:	6a 37                	push   $0x37
  jmp alltraps
801068ff:	e9 c1 f6 ff ff       	jmp    80105fc5 <alltraps>

80106904 <vector56>:
.globl vector56
vector56:
  pushl $0
80106904:	6a 00                	push   $0x0
  pushl $56
80106906:	6a 38                	push   $0x38
  jmp alltraps
80106908:	e9 b8 f6 ff ff       	jmp    80105fc5 <alltraps>

8010690d <vector57>:
.globl vector57
vector57:
  pushl $0
8010690d:	6a 00                	push   $0x0
  pushl $57
8010690f:	6a 39                	push   $0x39
  jmp alltraps
80106911:	e9 af f6 ff ff       	jmp    80105fc5 <alltraps>

80106916 <vector58>:
.globl vector58
vector58:
  pushl $0
80106916:	6a 00                	push   $0x0
  pushl $58
80106918:	6a 3a                	push   $0x3a
  jmp alltraps
8010691a:	e9 a6 f6 ff ff       	jmp    80105fc5 <alltraps>

8010691f <vector59>:
.globl vector59
vector59:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $59
80106921:	6a 3b                	push   $0x3b
  jmp alltraps
80106923:	e9 9d f6 ff ff       	jmp    80105fc5 <alltraps>

80106928 <vector60>:
.globl vector60
vector60:
  pushl $0
80106928:	6a 00                	push   $0x0
  pushl $60
8010692a:	6a 3c                	push   $0x3c
  jmp alltraps
8010692c:	e9 94 f6 ff ff       	jmp    80105fc5 <alltraps>

80106931 <vector61>:
.globl vector61
vector61:
  pushl $0
80106931:	6a 00                	push   $0x0
  pushl $61
80106933:	6a 3d                	push   $0x3d
  jmp alltraps
80106935:	e9 8b f6 ff ff       	jmp    80105fc5 <alltraps>

8010693a <vector62>:
.globl vector62
vector62:
  pushl $0
8010693a:	6a 00                	push   $0x0
  pushl $62
8010693c:	6a 3e                	push   $0x3e
  jmp alltraps
8010693e:	e9 82 f6 ff ff       	jmp    80105fc5 <alltraps>

80106943 <vector63>:
.globl vector63
vector63:
  pushl $0
80106943:	6a 00                	push   $0x0
  pushl $63
80106945:	6a 3f                	push   $0x3f
  jmp alltraps
80106947:	e9 79 f6 ff ff       	jmp    80105fc5 <alltraps>

8010694c <vector64>:
.globl vector64
vector64:
  pushl $0
8010694c:	6a 00                	push   $0x0
  pushl $64
8010694e:	6a 40                	push   $0x40
  jmp alltraps
80106950:	e9 70 f6 ff ff       	jmp    80105fc5 <alltraps>

80106955 <vector65>:
.globl vector65
vector65:
  pushl $0
80106955:	6a 00                	push   $0x0
  pushl $65
80106957:	6a 41                	push   $0x41
  jmp alltraps
80106959:	e9 67 f6 ff ff       	jmp    80105fc5 <alltraps>

8010695e <vector66>:
.globl vector66
vector66:
  pushl $0
8010695e:	6a 00                	push   $0x0
  pushl $66
80106960:	6a 42                	push   $0x42
  jmp alltraps
80106962:	e9 5e f6 ff ff       	jmp    80105fc5 <alltraps>

80106967 <vector67>:
.globl vector67
vector67:
  pushl $0
80106967:	6a 00                	push   $0x0
  pushl $67
80106969:	6a 43                	push   $0x43
  jmp alltraps
8010696b:	e9 55 f6 ff ff       	jmp    80105fc5 <alltraps>

80106970 <vector68>:
.globl vector68
vector68:
  pushl $0
80106970:	6a 00                	push   $0x0
  pushl $68
80106972:	6a 44                	push   $0x44
  jmp alltraps
80106974:	e9 4c f6 ff ff       	jmp    80105fc5 <alltraps>

80106979 <vector69>:
.globl vector69
vector69:
  pushl $0
80106979:	6a 00                	push   $0x0
  pushl $69
8010697b:	6a 45                	push   $0x45
  jmp alltraps
8010697d:	e9 43 f6 ff ff       	jmp    80105fc5 <alltraps>

80106982 <vector70>:
.globl vector70
vector70:
  pushl $0
80106982:	6a 00                	push   $0x0
  pushl $70
80106984:	6a 46                	push   $0x46
  jmp alltraps
80106986:	e9 3a f6 ff ff       	jmp    80105fc5 <alltraps>

8010698b <vector71>:
.globl vector71
vector71:
  pushl $0
8010698b:	6a 00                	push   $0x0
  pushl $71
8010698d:	6a 47                	push   $0x47
  jmp alltraps
8010698f:	e9 31 f6 ff ff       	jmp    80105fc5 <alltraps>

80106994 <vector72>:
.globl vector72
vector72:
  pushl $0
80106994:	6a 00                	push   $0x0
  pushl $72
80106996:	6a 48                	push   $0x48
  jmp alltraps
80106998:	e9 28 f6 ff ff       	jmp    80105fc5 <alltraps>

8010699d <vector73>:
.globl vector73
vector73:
  pushl $0
8010699d:	6a 00                	push   $0x0
  pushl $73
8010699f:	6a 49                	push   $0x49
  jmp alltraps
801069a1:	e9 1f f6 ff ff       	jmp    80105fc5 <alltraps>

801069a6 <vector74>:
.globl vector74
vector74:
  pushl $0
801069a6:	6a 00                	push   $0x0
  pushl $74
801069a8:	6a 4a                	push   $0x4a
  jmp alltraps
801069aa:	e9 16 f6 ff ff       	jmp    80105fc5 <alltraps>

801069af <vector75>:
.globl vector75
vector75:
  pushl $0
801069af:	6a 00                	push   $0x0
  pushl $75
801069b1:	6a 4b                	push   $0x4b
  jmp alltraps
801069b3:	e9 0d f6 ff ff       	jmp    80105fc5 <alltraps>

801069b8 <vector76>:
.globl vector76
vector76:
  pushl $0
801069b8:	6a 00                	push   $0x0
  pushl $76
801069ba:	6a 4c                	push   $0x4c
  jmp alltraps
801069bc:	e9 04 f6 ff ff       	jmp    80105fc5 <alltraps>

801069c1 <vector77>:
.globl vector77
vector77:
  pushl $0
801069c1:	6a 00                	push   $0x0
  pushl $77
801069c3:	6a 4d                	push   $0x4d
  jmp alltraps
801069c5:	e9 fb f5 ff ff       	jmp    80105fc5 <alltraps>

801069ca <vector78>:
.globl vector78
vector78:
  pushl $0
801069ca:	6a 00                	push   $0x0
  pushl $78
801069cc:	6a 4e                	push   $0x4e
  jmp alltraps
801069ce:	e9 f2 f5 ff ff       	jmp    80105fc5 <alltraps>

801069d3 <vector79>:
.globl vector79
vector79:
  pushl $0
801069d3:	6a 00                	push   $0x0
  pushl $79
801069d5:	6a 4f                	push   $0x4f
  jmp alltraps
801069d7:	e9 e9 f5 ff ff       	jmp    80105fc5 <alltraps>

801069dc <vector80>:
.globl vector80
vector80:
  pushl $0
801069dc:	6a 00                	push   $0x0
  pushl $80
801069de:	6a 50                	push   $0x50
  jmp alltraps
801069e0:	e9 e0 f5 ff ff       	jmp    80105fc5 <alltraps>

801069e5 <vector81>:
.globl vector81
vector81:
  pushl $0
801069e5:	6a 00                	push   $0x0
  pushl $81
801069e7:	6a 51                	push   $0x51
  jmp alltraps
801069e9:	e9 d7 f5 ff ff       	jmp    80105fc5 <alltraps>

801069ee <vector82>:
.globl vector82
vector82:
  pushl $0
801069ee:	6a 00                	push   $0x0
  pushl $82
801069f0:	6a 52                	push   $0x52
  jmp alltraps
801069f2:	e9 ce f5 ff ff       	jmp    80105fc5 <alltraps>

801069f7 <vector83>:
.globl vector83
vector83:
  pushl $0
801069f7:	6a 00                	push   $0x0
  pushl $83
801069f9:	6a 53                	push   $0x53
  jmp alltraps
801069fb:	e9 c5 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a00 <vector84>:
.globl vector84
vector84:
  pushl $0
80106a00:	6a 00                	push   $0x0
  pushl $84
80106a02:	6a 54                	push   $0x54
  jmp alltraps
80106a04:	e9 bc f5 ff ff       	jmp    80105fc5 <alltraps>

80106a09 <vector85>:
.globl vector85
vector85:
  pushl $0
80106a09:	6a 00                	push   $0x0
  pushl $85
80106a0b:	6a 55                	push   $0x55
  jmp alltraps
80106a0d:	e9 b3 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a12 <vector86>:
.globl vector86
vector86:
  pushl $0
80106a12:	6a 00                	push   $0x0
  pushl $86
80106a14:	6a 56                	push   $0x56
  jmp alltraps
80106a16:	e9 aa f5 ff ff       	jmp    80105fc5 <alltraps>

80106a1b <vector87>:
.globl vector87
vector87:
  pushl $0
80106a1b:	6a 00                	push   $0x0
  pushl $87
80106a1d:	6a 57                	push   $0x57
  jmp alltraps
80106a1f:	e9 a1 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a24 <vector88>:
.globl vector88
vector88:
  pushl $0
80106a24:	6a 00                	push   $0x0
  pushl $88
80106a26:	6a 58                	push   $0x58
  jmp alltraps
80106a28:	e9 98 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a2d <vector89>:
.globl vector89
vector89:
  pushl $0
80106a2d:	6a 00                	push   $0x0
  pushl $89
80106a2f:	6a 59                	push   $0x59
  jmp alltraps
80106a31:	e9 8f f5 ff ff       	jmp    80105fc5 <alltraps>

80106a36 <vector90>:
.globl vector90
vector90:
  pushl $0
80106a36:	6a 00                	push   $0x0
  pushl $90
80106a38:	6a 5a                	push   $0x5a
  jmp alltraps
80106a3a:	e9 86 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a3f <vector91>:
.globl vector91
vector91:
  pushl $0
80106a3f:	6a 00                	push   $0x0
  pushl $91
80106a41:	6a 5b                	push   $0x5b
  jmp alltraps
80106a43:	e9 7d f5 ff ff       	jmp    80105fc5 <alltraps>

80106a48 <vector92>:
.globl vector92
vector92:
  pushl $0
80106a48:	6a 00                	push   $0x0
  pushl $92
80106a4a:	6a 5c                	push   $0x5c
  jmp alltraps
80106a4c:	e9 74 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a51 <vector93>:
.globl vector93
vector93:
  pushl $0
80106a51:	6a 00                	push   $0x0
  pushl $93
80106a53:	6a 5d                	push   $0x5d
  jmp alltraps
80106a55:	e9 6b f5 ff ff       	jmp    80105fc5 <alltraps>

80106a5a <vector94>:
.globl vector94
vector94:
  pushl $0
80106a5a:	6a 00                	push   $0x0
  pushl $94
80106a5c:	6a 5e                	push   $0x5e
  jmp alltraps
80106a5e:	e9 62 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a63 <vector95>:
.globl vector95
vector95:
  pushl $0
80106a63:	6a 00                	push   $0x0
  pushl $95
80106a65:	6a 5f                	push   $0x5f
  jmp alltraps
80106a67:	e9 59 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a6c <vector96>:
.globl vector96
vector96:
  pushl $0
80106a6c:	6a 00                	push   $0x0
  pushl $96
80106a6e:	6a 60                	push   $0x60
  jmp alltraps
80106a70:	e9 50 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a75 <vector97>:
.globl vector97
vector97:
  pushl $0
80106a75:	6a 00                	push   $0x0
  pushl $97
80106a77:	6a 61                	push   $0x61
  jmp alltraps
80106a79:	e9 47 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a7e <vector98>:
.globl vector98
vector98:
  pushl $0
80106a7e:	6a 00                	push   $0x0
  pushl $98
80106a80:	6a 62                	push   $0x62
  jmp alltraps
80106a82:	e9 3e f5 ff ff       	jmp    80105fc5 <alltraps>

80106a87 <vector99>:
.globl vector99
vector99:
  pushl $0
80106a87:	6a 00                	push   $0x0
  pushl $99
80106a89:	6a 63                	push   $0x63
  jmp alltraps
80106a8b:	e9 35 f5 ff ff       	jmp    80105fc5 <alltraps>

80106a90 <vector100>:
.globl vector100
vector100:
  pushl $0
80106a90:	6a 00                	push   $0x0
  pushl $100
80106a92:	6a 64                	push   $0x64
  jmp alltraps
80106a94:	e9 2c f5 ff ff       	jmp    80105fc5 <alltraps>

80106a99 <vector101>:
.globl vector101
vector101:
  pushl $0
80106a99:	6a 00                	push   $0x0
  pushl $101
80106a9b:	6a 65                	push   $0x65
  jmp alltraps
80106a9d:	e9 23 f5 ff ff       	jmp    80105fc5 <alltraps>

80106aa2 <vector102>:
.globl vector102
vector102:
  pushl $0
80106aa2:	6a 00                	push   $0x0
  pushl $102
80106aa4:	6a 66                	push   $0x66
  jmp alltraps
80106aa6:	e9 1a f5 ff ff       	jmp    80105fc5 <alltraps>

80106aab <vector103>:
.globl vector103
vector103:
  pushl $0
80106aab:	6a 00                	push   $0x0
  pushl $103
80106aad:	6a 67                	push   $0x67
  jmp alltraps
80106aaf:	e9 11 f5 ff ff       	jmp    80105fc5 <alltraps>

80106ab4 <vector104>:
.globl vector104
vector104:
  pushl $0
80106ab4:	6a 00                	push   $0x0
  pushl $104
80106ab6:	6a 68                	push   $0x68
  jmp alltraps
80106ab8:	e9 08 f5 ff ff       	jmp    80105fc5 <alltraps>

80106abd <vector105>:
.globl vector105
vector105:
  pushl $0
80106abd:	6a 00                	push   $0x0
  pushl $105
80106abf:	6a 69                	push   $0x69
  jmp alltraps
80106ac1:	e9 ff f4 ff ff       	jmp    80105fc5 <alltraps>

80106ac6 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ac6:	6a 00                	push   $0x0
  pushl $106
80106ac8:	6a 6a                	push   $0x6a
  jmp alltraps
80106aca:	e9 f6 f4 ff ff       	jmp    80105fc5 <alltraps>

80106acf <vector107>:
.globl vector107
vector107:
  pushl $0
80106acf:	6a 00                	push   $0x0
  pushl $107
80106ad1:	6a 6b                	push   $0x6b
  jmp alltraps
80106ad3:	e9 ed f4 ff ff       	jmp    80105fc5 <alltraps>

80106ad8 <vector108>:
.globl vector108
vector108:
  pushl $0
80106ad8:	6a 00                	push   $0x0
  pushl $108
80106ada:	6a 6c                	push   $0x6c
  jmp alltraps
80106adc:	e9 e4 f4 ff ff       	jmp    80105fc5 <alltraps>

80106ae1 <vector109>:
.globl vector109
vector109:
  pushl $0
80106ae1:	6a 00                	push   $0x0
  pushl $109
80106ae3:	6a 6d                	push   $0x6d
  jmp alltraps
80106ae5:	e9 db f4 ff ff       	jmp    80105fc5 <alltraps>

80106aea <vector110>:
.globl vector110
vector110:
  pushl $0
80106aea:	6a 00                	push   $0x0
  pushl $110
80106aec:	6a 6e                	push   $0x6e
  jmp alltraps
80106aee:	e9 d2 f4 ff ff       	jmp    80105fc5 <alltraps>

80106af3 <vector111>:
.globl vector111
vector111:
  pushl $0
80106af3:	6a 00                	push   $0x0
  pushl $111
80106af5:	6a 6f                	push   $0x6f
  jmp alltraps
80106af7:	e9 c9 f4 ff ff       	jmp    80105fc5 <alltraps>

80106afc <vector112>:
.globl vector112
vector112:
  pushl $0
80106afc:	6a 00                	push   $0x0
  pushl $112
80106afe:	6a 70                	push   $0x70
  jmp alltraps
80106b00:	e9 c0 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b05 <vector113>:
.globl vector113
vector113:
  pushl $0
80106b05:	6a 00                	push   $0x0
  pushl $113
80106b07:	6a 71                	push   $0x71
  jmp alltraps
80106b09:	e9 b7 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b0e <vector114>:
.globl vector114
vector114:
  pushl $0
80106b0e:	6a 00                	push   $0x0
  pushl $114
80106b10:	6a 72                	push   $0x72
  jmp alltraps
80106b12:	e9 ae f4 ff ff       	jmp    80105fc5 <alltraps>

80106b17 <vector115>:
.globl vector115
vector115:
  pushl $0
80106b17:	6a 00                	push   $0x0
  pushl $115
80106b19:	6a 73                	push   $0x73
  jmp alltraps
80106b1b:	e9 a5 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b20 <vector116>:
.globl vector116
vector116:
  pushl $0
80106b20:	6a 00                	push   $0x0
  pushl $116
80106b22:	6a 74                	push   $0x74
  jmp alltraps
80106b24:	e9 9c f4 ff ff       	jmp    80105fc5 <alltraps>

80106b29 <vector117>:
.globl vector117
vector117:
  pushl $0
80106b29:	6a 00                	push   $0x0
  pushl $117
80106b2b:	6a 75                	push   $0x75
  jmp alltraps
80106b2d:	e9 93 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b32 <vector118>:
.globl vector118
vector118:
  pushl $0
80106b32:	6a 00                	push   $0x0
  pushl $118
80106b34:	6a 76                	push   $0x76
  jmp alltraps
80106b36:	e9 8a f4 ff ff       	jmp    80105fc5 <alltraps>

80106b3b <vector119>:
.globl vector119
vector119:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $119
80106b3d:	6a 77                	push   $0x77
  jmp alltraps
80106b3f:	e9 81 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b44 <vector120>:
.globl vector120
vector120:
  pushl $0
80106b44:	6a 00                	push   $0x0
  pushl $120
80106b46:	6a 78                	push   $0x78
  jmp alltraps
80106b48:	e9 78 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b4d <vector121>:
.globl vector121
vector121:
  pushl $0
80106b4d:	6a 00                	push   $0x0
  pushl $121
80106b4f:	6a 79                	push   $0x79
  jmp alltraps
80106b51:	e9 6f f4 ff ff       	jmp    80105fc5 <alltraps>

80106b56 <vector122>:
.globl vector122
vector122:
  pushl $0
80106b56:	6a 00                	push   $0x0
  pushl $122
80106b58:	6a 7a                	push   $0x7a
  jmp alltraps
80106b5a:	e9 66 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b5f <vector123>:
.globl vector123
vector123:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $123
80106b61:	6a 7b                	push   $0x7b
  jmp alltraps
80106b63:	e9 5d f4 ff ff       	jmp    80105fc5 <alltraps>

80106b68 <vector124>:
.globl vector124
vector124:
  pushl $0
80106b68:	6a 00                	push   $0x0
  pushl $124
80106b6a:	6a 7c                	push   $0x7c
  jmp alltraps
80106b6c:	e9 54 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b71 <vector125>:
.globl vector125
vector125:
  pushl $0
80106b71:	6a 00                	push   $0x0
  pushl $125
80106b73:	6a 7d                	push   $0x7d
  jmp alltraps
80106b75:	e9 4b f4 ff ff       	jmp    80105fc5 <alltraps>

80106b7a <vector126>:
.globl vector126
vector126:
  pushl $0
80106b7a:	6a 00                	push   $0x0
  pushl $126
80106b7c:	6a 7e                	push   $0x7e
  jmp alltraps
80106b7e:	e9 42 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b83 <vector127>:
.globl vector127
vector127:
  pushl $0
80106b83:	6a 00                	push   $0x0
  pushl $127
80106b85:	6a 7f                	push   $0x7f
  jmp alltraps
80106b87:	e9 39 f4 ff ff       	jmp    80105fc5 <alltraps>

80106b8c <vector128>:
.globl vector128
vector128:
  pushl $0
80106b8c:	6a 00                	push   $0x0
  pushl $128
80106b8e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106b93:	e9 2d f4 ff ff       	jmp    80105fc5 <alltraps>

80106b98 <vector129>:
.globl vector129
vector129:
  pushl $0
80106b98:	6a 00                	push   $0x0
  pushl $129
80106b9a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106b9f:	e9 21 f4 ff ff       	jmp    80105fc5 <alltraps>

80106ba4 <vector130>:
.globl vector130
vector130:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $130
80106ba6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106bab:	e9 15 f4 ff ff       	jmp    80105fc5 <alltraps>

80106bb0 <vector131>:
.globl vector131
vector131:
  pushl $0
80106bb0:	6a 00                	push   $0x0
  pushl $131
80106bb2:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106bb7:	e9 09 f4 ff ff       	jmp    80105fc5 <alltraps>

80106bbc <vector132>:
.globl vector132
vector132:
  pushl $0
80106bbc:	6a 00                	push   $0x0
  pushl $132
80106bbe:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106bc3:	e9 fd f3 ff ff       	jmp    80105fc5 <alltraps>

80106bc8 <vector133>:
.globl vector133
vector133:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $133
80106bca:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106bcf:	e9 f1 f3 ff ff       	jmp    80105fc5 <alltraps>

80106bd4 <vector134>:
.globl vector134
vector134:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $134
80106bd6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106bdb:	e9 e5 f3 ff ff       	jmp    80105fc5 <alltraps>

80106be0 <vector135>:
.globl vector135
vector135:
  pushl $0
80106be0:	6a 00                	push   $0x0
  pushl $135
80106be2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106be7:	e9 d9 f3 ff ff       	jmp    80105fc5 <alltraps>

80106bec <vector136>:
.globl vector136
vector136:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $136
80106bee:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106bf3:	e9 cd f3 ff ff       	jmp    80105fc5 <alltraps>

80106bf8 <vector137>:
.globl vector137
vector137:
  pushl $0
80106bf8:	6a 00                	push   $0x0
  pushl $137
80106bfa:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106bff:	e9 c1 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c04 <vector138>:
.globl vector138
vector138:
  pushl $0
80106c04:	6a 00                	push   $0x0
  pushl $138
80106c06:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106c0b:	e9 b5 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c10 <vector139>:
.globl vector139
vector139:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $139
80106c12:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106c17:	e9 a9 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c1c <vector140>:
.globl vector140
vector140:
  pushl $0
80106c1c:	6a 00                	push   $0x0
  pushl $140
80106c1e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106c23:	e9 9d f3 ff ff       	jmp    80105fc5 <alltraps>

80106c28 <vector141>:
.globl vector141
vector141:
  pushl $0
80106c28:	6a 00                	push   $0x0
  pushl $141
80106c2a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106c2f:	e9 91 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c34 <vector142>:
.globl vector142
vector142:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $142
80106c36:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106c3b:	e9 85 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c40 <vector143>:
.globl vector143
vector143:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $143
80106c42:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106c47:	e9 79 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c4c <vector144>:
.globl vector144
vector144:
  pushl $0
80106c4c:	6a 00                	push   $0x0
  pushl $144
80106c4e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106c53:	e9 6d f3 ff ff       	jmp    80105fc5 <alltraps>

80106c58 <vector145>:
.globl vector145
vector145:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $145
80106c5a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106c5f:	e9 61 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c64 <vector146>:
.globl vector146
vector146:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $146
80106c66:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106c6b:	e9 55 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c70 <vector147>:
.globl vector147
vector147:
  pushl $0
80106c70:	6a 00                	push   $0x0
  pushl $147
80106c72:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106c77:	e9 49 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c7c <vector148>:
.globl vector148
vector148:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $148
80106c7e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106c83:	e9 3d f3 ff ff       	jmp    80105fc5 <alltraps>

80106c88 <vector149>:
.globl vector149
vector149:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $149
80106c8a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106c8f:	e9 31 f3 ff ff       	jmp    80105fc5 <alltraps>

80106c94 <vector150>:
.globl vector150
vector150:
  pushl $0
80106c94:	6a 00                	push   $0x0
  pushl $150
80106c96:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106c9b:	e9 25 f3 ff ff       	jmp    80105fc5 <alltraps>

80106ca0 <vector151>:
.globl vector151
vector151:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $151
80106ca2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106ca7:	e9 19 f3 ff ff       	jmp    80105fc5 <alltraps>

80106cac <vector152>:
.globl vector152
vector152:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $152
80106cae:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106cb3:	e9 0d f3 ff ff       	jmp    80105fc5 <alltraps>

80106cb8 <vector153>:
.globl vector153
vector153:
  pushl $0
80106cb8:	6a 00                	push   $0x0
  pushl $153
80106cba:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106cbf:	e9 01 f3 ff ff       	jmp    80105fc5 <alltraps>

80106cc4 <vector154>:
.globl vector154
vector154:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $154
80106cc6:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106ccb:	e9 f5 f2 ff ff       	jmp    80105fc5 <alltraps>

80106cd0 <vector155>:
.globl vector155
vector155:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $155
80106cd2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106cd7:	e9 e9 f2 ff ff       	jmp    80105fc5 <alltraps>

80106cdc <vector156>:
.globl vector156
vector156:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $156
80106cde:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ce3:	e9 dd f2 ff ff       	jmp    80105fc5 <alltraps>

80106ce8 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ce8:	6a 00                	push   $0x0
  pushl $157
80106cea:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106cef:	e9 d1 f2 ff ff       	jmp    80105fc5 <alltraps>

80106cf4 <vector158>:
.globl vector158
vector158:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $158
80106cf6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106cfb:	e9 c5 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d00 <vector159>:
.globl vector159
vector159:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $159
80106d02:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106d07:	e9 b9 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d0c <vector160>:
.globl vector160
vector160:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $160
80106d0e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106d13:	e9 ad f2 ff ff       	jmp    80105fc5 <alltraps>

80106d18 <vector161>:
.globl vector161
vector161:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $161
80106d1a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106d1f:	e9 a1 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d24 <vector162>:
.globl vector162
vector162:
  pushl $0
80106d24:	6a 00                	push   $0x0
  pushl $162
80106d26:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106d2b:	e9 95 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d30 <vector163>:
.globl vector163
vector163:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $163
80106d32:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106d37:	e9 89 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d3c <vector164>:
.globl vector164
vector164:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $164
80106d3e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106d43:	e9 7d f2 ff ff       	jmp    80105fc5 <alltraps>

80106d48 <vector165>:
.globl vector165
vector165:
  pushl $0
80106d48:	6a 00                	push   $0x0
  pushl $165
80106d4a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106d4f:	e9 71 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d54 <vector166>:
.globl vector166
vector166:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $166
80106d56:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106d5b:	e9 65 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d60 <vector167>:
.globl vector167
vector167:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $167
80106d62:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106d67:	e9 59 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d6c <vector168>:
.globl vector168
vector168:
  pushl $0
80106d6c:	6a 00                	push   $0x0
  pushl $168
80106d6e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106d73:	e9 4d f2 ff ff       	jmp    80105fc5 <alltraps>

80106d78 <vector169>:
.globl vector169
vector169:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $169
80106d7a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106d7f:	e9 41 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d84 <vector170>:
.globl vector170
vector170:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $170
80106d86:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106d8b:	e9 35 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d90 <vector171>:
.globl vector171
vector171:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $171
80106d92:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106d97:	e9 29 f2 ff ff       	jmp    80105fc5 <alltraps>

80106d9c <vector172>:
.globl vector172
vector172:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $172
80106d9e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106da3:	e9 1d f2 ff ff       	jmp    80105fc5 <alltraps>

80106da8 <vector173>:
.globl vector173
vector173:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $173
80106daa:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106daf:	e9 11 f2 ff ff       	jmp    80105fc5 <alltraps>

80106db4 <vector174>:
.globl vector174
vector174:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $174
80106db6:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106dbb:	e9 05 f2 ff ff       	jmp    80105fc5 <alltraps>

80106dc0 <vector175>:
.globl vector175
vector175:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $175
80106dc2:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106dc7:	e9 f9 f1 ff ff       	jmp    80105fc5 <alltraps>

80106dcc <vector176>:
.globl vector176
vector176:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $176
80106dce:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106dd3:	e9 ed f1 ff ff       	jmp    80105fc5 <alltraps>

80106dd8 <vector177>:
.globl vector177
vector177:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $177
80106dda:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106ddf:	e9 e1 f1 ff ff       	jmp    80105fc5 <alltraps>

80106de4 <vector178>:
.globl vector178
vector178:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $178
80106de6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106deb:	e9 d5 f1 ff ff       	jmp    80105fc5 <alltraps>

80106df0 <vector179>:
.globl vector179
vector179:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $179
80106df2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106df7:	e9 c9 f1 ff ff       	jmp    80105fc5 <alltraps>

80106dfc <vector180>:
.globl vector180
vector180:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $180
80106dfe:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106e03:	e9 bd f1 ff ff       	jmp    80105fc5 <alltraps>

80106e08 <vector181>:
.globl vector181
vector181:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $181
80106e0a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106e0f:	e9 b1 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e14 <vector182>:
.globl vector182
vector182:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $182
80106e16:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106e1b:	e9 a5 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e20 <vector183>:
.globl vector183
vector183:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $183
80106e22:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106e27:	e9 99 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e2c <vector184>:
.globl vector184
vector184:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $184
80106e2e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106e33:	e9 8d f1 ff ff       	jmp    80105fc5 <alltraps>

80106e38 <vector185>:
.globl vector185
vector185:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $185
80106e3a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106e3f:	e9 81 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e44 <vector186>:
.globl vector186
vector186:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $186
80106e46:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106e4b:	e9 75 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e50 <vector187>:
.globl vector187
vector187:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $187
80106e52:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106e57:	e9 69 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e5c <vector188>:
.globl vector188
vector188:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $188
80106e5e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106e63:	e9 5d f1 ff ff       	jmp    80105fc5 <alltraps>

80106e68 <vector189>:
.globl vector189
vector189:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $189
80106e6a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106e6f:	e9 51 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e74 <vector190>:
.globl vector190
vector190:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $190
80106e76:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106e7b:	e9 45 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e80 <vector191>:
.globl vector191
vector191:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $191
80106e82:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106e87:	e9 39 f1 ff ff       	jmp    80105fc5 <alltraps>

80106e8c <vector192>:
.globl vector192
vector192:
  pushl $0
80106e8c:	6a 00                	push   $0x0
  pushl $192
80106e8e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106e93:	e9 2d f1 ff ff       	jmp    80105fc5 <alltraps>

80106e98 <vector193>:
.globl vector193
vector193:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $193
80106e9a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106e9f:	e9 21 f1 ff ff       	jmp    80105fc5 <alltraps>

80106ea4 <vector194>:
.globl vector194
vector194:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $194
80106ea6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106eab:	e9 15 f1 ff ff       	jmp    80105fc5 <alltraps>

80106eb0 <vector195>:
.globl vector195
vector195:
  pushl $0
80106eb0:	6a 00                	push   $0x0
  pushl $195
80106eb2:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106eb7:	e9 09 f1 ff ff       	jmp    80105fc5 <alltraps>

80106ebc <vector196>:
.globl vector196
vector196:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $196
80106ebe:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106ec3:	e9 fd f0 ff ff       	jmp    80105fc5 <alltraps>

80106ec8 <vector197>:
.globl vector197
vector197:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $197
80106eca:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106ecf:	e9 f1 f0 ff ff       	jmp    80105fc5 <alltraps>

80106ed4 <vector198>:
.globl vector198
vector198:
  pushl $0
80106ed4:	6a 00                	push   $0x0
  pushl $198
80106ed6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106edb:	e9 e5 f0 ff ff       	jmp    80105fc5 <alltraps>

80106ee0 <vector199>:
.globl vector199
vector199:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $199
80106ee2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106ee7:	e9 d9 f0 ff ff       	jmp    80105fc5 <alltraps>

80106eec <vector200>:
.globl vector200
vector200:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $200
80106eee:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106ef3:	e9 cd f0 ff ff       	jmp    80105fc5 <alltraps>

80106ef8 <vector201>:
.globl vector201
vector201:
  pushl $0
80106ef8:	6a 00                	push   $0x0
  pushl $201
80106efa:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106eff:	e9 c1 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f04 <vector202>:
.globl vector202
vector202:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $202
80106f06:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106f0b:	e9 b5 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f10 <vector203>:
.globl vector203
vector203:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $203
80106f12:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106f17:	e9 a9 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f1c <vector204>:
.globl vector204
vector204:
  pushl $0
80106f1c:	6a 00                	push   $0x0
  pushl $204
80106f1e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106f23:	e9 9d f0 ff ff       	jmp    80105fc5 <alltraps>

80106f28 <vector205>:
.globl vector205
vector205:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $205
80106f2a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106f2f:	e9 91 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f34 <vector206>:
.globl vector206
vector206:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $206
80106f36:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106f3b:	e9 85 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f40 <vector207>:
.globl vector207
vector207:
  pushl $0
80106f40:	6a 00                	push   $0x0
  pushl $207
80106f42:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106f47:	e9 79 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f4c <vector208>:
.globl vector208
vector208:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $208
80106f4e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106f53:	e9 6d f0 ff ff       	jmp    80105fc5 <alltraps>

80106f58 <vector209>:
.globl vector209
vector209:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $209
80106f5a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106f5f:	e9 61 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f64 <vector210>:
.globl vector210
vector210:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $210
80106f66:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106f6b:	e9 55 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f70 <vector211>:
.globl vector211
vector211:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $211
80106f72:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106f77:	e9 49 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f7c <vector212>:
.globl vector212
vector212:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $212
80106f7e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106f83:	e9 3d f0 ff ff       	jmp    80105fc5 <alltraps>

80106f88 <vector213>:
.globl vector213
vector213:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $213
80106f8a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106f8f:	e9 31 f0 ff ff       	jmp    80105fc5 <alltraps>

80106f94 <vector214>:
.globl vector214
vector214:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $214
80106f96:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106f9b:	e9 25 f0 ff ff       	jmp    80105fc5 <alltraps>

80106fa0 <vector215>:
.globl vector215
vector215:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $215
80106fa2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106fa7:	e9 19 f0 ff ff       	jmp    80105fc5 <alltraps>

80106fac <vector216>:
.globl vector216
vector216:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $216
80106fae:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106fb3:	e9 0d f0 ff ff       	jmp    80105fc5 <alltraps>

80106fb8 <vector217>:
.globl vector217
vector217:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $217
80106fba:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106fbf:	e9 01 f0 ff ff       	jmp    80105fc5 <alltraps>

80106fc4 <vector218>:
.globl vector218
vector218:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $218
80106fc6:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106fcb:	e9 f5 ef ff ff       	jmp    80105fc5 <alltraps>

80106fd0 <vector219>:
.globl vector219
vector219:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $219
80106fd2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106fd7:	e9 e9 ef ff ff       	jmp    80105fc5 <alltraps>

80106fdc <vector220>:
.globl vector220
vector220:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $220
80106fde:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106fe3:	e9 dd ef ff ff       	jmp    80105fc5 <alltraps>

80106fe8 <vector221>:
.globl vector221
vector221:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $221
80106fea:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106fef:	e9 d1 ef ff ff       	jmp    80105fc5 <alltraps>

80106ff4 <vector222>:
.globl vector222
vector222:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $222
80106ff6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106ffb:	e9 c5 ef ff ff       	jmp    80105fc5 <alltraps>

80107000 <vector223>:
.globl vector223
vector223:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $223
80107002:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107007:	e9 b9 ef ff ff       	jmp    80105fc5 <alltraps>

8010700c <vector224>:
.globl vector224
vector224:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $224
8010700e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107013:	e9 ad ef ff ff       	jmp    80105fc5 <alltraps>

80107018 <vector225>:
.globl vector225
vector225:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $225
8010701a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010701f:	e9 a1 ef ff ff       	jmp    80105fc5 <alltraps>

80107024 <vector226>:
.globl vector226
vector226:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $226
80107026:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010702b:	e9 95 ef ff ff       	jmp    80105fc5 <alltraps>

80107030 <vector227>:
.globl vector227
vector227:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $227
80107032:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107037:	e9 89 ef ff ff       	jmp    80105fc5 <alltraps>

8010703c <vector228>:
.globl vector228
vector228:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $228
8010703e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107043:	e9 7d ef ff ff       	jmp    80105fc5 <alltraps>

80107048 <vector229>:
.globl vector229
vector229:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $229
8010704a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010704f:	e9 71 ef ff ff       	jmp    80105fc5 <alltraps>

80107054 <vector230>:
.globl vector230
vector230:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $230
80107056:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010705b:	e9 65 ef ff ff       	jmp    80105fc5 <alltraps>

80107060 <vector231>:
.globl vector231
vector231:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $231
80107062:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107067:	e9 59 ef ff ff       	jmp    80105fc5 <alltraps>

8010706c <vector232>:
.globl vector232
vector232:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $232
8010706e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107073:	e9 4d ef ff ff       	jmp    80105fc5 <alltraps>

80107078 <vector233>:
.globl vector233
vector233:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $233
8010707a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010707f:	e9 41 ef ff ff       	jmp    80105fc5 <alltraps>

80107084 <vector234>:
.globl vector234
vector234:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $234
80107086:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010708b:	e9 35 ef ff ff       	jmp    80105fc5 <alltraps>

80107090 <vector235>:
.globl vector235
vector235:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $235
80107092:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107097:	e9 29 ef ff ff       	jmp    80105fc5 <alltraps>

8010709c <vector236>:
.globl vector236
vector236:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $236
8010709e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801070a3:	e9 1d ef ff ff       	jmp    80105fc5 <alltraps>

801070a8 <vector237>:
.globl vector237
vector237:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $237
801070aa:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801070af:	e9 11 ef ff ff       	jmp    80105fc5 <alltraps>

801070b4 <vector238>:
.globl vector238
vector238:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $238
801070b6:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801070bb:	e9 05 ef ff ff       	jmp    80105fc5 <alltraps>

801070c0 <vector239>:
.globl vector239
vector239:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $239
801070c2:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801070c7:	e9 f9 ee ff ff       	jmp    80105fc5 <alltraps>

801070cc <vector240>:
.globl vector240
vector240:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $240
801070ce:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801070d3:	e9 ed ee ff ff       	jmp    80105fc5 <alltraps>

801070d8 <vector241>:
.globl vector241
vector241:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $241
801070da:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801070df:	e9 e1 ee ff ff       	jmp    80105fc5 <alltraps>

801070e4 <vector242>:
.globl vector242
vector242:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $242
801070e6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801070eb:	e9 d5 ee ff ff       	jmp    80105fc5 <alltraps>

801070f0 <vector243>:
.globl vector243
vector243:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $243
801070f2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801070f7:	e9 c9 ee ff ff       	jmp    80105fc5 <alltraps>

801070fc <vector244>:
.globl vector244
vector244:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $244
801070fe:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107103:	e9 bd ee ff ff       	jmp    80105fc5 <alltraps>

80107108 <vector245>:
.globl vector245
vector245:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $245
8010710a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010710f:	e9 b1 ee ff ff       	jmp    80105fc5 <alltraps>

80107114 <vector246>:
.globl vector246
vector246:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $246
80107116:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010711b:	e9 a5 ee ff ff       	jmp    80105fc5 <alltraps>

80107120 <vector247>:
.globl vector247
vector247:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $247
80107122:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107127:	e9 99 ee ff ff       	jmp    80105fc5 <alltraps>

8010712c <vector248>:
.globl vector248
vector248:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $248
8010712e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107133:	e9 8d ee ff ff       	jmp    80105fc5 <alltraps>

80107138 <vector249>:
.globl vector249
vector249:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $249
8010713a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010713f:	e9 81 ee ff ff       	jmp    80105fc5 <alltraps>

80107144 <vector250>:
.globl vector250
vector250:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $250
80107146:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010714b:	e9 75 ee ff ff       	jmp    80105fc5 <alltraps>

80107150 <vector251>:
.globl vector251
vector251:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $251
80107152:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107157:	e9 69 ee ff ff       	jmp    80105fc5 <alltraps>

8010715c <vector252>:
.globl vector252
vector252:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $252
8010715e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107163:	e9 5d ee ff ff       	jmp    80105fc5 <alltraps>

80107168 <vector253>:
.globl vector253
vector253:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $253
8010716a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010716f:	e9 51 ee ff ff       	jmp    80105fc5 <alltraps>

80107174 <vector254>:
.globl vector254
vector254:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $254
80107176:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010717b:	e9 45 ee ff ff       	jmp    80105fc5 <alltraps>

80107180 <vector255>:
.globl vector255
vector255:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $255
80107182:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107187:	e9 39 ee ff ff       	jmp    80105fc5 <alltraps>

8010718c <lgdt>:
{
8010718c:	55                   	push   %ebp
8010718d:	89 e5                	mov    %esp,%ebp
8010718f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107192:	8b 45 0c             	mov    0xc(%ebp),%eax
80107195:	83 e8 01             	sub    $0x1,%eax
80107198:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010719c:	8b 45 08             	mov    0x8(%ebp),%eax
8010719f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071a3:	8b 45 08             	mov    0x8(%ebp),%eax
801071a6:	c1 e8 10             	shr    $0x10,%eax
801071a9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801071ad:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071b0:	0f 01 10             	lgdtl  (%eax)
}
801071b3:	90                   	nop
801071b4:	c9                   	leave  
801071b5:	c3                   	ret    

801071b6 <ltr>:
{
801071b6:	55                   	push   %ebp
801071b7:	89 e5                	mov    %esp,%ebp
801071b9:	83 ec 04             	sub    $0x4,%esp
801071bc:	8b 45 08             	mov    0x8(%ebp),%eax
801071bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801071c3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801071c7:	0f 00 d8             	ltr    %ax
}
801071ca:	90                   	nop
801071cb:	c9                   	leave  
801071cc:	c3                   	ret    

801071cd <lcr3>:

static inline void
lcr3(uint val)
{
801071cd:	55                   	push   %ebp
801071ce:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801071d0:	8b 45 08             	mov    0x8(%ebp),%eax
801071d3:	0f 22 d8             	mov    %eax,%cr3
}
801071d6:	90                   	nop
801071d7:	5d                   	pop    %ebp
801071d8:	c3                   	ret    

801071d9 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801071d9:	f3 0f 1e fb          	endbr32 
801071dd:	55                   	push   %ebp
801071de:	89 e5                	mov    %esp,%ebp
801071e0:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801071e3:	e8 26 c9 ff ff       	call   80103b0e <cpuid>
801071e8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801071ee:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801071f3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801071f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801071ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107202:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010720f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107212:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107216:	83 e2 f0             	and    $0xfffffff0,%edx
80107219:	83 ca 0a             	or     $0xa,%edx
8010721c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010721f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107222:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107226:	83 ca 10             	or     $0x10,%edx
80107229:	88 50 7d             	mov    %dl,0x7d(%eax)
8010722c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107233:	83 e2 9f             	and    $0xffffff9f,%edx
80107236:	88 50 7d             	mov    %dl,0x7d(%eax)
80107239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107240:	83 ca 80             	or     $0xffffff80,%edx
80107243:	88 50 7d             	mov    %dl,0x7d(%eax)
80107246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107249:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010724d:	83 ca 0f             	or     $0xf,%edx
80107250:	88 50 7e             	mov    %dl,0x7e(%eax)
80107253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107256:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010725a:	83 e2 ef             	and    $0xffffffef,%edx
8010725d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107263:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107267:	83 e2 df             	and    $0xffffffdf,%edx
8010726a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010726d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107270:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107274:	83 ca 40             	or     $0x40,%edx
80107277:	88 50 7e             	mov    %dl,0x7e(%eax)
8010727a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107281:	83 ca 80             	or     $0xffffff80,%edx
80107284:	88 50 7e             	mov    %dl,0x7e(%eax)
80107287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728a:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010728e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107291:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107298:	ff ff 
8010729a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729d:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801072a4:	00 00 
801072a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a9:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801072b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072ba:	83 e2 f0             	and    $0xfffffff0,%edx
801072bd:	83 ca 02             	or     $0x2,%edx
801072c0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072d0:	83 ca 10             	or     $0x10,%edx
801072d3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072dc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072e3:	83 e2 9f             	and    $0xffffff9f,%edx
801072e6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ef:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072f6:	83 ca 80             	or     $0xffffff80,%edx
801072f9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107302:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107309:	83 ca 0f             	or     $0xf,%edx
8010730c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107315:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010731c:	83 e2 ef             	and    $0xffffffef,%edx
8010731f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107328:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010732f:	83 e2 df             	and    $0xffffffdf,%edx
80107332:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107342:	83 ca 40             	or     $0x40,%edx
80107345:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010734b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107355:	83 ca 80             	or     $0xffffff80,%edx
80107358:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010735e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107361:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736b:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107372:	ff ff 
80107374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107377:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010737e:	00 00 
80107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107383:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010738a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107394:	83 e2 f0             	and    $0xfffffff0,%edx
80107397:	83 ca 0a             	or     $0xa,%edx
8010739a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073aa:	83 ca 10             	or     $0x10,%edx
801073ad:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073bd:	83 ca 60             	or     $0x60,%edx
801073c0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073d0:	83 ca 80             	or     $0xffffff80,%edx
801073d3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073dc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801073e3:	83 ca 0f             	or     $0xf,%edx
801073e6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801073ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ef:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801073f6:	83 e2 ef             	and    $0xffffffef,%edx
801073f9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107409:	83 e2 df             	and    $0xffffffdf,%edx
8010740c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107415:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010741c:	83 ca 40             	or     $0x40,%edx
8010741f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107428:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010742f:	83 ca 80             	or     $0xffffff80,%edx
80107432:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743b:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107445:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010744c:	ff ff 
8010744e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107451:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107458:	00 00 
8010745a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107467:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010746e:	83 e2 f0             	and    $0xfffffff0,%edx
80107471:	83 ca 02             	or     $0x2,%edx
80107474:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010747a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107484:	83 ca 10             	or     $0x10,%edx
80107487:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010748d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107490:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107497:	83 ca 60             	or     $0x60,%edx
8010749a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074aa:	83 ca 80             	or     $0xffffff80,%edx
801074ad:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074bd:	83 ca 0f             	or     $0xf,%edx
801074c0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074d0:	83 e2 ef             	and    $0xffffffef,%edx
801074d3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074e3:	83 e2 df             	and    $0xffffffdf,%edx
801074e6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ef:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074f6:	83 ca 40             	or     $0x40,%edx
801074f9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107502:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107509:	83 ca 80             	or     $0xffffff80,%edx
8010750c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107515:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010751c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751f:	83 c0 70             	add    $0x70,%eax
80107522:	83 ec 08             	sub    $0x8,%esp
80107525:	6a 30                	push   $0x30
80107527:	50                   	push   %eax
80107528:	e8 5f fc ff ff       	call   8010718c <lgdt>
8010752d:	83 c4 10             	add    $0x10,%esp
}
80107530:	90                   	nop
80107531:	c9                   	leave  
80107532:	c3                   	ret    

80107533 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107533:	f3 0f 1e fb          	endbr32 
80107537:	55                   	push   %ebp
80107538:	89 e5                	mov    %esp,%ebp
8010753a:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010753d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107540:	c1 e8 16             	shr    $0x16,%eax
80107543:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010754a:	8b 45 08             	mov    0x8(%ebp),%eax
8010754d:	01 d0                	add    %edx,%eax
8010754f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107555:	8b 00                	mov    (%eax),%eax
80107557:	83 e0 01             	and    $0x1,%eax
8010755a:	85 c0                	test   %eax,%eax
8010755c:	74 14                	je     80107572 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010755e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107561:	8b 00                	mov    (%eax),%eax
80107563:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107568:	05 00 00 00 80       	add    $0x80000000,%eax
8010756d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107570:	eb 42                	jmp    801075b4 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107572:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107576:	74 0e                	je     80107586 <walkpgdir+0x53>
80107578:	e8 15 b3 ff ff       	call   80102892 <kalloc>
8010757d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107580:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107584:	75 07                	jne    8010758d <walkpgdir+0x5a>
      return 0;
80107586:	b8 00 00 00 00       	mov    $0x0,%eax
8010758b:	eb 3e                	jmp    801075cb <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010758d:	83 ec 04             	sub    $0x4,%esp
80107590:	68 00 10 00 00       	push   $0x1000
80107595:	6a 00                	push   $0x0
80107597:	ff 75 f4             	pushl  -0xc(%ebp)
8010759a:	e8 bf d5 ff ff       	call   80104b5e <memset>
8010759f:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801075a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a5:	05 00 00 00 80       	add    $0x80000000,%eax
801075aa:	83 c8 07             	or     $0x7,%eax
801075ad:	89 c2                	mov    %eax,%edx
801075af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075b2:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801075b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801075b7:	c1 e8 0c             	shr    $0xc,%eax
801075ba:	25 ff 03 00 00       	and    $0x3ff,%eax
801075bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801075c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c9:	01 d0                	add    %edx,%eax
}
801075cb:	c9                   	leave  
801075cc:	c3                   	ret    

801075cd <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801075cd:	f3 0f 1e fb          	endbr32 
801075d1:	55                   	push   %ebp
801075d2:	89 e5                	mov    %esp,%ebp
801075d4:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801075d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801075da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801075e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801075e5:	8b 45 10             	mov    0x10(%ebp),%eax
801075e8:	01 d0                	add    %edx,%eax
801075ea:	83 e8 01             	sub    $0x1,%eax
801075ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801075f5:	83 ec 04             	sub    $0x4,%esp
801075f8:	6a 01                	push   $0x1
801075fa:	ff 75 f4             	pushl  -0xc(%ebp)
801075fd:	ff 75 08             	pushl  0x8(%ebp)
80107600:	e8 2e ff ff ff       	call   80107533 <walkpgdir>
80107605:	83 c4 10             	add    $0x10,%esp
80107608:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010760b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010760f:	75 07                	jne    80107618 <mappages+0x4b>
      return -1;
80107611:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107616:	eb 47                	jmp    8010765f <mappages+0x92>
    if(*pte & PTE_P)
80107618:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010761b:	8b 00                	mov    (%eax),%eax
8010761d:	83 e0 01             	and    $0x1,%eax
80107620:	85 c0                	test   %eax,%eax
80107622:	74 0d                	je     80107631 <mappages+0x64>
      panic("remap");
80107624:	83 ec 0c             	sub    $0xc,%esp
80107627:	68 7c aa 10 80       	push   $0x8010aa7c
8010762c:	e8 94 8f ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107631:	8b 45 18             	mov    0x18(%ebp),%eax
80107634:	0b 45 14             	or     0x14(%ebp),%eax
80107637:	83 c8 01             	or     $0x1,%eax
8010763a:	89 c2                	mov    %eax,%edx
8010763c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010763f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107644:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107647:	74 10                	je     80107659 <mappages+0x8c>
      break;
    a += PGSIZE;
80107649:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107650:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107657:	eb 9c                	jmp    801075f5 <mappages+0x28>
      break;
80107659:	90                   	nop
  }
  return 0;
8010765a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010765f:	c9                   	leave  
80107660:	c3                   	ret    

80107661 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107661:	f3 0f 1e fb          	endbr32 
80107665:	55                   	push   %ebp
80107666:	89 e5                	mov    %esp,%ebp
80107668:	53                   	push   %ebx
80107669:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010766c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107673:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107678:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010767d:	29 c2                	sub    %eax,%edx
8010767f:	89 d0                	mov    %edx,%eax
80107681:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107684:	a1 84 80 19 80       	mov    0x80198084,%eax
80107689:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010768c:	8b 15 84 80 19 80    	mov    0x80198084,%edx
80107692:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107697:	01 d0                	add    %edx,%eax
80107699:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010769c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801076a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a6:	83 c0 30             	add    $0x30,%eax
801076a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801076ac:	89 10                	mov    %edx,(%eax)
801076ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801076b1:	89 50 04             	mov    %edx,0x4(%eax)
801076b4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076b7:	89 50 08             	mov    %edx,0x8(%eax)
801076ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
801076bd:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801076c0:	e8 cd b1 ff ff       	call   80102892 <kalloc>
801076c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076cc:	75 07                	jne    801076d5 <setupkvm+0x74>
    return 0;
801076ce:	b8 00 00 00 00       	mov    $0x0,%eax
801076d3:	eb 78                	jmp    8010774d <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801076d5:	83 ec 04             	sub    $0x4,%esp
801076d8:	68 00 10 00 00       	push   $0x1000
801076dd:	6a 00                	push   $0x0
801076df:	ff 75 f0             	pushl  -0x10(%ebp)
801076e2:	e8 77 d4 ff ff       	call   80104b5e <memset>
801076e7:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801076ea:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801076f1:	eb 4e                	jmp    80107741 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801076f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801076f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fc:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801076ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107702:	8b 58 08             	mov    0x8(%eax),%ebx
80107705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107708:	8b 40 04             	mov    0x4(%eax),%eax
8010770b:	29 c3                	sub    %eax,%ebx
8010770d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107710:	8b 00                	mov    (%eax),%eax
80107712:	83 ec 0c             	sub    $0xc,%esp
80107715:	51                   	push   %ecx
80107716:	52                   	push   %edx
80107717:	53                   	push   %ebx
80107718:	50                   	push   %eax
80107719:	ff 75 f0             	pushl  -0x10(%ebp)
8010771c:	e8 ac fe ff ff       	call   801075cd <mappages>
80107721:	83 c4 20             	add    $0x20,%esp
80107724:	85 c0                	test   %eax,%eax
80107726:	79 15                	jns    8010773d <setupkvm+0xdc>
      freevm(pgdir);
80107728:	83 ec 0c             	sub    $0xc,%esp
8010772b:	ff 75 f0             	pushl  -0x10(%ebp)
8010772e:	e8 11 05 00 00       	call   80107c44 <freevm>
80107733:	83 c4 10             	add    $0x10,%esp
      return 0;
80107736:	b8 00 00 00 00       	mov    $0x0,%eax
8010773b:	eb 10                	jmp    8010774d <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010773d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107741:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107748:	72 a9                	jb     801076f3 <setupkvm+0x92>
    }
  return pgdir;
8010774a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010774d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107750:	c9                   	leave  
80107751:	c3                   	ret    

80107752 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107752:	f3 0f 1e fb          	endbr32 
80107756:	55                   	push   %ebp
80107757:	89 e5                	mov    %esp,%ebp
80107759:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010775c:	e8 00 ff ff ff       	call   80107661 <setupkvm>
80107761:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
80107766:	e8 03 00 00 00       	call   8010776e <switchkvm>
}
8010776b:	90                   	nop
8010776c:	c9                   	leave  
8010776d:	c3                   	ret    

8010776e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010776e:	f3 0f 1e fb          	endbr32 
80107772:	55                   	push   %ebp
80107773:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107775:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010777a:	05 00 00 00 80       	add    $0x80000000,%eax
8010777f:	50                   	push   %eax
80107780:	e8 48 fa ff ff       	call   801071cd <lcr3>
80107785:	83 c4 04             	add    $0x4,%esp
}
80107788:	90                   	nop
80107789:	c9                   	leave  
8010778a:	c3                   	ret    

8010778b <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010778b:	f3 0f 1e fb          	endbr32 
8010778f:	55                   	push   %ebp
80107790:	89 e5                	mov    %esp,%ebp
80107792:	56                   	push   %esi
80107793:	53                   	push   %ebx
80107794:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107797:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010779b:	75 0d                	jne    801077aa <switchuvm+0x1f>
    panic("switchuvm: no process");
8010779d:	83 ec 0c             	sub    $0xc,%esp
801077a0:	68 82 aa 10 80       	push   $0x8010aa82
801077a5:	e8 1b 8e ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
801077aa:	8b 45 08             	mov    0x8(%ebp),%eax
801077ad:	8b 40 08             	mov    0x8(%eax),%eax
801077b0:	85 c0                	test   %eax,%eax
801077b2:	75 0d                	jne    801077c1 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801077b4:	83 ec 0c             	sub    $0xc,%esp
801077b7:	68 98 aa 10 80       	push   $0x8010aa98
801077bc:	e8 04 8e ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
801077c1:	8b 45 08             	mov    0x8(%ebp),%eax
801077c4:	8b 40 04             	mov    0x4(%eax),%eax
801077c7:	85 c0                	test   %eax,%eax
801077c9:	75 0d                	jne    801077d8 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801077cb:	83 ec 0c             	sub    $0xc,%esp
801077ce:	68 ad aa 10 80       	push   $0x8010aaad
801077d3:	e8 ed 8d ff ff       	call   801005c5 <panic>

  pushcli();
801077d8:	e8 6e d2 ff ff       	call   80104a4b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801077dd:	e8 4b c3 ff ff       	call   80103b2d <mycpu>
801077e2:	89 c3                	mov    %eax,%ebx
801077e4:	e8 44 c3 ff ff       	call   80103b2d <mycpu>
801077e9:	83 c0 08             	add    $0x8,%eax
801077ec:	89 c6                	mov    %eax,%esi
801077ee:	e8 3a c3 ff ff       	call   80103b2d <mycpu>
801077f3:	83 c0 08             	add    $0x8,%eax
801077f6:	c1 e8 10             	shr    $0x10,%eax
801077f9:	88 45 f7             	mov    %al,-0x9(%ebp)
801077fc:	e8 2c c3 ff ff       	call   80103b2d <mycpu>
80107801:	83 c0 08             	add    $0x8,%eax
80107804:	c1 e8 18             	shr    $0x18,%eax
80107807:	89 c2                	mov    %eax,%edx
80107809:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107810:	67 00 
80107812:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107819:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010781d:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107823:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010782a:	83 e0 f0             	and    $0xfffffff0,%eax
8010782d:	83 c8 09             	or     $0x9,%eax
80107830:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107836:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010783d:	83 c8 10             	or     $0x10,%eax
80107840:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107846:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010784d:	83 e0 9f             	and    $0xffffff9f,%eax
80107850:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107856:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010785d:	83 c8 80             	or     $0xffffff80,%eax
80107860:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107866:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010786d:	83 e0 f0             	and    $0xfffffff0,%eax
80107870:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107876:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010787d:	83 e0 ef             	and    $0xffffffef,%eax
80107880:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107886:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010788d:	83 e0 df             	and    $0xffffffdf,%eax
80107890:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107896:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010789d:	83 c8 40             	or     $0x40,%eax
801078a0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078a6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078ad:	83 e0 7f             	and    $0x7f,%eax
801078b0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078b6:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801078bc:	e8 6c c2 ff ff       	call   80103b2d <mycpu>
801078c1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801078c8:	83 e2 ef             	and    $0xffffffef,%edx
801078cb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801078d1:	e8 57 c2 ff ff       	call   80103b2d <mycpu>
801078d6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801078dc:	8b 45 08             	mov    0x8(%ebp),%eax
801078df:	8b 40 08             	mov    0x8(%eax),%eax
801078e2:	89 c3                	mov    %eax,%ebx
801078e4:	e8 44 c2 ff ff       	call   80103b2d <mycpu>
801078e9:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801078ef:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801078f2:	e8 36 c2 ff ff       	call   80103b2d <mycpu>
801078f7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801078fd:	83 ec 0c             	sub    $0xc,%esp
80107900:	6a 28                	push   $0x28
80107902:	e8 af f8 ff ff       	call   801071b6 <ltr>
80107907:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010790a:	8b 45 08             	mov    0x8(%ebp),%eax
8010790d:	8b 40 04             	mov    0x4(%eax),%eax
80107910:	05 00 00 00 80       	add    $0x80000000,%eax
80107915:	83 ec 0c             	sub    $0xc,%esp
80107918:	50                   	push   %eax
80107919:	e8 af f8 ff ff       	call   801071cd <lcr3>
8010791e:	83 c4 10             	add    $0x10,%esp
  popcli();
80107921:	e8 76 d1 ff ff       	call   80104a9c <popcli>
}
80107926:	90                   	nop
80107927:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010792a:	5b                   	pop    %ebx
8010792b:	5e                   	pop    %esi
8010792c:	5d                   	pop    %ebp
8010792d:	c3                   	ret    

8010792e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010792e:	f3 0f 1e fb          	endbr32 
80107932:	55                   	push   %ebp
80107933:	89 e5                	mov    %esp,%ebp
80107935:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107938:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010793f:	76 0d                	jbe    8010794e <inituvm+0x20>
    panic("inituvm: more than a page");
80107941:	83 ec 0c             	sub    $0xc,%esp
80107944:	68 c1 aa 10 80       	push   $0x8010aac1
80107949:	e8 77 8c ff ff       	call   801005c5 <panic>
  mem = kalloc();
8010794e:	e8 3f af ff ff       	call   80102892 <kalloc>
80107953:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107956:	83 ec 04             	sub    $0x4,%esp
80107959:	68 00 10 00 00       	push   $0x1000
8010795e:	6a 00                	push   $0x0
80107960:	ff 75 f4             	pushl  -0xc(%ebp)
80107963:	e8 f6 d1 ff ff       	call   80104b5e <memset>
80107968:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010796b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796e:	05 00 00 00 80       	add    $0x80000000,%eax
80107973:	83 ec 0c             	sub    $0xc,%esp
80107976:	6a 06                	push   $0x6
80107978:	50                   	push   %eax
80107979:	68 00 10 00 00       	push   $0x1000
8010797e:	6a 00                	push   $0x0
80107980:	ff 75 08             	pushl  0x8(%ebp)
80107983:	e8 45 fc ff ff       	call   801075cd <mappages>
80107988:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010798b:	83 ec 04             	sub    $0x4,%esp
8010798e:	ff 75 10             	pushl  0x10(%ebp)
80107991:	ff 75 0c             	pushl  0xc(%ebp)
80107994:	ff 75 f4             	pushl  -0xc(%ebp)
80107997:	e8 89 d2 ff ff       	call   80104c25 <memmove>
8010799c:	83 c4 10             	add    $0x10,%esp
}
8010799f:	90                   	nop
801079a0:	c9                   	leave  
801079a1:	c3                   	ret    

801079a2 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801079a2:	f3 0f 1e fb          	endbr32 
801079a6:	55                   	push   %ebp
801079a7:	89 e5                	mov    %esp,%ebp
801079a9:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801079ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801079af:	25 ff 0f 00 00       	and    $0xfff,%eax
801079b4:	85 c0                	test   %eax,%eax
801079b6:	74 0d                	je     801079c5 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801079b8:	83 ec 0c             	sub    $0xc,%esp
801079bb:	68 dc aa 10 80       	push   $0x8010aadc
801079c0:	e8 00 8c ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801079c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079cc:	e9 8f 00 00 00       	jmp    80107a60 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801079d1:	8b 55 0c             	mov    0xc(%ebp),%edx
801079d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d7:	01 d0                	add    %edx,%eax
801079d9:	83 ec 04             	sub    $0x4,%esp
801079dc:	6a 00                	push   $0x0
801079de:	50                   	push   %eax
801079df:	ff 75 08             	pushl  0x8(%ebp)
801079e2:	e8 4c fb ff ff       	call   80107533 <walkpgdir>
801079e7:	83 c4 10             	add    $0x10,%esp
801079ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079f1:	75 0d                	jne    80107a00 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801079f3:	83 ec 0c             	sub    $0xc,%esp
801079f6:	68 ff aa 10 80       	push   $0x8010aaff
801079fb:	e8 c5 8b ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107a00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a03:	8b 00                	mov    (%eax),%eax
80107a05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107a0d:	8b 45 18             	mov    0x18(%ebp),%eax
80107a10:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a13:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107a18:	77 0b                	ja     80107a25 <loaduvm+0x83>
      n = sz - i;
80107a1a:	8b 45 18             	mov    0x18(%ebp),%eax
80107a1d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a23:	eb 07                	jmp    80107a2c <loaduvm+0x8a>
    else
      n = PGSIZE;
80107a25:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107a2c:	8b 55 14             	mov    0x14(%ebp),%edx
80107a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a32:	01 d0                	add    %edx,%eax
80107a34:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a37:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107a3d:	ff 75 f0             	pushl  -0x10(%ebp)
80107a40:	50                   	push   %eax
80107a41:	52                   	push   %edx
80107a42:	ff 75 10             	pushl  0x10(%ebp)
80107a45:	e8 3a a5 ff ff       	call   80101f84 <readi>
80107a4a:	83 c4 10             	add    $0x10,%esp
80107a4d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107a50:	74 07                	je     80107a59 <loaduvm+0xb7>
      return -1;
80107a52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a57:	eb 18                	jmp    80107a71 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107a59:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	3b 45 18             	cmp    0x18(%ebp),%eax
80107a66:	0f 82 65 ff ff ff    	jb     801079d1 <loaduvm+0x2f>
  }
  return 0;
80107a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a71:	c9                   	leave  
80107a72:	c3                   	ret    

80107a73 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a73:	f3 0f 1e fb          	endbr32 
80107a77:	55                   	push   %ebp
80107a78:	89 e5                	mov    %esp,%ebp
80107a7a:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107a7d:	8b 45 10             	mov    0x10(%ebp),%eax
80107a80:	85 c0                	test   %eax,%eax
80107a82:	79 0a                	jns    80107a8e <allocuvm+0x1b>
    return 0;
80107a84:	b8 00 00 00 00       	mov    $0x0,%eax
80107a89:	e9 ec 00 00 00       	jmp    80107b7a <allocuvm+0x107>
  if(newsz < oldsz)
80107a8e:	8b 45 10             	mov    0x10(%ebp),%eax
80107a91:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a94:	73 08                	jae    80107a9e <allocuvm+0x2b>
    return oldsz;
80107a96:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a99:	e9 dc 00 00 00       	jmp    80107b7a <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aa1:	05 ff 0f 00 00       	add    $0xfff,%eax
80107aa6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107aae:	e9 b8 00 00 00       	jmp    80107b6b <allocuvm+0xf8>
    mem = kalloc();
80107ab3:	e8 da ad ff ff       	call   80102892 <kalloc>
80107ab8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107abb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107abf:	75 2e                	jne    80107aef <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107ac1:	83 ec 0c             	sub    $0xc,%esp
80107ac4:	68 1d ab 10 80       	push   $0x8010ab1d
80107ac9:	e8 3e 89 ff ff       	call   8010040c <cprintf>
80107ace:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ad1:	83 ec 04             	sub    $0x4,%esp
80107ad4:	ff 75 0c             	pushl  0xc(%ebp)
80107ad7:	ff 75 10             	pushl  0x10(%ebp)
80107ada:	ff 75 08             	pushl  0x8(%ebp)
80107add:	e8 9a 00 00 00       	call   80107b7c <deallocuvm>
80107ae2:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ae5:	b8 00 00 00 00       	mov    $0x0,%eax
80107aea:	e9 8b 00 00 00       	jmp    80107b7a <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107aef:	83 ec 04             	sub    $0x4,%esp
80107af2:	68 00 10 00 00       	push   $0x1000
80107af7:	6a 00                	push   $0x0
80107af9:	ff 75 f0             	pushl  -0x10(%ebp)
80107afc:	e8 5d d0 ff ff       	call   80104b5e <memset>
80107b01:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b07:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b10:	83 ec 0c             	sub    $0xc,%esp
80107b13:	6a 06                	push   $0x6
80107b15:	52                   	push   %edx
80107b16:	68 00 10 00 00       	push   $0x1000
80107b1b:	50                   	push   %eax
80107b1c:	ff 75 08             	pushl  0x8(%ebp)
80107b1f:	e8 a9 fa ff ff       	call   801075cd <mappages>
80107b24:	83 c4 20             	add    $0x20,%esp
80107b27:	85 c0                	test   %eax,%eax
80107b29:	79 39                	jns    80107b64 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107b2b:	83 ec 0c             	sub    $0xc,%esp
80107b2e:	68 35 ab 10 80       	push   $0x8010ab35
80107b33:	e8 d4 88 ff ff       	call   8010040c <cprintf>
80107b38:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107b3b:	83 ec 04             	sub    $0x4,%esp
80107b3e:	ff 75 0c             	pushl  0xc(%ebp)
80107b41:	ff 75 10             	pushl  0x10(%ebp)
80107b44:	ff 75 08             	pushl  0x8(%ebp)
80107b47:	e8 30 00 00 00       	call   80107b7c <deallocuvm>
80107b4c:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107b4f:	83 ec 0c             	sub    $0xc,%esp
80107b52:	ff 75 f0             	pushl  -0x10(%ebp)
80107b55:	e8 9a ac ff ff       	call   801027f4 <kfree>
80107b5a:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b5d:	b8 00 00 00 00       	mov    $0x0,%eax
80107b62:	eb 16                	jmp    80107b7a <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107b64:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	3b 45 10             	cmp    0x10(%ebp),%eax
80107b71:	0f 82 3c ff ff ff    	jb     80107ab3 <allocuvm+0x40>
    }
  }
  return newsz;
80107b77:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107b7a:	c9                   	leave  
80107b7b:	c3                   	ret    

80107b7c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107b7c:	f3 0f 1e fb          	endbr32 
80107b80:	55                   	push   %ebp
80107b81:	89 e5                	mov    %esp,%ebp
80107b83:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107b86:	8b 45 10             	mov    0x10(%ebp),%eax
80107b89:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b8c:	72 08                	jb     80107b96 <deallocuvm+0x1a>
    return oldsz;
80107b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b91:	e9 ac 00 00 00       	jmp    80107c42 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107b96:	8b 45 10             	mov    0x10(%ebp),%eax
80107b99:	05 ff 0f 00 00       	add    $0xfff,%eax
80107b9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107ba6:	e9 88 00 00 00       	jmp    80107c33 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	83 ec 04             	sub    $0x4,%esp
80107bb1:	6a 00                	push   $0x0
80107bb3:	50                   	push   %eax
80107bb4:	ff 75 08             	pushl  0x8(%ebp)
80107bb7:	e8 77 f9 ff ff       	call   80107533 <walkpgdir>
80107bbc:	83 c4 10             	add    $0x10,%esp
80107bbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107bc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bc6:	75 16                	jne    80107bde <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	c1 e8 16             	shr    $0x16,%eax
80107bce:	83 c0 01             	add    $0x1,%eax
80107bd1:	c1 e0 16             	shl    $0x16,%eax
80107bd4:	2d 00 10 00 00       	sub    $0x1000,%eax
80107bd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bdc:	eb 4e                	jmp    80107c2c <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be1:	8b 00                	mov    (%eax),%eax
80107be3:	83 e0 01             	and    $0x1,%eax
80107be6:	85 c0                	test   %eax,%eax
80107be8:	74 42                	je     80107c2c <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bed:	8b 00                	mov    (%eax),%eax
80107bef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107bf7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bfb:	75 0d                	jne    80107c0a <deallocuvm+0x8e>
        panic("kfree");
80107bfd:	83 ec 0c             	sub    $0xc,%esp
80107c00:	68 51 ab 10 80       	push   $0x8010ab51
80107c05:	e8 bb 89 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107c0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c0d:	05 00 00 00 80       	add    $0x80000000,%eax
80107c12:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107c15:	83 ec 0c             	sub    $0xc,%esp
80107c18:	ff 75 e8             	pushl  -0x18(%ebp)
80107c1b:	e8 d4 ab ff ff       	call   801027f4 <kfree>
80107c20:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107c2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c36:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c39:	0f 82 6c ff ff ff    	jb     80107bab <deallocuvm+0x2f>
    }
  }
  return newsz;
80107c3f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107c42:	c9                   	leave  
80107c43:	c3                   	ret    

80107c44 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107c44:	f3 0f 1e fb          	endbr32 
80107c48:	55                   	push   %ebp
80107c49:	89 e5                	mov    %esp,%ebp
80107c4b:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107c4e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c52:	75 0d                	jne    80107c61 <freevm+0x1d>
    panic("freevm: no pgdir");
80107c54:	83 ec 0c             	sub    $0xc,%esp
80107c57:	68 57 ab 10 80       	push   $0x8010ab57
80107c5c:	e8 64 89 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107c61:	83 ec 04             	sub    $0x4,%esp
80107c64:	6a 00                	push   $0x0
80107c66:	68 00 00 00 80       	push   $0x80000000
80107c6b:	ff 75 08             	pushl  0x8(%ebp)
80107c6e:	e8 09 ff ff ff       	call   80107b7c <deallocuvm>
80107c73:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c7d:	eb 48                	jmp    80107cc7 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c89:	8b 45 08             	mov    0x8(%ebp),%eax
80107c8c:	01 d0                	add    %edx,%eax
80107c8e:	8b 00                	mov    (%eax),%eax
80107c90:	83 e0 01             	and    $0x1,%eax
80107c93:	85 c0                	test   %eax,%eax
80107c95:	74 2c                	je     80107cc3 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca4:	01 d0                	add    %edx,%eax
80107ca6:	8b 00                	mov    (%eax),%eax
80107ca8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cad:	05 00 00 00 80       	add    $0x80000000,%eax
80107cb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107cb5:	83 ec 0c             	sub    $0xc,%esp
80107cb8:	ff 75 f0             	pushl  -0x10(%ebp)
80107cbb:	e8 34 ab ff ff       	call   801027f4 <kfree>
80107cc0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107cc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cc7:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107cce:	76 af                	jbe    80107c7f <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107cd0:	83 ec 0c             	sub    $0xc,%esp
80107cd3:	ff 75 08             	pushl  0x8(%ebp)
80107cd6:	e8 19 ab ff ff       	call   801027f4 <kfree>
80107cdb:	83 c4 10             	add    $0x10,%esp
}
80107cde:	90                   	nop
80107cdf:	c9                   	leave  
80107ce0:	c3                   	ret    

80107ce1 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107ce1:	f3 0f 1e fb          	endbr32 
80107ce5:	55                   	push   %ebp
80107ce6:	89 e5                	mov    %esp,%ebp
80107ce8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107ceb:	83 ec 04             	sub    $0x4,%esp
80107cee:	6a 00                	push   $0x0
80107cf0:	ff 75 0c             	pushl  0xc(%ebp)
80107cf3:	ff 75 08             	pushl  0x8(%ebp)
80107cf6:	e8 38 f8 ff ff       	call   80107533 <walkpgdir>
80107cfb:	83 c4 10             	add    $0x10,%esp
80107cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107d01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d05:	75 0d                	jne    80107d14 <clearpteu+0x33>
    panic("clearpteu");
80107d07:	83 ec 0c             	sub    $0xc,%esp
80107d0a:	68 68 ab 10 80       	push   $0x8010ab68
80107d0f:	e8 b1 88 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d17:	8b 00                	mov    (%eax),%eax
80107d19:	83 e0 fb             	and    $0xfffffffb,%eax
80107d1c:	89 c2                	mov    %eax,%edx
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	89 10                	mov    %edx,(%eax)
}
80107d23:	90                   	nop
80107d24:	c9                   	leave  
80107d25:	c3                   	ret    

80107d26 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107d26:	f3 0f 1e fb          	endbr32 
80107d2a:	55                   	push   %ebp
80107d2b:	89 e5                	mov    %esp,%ebp
80107d2d:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107d30:	e8 2c f9 ff ff       	call   80107661 <setupkvm>
80107d35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d3c:	75 0a                	jne    80107d48 <copyuvm+0x22>
    return 0;
80107d3e:	b8 00 00 00 00       	mov    $0x0,%eax
80107d43:	e9 eb 00 00 00       	jmp    80107e33 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80107d48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d4f:	e9 b7 00 00 00       	jmp    80107e0b <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d57:	83 ec 04             	sub    $0x4,%esp
80107d5a:	6a 00                	push   $0x0
80107d5c:	50                   	push   %eax
80107d5d:	ff 75 08             	pushl  0x8(%ebp)
80107d60:	e8 ce f7 ff ff       	call   80107533 <walkpgdir>
80107d65:	83 c4 10             	add    $0x10,%esp
80107d68:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d6f:	75 0d                	jne    80107d7e <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80107d71:	83 ec 0c             	sub    $0xc,%esp
80107d74:	68 72 ab 10 80       	push   $0x8010ab72
80107d79:	e8 47 88 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80107d7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d81:	8b 00                	mov    (%eax),%eax
80107d83:	83 e0 01             	and    $0x1,%eax
80107d86:	85 c0                	test   %eax,%eax
80107d88:	75 0d                	jne    80107d97 <copyuvm+0x71>
      panic("copyuvm: page not present");
80107d8a:	83 ec 0c             	sub    $0xc,%esp
80107d8d:	68 8c ab 10 80       	push   $0x8010ab8c
80107d92:	e8 2e 88 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d9a:	8b 00                	mov    (%eax),%eax
80107d9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107da1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107da7:	8b 00                	mov    (%eax),%eax
80107da9:	25 ff 0f 00 00       	and    $0xfff,%eax
80107dae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107db1:	e8 dc aa ff ff       	call   80102892 <kalloc>
80107db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107db9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107dbd:	74 5d                	je     80107e1c <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107dbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107dc2:	05 00 00 00 80       	add    $0x80000000,%eax
80107dc7:	83 ec 04             	sub    $0x4,%esp
80107dca:	68 00 10 00 00       	push   $0x1000
80107dcf:	50                   	push   %eax
80107dd0:	ff 75 e0             	pushl  -0x20(%ebp)
80107dd3:	e8 4d ce ff ff       	call   80104c25 <memmove>
80107dd8:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107ddb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107dde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107de1:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dea:	83 ec 0c             	sub    $0xc,%esp
80107ded:	52                   	push   %edx
80107dee:	51                   	push   %ecx
80107def:	68 00 10 00 00       	push   $0x1000
80107df4:	50                   	push   %eax
80107df5:	ff 75 f0             	pushl  -0x10(%ebp)
80107df8:	e8 d0 f7 ff ff       	call   801075cd <mappages>
80107dfd:	83 c4 20             	add    $0x20,%esp
80107e00:	85 c0                	test   %eax,%eax
80107e02:	78 1b                	js     80107e1f <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80107e04:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e11:	0f 82 3d ff ff ff    	jb     80107d54 <copyuvm+0x2e>
      goto bad;
  }
  return d;
80107e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e1a:	eb 17                	jmp    80107e33 <copyuvm+0x10d>
      goto bad;
80107e1c:	90                   	nop
80107e1d:	eb 01                	jmp    80107e20 <copyuvm+0xfa>
      goto bad;
80107e1f:	90                   	nop

bad:
  freevm(d);
80107e20:	83 ec 0c             	sub    $0xc,%esp
80107e23:	ff 75 f0             	pushl  -0x10(%ebp)
80107e26:	e8 19 fe ff ff       	call   80107c44 <freevm>
80107e2b:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e33:	c9                   	leave  
80107e34:	c3                   	ret    

80107e35 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107e35:	f3 0f 1e fb          	endbr32 
80107e39:	55                   	push   %ebp
80107e3a:	89 e5                	mov    %esp,%ebp
80107e3c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e3f:	83 ec 04             	sub    $0x4,%esp
80107e42:	6a 00                	push   $0x0
80107e44:	ff 75 0c             	pushl  0xc(%ebp)
80107e47:	ff 75 08             	pushl  0x8(%ebp)
80107e4a:	e8 e4 f6 ff ff       	call   80107533 <walkpgdir>
80107e4f:	83 c4 10             	add    $0x10,%esp
80107e52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	8b 00                	mov    (%eax),%eax
80107e5a:	83 e0 01             	and    $0x1,%eax
80107e5d:	85 c0                	test   %eax,%eax
80107e5f:	75 07                	jne    80107e68 <uva2ka+0x33>
    return 0;
80107e61:	b8 00 00 00 00       	mov    $0x0,%eax
80107e66:	eb 22                	jmp    80107e8a <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	8b 00                	mov    (%eax),%eax
80107e6d:	83 e0 04             	and    $0x4,%eax
80107e70:	85 c0                	test   %eax,%eax
80107e72:	75 07                	jne    80107e7b <uva2ka+0x46>
    return 0;
80107e74:	b8 00 00 00 00       	mov    $0x0,%eax
80107e79:	eb 0f                	jmp    80107e8a <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	8b 00                	mov    (%eax),%eax
80107e80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e85:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107e8a:	c9                   	leave  
80107e8b:	c3                   	ret    

80107e8c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107e8c:	f3 0f 1e fb          	endbr32 
80107e90:	55                   	push   %ebp
80107e91:	89 e5                	mov    %esp,%ebp
80107e93:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107e96:	8b 45 10             	mov    0x10(%ebp),%eax
80107e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107e9c:	eb 7f                	jmp    80107f1d <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80107e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ea1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ea6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eac:	83 ec 08             	sub    $0x8,%esp
80107eaf:	50                   	push   %eax
80107eb0:	ff 75 08             	pushl  0x8(%ebp)
80107eb3:	e8 7d ff ff ff       	call   80107e35 <uva2ka>
80107eb8:	83 c4 10             	add    $0x10,%esp
80107ebb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107ebe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107ec2:	75 07                	jne    80107ecb <copyout+0x3f>
      return -1;
80107ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ec9:	eb 61                	jmp    80107f2c <copyout+0xa0>
    n = PGSIZE - (va - va0);
80107ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ece:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ed1:	05 00 10 00 00       	add    $0x1000,%eax
80107ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107edc:	3b 45 14             	cmp    0x14(%ebp),%eax
80107edf:	76 06                	jbe    80107ee7 <copyout+0x5b>
      n = len;
80107ee1:	8b 45 14             	mov    0x14(%ebp),%eax
80107ee4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eea:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107eed:	89 c2                	mov    %eax,%edx
80107eef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ef2:	01 d0                	add    %edx,%eax
80107ef4:	83 ec 04             	sub    $0x4,%esp
80107ef7:	ff 75 f0             	pushl  -0x10(%ebp)
80107efa:	ff 75 f4             	pushl  -0xc(%ebp)
80107efd:	50                   	push   %eax
80107efe:	e8 22 cd ff ff       	call   80104c25 <memmove>
80107f03:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f09:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f0f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107f12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f15:	05 00 10 00 00       	add    $0x1000,%eax
80107f1a:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107f1d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107f21:	0f 85 77 ff ff ff    	jne    80107e9e <copyout+0x12>
  }
  return 0;
80107f27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f2c:	c9                   	leave  
80107f2d:	c3                   	ret    

80107f2e <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107f2e:	f3 0f 1e fb          	endbr32 
80107f32:	55                   	push   %ebp
80107f33:	89 e5                	mov    %esp,%ebp
80107f35:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107f38:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107f3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f42:	8b 40 08             	mov    0x8(%eax),%eax
80107f45:	05 00 00 00 80       	add    $0x80000000,%eax
80107f4a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107f4d:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f57:	8b 40 24             	mov    0x24(%eax),%eax
80107f5a:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80107f5f:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
80107f66:	00 00 00 

  while(i<madt->len){
80107f69:	90                   	nop
80107f6a:	e9 be 00 00 00       	jmp    8010802d <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80107f6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f75:	01 d0                	add    %edx,%eax
80107f77:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f7d:	0f b6 00             	movzbl (%eax),%eax
80107f80:	0f b6 c0             	movzbl %al,%eax
80107f83:	83 f8 05             	cmp    $0x5,%eax
80107f86:	0f 87 a1 00 00 00    	ja     8010802d <mpinit_uefi+0xff>
80107f8c:	8b 04 85 a8 ab 10 80 	mov    -0x7fef5458(,%eax,4),%eax
80107f93:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f99:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107f9c:	a1 80 80 19 80       	mov    0x80198080,%eax
80107fa1:	83 f8 03             	cmp    $0x3,%eax
80107fa4:	7f 28                	jg     80107fce <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107fa6:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80107fac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107faf:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107fb3:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107fb9:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80107fbf:	88 02                	mov    %al,(%edx)
          ncpu++;
80107fc1:	a1 80 80 19 80       	mov    0x80198080,%eax
80107fc6:	83 c0 01             	add    $0x1,%eax
80107fc9:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
80107fce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fd1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107fd5:	0f b6 c0             	movzbl %al,%eax
80107fd8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107fdb:	eb 50                	jmp    8010802d <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107fe3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fe6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107fea:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
80107fef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ff2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ff6:	0f b6 c0             	movzbl %al,%eax
80107ff9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ffc:	eb 2f                	jmp    8010802d <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107ffe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108001:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108004:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108007:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010800b:	0f b6 c0             	movzbl %al,%eax
8010800e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108011:	eb 1a                	jmp    8010802d <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108016:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010801c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108020:	0f b6 c0             	movzbl %al,%eax
80108023:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108026:	eb 05                	jmp    8010802d <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80108028:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010802c:	90                   	nop
  while(i<madt->len){
8010802d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108030:	8b 40 04             	mov    0x4(%eax),%eax
80108033:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108036:	0f 82 33 ff ff ff    	jb     80107f6f <mpinit_uefi+0x41>
    }
  }

}
8010803c:	90                   	nop
8010803d:	90                   	nop
8010803e:	c9                   	leave  
8010803f:	c3                   	ret    

80108040 <inb>:
{
80108040:	55                   	push   %ebp
80108041:	89 e5                	mov    %esp,%ebp
80108043:	83 ec 14             	sub    $0x14,%esp
80108046:	8b 45 08             	mov    0x8(%ebp),%eax
80108049:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010804d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108051:	89 c2                	mov    %eax,%edx
80108053:	ec                   	in     (%dx),%al
80108054:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108057:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010805b:	c9                   	leave  
8010805c:	c3                   	ret    

8010805d <outb>:
{
8010805d:	55                   	push   %ebp
8010805e:	89 e5                	mov    %esp,%ebp
80108060:	83 ec 08             	sub    $0x8,%esp
80108063:	8b 45 08             	mov    0x8(%ebp),%eax
80108066:	8b 55 0c             	mov    0xc(%ebp),%edx
80108069:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010806d:	89 d0                	mov    %edx,%eax
8010806f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108072:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108076:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010807a:	ee                   	out    %al,(%dx)
}
8010807b:	90                   	nop
8010807c:	c9                   	leave  
8010807d:	c3                   	ret    

8010807e <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010807e:	f3 0f 1e fb          	endbr32 
80108082:	55                   	push   %ebp
80108083:	89 e5                	mov    %esp,%ebp
80108085:	83 ec 28             	sub    $0x28,%esp
80108088:	8b 45 08             	mov    0x8(%ebp),%eax
8010808b:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010808e:	6a 00                	push   $0x0
80108090:	68 fa 03 00 00       	push   $0x3fa
80108095:	e8 c3 ff ff ff       	call   8010805d <outb>
8010809a:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010809d:	68 80 00 00 00       	push   $0x80
801080a2:	68 fb 03 00 00       	push   $0x3fb
801080a7:	e8 b1 ff ff ff       	call   8010805d <outb>
801080ac:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801080af:	6a 0c                	push   $0xc
801080b1:	68 f8 03 00 00       	push   $0x3f8
801080b6:	e8 a2 ff ff ff       	call   8010805d <outb>
801080bb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801080be:	6a 00                	push   $0x0
801080c0:	68 f9 03 00 00       	push   $0x3f9
801080c5:	e8 93 ff ff ff       	call   8010805d <outb>
801080ca:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801080cd:	6a 03                	push   $0x3
801080cf:	68 fb 03 00 00       	push   $0x3fb
801080d4:	e8 84 ff ff ff       	call   8010805d <outb>
801080d9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801080dc:	6a 00                	push   $0x0
801080de:	68 fc 03 00 00       	push   $0x3fc
801080e3:	e8 75 ff ff ff       	call   8010805d <outb>
801080e8:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801080eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080f2:	eb 11                	jmp    80108105 <uart_debug+0x87>
801080f4:	83 ec 0c             	sub    $0xc,%esp
801080f7:	6a 0a                	push   $0xa
801080f9:	e8 46 ab ff ff       	call   80102c44 <microdelay>
801080fe:	83 c4 10             	add    $0x10,%esp
80108101:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108105:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108109:	7f 1a                	jg     80108125 <uart_debug+0xa7>
8010810b:	83 ec 0c             	sub    $0xc,%esp
8010810e:	68 fd 03 00 00       	push   $0x3fd
80108113:	e8 28 ff ff ff       	call   80108040 <inb>
80108118:	83 c4 10             	add    $0x10,%esp
8010811b:	0f b6 c0             	movzbl %al,%eax
8010811e:	83 e0 20             	and    $0x20,%eax
80108121:	85 c0                	test   %eax,%eax
80108123:	74 cf                	je     801080f4 <uart_debug+0x76>
  outb(COM1+0, p);
80108125:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108129:	0f b6 c0             	movzbl %al,%eax
8010812c:	83 ec 08             	sub    $0x8,%esp
8010812f:	50                   	push   %eax
80108130:	68 f8 03 00 00       	push   $0x3f8
80108135:	e8 23 ff ff ff       	call   8010805d <outb>
8010813a:	83 c4 10             	add    $0x10,%esp
}
8010813d:	90                   	nop
8010813e:	c9                   	leave  
8010813f:	c3                   	ret    

80108140 <uart_debugs>:

void uart_debugs(char *p){
80108140:	f3 0f 1e fb          	endbr32 
80108144:	55                   	push   %ebp
80108145:	89 e5                	mov    %esp,%ebp
80108147:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010814a:	eb 1b                	jmp    80108167 <uart_debugs+0x27>
    uart_debug(*p++);
8010814c:	8b 45 08             	mov    0x8(%ebp),%eax
8010814f:	8d 50 01             	lea    0x1(%eax),%edx
80108152:	89 55 08             	mov    %edx,0x8(%ebp)
80108155:	0f b6 00             	movzbl (%eax),%eax
80108158:	0f be c0             	movsbl %al,%eax
8010815b:	83 ec 0c             	sub    $0xc,%esp
8010815e:	50                   	push   %eax
8010815f:	e8 1a ff ff ff       	call   8010807e <uart_debug>
80108164:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108167:	8b 45 08             	mov    0x8(%ebp),%eax
8010816a:	0f b6 00             	movzbl (%eax),%eax
8010816d:	84 c0                	test   %al,%al
8010816f:	75 db                	jne    8010814c <uart_debugs+0xc>
  }
}
80108171:	90                   	nop
80108172:	90                   	nop
80108173:	c9                   	leave  
80108174:	c3                   	ret    

80108175 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108175:	f3 0f 1e fb          	endbr32 
80108179:	55                   	push   %ebp
8010817a:	89 e5                	mov    %esp,%ebp
8010817c:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010817f:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108186:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108189:	8b 50 14             	mov    0x14(%eax),%edx
8010818c:	8b 40 10             	mov    0x10(%eax),%eax
8010818f:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108194:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108197:	8b 50 1c             	mov    0x1c(%eax),%edx
8010819a:	8b 40 18             	mov    0x18(%eax),%eax
8010819d:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801081a2:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801081a7:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801081ac:	29 c2                	sub    %eax,%edx
801081ae:	89 d0                	mov    %edx,%eax
801081b0:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801081b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081b8:	8b 50 24             	mov    0x24(%eax),%edx
801081bb:	8b 40 20             	mov    0x20(%eax),%eax
801081be:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801081c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081c6:	8b 50 2c             	mov    0x2c(%eax),%edx
801081c9:	8b 40 28             	mov    0x28(%eax),%eax
801081cc:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801081d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081d4:	8b 50 34             	mov    0x34(%eax),%edx
801081d7:	8b 40 30             	mov    0x30(%eax),%eax
801081da:	a3 98 80 19 80       	mov    %eax,0x80198098
}
801081df:	90                   	nop
801081e0:	c9                   	leave  
801081e1:	c3                   	ret    

801081e2 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801081e2:	f3 0f 1e fb          	endbr32 
801081e6:	55                   	push   %ebp
801081e7:	89 e5                	mov    %esp,%ebp
801081e9:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801081ec:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801081f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f5:	0f af d0             	imul   %eax,%edx
801081f8:	8b 45 08             	mov    0x8(%ebp),%eax
801081fb:	01 d0                	add    %edx,%eax
801081fd:	c1 e0 02             	shl    $0x2,%eax
80108200:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108203:	8b 15 88 80 19 80    	mov    0x80198088,%edx
80108209:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010820c:	01 d0                	add    %edx,%eax
8010820e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108211:	8b 45 10             	mov    0x10(%ebp),%eax
80108214:	0f b6 10             	movzbl (%eax),%edx
80108217:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010821a:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010821c:	8b 45 10             	mov    0x10(%ebp),%eax
8010821f:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108223:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108226:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108229:	8b 45 10             	mov    0x10(%ebp),%eax
8010822c:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108230:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108233:	88 50 02             	mov    %dl,0x2(%eax)
}
80108236:	90                   	nop
80108237:	c9                   	leave  
80108238:	c3                   	ret    

80108239 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108239:	f3 0f 1e fb          	endbr32 
8010823d:	55                   	push   %ebp
8010823e:	89 e5                	mov    %esp,%ebp
80108240:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108243:	8b 15 98 80 19 80    	mov    0x80198098,%edx
80108249:	8b 45 08             	mov    0x8(%ebp),%eax
8010824c:	0f af c2             	imul   %edx,%eax
8010824f:	c1 e0 02             	shl    $0x2,%eax
80108252:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108255:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
8010825b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825e:	29 c2                	sub    %eax,%edx
80108260:	89 d0                	mov    %edx,%eax
80108262:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108268:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010826b:	01 ca                	add    %ecx,%edx
8010826d:	89 d1                	mov    %edx,%ecx
8010826f:	8b 15 88 80 19 80    	mov    0x80198088,%edx
80108275:	83 ec 04             	sub    $0x4,%esp
80108278:	50                   	push   %eax
80108279:	51                   	push   %ecx
8010827a:	52                   	push   %edx
8010827b:	e8 a5 c9 ff ff       	call   80104c25 <memmove>
80108280:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108286:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010828c:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108292:	01 d1                	add    %edx,%ecx
80108294:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108297:	29 d1                	sub    %edx,%ecx
80108299:	89 ca                	mov    %ecx,%edx
8010829b:	83 ec 04             	sub    $0x4,%esp
8010829e:	50                   	push   %eax
8010829f:	6a 00                	push   $0x0
801082a1:	52                   	push   %edx
801082a2:	e8 b7 c8 ff ff       	call   80104b5e <memset>
801082a7:	83 c4 10             	add    $0x10,%esp
}
801082aa:	90                   	nop
801082ab:	c9                   	leave  
801082ac:	c3                   	ret    

801082ad <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801082ad:	f3 0f 1e fb          	endbr32 
801082b1:	55                   	push   %ebp
801082b2:	89 e5                	mov    %esp,%ebp
801082b4:	53                   	push   %ebx
801082b5:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801082b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082bf:	e9 b1 00 00 00       	jmp    80108375 <font_render+0xc8>
    for(int j=14;j>-1;j--){
801082c4:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801082cb:	e9 97 00 00 00       	jmp    80108367 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801082d0:	8b 45 10             	mov    0x10(%ebp),%eax
801082d3:	83 e8 20             	sub    $0x20,%eax
801082d6:	6b d0 1e             	imul   $0x1e,%eax,%edx
801082d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082dc:	01 d0                	add    %edx,%eax
801082de:	0f b7 84 00 c0 ab 10 	movzwl -0x7fef5440(%eax,%eax,1),%eax
801082e5:	80 
801082e6:	0f b7 d0             	movzwl %ax,%edx
801082e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ec:	bb 01 00 00 00       	mov    $0x1,%ebx
801082f1:	89 c1                	mov    %eax,%ecx
801082f3:	d3 e3                	shl    %cl,%ebx
801082f5:	89 d8                	mov    %ebx,%eax
801082f7:	21 d0                	and    %edx,%eax
801082f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801082fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ff:	ba 01 00 00 00       	mov    $0x1,%edx
80108304:	89 c1                	mov    %eax,%ecx
80108306:	d3 e2                	shl    %cl,%edx
80108308:	89 d0                	mov    %edx,%eax
8010830a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010830d:	75 2b                	jne    8010833a <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
8010830f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108315:	01 c2                	add    %eax,%edx
80108317:	b8 0e 00 00 00       	mov    $0xe,%eax
8010831c:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010831f:	89 c1                	mov    %eax,%ecx
80108321:	8b 45 08             	mov    0x8(%ebp),%eax
80108324:	01 c8                	add    %ecx,%eax
80108326:	83 ec 04             	sub    $0x4,%esp
80108329:	68 e0 f4 10 80       	push   $0x8010f4e0
8010832e:	52                   	push   %edx
8010832f:	50                   	push   %eax
80108330:	e8 ad fe ff ff       	call   801081e2 <graphic_draw_pixel>
80108335:	83 c4 10             	add    $0x10,%esp
80108338:	eb 29                	jmp    80108363 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010833a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010833d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108340:	01 c2                	add    %eax,%edx
80108342:	b8 0e 00 00 00       	mov    $0xe,%eax
80108347:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010834a:	89 c1                	mov    %eax,%ecx
8010834c:	8b 45 08             	mov    0x8(%ebp),%eax
8010834f:	01 c8                	add    %ecx,%eax
80108351:	83 ec 04             	sub    $0x4,%esp
80108354:	68 64 d0 18 80       	push   $0x8018d064
80108359:	52                   	push   %edx
8010835a:	50                   	push   %eax
8010835b:	e8 82 fe ff ff       	call   801081e2 <graphic_draw_pixel>
80108360:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108363:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108367:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010836b:	0f 89 5f ff ff ff    	jns    801082d0 <font_render+0x23>
  for(int i=0;i<30;i++){
80108371:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108375:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108379:	0f 8e 45 ff ff ff    	jle    801082c4 <font_render+0x17>
      }
    }
  }
}
8010837f:	90                   	nop
80108380:	90                   	nop
80108381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108384:	c9                   	leave  
80108385:	c3                   	ret    

80108386 <font_render_string>:

void font_render_string(char *string,int row){
80108386:	f3 0f 1e fb          	endbr32 
8010838a:	55                   	push   %ebp
8010838b:	89 e5                	mov    %esp,%ebp
8010838d:	53                   	push   %ebx
8010838e:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108391:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108398:	eb 33                	jmp    801083cd <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010839a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010839d:	8b 45 08             	mov    0x8(%ebp),%eax
801083a0:	01 d0                	add    %edx,%eax
801083a2:	0f b6 00             	movzbl (%eax),%eax
801083a5:	0f be d8             	movsbl %al,%ebx
801083a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801083ab:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801083ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083b1:	89 d0                	mov    %edx,%eax
801083b3:	c1 e0 04             	shl    $0x4,%eax
801083b6:	29 d0                	sub    %edx,%eax
801083b8:	83 c0 02             	add    $0x2,%eax
801083bb:	83 ec 04             	sub    $0x4,%esp
801083be:	53                   	push   %ebx
801083bf:	51                   	push   %ecx
801083c0:	50                   	push   %eax
801083c1:	e8 e7 fe ff ff       	call   801082ad <font_render>
801083c6:	83 c4 10             	add    $0x10,%esp
    i++;
801083c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801083cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083d0:	8b 45 08             	mov    0x8(%ebp),%eax
801083d3:	01 d0                	add    %edx,%eax
801083d5:	0f b6 00             	movzbl (%eax),%eax
801083d8:	84 c0                	test   %al,%al
801083da:	74 06                	je     801083e2 <font_render_string+0x5c>
801083dc:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801083e0:	7e b8                	jle    8010839a <font_render_string+0x14>
  }
}
801083e2:	90                   	nop
801083e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083e6:	c9                   	leave  
801083e7:	c3                   	ret    

801083e8 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801083e8:	f3 0f 1e fb          	endbr32 
801083ec:	55                   	push   %ebp
801083ed:	89 e5                	mov    %esp,%ebp
801083ef:	53                   	push   %ebx
801083f0:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801083f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083fa:	eb 6b                	jmp    80108467 <pci_init+0x7f>
    for(int j=0;j<32;j++){
801083fc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108403:	eb 58                	jmp    8010845d <pci_init+0x75>
      for(int k=0;k<8;k++){
80108405:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010840c:	eb 45                	jmp    80108453 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
8010840e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108411:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108417:	83 ec 0c             	sub    $0xc,%esp
8010841a:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010841d:	53                   	push   %ebx
8010841e:	6a 00                	push   $0x0
80108420:	51                   	push   %ecx
80108421:	52                   	push   %edx
80108422:	50                   	push   %eax
80108423:	e8 c0 00 00 00       	call   801084e8 <pci_access_config>
80108428:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010842b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010842e:	0f b7 c0             	movzwl %ax,%eax
80108431:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108436:	74 17                	je     8010844f <pci_init+0x67>
        pci_init_device(i,j,k);
80108438:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010843b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010843e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108441:	83 ec 04             	sub    $0x4,%esp
80108444:	51                   	push   %ecx
80108445:	52                   	push   %edx
80108446:	50                   	push   %eax
80108447:	e8 4f 01 00 00       	call   8010859b <pci_init_device>
8010844c:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010844f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108453:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108457:	7e b5                	jle    8010840e <pci_init+0x26>
    for(int j=0;j<32;j++){
80108459:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010845d:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108461:	7e a2                	jle    80108405 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108463:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108467:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010846e:	7e 8c                	jle    801083fc <pci_init+0x14>
      }
      }
    }
  }
}
80108470:	90                   	nop
80108471:	90                   	nop
80108472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108475:	c9                   	leave  
80108476:	c3                   	ret    

80108477 <pci_write_config>:

void pci_write_config(uint config){
80108477:	f3 0f 1e fb          	endbr32 
8010847b:	55                   	push   %ebp
8010847c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010847e:	8b 45 08             	mov    0x8(%ebp),%eax
80108481:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108486:	89 c0                	mov    %eax,%eax
80108488:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108489:	90                   	nop
8010848a:	5d                   	pop    %ebp
8010848b:	c3                   	ret    

8010848c <pci_write_data>:

void pci_write_data(uint config){
8010848c:	f3 0f 1e fb          	endbr32 
80108490:	55                   	push   %ebp
80108491:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108493:	8b 45 08             	mov    0x8(%ebp),%eax
80108496:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010849b:	89 c0                	mov    %eax,%eax
8010849d:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010849e:	90                   	nop
8010849f:	5d                   	pop    %ebp
801084a0:	c3                   	ret    

801084a1 <pci_read_config>:
uint pci_read_config(){
801084a1:	f3 0f 1e fb          	endbr32 
801084a5:	55                   	push   %ebp
801084a6:	89 e5                	mov    %esp,%ebp
801084a8:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801084ab:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801084b0:	ed                   	in     (%dx),%eax
801084b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801084b4:	83 ec 0c             	sub    $0xc,%esp
801084b7:	68 c8 00 00 00       	push   $0xc8
801084bc:	e8 83 a7 ff ff       	call   80102c44 <microdelay>
801084c1:	83 c4 10             	add    $0x10,%esp
  return data;
801084c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801084c7:	c9                   	leave  
801084c8:	c3                   	ret    

801084c9 <pci_test>:


void pci_test(){
801084c9:	f3 0f 1e fb          	endbr32 
801084cd:	55                   	push   %ebp
801084ce:	89 e5                	mov    %esp,%ebp
801084d0:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801084d3:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801084da:	ff 75 fc             	pushl  -0x4(%ebp)
801084dd:	e8 95 ff ff ff       	call   80108477 <pci_write_config>
801084e2:	83 c4 04             	add    $0x4,%esp
}
801084e5:	90                   	nop
801084e6:	c9                   	leave  
801084e7:	c3                   	ret    

801084e8 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801084e8:	f3 0f 1e fb          	endbr32 
801084ec:	55                   	push   %ebp
801084ed:	89 e5                	mov    %esp,%ebp
801084ef:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084f2:	8b 45 08             	mov    0x8(%ebp),%eax
801084f5:	c1 e0 10             	shl    $0x10,%eax
801084f8:	25 00 00 ff 00       	and    $0xff0000,%eax
801084fd:	89 c2                	mov    %eax,%edx
801084ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108502:	c1 e0 0b             	shl    $0xb,%eax
80108505:	0f b7 c0             	movzwl %ax,%eax
80108508:	09 c2                	or     %eax,%edx
8010850a:	8b 45 10             	mov    0x10(%ebp),%eax
8010850d:	c1 e0 08             	shl    $0x8,%eax
80108510:	25 00 07 00 00       	and    $0x700,%eax
80108515:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108517:	8b 45 14             	mov    0x14(%ebp),%eax
8010851a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010851f:	09 d0                	or     %edx,%eax
80108521:	0d 00 00 00 80       	or     $0x80000000,%eax
80108526:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108529:	ff 75 f4             	pushl  -0xc(%ebp)
8010852c:	e8 46 ff ff ff       	call   80108477 <pci_write_config>
80108531:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108534:	e8 68 ff ff ff       	call   801084a1 <pci_read_config>
80108539:	8b 55 18             	mov    0x18(%ebp),%edx
8010853c:	89 02                	mov    %eax,(%edx)
}
8010853e:	90                   	nop
8010853f:	c9                   	leave  
80108540:	c3                   	ret    

80108541 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108541:	f3 0f 1e fb          	endbr32 
80108545:	55                   	push   %ebp
80108546:	89 e5                	mov    %esp,%ebp
80108548:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010854b:	8b 45 08             	mov    0x8(%ebp),%eax
8010854e:	c1 e0 10             	shl    $0x10,%eax
80108551:	25 00 00 ff 00       	and    $0xff0000,%eax
80108556:	89 c2                	mov    %eax,%edx
80108558:	8b 45 0c             	mov    0xc(%ebp),%eax
8010855b:	c1 e0 0b             	shl    $0xb,%eax
8010855e:	0f b7 c0             	movzwl %ax,%eax
80108561:	09 c2                	or     %eax,%edx
80108563:	8b 45 10             	mov    0x10(%ebp),%eax
80108566:	c1 e0 08             	shl    $0x8,%eax
80108569:	25 00 07 00 00       	and    $0x700,%eax
8010856e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108570:	8b 45 14             	mov    0x14(%ebp),%eax
80108573:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108578:	09 d0                	or     %edx,%eax
8010857a:	0d 00 00 00 80       	or     $0x80000000,%eax
8010857f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108582:	ff 75 fc             	pushl  -0x4(%ebp)
80108585:	e8 ed fe ff ff       	call   80108477 <pci_write_config>
8010858a:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010858d:	ff 75 18             	pushl  0x18(%ebp)
80108590:	e8 f7 fe ff ff       	call   8010848c <pci_write_data>
80108595:	83 c4 04             	add    $0x4,%esp
}
80108598:	90                   	nop
80108599:	c9                   	leave  
8010859a:	c3                   	ret    

8010859b <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010859b:	f3 0f 1e fb          	endbr32 
8010859f:	55                   	push   %ebp
801085a0:	89 e5                	mov    %esp,%ebp
801085a2:	53                   	push   %ebx
801085a3:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801085a6:	8b 45 08             	mov    0x8(%ebp),%eax
801085a9:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
801085ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801085b1:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
801085b6:	8b 45 10             	mov    0x10(%ebp),%eax
801085b9:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801085be:	ff 75 10             	pushl  0x10(%ebp)
801085c1:	ff 75 0c             	pushl  0xc(%ebp)
801085c4:	ff 75 08             	pushl  0x8(%ebp)
801085c7:	68 04 c2 10 80       	push   $0x8010c204
801085cc:	e8 3b 7e ff ff       	call   8010040c <cprintf>
801085d1:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801085d4:	83 ec 0c             	sub    $0xc,%esp
801085d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085da:	50                   	push   %eax
801085db:	6a 00                	push   $0x0
801085dd:	ff 75 10             	pushl  0x10(%ebp)
801085e0:	ff 75 0c             	pushl  0xc(%ebp)
801085e3:	ff 75 08             	pushl  0x8(%ebp)
801085e6:	e8 fd fe ff ff       	call   801084e8 <pci_access_config>
801085eb:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801085ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085f1:	c1 e8 10             	shr    $0x10,%eax
801085f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801085f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085fa:	25 ff ff 00 00       	and    $0xffff,%eax
801085ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108605:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
8010860a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010860d:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108612:	83 ec 04             	sub    $0x4,%esp
80108615:	ff 75 f0             	pushl  -0x10(%ebp)
80108618:	ff 75 f4             	pushl  -0xc(%ebp)
8010861b:	68 38 c2 10 80       	push   $0x8010c238
80108620:	e8 e7 7d ff ff       	call   8010040c <cprintf>
80108625:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108628:	83 ec 0c             	sub    $0xc,%esp
8010862b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010862e:	50                   	push   %eax
8010862f:	6a 08                	push   $0x8
80108631:	ff 75 10             	pushl  0x10(%ebp)
80108634:	ff 75 0c             	pushl  0xc(%ebp)
80108637:	ff 75 08             	pushl  0x8(%ebp)
8010863a:	e8 a9 fe ff ff       	call   801084e8 <pci_access_config>
8010863f:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108642:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108645:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108648:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010864b:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010864e:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108651:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108654:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108657:	0f b6 c0             	movzbl %al,%eax
8010865a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010865d:	c1 eb 18             	shr    $0x18,%ebx
80108660:	83 ec 0c             	sub    $0xc,%esp
80108663:	51                   	push   %ecx
80108664:	52                   	push   %edx
80108665:	50                   	push   %eax
80108666:	53                   	push   %ebx
80108667:	68 5c c2 10 80       	push   $0x8010c25c
8010866c:	e8 9b 7d ff ff       	call   8010040c <cprintf>
80108671:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108674:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108677:	c1 e8 18             	shr    $0x18,%eax
8010867a:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
8010867f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108682:	c1 e8 10             	shr    $0x10,%eax
80108685:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
8010868a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010868d:	c1 e8 08             	shr    $0x8,%eax
80108690:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
80108695:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108698:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010869d:	83 ec 0c             	sub    $0xc,%esp
801086a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086a3:	50                   	push   %eax
801086a4:	6a 10                	push   $0x10
801086a6:	ff 75 10             	pushl  0x10(%ebp)
801086a9:	ff 75 0c             	pushl  0xc(%ebp)
801086ac:	ff 75 08             	pushl  0x8(%ebp)
801086af:	e8 34 fe ff ff       	call   801084e8 <pci_access_config>
801086b4:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801086b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ba:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801086bf:	83 ec 0c             	sub    $0xc,%esp
801086c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086c5:	50                   	push   %eax
801086c6:	6a 14                	push   $0x14
801086c8:	ff 75 10             	pushl  0x10(%ebp)
801086cb:	ff 75 0c             	pushl  0xc(%ebp)
801086ce:	ff 75 08             	pushl  0x8(%ebp)
801086d1:	e8 12 fe ff ff       	call   801084e8 <pci_access_config>
801086d6:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801086d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086dc:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801086e1:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801086e8:	75 5a                	jne    80108744 <pci_init_device+0x1a9>
801086ea:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801086f1:	75 51                	jne    80108744 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801086f3:	83 ec 0c             	sub    $0xc,%esp
801086f6:	68 a1 c2 10 80       	push   $0x8010c2a1
801086fb:	e8 0c 7d ff ff       	call   8010040c <cprintf>
80108700:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108703:	83 ec 0c             	sub    $0xc,%esp
80108706:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108709:	50                   	push   %eax
8010870a:	68 f0 00 00 00       	push   $0xf0
8010870f:	ff 75 10             	pushl  0x10(%ebp)
80108712:	ff 75 0c             	pushl  0xc(%ebp)
80108715:	ff 75 08             	pushl  0x8(%ebp)
80108718:	e8 cb fd ff ff       	call   801084e8 <pci_access_config>
8010871d:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108720:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108723:	83 ec 08             	sub    $0x8,%esp
80108726:	50                   	push   %eax
80108727:	68 bb c2 10 80       	push   $0x8010c2bb
8010872c:	e8 db 7c ff ff       	call   8010040c <cprintf>
80108731:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108734:	83 ec 0c             	sub    $0xc,%esp
80108737:	68 9c 80 19 80       	push   $0x8019809c
8010873c:	e8 09 00 00 00       	call   8010874a <i8254_init>
80108741:	83 c4 10             	add    $0x10,%esp
  }
}
80108744:	90                   	nop
80108745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108748:	c9                   	leave  
80108749:	c3                   	ret    

8010874a <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010874a:	f3 0f 1e fb          	endbr32 
8010874e:	55                   	push   %ebp
8010874f:	89 e5                	mov    %esp,%ebp
80108751:	53                   	push   %ebx
80108752:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108755:	8b 45 08             	mov    0x8(%ebp),%eax
80108758:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010875c:	0f b6 c8             	movzbl %al,%ecx
8010875f:	8b 45 08             	mov    0x8(%ebp),%eax
80108762:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108766:	0f b6 d0             	movzbl %al,%edx
80108769:	8b 45 08             	mov    0x8(%ebp),%eax
8010876c:	0f b6 00             	movzbl (%eax),%eax
8010876f:	0f b6 c0             	movzbl %al,%eax
80108772:	83 ec 0c             	sub    $0xc,%esp
80108775:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108778:	53                   	push   %ebx
80108779:	6a 04                	push   $0x4
8010877b:	51                   	push   %ecx
8010877c:	52                   	push   %edx
8010877d:	50                   	push   %eax
8010877e:	e8 65 fd ff ff       	call   801084e8 <pci_access_config>
80108783:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108786:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108789:	83 c8 04             	or     $0x4,%eax
8010878c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010878f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108792:	8b 45 08             	mov    0x8(%ebp),%eax
80108795:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108799:	0f b6 c8             	movzbl %al,%ecx
8010879c:	8b 45 08             	mov    0x8(%ebp),%eax
8010879f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087a3:	0f b6 d0             	movzbl %al,%edx
801087a6:	8b 45 08             	mov    0x8(%ebp),%eax
801087a9:	0f b6 00             	movzbl (%eax),%eax
801087ac:	0f b6 c0             	movzbl %al,%eax
801087af:	83 ec 0c             	sub    $0xc,%esp
801087b2:	53                   	push   %ebx
801087b3:	6a 04                	push   $0x4
801087b5:	51                   	push   %ecx
801087b6:	52                   	push   %edx
801087b7:	50                   	push   %eax
801087b8:	e8 84 fd ff ff       	call   80108541 <pci_write_config_register>
801087bd:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801087c0:	8b 45 08             	mov    0x8(%ebp),%eax
801087c3:	8b 40 10             	mov    0x10(%eax),%eax
801087c6:	05 00 00 00 40       	add    $0x40000000,%eax
801087cb:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
801087d0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801087d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801087d8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801087dd:	05 d8 00 00 00       	add    $0xd8,%eax
801087e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801087e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087e8:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801087ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f1:	8b 00                	mov    (%eax),%eax
801087f3:	0d 00 00 00 04       	or     $0x4000000,%eax
801087f8:	89 c2                	mov    %eax,%edx
801087fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fd:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801087ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108802:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880b:	8b 00                	mov    (%eax),%eax
8010880d:	83 c8 40             	or     $0x40,%eax
80108810:	89 c2                	mov    %eax,%edx
80108812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108815:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881a:	8b 10                	mov    (%eax),%edx
8010881c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881f:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108821:	83 ec 0c             	sub    $0xc,%esp
80108824:	68 d0 c2 10 80       	push   $0x8010c2d0
80108829:	e8 de 7b ff ff       	call   8010040c <cprintf>
8010882e:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108831:	e8 5c a0 ff ff       	call   80102892 <kalloc>
80108836:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
8010883b:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108840:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108846:	a1 b8 80 19 80       	mov    0x801980b8,%eax
8010884b:	83 ec 08             	sub    $0x8,%esp
8010884e:	50                   	push   %eax
8010884f:	68 f2 c2 10 80       	push   $0x8010c2f2
80108854:	e8 b3 7b ff ff       	call   8010040c <cprintf>
80108859:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010885c:	e8 50 00 00 00       	call   801088b1 <i8254_init_recv>
  i8254_init_send();
80108861:	e8 6d 03 00 00       	call   80108bd3 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108866:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010886d:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108870:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108877:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010887a:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108881:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108884:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010888b:	0f b6 c0             	movzbl %al,%eax
8010888e:	83 ec 0c             	sub    $0xc,%esp
80108891:	53                   	push   %ebx
80108892:	51                   	push   %ecx
80108893:	52                   	push   %edx
80108894:	50                   	push   %eax
80108895:	68 00 c3 10 80       	push   $0x8010c300
8010889a:	e8 6d 7b ff ff       	call   8010040c <cprintf>
8010889f:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801088a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801088ab:	90                   	nop
801088ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088af:	c9                   	leave  
801088b0:	c3                   	ret    

801088b1 <i8254_init_recv>:

void i8254_init_recv(){
801088b1:	f3 0f 1e fb          	endbr32 
801088b5:	55                   	push   %ebp
801088b6:	89 e5                	mov    %esp,%ebp
801088b8:	57                   	push   %edi
801088b9:	56                   	push   %esi
801088ba:	53                   	push   %ebx
801088bb:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801088be:	83 ec 0c             	sub    $0xc,%esp
801088c1:	6a 00                	push   $0x0
801088c3:	e8 ec 04 00 00       	call   80108db4 <i8254_read_eeprom>
801088c8:	83 c4 10             	add    $0x10,%esp
801088cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801088ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801088d1:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
801088d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801088d9:	c1 e8 08             	shr    $0x8,%eax
801088dc:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
801088e1:	83 ec 0c             	sub    $0xc,%esp
801088e4:	6a 01                	push   $0x1
801088e6:	e8 c9 04 00 00       	call   80108db4 <i8254_read_eeprom>
801088eb:	83 c4 10             	add    $0x10,%esp
801088ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801088f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088f4:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
801088f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088fc:	c1 e8 08             	shr    $0x8,%eax
801088ff:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108904:	83 ec 0c             	sub    $0xc,%esp
80108907:	6a 02                	push   $0x2
80108909:	e8 a6 04 00 00       	call   80108db4 <i8254_read_eeprom>
8010890e:	83 c4 10             	add    $0x10,%esp
80108911:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108914:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108917:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
8010891c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010891f:	c1 e8 08             	shr    $0x8,%eax
80108922:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108927:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010892e:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108931:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108938:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010893b:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108942:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108945:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010894c:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010894f:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108956:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108959:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108960:	0f b6 c0             	movzbl %al,%eax
80108963:	83 ec 04             	sub    $0x4,%esp
80108966:	57                   	push   %edi
80108967:	56                   	push   %esi
80108968:	53                   	push   %ebx
80108969:	51                   	push   %ecx
8010896a:	52                   	push   %edx
8010896b:	50                   	push   %eax
8010896c:	68 18 c3 10 80       	push   $0x8010c318
80108971:	e8 96 7a ff ff       	call   8010040c <cprintf>
80108976:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108979:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010897e:	05 00 54 00 00       	add    $0x5400,%eax
80108983:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108986:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010898b:	05 04 54 00 00       	add    $0x5404,%eax
80108990:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108993:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108996:	c1 e0 10             	shl    $0x10,%eax
80108999:	0b 45 d8             	or     -0x28(%ebp),%eax
8010899c:	89 c2                	mov    %eax,%edx
8010899e:	8b 45 cc             	mov    -0x34(%ebp),%eax
801089a1:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801089a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089a6:	0d 00 00 00 80       	or     $0x80000000,%eax
801089ab:	89 c2                	mov    %eax,%edx
801089ad:	8b 45 c8             	mov    -0x38(%ebp),%eax
801089b0:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801089b2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089b7:	05 00 52 00 00       	add    $0x5200,%eax
801089bc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801089bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801089c6:	eb 19                	jmp    801089e1 <i8254_init_recv+0x130>
    mta[i] = 0;
801089c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801089cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089d2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801089d5:	01 d0                	add    %edx,%eax
801089d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801089dd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801089e1:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801089e5:	7e e1                	jle    801089c8 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801089e7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089ec:	05 d0 00 00 00       	add    $0xd0,%eax
801089f1:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801089f4:	8b 45 c0             	mov    -0x40(%ebp),%eax
801089f7:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801089fd:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a02:	05 c8 00 00 00       	add    $0xc8,%eax
80108a07:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108a0a:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108a0d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108a13:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a18:	05 28 28 00 00       	add    $0x2828,%eax
80108a1d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108a20:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108a23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108a29:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a2e:	05 00 01 00 00       	add    $0x100,%eax
80108a33:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108a36:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a39:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108a3f:	e8 4e 9e ff ff       	call   80102892 <kalloc>
80108a44:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a47:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a4c:	05 00 28 00 00       	add    $0x2800,%eax
80108a51:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108a54:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a59:	05 04 28 00 00       	add    $0x2804,%eax
80108a5e:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108a61:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a66:	05 08 28 00 00       	add    $0x2808,%eax
80108a6b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a6e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a73:	05 10 28 00 00       	add    $0x2810,%eax
80108a78:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108a7b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a80:	05 18 28 00 00       	add    $0x2818,%eax
80108a85:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108a88:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108a8b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a91:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108a94:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108a96:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108a99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108a9f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108aa2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108aa8:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108aab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108ab1:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108ab4:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108aba:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108abd:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ac0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108ac7:	eb 73                	jmp    80108b3c <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108ac9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108acc:	c1 e0 04             	shl    $0x4,%eax
80108acf:	89 c2                	mov    %eax,%edx
80108ad1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ad4:	01 d0                	add    %edx,%eax
80108ad6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108add:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ae0:	c1 e0 04             	shl    $0x4,%eax
80108ae3:	89 c2                	mov    %eax,%edx
80108ae5:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ae8:	01 d0                	add    %edx,%eax
80108aea:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108af3:	c1 e0 04             	shl    $0x4,%eax
80108af6:	89 c2                	mov    %eax,%edx
80108af8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108afb:	01 d0                	add    %edx,%eax
80108afd:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108b03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b06:	c1 e0 04             	shl    $0x4,%eax
80108b09:	89 c2                	mov    %eax,%edx
80108b0b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b0e:	01 d0                	add    %edx,%eax
80108b10:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108b14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b17:	c1 e0 04             	shl    $0x4,%eax
80108b1a:	89 c2                	mov    %eax,%edx
80108b1c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b1f:	01 d0                	add    %edx,%eax
80108b21:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108b25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b28:	c1 e0 04             	shl    $0x4,%eax
80108b2b:	89 c2                	mov    %eax,%edx
80108b2d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b30:	01 d0                	add    %edx,%eax
80108b32:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108b38:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108b3c:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108b43:	7e 84                	jle    80108ac9 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b45:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108b4c:	eb 57                	jmp    80108ba5 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108b4e:	e8 3f 9d ff ff       	call   80102892 <kalloc>
80108b53:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108b56:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108b5a:	75 12                	jne    80108b6e <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108b5c:	83 ec 0c             	sub    $0xc,%esp
80108b5f:	68 38 c3 10 80       	push   $0x8010c338
80108b64:	e8 a3 78 ff ff       	call   8010040c <cprintf>
80108b69:	83 c4 10             	add    $0x10,%esp
      break;
80108b6c:	eb 3d                	jmp    80108bab <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108b6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b71:	c1 e0 04             	shl    $0x4,%eax
80108b74:	89 c2                	mov    %eax,%edx
80108b76:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b79:	01 d0                	add    %edx,%eax
80108b7b:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b7e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b84:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108b86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b89:	83 c0 01             	add    $0x1,%eax
80108b8c:	c1 e0 04             	shl    $0x4,%eax
80108b8f:	89 c2                	mov    %eax,%edx
80108b91:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b94:	01 d0                	add    %edx,%eax
80108b96:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b99:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108b9f:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ba1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108ba5:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108ba9:	7e a3                	jle    80108b4e <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108bab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bae:	8b 00                	mov    (%eax),%eax
80108bb0:	83 c8 02             	or     $0x2,%eax
80108bb3:	89 c2                	mov    %eax,%edx
80108bb5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bb8:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108bba:	83 ec 0c             	sub    $0xc,%esp
80108bbd:	68 58 c3 10 80       	push   $0x8010c358
80108bc2:	e8 45 78 ff ff       	call   8010040c <cprintf>
80108bc7:	83 c4 10             	add    $0x10,%esp
}
80108bca:	90                   	nop
80108bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108bce:	5b                   	pop    %ebx
80108bcf:	5e                   	pop    %esi
80108bd0:	5f                   	pop    %edi
80108bd1:	5d                   	pop    %ebp
80108bd2:	c3                   	ret    

80108bd3 <i8254_init_send>:

void i8254_init_send(){
80108bd3:	f3 0f 1e fb          	endbr32 
80108bd7:	55                   	push   %ebp
80108bd8:	89 e5                	mov    %esp,%ebp
80108bda:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108bdd:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108be2:	05 28 38 00 00       	add    $0x3828,%eax
80108be7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108bea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bed:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108bf3:	e8 9a 9c ff ff       	call   80102892 <kalloc>
80108bf8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108bfb:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c00:	05 00 38 00 00       	add    $0x3800,%eax
80108c05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108c08:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c0d:	05 04 38 00 00       	add    $0x3804,%eax
80108c12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108c15:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c1a:	05 08 38 00 00       	add    $0x3808,%eax
80108c1f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108c22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c25:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c2e:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108c30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108c39:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c3c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108c42:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c47:	05 10 38 00 00       	add    $0x3810,%eax
80108c4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108c4f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c54:	05 18 38 00 00       	add    $0x3818,%eax
80108c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108c5c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108c65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c71:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108c74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c7b:	e9 82 00 00 00       	jmp    80108d02 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c83:	c1 e0 04             	shl    $0x4,%eax
80108c86:	89 c2                	mov    %eax,%edx
80108c88:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c8b:	01 d0                	add    %edx,%eax
80108c8d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c97:	c1 e0 04             	shl    $0x4,%eax
80108c9a:	89 c2                	mov    %eax,%edx
80108c9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c9f:	01 d0                	add    %edx,%eax
80108ca1:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108caa:	c1 e0 04             	shl    $0x4,%eax
80108cad:	89 c2                	mov    %eax,%edx
80108caf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cb2:	01 d0                	add    %edx,%eax
80108cb4:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cbb:	c1 e0 04             	shl    $0x4,%eax
80108cbe:	89 c2                	mov    %eax,%edx
80108cc0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cc3:	01 d0                	add    %edx,%eax
80108cc5:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ccc:	c1 e0 04             	shl    $0x4,%eax
80108ccf:	89 c2                	mov    %eax,%edx
80108cd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cd4:	01 d0                	add    %edx,%eax
80108cd6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cdd:	c1 e0 04             	shl    $0x4,%eax
80108ce0:	89 c2                	mov    %eax,%edx
80108ce2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ce5:	01 d0                	add    %edx,%eax
80108ce7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cee:	c1 e0 04             	shl    $0x4,%eax
80108cf1:	89 c2                	mov    %eax,%edx
80108cf3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cf6:	01 d0                	add    %edx,%eax
80108cf8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108cfe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d02:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108d09:	0f 8e 71 ff ff ff    	jle    80108c80 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d16:	eb 57                	jmp    80108d6f <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108d18:	e8 75 9b ff ff       	call   80102892 <kalloc>
80108d1d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108d20:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108d24:	75 12                	jne    80108d38 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108d26:	83 ec 0c             	sub    $0xc,%esp
80108d29:	68 38 c3 10 80       	push   $0x8010c338
80108d2e:	e8 d9 76 ff ff       	call   8010040c <cprintf>
80108d33:	83 c4 10             	add    $0x10,%esp
      break;
80108d36:	eb 3d                	jmp    80108d75 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d3b:	c1 e0 04             	shl    $0x4,%eax
80108d3e:	89 c2                	mov    %eax,%edx
80108d40:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d43:	01 d0                	add    %edx,%eax
80108d45:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d48:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d4e:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d53:	83 c0 01             	add    $0x1,%eax
80108d56:	c1 e0 04             	shl    $0x4,%eax
80108d59:	89 c2                	mov    %eax,%edx
80108d5b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d5e:	01 d0                	add    %edx,%eax
80108d60:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d63:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d69:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d6b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d6f:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108d73:	7e a3                	jle    80108d18 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108d75:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d7a:	05 00 04 00 00       	add    $0x400,%eax
80108d7f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108d82:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108d85:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108d8b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d90:	05 10 04 00 00       	add    $0x410,%eax
80108d95:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108d98:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d9b:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108da1:	83 ec 0c             	sub    $0xc,%esp
80108da4:	68 78 c3 10 80       	push   $0x8010c378
80108da9:	e8 5e 76 ff ff       	call   8010040c <cprintf>
80108dae:	83 c4 10             	add    $0x10,%esp

}
80108db1:	90                   	nop
80108db2:	c9                   	leave  
80108db3:	c3                   	ret    

80108db4 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108db4:	f3 0f 1e fb          	endbr32 
80108db8:	55                   	push   %ebp
80108db9:	89 e5                	mov    %esp,%ebp
80108dbb:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108dbe:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dc3:	83 c0 14             	add    $0x14,%eax
80108dc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80108dcc:	c1 e0 08             	shl    $0x8,%eax
80108dcf:	0f b7 c0             	movzwl %ax,%eax
80108dd2:	83 c8 01             	or     $0x1,%eax
80108dd5:	89 c2                	mov    %eax,%edx
80108dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dda:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108ddc:	83 ec 0c             	sub    $0xc,%esp
80108ddf:	68 98 c3 10 80       	push   $0x8010c398
80108de4:	e8 23 76 ff ff       	call   8010040c <cprintf>
80108de9:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108def:	8b 00                	mov    (%eax),%eax
80108df1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df7:	83 e0 10             	and    $0x10,%eax
80108dfa:	85 c0                	test   %eax,%eax
80108dfc:	75 02                	jne    80108e00 <i8254_read_eeprom+0x4c>
  while(1){
80108dfe:	eb dc                	jmp    80108ddc <i8254_read_eeprom+0x28>
      break;
80108e00:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e04:	8b 00                	mov    (%eax),%eax
80108e06:	c1 e8 10             	shr    $0x10,%eax
}
80108e09:	c9                   	leave  
80108e0a:	c3                   	ret    

80108e0b <i8254_recv>:
void i8254_recv(){
80108e0b:	f3 0f 1e fb          	endbr32 
80108e0f:	55                   	push   %ebp
80108e10:	89 e5                	mov    %esp,%ebp
80108e12:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108e15:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e1a:	05 10 28 00 00       	add    $0x2810,%eax
80108e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108e22:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e27:	05 18 28 00 00       	add    $0x2818,%eax
80108e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108e2f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e34:	05 00 28 00 00       	add    $0x2800,%eax
80108e39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108e3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e3f:	8b 00                	mov    (%eax),%eax
80108e41:	05 00 00 00 80       	add    $0x80000000,%eax
80108e46:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e4c:	8b 10                	mov    (%eax),%edx
80108e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e51:	8b 00                	mov    (%eax),%eax
80108e53:	29 c2                	sub    %eax,%edx
80108e55:	89 d0                	mov    %edx,%eax
80108e57:	25 ff 00 00 00       	and    $0xff,%eax
80108e5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108e5f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e63:	7e 37                	jle    80108e9c <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e68:	8b 00                	mov    (%eax),%eax
80108e6a:	c1 e0 04             	shl    $0x4,%eax
80108e6d:	89 c2                	mov    %eax,%edx
80108e6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e72:	01 d0                	add    %edx,%eax
80108e74:	8b 00                	mov    (%eax),%eax
80108e76:	05 00 00 00 80       	add    $0x80000000,%eax
80108e7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e81:	8b 00                	mov    (%eax),%eax
80108e83:	83 c0 01             	add    $0x1,%eax
80108e86:	0f b6 d0             	movzbl %al,%edx
80108e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e8c:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108e8e:	83 ec 0c             	sub    $0xc,%esp
80108e91:	ff 75 e0             	pushl  -0x20(%ebp)
80108e94:	e8 47 09 00 00       	call   801097e0 <eth_proc>
80108e99:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e9f:	8b 10                	mov    (%eax),%edx
80108ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea4:	8b 00                	mov    (%eax),%eax
80108ea6:	39 c2                	cmp    %eax,%edx
80108ea8:	75 9f                	jne    80108e49 <i8254_recv+0x3e>
      (*rdt)--;
80108eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ead:	8b 00                	mov    (%eax),%eax
80108eaf:	8d 50 ff             	lea    -0x1(%eax),%edx
80108eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb5:	89 10                	mov    %edx,(%eax)
  while(1){
80108eb7:	eb 90                	jmp    80108e49 <i8254_recv+0x3e>

80108eb9 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108eb9:	f3 0f 1e fb          	endbr32 
80108ebd:	55                   	push   %ebp
80108ebe:	89 e5                	mov    %esp,%ebp
80108ec0:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ec3:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ec8:	05 10 38 00 00       	add    $0x3810,%eax
80108ecd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ed0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ed5:	05 18 38 00 00       	add    $0x3818,%eax
80108eda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108edd:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ee2:	05 00 38 00 00       	add    $0x3800,%eax
80108ee7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eed:	8b 00                	mov    (%eax),%eax
80108eef:	05 00 00 00 80       	add    $0x80000000,%eax
80108ef4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108efa:	8b 10                	mov    (%eax),%edx
80108efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eff:	8b 00                	mov    (%eax),%eax
80108f01:	29 c2                	sub    %eax,%edx
80108f03:	89 d0                	mov    %edx,%eax
80108f05:	0f b6 c0             	movzbl %al,%eax
80108f08:	ba 00 01 00 00       	mov    $0x100,%edx
80108f0d:	29 c2                	sub    %eax,%edx
80108f0f:	89 d0                	mov    %edx,%eax
80108f11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f17:	8b 00                	mov    (%eax),%eax
80108f19:	25 ff 00 00 00       	and    $0xff,%eax
80108f1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108f21:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f25:	0f 8e a8 00 00 00    	jle    80108fd3 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80108f2e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108f31:	89 d1                	mov    %edx,%ecx
80108f33:	c1 e1 04             	shl    $0x4,%ecx
80108f36:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108f39:	01 ca                	add    %ecx,%edx
80108f3b:	8b 12                	mov    (%edx),%edx
80108f3d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f43:	83 ec 04             	sub    $0x4,%esp
80108f46:	ff 75 0c             	pushl  0xc(%ebp)
80108f49:	50                   	push   %eax
80108f4a:	52                   	push   %edx
80108f4b:	e8 d5 bc ff ff       	call   80104c25 <memmove>
80108f50:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f56:	c1 e0 04             	shl    $0x4,%eax
80108f59:	89 c2                	mov    %eax,%edx
80108f5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f5e:	01 d0                	add    %edx,%eax
80108f60:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f63:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108f67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f6a:	c1 e0 04             	shl    $0x4,%eax
80108f6d:	89 c2                	mov    %eax,%edx
80108f6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f72:	01 d0                	add    %edx,%eax
80108f74:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f7b:	c1 e0 04             	shl    $0x4,%eax
80108f7e:	89 c2                	mov    %eax,%edx
80108f80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f83:	01 d0                	add    %edx,%eax
80108f85:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108f89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f8c:	c1 e0 04             	shl    $0x4,%eax
80108f8f:	89 c2                	mov    %eax,%edx
80108f91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f94:	01 d0                	add    %edx,%eax
80108f96:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108f9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f9d:	c1 e0 04             	shl    $0x4,%eax
80108fa0:	89 c2                	mov    %eax,%edx
80108fa2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fa5:	01 d0                	add    %edx,%eax
80108fa7:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fb0:	c1 e0 04             	shl    $0x4,%eax
80108fb3:	89 c2                	mov    %eax,%edx
80108fb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fb8:	01 d0                	add    %edx,%eax
80108fba:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc1:	8b 00                	mov    (%eax),%eax
80108fc3:	83 c0 01             	add    $0x1,%eax
80108fc6:	0f b6 d0             	movzbl %al,%edx
80108fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fcc:	89 10                	mov    %edx,(%eax)
    return len;
80108fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fd1:	eb 05                	jmp    80108fd8 <i8254_send+0x11f>
  }else{
    return -1;
80108fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108fd8:	c9                   	leave  
80108fd9:	c3                   	ret    

80108fda <i8254_intr>:

void i8254_intr(){
80108fda:	f3 0f 1e fb          	endbr32 
80108fde:	55                   	push   %ebp
80108fdf:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108fe1:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108fe6:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108fec:	90                   	nop
80108fed:	5d                   	pop    %ebp
80108fee:	c3                   	ret    

80108fef <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108fef:	f3 0f 1e fb          	endbr32 
80108ff3:	55                   	push   %ebp
80108ff4:	89 e5                	mov    %esp,%ebp
80108ff6:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80108ffc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109002:	0f b7 00             	movzwl (%eax),%eax
80109005:	66 3d 00 01          	cmp    $0x100,%ax
80109009:	74 0a                	je     80109015 <arp_proc+0x26>
8010900b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109010:	e9 4f 01 00 00       	jmp    80109164 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109018:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010901c:	66 83 f8 08          	cmp    $0x8,%ax
80109020:	74 0a                	je     8010902c <arp_proc+0x3d>
80109022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109027:	e9 38 01 00 00       	jmp    80109164 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
8010902c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010902f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109033:	3c 06                	cmp    $0x6,%al
80109035:	74 0a                	je     80109041 <arp_proc+0x52>
80109037:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010903c:	e9 23 01 00 00       	jmp    80109164 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109044:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109048:	3c 04                	cmp    $0x4,%al
8010904a:	74 0a                	je     80109056 <arp_proc+0x67>
8010904c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109051:	e9 0e 01 00 00       	jmp    80109164 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109059:	83 c0 18             	add    $0x18,%eax
8010905c:	83 ec 04             	sub    $0x4,%esp
8010905f:	6a 04                	push   $0x4
80109061:	50                   	push   %eax
80109062:	68 e4 f4 10 80       	push   $0x8010f4e4
80109067:	e8 5d bb ff ff       	call   80104bc9 <memcmp>
8010906c:	83 c4 10             	add    $0x10,%esp
8010906f:	85 c0                	test   %eax,%eax
80109071:	74 27                	je     8010909a <arp_proc+0xab>
80109073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109076:	83 c0 0e             	add    $0xe,%eax
80109079:	83 ec 04             	sub    $0x4,%esp
8010907c:	6a 04                	push   $0x4
8010907e:	50                   	push   %eax
8010907f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109084:	e8 40 bb ff ff       	call   80104bc9 <memcmp>
80109089:	83 c4 10             	add    $0x10,%esp
8010908c:	85 c0                	test   %eax,%eax
8010908e:	74 0a                	je     8010909a <arp_proc+0xab>
80109090:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109095:	e9 ca 00 00 00       	jmp    80109164 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010909a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801090a1:	66 3d 00 01          	cmp    $0x100,%ax
801090a5:	75 69                	jne    80109110 <arp_proc+0x121>
801090a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090aa:	83 c0 18             	add    $0x18,%eax
801090ad:	83 ec 04             	sub    $0x4,%esp
801090b0:	6a 04                	push   $0x4
801090b2:	50                   	push   %eax
801090b3:	68 e4 f4 10 80       	push   $0x8010f4e4
801090b8:	e8 0c bb ff ff       	call   80104bc9 <memcmp>
801090bd:	83 c4 10             	add    $0x10,%esp
801090c0:	85 c0                	test   %eax,%eax
801090c2:	75 4c                	jne    80109110 <arp_proc+0x121>
    uint send = (uint)kalloc();
801090c4:	e8 c9 97 ff ff       	call   80102892 <kalloc>
801090c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801090cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801090d3:	83 ec 04             	sub    $0x4,%esp
801090d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090d9:	50                   	push   %eax
801090da:	ff 75 f0             	pushl  -0x10(%ebp)
801090dd:	ff 75 f4             	pushl  -0xc(%ebp)
801090e0:	e8 33 04 00 00       	call   80109518 <arp_reply_pkt_create>
801090e5:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801090e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090eb:	83 ec 08             	sub    $0x8,%esp
801090ee:	50                   	push   %eax
801090ef:	ff 75 f0             	pushl  -0x10(%ebp)
801090f2:	e8 c2 fd ff ff       	call   80108eb9 <i8254_send>
801090f7:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801090fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090fd:	83 ec 0c             	sub    $0xc,%esp
80109100:	50                   	push   %eax
80109101:	e8 ee 96 ff ff       	call   801027f4 <kfree>
80109106:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109109:	b8 02 00 00 00       	mov    $0x2,%eax
8010910e:	eb 54                	jmp    80109164 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109113:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109117:	66 3d 00 02          	cmp    $0x200,%ax
8010911b:	75 42                	jne    8010915f <arp_proc+0x170>
8010911d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109120:	83 c0 18             	add    $0x18,%eax
80109123:	83 ec 04             	sub    $0x4,%esp
80109126:	6a 04                	push   $0x4
80109128:	50                   	push   %eax
80109129:	68 e4 f4 10 80       	push   $0x8010f4e4
8010912e:	e8 96 ba ff ff       	call   80104bc9 <memcmp>
80109133:	83 c4 10             	add    $0x10,%esp
80109136:	85 c0                	test   %eax,%eax
80109138:	75 25                	jne    8010915f <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010913a:	83 ec 0c             	sub    $0xc,%esp
8010913d:	68 9c c3 10 80       	push   $0x8010c39c
80109142:	e8 c5 72 ff ff       	call   8010040c <cprintf>
80109147:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010914a:	83 ec 0c             	sub    $0xc,%esp
8010914d:	ff 75 f4             	pushl  -0xc(%ebp)
80109150:	e8 b7 01 00 00       	call   8010930c <arp_table_update>
80109155:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109158:	b8 01 00 00 00       	mov    $0x1,%eax
8010915d:	eb 05                	jmp    80109164 <arp_proc+0x175>
  }else{
    return -1;
8010915f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109164:	c9                   	leave  
80109165:	c3                   	ret    

80109166 <arp_scan>:

void arp_scan(){
80109166:	f3 0f 1e fb          	endbr32 
8010916a:	55                   	push   %ebp
8010916b:	89 e5                	mov    %esp,%ebp
8010916d:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109170:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109177:	eb 6f                	jmp    801091e8 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109179:	e8 14 97 ff ff       	call   80102892 <kalloc>
8010917e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109181:	83 ec 04             	sub    $0x4,%esp
80109184:	ff 75 f4             	pushl  -0xc(%ebp)
80109187:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010918a:	50                   	push   %eax
8010918b:	ff 75 ec             	pushl  -0x14(%ebp)
8010918e:	e8 62 00 00 00       	call   801091f5 <arp_broadcast>
80109193:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109196:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109199:	83 ec 08             	sub    $0x8,%esp
8010919c:	50                   	push   %eax
8010919d:	ff 75 ec             	pushl  -0x14(%ebp)
801091a0:	e8 14 fd ff ff       	call   80108eb9 <i8254_send>
801091a5:	83 c4 10             	add    $0x10,%esp
801091a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801091ab:	eb 22                	jmp    801091cf <arp_scan+0x69>
      microdelay(1);
801091ad:	83 ec 0c             	sub    $0xc,%esp
801091b0:	6a 01                	push   $0x1
801091b2:	e8 8d 9a ff ff       	call   80102c44 <microdelay>
801091b7:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801091ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091bd:	83 ec 08             	sub    $0x8,%esp
801091c0:	50                   	push   %eax
801091c1:	ff 75 ec             	pushl  -0x14(%ebp)
801091c4:	e8 f0 fc ff ff       	call   80108eb9 <i8254_send>
801091c9:	83 c4 10             	add    $0x10,%esp
801091cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801091cf:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801091d3:	74 d8                	je     801091ad <arp_scan+0x47>
    }
    kfree((char *)send);
801091d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091d8:	83 ec 0c             	sub    $0xc,%esp
801091db:	50                   	push   %eax
801091dc:	e8 13 96 ff ff       	call   801027f4 <kfree>
801091e1:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801091e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091e8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801091ef:	7e 88                	jle    80109179 <arp_scan+0x13>
  }
}
801091f1:	90                   	nop
801091f2:	90                   	nop
801091f3:	c9                   	leave  
801091f4:	c3                   	ret    

801091f5 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801091f5:	f3 0f 1e fb          	endbr32 
801091f9:	55                   	push   %ebp
801091fa:	89 e5                	mov    %esp,%ebp
801091fc:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801091ff:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109203:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109207:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010920b:	8b 45 10             	mov    0x10(%ebp),%eax
8010920e:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109211:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109218:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010921e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109225:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010922b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010922e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109234:	8b 45 08             	mov    0x8(%ebp),%eax
80109237:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010923a:	8b 45 08             	mov    0x8(%ebp),%eax
8010923d:	83 c0 0e             	add    $0xe,%eax
80109240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109246:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010924a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109254:	83 ec 04             	sub    $0x4,%esp
80109257:	6a 06                	push   $0x6
80109259:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010925c:	52                   	push   %edx
8010925d:	50                   	push   %eax
8010925e:	e8 c2 b9 ff ff       	call   80104c25 <memmove>
80109263:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109269:	83 c0 06             	add    $0x6,%eax
8010926c:	83 ec 04             	sub    $0x4,%esp
8010926f:	6a 06                	push   $0x6
80109271:	68 68 d0 18 80       	push   $0x8018d068
80109276:	50                   	push   %eax
80109277:	e8 a9 b9 ff ff       	call   80104c25 <memmove>
8010927c:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010927f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109282:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109287:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928a:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109293:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010929a:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010929e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a1:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801092a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092aa:	8d 50 12             	lea    0x12(%eax),%edx
801092ad:	83 ec 04             	sub    $0x4,%esp
801092b0:	6a 06                	push   $0x6
801092b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801092b5:	50                   	push   %eax
801092b6:	52                   	push   %edx
801092b7:	e8 69 b9 ff ff       	call   80104c25 <memmove>
801092bc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801092bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c2:	8d 50 18             	lea    0x18(%eax),%edx
801092c5:	83 ec 04             	sub    $0x4,%esp
801092c8:	6a 04                	push   $0x4
801092ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801092cd:	50                   	push   %eax
801092ce:	52                   	push   %edx
801092cf:	e8 51 b9 ff ff       	call   80104c25 <memmove>
801092d4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801092d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092da:	83 c0 08             	add    $0x8,%eax
801092dd:	83 ec 04             	sub    $0x4,%esp
801092e0:	6a 06                	push   $0x6
801092e2:	68 68 d0 18 80       	push   $0x8018d068
801092e7:	50                   	push   %eax
801092e8:	e8 38 b9 ff ff       	call   80104c25 <memmove>
801092ed:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092f3:	83 c0 0e             	add    $0xe,%eax
801092f6:	83 ec 04             	sub    $0x4,%esp
801092f9:	6a 04                	push   $0x4
801092fb:	68 e4 f4 10 80       	push   $0x8010f4e4
80109300:	50                   	push   %eax
80109301:	e8 1f b9 ff ff       	call   80104c25 <memmove>
80109306:	83 c4 10             	add    $0x10,%esp
}
80109309:	90                   	nop
8010930a:	c9                   	leave  
8010930b:	c3                   	ret    

8010930c <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010930c:	f3 0f 1e fb          	endbr32 
80109310:	55                   	push   %ebp
80109311:	89 e5                	mov    %esp,%ebp
80109313:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109316:	8b 45 08             	mov    0x8(%ebp),%eax
80109319:	83 c0 0e             	add    $0xe,%eax
8010931c:	83 ec 0c             	sub    $0xc,%esp
8010931f:	50                   	push   %eax
80109320:	e8 bc 00 00 00       	call   801093e1 <arp_table_search>
80109325:	83 c4 10             	add    $0x10,%esp
80109328:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010932b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010932f:	78 2d                	js     8010935e <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109331:	8b 45 08             	mov    0x8(%ebp),%eax
80109334:	8d 48 08             	lea    0x8(%eax),%ecx
80109337:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010933a:	89 d0                	mov    %edx,%eax
8010933c:	c1 e0 02             	shl    $0x2,%eax
8010933f:	01 d0                	add    %edx,%eax
80109341:	01 c0                	add    %eax,%eax
80109343:	01 d0                	add    %edx,%eax
80109345:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010934a:	83 c0 04             	add    $0x4,%eax
8010934d:	83 ec 04             	sub    $0x4,%esp
80109350:	6a 06                	push   $0x6
80109352:	51                   	push   %ecx
80109353:	50                   	push   %eax
80109354:	e8 cc b8 ff ff       	call   80104c25 <memmove>
80109359:	83 c4 10             	add    $0x10,%esp
8010935c:	eb 70                	jmp    801093ce <arp_table_update+0xc2>
  }else{
    index += 1;
8010935e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109362:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109365:	8b 45 08             	mov    0x8(%ebp),%eax
80109368:	8d 48 08             	lea    0x8(%eax),%ecx
8010936b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010936e:	89 d0                	mov    %edx,%eax
80109370:	c1 e0 02             	shl    $0x2,%eax
80109373:	01 d0                	add    %edx,%eax
80109375:	01 c0                	add    %eax,%eax
80109377:	01 d0                	add    %edx,%eax
80109379:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010937e:	83 c0 04             	add    $0x4,%eax
80109381:	83 ec 04             	sub    $0x4,%esp
80109384:	6a 06                	push   $0x6
80109386:	51                   	push   %ecx
80109387:	50                   	push   %eax
80109388:	e8 98 b8 ff ff       	call   80104c25 <memmove>
8010938d:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109390:	8b 45 08             	mov    0x8(%ebp),%eax
80109393:	8d 48 0e             	lea    0xe(%eax),%ecx
80109396:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109399:	89 d0                	mov    %edx,%eax
8010939b:	c1 e0 02             	shl    $0x2,%eax
8010939e:	01 d0                	add    %edx,%eax
801093a0:	01 c0                	add    %eax,%eax
801093a2:	01 d0                	add    %edx,%eax
801093a4:	05 80 d0 18 80       	add    $0x8018d080,%eax
801093a9:	83 ec 04             	sub    $0x4,%esp
801093ac:	6a 04                	push   $0x4
801093ae:	51                   	push   %ecx
801093af:	50                   	push   %eax
801093b0:	e8 70 b8 ff ff       	call   80104c25 <memmove>
801093b5:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801093b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093bb:	89 d0                	mov    %edx,%eax
801093bd:	c1 e0 02             	shl    $0x2,%eax
801093c0:	01 d0                	add    %edx,%eax
801093c2:	01 c0                	add    %eax,%eax
801093c4:	01 d0                	add    %edx,%eax
801093c6:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801093cb:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801093ce:	83 ec 0c             	sub    $0xc,%esp
801093d1:	68 80 d0 18 80       	push   $0x8018d080
801093d6:	e8 87 00 00 00       	call   80109462 <print_arp_table>
801093db:	83 c4 10             	add    $0x10,%esp
}
801093de:	90                   	nop
801093df:	c9                   	leave  
801093e0:	c3                   	ret    

801093e1 <arp_table_search>:

int arp_table_search(uchar *ip){
801093e1:	f3 0f 1e fb          	endbr32 
801093e5:	55                   	push   %ebp
801093e6:	89 e5                	mov    %esp,%ebp
801093e8:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801093eb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801093f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801093f9:	eb 59                	jmp    80109454 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801093fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801093fe:	89 d0                	mov    %edx,%eax
80109400:	c1 e0 02             	shl    $0x2,%eax
80109403:	01 d0                	add    %edx,%eax
80109405:	01 c0                	add    %eax,%eax
80109407:	01 d0                	add    %edx,%eax
80109409:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010940e:	83 ec 04             	sub    $0x4,%esp
80109411:	6a 04                	push   $0x4
80109413:	ff 75 08             	pushl  0x8(%ebp)
80109416:	50                   	push   %eax
80109417:	e8 ad b7 ff ff       	call   80104bc9 <memcmp>
8010941c:	83 c4 10             	add    $0x10,%esp
8010941f:	85 c0                	test   %eax,%eax
80109421:	75 05                	jne    80109428 <arp_table_search+0x47>
      return i;
80109423:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109426:	eb 38                	jmp    80109460 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109428:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010942b:	89 d0                	mov    %edx,%eax
8010942d:	c1 e0 02             	shl    $0x2,%eax
80109430:	01 d0                	add    %edx,%eax
80109432:	01 c0                	add    %eax,%eax
80109434:	01 d0                	add    %edx,%eax
80109436:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010943b:	0f b6 00             	movzbl (%eax),%eax
8010943e:	84 c0                	test   %al,%al
80109440:	75 0e                	jne    80109450 <arp_table_search+0x6f>
80109442:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109446:	75 08                	jne    80109450 <arp_table_search+0x6f>
      empty = -i;
80109448:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944b:	f7 d8                	neg    %eax
8010944d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109450:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109454:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109458:	7e a1                	jle    801093fb <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010945a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010945d:	83 e8 01             	sub    $0x1,%eax
}
80109460:	c9                   	leave  
80109461:	c3                   	ret    

80109462 <print_arp_table>:

void print_arp_table(){
80109462:	f3 0f 1e fb          	endbr32 
80109466:	55                   	push   %ebp
80109467:	89 e5                	mov    %esp,%ebp
80109469:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010946c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109473:	e9 92 00 00 00       	jmp    8010950a <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109478:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010947b:	89 d0                	mov    %edx,%eax
8010947d:	c1 e0 02             	shl    $0x2,%eax
80109480:	01 d0                	add    %edx,%eax
80109482:	01 c0                	add    %eax,%eax
80109484:	01 d0                	add    %edx,%eax
80109486:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010948b:	0f b6 00             	movzbl (%eax),%eax
8010948e:	84 c0                	test   %al,%al
80109490:	74 74                	je     80109506 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109492:	83 ec 08             	sub    $0x8,%esp
80109495:	ff 75 f4             	pushl  -0xc(%ebp)
80109498:	68 af c3 10 80       	push   $0x8010c3af
8010949d:	e8 6a 6f ff ff       	call   8010040c <cprintf>
801094a2:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801094a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094a8:	89 d0                	mov    %edx,%eax
801094aa:	c1 e0 02             	shl    $0x2,%eax
801094ad:	01 d0                	add    %edx,%eax
801094af:	01 c0                	add    %eax,%eax
801094b1:	01 d0                	add    %edx,%eax
801094b3:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094b8:	83 ec 0c             	sub    $0xc,%esp
801094bb:	50                   	push   %eax
801094bc:	e8 5c 02 00 00       	call   8010971d <print_ipv4>
801094c1:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801094c4:	83 ec 0c             	sub    $0xc,%esp
801094c7:	68 be c3 10 80       	push   $0x8010c3be
801094cc:	e8 3b 6f ff ff       	call   8010040c <cprintf>
801094d1:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801094d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094d7:	89 d0                	mov    %edx,%eax
801094d9:	c1 e0 02             	shl    $0x2,%eax
801094dc:	01 d0                	add    %edx,%eax
801094de:	01 c0                	add    %eax,%eax
801094e0:	01 d0                	add    %edx,%eax
801094e2:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094e7:	83 c0 04             	add    $0x4,%eax
801094ea:	83 ec 0c             	sub    $0xc,%esp
801094ed:	50                   	push   %eax
801094ee:	e8 7c 02 00 00       	call   8010976f <print_mac>
801094f3:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801094f6:	83 ec 0c             	sub    $0xc,%esp
801094f9:	68 c0 c3 10 80       	push   $0x8010c3c0
801094fe:	e8 09 6f ff ff       	call   8010040c <cprintf>
80109503:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109506:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010950a:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010950e:	0f 8e 64 ff ff ff    	jle    80109478 <print_arp_table+0x16>
    }
  }
}
80109514:	90                   	nop
80109515:	90                   	nop
80109516:	c9                   	leave  
80109517:	c3                   	ret    

80109518 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109518:	f3 0f 1e fb          	endbr32 
8010951c:	55                   	push   %ebp
8010951d:	89 e5                	mov    %esp,%ebp
8010951f:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109522:	8b 45 10             	mov    0x10(%ebp),%eax
80109525:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010952b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010952e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109531:	8b 45 0c             	mov    0xc(%ebp),%eax
80109534:	83 c0 0e             	add    $0xe,%eax
80109537:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010953a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109544:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109548:	8b 45 08             	mov    0x8(%ebp),%eax
8010954b:	8d 50 08             	lea    0x8(%eax),%edx
8010954e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109551:	83 ec 04             	sub    $0x4,%esp
80109554:	6a 06                	push   $0x6
80109556:	52                   	push   %edx
80109557:	50                   	push   %eax
80109558:	e8 c8 b6 ff ff       	call   80104c25 <memmove>
8010955d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109563:	83 c0 06             	add    $0x6,%eax
80109566:	83 ec 04             	sub    $0x4,%esp
80109569:	6a 06                	push   $0x6
8010956b:	68 68 d0 18 80       	push   $0x8018d068
80109570:	50                   	push   %eax
80109571:	e8 af b6 ff ff       	call   80104c25 <memmove>
80109576:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010957c:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109581:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109584:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010958a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010958d:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109594:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010959b:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801095a1:	8b 45 08             	mov    0x8(%ebp),%eax
801095a4:	8d 50 08             	lea    0x8(%eax),%edx
801095a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095aa:	83 c0 12             	add    $0x12,%eax
801095ad:	83 ec 04             	sub    $0x4,%esp
801095b0:	6a 06                	push   $0x6
801095b2:	52                   	push   %edx
801095b3:	50                   	push   %eax
801095b4:	e8 6c b6 ff ff       	call   80104c25 <memmove>
801095b9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801095bc:	8b 45 08             	mov    0x8(%ebp),%eax
801095bf:	8d 50 0e             	lea    0xe(%eax),%edx
801095c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c5:	83 c0 18             	add    $0x18,%eax
801095c8:	83 ec 04             	sub    $0x4,%esp
801095cb:	6a 04                	push   $0x4
801095cd:	52                   	push   %edx
801095ce:	50                   	push   %eax
801095cf:	e8 51 b6 ff ff       	call   80104c25 <memmove>
801095d4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801095d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095da:	83 c0 08             	add    $0x8,%eax
801095dd:	83 ec 04             	sub    $0x4,%esp
801095e0:	6a 06                	push   $0x6
801095e2:	68 68 d0 18 80       	push   $0x8018d068
801095e7:	50                   	push   %eax
801095e8:	e8 38 b6 ff ff       	call   80104c25 <memmove>
801095ed:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801095f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f3:	83 c0 0e             	add    $0xe,%eax
801095f6:	83 ec 04             	sub    $0x4,%esp
801095f9:	6a 04                	push   $0x4
801095fb:	68 e4 f4 10 80       	push   $0x8010f4e4
80109600:	50                   	push   %eax
80109601:	e8 1f b6 ff ff       	call   80104c25 <memmove>
80109606:	83 c4 10             	add    $0x10,%esp
}
80109609:	90                   	nop
8010960a:	c9                   	leave  
8010960b:	c3                   	ret    

8010960c <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010960c:	f3 0f 1e fb          	endbr32 
80109610:	55                   	push   %ebp
80109611:	89 e5                	mov    %esp,%ebp
80109613:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109616:	83 ec 0c             	sub    $0xc,%esp
80109619:	68 c2 c3 10 80       	push   $0x8010c3c2
8010961e:	e8 e9 6d ff ff       	call   8010040c <cprintf>
80109623:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109626:	8b 45 08             	mov    0x8(%ebp),%eax
80109629:	83 c0 0e             	add    $0xe,%eax
8010962c:	83 ec 0c             	sub    $0xc,%esp
8010962f:	50                   	push   %eax
80109630:	e8 e8 00 00 00       	call   8010971d <print_ipv4>
80109635:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109638:	83 ec 0c             	sub    $0xc,%esp
8010963b:	68 c0 c3 10 80       	push   $0x8010c3c0
80109640:	e8 c7 6d ff ff       	call   8010040c <cprintf>
80109645:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109648:	8b 45 08             	mov    0x8(%ebp),%eax
8010964b:	83 c0 08             	add    $0x8,%eax
8010964e:	83 ec 0c             	sub    $0xc,%esp
80109651:	50                   	push   %eax
80109652:	e8 18 01 00 00       	call   8010976f <print_mac>
80109657:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010965a:	83 ec 0c             	sub    $0xc,%esp
8010965d:	68 c0 c3 10 80       	push   $0x8010c3c0
80109662:	e8 a5 6d ff ff       	call   8010040c <cprintf>
80109667:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010966a:	83 ec 0c             	sub    $0xc,%esp
8010966d:	68 d9 c3 10 80       	push   $0x8010c3d9
80109672:	e8 95 6d ff ff       	call   8010040c <cprintf>
80109677:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010967a:	8b 45 08             	mov    0x8(%ebp),%eax
8010967d:	83 c0 18             	add    $0x18,%eax
80109680:	83 ec 0c             	sub    $0xc,%esp
80109683:	50                   	push   %eax
80109684:	e8 94 00 00 00       	call   8010971d <print_ipv4>
80109689:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010968c:	83 ec 0c             	sub    $0xc,%esp
8010968f:	68 c0 c3 10 80       	push   $0x8010c3c0
80109694:	e8 73 6d ff ff       	call   8010040c <cprintf>
80109699:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010969c:	8b 45 08             	mov    0x8(%ebp),%eax
8010969f:	83 c0 12             	add    $0x12,%eax
801096a2:	83 ec 0c             	sub    $0xc,%esp
801096a5:	50                   	push   %eax
801096a6:	e8 c4 00 00 00       	call   8010976f <print_mac>
801096ab:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096ae:	83 ec 0c             	sub    $0xc,%esp
801096b1:	68 c0 c3 10 80       	push   $0x8010c3c0
801096b6:	e8 51 6d ff ff       	call   8010040c <cprintf>
801096bb:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801096be:	83 ec 0c             	sub    $0xc,%esp
801096c1:	68 f0 c3 10 80       	push   $0x8010c3f0
801096c6:	e8 41 6d ff ff       	call   8010040c <cprintf>
801096cb:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801096ce:	8b 45 08             	mov    0x8(%ebp),%eax
801096d1:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096d5:	66 3d 00 01          	cmp    $0x100,%ax
801096d9:	75 12                	jne    801096ed <print_arp_info+0xe1>
801096db:	83 ec 0c             	sub    $0xc,%esp
801096de:	68 fc c3 10 80       	push   $0x8010c3fc
801096e3:	e8 24 6d ff ff       	call   8010040c <cprintf>
801096e8:	83 c4 10             	add    $0x10,%esp
801096eb:	eb 1d                	jmp    8010970a <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
801096ed:	8b 45 08             	mov    0x8(%ebp),%eax
801096f0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096f4:	66 3d 00 02          	cmp    $0x200,%ax
801096f8:	75 10                	jne    8010970a <print_arp_info+0xfe>
    cprintf("Reply\n");
801096fa:	83 ec 0c             	sub    $0xc,%esp
801096fd:	68 05 c4 10 80       	push   $0x8010c405
80109702:	e8 05 6d ff ff       	call   8010040c <cprintf>
80109707:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010970a:	83 ec 0c             	sub    $0xc,%esp
8010970d:	68 c0 c3 10 80       	push   $0x8010c3c0
80109712:	e8 f5 6c ff ff       	call   8010040c <cprintf>
80109717:	83 c4 10             	add    $0x10,%esp
}
8010971a:	90                   	nop
8010971b:	c9                   	leave  
8010971c:	c3                   	ret    

8010971d <print_ipv4>:

void print_ipv4(uchar *ip){
8010971d:	f3 0f 1e fb          	endbr32 
80109721:	55                   	push   %ebp
80109722:	89 e5                	mov    %esp,%ebp
80109724:	53                   	push   %ebx
80109725:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109728:	8b 45 08             	mov    0x8(%ebp),%eax
8010972b:	83 c0 03             	add    $0x3,%eax
8010972e:	0f b6 00             	movzbl (%eax),%eax
80109731:	0f b6 d8             	movzbl %al,%ebx
80109734:	8b 45 08             	mov    0x8(%ebp),%eax
80109737:	83 c0 02             	add    $0x2,%eax
8010973a:	0f b6 00             	movzbl (%eax),%eax
8010973d:	0f b6 c8             	movzbl %al,%ecx
80109740:	8b 45 08             	mov    0x8(%ebp),%eax
80109743:	83 c0 01             	add    $0x1,%eax
80109746:	0f b6 00             	movzbl (%eax),%eax
80109749:	0f b6 d0             	movzbl %al,%edx
8010974c:	8b 45 08             	mov    0x8(%ebp),%eax
8010974f:	0f b6 00             	movzbl (%eax),%eax
80109752:	0f b6 c0             	movzbl %al,%eax
80109755:	83 ec 0c             	sub    $0xc,%esp
80109758:	53                   	push   %ebx
80109759:	51                   	push   %ecx
8010975a:	52                   	push   %edx
8010975b:	50                   	push   %eax
8010975c:	68 0c c4 10 80       	push   $0x8010c40c
80109761:	e8 a6 6c ff ff       	call   8010040c <cprintf>
80109766:	83 c4 20             	add    $0x20,%esp
}
80109769:	90                   	nop
8010976a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010976d:	c9                   	leave  
8010976e:	c3                   	ret    

8010976f <print_mac>:

void print_mac(uchar *mac){
8010976f:	f3 0f 1e fb          	endbr32 
80109773:	55                   	push   %ebp
80109774:	89 e5                	mov    %esp,%ebp
80109776:	57                   	push   %edi
80109777:	56                   	push   %esi
80109778:	53                   	push   %ebx
80109779:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010977c:	8b 45 08             	mov    0x8(%ebp),%eax
8010977f:	83 c0 05             	add    $0x5,%eax
80109782:	0f b6 00             	movzbl (%eax),%eax
80109785:	0f b6 f8             	movzbl %al,%edi
80109788:	8b 45 08             	mov    0x8(%ebp),%eax
8010978b:	83 c0 04             	add    $0x4,%eax
8010978e:	0f b6 00             	movzbl (%eax),%eax
80109791:	0f b6 f0             	movzbl %al,%esi
80109794:	8b 45 08             	mov    0x8(%ebp),%eax
80109797:	83 c0 03             	add    $0x3,%eax
8010979a:	0f b6 00             	movzbl (%eax),%eax
8010979d:	0f b6 d8             	movzbl %al,%ebx
801097a0:	8b 45 08             	mov    0x8(%ebp),%eax
801097a3:	83 c0 02             	add    $0x2,%eax
801097a6:	0f b6 00             	movzbl (%eax),%eax
801097a9:	0f b6 c8             	movzbl %al,%ecx
801097ac:	8b 45 08             	mov    0x8(%ebp),%eax
801097af:	83 c0 01             	add    $0x1,%eax
801097b2:	0f b6 00             	movzbl (%eax),%eax
801097b5:	0f b6 d0             	movzbl %al,%edx
801097b8:	8b 45 08             	mov    0x8(%ebp),%eax
801097bb:	0f b6 00             	movzbl (%eax),%eax
801097be:	0f b6 c0             	movzbl %al,%eax
801097c1:	83 ec 04             	sub    $0x4,%esp
801097c4:	57                   	push   %edi
801097c5:	56                   	push   %esi
801097c6:	53                   	push   %ebx
801097c7:	51                   	push   %ecx
801097c8:	52                   	push   %edx
801097c9:	50                   	push   %eax
801097ca:	68 24 c4 10 80       	push   $0x8010c424
801097cf:	e8 38 6c ff ff       	call   8010040c <cprintf>
801097d4:	83 c4 20             	add    $0x20,%esp
}
801097d7:	90                   	nop
801097d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801097db:	5b                   	pop    %ebx
801097dc:	5e                   	pop    %esi
801097dd:	5f                   	pop    %edi
801097de:	5d                   	pop    %ebp
801097df:	c3                   	ret    

801097e0 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801097e0:	f3 0f 1e fb          	endbr32 
801097e4:	55                   	push   %ebp
801097e5:	89 e5                	mov    %esp,%ebp
801097e7:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801097ea:	8b 45 08             	mov    0x8(%ebp),%eax
801097ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801097f0:	8b 45 08             	mov    0x8(%ebp),%eax
801097f3:	83 c0 0e             	add    $0xe,%eax
801097f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801097f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097fc:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109800:	3c 08                	cmp    $0x8,%al
80109802:	75 1b                	jne    8010981f <eth_proc+0x3f>
80109804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109807:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010980b:	3c 06                	cmp    $0x6,%al
8010980d:	75 10                	jne    8010981f <eth_proc+0x3f>
    arp_proc(pkt_addr);
8010980f:	83 ec 0c             	sub    $0xc,%esp
80109812:	ff 75 f0             	pushl  -0x10(%ebp)
80109815:	e8 d5 f7 ff ff       	call   80108fef <arp_proc>
8010981a:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010981d:	eb 24                	jmp    80109843 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010981f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109822:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109826:	3c 08                	cmp    $0x8,%al
80109828:	75 19                	jne    80109843 <eth_proc+0x63>
8010982a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109831:	84 c0                	test   %al,%al
80109833:	75 0e                	jne    80109843 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109835:	83 ec 0c             	sub    $0xc,%esp
80109838:	ff 75 08             	pushl  0x8(%ebp)
8010983b:	e8 b3 00 00 00       	call   801098f3 <ipv4_proc>
80109840:	83 c4 10             	add    $0x10,%esp
}
80109843:	90                   	nop
80109844:	c9                   	leave  
80109845:	c3                   	ret    

80109846 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109846:	f3 0f 1e fb          	endbr32 
8010984a:	55                   	push   %ebp
8010984b:	89 e5                	mov    %esp,%ebp
8010984d:	83 ec 04             	sub    $0x4,%esp
80109850:	8b 45 08             	mov    0x8(%ebp),%eax
80109853:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109857:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010985b:	c1 e0 08             	shl    $0x8,%eax
8010985e:	89 c2                	mov    %eax,%edx
80109860:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109864:	66 c1 e8 08          	shr    $0x8,%ax
80109868:	01 d0                	add    %edx,%eax
}
8010986a:	c9                   	leave  
8010986b:	c3                   	ret    

8010986c <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010986c:	f3 0f 1e fb          	endbr32 
80109870:	55                   	push   %ebp
80109871:	89 e5                	mov    %esp,%ebp
80109873:	83 ec 04             	sub    $0x4,%esp
80109876:	8b 45 08             	mov    0x8(%ebp),%eax
80109879:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010987d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109881:	c1 e0 08             	shl    $0x8,%eax
80109884:	89 c2                	mov    %eax,%edx
80109886:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010988a:	66 c1 e8 08          	shr    $0x8,%ax
8010988e:	01 d0                	add    %edx,%eax
}
80109890:	c9                   	leave  
80109891:	c3                   	ret    

80109892 <H2N_uint>:

uint H2N_uint(uint value){
80109892:	f3 0f 1e fb          	endbr32 
80109896:	55                   	push   %ebp
80109897:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109899:	8b 45 08             	mov    0x8(%ebp),%eax
8010989c:	c1 e0 18             	shl    $0x18,%eax
8010989f:	25 00 00 00 0f       	and    $0xf000000,%eax
801098a4:	89 c2                	mov    %eax,%edx
801098a6:	8b 45 08             	mov    0x8(%ebp),%eax
801098a9:	c1 e0 08             	shl    $0x8,%eax
801098ac:	25 00 f0 00 00       	and    $0xf000,%eax
801098b1:	09 c2                	or     %eax,%edx
801098b3:	8b 45 08             	mov    0x8(%ebp),%eax
801098b6:	c1 e8 08             	shr    $0x8,%eax
801098b9:	83 e0 0f             	and    $0xf,%eax
801098bc:	01 d0                	add    %edx,%eax
}
801098be:	5d                   	pop    %ebp
801098bf:	c3                   	ret    

801098c0 <N2H_uint>:

uint N2H_uint(uint value){
801098c0:	f3 0f 1e fb          	endbr32 
801098c4:	55                   	push   %ebp
801098c5:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801098c7:	8b 45 08             	mov    0x8(%ebp),%eax
801098ca:	c1 e0 18             	shl    $0x18,%eax
801098cd:	89 c2                	mov    %eax,%edx
801098cf:	8b 45 08             	mov    0x8(%ebp),%eax
801098d2:	c1 e0 08             	shl    $0x8,%eax
801098d5:	25 00 00 ff 00       	and    $0xff0000,%eax
801098da:	01 c2                	add    %eax,%edx
801098dc:	8b 45 08             	mov    0x8(%ebp),%eax
801098df:	c1 e8 08             	shr    $0x8,%eax
801098e2:	25 00 ff 00 00       	and    $0xff00,%eax
801098e7:	01 c2                	add    %eax,%edx
801098e9:	8b 45 08             	mov    0x8(%ebp),%eax
801098ec:	c1 e8 18             	shr    $0x18,%eax
801098ef:	01 d0                	add    %edx,%eax
}
801098f1:	5d                   	pop    %ebp
801098f2:	c3                   	ret    

801098f3 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801098f3:	f3 0f 1e fb          	endbr32 
801098f7:	55                   	push   %ebp
801098f8:	89 e5                	mov    %esp,%ebp
801098fa:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801098fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109900:	83 c0 0e             	add    $0xe,%eax
80109903:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109909:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010990d:	0f b7 d0             	movzwl %ax,%edx
80109910:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109915:	39 c2                	cmp    %eax,%edx
80109917:	74 60                	je     80109979 <ipv4_proc+0x86>
80109919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010991c:	83 c0 0c             	add    $0xc,%eax
8010991f:	83 ec 04             	sub    $0x4,%esp
80109922:	6a 04                	push   $0x4
80109924:	50                   	push   %eax
80109925:	68 e4 f4 10 80       	push   $0x8010f4e4
8010992a:	e8 9a b2 ff ff       	call   80104bc9 <memcmp>
8010992f:	83 c4 10             	add    $0x10,%esp
80109932:	85 c0                	test   %eax,%eax
80109934:	74 43                	je     80109979 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109939:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010993d:	0f b7 c0             	movzwl %ax,%eax
80109940:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109948:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010994c:	3c 01                	cmp    $0x1,%al
8010994e:	75 10                	jne    80109960 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109950:	83 ec 0c             	sub    $0xc,%esp
80109953:	ff 75 08             	pushl  0x8(%ebp)
80109956:	e8 a7 00 00 00       	call   80109a02 <icmp_proc>
8010995b:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010995e:	eb 19                	jmp    80109979 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109963:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109967:	3c 06                	cmp    $0x6,%al
80109969:	75 0e                	jne    80109979 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010996b:	83 ec 0c             	sub    $0xc,%esp
8010996e:	ff 75 08             	pushl  0x8(%ebp)
80109971:	e8 c7 03 00 00       	call   80109d3d <tcp_proc>
80109976:	83 c4 10             	add    $0x10,%esp
}
80109979:	90                   	nop
8010997a:	c9                   	leave  
8010997b:	c3                   	ret    

8010997c <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010997c:	f3 0f 1e fb          	endbr32 
80109980:	55                   	push   %ebp
80109981:	89 e5                	mov    %esp,%ebp
80109983:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109986:	8b 45 08             	mov    0x8(%ebp),%eax
80109989:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010998c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010998f:	0f b6 00             	movzbl (%eax),%eax
80109992:	83 e0 0f             	and    $0xf,%eax
80109995:	01 c0                	add    %eax,%eax
80109997:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010999a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801099a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801099a8:	eb 48                	jmp    801099f2 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801099aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099ad:	01 c0                	add    %eax,%eax
801099af:	89 c2                	mov    %eax,%edx
801099b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b4:	01 d0                	add    %edx,%eax
801099b6:	0f b6 00             	movzbl (%eax),%eax
801099b9:	0f b6 c0             	movzbl %al,%eax
801099bc:	c1 e0 08             	shl    $0x8,%eax
801099bf:	89 c2                	mov    %eax,%edx
801099c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099c4:	01 c0                	add    %eax,%eax
801099c6:	8d 48 01             	lea    0x1(%eax),%ecx
801099c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099cc:	01 c8                	add    %ecx,%eax
801099ce:	0f b6 00             	movzbl (%eax),%eax
801099d1:	0f b6 c0             	movzbl %al,%eax
801099d4:	01 d0                	add    %edx,%eax
801099d6:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801099d9:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801099e0:	76 0c                	jbe    801099ee <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
801099e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099e5:	0f b7 c0             	movzwl %ax,%eax
801099e8:	83 c0 01             	add    $0x1,%eax
801099eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
801099ee:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801099f2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801099f6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801099f9:	7c af                	jl     801099aa <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
801099fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099fe:	f7 d0                	not    %eax
}
80109a00:	c9                   	leave  
80109a01:	c3                   	ret    

80109a02 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109a02:	f3 0f 1e fb          	endbr32 
80109a06:	55                   	push   %ebp
80109a07:	89 e5                	mov    %esp,%ebp
80109a09:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0f:	83 c0 0e             	add    $0xe,%eax
80109a12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a18:	0f b6 00             	movzbl (%eax),%eax
80109a1b:	0f b6 c0             	movzbl %al,%eax
80109a1e:	83 e0 0f             	and    $0xf,%eax
80109a21:	c1 e0 02             	shl    $0x2,%eax
80109a24:	89 c2                	mov    %eax,%edx
80109a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a29:	01 d0                	add    %edx,%eax
80109a2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a31:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109a35:	84 c0                	test   %al,%al
80109a37:	75 4f                	jne    80109a88 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a3c:	0f b6 00             	movzbl (%eax),%eax
80109a3f:	3c 08                	cmp    $0x8,%al
80109a41:	75 45                	jne    80109a88 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109a43:	e8 4a 8e ff ff       	call   80102892 <kalloc>
80109a48:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109a4b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109a52:	83 ec 04             	sub    $0x4,%esp
80109a55:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109a58:	50                   	push   %eax
80109a59:	ff 75 ec             	pushl  -0x14(%ebp)
80109a5c:	ff 75 08             	pushl  0x8(%ebp)
80109a5f:	e8 7c 00 00 00       	call   80109ae0 <icmp_reply_pkt_create>
80109a64:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109a67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a6a:	83 ec 08             	sub    $0x8,%esp
80109a6d:	50                   	push   %eax
80109a6e:	ff 75 ec             	pushl  -0x14(%ebp)
80109a71:	e8 43 f4 ff ff       	call   80108eb9 <i8254_send>
80109a76:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109a79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a7c:	83 ec 0c             	sub    $0xc,%esp
80109a7f:	50                   	push   %eax
80109a80:	e8 6f 8d ff ff       	call   801027f4 <kfree>
80109a85:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109a88:	90                   	nop
80109a89:	c9                   	leave  
80109a8a:	c3                   	ret    

80109a8b <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109a8b:	f3 0f 1e fb          	endbr32 
80109a8f:	55                   	push   %ebp
80109a90:	89 e5                	mov    %esp,%ebp
80109a92:	53                   	push   %ebx
80109a93:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109a96:	8b 45 08             	mov    0x8(%ebp),%eax
80109a99:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a9d:	0f b7 c0             	movzwl %ax,%eax
80109aa0:	83 ec 0c             	sub    $0xc,%esp
80109aa3:	50                   	push   %eax
80109aa4:	e8 9d fd ff ff       	call   80109846 <N2H_ushort>
80109aa9:	83 c4 10             	add    $0x10,%esp
80109aac:	0f b7 d8             	movzwl %ax,%ebx
80109aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ab6:	0f b7 c0             	movzwl %ax,%eax
80109ab9:	83 ec 0c             	sub    $0xc,%esp
80109abc:	50                   	push   %eax
80109abd:	e8 84 fd ff ff       	call   80109846 <N2H_ushort>
80109ac2:	83 c4 10             	add    $0x10,%esp
80109ac5:	0f b7 c0             	movzwl %ax,%eax
80109ac8:	83 ec 04             	sub    $0x4,%esp
80109acb:	53                   	push   %ebx
80109acc:	50                   	push   %eax
80109acd:	68 43 c4 10 80       	push   $0x8010c443
80109ad2:	e8 35 69 ff ff       	call   8010040c <cprintf>
80109ad7:	83 c4 10             	add    $0x10,%esp
}
80109ada:	90                   	nop
80109adb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109ade:	c9                   	leave  
80109adf:	c3                   	ret    

80109ae0 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109ae0:	f3 0f 1e fb          	endbr32 
80109ae4:	55                   	push   %ebp
80109ae5:	89 e5                	mov    %esp,%ebp
80109ae7:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109aea:	8b 45 08             	mov    0x8(%ebp),%eax
80109aed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109af0:	8b 45 08             	mov    0x8(%ebp),%eax
80109af3:	83 c0 0e             	add    $0xe,%eax
80109af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109afc:	0f b6 00             	movzbl (%eax),%eax
80109aff:	0f b6 c0             	movzbl %al,%eax
80109b02:	83 e0 0f             	and    $0xf,%eax
80109b05:	c1 e0 02             	shl    $0x2,%eax
80109b08:	89 c2                	mov    %eax,%edx
80109b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b0d:	01 d0                	add    %edx,%eax
80109b0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b12:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b15:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b18:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b1b:	83 c0 0e             	add    $0xe,%eax
80109b1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109b21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b24:	83 c0 14             	add    $0x14,%eax
80109b27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109b2a:	8b 45 10             	mov    0x10(%ebp),%eax
80109b2d:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b36:	8d 50 06             	lea    0x6(%eax),%edx
80109b39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b3c:	83 ec 04             	sub    $0x4,%esp
80109b3f:	6a 06                	push   $0x6
80109b41:	52                   	push   %edx
80109b42:	50                   	push   %eax
80109b43:	e8 dd b0 ff ff       	call   80104c25 <memmove>
80109b48:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b4e:	83 c0 06             	add    $0x6,%eax
80109b51:	83 ec 04             	sub    $0x4,%esp
80109b54:	6a 06                	push   $0x6
80109b56:	68 68 d0 18 80       	push   $0x8018d068
80109b5b:	50                   	push   %eax
80109b5c:	e8 c4 b0 ff ff       	call   80104c25 <memmove>
80109b61:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b67:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b6e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b75:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b7b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109b7f:	83 ec 0c             	sub    $0xc,%esp
80109b82:	6a 54                	push   $0x54
80109b84:	e8 e3 fc ff ff       	call   8010986c <H2N_ushort>
80109b89:	83 c4 10             	add    $0x10,%esp
80109b8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b8f:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b93:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b9d:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109ba1:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109ba8:	83 c0 01             	add    $0x1,%eax
80109bab:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109bb1:	83 ec 0c             	sub    $0xc,%esp
80109bb4:	68 00 40 00 00       	push   $0x4000
80109bb9:	e8 ae fc ff ff       	call   8010986c <H2N_ushort>
80109bbe:	83 c4 10             	add    $0x10,%esp
80109bc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bc4:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109bc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bcb:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109bcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd9:	83 c0 0c             	add    $0xc,%eax
80109bdc:	83 ec 04             	sub    $0x4,%esp
80109bdf:	6a 04                	push   $0x4
80109be1:	68 e4 f4 10 80       	push   $0x8010f4e4
80109be6:	50                   	push   %eax
80109be7:	e8 39 b0 ff ff       	call   80104c25 <memmove>
80109bec:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bf2:	8d 50 0c             	lea    0xc(%eax),%edx
80109bf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf8:	83 c0 10             	add    $0x10,%eax
80109bfb:	83 ec 04             	sub    $0x4,%esp
80109bfe:	6a 04                	push   $0x4
80109c00:	52                   	push   %edx
80109c01:	50                   	push   %eax
80109c02:	e8 1e b0 ff ff       	call   80104c25 <memmove>
80109c07:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c0d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c16:	83 ec 0c             	sub    $0xc,%esp
80109c19:	50                   	push   %eax
80109c1a:	e8 5d fd ff ff       	call   8010997c <ipv4_chksum>
80109c1f:	83 c4 10             	add    $0x10,%esp
80109c22:	0f b7 c0             	movzwl %ax,%eax
80109c25:	83 ec 0c             	sub    $0xc,%esp
80109c28:	50                   	push   %eax
80109c29:	e8 3e fc ff ff       	call   8010986c <H2N_ushort>
80109c2e:	83 c4 10             	add    $0x10,%esp
80109c31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c34:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109c38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c3b:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109c3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c41:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c48:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109c4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c4f:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c56:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109c5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c5d:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109c61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c64:	8d 50 08             	lea    0x8(%eax),%edx
80109c67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c6a:	83 c0 08             	add    $0x8,%eax
80109c6d:	83 ec 04             	sub    $0x4,%esp
80109c70:	6a 08                	push   $0x8
80109c72:	52                   	push   %edx
80109c73:	50                   	push   %eax
80109c74:	e8 ac af ff ff       	call   80104c25 <memmove>
80109c79:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109c7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c7f:	8d 50 10             	lea    0x10(%eax),%edx
80109c82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c85:	83 c0 10             	add    $0x10,%eax
80109c88:	83 ec 04             	sub    $0x4,%esp
80109c8b:	6a 30                	push   $0x30
80109c8d:	52                   	push   %edx
80109c8e:	50                   	push   %eax
80109c8f:	e8 91 af ff ff       	call   80104c25 <memmove>
80109c94:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c9a:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109ca0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ca3:	83 ec 0c             	sub    $0xc,%esp
80109ca6:	50                   	push   %eax
80109ca7:	e8 1c 00 00 00       	call   80109cc8 <icmp_chksum>
80109cac:	83 c4 10             	add    $0x10,%esp
80109caf:	0f b7 c0             	movzwl %ax,%eax
80109cb2:	83 ec 0c             	sub    $0xc,%esp
80109cb5:	50                   	push   %eax
80109cb6:	e8 b1 fb ff ff       	call   8010986c <H2N_ushort>
80109cbb:	83 c4 10             	add    $0x10,%esp
80109cbe:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109cc1:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109cc5:	90                   	nop
80109cc6:	c9                   	leave  
80109cc7:	c3                   	ret    

80109cc8 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109cc8:	f3 0f 1e fb          	endbr32 
80109ccc:	55                   	push   %ebp
80109ccd:	89 e5                	mov    %esp,%ebp
80109ccf:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109cd8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109cdf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109ce6:	eb 48                	jmp    80109d30 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109ce8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ceb:	01 c0                	add    %eax,%eax
80109ced:	89 c2                	mov    %eax,%edx
80109cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cf2:	01 d0                	add    %edx,%eax
80109cf4:	0f b6 00             	movzbl (%eax),%eax
80109cf7:	0f b6 c0             	movzbl %al,%eax
80109cfa:	c1 e0 08             	shl    $0x8,%eax
80109cfd:	89 c2                	mov    %eax,%edx
80109cff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d02:	01 c0                	add    %eax,%eax
80109d04:	8d 48 01             	lea    0x1(%eax),%ecx
80109d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d0a:	01 c8                	add    %ecx,%eax
80109d0c:	0f b6 00             	movzbl (%eax),%eax
80109d0f:	0f b6 c0             	movzbl %al,%eax
80109d12:	01 d0                	add    %edx,%eax
80109d14:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d17:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d1e:	76 0c                	jbe    80109d2c <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d20:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d23:	0f b7 c0             	movzwl %ax,%eax
80109d26:	83 c0 01             	add    $0x1,%eax
80109d29:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d2c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d30:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109d34:	7e b2                	jle    80109ce8 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109d36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d39:	f7 d0                	not    %eax
}
80109d3b:	c9                   	leave  
80109d3c:	c3                   	ret    

80109d3d <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109d3d:	f3 0f 1e fb          	endbr32 
80109d41:	55                   	push   %ebp
80109d42:	89 e5                	mov    %esp,%ebp
80109d44:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109d47:	8b 45 08             	mov    0x8(%ebp),%eax
80109d4a:	83 c0 0e             	add    $0xe,%eax
80109d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d53:	0f b6 00             	movzbl (%eax),%eax
80109d56:	0f b6 c0             	movzbl %al,%eax
80109d59:	83 e0 0f             	and    $0xf,%eax
80109d5c:	c1 e0 02             	shl    $0x2,%eax
80109d5f:	89 c2                	mov    %eax,%edx
80109d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d64:	01 d0                	add    %edx,%eax
80109d66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d6c:	83 c0 14             	add    $0x14,%eax
80109d6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109d72:	e8 1b 8b ff ff       	call   80102892 <kalloc>
80109d77:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109d7a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d84:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d88:	0f b6 c0             	movzbl %al,%eax
80109d8b:	83 e0 02             	and    $0x2,%eax
80109d8e:	85 c0                	test   %eax,%eax
80109d90:	74 3d                	je     80109dcf <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109d92:	83 ec 0c             	sub    $0xc,%esp
80109d95:	6a 00                	push   $0x0
80109d97:	6a 12                	push   $0x12
80109d99:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d9c:	50                   	push   %eax
80109d9d:	ff 75 e8             	pushl  -0x18(%ebp)
80109da0:	ff 75 08             	pushl  0x8(%ebp)
80109da3:	e8 a2 01 00 00       	call   80109f4a <tcp_pkt_create>
80109da8:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109dab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109dae:	83 ec 08             	sub    $0x8,%esp
80109db1:	50                   	push   %eax
80109db2:	ff 75 e8             	pushl  -0x18(%ebp)
80109db5:	e8 ff f0 ff ff       	call   80108eb9 <i8254_send>
80109dba:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109dbd:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109dc2:	83 c0 01             	add    $0x1,%eax
80109dc5:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109dca:	e9 69 01 00 00       	jmp    80109f38 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dd2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109dd6:	3c 18                	cmp    $0x18,%al
80109dd8:	0f 85 10 01 00 00    	jne    80109eee <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109dde:	83 ec 04             	sub    $0x4,%esp
80109de1:	6a 03                	push   $0x3
80109de3:	68 5e c4 10 80       	push   $0x8010c45e
80109de8:	ff 75 ec             	pushl  -0x14(%ebp)
80109deb:	e8 d9 ad ff ff       	call   80104bc9 <memcmp>
80109df0:	83 c4 10             	add    $0x10,%esp
80109df3:	85 c0                	test   %eax,%eax
80109df5:	74 74                	je     80109e6b <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109df7:	83 ec 0c             	sub    $0xc,%esp
80109dfa:	68 62 c4 10 80       	push   $0x8010c462
80109dff:	e8 08 66 ff ff       	call   8010040c <cprintf>
80109e04:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e07:	83 ec 0c             	sub    $0xc,%esp
80109e0a:	6a 00                	push   $0x0
80109e0c:	6a 10                	push   $0x10
80109e0e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e11:	50                   	push   %eax
80109e12:	ff 75 e8             	pushl  -0x18(%ebp)
80109e15:	ff 75 08             	pushl  0x8(%ebp)
80109e18:	e8 2d 01 00 00       	call   80109f4a <tcp_pkt_create>
80109e1d:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e20:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e23:	83 ec 08             	sub    $0x8,%esp
80109e26:	50                   	push   %eax
80109e27:	ff 75 e8             	pushl  -0x18(%ebp)
80109e2a:	e8 8a f0 ff ff       	call   80108eb9 <i8254_send>
80109e2f:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e35:	83 c0 36             	add    $0x36,%eax
80109e38:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e3b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109e3e:	50                   	push   %eax
80109e3f:	ff 75 e0             	pushl  -0x20(%ebp)
80109e42:	6a 00                	push   $0x0
80109e44:	6a 00                	push   $0x0
80109e46:	e8 66 04 00 00       	call   8010a2b1 <http_proc>
80109e4b:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109e4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109e51:	83 ec 0c             	sub    $0xc,%esp
80109e54:	50                   	push   %eax
80109e55:	6a 18                	push   $0x18
80109e57:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e5a:	50                   	push   %eax
80109e5b:	ff 75 e8             	pushl  -0x18(%ebp)
80109e5e:	ff 75 08             	pushl  0x8(%ebp)
80109e61:	e8 e4 00 00 00       	call   80109f4a <tcp_pkt_create>
80109e66:	83 c4 20             	add    $0x20,%esp
80109e69:	eb 62                	jmp    80109ecd <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e6b:	83 ec 0c             	sub    $0xc,%esp
80109e6e:	6a 00                	push   $0x0
80109e70:	6a 10                	push   $0x10
80109e72:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e75:	50                   	push   %eax
80109e76:	ff 75 e8             	pushl  -0x18(%ebp)
80109e79:	ff 75 08             	pushl  0x8(%ebp)
80109e7c:	e8 c9 00 00 00       	call   80109f4a <tcp_pkt_create>
80109e81:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109e84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e87:	83 ec 08             	sub    $0x8,%esp
80109e8a:	50                   	push   %eax
80109e8b:	ff 75 e8             	pushl  -0x18(%ebp)
80109e8e:	e8 26 f0 ff ff       	call   80108eb9 <i8254_send>
80109e93:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e99:	83 c0 36             	add    $0x36,%eax
80109e9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e9f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109ea2:	50                   	push   %eax
80109ea3:	ff 75 e4             	pushl  -0x1c(%ebp)
80109ea6:	6a 00                	push   $0x0
80109ea8:	6a 00                	push   $0x0
80109eaa:	e8 02 04 00 00       	call   8010a2b1 <http_proc>
80109eaf:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109eb2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109eb5:	83 ec 0c             	sub    $0xc,%esp
80109eb8:	50                   	push   %eax
80109eb9:	6a 18                	push   $0x18
80109ebb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ebe:	50                   	push   %eax
80109ebf:	ff 75 e8             	pushl  -0x18(%ebp)
80109ec2:	ff 75 08             	pushl  0x8(%ebp)
80109ec5:	e8 80 00 00 00       	call   80109f4a <tcp_pkt_create>
80109eca:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109ecd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ed0:	83 ec 08             	sub    $0x8,%esp
80109ed3:	50                   	push   %eax
80109ed4:	ff 75 e8             	pushl  -0x18(%ebp)
80109ed7:	e8 dd ef ff ff       	call   80108eb9 <i8254_send>
80109edc:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109edf:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109ee4:	83 c0 01             	add    $0x1,%eax
80109ee7:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109eec:	eb 4a                	jmp    80109f38 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ef1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ef5:	3c 10                	cmp    $0x10,%al
80109ef7:	75 3f                	jne    80109f38 <tcp_proc+0x1fb>
    if(fin_flag == 1){
80109ef9:	a1 48 d3 18 80       	mov    0x8018d348,%eax
80109efe:	83 f8 01             	cmp    $0x1,%eax
80109f01:	75 35                	jne    80109f38 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f03:	83 ec 0c             	sub    $0xc,%esp
80109f06:	6a 00                	push   $0x0
80109f08:	6a 01                	push   $0x1
80109f0a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f0d:	50                   	push   %eax
80109f0e:	ff 75 e8             	pushl  -0x18(%ebp)
80109f11:	ff 75 08             	pushl  0x8(%ebp)
80109f14:	e8 31 00 00 00       	call   80109f4a <tcp_pkt_create>
80109f19:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f1f:	83 ec 08             	sub    $0x8,%esp
80109f22:	50                   	push   %eax
80109f23:	ff 75 e8             	pushl  -0x18(%ebp)
80109f26:	e8 8e ef ff ff       	call   80108eb9 <i8254_send>
80109f2b:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109f2e:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
80109f35:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109f38:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f3b:	83 ec 0c             	sub    $0xc,%esp
80109f3e:	50                   	push   %eax
80109f3f:	e8 b0 88 ff ff       	call   801027f4 <kfree>
80109f44:	83 c4 10             	add    $0x10,%esp
}
80109f47:	90                   	nop
80109f48:	c9                   	leave  
80109f49:	c3                   	ret    

80109f4a <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109f4a:	f3 0f 1e fb          	endbr32 
80109f4e:	55                   	push   %ebp
80109f4f:	89 e5                	mov    %esp,%ebp
80109f51:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109f54:	8b 45 08             	mov    0x8(%ebp),%eax
80109f57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109f5d:	83 c0 0e             	add    $0xe,%eax
80109f60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f66:	0f b6 00             	movzbl (%eax),%eax
80109f69:	0f b6 c0             	movzbl %al,%eax
80109f6c:	83 e0 0f             	and    $0xf,%eax
80109f6f:	c1 e0 02             	shl    $0x2,%eax
80109f72:	89 c2                	mov    %eax,%edx
80109f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f77:	01 d0                	add    %edx,%eax
80109f79:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f7f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109f82:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f85:	83 c0 0e             	add    $0xe,%eax
80109f88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109f8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f8e:	83 c0 14             	add    $0x14,%eax
80109f91:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109f94:	8b 45 18             	mov    0x18(%ebp),%eax
80109f97:	8d 50 36             	lea    0x36(%eax),%edx
80109f9a:	8b 45 10             	mov    0x10(%ebp),%eax
80109f9d:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fa2:	8d 50 06             	lea    0x6(%eax),%edx
80109fa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fa8:	83 ec 04             	sub    $0x4,%esp
80109fab:	6a 06                	push   $0x6
80109fad:	52                   	push   %edx
80109fae:	50                   	push   %eax
80109faf:	e8 71 ac ff ff       	call   80104c25 <memmove>
80109fb4:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109fb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fba:	83 c0 06             	add    $0x6,%eax
80109fbd:	83 ec 04             	sub    $0x4,%esp
80109fc0:	6a 06                	push   $0x6
80109fc2:	68 68 d0 18 80       	push   $0x8018d068
80109fc7:	50                   	push   %eax
80109fc8:	e8 58 ac ff ff       	call   80104c25 <memmove>
80109fcd:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109fd0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fd3:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109fd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fda:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fe1:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fe7:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109feb:	8b 45 18             	mov    0x18(%ebp),%eax
80109fee:	83 c0 28             	add    $0x28,%eax
80109ff1:	0f b7 c0             	movzwl %ax,%eax
80109ff4:	83 ec 0c             	sub    $0xc,%esp
80109ff7:	50                   	push   %eax
80109ff8:	e8 6f f8 ff ff       	call   8010986c <H2N_ushort>
80109ffd:	83 c4 10             	add    $0x10,%esp
8010a000:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a003:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a007:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a00e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a011:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a015:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a01c:	83 c0 01             	add    $0x1,%eax
8010a01f:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a025:	83 ec 0c             	sub    $0xc,%esp
8010a028:	6a 00                	push   $0x0
8010a02a:	e8 3d f8 ff ff       	call   8010986c <H2N_ushort>
8010a02f:	83 c4 10             	add    $0x10,%esp
8010a032:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a035:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a040:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a043:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a04a:	83 c0 0c             	add    $0xc,%eax
8010a04d:	83 ec 04             	sub    $0x4,%esp
8010a050:	6a 04                	push   $0x4
8010a052:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a057:	50                   	push   %eax
8010a058:	e8 c8 ab ff ff       	call   80104c25 <memmove>
8010a05d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a060:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a063:	8d 50 0c             	lea    0xc(%eax),%edx
8010a066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a069:	83 c0 10             	add    $0x10,%eax
8010a06c:	83 ec 04             	sub    $0x4,%esp
8010a06f:	6a 04                	push   $0x4
8010a071:	52                   	push   %edx
8010a072:	50                   	push   %eax
8010a073:	e8 ad ab ff ff       	call   80104c25 <memmove>
8010a078:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a07b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a07e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a084:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a087:	83 ec 0c             	sub    $0xc,%esp
8010a08a:	50                   	push   %eax
8010a08b:	e8 ec f8 ff ff       	call   8010997c <ipv4_chksum>
8010a090:	83 c4 10             	add    $0x10,%esp
8010a093:	0f b7 c0             	movzwl %ax,%eax
8010a096:	83 ec 0c             	sub    $0xc,%esp
8010a099:	50                   	push   %eax
8010a09a:	e8 cd f7 ff ff       	call   8010986c <H2N_ushort>
8010a09f:	83 c4 10             	add    $0x10,%esp
8010a0a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0a5:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a0a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0ac:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a0b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0b3:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a0b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0b9:	0f b7 10             	movzwl (%eax),%edx
8010a0bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0bf:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a0c3:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a0c8:	83 ec 0c             	sub    $0xc,%esp
8010a0cb:	50                   	push   %eax
8010a0cc:	e8 c1 f7 ff ff       	call   80109892 <H2N_uint>
8010a0d1:	83 c4 10             	add    $0x10,%esp
8010a0d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a0d7:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a0da:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0dd:	8b 40 04             	mov    0x4(%eax),%eax
8010a0e0:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a0e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0e9:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a0ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0ef:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a0f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0f6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a0fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0fd:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a101:	8b 45 14             	mov    0x14(%ebp),%eax
8010a104:	89 c2                	mov    %eax,%edx
8010a106:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a109:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a10c:	83 ec 0c             	sub    $0xc,%esp
8010a10f:	68 90 38 00 00       	push   $0x3890
8010a114:	e8 53 f7 ff ff       	call   8010986c <H2N_ushort>
8010a119:	83 c4 10             	add    $0x10,%esp
8010a11c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a11f:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a123:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a126:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a12c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a12f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a138:	83 ec 0c             	sub    $0xc,%esp
8010a13b:	50                   	push   %eax
8010a13c:	e8 1f 00 00 00       	call   8010a160 <tcp_chksum>
8010a141:	83 c4 10             	add    $0x10,%esp
8010a144:	83 c0 08             	add    $0x8,%eax
8010a147:	0f b7 c0             	movzwl %ax,%eax
8010a14a:	83 ec 0c             	sub    $0xc,%esp
8010a14d:	50                   	push   %eax
8010a14e:	e8 19 f7 ff ff       	call   8010986c <H2N_ushort>
8010a153:	83 c4 10             	add    $0x10,%esp
8010a156:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a159:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a15d:	90                   	nop
8010a15e:	c9                   	leave  
8010a15f:	c3                   	ret    

8010a160 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a160:	f3 0f 1e fb          	endbr32 
8010a164:	55                   	push   %ebp
8010a165:	89 e5                	mov    %esp,%ebp
8010a167:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a16a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a16d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a170:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a173:	83 c0 14             	add    $0x14,%eax
8010a176:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a179:	83 ec 04             	sub    $0x4,%esp
8010a17c:	6a 04                	push   $0x4
8010a17e:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a183:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a186:	50                   	push   %eax
8010a187:	e8 99 aa ff ff       	call   80104c25 <memmove>
8010a18c:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a18f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a192:	83 c0 0c             	add    $0xc,%eax
8010a195:	83 ec 04             	sub    $0x4,%esp
8010a198:	6a 04                	push   $0x4
8010a19a:	50                   	push   %eax
8010a19b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a19e:	83 c0 04             	add    $0x4,%eax
8010a1a1:	50                   	push   %eax
8010a1a2:	e8 7e aa ff ff       	call   80104c25 <memmove>
8010a1a7:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a1aa:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a1ae:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a1b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1b5:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a1b9:	0f b7 c0             	movzwl %ax,%eax
8010a1bc:	83 ec 0c             	sub    $0xc,%esp
8010a1bf:	50                   	push   %eax
8010a1c0:	e8 81 f6 ff ff       	call   80109846 <N2H_ushort>
8010a1c5:	83 c4 10             	add    $0x10,%esp
8010a1c8:	83 e8 14             	sub    $0x14,%eax
8010a1cb:	0f b7 c0             	movzwl %ax,%eax
8010a1ce:	83 ec 0c             	sub    $0xc,%esp
8010a1d1:	50                   	push   %eax
8010a1d2:	e8 95 f6 ff ff       	call   8010986c <H2N_ushort>
8010a1d7:	83 c4 10             	add    $0x10,%esp
8010a1da:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a1de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a1e5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a1eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a1f2:	eb 33                	jmp    8010a227 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a1f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1f7:	01 c0                	add    %eax,%eax
8010a1f9:	89 c2                	mov    %eax,%edx
8010a1fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1fe:	01 d0                	add    %edx,%eax
8010a200:	0f b6 00             	movzbl (%eax),%eax
8010a203:	0f b6 c0             	movzbl %al,%eax
8010a206:	c1 e0 08             	shl    $0x8,%eax
8010a209:	89 c2                	mov    %eax,%edx
8010a20b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a20e:	01 c0                	add    %eax,%eax
8010a210:	8d 48 01             	lea    0x1(%eax),%ecx
8010a213:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a216:	01 c8                	add    %ecx,%eax
8010a218:	0f b6 00             	movzbl (%eax),%eax
8010a21b:	0f b6 c0             	movzbl %al,%eax
8010a21e:	01 d0                	add    %edx,%eax
8010a220:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a223:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a227:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a22b:	7e c7                	jle    8010a1f4 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a22d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a230:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a233:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a23a:	eb 33                	jmp    8010a26f <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a23c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a23f:	01 c0                	add    %eax,%eax
8010a241:	89 c2                	mov    %eax,%edx
8010a243:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a246:	01 d0                	add    %edx,%eax
8010a248:	0f b6 00             	movzbl (%eax),%eax
8010a24b:	0f b6 c0             	movzbl %al,%eax
8010a24e:	c1 e0 08             	shl    $0x8,%eax
8010a251:	89 c2                	mov    %eax,%edx
8010a253:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a256:	01 c0                	add    %eax,%eax
8010a258:	8d 48 01             	lea    0x1(%eax),%ecx
8010a25b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a25e:	01 c8                	add    %ecx,%eax
8010a260:	0f b6 00             	movzbl (%eax),%eax
8010a263:	0f b6 c0             	movzbl %al,%eax
8010a266:	01 d0                	add    %edx,%eax
8010a268:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a26b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a26f:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a273:	0f b7 c0             	movzwl %ax,%eax
8010a276:	83 ec 0c             	sub    $0xc,%esp
8010a279:	50                   	push   %eax
8010a27a:	e8 c7 f5 ff ff       	call   80109846 <N2H_ushort>
8010a27f:	83 c4 10             	add    $0x10,%esp
8010a282:	66 d1 e8             	shr    %ax
8010a285:	0f b7 c0             	movzwl %ax,%eax
8010a288:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a28b:	7c af                	jl     8010a23c <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a290:	c1 e8 10             	shr    $0x10,%eax
8010a293:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a296:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a299:	f7 d0                	not    %eax
}
8010a29b:	c9                   	leave  
8010a29c:	c3                   	ret    

8010a29d <tcp_fin>:

void tcp_fin(){
8010a29d:	f3 0f 1e fb          	endbr32 
8010a2a1:	55                   	push   %ebp
8010a2a2:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a2a4:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a2ab:	00 00 00 
}
8010a2ae:	90                   	nop
8010a2af:	5d                   	pop    %ebp
8010a2b0:	c3                   	ret    

8010a2b1 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a2b1:	f3 0f 1e fb          	endbr32 
8010a2b5:	55                   	push   %ebp
8010a2b6:	89 e5                	mov    %esp,%ebp
8010a2b8:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a2bb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2be:	83 ec 04             	sub    $0x4,%esp
8010a2c1:	6a 00                	push   $0x0
8010a2c3:	68 6b c4 10 80       	push   $0x8010c46b
8010a2c8:	50                   	push   %eax
8010a2c9:	e8 65 00 00 00       	call   8010a333 <http_strcpy>
8010a2ce:	83 c4 10             	add    $0x10,%esp
8010a2d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a2d4:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2d7:	83 ec 04             	sub    $0x4,%esp
8010a2da:	ff 75 f4             	pushl  -0xc(%ebp)
8010a2dd:	68 7e c4 10 80       	push   $0x8010c47e
8010a2e2:	50                   	push   %eax
8010a2e3:	e8 4b 00 00 00       	call   8010a333 <http_strcpy>
8010a2e8:	83 c4 10             	add    $0x10,%esp
8010a2eb:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a2ee:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2f1:	83 ec 04             	sub    $0x4,%esp
8010a2f4:	ff 75 f4             	pushl  -0xc(%ebp)
8010a2f7:	68 99 c4 10 80       	push   $0x8010c499
8010a2fc:	50                   	push   %eax
8010a2fd:	e8 31 00 00 00       	call   8010a333 <http_strcpy>
8010a302:	83 c4 10             	add    $0x10,%esp
8010a305:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a30b:	83 e0 01             	and    $0x1,%eax
8010a30e:	85 c0                	test   %eax,%eax
8010a310:	74 11                	je     8010a323 <http_proc+0x72>
    char *payload = (char *)send;
8010a312:	8b 45 10             	mov    0x10(%ebp),%eax
8010a315:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a318:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a31b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a31e:	01 d0                	add    %edx,%eax
8010a320:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a323:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a326:	8b 45 14             	mov    0x14(%ebp),%eax
8010a329:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a32b:	e8 6d ff ff ff       	call   8010a29d <tcp_fin>
}
8010a330:	90                   	nop
8010a331:	c9                   	leave  
8010a332:	c3                   	ret    

8010a333 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a333:	f3 0f 1e fb          	endbr32 
8010a337:	55                   	push   %ebp
8010a338:	89 e5                	mov    %esp,%ebp
8010a33a:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a33d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a344:	eb 20                	jmp    8010a366 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a346:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a34c:	01 d0                	add    %edx,%eax
8010a34e:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a351:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a354:	01 ca                	add    %ecx,%edx
8010a356:	89 d1                	mov    %edx,%ecx
8010a358:	8b 55 08             	mov    0x8(%ebp),%edx
8010a35b:	01 ca                	add    %ecx,%edx
8010a35d:	0f b6 00             	movzbl (%eax),%eax
8010a360:	88 02                	mov    %al,(%edx)
    i++;
8010a362:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a366:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a369:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a36c:	01 d0                	add    %edx,%eax
8010a36e:	0f b6 00             	movzbl (%eax),%eax
8010a371:	84 c0                	test   %al,%al
8010a373:	75 d1                	jne    8010a346 <http_strcpy+0x13>
  }
  return i;
8010a375:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a378:	c9                   	leave  
8010a379:	c3                   	ret    

8010a37a <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a37a:	f3 0f 1e fb          	endbr32 
8010a37e:	55                   	push   %ebp
8010a37f:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a381:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a388:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a38b:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a390:	c1 e8 09             	shr    $0x9,%eax
8010a393:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a398:	90                   	nop
8010a399:	5d                   	pop    %ebp
8010a39a:	c3                   	ret    

8010a39b <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a39b:	f3 0f 1e fb          	endbr32 
8010a39f:	55                   	push   %ebp
8010a3a0:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a3a2:	90                   	nop
8010a3a3:	5d                   	pop    %ebp
8010a3a4:	c3                   	ret    

8010a3a5 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a3a5:	f3 0f 1e fb          	endbr32 
8010a3a9:	55                   	push   %ebp
8010a3aa:	89 e5                	mov    %esp,%ebp
8010a3ac:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a3af:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3b2:	83 c0 0c             	add    $0xc,%eax
8010a3b5:	83 ec 0c             	sub    $0xc,%esp
8010a3b8:	50                   	push   %eax
8010a3b9:	e8 78 a4 ff ff       	call   80104836 <holdingsleep>
8010a3be:	83 c4 10             	add    $0x10,%esp
8010a3c1:	85 c0                	test   %eax,%eax
8010a3c3:	75 0d                	jne    8010a3d2 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a3c5:	83 ec 0c             	sub    $0xc,%esp
8010a3c8:	68 aa c4 10 80       	push   $0x8010c4aa
8010a3cd:	e8 f3 61 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a3d2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3d5:	8b 00                	mov    (%eax),%eax
8010a3d7:	83 e0 06             	and    $0x6,%eax
8010a3da:	83 f8 02             	cmp    $0x2,%eax
8010a3dd:	75 0d                	jne    8010a3ec <iderw+0x47>
    panic("iderw: nothing to do");
8010a3df:	83 ec 0c             	sub    $0xc,%esp
8010a3e2:	68 c0 c4 10 80       	push   $0x8010c4c0
8010a3e7:	e8 d9 61 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a3ec:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ef:	8b 40 04             	mov    0x4(%eax),%eax
8010a3f2:	83 f8 01             	cmp    $0x1,%eax
8010a3f5:	74 0d                	je     8010a404 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a3f7:	83 ec 0c             	sub    $0xc,%esp
8010a3fa:	68 d5 c4 10 80       	push   $0x8010c4d5
8010a3ff:	e8 c1 61 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a404:	8b 45 08             	mov    0x8(%ebp),%eax
8010a407:	8b 40 08             	mov    0x8(%eax),%eax
8010a40a:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a410:	39 d0                	cmp    %edx,%eax
8010a412:	72 0d                	jb     8010a421 <iderw+0x7c>
    panic("iderw: block out of range");
8010a414:	83 ec 0c             	sub    $0xc,%esp
8010a417:	68 f3 c4 10 80       	push   $0x8010c4f3
8010a41c:	e8 a4 61 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a421:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a427:	8b 45 08             	mov    0x8(%ebp),%eax
8010a42a:	8b 40 08             	mov    0x8(%eax),%eax
8010a42d:	c1 e0 09             	shl    $0x9,%eax
8010a430:	01 d0                	add    %edx,%eax
8010a432:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a435:	8b 45 08             	mov    0x8(%ebp),%eax
8010a438:	8b 00                	mov    (%eax),%eax
8010a43a:	83 e0 04             	and    $0x4,%eax
8010a43d:	85 c0                	test   %eax,%eax
8010a43f:	74 2b                	je     8010a46c <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a441:	8b 45 08             	mov    0x8(%ebp),%eax
8010a444:	8b 00                	mov    (%eax),%eax
8010a446:	83 e0 fb             	and    $0xfffffffb,%eax
8010a449:	89 c2                	mov    %eax,%edx
8010a44b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a44e:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a450:	8b 45 08             	mov    0x8(%ebp),%eax
8010a453:	83 c0 5c             	add    $0x5c,%eax
8010a456:	83 ec 04             	sub    $0x4,%esp
8010a459:	68 00 02 00 00       	push   $0x200
8010a45e:	50                   	push   %eax
8010a45f:	ff 75 f4             	pushl  -0xc(%ebp)
8010a462:	e8 be a7 ff ff       	call   80104c25 <memmove>
8010a467:	83 c4 10             	add    $0x10,%esp
8010a46a:	eb 1a                	jmp    8010a486 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a46c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a46f:	83 c0 5c             	add    $0x5c,%eax
8010a472:	83 ec 04             	sub    $0x4,%esp
8010a475:	68 00 02 00 00       	push   $0x200
8010a47a:	ff 75 f4             	pushl  -0xc(%ebp)
8010a47d:	50                   	push   %eax
8010a47e:	e8 a2 a7 ff ff       	call   80104c25 <memmove>
8010a483:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a486:	8b 45 08             	mov    0x8(%ebp),%eax
8010a489:	8b 00                	mov    (%eax),%eax
8010a48b:	83 c8 02             	or     $0x2,%eax
8010a48e:	89 c2                	mov    %eax,%edx
8010a490:	8b 45 08             	mov    0x8(%ebp),%eax
8010a493:	89 10                	mov    %edx,(%eax)
}
8010a495:	90                   	nop
8010a496:	c9                   	leave  
8010a497:	c3                   	ret    
