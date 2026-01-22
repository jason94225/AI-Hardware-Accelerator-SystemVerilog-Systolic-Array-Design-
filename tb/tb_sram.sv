`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_sram ();

    localparam CLK_PERIOD = 10ns;

    // DUT input signals
    logic [9:0]  sram_addr;
    logic        sram_read_en;
    logic        sram_write_en;
    logic [31:0] sram_write_data;

    // DUT output signals
    logic [31:0] sram_read_data;
    logic [1:0]  sram_state;
    

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    sram #() DUT (
        .clk(clk),
        .n_rst(n_rst),
        .sram_addr(sram_addr),
        .sram_read_en(sram_read_en),
        .sram_write_en(sram_write_en),
        .sram_write_data(sram_write_data),
        .sram_read_data(sram_read_data),
        .sram_state(sram_state)//sram.sv/sram_state
    );

    initial begin
        n_rst = 1;
        sram_read_en = 0;
        sram_write_data = '0;
        sram_addr = '0;
        sram_write_en = 0;
        reset_dut;
        sram_write_data = 32'hffffffff;
        sram_addr = 10'd300;
        sram_write_en = 1;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        sram_read_en = 1;
        sram_write_en = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
         sram_read_en = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        $finish;
    end
endmodule

/* verilator coverage_on */

