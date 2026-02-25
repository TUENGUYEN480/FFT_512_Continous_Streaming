module fp_complex_mult_top (
    input  logic [31:0] ar, ai, br, bi,
    output logic [31:0] pr, pi,
    output logic        complex_overflow,
    output logic        complex_underflow,
    output logic        complex_invalid
);

    logic [31:0] m_rr, m_ii, m_ri, m_ir;
    logic [3:0]  ov_m, un_m, inv_m;
    logic [1:0]  ov_a, un_a, inv_a;

    // 4 Bộ nhân thực
    FP_multiplier_top M0 (.A(ar), .B(br), .Result_Out(m_rr), .Overflow(ov_m[0]), .Underflow(un_m[0]), .Invalid(inv_m[0]));
    FP_multiplier_top M1 (.A(ai), .B(bi), .Result_Out(m_ii), .Overflow(ov_m[1]), .Underflow(un_m[1]), .Invalid(inv_m[1]));
    FP_multiplier_top M2 (.A(ar), .B(bi), .Result_Out(m_ri), .Overflow(ov_m[2]), .Underflow(un_m[2]), .Invalid(inv_m[2]));
    FP_multiplier_top M3 (.A(ai), .B(br), .Result_Out(m_ir), .Overflow(ov_m[3]), .Underflow(un_m[3]), .Invalid(inv_m[3]));

    // pr = m_rr - m_ii
    FP_ADDER_TOP ADD_REAL (
        .i_32_a(m_rr), .i_32_b(m_ii), .i_add_sub(1'b1), // Dùng trực tiếp phép trừ
        .o_32_s(pr), .o_ov_flag(ov_a[0]), .o_un_flag(un_a[0]), .o_invalid(inv_a[0])
    );

    // pi = m_ri + m_ir
    FP_ADDER_TOP ADD_IMAG (
        .i_32_a(m_ri), .i_32_b(m_ir), .i_add_sub(1'b0), // Dùng phép cộng
        .o_32_s(pi), .o_ov_flag(ov_a[1]), .o_un_flag(un_a[1]), .o_invalid(inv_a[1])
    );

    assign complex_overflow  = (|ov_m)  | (|ov_a);
    assign complex_underflow = (|un_m)  | (|un_a);
    assign complex_invalid   = (|inv_m) | (|inv_a);
endmodule
