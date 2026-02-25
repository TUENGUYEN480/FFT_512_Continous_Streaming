/*
 * ram_sp.sv
 * Simple Single-Port Synchronous RAM
 * FIXED VERSION - Explicit read-during-write behavior
 */

module ram_sp #(
    parameter int DATA_WIDTH = 64,
    parameter int ADDR_WIDTH = 3,
    parameter int DEPTH = 8
) (
    input  logic                     clk,
    input  logic                     we,
    input  logic [ADDR_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    d_in,
    output logic [DATA_WIDTH-1:0]    d_out
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Synchronous read/write
    // Read-during-write: OLD data forwarded (not new data)
    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= d_in;
        end
        d_out <= mem[addr];  // Reads happen before write takes effect
    end

endmodule