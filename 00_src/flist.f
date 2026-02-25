// ================================================================
// 1. CÁC THÀNH PHẦN CƠ BẢN & PACKAGES
// ================================================================
../00_src/mul_FP/mul_unsign_24_bit/wallace_pkg.sv
../00_src/mul_FP/basic_cells/FA_1bit.sv
../00_src/mul_FP/basic_cells/HA_1bit.sv

// ================================================================
// 2. FP ADDER COMPONENTS (Adder_Fp)
// ================================================================
../00_src/Adder_Fp/Adder/CLA/CLA_24bit.sv
../00_src/Adder_Fp/Adder/CLA/CLA_4bit.sv
../00_src/Adder_Fp/Adder/CLA/CLA_8bit.sv
../00_src/Adder_Fp/Adder/CLA/CLA_9bit.sv
../00_src/Adder_Fp/Adder/CLA/CLA_logic.sv
../00_src/Adder_Fp/Adder/CLA/CLA_logic_tree_level.sv
../00_src/Adder_Fp/Adder/CLA/CLA_adder_top.sv
../00_src/Adder_Fp/Adder/FPPA2_adder.sv
../00_src/Adder_Fp/Adder/Incre_decr.sv
../00_src/Adder_Fp/Adder/Incrementer.sv
../00_src/Adder_Fp/LZC/LZC_16bit.sv
../00_src/Adder_Fp/LZC/LZC_32bit.sv
../00_src/Adder_Fp/Normalization/Normalization_Close.sv
../00_src/Adder_Fp/Normalization/Normalization_Large.sv
../00_src/Adder_Fp/Adder_round_logic.sv
../00_src/Adder_Fp/Bypass_Logic.sv
../00_src/Adder_Fp/Data_selector.sv
../00_src/Adder_Fp/Pre_aliment.sv
../00_src/Adder_Fp/PTFADD_decode_control.sv
../00_src/Adder_Fp/Result_Close.sv
../00_src/Adder_Fp/Result_Integration.sv
../00_src/Adder_Fp/Result_Large.sv
../00_src/Adder_Fp/Right_Shifter_1bit.sv
../00_src/Adder_Fp/PTPFADD_top.sv
../00_src/Adder_Fp/TOP/FP_ADDER_TOP.sv

// ================================================================
// 3. FP MULTIPLIER COMPONENTS (mul_FP)
// ================================================================
../00_src/mul_FP/mul_unsign_24_bit/Modified_booth.sv
../00_src/mul_FP/mul_unsign_24_bit/signed_area_computation.sv
../00_src/mul_FP/mul_unsign_24_bit/signed_area_computation_prefix.sv
../00_src/mul_FP/mul_unsign_24_bit/wallace_stage.sv
../00_src/mul_FP/mul_unsign_24_bit/wallace_tree.sv
../00_src/mul_FP/mul_unsign_24_bit/wallace_final_merge.sv
../00_src/mul_FP/mul_unsign_24_bit/Multiplier.sv
../00_src/mul_FP/Adder_and_rounding.sv
../00_src/mul_FP/Bypass_logic.sv
../00_src/mul_FP/Exp_process.sv
../00_src/mul_FP/FP_mul_2_decode_control.sv
../00_src/mul_FP/Result_Integration.sv
../00_src/mul_FP/FP_multiplier_top.sv

// ================================================================
// 4. COMPLEX MULTIPLIER & FFT CORE
// ================================================================
../00_src/fp_complex_mult_top.sv
../00_src/fft_core/ram_sp.sv
../00_src/fft_core/rom_twiddle.sv
../00_src/fft_core/butterfly_pe.sv
../00_src/fft_core/fft_control.sv
../00_src/fft_core/fft_top.sv