module Result_Integration_Mul (
    // Control signals
    input  logic        carry_out_msb,
    input  logic        bypass_s1,
    input  logic        Overflow,
    input  logic        Underflow,
    input  logic        Invalid,
    
    // Special case flags
    input  logic        res_is_nan_s1,
    input  logic        res_is_inf_s1,
    input  logic        res_is_zero_s1,
    
    // Data inputs
    input  logic [9:0]  exp_sum_AB,
    input  logic [9:0]  exp_sum_AB_add1,
    input  logic [25:0] product_result,
    input  logic        sign_product_AB,
    
    // Outputs
    output logic [31:0] Result_Out,
    output logic [8:0]  final_exponent,
    output logic [22:0] final_mant
);
// ================================================================
    // STAGE 4: NORMALIZATION LOGIC (SỬA ĐỔI)
    // ================================================================
    always_comb begin
        if(carry_out_msb) begin
            // Tích >= 2.0: Bit ẩn là product_result[24] (bit 47)
            // Fraction là các bit từ 46 xuống 24 -> product_result[23:1]
            final_exponent = exp_sum_AB_add1[8:0];
            final_mant     = product_result[23:1]; 
        end else begin
            // Tích < 2.0: Bit ẩn là product_result[23] (bit 46)
            // Fraction là các bit từ 45 xuống 23 -> product_result[22:0]
            // Lưu ý: product_result[22:0] ở đây tương ứng với tích[45:23]
            final_exponent = exp_sum_AB[8:0];
            final_mant     = product_result[22:0]; 
        end
    end

    // ================================================================
    // STAGE 5: RESULT INTEGRATION (IEEE-754 Compliant)
    // Select final output based on special cases and exceptions
    // ================================================================
    always_comb begin
        if (bypass_s1 || Overflow || Underflow) begin
            // Special cases handling (priority order)
            if (res_is_nan_s1 || Invalid) 
                Result_Out = {1'b0, 8'hFF, 23'h400000}; // Quiet NaN
            else if (res_is_zero_s1 || Underflow)
                Result_Out = {sign_product_AB, 8'h00, 23'h0}; // Zero (higher priority than inf)
            else if (res_is_inf_s1 || Overflow) 
                Result_Out = {sign_product_AB, 8'hFF, 23'h0}; // Infinity
            else 
                Result_Out = {sign_product_AB, 8'h00, 23'h0}; // Default zero
        end else begin
            // Normal result: Sign + Exponent + Mantissa
            Result_Out = {sign_product_AB, final_exponent[7:0], final_mant};
        end
    end

endmodule
