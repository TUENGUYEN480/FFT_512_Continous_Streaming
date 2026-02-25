/*
 * rom_twiddle.sv - 512-point Twiddle Factor ROM
 */
module rom_twiddle (
    input  logic [8:0]  addr,
    output logic [63:0] data
);
    // Khai báo mảng rõ ràng với kiểu logic
    logic [63:0] twiddle_mem [0:511];

    initial begin
        // Đảm bảo file này tồn tại trong cùng thư mục chạy lệnh xrun
        $readmemh("twiddle_512.hex", twiddle_mem);
    end
    
    // Đọc dữ liệu tổ hợp
    assign data = twiddle_mem[addr];

endmodule