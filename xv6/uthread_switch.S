# uthread_switch.S

# 전역 변수 선언 (C 코드의 current_thread, next_thread)
.globl current_thread
.globl next_thread

# thread_switch 함수 정의
.globl thread_switch
thread_switch:
  # 1. 현재 스레드의 Callee-saved 레지스터 저장
  #    (함수 호출 시 호출된 함수(callee)가 보존해야 하는 레지스터들)
  pushl %ebp
  pushl %ebx
  pushl %esi
  pushl %edi
  
  # 2. 현재 스택 포인터(ESP)를 current_thread->sp 에 저장
  #    current_thread 변수(포인터)의 주소를 %eax 로 가져옴
  movl current_thread, %eax 
  #    현재 %esp 값을 current_thread 구조체의 첫 번째 멤버(sp 필드로 가정)에 저장
  movl %esp, (%eax)        
  
  # 3. 다음 스레드로 전환 (current_thread 포인터 업데이트)
  #    next_thread 변수(포인터)의 주소를 %eax 로 가져옴
  movl next_thread, %eax
  #    current_thread 변수가 이제 next_thread 를 가리키도록 업데이트
  movl %eax, current_thread 
  
  # 4. 다음 스레드(이제 current_thread가 가리킴)의 저장된 스택 포인터를 %esp 로 복원
  #    current_thread 가 가리키는 구조체의 첫 번째 멤버(sp 필드) 값을 %esp 로 로드
  #    이제 %esp 는 다음에 실행될 스레드가 마지막으로 저장했던 스택 상태를 가리킴
  #    (스택의 최상단에는 저장된 %edi 값이 있음)
  movl (%eax), %esp          
  
  # 5. 다음 스레드의 Callee-saved 레지스터 복원 (저장 순서의 역순)
  popl %edi
  popl %esi
  popl %ebx
  popl %ebp
  
  # 6. 복귀 (Return)
  #    'ret' 명령어는 현재 %esp 가 가리키는 스택 위치에서 복귀 주소(EIP)를 pop 하고
  #    해당 주소로 점프합니다.
  #    - 스레드가 처음 생성된 경우: thread_create 에서 설정한 스레드 함수 시작 주소 (func)
  #    - 스레드가 협조적으로 양보(yield)한 경우: thread_schedule 내의 'call thread_switch' 다음 주소
  #    - 스레드가 선점(preempt)된 경우: trap.c 가 사용자 스택에 저장한 원래 실행 지점 (original_eip) 이어야 함. 
  #                                  (이 부분이 올바르게 동작하는지가 선점형 스케줄링의 핵심)
  ret