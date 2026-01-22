`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_combine ();

    localparam CLK_PERIOD = 10ns;

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

    task clk_gen;
    integer i;
    input logic [10:0] num;
    begin
        for(i = 0; i<num; i ++) begin
            @(negedge clk);
        end
    end
    endtask



    combine #() DUT (.*);
    logic [9:0] i;
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
        //systolic array
        array_busy = 0;
        // activations
        activations = '0;
        activations_valid = 0;

        reset_dut;
        @(negedge clk);

        //write weight from ahb to sram (full)
        for(i = 0; i < 8; i++) begin
             weight_data = 64'h1111111100001111;
             write_weight = 1;
             @(negedge clk);
             write_weight = 0;
             clk_gen(15);
         end

        //read weight from sram to array
        load_weight = 1;
        @(negedge clk);
        load_weight = 0;
        clk_gen(125);

        // //write input from sram to array
        for(i = 0; i < 8; i++) begin
            input_data = 64'h1111111100001111;
            write_input = 1;
            @(negedge clk);
            write_input = 0;
            clk_gen(15);
        end

        // //read input from ahb to sram
        start_inference = 1;
        @(negedge clk);
        start_inference = 0;
        clk_gen(125);
        
        // // write output from activations to sram
        for(i = 0; i < 9; i++) begin
            activations = 64'h1111111100001111;
            activations_valid = 1;
            @(negedge clk);
            activations_valid = 0;
            clk_gen(15);
        end
        // //read outputfrom activations from sramto AHB
        output_read = 1;
        @(negedge clk);
        output_read = 0;
        clk_gen(15);
        //occupancy error weight
        //occupancy error input
        //occupnacy error output
        //busy error

    

        $finish;
    end
endmodule

/* verilator coverage_on */

