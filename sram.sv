`timescale 1ns / 10ps

module sram #(
    // parameters
) (
    // inputs
    input  logic        clk,
    input  logic        n_rst,
    input  logic [9:0]  sram_addr,
    input  logic        sram_read_en,
    input  logic        sram_write_en,
    input  logic [31:0] sram_write_data,
    // outputs
    output logic [31:0] sram_read_data,
    output logic [1:0]  sram_state

);
sram1024x32_wrapper #() Core (
    .clk(clk),
    .n_rst(n_rst),
    .address(sram_addr),
    .read_enable(sram_read_en),
    .write_enable(sram_write_en),
    .write_data(sram_write_data),
    .read_data(sram_read_data),
    .sram_state(sram_state)
);



endmodule

