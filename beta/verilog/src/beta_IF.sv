`default_nettype none

module beta_IF (
    input STALL,
    input JT[32],
    input PC_REL[32],
    input IRQ_T_ADDR[4],
    input IRQ_T_DATA_IN[32],
    output IRQ_T_DATAOUT,
    input IRQ_T_WE,
    input IRQ_T_RE,
    input INSTRUCTION_DATA[32],
    output INSTRUCTION_ADDR[32],
    output INSTRUCTION[32],
    output PC[32]
);
endmodule
