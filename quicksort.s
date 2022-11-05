.section .data
msg: .asciz "Value: %d\n"
orgarray: .asciz "Original Array:\n"
sortarray: .asciz "Sorted Array:\n"
newline: .asciz "\n"
printval: .asciz "%d "


.section .text
.globl main

printarr:
	pushq %rbp
	movq %rsp, %rbp

	# rdi - pointer to array
	# rsi - array length
	subq $32, %rsp
	
	movq %rdi, -32(%rbp) # pointer to array
	movq $0, -24(%rbp) # counter
	subq $1, %rsi # subtract 1 so we don't go out of bounds
	movq %rsi, -16(%rbp) # array length

printarr_start:
	movq -24(%rbp), %rax
	movq -32(%rbp), %rcx
	leaq printval(%rip), %rdi
	movq (%rcx, %rax, 8), %rsi # arr[i]
	xor %al, %al
	call printf
	addq $1, -24(%rbp)
	movq -24(%rbp), %rax
	movq -16(%rbp), %rbx
	cmpq %rbx, %rax
	jl printarr_start # if i < array.length
printarr_end:
	leave
	ret
	
swaparr:
	pushq %rbp
	movq %rsp, %rbp

	# rdi - pointer to array
	# rsi - swap index 1
	# rdx - swap index 2

	subq $8, %rsp

	movq (%rdi, %rsi, 8), %rax 
	movq %rax, -8(%rbp) # temp = arr[idx1]

	movq (%rdi, %rdx, 8), %rax 
	movq %rax, (%rdi, %rsi, 8) # arr[idx1] = temp2

	movq -8(%rbp), %rax
	movq %rax, (%rdi, %rdx, 8) # arr[idx2] = temp

	leave
	ret

quicksort:
	pushq %rbp
	movq %rsp, %rbp

	subq $48, %rsp

	# rdi - pointer to array
	# rsi - lower bound index
	# rdx - upper bound index

	# base case 1 - return if lower_bound >= upper_bound
	cmpq %rdx, %rsi
	jge quicksort_return
	
	# base case 2 - return if upper_bound <= lower_bound
	cmpq %rsi, %rdx
	jle quicksort_return
		
	movq %rsi, -48(%rbp) # lower bound

	movq %rdi, -40(%rbp) # pointer to array

	movq %rsi, -32(%rbp) # counter

	subq $1, %rdx
	movq %rdx, -24(%rbp) # upper bound - 1

	# set pivot value (last element)
	movq -40(%rbp), %rdi
	movq -24(%rbp), %rdx
	addq $1, %rdx
	movq (%rdi, %rdx, 8), %rax
	movq %rax, -16(%rbp) 

	# set greater value index to lower bound
	movq %rsi, -8(%rbp)

	# start iterating from lower bound to upper bound - 1
quicksort_iterate_begin:
	movq -32(%rbp), %rcx # counter
	movq -16(%rbp), %rax # pivot value
	movq -40(%rbp), %rdi # pointer to array
	movq (%rdi, %rcx, 8), %rbx # arr[i]
	cmpq %rax, %rbx
	jle quicksort_swap_begin # if arr[i] <= pivot
	jmp quicksort_swap_end
quicksort_swap_begin:
	movq %rcx, %rsi
	movq -8(%rbp), %rdx
	call swaparr
	addq $1, -8(%rbp)
quicksort_swap_end:
	addq $1, -32(%rbp)
	movq -32(%rbp), %rax
	movq -24(%rbp), %rcx
	cmpq %rcx, %rax
	jle quicksort_iterate_begin
quicksort_iterate_end:
	movq -40(%rbp), %rdi
	movq -8(%rbp), %rsi
	movq -24(%rbp), %rdx
	addq $1, %rdx
	call swaparr
	movq -8(%rbp), %rax
	# recursive call for [lower_bound, pivot_idx - 1]
	movq -40(%rbp), %rdi
	movq -48(%rbp), %rsi
	subq $1, %rax
	movq %rax, %rdx
	call quicksort
	# recursive call for [pivot_idx + 1, upper_bound]
	movq -40(%rbp), %rdi
	movq -8(%rbp), %rax
	addq $1, %rax
	movq %rax, %rsi
	movq -24(%rbp), %rax
	addq $1, %rax
	movq %rax, %rdx
	call quicksort
quicksort_return:
	leave
	ret

main:
	# create array of 10 "random" 64-bit numbers on stack
	pushq %rbp
	movq %rsp, %rbp

	subq $88, %rsp
	movq $12, -88(%rbp)
	movq $8, -80(%rbp)
	movq $25, -72(%rbp)
	movq $13, -64(%rbp)
	movq $30, -56(%rbp)
	movq $2, -48(%rbp)
	movq $9, -40(%rbp)
	movq $18, -32(%rbp)
	movq $55, -24(%rbp)
	movq $14, -16(%rbp)
	# NOTE: it seems first 8 bytes on rbp is reserved? allocating below it

	leaq orgarray(%rip), %rdi
	xor %al, %al
	call printf

	leaq -88(%rbp), %rdi
	movq $10, %rsi
	call printarr

	leaq newline(%rip), %rdi
	xor %al, %al
	call printf

	# pass pointer to beginning of array to quicksort function
	# as well as the lower & upper bound indices [0-9]
	leaq -88(%rbp), %rdi
	movq $0, %rsi
	movq $9, %rdx
	call quicksort

	leaq sortarray(%rip), %rdi
	xor %al, %al
	call printf

	leaq -88(%rbp), %rdi
	movq $10, %rsi
	call printarr

	leaq newline(%rip), %rdi
	xor %al, %al
	call printf

	leave
	# return 0	
	xor %rdi, %rdi
	call exit
