module Adder_and_rounding (
    input  logic [24:0] m_S_AB_MSB,      // Lấy từ bit [47:23] của tích
    input  logic [24:0] m_C_AB_MSB,      // Lấy từ bit [47:23] của tích
    input  logic         carry_out_lsb,  // Carry từ phần LSB (bit [22:0])
    input  logic         G0, R0, S0,     // GRS cho No-Overflow
    input  logic         G1, R1, S1,     // GRS for Overflow
    output logic [25:0] product_result, // Nới rộng thêm 1 bit để an toàn
    output logic         is_overflow
);

    logic [25:0] sum_raw, sum_p1, sum_p2;
    logic        round_up_case0, round_up_case1;
    logic        final_round_up;

    // ================================================================
    // MSB COMPOUND ADDER (Bây giờ là 25-bit)
    // ================================================================
    FPPA2_adder #( .WIDTH(25) ) u_fppa2_msb (
        .A(m_S_AB_MSB), 
        .B(m_C_AB_MSB), 
        .C_in(1'b0),
        .Sum(sum_raw), 
        .Sum_p1(sum_p1),
        .Sum_p2(sum_p2),
        .C_out() // Carry out bit 26 luôn là 0
    );
    
    // Kiểm tra bit 47 (tương ứng bit 24 của bộ cộng 25-bit)
    assign is_overflow = sum_raw[24]; 

    // ================================================================
    // ROUNDING DECISION
    // ================================================================
    // Case 0: LSB là bit [0] của bộ cộng (tức bit 23 của tích)
    assign round_up_case0 = G0 & (R0 | S0 | sum_raw[0]);
    
    // Case 1: LSB là bit [1] của bộ cộng (tức bit 24 của tích)
    assign round_up_case1 = G1 & (R1 | S1 | sum_raw[1]);
    
    assign final_round_up = is_overflow ? round_up_case1 : round_up_case0;

    // ================================================================
    // RESULT SELECTION
    // ================================================================
    always_comb begin
        case ({final_round_up, carry_out_lsb})
            2'b00: product_result = {1'b0, sum_raw};
            2'b01: product_result = {1'b0, sum_p1};
            2'b10: product_result = {1'b0, sum_p1};
            2'b11: product_result = {1'b0, sum_p2};
            default: product_result = 26'b0;
        endcase
    end

endmodule