module butterfly_pe (
    input  logic clk, rst_n, start,
    input  logic [31:0] ar, ai, br, bi, wr, wi,
    output logic [31:0] ar_out, ai_out, br_out, bi_out,
    output logic done
);

    logic [31:0] sum_r, sum_i, diff_r, diff_i, prod_r, prod_i;

    // flags để nối đủ port (khỏi warning)
    logic ov_add_r, un_add_r, inv_add_r;
    logic ov_add_i, un_add_i, inv_add_i;
    logic ov_sub_r, un_sub_r, inv_sub_r;
    logic ov_sub_i, un_sub_i, inv_sub_i;
    logic ov_mul,   un_mul,   inv_mul;

    logic start_d;

    FP_ADDER_TOP U_ADD_R (
        .i_32_a(ar), .i_32_b(br), .i_add_sub(1'b0),
        .o_32_s(sum_r), .o_ov_flag(ov_add_r), .o_un_flag(un_add_r), .o_invalid(inv_add_r)
    );
    FP_ADDER_TOP U_ADD_I (
        .i_32_a(ai), .i_32_b(bi), .i_add_sub(1'b0),
        .o_32_s(sum_i), .o_ov_flag(ov_add_i), .o_un_flag(un_add_i), .o_invalid(inv_add_i)
    );

    FP_ADDER_TOP U_SUB_R (
        .i_32_a(ar), .i_32_b(br), .i_add_sub(1'b1),
        .o_32_s(diff_r), .o_ov_flag(ov_sub_r), .o_un_flag(un_sub_r), .o_invalid(inv_sub_r)
    );
    FP_ADDER_TOP U_SUB_I (
        .i_32_a(ai), .i_32_b(bi), .i_add_sub(1'b1),
        .o_32_s(diff_i), .o_ov_flag(ov_sub_i), .o_un_flag(un_sub_i), .o_invalid(inv_sub_i)
    );

    fp_complex_mult_top U_MULT (
        .ar(diff_r), .ai(diff_i),
        .br(wr),     .bi(wi),
        .pr(prod_r), .pi(prod_i),
        .complex_overflow(ov_mul),
        .complex_underflow(un_mul),
        .complex_invalid(inv_mul)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ar_out  <= 32'd0;
            ai_out  <= 32'd0;
            br_out  <= 32'd0;
            bi_out  <= 32'd0;
            start_d <= 1'b0;
            done    <= 1'b0;
        end else begin
            start_d <= start;     // trễ 1 chu kỳ
            done    <= start_d;   // bf_done lên đúng pha CALC

            if (start) begin
                ar_out <= sum_r;
                ai_out <= sum_i;
                br_out <= prod_r;
                bi_out <= prod_i;
            end
        end
    end

endmodule
