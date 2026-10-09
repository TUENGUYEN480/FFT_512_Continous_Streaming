`timescale 1ns/1ns

module tb_fft_512pt_verify;

    // --- Configuration ---
    parameter int N = 512;
    parameter int LOG2_N = 9;
    parameter time TCLK = 10ns;
    parameter shortreal TOLERANCE = 0.05; // Tăng nhẹ tolerance do tích lũy sai số 9 tầng butterfly

    // --- Signals ---
    logic        clk, rst_n, start, load_en, done;
    logic [8:0]  ext_addr;
    logic [63:0] ext_data_in, ext_data_out;

    // --- DUT Instantiation ---
    fft_top DUT (.*);

    // --- Storage ---
    shortreal x_in_re[N], x_in_im[N];
    shortreal exp_re[N], exp_im[N];
    shortreal act_re[N], act_im[N];

    // --- Clock ---
    initial begin
        clk = 0;
        forever #(TCLK/2) clk = ~clk;
    end

    // --- Helpers ---
    function automatic [31:0] f2b(shortreal f);
        return $shortrealtobits(f);
    endfunction

    function automatic shortreal b2f(logic [31:0] b);
        return $bitstoshortreal(b);
    endfunction

    function automatic int bit_reverse(int in_val, int width);
        int out_val = 0;
        for (int i = 0; i < width; i++) begin
            out_val = (out_val << 1) | (in_val & 1);
            in_val = in_val >> 1;
        end
        return out_val;
    endfunction

    // --- Golden DFT Calculation ---
    task automatic calculate_expect();
        shortreal a, c, s;
        for (int k = 0; k < N; k++) begin
            exp_re[k] = 0; exp_im[k] = 0;
            for (int n = 0; n < N; n++) begin
                a = -2.0 * 3.1415926535 * k * n / N;
                c = $cos(a); s = $sin(a);
                exp_re[k] += x_in_re[n]*c - x_in_im[n]*s;
                exp_im[k] += x_in_re[n]*s + x_in_im[n]*c;
            end
        end
    endtask

    // --- Main Control ---
    initial begin
        static int err_cnt = 0;
        int f_in, f_out;
        shortreal d_re, d_im, a_err;
        static shortreal max_err = 0;

        $display("\n============================================================================================");
        $display("   FFT 512-POINT HARDWARE VERIFICATION SYSTEM");
        $display("============================================================================================");

        f_in  = $fopen("input.hex", "w");
        f_out = $fopen("rtl_out.hex", "w");

        reset_dut();

        // 1. Load Data
        $display(" -> Loading 512 samples into RAM0...");
        load_en = 1;
        for (int i = 0; i < N; i++) begin
            x_in_re[i] = (int'($urandom_range(2000, 0)) - 1000) / 100.0;
            x_in_im[i] = (int'($urandom_range(2000, 0)) - 1000) / 100.0;
            ext_addr = i[8:0];
            ext_data_in = {f2b(x_in_re[i]), f2b(x_in_im[i])};
            $fdisplay(f_in, "%h", ext_data_in);
            @(posedge clk);
        end
        load_en = 0;
        $fclose(f_in);

        // 2. Run
        calculate_expect();
        start = 1; @(posedge clk); start = 0;
        $display(" -> Processing FFT (9 stages, 2304 butterfly ops)...");

        // Timeout watchdog
        fork
            begin
                while (!done) @(posedge clk);
            end
            begin
                repeat (100000) @(posedge clk);
                if (!done) begin
                    $display("\n [ERROR] Simulation Timeout! FFT core is not responding.");
                    $finish;
                end
            end
        join_any

        // 3. Compare Results
        $display("\n %-5s | %-24s | %-24s | %-10s", "Bin", "Expected (Re, Im)", "Actual (Re, Im)", "Abs Err");
        $display("-------|--------------------------|--------------------------|------------");

        for (int k = 0; k < N; k++) begin
            // Đọc dữ liệu ra theo thứ tự bit-reversed
            ext_addr = bit_reverse(k, LOG2_N);
            @(posedge clk);
            repeat(2) @(posedge clk); // Chờ RAM latency

            act_re[k] = b2f(ext_data_out[63:32]);
            act_im[k] = b2f(ext_data_out[31:0]);
            $fdisplay(f_out, "%h", ext_data_out);

            d_re  = exp_re[k] - act_re[k];
            d_im  = exp_im[k] - act_im[k];
            a_err = $sqrt(d_re*d_re + d_im*d_im);

            if (a_err > max_err) max_err = a_err;
            if (a_err > TOLERANCE) err_cnt++;

            // Chỉ in các mẫu đầu, cuối và mẫu lỗi để tránh tràn màn hình
            if ((k < 5 || k > N-6 || a_err > TOLERANCE)) begin
                $display(" %5d | (%10.4f, %10.4f) | (%10.4f, %10.4f) | %10.6f %s",
                         k, exp_re[k], exp_im[k], act_re[k], act_im[k], a_err,
                         (a_err > TOLERANCE) ? "[FAIL]" : "");
            end else if (k == 5) begin
                $display("  ...  |           ...            |           ...            |     ...");
            end
        end
        $fclose(f_out);

        // 4. Final Summary
        $display("--------------------------------------------------------------------------------------------");
        $display(" [SUMMARY]");
        $display("  - Max Absolute Error : %8.6e", max_err);
        $display("  - Error Count        : %0d / %0d", err_cnt, N);
        $display("  - Status             : %s", (err_cnt == 0) ? "PASS ✅" : "FAIL ❌");
        $display("============================================================================================\n");
        $finish;
    end

    task automatic reset_dut();
        rst_n = 0;
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);
    endtask

endmodule
