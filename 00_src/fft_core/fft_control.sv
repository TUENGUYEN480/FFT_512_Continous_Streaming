module fft_control (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       bf_done,
    
    output logic [8:0] rom_addr,
    output logic [8:0] ram_addr,
    output logic       ram_we,
    output logic       ping_pong,
    output logic       bf_start,
    output logic [1:0] mux_sel,
    output logic       finish
);
    typedef enum logic [3:0] {
        IDLE, READ_A, WAIT_A, READ_B, WAIT_B,
        LOAD_W, CALC, WRITE_A, WRITE_B, NEXT_PAIR, DONE_STATE
    } state_t;

    state_t state, next_state;
    
    logic [3:0] stage; 
    logic [8:0] pair;  // Sử dụng 9-bit để chứa giá trị 256 an toàn
    
    logic [8:0] distance, addr_a, addr_b, twiddle_idx;
    logic [8:0] group_idx, in_group;

    // Address Calculation Logic
    always_comb begin
        distance    = 9'd256 >> stage; 
        group_idx   = pair >> (8 - stage);
        in_group    = pair & ((9'd1 << (8 - stage)) - 1);
        addr_a      = (group_idx << (9 - stage)) | in_group;
        addr_b      = addr_a + distance;
        twiddle_idx = (pair & (distance - 1)) << stage;
    end
    
    assign ram_addr = (state == READ_B || state == WAIT_B || state == WRITE_B) ? addr_b : addr_a;
    assign rom_addr = twiddle_idx;

    // FSM Sequential Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            stage     <= 4'd0;
            pair      <= 9'd0;
            ping_pong <= 1'b0;
            finish    <= 1'b0;
        end else begin
            state <= next_state;
            if (state == NEXT_PAIR) begin
                if (pair == 9'd255) begin
                    if (stage == 4'd8) begin
                        finish <= 1'b1;
                    end else begin
                        stage <= stage + 4'd1;
                        pair  <= 9'd0;
                        ping_pong <= ~ping_pong;
                    end
                end else begin
                    pair <= pair + 9'd1;
                end
            end else if (state == IDLE) begin
                stage  <= 4'd0;
                pair   <= 9'd0;
                finish <= 1'b0;
            end
        end
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:      if (start) next_state = READ_A;
            READ_A:    next_state = WAIT_A;
            WAIT_A:    next_state = READ_B;
            READ_B:    next_state = WAIT_B;
            WAIT_B:    next_state = LOAD_W;
            LOAD_W:    next_state = CALC;
            CALC:      if (bf_done) next_state = WRITE_A;
            WRITE_A:   next_state = WRITE_B;
            WRITE_B:   next_state = NEXT_PAIR;
            NEXT_PAIR: if (finish) next_state = DONE_STATE;
                       else next_state = READ_A;
            DONE_STATE: next_state = DONE_STATE;
            default:   next_state = IDLE;
        endcase
    end

    // Output Logic
    always_comb begin
        ram_we   = 1'b0;
        mux_sel  = 2'b00;
        bf_start = 1'b0;
        case (state)
            WAIT_A:  mux_sel = 2'b00;
            READ_B:  mux_sel = 2'b01;
            WAIT_B:  mux_sel = 2'b01;
            LOAD_W:  bf_start = 1'b1;
            WRITE_A: begin ram_we = 1'b1; mux_sel = 2'b10; end
            WRITE_B: begin ram_we = 1'b1; mux_sel = 2'b11; end
            default: ;
        endcase
    end
endmodule