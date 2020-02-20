|; SWAP(Ra, Rb, Rt1, Rt2)  <Reg[Ra]> <=> <Reg[Rb]>  (Rt1 and Rt2 are temporary registers, should all be different)
.macro SWAP(Ra, Rb, Rt1, Rt2) LD(Ra, 0, Rt1) LD(Rb, 0, Rt2) ST(Rt1, 0, Rb) ST(Rt2, 0, Ra) 
|; ADDR(Ra, Ri, Ro)        Reg[Ra] + 4 * Reg[Ri]
.macro ADDR(Ra, Ri, Ro) MULC(Ri, 4, Ro) ADD(Ra, Ro, Ro)
|; LDARR(Ra, Ri, Ro)       Reg[Ro] <- <Reg[Ra] + 4 * Reg[Ri]>
.macro LDARR(Ra, Ri, Ro) ADDR(Ra, Ri, Ro) LD(Ro, 0, Ro)
|; ABS(Ra, Rb)             Reg[Rc] <- | Reg[Ra] |              (note: Ra should be different from Rc)
.macro ABS(Ra, Rt1, Rc) SRAC(Ra, 31, Rt1) XOR(Ra, Rt1, Rc) SUB(Rc, Rt1, Rc)
|; MOD(Ra, Rb, Rc)         Reg[Rc] <- Reg[Ra] % Reg[Rb]        (note: Ra should be different from Rc)
.macro MOD(Ra, Rb, Rc) MOVE(Ra, Rc) DIV(Ra, Rb, Rc) MUL(Rc, Rb, Rc) SUB(Ra, Rc, Rc)

|; log2(n):
|;  Compute the approximate integer logarithm of n (-> floor(log2(n))).
|;  @param n A positive integer
log2:
  PUSH(LP) PUSH(BP)
  MOVE(SP, BP)
  PUSH(R1) PUSH(R2)
  LD(BP, -12, R1)  |; n
  CMOVE(-1, R2)  |; r2 <- logval

log2_loop:
  CMPLT(R31, R1, R0)
  BF(R0, log2_end)
  SHRC(R1, 1, R1)
  ADDC(R2, 1, R2)
  BR(log2_loop)

log2_end:
  MOVE(R2, R0)
  POP(R2) POP(R1)
  POP(BP) POP(LP)
  RTN()


|; fill(array, size):
|;  Fill an array with increasing value ranging from 1 to size.
|;  @param array Address of the first element of the array
|;  @param size  The size of the array
fill: 
  PUSH(LP)           |; Save and update LP and BP
  PUSH(BP)
  MOVE(SP, BP) 

  PUSH(R1)           |; Save registers
  PUSH(R2)
  PUSH(R3)
  PUSH(R4)
  PUSH(R5)

  LD(BP, -12, R1)    |; array
  LD(BP, -16, R2)    |; size

  CMOVE(0, R3)       |; i = 0
    
fill_loop:
  CMPLT(R3, R2, R4)  |; i > 0
  BF(R4, fill_end)   |; if (i > 0) -> jump to fill_end
  ADDC(R3, 1, R4)    |; Compute value to place in the array: Reg[R4] <- i + 1 
  MULC(R3, 4, R5)    |; Reg[R5] <- 4 * i
  ADD(R1, R5, R5)    |; Compute address: Reg[R5] <- array + 4 * i
  ST(R4, 0, R5)      |; Save value in array
  ADDC(R3, 1, R3)    |; i++
  BR(fill_loop)

fill_end:
  POP(R5)            |; Restore registers
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
  POP(BP)
  POP(LP)
  RTN()

|; random_array(array, size):
|;  Fill an array with random values
|;  @param array Address of the first element of the array
|;  @param size  The size of the array
shuffle:
  PUSH(LP)              |; Save and update LP and BP
  PUSH(BP)
  MOVE(SP, BP) 

  PUSH(R1)              |; Save registers
  PUSH(R2)
  PUSH(R3)
  PUSH(R4)
  PUSH(R5)
  PUSH(R6)
  PUSH(R7)

  LD(BP, -12, R1)       |; array
  LD(BP, -16, R2)       |; size

  MOVE(R2, R3)          |; i = size
  SUBC(R3, 1, R3)       |; i--

shuffle_loop:
  CMPLT(R31, R3, R4)    |; i > 0
  BF(R4, shuffle_end)   |; if (i > 0) -> jump to shuffle_end
  RANDOM()              |; Compute swap first address : array + 4 * (rand() % i)
  ABS(R0, R6, R4)
  MOD(R4, R3, R0)
  ADDR(R1, R0, R4)             
  ADDR(R1, R3, R5)             
  SWAP(R4, R5, R6, R7)

  SUBC(R3, 1, R3)       |; i--
  BR(shuffle_loop)

shuffle_end:
  POP(R7)               |; Restore registers
  POP(R6)
  POP(R5)
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
  POP(BP)
  POP(LP)
  RTN()