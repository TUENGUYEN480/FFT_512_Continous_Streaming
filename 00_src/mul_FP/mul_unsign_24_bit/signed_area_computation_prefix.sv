// ============================================================
// Module: signed_area_computation_prefix (FIXED SYNTAX)
// Function: Generate sign-correction vector M
// ============================================================

module signed_area_computation_prefix #(
    parameter int N       = 24,
    parameter int NUM_PP  = 13,
    parameter int WIDTH   = 52 
)(
    input  logic [N:0]       PP [0:NUM_PP-1],
    output logic [WIDTH-1:0] Vector_M
);

    // 1. Extract sign bits
    logic sign_bits [0:NUM_PP-1];
    always_comb begin
        for (int i = 0; i < NUM_PP; i++) begin
            sign_bits[i] = PP[i][N];
        end
    end

    // 2. Prefix OR
    logic prefix_or [0:NUM_PP];
    assign prefix_or[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < NUM_PP; i++) begin : GEN_PREFIX
            assign prefix_or[i+1] = prefix_or[i] | sign_bits[i];
        end
    endgenerate

    // 3. Generate Vector_M
    always_comb begin
        Vector_M = '0; // Mặc định 0

        for (int col = N; col < WIDTH; col++) begin
            // [SỬA LỖI] Khai báo biến trước, gán giá trị sau
            // Để tránh lỗi automatic variable illegal in static initializer
            int rel_pos;
            int pp_idx;
            logic is_gap;

            rel_pos = col - N;
            pp_idx  = rel_pos / 2;      
            is_gap  = (rel_pos % 2 == 1); 

            if (pp_idx < NUM_PP) begin
                if (is_gap) begin
                    // Tại Gap
                    Vector_M[col] = prefix_or[pp_idx + 1];
                end else begin
                    // Tại Mark
                    Vector_M[col] = prefix_or[pp_idx] ^ sign_bits[pp_idx];
                end
            end else begin
                // Vùng vượt quá PP cuối cùng
                Vector_M[col] = prefix_or[NUM_PP];
            end
        end
    end

endmodule