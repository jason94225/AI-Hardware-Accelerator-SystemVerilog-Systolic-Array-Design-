`timescale 1ns / 10ps

module top_level #(
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
    output logic [63:0] hrdata,
    
    // to array
    output logic [63:0] bias,
    output logic [2:0] activation_mode,
    output logic        array_start,  
    output logic        load,
    output logic [63:0] inputs,
    output logic design_busy,

    // systolic array 
    input  logic        array_busy,

    // activation
    input  logic [63:0] activations,
    input  logic        activations_valid
);
    //from SRAM to AHB
    logic [63:0] output_data;
    logic occupancy_err_i, occupancy_err_o, occupancy_err_w, device_busy_err, data_ready;

    //from AHB to sram
    logic [63:0] weight_data, input_data;
    logic start_inference, load_weight;
    logic write_weight, write_input;
    logic output_read;

    combine controller_sram(.*);
    subordinate subordinate(.*);

endmodule

