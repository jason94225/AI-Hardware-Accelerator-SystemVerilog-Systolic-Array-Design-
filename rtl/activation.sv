`timescale 1ns / 10ps

module activation #(
    // parameters
) (
    input logic [2:0] activation_mode,
    input logic [63:0] sum_out,
    output logic [63:0] activations
);

    always_comb begin
        activations = sum_out;
        case(activation_mode)
            3'd0: begin
                if (sum_out[63:56] < 0) activations[63:56] = '0;
                if (sum_out[55:48] < 0) activations[55:48] = '0;
                if (sum_out[47:40] < 0) activations[47:40] = '0;
                if (sum_out[39:32] < 0) activations[39:32] = '0;
                if (sum_out[31:24] < 0) activations[31:24] = '0;
                if (sum_out[23:16] < 0) activations[23:16] = '0;
                if (sum_out[15:8]  < 0) activations[15:8]  = '0;
                if (sum_out[7:0]   < 0) activations[7:0]   = '0;
            end
            3'd1: begin
                if (sum_out[63:56] > 0) activations[63:56] = 8'd1;
                else                    activations[63:56] = 8'd0;

                if (sum_out[55:48] > 0) activations[55:48] = 8'd1;
                else                    activations[55:48] = 8'd0;

                if (sum_out[47:40] > 0) activations[47:40] = 8'd1;
                else                    activations[47:40] = 8'd0;

                if (sum_out[39:32] > 0) activations[39:32] = 8'd1;
                else                    activations[39:32] = 8'd0;

                if (sum_out[31:24] > 0) activations[31:24] = 8'd1;
                else                    activations[31:24] = 8'd0;

                if (sum_out[23:16] > 0) activations[23:16] = 8'd1;
                else                    activations[23:16] = 8'd0;

                if (sum_out[15:8] > 0) activations[15:8] = 8'd1;
                else                   activations[15:8] = 8'd0;

                if (sum_out[7:0] > 0) activations[7:0] = 8'd1;
                else                  activations[7:0] = 8'd0;
            end
            3'd2: begin
                activations = sum_out;
            end
            3'd3: begin
                if (sum_out[63:56] < 0) activations[63:56] = sum_out[63:56] * 0.125;
                if (sum_out[55:48] < 0) activations[55:48] = sum_out[55:48] * 0.125;
                if (sum_out[47:40] < 0) activations[47:40] = sum_out[47:40] * 0.125;
                if (sum_out[39:32] < 0) activations[39:32] = sum_out[39:32] * 0.125;
                if (sum_out[31:24] < 0) activations[31:24] = sum_out[31:24] * 0.125;
                if (sum_out[23:16] < 0) activations[23:16] = sum_out[23:16] * 0.125;
                if (sum_out[15:8]  < 0) activations[15:8]  = sum_out[15:8]  * 0.125;
                if (sum_out[7:0]   < 0) activations[7:0]   = sum_out[7:0]   * 0.125;
            end
        endcase
    end



endmodule

