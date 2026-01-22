`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_sram_controller ();

    localparam CLK_PERIOD = 10ns;
    logic clk, n_rst;

    logic output_read;
    logic write_input;
    logic write_weight;
    logic start_inference;
    logic load_weight;
    logic [63:0] input_data;
    logic [63:0] weight_data;

    logic        data_ready;
    logic        design_busy;
    logic        occupancy_err_i;
    logic        occupancy_err_o;
    logic        occupancy_err_w;
    logic        device_busy_err;
    logic [63:0] output_data;

    logic [63:0] sram_read_data;
    logic [1:0]  sram_state;

    logic        sram_read_en;
    logic        sram_write_en;
    logic [63:0] sram_write_data;
    logic [9:0]  sram_addr;

    logic        array_busy;

    logic        array_start;
    logic        load;
    logic [63:0] inputs;

    logic [63:0] activations;
    logic activations_valid;
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

    sram_controller #() DUT (.*);

    initial begin
        n_rst = 1;
        //AHB
        output_read = 0;
        write_input = 0;
        write_weight = 0;
        start_inference = 0;
        load_weight = 0;
        input_data = '0;
        weight_data = '0;
        //SRAM
        sram_read_data = '0;
        sram_state = '0;
        //systolic array
        array_busy = 0;
        // activations
        activations = '0;
        activations_valid = 0;
        reset_dut;
        //write weight from ahb to sram
        load_weight = 1;
        @(negedge clk);
        load_weight = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        //read weight from sram to array
        //write input from sram to array
        //write input from sram to array
        //write output from activations to sram
        //read outputfrom activations from sramto AHB
        //occupancy error weight
        //occupancy error input
        //occupnacy error output
        //busy error


        $finish;
    end
endmodule

/* verilator coverage_on */

