module fft_top (
    input  logic clk, rst_n, start,
    input  logic load_en,
    input  logic [8:0]  ext_addr,
    input  logic [63:0] ext_data_in,
    output logic [63:0] ext_data_out,
    output logic [63:0] ext_ram0_out,
    output logic [63:0] ext_ram1_out,
    output logic done
);

    // --- Khai báo tín hiệu điều khiển nội bộ ---
    logic [8:0] c_ram_addr;
    logic [8:0] c_rom_addr;
    logic       c_ram_we, c_ping_pong, c_bf_start, c_bf_done;
    logic [1:0] c_mux_sel;

    // --- Khai báo các bus dữ liệu logic ---
    logic [63:0] ram0_out, ram1_out, rom_out;
    logic [63:0] bf_in_a, bf_in_b;
    logic [31:0] bf_ar, bf_ai, bf_br, bf_bi;

    // --- Logic chọn nguồn dữ liệu (Mux) ---
    wire [63:0] src_ram_out = (c_ping_pong == 1'b0) ? ram0_out : ram1_out;
    wire [63:0] wA = {bf_ar, bf_ai};
    wire [63:0] wB = {bf_br, bf_bi};
    
    logic [63:0] data_internal;
    always_comb begin
        case (c_mux_sel)
            2'd2:    data_internal = wA;
            2'd3:    data_internal = wB;
            default: data_internal = 64'h0;
        endcase
    end

    // --- Logic địa chỉ ---
    wire [8:0] addr_sel = (load_en && !done) ? ext_addr : (done ? ext_addr : c_ram_addr);

    // --- Khối RAM0 ---
    wire r0_we = (load_en && !done) ? 1'b1 : (c_ram_we & (c_ping_pong == 1'b1));
    ram_sp #(.DATA_WIDTH(64), .ADDR_WIDTH(9), .DEPTH(512)) RAM0 (
        .clk(clk), .we(r0_we), .addr(addr_sel), 
        .d_in((load_en && !done) ? ext_data_in : data_internal), 
        .d_out(ram0_out)
    );

    // --- Khối RAM1 ---
    wire r1_we = (c_ram_we & (c_ping_pong == 1'b0));
    ram_sp #(.DATA_WIDTH(64), .ADDR_WIDTH(9), .DEPTH(512)) RAM1 (
        .clk(clk), .we(r1_we), .addr(addr_sel), 
        .d_in(data_internal), 
        .d_out(ram1_out)
    );

    // --- Twiddle Factor ROM ---
    rom_twiddle ROM_INST (.addr(c_rom_addr), .data(rom_out));

    // --- Control Unit ---
    fft_control CTRL (
        .clk(clk), .rst_n(rst_n), .start(start), .bf_done(c_bf_done),
        .rom_addr(c_rom_addr), .ram_addr(c_ram_addr),
        .ram_we(c_ram_we), .ping_pong(c_ping_pong),
        .bf_start(c_bf_start), .mux_sel(c_mux_sel), .finish(done)
    );

    // --- Ghi dữ liệu vào thanh ghi PE ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bf_in_a <= 64'h0;
            bf_in_b <= 64'h0;
        end else begin
            if (c_mux_sel == 2'd0) bf_in_a <= src_ram_out;
            if (c_mux_sel == 2'd1) bf_in_b <= src_ram_out;
        end
    end

    // --- Butterfly PE Unit ---
    butterfly_pe PE (
        .clk(clk), .rst_n(rst_n), .start(c_bf_start),
        .ar(bf_in_a[63:32]), .ai(bf_in_a[31:0]),
        .br(bf_in_b[63:32]), .bi(bf_in_b[31:0]),
        .wr(rom_out[63:32]), .wi(rom_out[31:0]),
        .ar_out(bf_ar), .ai_out(bf_ai),
        .br_out(bf_br), .bi_out(bf_bi),
        .done(c_bf_done)
    );

    // --- Kết nối đầu ra ---
    assign ext_data_out = (c_ping_pong == 1'b0) ? ram1_out : ram0_out;
    assign ext_ram0_out = ram0_out;
    assign ext_ram1_out = ram1_out;

endmodule