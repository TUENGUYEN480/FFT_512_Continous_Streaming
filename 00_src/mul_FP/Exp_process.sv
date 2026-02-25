module Exp_process #(
    parameter WIDTH = 9,   // Width of individual exponent (9-bit)
    parameter BIAS = 127   // Bias for exponent
) (
    input  logic [WIDTH-1:0] exp_A,     // eA from decode module
    input  logic [WIDTH-1:0] exp_B,     // eB from decode module
    
    output logic [WIDTH:0]   exp_sum_AB     // eA + eB - bias (10-bit)
);

    logic carry_out_sum;
    logic [WIDTH-1:0] sum_9bit;
    logic [WIDTH:0] sum_raw;
    logic [WIDTH:0] bias_complement;
    
    // ================================================================
    // Step 1: Calculate eA + eB (9-bit + 9-bit = 10-bit)
    // ================================================================
    CLA_adder_top #(
        .WIDTH(WIDTH),
        .FANIN(4)
    ) u_exp_add_AB (
        .A(exp_A),
        .B(exp_B),
        .C_in(1'b0),
        .Sum(sum_9bit),
        .C_out(carry_out_sum)
    );
    
    // Combine Sum + Carry to form 10-bit result
    assign sum_raw = {carry_out_sum, sum_9bit};
    
    // ================================================================
    // Step 2: Subtract bias: exp_sum_AB = (eA + eB) - BIAS
    // = (eA + eB) + (~BIAS) + 1
    // ================================================================
    assign bias_complement = ~BIAS;
    
    CLA_adder_top #(
        .WIDTH(WIDTH + 1),  // 10-bit width
        .FANIN(4)
    ) u_exp_sub_bias (
        .A(sum_raw),
        .B(bias_complement),
        .C_in(1'b1),  // +1 for 2's complement
        .Sum(exp_sum_AB),
        .C_out()
    );

endmodule