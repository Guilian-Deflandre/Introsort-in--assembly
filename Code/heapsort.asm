|; void heapsort(int* array, int size)
|;   @param array A pointer to the array
|;   @param size Size of the array
heapsort:
  PUSH(LP)
  PUSH(BP)
	MOVE(SP,BP)

  |; ***** Arguments *****
	PUSH(R1)
  PUSH(R2)
	LD(BP, -12, R1) 		               |; R1 = array
	LD(BP, -16, R2) 		               |; R2 = size

  |; ***** Local variables *****
  |; NB: For all our implementations, we choose to declare locals variables
  |; just after the initialisation of our arguments. This could lead to minimal
  |; non-optimalities of memory management but it simplifies the process ending
  |; of each function (by simply POP used registers at the end).
	PUSH(R3)
	DIVC(R2, 2, R3) 		               |; R3 = size/2
	SUBC(R3, 1, R3)		                 |; R3 = i = size/2 - 1

loop1:
	CMPLE(R31, R3, R0)                 |; Cannot use CMPLTC in reverse order
  BF(R0, end_loop1)
  PUSH(R3)       				             |; i
  PUSH(R2)       				             |; size
	PUSH(R1)       	  			           |; array
  CALL(heapify, 3)     	             |; heapify(array, size, i)
  SUBC(R3, 1, R3)	    	             |; R3 = i - 1
  BR(loop1)

end_loop1:
	SUBC(R2, 1, R3)	    	             |; R3 = size - 1 = i

loop2:
	CMPLE(R31, R3, R0)                 |; Cannot use CMPLTC in reverse order
  BF(R0, heapsort_end)
	ADDR(R1, R3, R0)       	           |; R0 = array + 4 * i (valid address)

  |; We need new registers to perform the swap
  PUSH(R4)
  PUSH(R5)
  SWAP(R1, R0, R4, R5)	             |; swap(array, array + i)
  POP(R5)                            |; We don't need these registers anymore
  POP(R4)

  PUSH(R31)                          |; 0
  PUSH(R3)            	             |; i
  PUSH(R1)            	             |; array
  CALL(heapify, 3)   	               |; heapify(array, i, 0)
  SUBC(R3, 1, R3)	    	             |; R3 = i = i-1
	BR(loop2)

heapsort_end:
	POP(R3)
  POP(R2)
  POP(R1)
	MOVE(BP, SP)
	POP(BP)
  POP(LP)
	RTN()

heapify:
 	PUSH(LP)
	PUSH(BP)
	MOVE(SP, BP)

  |; ***** Arguments *****
	PUSH(R1)
  PUSH(R2)
  PUSH(R3)
	LD(BP, -12, R1) 		               |; R1 = array
	LD(BP, -16, R2) 		               |; R2 = size
	LD(BP, -20, R3) 		               |; R3 = index

  |; ***** Local variables *****
  |; NB: For all our implementations, we choose to declare locals variables
  |; just after the initialisation of our arguments. This could lead to minimal
  |; non-optimalities of memory management but it simplifies the process ending
  |; of each function (by simply POP used registers at the end).
	PUSH(R4) 		                       |; R4 = largest
	PUSH(R5) 	                       	 |; R5 = left
	PUSH(R6) 		                       |; R6 = right

while_loop_heapify:
	CMPLT(R3, R2, R0)
  BF(R0, heapify_end)
	MOVE(R3, R4)  	 	                 |; largest = index
	MULC(R3, 2, R0) 		               |; R0 = index*2
	ADDC(R0, 1, R5) 		               |; R5 = left = index*2 + 1
	ADDC(R3, 1, R0) 		               |; R0 = index + 1
	MULC(R0, 2, R6) 		               |; R6 = right = (index + 1)*2

  CMPLT(R5, R2, R0)   	             |; R0 = left < size

  |; We need register for the double comparison
  PUSH(R7)                           |; We need register for the double comparison
  PUSH(R8)
  PUSH(R9)
  LDARR(R1, R4, R7) 	               |; R7 = array[largest]
  LDARR(R1, R5, R8) 	               |; R8 = array[left]
  CMPLT(R7, R8, R9)   	             |; array[largest] < array[left]
  AND(R0, R9, R0)                    |; R0 = left < size && array[largest] < array[left]
  POP(R9)                            |; We don't need these registers anymore
  POP(R8)
  POP(R7)

  BF(R0, if2_heapify)
  MOVE(R5, R4)     	                 |; largest = left

if2_heapify:
	CMPLT(R6,R2,R0)    	               |; R0 = right < size

  |; We need register for the double comparison
  PUSH(R7)
  PUSH(R8)
  PUSH(R9)
  LDARR(R1, R4, R7) 	               |; R7 = array[largest]
  LDARR(R1, R6, R8)  	               |; R8 = array[right]
  CMPLT(R7, R8, R9)    	             |; R9 = array[largest] < array[right]
  AND(R0, R9, R0)                    |; R0 = right < size && array[largest] < array[right]
  POP(R9)                            |; We don't need these registers anymore
  POP(R8)
  POP(R7)

  BF(R0, if3_heapify)
  MOVE(R6, R4)        	             |; largest = right

if3_heapify:
	CMPEQ(R3, R4, R0)                  |; largest != index check
  BT(R0, heapify_end)

  |; left and right are no more use until now in the code so we can reuse the
  |; registers countaining their values.
	ADDR(R1, R4, R5) 	   	             |; R5 = array+ 4 * largest
	ADDR(R1, R3, R6) 	   	             |; R6 = array+ 4 * index

  |; We need new registers to perform the swap operation
  PUSH(R7)
  PUSH(R8)
  SWAP(R5, R6, R7, R8)
  POP(R7)                            |; We don't need these registers anymore
  POP(R8)
  MOVE(R4, R3)	                     |; index = largest
  BR(while_loop_heapify)

heapify_end:
  POP(R6)
  POP(R5)
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
	MOVE(BP, SP)
	POP(BP)
  POP(LP)
	RTN()
