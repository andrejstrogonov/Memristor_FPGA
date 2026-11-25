module fir_filter #(
    parameter TAPS = 8,
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16
) (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    en,
    input  wire signed [DATA_WIDTH-1:0] din,
    output reg  signed [DATA_WIDTH-1:0] dout
);

    reg signed [DATA_WIDTH-1:0] delay_line [0:TAPS-1];
    wire signed [COEFF_WIDTH-1:0] coeff [0:TAPS-1];
    wire signed [DATA_WIDTH+COEFF_WIDTH-1:0] mult [0:TAPS-1];
    reg signed [DATA_WIDTH+COEFF_WIDTH:0] sum;
    integer i;

    rram_coeff_storage #(
        .TAPS(TAPS),
        .WIDTH(COEFF_WIDTH)
    ) coeff_mem (
        .clk(clk),
        .coeff_out(coeff)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < TAPS; i = i + 1)
                delay_line[i] <= 0;
            dout <= 0;
        end else if (en) begin
            delay_line[0] <= din;
            for (i = 1; i < TAPS; i = i + 1)
                delay_line[i] <= delay_line[i-1];
        end
    end

    generate
        genvar g;
        for (g = 0; g < TAPS; g = g + 1) begin : MULT_STAGE
            assign mult[g] = delay_line[g] * coeff[g];
        end
    endgenerate

    always @(*) begin
        sum = 0;
        for (i = 0; i < TAPS; i = i + 1)
            sum = sum + mult[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dout <= 0;
        else if (en)
            dout <= sum[DATA_WIDTH-1:0];
    end

endmodule

module rram_coeff_storage #(
    parameter TAPS = 8,
    parameter WIDTH = 16
) (
    input  wire clk,
    output reg signed [WIDTH-1:0] coeff_out_0,
    output reg signed [WIDTH-1:0] coeff_out_1,
    output reg signed [WIDTH-1:0] coeff_out_2,
    output reg signed [WIDTH-1:0] coeff_out_3,
    output reg signed [WIDTH-1:0] coeff_out_4,
    output reg signed [WIDTH-1:0] coeff_out_5,
    output reg signed [WIDTH-1:0] coeff_out_6,
    output reg signed [WIDTH-1:0] coeff_out_7
);

    wire [TAPS-1:0] rram_bits;
    wire [TAPS-1:0] rram_bits_b;

    genvar k;
    generate
        for (k = 0; k < TAPS; k = k + 1) begin : RRAM_ARRAY
            rram_1t1r u_rram (
                .bl   (1'b0),
                .wl   (clk),
                .out  (rram_bits[k]),
                .outb (rram_bits_b[k])
            );
        end
    endgenerate

    initial begin
        coeff_out_0 =  16'sd23;
        coeff_out_1 =  16'sd45;
        coeff_out_2 = -16'sd12;
        coeff_out_3 = -16'sd67;
        coeff_out_4 = -16'sd67;
        coeff_out_5 = -16'sd12;
        coeff_out_6 =  16'sd45;
        coeff_out_7 =  16'sd23;
    end

    always @(posedge clk) begin
        coeff_out_0 <= coeff_out_0;
        coeff_out_1 <= coeff_out_1;
        coeff_out_2 <= coeff_out_2;
        coeff_out_3 <= coeff_out_3;
        coeff_out_4 <= coeff_out_4;
        coeff_out_5 <= coeff_out_5;
        coeff_out_6 <= coeff_out_6;
        coeff_out_7 <= coeff_out_7;
    end

endmodule

module fir_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [15:0] din,
    output wire [15:0] dout
);

    fir_filter #(
        .TAPS(8),
        .DATA_WIDTH(16),
        .COEFF_WIDTH(16)
    ) u_fir (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .din   (din),
        .dout  (dout)
    );

endmodule