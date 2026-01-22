`timescale 1ns / 10ps

module subordinate #(
    // parameters
) (
    input logic clk, n_rst,
    input logic [63:0] output_data,
    input logic occupancy_err_i, occupancy_err_o, occupancy_err_w, device_busy_err, data_ready, design_busy, 
    input logic hsel, 
    input logic [7:0] haddr,
    input logic [1:0] htrans,
    input logic [2:0] hsize,
    input logic hwrite,
    input logic [63:0] hwdata,
    input logic [2:0] hburst,
    output logic [63:0] weight_data, input_data, bias,
    output logic start_inference, load_weight,
    output logic [2:0] activation_mode,
    output logic write_weight, write_input,
    output logic hresp, hready,
    output logic [63:0] hrdata,
    output logic output_read
);
    logic last_hsel,last_hwrite;
    logic [7:0] last_haddr, next_write_sel, write_sel;
    logic [2:0] last_hsize;
    logic [63:0] next_hrdata, real_next_hrdata, reg0, next_reg0, reg8, next_reg8, reg10, next_reg10;
    logic [63:0] out18;
    logic [15:0] out20;
    logic [7:0] out23;
    logic [7:0] reg22, next_reg22, reg24, next_reg24; 
    logic real_hsel, real_hwrite, hreadyy;
    logic [7:0] real_haddr;
    logic [2:0] real_hsize;
    logic last_design_busy, err_signal, hrespp, hresp_p;
    logic [1:0] last_htrans, real_htrans;

    assign out18 = output_data;
    assign start_inference = reg22[0];
    assign load_weight = reg22[1];
    assign weight_data = reg0;
    assign input_data = reg8;
    assign bias = reg10;

    always_comb begin
        if(reg24 == 8'd0) activation_mode = 3'd0;
        else if(reg24 == 8'd1) activation_mode = 3'd1;
        else if(reg24 == 8'd2) activation_mode = 3'd2;
        else if(reg24 == 8'd3) activation_mode = 3'd3;
        else activation_mode = 3'd7;
    end
    always_comb begin
        out20 = '0;
        if(last_haddr>=8'h00 && last_haddr<=8'h07 && haddr==8'h20) begin
            out20[0] = occupancy_err_w;    
            out20[8] = device_busy_err;
        end
        else if(last_haddr>=8'h08 && last_haddr<=8'h0F && haddr==8'h20) begin
            out20[0] = occupancy_err_i;    
            out20[8] = device_busy_err;
        end
        else if(last_haddr>=8'h18 && last_haddr<=8'h1F && haddr==8'h20) begin
            out20[0] = occupancy_err_o;    
            out20[8] = device_busy_err;
        end
    end
    always_comb begin
        out23[7:2] = '0;
        out23[0] = data_ready;
        out23[1] = design_busy;
    end
    always_comb begin
        if(hready) begin
            real_hsel = hsel;
            real_haddr = haddr;
            real_hwrite = hwrite;
            real_hsize = hsize;
            real_htrans = htrans;
        end
        else begin
            real_hsel = last_hsel;
            real_haddr = last_haddr;
            real_hwrite = last_hwrite;
            real_hsize = last_hsize;
            real_htrans = last_htrans;
        end
    end
    always_ff @( posedge clk, negedge n_rst ) begin
        if(!n_rst) begin
            last_design_busy <= 0;
            last_htrans <= 0;
        end
        else begin
            last_design_busy <= design_busy;
            last_htrans <= htrans;
        end
    end
    typedef enum logic {
        IDLE,
        ERR_CLEAR
    } state;
    state curr_state, next_state;
    always_comb begin
        next_state = curr_state;
        case (curr_state)
            IDLE: begin
                if(hrespp) begin
                    next_state = ERR_CLEAR;
                end
                else begin
                    next_state = IDLE;
                end
            end
            ERR_CLEAR: begin
                next_state = IDLE;
            end
        endcase
    end
    always_ff @( posedge clk, negedge n_rst ) begin
        if(!n_rst) curr_state <= IDLE;
        else curr_state <= next_state;
    end
    always_comb begin
        case (curr_state)
            IDLE: begin
                if(hrespp) err_signal = 1;
                else err_signal = 0;
            end
            ERR_CLEAR: begin
                err_signal = 0;
            end
        endcase
    end
    always_comb begin
        hreadyy = 1;
        hready = 1;
        if(last_hsel)begin
            if((last_haddr>=8'h00 && last_haddr<=8'h0F) || (last_haddr>=8'h18 && last_haddr<=8'h1F)) begin
                if(design_busy) hreadyy = 0;
            end
        end
        hready = hreadyy & (!err_signal);
    end
    always_comb begin
        hrespp = 0;
        output_read = 0;
        if(hsel && htrans==2'd2)begin
            hrespp = 1;
            case(haddr)
                8'h00, 8'h01, 8'h02, 8'h03,
                8'h04, 8'h05, 8'h06, 8'h07,
                8'h08, 8'h09, 8'h0A, 8'h0B,
                8'h0C, 8'h0D, 8'h0E, 8'h0F: begin
                    if(hwrite) hrespp = 0;
                end
                8'h10, 8'h11, 8'h12, 8'h13, 8'h14,
                8'h15, 8'h16, 8'h17, 8'h22, 8'h24: begin
                    hrespp = 0;
                end
                8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C,
                8'h1D, 8'h1E, 8'h1F: begin
                    if(!hwrite) begin
                        hrespp = 0;
                        output_read = 1;
                    end
                end
                8'h20, 8'h21, 8'h23: begin
                    if(!hwrite) hrespp = 0;
                end
            endcase
        end
    end
    typedef enum logic {
        IDLEP,
        ERR_CLEARP
    } state_p;
    state_p curr_statep, next_statep;
    always_comb begin
        next_statep = curr_statep;
        case (curr_statep)
            IDLEP: begin
                if(hrespp) begin
                    next_statep = ERR_CLEARP;
                end
                else begin
                    next_statep = IDLEP;
                end
            end
            ERR_CLEARP: begin
                next_statep = IDLEP;
            end
        endcase
    end
    always_ff @( posedge clk, negedge n_rst ) begin
        if(!n_rst) curr_statep <= IDLEP;
        else curr_statep <= next_statep;
    end
    always_comb begin
        case (curr_statep)
            IDLE: begin
                hresp_p=0;
            end
            ERR_CLEAR: begin
                hresp_p = 1;
            end
        endcase
    end
    assign hresp = hrespp | hresp_p;
    always_comb begin
        next_hrdata   = 64'd0;
        next_write_sel = 8'h25;
        if(hsel) begin
            if(htrans == 2'd2 || htrans == 2'd0) begin
                case(real_haddr)
                    8'h00, 8'h01, 8'h02, 8'h03,
                    8'h04, 8'h05, 8'h06, 8'h07: begin
                        if(real_hwrite) begin
                            next_write_sel = real_haddr;
                        end
                    end
                    8'h08, 8'h09, 8'h0A, 8'h0B,
                    8'h0C, 8'h0D, 8'h0E, 8'h0F: begin
                        if(real_hwrite) begin 
                            next_write_sel = real_haddr;
                        end
                    end
                    8'h10: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {56'd0, reg10[7:0]};
                            if(real_hsize == 3'h1) next_hrdata = {48'd0, reg10[15:0]};
                            if(real_hsize == 3'h2) next_hrdata = {32'd0, reg10[31:0]};
                            if(real_hsize == 3'h3) next_hrdata = reg10;
                        end
                        else begin
                            next_write_sel = 8'h10;
                        end
                    end
                    8'h11: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {48'd0, reg10[15:8], 8'd0};
                        end
                        else begin
                            next_write_sel = 8'h11;
                        end
                    end
                    8'h12: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {40'd0, reg10[23:16], 16'd0};
                            if(real_hsize == 3'h1) next_hrdata = {32'd0, reg10[31:16], 16'd0};
                        end
                        else begin
                            next_write_sel = 8'h12;
                        end
                    end
                    8'h13: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {32'd0, reg10[31:24], 24'd0};
                        end
                        else begin
                            next_write_sel = 8'h13;
                        end
                    end
                    8'h14: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {24'd0, reg10[39:32], 32'd0};
                            if(real_hsize == 3'h1) next_hrdata = {16'd0, reg10[47:32], 32'd0};
                            if(real_hsize == 3'h2) next_hrdata = {reg10[63:32], 32'd0};
                        end
                        else begin
                            next_write_sel = 8'h14;
                        end
                    end
                    8'h15: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {16'd0, reg10[47:40], 40'd0};
                        end
                        else begin
                            next_write_sel = 8'h15;
                        end
                    end
                    8'h16: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {8'd0, reg10[55:48], 48'd0};
                            if(real_hsize == 3'h1) next_hrdata = {reg10[63:48], 48'd0};
                        end
                        else begin
                            next_write_sel = 8'h16;
                        end
                    end
                    8'h17: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {reg10[63:56], 56'd0};
                        end
                        else begin
                            next_write_sel = 8'h17;
                        end
                    end
                    8'h18: begin
                        if (!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {56'd0, out18[7:0]};
                            if(real_hsize == 3'h1) next_hrdata = {48'd0, out18[15:0]};
                            if(real_hsize == 3'h2) next_hrdata = {32'd0, out18[31:0]};
                            if(real_hsize == 3'h3) next_hrdata = out18;
                        end
                    end
                    8'h19: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {48'd0, out18[15:8], 8'd0};
                        end
                    end
                    8'h1A: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {40'd0, out18[23:16], 16'd0};
                            if(real_hsize == 3'h1) next_hrdata = {32'd0, out18[31:16], 16'd0};
                        end
                    end
                    8'h1B: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {32'd0, out18[31:24], 24'd0};
                        end
                    end
                    8'h1C: begin
                        if (!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {24'd0, out18[39:32], 32'd0};
                            if(real_hsize == 3'h1) next_hrdata = {16'd0, out18[47:32], 32'd0};
                            if(real_hsize == 3'h2) next_hrdata = {out18[63:32], 32'd0};
                        end
                    end
                    8'h1D: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {16'd0, out18[47:40], 40'd0};
                        end
                    end
                    8'h1E: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {8'd0, out18[55:48], 48'd0};
                            if(real_hsize == 3'h1) next_hrdata = {out18[63:48], 48'd0};
                        end
                    end
                    8'h1F: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {out18[63:56], 56'd0};
                        end
                    end
                    8'h20: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {56'd0, out20[7:0]};
                            if(real_hsize == 3'h1) next_hrdata = {48'd0, out20[15:0]};
                        end
                    end
                    8'h21: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {48'd0, out20[15:8], 8'd0};
                        end
                    end
                    8'h22: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {40'd0, reg22, 16'd0};
                        end
                        else begin
                            next_write_sel = 8'h22;
                        end
                    end
                    8'h23: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {32'd0, out23, 24'd0};
                        end
                    end
                    8'h24: begin
                        if(!real_hwrite) begin
                            if(real_hsize == 3'h0) next_hrdata = {24'd0, reg24, 32'd0};
                        end
                        else begin
                            next_write_sel = 8'h24;
                        end
                    end
                endcase
            end
        end
    end
    always_comb begin
        next_reg0  = reg0;
        next_reg8  = reg8;
        next_reg10 = reg10;
        next_reg22[7:2] = reg22[7:2];
        if(reg22[0]) next_reg22[0] = 0;
        else next_reg22[0] = reg22[0];

        if(reg22[1]) next_reg22[1] = 0;
        else next_reg22[1] = reg22[1];

        next_reg22[7:2] = reg22[7:2];
        next_reg24 = reg24;

        write_weight = 0;
        write_input  = 0;

        case(write_sel)
            8'h00: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[7:0]   = hwdata[7:0];
                else if(last_hsize == 3'h1) next_reg0[15:0]  = hwdata[15:0];
                else if(last_hsize == 3'h2) next_reg0[31:0]  = hwdata[31:0];
                else if(last_hsize == 3'h3) next_reg0[63:0]  = hwdata[63:0];
            end
            8'h01: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[15:8] = hwdata[15:8];
            end
            8'h02: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[23:16] = hwdata[23:16];
                else if(last_hsize == 3'h1) next_reg0[31:16] = hwdata[31:16];
            end
            8'h03: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[31:24] = hwdata[31:24];
            end
            8'h04: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[39:32] = hwdata[39:32];
                else if(last_hsize == 3'h1) next_reg0[47:32] = hwdata[47:32];
                else if(last_hsize == 3'h2) next_reg0[63:32] = hwdata[63:32];
            end
            8'h05: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[47:40] = hwdata[47:40];
            end
            8'h06: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[55:48] = hwdata[55:48];
                else if(last_hsize == 3'h1) next_reg0[63:48] = hwdata[63:48];
            end
            8'h07: begin
                write_weight = 1;
                if(last_hsize == 3'h0) next_reg0[63:56] = hwdata[63:56];
            end
            8'h08: begin
                write_input = 1;
                if(last_hsize >= 3'h0) next_reg8[7:0]   = hwdata[7:0];
                if(last_hsize >= 3'h1) next_reg8[15:8]  = hwdata[15:8];
                if(last_hsize >= 3'h2) next_reg8[31:16] = hwdata[31:16];
                if(last_hsize == 3'h3) next_reg8[63:32] = hwdata[63:32];
            end
            8'h09: begin
                write_input = 1;
                if(last_hsize == 3'h0) next_reg8[15:8] = hwdata[15:8];
            end
            8'h0A: begin
                write_input = 1;
                if(last_hsize == 3'h0) next_reg8[23:16] = hwdata[23:16];
                else if(last_hsize == 3'h1) next_reg8[31:16] = hwdata[31:16];
            end
            8'h0B: begin
                write_input = 1;
                if(last_hsize == 3'h0) next_reg8[31:24] = hwdata[31:24];
            end
            8'h0C: begin
                write_input = 1;
                if(last_hsize == 3'h0) next_reg8[39:32] = hwdata[39:32];
                else if(last_hsize == 3'h1) next_reg8[47:32] = hwdata[47:32];
                else if(last_hsize == 3'h2) next_reg8[63:32] = hwdata[63:32];
            end
            8'h0D: begin
                write_input = 1;
                if(last_hsize == 3'h0) next_reg8[47:40] = hwdata[47:40];
            end
            8'h0E: begin
                write_input = 1;
                if(last_hsize == 3'h0) next_reg8[55:48] = hwdata[55:48];
                else if(last_hsize == 3'h1) next_reg8[63:48] = hwdata[63:48];
            end
            8'h0F: begin
                write_input = 1;
                if(last_hsize == 3'h0) next_reg8[63:56] = hwdata[63:56];
            end
            8'h10: begin
                if(last_hsize >= 3'h0) next_reg10[7:0]   = hwdata[7:0];
                if(last_hsize >= 3'h1) next_reg10[15:8]  = hwdata[15:8];
                if(last_hsize >= 3'h2) next_reg10[31:16] = hwdata[31:16];
                if(last_hsize == 3'h3) next_reg10[63:32] = hwdata[63:32];
            end
            8'h11: begin
                if(last_hsize == 3'h0) next_reg10[15:8] = hwdata[15:8];
            end
            8'h12: begin
                if(last_hsize == 3'h0) next_reg10[23:16] = hwdata[23:16];
                else if(last_hsize == 3'h1) next_reg10[31:16] = hwdata[31:16];
            end
            8'h13: begin
                if(last_hsize == 3'h0) next_reg10[31:24] = hwdata[31:24];
            end
            8'h14: begin
                if(last_hsize == 3'h0) next_reg10[39:32] = hwdata[39:32];
                else if(last_hsize == 3'h1) next_reg10[47:32] = hwdata[47:32];
                else if(last_hsize == 3'h2) next_reg10[63:32] = hwdata[63:32];
            end
            8'h15: begin
                if(last_hsize == 3'h0) next_reg10[47:40] = hwdata[47:40];
            end
            8'h16: begin
                if(last_hsize == 3'h0) next_reg10[55:48] = hwdata[55:48];
                else if(last_hsize == 3'h1) next_reg10[63:48] = hwdata[63:48];
            end
            8'h17: begin
                if(last_hsize == 3'h0) next_reg10[63:56] = hwdata[63:56];
            end
            8'h22: begin
                if(last_hsize == 3'h0) next_reg22 = hwdata[23:16];
            end
            8'h24: begin
                if(last_hsize == 3'h0) next_reg24 = hwdata[39:32];
            end
        endcase
    end
    always_ff @( posedge clk, negedge n_rst ) begin : FF1
        if(!n_rst) begin
            last_hsel <= 0;
            last_hwrite <= 0;
        end
        else begin
            last_hsel <= real_hsel;
            last_hwrite <= real_hwrite;
        end
    end
    always_ff @( posedge clk, negedge n_rst ) begin : FF2
        if(!n_rst) begin
            last_hsize <= 0;
        end
        else begin
            last_hsize <= real_hsize;
        end
    end
    always_ff @( posedge clk, negedge n_rst ) begin : FF8
        if(!n_rst) begin
            reg22 <= 0;
            reg24 <= 0;
        end
        else begin
            reg22 <= next_reg22;
            reg24 <= next_reg24;
        end
    end
    always_ff @( posedge clk, negedge n_rst ) begin : FF82
        if(!n_rst) begin
            last_haddr <= 0;
            write_sel <= 8'h25;
        end
        else begin
            last_haddr <= real_haddr;
            write_sel <= next_write_sel;
        end
    end

    always_ff @( posedge clk, negedge n_rst ) begin : FF64
        if(!n_rst) begin
            reg0 <= 0;
            reg8 <= 0;
            reg10 <= 0;
            hrdata <= 0;
        end
        else begin
            reg0 <= next_reg0;
            reg8 <= next_reg8;
            reg10 <= next_reg10;
            hrdata <= real_next_hrdata;
        end
    end
    always_comb begin
        real_next_hrdata = hwdata;
        if(!hwrite && haddr==8'h10) begin
            if(hsel==last_hsel && last_hwrite) begin
                if(last_haddr==8'h10) begin
                    if(hsize==3'h0)
                        real_next_hrdata = {56'd0, hwdata[7:0]};
                    else if(hsize==3'h1) begin
                        if(last_hsize==3'h0)
                            real_next_hrdata = {48'd0, next_hrdata[15:8], hwdata[7:0]};
                        else
                            real_next_hrdata = {48'd0, hwdata[15:0]};
                    end
                    else if(hsize==3'h2) begin
                        if(last_hsize==3'h0)
                            real_next_hrdata = {32'd0, next_hrdata[31:8], hwdata[7:0]};
                        else if(last_hsize==3'h1)
                            real_next_hrdata = {32'd0, next_hrdata[31:16], hwdata[15:0]};
                        else
                            real_next_hrdata = {32'd0, hwdata[31:0]};
                    end
                    else if(hsize==3'h3) begin
                        if(last_hsize==3'h0)
                            real_next_hrdata = {next_hrdata[63:8], hwdata[7:0]};
                        else if(last_hsize==3'h1)
                            real_next_hrdata = {next_hrdata[63:16], hwdata[15:0]};
                        else if(last_hsize==3'h2)
                            real_next_hrdata = {next_hrdata[63:32], hwdata[31:0]};
                        else
                            real_next_hrdata = hwdata;
                    end
                    else
                        real_next_hrdata = next_hrdata;
                end
                else if(last_haddr==8'h11) begin
                    if(hsize==3'h1)
                        real_next_hrdata = {48'd0, hwdata[15:8], next_hrdata[7:0]};
                    else if(hsize==3'h2)
                        real_next_hrdata = {32'd0, next_hrdata[31:16], hwdata[15:8], next_hrdata[7:0]};
                    else if(hsize==3'h3)
                        real_next_hrdata = {next_hrdata[63:16], hwdata[15:8], next_hrdata[7:0]};
                    else
                        real_next_hrdata = hwdata;
                end
                else if(last_haddr==8'h12) begin
                    if(hsize==3'h2) begin
                        if(last_hsize==3'h0)
                            real_next_hrdata = {32'd0, next_hrdata[31:24], hwdata[23:16], next_hrdata[15:0]};
                        else if(last_hsize==3'h1)
                            real_next_hrdata = {32'd0, hwdata[31:16], next_hrdata[15:0]};
                        else
                            real_next_hrdata = hwdata;
                    end
                    else if(hsize==3'h3) begin
                        if(last_hsize==3'h0)
                            real_next_hrdata = {next_hrdata[63:24], hwdata[23:16], next_hrdata[15:0]};
                        else if(last_hsize==3'h1)
                            real_next_hrdata = {32'd0, hwdata[31:16], next_hrdata[15:0]};
                        else
                            real_next_hrdata = hwdata;
                    end
                    else real_next_hrdata = hwdata;
                end
                else if(last_haddr==8'h13) begin
                    if(hsize==3'h2)
                        real_next_hrdata = {32'd0, hwdata[31:24], next_hrdata[23:0]};
                    else if(hsize==3'h3)
                        real_next_hrdata = {next_hrdata[63:32], hwdata[31:24], next_hrdata[23:0]};
                    else
                        real_next_hrdata = hwdata;
                end
                else if(last_haddr==8'h14) begin
                    if(hsize==3'h3) begin
                        if(last_hsize==3'h0)
                            real_next_hrdata = {next_hrdata[63:40], hwdata[39:32], next_hrdata[31:0]};
                        if(last_hsize==3'h1)
                            real_next_hrdata = {next_hrdata[63:48], hwdata[47:32], next_hrdata[31:0]};
                        if(last_hsize==3'h2)
                            real_next_hrdata = {hwdata[63:32], next_hrdata[31:0]};
                    end
                    else
                        real_next_hrdata = hwdata;
                end
                else if(last_haddr==8'h15) begin
                    if(hsize==3'h3)
                        real_next_hrdata = {next_hrdata[63:48], hwdata[47:40], next_hrdata[39:0]};
                    else
                        real_next_hrdata = hwdata;
                end
                else if(last_haddr==8'h16) begin
                    if(hsize==3'h3) begin
                        if(last_hsize==3'h0)
                            real_next_hrdata = {next_hrdata[63:56], hwdata[55:48], next_hrdata[47:0]};
                        if(last_hsize==3'h1)
                            real_next_hrdata = {hwdata[63:48], next_hrdata[47:0]};
                    end
                    else
                        real_next_hrdata = hwdata;
                end
                else if(last_haddr==8'h17) begin
                    if(hsize==3'h3)
                        real_next_hrdata = {hwdata[63:56], next_hrdata[55:0]};
                    else
                        real_next_hrdata = hwdata;
                end
            end
            else begin
                real_next_hrdata = next_hrdata;
            end
        end

        else if(!hwrite && haddr==8'h11 && hsel==last_hsel && last_hwrite) begin
            if(last_haddr==8'h11)
                real_next_hrdata = {48'd0, hwdata[15:8], 8'd0};
            else if(last_haddr==8'h10) begin
                if(last_hsize>=3'h1)
                    real_next_hrdata = {48'd0, hwdata[15:8], 8'd0};
                else
                    real_next_hrdata = next_hrdata;
            end
            else
                real_next_hrdata = next_hrdata;
        end
        else if(!hwrite && haddr==8'h13 && hsel==last_hsel && last_hwrite) begin
            if(last_haddr==8'h13 || (last_haddr==8'h10 && last_hsize>=3'h2) || (last_haddr==8'h12 && last_hsize==3'h1))
                real_next_hrdata = {32'd0, hwdata[31:24], 24'd0};
            else
                real_next_hrdata = next_hrdata;
        end
        else if(!hwrite && haddr==8'h15 && hsel==last_hsel && last_hwrite) begin
            if(last_haddr==8'h15 || (last_haddr==8'h10 && last_hsize==3'h3) || (last_haddr==8'h14 && last_hsize>=3'h1))
                real_next_hrdata = {16'd0, hwdata[47:40], 40'd0};
            else
                real_next_hrdata = next_hrdata;
        end
        else if(!hwrite && haddr==8'h17 && hsel==last_hsel && last_hwrite) begin
            if(last_haddr==8'h17 || (last_haddr==8'h10 && last_hsize==3'h3) || (last_haddr==8'h14 && last_hsize==3'h2) || (last_haddr==8'h16 && last_hsize==3'h1))
                real_next_hrdata = {hwdata[63:56], 56'd0};
            else
                real_next_hrdata = next_hrdata;
        end

        else if(!hwrite && haddr==8'h12 && hsel==last_hsel && last_hwrite) begin
            if(last_haddr==8'h12) begin
                if(hsize==3'h0)
                    real_next_hrdata = {40'd0, hwdata[23:16], 16'd0};
                else if(hsize==3'h1) begin
                    if(last_hsize==3'h0)
                        real_next_hrdata = {32'd0, next_hrdata[31:24], hwdata[23:16], 16'd0};
                    else
                        real_next_hrdata = {32'd0, hwdata[31:16], 16'd0};
                end
                else
                    real_next_hrdata = next_hrdata;
            end
            else if(last_haddr==8'h13) begin
                if(hsize==3'h1)
                    real_next_hrdata = {32'd0, hwdata[31:24], next_hrdata[23:16], 16'd0};
                else
                    real_next_hrdata = next_hrdata;
            end
            else if(last_haddr==8'h10 && last_hsize>=3'h2) begin
                if(hsize==3'h0)
                    real_next_hrdata = {40'd0, hwdata[23:16], 16'd0};
                else if(hsize==3'h1) 
                    real_next_hrdata = {32'd0, hwdata[31:16], 16'd0};
                else
                real_next_hrdata = next_hrdata;
            end
            else
                real_next_hrdata = next_hrdata;
        end

        else if(!hwrite && haddr==8'h14 && hsel==last_hsel && last_hwrite) begin
            if(last_haddr==8'h14) begin
                if(hsize==3'h0)
                    real_next_hrdata = {24'd0, hwdata[39:32], 32'd0};
                else if(hsize==3'h1) begin
                    if(last_hsize==3'h0)
                        real_next_hrdata = {16'd0, next_hrdata[47:40], hwdata[39:32], 32'd0};
                    else
                        real_next_hrdata = {16'd0, hwdata[47:32], 32'd0};
                end
                else if(hsize==3'h2) begin
                    if(last_hsize==3'h0)
                        real_next_hrdata = {next_hrdata[63:40], hwdata[39:32], 32'd0};
                    else if(last_hsize==3'h1)
                        real_next_hrdata = {next_hrdata[63:48], hwdata[47:32], 32'd0};
                    else
                        real_next_hrdata = {hwdata[63:32], 32'd0};
                end
            end
            else if(last_haddr==8'h10 && last_hsize==3'h3) begin
                if(hsize==3'h0)
                    real_next_hrdata = {24'd0, hwdata[39:32], 32'd0};
                else if(hsize==3'h1) 
                    real_next_hrdata = {16'd0, hwdata[47:32], 32'd0};
                else if(hsize==3'h2) 
                    real_next_hrdata = {hwdata[63:32], 32'd0};
                else
                real_next_hrdata = next_hrdata;
            end
            else if(last_haddr==8'h15) begin
                if(hsize==3'h0)
                    real_next_hrdata = next_hrdata;
                else if(hsize==3'h1)
                    real_next_hrdata = {16'd0, hwdata[47:40],  next_hrdata[39:32], 32'd0};
                else if(hsize==3'h2) 
                    real_next_hrdata = {next_hrdata[63:48], hwdata[47:40], next_hrdata[39:32], 32'd0};
            end
            else if(last_haddr==8'h16) begin
                if(hsize==3'h0)
                    real_next_hrdata = next_hrdata;
                else if(hsize==3'h1) 
                    real_next_hrdata = next_hrdata;
                else if(hsize==3'h2) begin
                    if(last_hsize==3'h0)
                        real_next_hrdata = {next_hrdata[63:56], hwdata[55:48], next_hrdata[47:32], 32'd0};
                    else if(last_hsize==3'h1)
                        real_next_hrdata = {hwdata[63:48], next_hrdata[47:32], 32'd0};
                    else
                        real_next_hrdata = next_hrdata;
                end
            end
            else if(last_haddr==8'h17 && hsize==3'h2) 
                real_next_hrdata = {hwdata[63:56], next_hrdata[55:32], 32'd0};
            else
                real_next_hrdata = next_hrdata;
        end

        else if(!hwrite && haddr==8'h16 && hsel==last_hsel && last_hwrite) begin
            if(last_haddr==8'h16) begin
                if(hsize==3'h0)
                    real_next_hrdata = {8'd0, hwdata[55:48], 48'd0};
                else if(hsize==3'h1) begin
                    if(last_hsize==3'h0)
                        real_next_hrdata = {next_hrdata[63:56], hwdata[55:48], 48'd0};
                    else
                        real_next_hrdata = {hwdata[63:48], 48'd0};
                end
                else
                    real_next_hrdata = next_hrdata;
            end
            else if(last_haddr==8'h10 && last_hsize==3'h3) begin
                if(hsize==3'h0)
                    real_next_hrdata = {8'd0, hwdata[55:48], 48'd0};
                else if(hsize==3'h1) 
                    real_next_hrdata = {hwdata[63:48], 48'd0};
                else
                real_next_hrdata = next_hrdata;
            end
            else if(last_haddr==8'h17 && hsize==3'h1) 
                    real_next_hrdata = {hwdata[63:56], next_hrdata[55:48], 48'd0};
            else
                real_next_hrdata = next_hrdata;
        end

        else if(hsize==3'h0 && last_hsize==3'h0 && !hwrite && haddr==8'h22) begin
            if(hsel==last_hsel && last_hwrite) begin
                if(last_haddr==haddr)
                    real_next_hrdata = {40'd0, hwdata[23:16], 16'd0};
                else
                    real_next_hrdata = next_hrdata;
            end
            else
                real_next_hrdata = next_hrdata;
        end
        else if(hsize==3'h0 && last_hsize==3'h0 && !hwrite && haddr==8'h24) begin
            if(hsel==last_hsel && last_hwrite) begin
                if(last_haddr==haddr)
                    real_next_hrdata = {24'd0, hwdata[39:32], 32'd0};
                else
                    real_next_hrdata = next_hrdata;
            end
            else
                real_next_hrdata = next_hrdata;
        end

        else begin
            real_next_hrdata = next_hrdata;
        end
    end
    
endmodule
