module FP_mul_2_decode_control (
    input  logic [31:0] A,
    input  logic [31:0] B,
    
//-----------------------------------------------------
//  STAGE 1 OUTPUTS: DECODE INFO
//-----------------------------------------------------
    // Exponents (9-bit: 1 bit for denormal handling + 8 bits)
    output logic [8:0] exp_A_s1, exp_B_s1,
    
    // Mantissas (24-bit: implicit leading 1 + 23 bits)
    output logic [23:0] Ma_s1, Mb_s1,
    
//-----------------------------------------------------
//  CLASSIFICATION FLAGS
//-----------------------------------------------------
    // Zero flags
    output logic is_zero_A_s1, is_zero_B_s1,
    
    // NaN flags (Quiet NaN)
    output logic is_nan_A_s1, is_nan_B_s1,
    
    // Signaling NaN flags
    output logic is_snan_A_s1, is_snan_B_s1,
    
    // Infinity flags
    output logic is_inf_A_s1, is_inf_B_s1,
    
//-----------------------------------------------------
//  CONTROL SIGNALS
//-----------------------------------------------------
    // Product sign bit
    output logic sign_product_AB,              // dấu của (A*B)
    
    // Bypass signals for special cases
    output logic bypass_s1                     // 1 = bypass denormal/special case logic
    

);

//-----------------------------------------------------
//  INTERMEDIATE SIGNALS - Helper wires
//-----------------------------------------------------

// --- Exponent classification for each input ---
wire exp_A_ones, exp_B_ones;
wire exp_A_zeros, exp_B_zeros;

// --- Mantissa non-zero checks ---
wire mant_A_nzero, mant_B_nzero;

// --- Sign bits for products ---
wire sign_A, sign_B;

assign exp_A_ones = &A[30:23];
assign exp_B_ones = &B[30:23];

assign exp_A_zeros = ~|A[30:23];
assign exp_B_zeros = ~|B[30:23];

assign mant_A_nzero = |A[22:0];
assign mant_B_nzero = |B[22:0];

//-----------------------------------------------------
//  CLASSIFICATION LOGIC - INPUT A
//-----------------------------------------------------
assign is_zero_A_s1 = ~|A[30:0];
assign is_nan_A_s1  = exp_A_ones & mant_A_nzero;
assign is_snan_A_s1 = exp_A_ones & ~A[22] & (|A[21:0]);
assign is_inf_A_s1  = exp_A_ones & ~mant_A_nzero;

//-----------------------------------------------------
//  CLASSIFICATION LOGIC - INPUT B
//-----------------------------------------------------
assign is_zero_B_s1 = ~|B[30:0];
assign is_nan_B_s1  = exp_B_ones & mant_B_nzero;
assign is_snan_B_s1 = exp_B_ones & ~B[22] & (|B[21:0]);
assign is_inf_B_s1  = exp_B_ones & ~mant_B_nzero;

//-----------------------------------------------------
//  EXTRACTION LOGIC - SIGNS
//-----------------------------------------------------
assign sign_A = A[31];
assign sign_B = B[31];

//-----------------------------------------------------
//  EXTRACTION LOGIC - EXPONENTS
//-----------------------------------------------------
assign exp_A_s1 = {1'b0, A[30:23]};
assign exp_B_s1 = {1'b0, B[30:23]};

//-----------------------------------------------------
//  EXTRACTION LOGIC - MANTISSAS (with implicit leading bit)
// For normal numbers (exp != 0): leading bit = 1
// For denormal numbers (exp == 0): leading bit = 0
//-----------------------------------------------------
assign Ma_s1 = {~exp_A_zeros, A[22:0]};
assign Mb_s1 = {~exp_B_zeros, B[22:0]};

//-----------------------------------------------------
//  PRODUCT SIGN CALCULATION
//-----------------------------------------------------
assign sign_product_AB = sign_A ^ sign_B;

//-----------------------------------------------------
//  BYPASS SIGNAL FOR SPECIAL CASES
//-----------------------------------------------------
// Trigger bypass if any input is NaN, Infinity, or Zero
assign bypass_s1 = (is_nan_A_s1 | is_nan_B_s1) |
                   (is_snan_A_s1 | is_snan_B_s1) |
                   (is_inf_A_s1 | is_inf_B_s1) |
                   (is_zero_A_s1 | is_zero_B_s1);



endmodule