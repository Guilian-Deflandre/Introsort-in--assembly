.include beta.uasm
  CMOVE(stack__, SP)
  MOVE(SP, BP)
  BR(main)

.include util.asm
.include heapsort.asm
.include introsort.asm

ARRAY_SIZE = 10

array_size:
  LONG(ARRAY_SIZE)

array:
  STORAGE(ARRAY_SIZE)

main:
  CMOVE(array, R1)     |; array address
  LDR(array_size, R2)  |; array size
  PUSH(R2) PUSH(R1)
  CALL(fill)
  CALL(shuffle)
  CALL(introsort, 2)
  HALT()


 LONG(0xDEADCAFE) |; just to be able to locate the stack in the simulator
stack__:
