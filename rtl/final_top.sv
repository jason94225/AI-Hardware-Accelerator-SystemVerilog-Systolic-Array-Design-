`timescale 1ns / 10ps

module final_top #(
    // parameters
) (
    input logic clk, n_rst,
    //from CPU
    input logic hsel, 
    input logic [7:0] haddr,
    input logic [1:0] htrans,
    input logic [2:0] hsize,
    input logic hwrite,
    input logic [63:0] hwdata,
    input logic [2:0] hburst,

    //to CPU
    output logic hresp, hready,
    output logic [63:0] hrdata

);

    // SRAM to systolic array
    logic        design_busy;
    logic        array_start;  
    logic        load;
    logic [63:0] inputs;

    // systolic array to SRAM
    logic        array_busy;
    logic        activations_valid;
    // activation to SRAM
    logic [63:0] activations;

    // array to activattions
    logic [63:0] outputs;
    //bias to activations
    logic [63:0] sum_out;
    //AHB to activations
    logic [2:0] activation_mode;

    //AHB to bias 
    logic [63:0] bias;

    bias_adder biasa (.*);
    activation actv (.*);
    systolic_array array (.*);
    top_level sram_AHB (.*);





endmodule

