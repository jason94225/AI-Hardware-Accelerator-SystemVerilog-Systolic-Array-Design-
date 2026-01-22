`timescale 1ns / 10ps

module combine #(
    // parameters
) (
    input  logic        clk,
    input  logic        n_rst,

    // AHB subordinate
    input  logic        output_read,
    input  logic        write_input,
    input  logic        write_weight,
    input  logic        start_inference,
    input  logic        load_weight,
    input  logic [63:0] input_data,
    input  logic [63:0] weight_data,

    output logic        data_ready,
    output logic        design_busy,
    output logic        occupancy_err_i,
    output logic        occupancy_err_o,
    output logic        occupancy_err_w,
    output logic        device_busy_err,
    output logic [63:0] output_data,

    // systolic array 
    input  logic        array_busy,

    output logic        array_start,  
    output logic        load,
    output logic [63:0] inputs,

    // activation
    input  logic [63:0] activations,
    input  logic        activations_valid
);

    logic [31:0] sram_read_data;
    logic [1:0]  sram_state;
    logic        sram_read_en;
    logic        sram_write_en;
    logic [31:0] sram_write_data;
    logic [9:0]  sram_addr;

    sram_controller controller(.*);
    sram sram(.*);

endmodule

