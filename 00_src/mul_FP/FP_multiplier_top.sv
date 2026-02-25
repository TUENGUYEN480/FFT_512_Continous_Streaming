module FP_multiplier_top (
    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] Result_Out,
    output logic        Overflow,
    output logic        Underflow,
    output logic        Invalid
);

    //-----------------------------------------------------
    //  INTERNAL SIGNALS & FLAGS
    //-----------------------------------------------------
    logic [8:0]  exp_A_s1, exp_B_s1;
    logic [23:0] Ma_s1, Mb_s1;
    logic        is_zero_A_s1, is_zero_B_s1;
    logic        is_nan_A_s1, is_nan_B_s1;
    logic        is_snan_A_s1, is_snan_B_s1;
    logic        is_inf_A_s1, is_inf_B_s1;
    logic        sign_product_AB;
    logic        bypass_s1;
    
    logic        Overflow_in, Underflow_in, Invalid_in;

    logic [47:0] m_S_AB, m_C_AB;
    logic [24:0] m_S_AB_MSB, m_C_AB_MSB; // 25-bit MSB (bits 47:23)
    logic [22:0] m_S_AB_LSB, m_C_AB_LSB; // 23-bit LSB (bits 22:0)

    logic [9:0]  exp_sum_AB;
    logic [9:0]  exp_sum_AB_add1;
    
    logic        carry_out_msb;
    logic [22:0] lsb_sum;
    logic        carry_out_lsb;
    
    logic        G0, R0, S0; 
    logic        G1, R1, S1;
    logic [25:0] product_result;

    // ================================================================
    // STAGE 0: DECODE & SPECIAL CASES
    // ================================================================
    FP_mul_2_decode_control u_decode (
        .A(A), .B(B),
        .exp_A_s1(exp_A_s1), .exp_B_s1(exp_B_s1),
        .Ma_s1(Ma_s1), .Mb_s1(Mb_s1),
        .sign_product_AB(sign_product_AB),
        .is_zero_A_s1(is_zero_A_s1), .is_zero_B_s1(is_zero_B_s1),
        .is_nan_A_s1(is_nan_A_s1), .is_nan_B_s1(is_nan_B_s1),
        .is_snan_A_s1(is_snan_A_s1), .is_snan_B_s1(is_snan_B_s1),
        .is_inf_A_s1(is_inf_A_s1), .is_inf_B_s1(is_inf_B_s1),
        .bypass_s1(bypass_s1)
    );

    // ================================================================
    // STAGE 1: EXPONENT & MANTISSA MULTIPLIER
    // ================================================================
    Exp_process #( .WIDTH(9), .BIAS(127) ) u_exp_proc (
        .exp_A(exp_A_s1),
        .exp_B(exp_B_s1),
        .exp_sum_AB(exp_sum_AB)
    );

    Multiplier u_mult_AB (
        .A(Ma_s1), .B(Mb_s1),
        .Product_A(m_S_AB),
        .Product_B(m_C_AB)
    );

    // Tách 48 bit thành 25 MSB [47:23] và 23 LSB [22:0]
    assign m_S_AB_MSB = m_S_AB[47:23];
    assign m_C_AB_MSB = m_C_AB[47:23];
    assign m_S_AB_LSB = m_S_AB[22:0];    // 23-bit LSB (bits 22:0)
    assign m_C_AB_LSB = m_C_AB[22:0];

    // ================================================================
    // STAGE 2: LSB ADDER & STICKY LOGIC
    // ================================================================
    CLA_adder_top #( .WIDTH(23) ) u_adder_lsb (
        .A(m_S_AB_LSB), .B(m_C_AB_LSB), .C_in(1'b0),
        .Sum(lsb_sum), .C_out(carry_out_lsb)
    );

        // G, R, S cho cả 2 trường hợp rounding
    // --- Case 0: No Overflow ([1.0, 2.0)) ---
        assign G0 = lsb_sum[22];            // Bit 22 của tích
        assign R0 = lsb_sum[21];            // Bit 21 của tích
        assign S0 = |lsb_sum[20:0];         // OR từ bit 20 xuống 0

        // --- Case 1: Overflow ([2.0, 4.0)) ---
        // G1 là bit 23 của tích. Bit này chính là bit [0] của kết quả bộ cộng MSB 25-bit
        assign G1 = m_S_AB_MSB[0] ^ m_C_AB_MSB[0] ^ carry_out_lsb;      // Bit 23 của tích (sau khi đã cộng carry_out_lsb)
        assign R1 = lsb_sum[22];            // Bit 22 của tích
        assign S1 = lsb_sum[21] | S0;       // OR từ bit 21 xuống 0
    // ================================================================
    // STAGE 3: MSB ADDER & ROUNDING LOGIC
    // ================================================================
    Adder_and_rounding u_adder_rounding (
        .m_S_AB_MSB(m_S_AB_MSB),
        .m_C_AB_MSB(m_C_AB_MSB),
        .carry_out_lsb(carry_out_lsb),
        .G0(G0), .R0(R0), .S0(S0),
        .G1(G1), .R1(R1), .S1(S1),
        .product_result(product_result),
        .is_overflow(carry_out_msb)  // Bit 47 của kết quả (normalize flag)
    );

    // ================================================================
    // STAGE 4: EXPONENT INCREMENT & EXCEPTION FLAGS
    // ================================================================
    Incrementer #( .N(10) ) u_incremeter (
        .A(exp_sum_AB), 
        .S(exp_sum_AB_add1),
        .C_out() // Không sử dụng
    );

    // Tính các cờ exception
    assign Overflow_in  = (exp_sum_AB >= 10'd255) || (exp_sum_AB == 10'd254 && carry_out_msb);
    assign Underflow_in = (exp_sum_AB[9] == 1'b1); // Số âm (signed overflow)
    assign Invalid_in   = (is_zero_A_s1 && is_inf_B_s1) || (is_inf_A_s1 && is_zero_B_s1) || 
                          is_nan_A_s1 || is_nan_B_s1;

    // ================================================================
    // STAGE 5: RESULT INTEGRATION & OUTPUT
    // ================================================================
    Result_Integration_Mul u_result_integration (
        .carry_out_msb(carry_out_msb),
        .bypass_s1(bypass_s1),
        .Overflow(Overflow_in),
        .Underflow(Underflow_in),
        .Invalid(Invalid_in),
        .res_is_nan_s1(is_nan_A_s1 || is_nan_B_s1),
        .res_is_inf_s1(is_inf_A_s1 || is_inf_B_s1),
        .res_is_zero_s1(is_zero_A_s1 || is_zero_B_s1),
        .exp_sum_AB(exp_sum_AB),
        .exp_sum_AB_add1(exp_sum_AB_add1),
        .product_result(product_result),
        .sign_product_AB(sign_product_AB),
        .Result_Out(Result_Out),
        .final_exponent(),
        .final_mant()
    );

    // Drive top-level exception outputs
    assign Overflow  = Overflow_in;
    assign Underflow = Underflow_in;
    assign Invalid   = Invalid_in;

endmodule