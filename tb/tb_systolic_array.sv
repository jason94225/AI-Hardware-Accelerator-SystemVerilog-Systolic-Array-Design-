`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_systolic_array ();
    logic clk, n_rst;
    logic load;
    logic [63:0] inputs;
    logic array_start;
    logic array_busy;
    logic [63:0] outputs;
    logic design_busy;
    logic activations_valid;

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

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

    systolic_array #() DUT (.*);

    initial begin
        n_rst = 1;
        array_start = 0;
        inputs = '0;
        load = 0;
        design_busy = 0;
        reset_dut;
        @(negedge clk);

        load = 1;
        inputs = 64'h0101_0101_0101_0101;   // was 1111
        @(negedge clk);
        load = 0;
        @(negedge clk);

        load = 1;
        inputs = 64'h0202_0202_0202_0202;   // was 2222
        @(negedge clk);
        load = 0;
        @(negedge clk);

        load = 1;
        inputs = 64'h0303_0303_0303_0303;   // was 3333
        @(negedge clk);
        load = 0;
        @(negedge clk);

        load = 1;
        inputs = 64'h0404_0404_0404_0404;   // was 4444
        @(negedge clk);
        load = 0;
        @(negedge clk);

        load = 1;
        inputs = 64'h0505_0505_0505_0505;   // was 5555
        @(negedge clk);
        load = 0;
        @(negedge clk);

        load = 1;
        inputs = 64'h0606_0606_0606_0606;   // was 6666
        @(negedge clk);
        load = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        load = 1;
        inputs = 64'h0707_0709_0707_0707;   // was 7777
        @(negedge clk);
        load = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        load = 1;
        inputs = 64'h0101_0101_0101_0101;   // was 8888
        @(negedge clk);
        load = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        @(posedge clk);
        array_start = 1;
        inputs = 64'h0101_0101_0101_0101;   // was 1111
        @(posedge clk);
        array_start = 0;
        @(posedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        array_start = 1;
        inputs = 64'h0202_0202_0202_0202;   // was 2222
        @(negedge clk);
        array_start = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        array_start = 1;
        inputs = 64'h0303_0303_0303_0303;   // was 3333
        @(negedge clk);
        array_start = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        array_start = 1;
        inputs = 64'h0404_0404_0404_0404;   // was 4444
        @(negedge clk);
        array_start = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        array_start = 1;
        inputs = 64'h0505_0505_0505_0505;   // was 5555
        @(negedge clk);
        array_start = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        array_start = 1;
        inputs = 64'h0606_0606_0606_0606;   // was 6666
        @(negedge clk);
        array_start = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        array_start = 1;
        inputs = 64'h0707_0707_0707_0707;   // was 7777
        @(negedge clk);
        array_start = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        array_start = 1;
        inputs = 64'h0101_0101_0101_0101;   // was 8888
        @(negedge clk);
        array_start = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
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

