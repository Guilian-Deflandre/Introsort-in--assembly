|; void sort(int* array, int size)
|;   @param array A pointer to the array
|;   @param size Size of the array
sort:
  PUSH(LP)
  PUSH(BP)
  MOVE(SP, BP)

  |; ***** Arguments *****
  PUSH(R1)
  PUSH(R2)
  LD(BP, -12, R1)                     |; R1 = *array
  LD(BP, -16, R2)                     |; R2 = size

  CMPEQC(R2, 0, R0)
  BT(R0, end_sort)

  |; ***** Local variables *****
  |; NB: For all our implementations, we choose to declare locals variables
  |; just after the initialisation of our arguments. This could lead to minimal
  |; non-optimalities of memory management but it simplifies the process ending
  |; of each function (by simply POP used registers at the end).
  PUSH(R3)                            |; R3 = maxd

  PUSH(R2)
  CALL(log2, 1)                       |; Return of log2 is in R0
  MULC(R0, 2, R3)                     |; R3 = maxd = 2*log2(size)
  PUSH(R3)
  PUSH(R2)
  PUSH(R1)
  CALL(introsort, 3)                  |; introsort(array, size, maxd)

end_sort:
  POP(R3)
  POP(R2)
  POP(R1)
  MOVE(BP, SP)
  POP(BP)
  POP(LP)
  RTN()


|; void introsort(int* array, int size, int maxd)
|;   @param array A pointer to the array
|;   @param size Size of the array
|;   @param maxd Maximum number of recursive calls
introsort:
  PUSH(LP)
  PUSH(BP)
  MOVE(SP, BP)

  |; ***** Arguments *****
  PUSH(R1)
  PUSH(R2)
  PUSH(R3)
  LD(BP, -12, R1)                     |; R1 = *array
  LD(BP, -16, R2)                     |; R2 = n
  LD(BP, -20, R3)                     |; R3 = maxd

  |; ***** Local variables *****
  |; NB: For all our implementations, we choose to declare locals variables
  |; just after the initialisation of our arguments. This could lead to minimal
  |; non-optimalities of memory management but it simplifies the process ending
  |; of each function (by simply POP used registers at the end).
  PUSH(R4)                            |; R4 = pivot
  PUSH(R5)                            |; R5 = i
  PUSH(R6)                            |; R6 = l
  PUSH(R7)                            |; R7 = r

first_while_intro:
  CMOVE(1, R0)                        |; R0 = 1, Cannot use CMPLTC in reverse order
  CMPLT(R0, R2, R0)                   |; R0 = 1 < n
  BF(R0, end_first_while_intro)
  CMPLEC(R3, 0, R0)
  BF(R0, after_if_first_while_intro)

  PUSH(R2)
  PUSH(R1)
  CALL(heapsort, 2)                   |; heapsort(array, n)

after_if_first_while_intro:
  SUBC(R3, 1, R3)                     |; R3 = maxd-1
  PUSH(R2)
  PUSH(R1)
  CALL(median3, 2)                    |; R0 = return of median3(array, n)
  MOVE(R0, R4)                        |; R4 = pivot = median3(array, n)


  |; TREE-WAY PARTITION
  CMOVE(0, R5)                        |; i = 0
  CMOVE(0, R6)                        |; l = 0
  MOVE(R2, R7)                        |; r = n

second_while_intro:
  CMPLT(R5, R7, R0)                   |; R0 = i < r
  BF(R0, end_second_while_intro)
  LDARR(R1, R5, R0)                   |; R0 = array[i]
  CMPLT(R0, R4, R0)                   |; R0 = array[i] < pivot
  BF(R0, else_if_second_while_intro)

  |; We need new registers to perform the swap operation
  PUSH(R8)
  PUSH(R9)
  PUSH(R10)
  ADDR(R1, R5, R0)                    |; R0 = array + 4 * i, valid address
  ADDR(R1, R6, R8)                    |; R8 = array + 4 * l, valid address
  SWAP(R0, R8, R9, R10)               |; swap(array + i, array + l)
  POP(R10)                            |; We don't need these registers anymore
  POP(R9)
  POP(R8)

  ADDC(R5, 1, R5)
  ADDC(R6, 1, R6)
  BR(second_while_intro)


else_if_second_while_intro:
  LDARR(R1, R5, R0)                   |; R0 = array[i]
  CMPLT(R4, R0, R0)                   |; R0 = array[i] > pivot
  BF(R0, else_second_while_intro)
  SUBC(R7, 1, R7)

  |; We need new registers to perform the swap operation
  PUSH(R8)
  PUSH(R9)
  PUSH(R10)
  ADDR(R1, R5, R0)                    |; R0 = array + 4 * i, valid address
  ADDR(R1, R7, R8)                    |; R8 = array + 4 * r, valid address
  SWAP(R0, R8, R9, R10)               |; swap(array + i, array + r)
  POP(R10)                            |; We don't need these registers anymore
  POP(R9)
  POP(R8)
  BR(second_while_intro)

else_second_while_intro:
  ADDC(R5, 1, R5)
  BR(second_while_intro)

end_second_while_intro:
  PUSH(R3)
  PUSH(R6)
  PUSH(R1)
  CALL(introsort, 3)                  |; introsort(array, l, maxd)
  MULC(R7, 4, R0)                     |; R0 = 4 * l
  ADD(R1, R0, R1)                     |; R1 = array = array + 4 * r, valid address
  SUB(R2, R7, R2)
  BR(first_while_intro)

end_first_while_intro:
  POP(R7)
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

|; int median3(int* array, int n))
|;   @param array A pointer to the array
|;   @param n Size of the array
|;   @return Either the begining, the half or the end value of array
median3:
  PUSH(LP)
  PUSH(BP)
  MOVE(SP, BP)

  |; ***** Arguments *****
  PUSH(R1)
  PUSH(R2)
  LD(BP, -12, R1)                     |; R1 = *array
  LD(BP, -16, R2)                     |; R2 = n

  |; ***** Local variables *****
  |; NB: For all our implementations, we choose to declare locals variables
  |; just after the initialisation of our arguments. This could lead to minimal
  |; non-optimalities of memory management but it simplifies the process ending
  |; of each function (by simply POP used registers at the end).
  PUSH(R3)                            |; R3 = a
  PUSH(R4)                            |; R4 = b
  PUSH(R5)                            |; R5 = c

  LDARR(R1, R31, R3)                  |; R3 = a = array[0]
  DIVC(R2, 2, R0)                     |; R0 = n/2
  LDARR(R1, R0, R4)                   |; R4 = b = array[n/2]
  SUBC(R2, 1, R0)                     |; R0 = n-1
  LDARR(R1, R0, R5)                   |; R5 = c = array[n-1]

  CMPLT(R3, R4, R0)
  BF(R0, else_if_b_c_median3)         |; if(a>b), go in else if of median3
  CMPLT(R4, R5, R0)
  BT(R0, return_b_median3)
  CMPLT(R3, R5, R0)
  BT(R0, return_c_median3)
  BR(return_a_median3)

else_if_b_c_median3:
  CMPLT(R4, R5, R0)
  BF(R0, else_median3)                |; if(b>c) go in else of median3
  CMPLT(R3, R5, R0)
  BT(R0, return_a_median3)
  BR(return_c_median3)

else_median3:
  BR(return_b_median3)

return_a_median3:
  MOVE(R3, R0)                        |; R0 is the return register and worth a
  POP(R5)
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
  MOVE(BP, SP)
  POP(BP)
  POP(LP)
  RTN()

return_b_median3:
  MOVE(R4, R0)                        |; R0 is the return register and worth b
  POP(R5)
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
  MOVE(BP, SP)
  POP(BP)
  POP(LP)
  RTN()

return_c_median3:
  MOVE(R5, R0)                        |; R0 is the return register and worth c
  POP(R5)
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
  MOVE(BP, SP)
  POP(BP)
  POP(LP)
  RTN()
