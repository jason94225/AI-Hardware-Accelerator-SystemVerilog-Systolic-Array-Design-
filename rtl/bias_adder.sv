`timescale 1ns / 10ps

module bias_adder #(
    // parameters
) (
    input logic [63:0] outputs,
    input logic [63:0] bias,
    output logic [63:0] sum_out
);

    assign sum_out[63:56] = outputs[63:56] + bias[63:56];
    assign sum_out[55:48] = outputs[55:48] + bias[55:48];
    assign sum_out[47:40] = outputs[47:40] + bias[47:40];
    assign sum_out[39:32] = outputs[39:32] + bias[39:32];
    assign sum_out[31:24] = outputs[31:24] + bias[31:24];
    assign sum_out[23:16] = outputs[23:16] + bias[23:16];
    assign sum_out[15:8]  = outputs[15:8]  + bias[15:8];
    assign sum_out[7:0]   = outputs[7:0]   + bias[7:0];



endmodule

