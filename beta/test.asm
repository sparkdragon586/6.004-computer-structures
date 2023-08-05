| interrupt vector table
.include beta.uasm
. = 0x0
BR(CODE_START)
BR(ILLOP_HANDLER)
BR(IRQ_HANDLER)


ILLOP_HANDLER: HALT()

IRQ_HANDLER: HALT()

CODE_START: 
  N = 12
  ADDC(r31, N, r1)
  ADDC(r31, 1, r0)
Loop: 
  MUL(r0,r1, r0)
  SUBC(r1, 1, r1)
  BNE(r1, Loop, r31)
