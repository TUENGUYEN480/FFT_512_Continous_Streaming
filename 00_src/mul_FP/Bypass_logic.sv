

module Bypass_logic (
    input  logic        bypass_path_s1, 
    // Không cần tín hiệu 'sub' như bộ cộng
    input  logic        is_zero_A_s1,
    input  logic        is_zero_B_s1,
    input  logic        is_nan_A_s1,
    input  logic        is_nan_B_s1,
    input  logic        is_inf_A_s1,
    input  logic        is_inf_B_s1,
    input  logic        is_snan_A_s1,   
    input  logic        is_snan_B_s1,   
    input  logic        sign_A_s1,      
    input  logic        sign_B_s1,      
    input  logic [7:0]  exp_A_field_s1, 
    input  logic [7:0]  exp_B_field_s1, 
    input  logic [22:0] frac_A_s1,      
    input  logic [22:0] frac_B_s1,      

    output logic        special_case_detected_comb,
    output logic [31:0] special_case_result_comb, 
    output logic        overflow_flag_comb,        
    output logic        underflow_flag_comb,              
    output logic        invalid_flag_comb            
);

    logic [31:0] A_rec;
    logic [31:0] B_rec;
    logic        sign_res; // Dấu của kết quả tích (A^B)

    assign A_rec = { sign_A_s1, exp_A_field_s1, frac_A_s1 };
    assign B_rec = { sign_B_s1, exp_B_field_s1, frac_B_s1 };

    // Trong phép nhân, dấu luôn là XOR của hai dấu đầu vào (kể cả với 0 hay vô cùng)
    assign sign_res = sign_A_s1 ^ sign_B_s1;

    always_comb begin
        // Mặc định
        special_case_detected_comb = 1'b0;
        special_case_result_comb   = 32'b0;
        overflow_flag_comb         = 1'b0;
        underflow_flag_comb        = 1'b0;
        invalid_flag_comb          = 1'b0;

        if (bypass_path_s1 && (
            is_nan_A_s1 || is_nan_B_s1 || 
            is_inf_A_s1 || is_inf_B_s1 || 
            is_zero_A_s1 || is_zero_B_s1)) begin

            special_case_detected_comb = 1'b1;

            // ===== Ưu tiên 1: NaN (QNaN hoặc SNaN) =====
            if (is_nan_A_s1 || is_nan_B_s1) begin
                // Nếu là SNaN thì bật cờ Invalid
                if (is_snan_A_s1 || is_snan_B_s1) invalid_flag_comb = 1'b1;
                // Trả về NaN (thường là A nếu cả hai đều là NaN)
                special_case_result_comb = (is_nan_A_s1) ? A_rec : B_rec;
            end

            // ===== Ưu tiên 2: Trường hợp Invalid (0 * Infinity) =====
            else if ((is_inf_A_s1 && is_zero_B_s1) || (is_inf_B_s1 && is_zero_A_s1)) begin
                invalid_flag_comb = 1'b1;
                // Kết quả của 0 * inf là NaN (theo chuẩn IEEE-754 là QNaN)
                special_case_result_comb = 32'h7FC00000; 
            end

            // ===== Ưu tiên 3: Infinity Cases (inf * finite hoặc inf * inf) =====
            else if (is_inf_A_s1 || is_inf_B_s1) begin
                // Kết quả là Infinity với dấu đã tính toán
                special_case_result_comb = {sign_res, 8'hFF, 23'h0};
            end

            // ===== Ưu tiên 4: Zero Cases (0 * finite hoặc 0 * 0) =====
            else if (is_zero_A_s1 || is_zero_B_s1) begin
                // Kết quả là Zero với dấu đã tính toán
                special_case_result_comb = {sign_res, 31'h0};
            end
        end
    end

endmodule