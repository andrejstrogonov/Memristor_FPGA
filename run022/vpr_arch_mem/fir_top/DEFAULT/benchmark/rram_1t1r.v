module rram_1t1r (
    input  wire bl, wl,
    output wire out, outb
);
    reg cfg = 1'b0;
    always @(posedge wl) cfg <= bl;
    assign out  = cfg;
    assign outb = ~cfg;
endmodule

module rram_ccff (
    input  wire p_reset, p_set, prog_clk,
    input  wire ccff_head,
    output wire ccff_tail,
    output wire mem_out, mem_outb
);
    reg shift = 1'b0;
    always @(posedge prog_clk)
        if (p_reset)     shift <= 1'b0;
        else if (p_set)  shift <= 1'b1;
        else             shift <= ccff_head;
    assign ccff_tail = shift;
    assign mem_out   = shift;      // в scan-chain бит конфигурации = сдвиговый регистр
    assign mem_outb  = ~shift;     // RRAM-запись подключим на этапе memory_bank
endmodule
