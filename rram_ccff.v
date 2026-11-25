module rram_ccff (
    input  wire p_reset,
    input  wire p_set,
    input  wire prog_clk,
    input  wire ccff_head,
    output wire ccff_tail,
    output wire mem_out,
    output wire mem_outb
);
    reg shift = 1'b0;
    always @(posedge prog_clk)
        if (p_reset)     shift <= 1'b0;
        else if (p_set)  shift <= 1'b1;
        else             shift <= ccff_head;
    assign ccff_tail = shift;
    assign mem_out   = shift;
    assign mem_outb  = ~shift;
endmodule