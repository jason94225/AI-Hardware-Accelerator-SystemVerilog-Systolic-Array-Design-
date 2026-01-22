`timescale 1ns / 10ps

module systolic_array #(
    // parameters
) (
    input logic clk, n_rst,
    input logic load,
    input logic [63:0] inputs,
    input logic array_start,
    input logic design_busy,
    output logic array_busy,
    output logic [63:0] outputs,
    output logic activations_valid
);
    //input store register
    logic [7:0] input_store0 [14:0];
    logic [7:0] input_store1 [14:0];
    logic [7:0] input_store2 [14:0];
    logic [7:0] input_store3 [14:0];
    logic [7:0] input_store4 [14:0];
    logic [7:0] input_store5 [14:0];
    logic [7:0] input_store6 [14:0];
    logic [7:0] input_store7 [14:0];

    logic [7:0] n_input_store0 [14:0];
    logic [7:0] n_input_store1 [14:0];
    logic [7:0] n_input_store2 [14:0];
    logic [7:0] n_input_store3 [14:0];
    logic [7:0] n_input_store4 [14:0];
    logic [7:0] n_input_store5 [14:0];
    logic [7:0] n_input_store6 [14:0];
    logic [7:0] n_input_store7 [14:0];

    //output store register
    logic [7:0] output_store0  [7:0];
    logic [7:0] output_store1  [7:0];
    logic [7:0] output_store2  [7:0];
    logic [7:0] output_store3  [7:0];
    logic [7:0] output_store4  [7:0];
    logic [7:0] output_store5  [7:0];
    logic [7:0] output_store6  [7:0];
    logic [7:0] output_store7  [7:0];
    logic [7:0] output_store8  [7:0];
    logic [7:0] output_store9  [7:0];
    logic [7:0] output_store10 [7:0];
    logic [7:0] output_store11 [7:0];
    logic [7:0] output_store12 [7:0];
    logic [7:0] output_store13 [7:0];
    logic [7:0] output_store14 [7:0];

    logic [7:0] n_output_store0  [7:0];
    logic [7:0] n_output_store1  [7:0];
    logic [7:0] n_output_store2  [7:0];
    logic [7:0] n_output_store3  [7:0];
    logic [7:0] n_output_store4  [7:0];
    logic [7:0] n_output_store5  [7:0];
    logic [7:0] n_output_store6  [7:0];
    logic [7:0] n_output_store7  [7:0];
    logic [7:0] n_output_store8  [7:0];
    logic [7:0] n_output_store9  [7:0];
    logic [7:0] n_output_store10 [7:0];
    logic [7:0] n_output_store11 [7:0];
    logic [7:0] n_output_store12 [7:0];
    logic [7:0] n_output_store13 [7:0];
    logic [7:0] n_output_store14 [7:0];


    
    //weight data register
    logic [7:0] weight0 [7:0];
    logic [7:0] weight1 [7:0];
    logic [7:0] weight2 [7:0];
    logic [7:0] weight3 [7:0];
    logic [7:0] weight4 [7:0];
    logic [7:0] weight5 [7:0];
    logic [7:0] weight6 [7:0];
    logic [7:0] weight7 [7:0];

    logic [7:0] n_weight0 [7:0];
    logic [7:0] n_weight1 [7:0];
    logic [7:0] n_weight2 [7:0];
    logic [7:0] n_weight3 [7:0];
    logic [7:0] n_weight4 [7:0];
    logic [7:0] n_weight5 [7:0];
    logic [7:0] n_weight6 [7:0];
    logic [7:0] n_weight7 [7:0];

    //input register
    logic [7:0] input0 [7:0];
    logic [7:0] input1 [7:0];
    logic [7:0] input2 [7:0];
    logic [7:0] input3 [7:0];
    logic [7:0] input4 [7:0];
    logic [7:0] input5 [7:0];
    logic [7:0] input6 [7:0];
    logic [7:0] input7 [7:0];

    logic [7:0] n_input0 [7:0];
    logic [7:0] n_input1 [7:0];
    logic [7:0] n_input2 [7:0];
    logic [7:0] n_input3 [7:0];
    logic [7:0] n_input4 [7:0];
    logic [7:0] n_input5 [7:0];
    logic [7:0] n_input6 [7:0];
    logic [7:0] n_input7 [7:0];

    //output register
    logic [7:0] output0 [7:0];
    logic [7:0] output1 [7:0];
    logic [7:0] output2 [7:0];
    logic [7:0] output3 [7:0];
    logic [7:0] output4 [7:0];
    logic [7:0] output5 [7:0];
    logic [7:0] output6 [7:0];
    logic [7:0] output7 [7:0];

    logic [7:0] n_output0 [7:0];
    logic [7:0] n_output1 [7:0];
    logic [7:0] n_output2 [7:0];
    logic [7:0] n_output3 [7:0];
    logic [7:0] n_output4 [7:0];
    logic [7:0] n_output5 [7:0];
    logic [7:0] n_output6 [7:0];
    logic [7:0] n_output7 [7:0];


    //subsum register
    logic [7:0] subsum0 [7:0];
    logic [7:0] subsum1 [7:0];
    logic [7:0] subsum2 [7:0];
    logic [7:0] subsum3 [7:0];
    logic [7:0] subsum4 [7:0];
    logic [7:0] subsum5 [7:0];
    logic [7:0] subsum6 [7:0];
    logic [7:0] subsum7 [7:0];

    logic [7:0] n_subsum0 [7:0];
    logic [7:0] n_subsum1 [7:0];
    logic [7:0] n_subsum2 [7:0];
    logic [7:0] n_subsum3 [7:0];
    logic [7:0] n_subsum4 [7:0];
    logic [7:0] n_subsum5 [7:0];
    logic [7:0] n_subsum6 [7:0];
    logic [7:0] n_subsum7 [7:0];
    logic [4:0] load_count;
    logic [4:0] subsum7_count;

    assign array_busy = (load_count!=0 || subsum7_count!=0);


always_ff @( posedge clk, negedge n_rst ) begin : ff
    if(!n_rst) begin
        for(int i = 0; i<15; i++) begin
            input_store0[i] <= '0;
            input_store1[i] <= '0;
            input_store2[i] <= '0;
            input_store3[i] <= '0;
            input_store4[i] <= '0;
            input_store5[i] <= '0;
            input_store6[i] <= '0;
            input_store7[i] <= '0;

        end
        for(int i = 0; i<8; i++) begin
            weight0[i] <= '0;
            weight1[i] <= '0;
            weight2[i] <= '0;
            weight3[i] <= '0;
            weight4[i] <= '0;
            weight5[i] <= '0;
            weight6[i] <= '0;
            weight7[i] <= '0;

            input0[i] <= '0;
            input1[i] <= '0;
            input2[i] <= '0;
            input3[i] <= '0;
            input4[i] <= '0;
            input5[i] <= '0;
            input6[i] <= '0;
            input7[i] <= '0;

            output_store0[i]  <= '0;
            output_store1[i]  <= '0;
            output_store2[i]  <= '0;
            output_store3[i]  <= '0;
            output_store4[i]  <= '0;
            output_store5[i]  <= '0;
            output_store6[i]  <= '0;
            output_store7[i]  <= '0;
            output_store8[i]  <= '0;
            output_store9[i]  <= '0;
            output_store10[i] <= '0;
            output_store11[i] <= '0;
            output_store12[i] <= '0;
            output_store13[i] <= '0;
            output_store14[i] <= '0;

            subsum0[i] <= '0;
            subsum1[i] <= '0;
            subsum2[i] <= '0;
            subsum3[i] <= '0;
            subsum4[i] <= '0;
            subsum5[i] <= '0;
            subsum6[i] <= '0;
            subsum7[i] <= '0;
            
            output0[i] <= '0;
            output1[i] <= '0;
            output2[i] <= '0;
            output3[i] <= '0;
            output4[i] <= '0;
            output5[i] <= '0;
            output6[i] <= '0;
            output7[i] <= '0;
        end
    end
    else begin
        for(int i = 0; i<15; i++) begin
            input_store0[i] <= n_input_store0[i];
            input_store1[i] <= n_input_store1[i];
            input_store2[i] <= n_input_store2[i];
            input_store3[i] <= n_input_store3[i];
            input_store4[i] <= n_input_store4[i];
            input_store5[i] <= n_input_store5[i];
            input_store6[i] <= n_input_store6[i];
            input_store7[i] <= n_input_store7[i];
        end
        for(int i = 0; i<8; i++) begin
            weight0[i] <= n_weight0[i];
            weight1[i] <= n_weight1[i];
            weight2[i] <= n_weight2[i];
            weight3[i] <= n_weight3[i];
            weight4[i] <= n_weight4[i];
            weight5[i] <= n_weight5[i];
            weight6[i] <= n_weight6[i];
            weight7[i] <= n_weight7[i];

            input0[i] <= n_input0[i];
            input1[i] <= n_input1[i];
            input2[i] <= n_input2[i];
            input3[i] <= n_input3[i];
            input4[i] <= n_input4[i];
            input5[i] <= n_input5[i];
            input6[i] <= n_input6[i];
            input7[i] <= n_input7[i];

            output_store0[i]  <= n_output_store0[i];
            output_store1[i]  <= n_output_store1[i];
            output_store2[i]  <= n_output_store2[i];
            output_store3[i]  <= n_output_store3[i];
            output_store4[i]  <= n_output_store4[i];
            output_store5[i]  <= n_output_store5[i];
            output_store6[i]  <= n_output_store6[i];
            output_store7[i]  <= n_output_store7[i];
            output_store8[i]  <= n_output_store8[i];
            output_store9[i]  <= n_output_store9[i];
            output_store10[i] <= n_output_store10[i];
            output_store11[i] <= n_output_store11[i];
            output_store12[i] <= n_output_store12[i];
            output_store13[i] <= n_output_store13[i];
            output_store14[i] <= n_output_store14[i];


            subsum0[i] <= n_subsum0[i];
            subsum1[i] <= n_subsum1[i];
            subsum2[i] <= n_subsum2[i];
            subsum3[i] <= n_subsum3[i];
            subsum4[i] <= n_subsum4[i];
            subsum5[i] <= n_subsum5[i];
            subsum6[i] <= n_subsum6[i];
            subsum7[i] <= n_subsum7[i];

            output0[i] <= n_output0[i];
            output1[i] <= n_output1[i];
            output2[i] <= n_output2[i];
            output3[i] <= n_output3[i];
            output4[i] <= n_output4[i];
            output5[i] <= n_output5[i];
            output6[i] <= n_output6[i];
            output7[i] <= n_output7[i];
        end
    end
end

    //store weight logic
    logic [2:0] weight_count;
    logic [2:0] n_weight_count;
    always_ff @(posedge clk, negedge n_rst)begin
        if(!n_rst)
            weight_count <= 0;
        else
            weight_count <= n_weight_count;
    end

    always_comb begin
        n_weight_count = weight_count;
        for(int i = 0; i<8; i++)begin
            n_weight0[i] = weight0[i];
            n_weight1[i] = weight1[i];
            n_weight2[i] = weight2[i];
            n_weight3[i] = weight3[i];
            n_weight4[i] = weight4[i];
            n_weight5[i] = weight5[i];
            n_weight6[i] = weight6[i];
            n_weight7[i] = weight7[i];
        end
        if (load) begin
            if(weight_count == 3'd0) begin
                n_weight_count = weight_count + 1;
                n_weight0[0] = inputs[7:0];
                n_weight0[1] = inputs[15:8];
                n_weight0[2] = inputs[23:16];
                n_weight0[3] = inputs[31:24];
                n_weight0[4] = inputs[39:32];
                n_weight0[5] = inputs[47:40];
                n_weight0[6] = inputs[55:48];
                n_weight0[7] = inputs[63:56];

            end
            else if(weight_count == 3'd1) begin
                n_weight_count = weight_count + 1;
                n_weight1[0] = inputs[7:0];
                n_weight1[1] = inputs[15:8];
                n_weight1[2] = inputs[23:16];
                n_weight1[3] = inputs[31:24];
                n_weight1[4] = inputs[39:32];
                n_weight1[5] = inputs[47:40];
                n_weight1[6] = inputs[55:48];
                n_weight1[7] = inputs[63:56];
            end
            else if(weight_count == 3'd2) begin
                n_weight_count = weight_count + 1;
                n_weight2[0] = inputs[7:0];
                n_weight2[1] = inputs[15:8];
                n_weight2[2] = inputs[23:16];
                n_weight2[3] = inputs[31:24];
                n_weight2[4] = inputs[39:32];
                n_weight2[5] = inputs[47:40];
                n_weight2[6] = inputs[55:48];
                n_weight2[7] = inputs[63:56];
            end
            else if(weight_count == 3'd3) begin
                n_weight_count = weight_count + 1;
                n_weight3[0] = inputs[7:0];
                n_weight3[1] = inputs[15:8];
                n_weight3[2] = inputs[23:16];
                n_weight3[3] = inputs[31:24];
                n_weight3[4] = inputs[39:32];
                n_weight3[5] = inputs[47:40];
                n_weight3[6] = inputs[55:48];
                n_weight3[7] = inputs[63:56];
            end
            else if(weight_count == 3'd4) begin
                n_weight_count = weight_count + 1;
                n_weight4[0] = inputs[7:0];
                n_weight4[1] = inputs[15:8];
                n_weight4[2] = inputs[23:16];
                n_weight4[3] = inputs[31:24];
                n_weight4[4] = inputs[39:32];
                n_weight4[5] = inputs[47:40];
                n_weight4[6] = inputs[55:48];
                n_weight4[7] = inputs[63:56];
            end
            else if(weight_count == 3'd5) begin
                n_weight_count = weight_count + 1;
                n_weight5[0] = inputs[7:0];
                n_weight5[1] = inputs[15:8];
                n_weight5[2] = inputs[23:16];
                n_weight5[3] = inputs[31:24];
                n_weight5[4] = inputs[39:32];
                n_weight5[5] = inputs[47:40];
                n_weight5[6] = inputs[55:48];
                n_weight5[7] = inputs[63:56];
            end
            else if(weight_count == 3'd6) begin
                n_weight_count = weight_count + 1;
                n_weight6[0] = inputs[7:0];
                n_weight6[1] = inputs[15:8];
                n_weight6[2] = inputs[23:16];
                n_weight6[3] = inputs[31:24];
                n_weight6[4] = inputs[39:32];
                n_weight6[5] = inputs[47:40];
                n_weight6[6] = inputs[55:48];
                n_weight6[7] = inputs[63:56];
            end
            else if(weight_count == 3'd7) begin
                n_weight_count = 0;
                n_weight7[0] = inputs[7:0];
                n_weight7[1] = inputs[15:8];
                n_weight7[2] = inputs[23:16];
                n_weight7[3] = inputs[31:24];
                n_weight7[4] = inputs[39:32];
                n_weight7[5] = inputs[47:40];
                n_weight7[6] = inputs[55:48];
                n_weight7[7] = inputs[63:56];
            end

        end
    end


    //input store logic
    logic [2:0] input_count;
    logic [2:0] n_input_count;
    always_ff @(posedge clk, negedge n_rst)begin
        if(!n_rst)
            input_count <= 0;
        else 
            input_count <= n_input_count;
    end

    always_comb begin
        n_input_count = input_count;
        for(int i = 0; i<15; i++) begin
            n_input_store0[i] = input_store0[i];
            n_input_store1[i] = input_store1[i];
            n_input_store2[i] = input_store2[i];
            n_input_store3[i] = input_store3[i];
            n_input_store4[i] = input_store4[i];
            n_input_store5[i] = input_store5[i];
            n_input_store6[i] = input_store6[i];
            n_input_store7[i] = input_store7[i];
        end
        if(array_start) begin
            if(input_count==3'd0) begin
                n_input_count = input_count + 1;
                n_input_store0[0]  = inputs[63:56];
                n_input_store1[1]  = inputs[55:48];
                n_input_store2[2]  = inputs[47:40];
                n_input_store3[3]  = inputs[39:32];
                n_input_store4[4]  = inputs[31:24];
                n_input_store5[5]  = inputs[23:16];
                n_input_store6[6]  = inputs[15:8];
                n_input_store7[7]  = inputs[7:0];
            end
            else if(input_count==3'd1) begin
                n_input_count = input_count + 1;
                n_input_store0[1]  = inputs[63:56];
                n_input_store1[2]  = inputs[55:48];
                n_input_store2[3]  = inputs[47:40];
                n_input_store3[4]  = inputs[39:32];
                n_input_store4[5]  = inputs[31:24];
                n_input_store5[6]  = inputs[23:16];
                n_input_store6[7]  = inputs[15:8];
                n_input_store7[8]  = inputs[7:0];
            end
            else if(input_count==3'd2) begin
                n_input_count = input_count + 1;
                n_input_store0[2]  = inputs[63:56];
                n_input_store1[3]  = inputs[55:48];
                n_input_store2[4]  = inputs[47:40];
                n_input_store3[5]  = inputs[39:32];
                n_input_store4[6]  = inputs[31:24];
                n_input_store5[7]  = inputs[23:16];
                n_input_store6[8]  = inputs[15:8];
                n_input_store7[9]  = inputs[7:0];
            end
            else if(input_count==3'd3) begin
                n_input_count = input_count + 1;
                n_input_store0[3]  = inputs[63:56];
                n_input_store1[4]  = inputs[55:48];
                n_input_store2[5]  = inputs[47:40];
                n_input_store3[6]  = inputs[39:32];
                n_input_store4[7]  = inputs[31:24];
                n_input_store5[8]  = inputs[23:16];
                n_input_store6[9]  = inputs[15:8];
                n_input_store7[10] = inputs[7:0];
            end
            else if(input_count==3'd4) begin
                n_input_count = input_count + 1;
                n_input_store0[4]  = inputs[63:56];
                n_input_store1[5]  = inputs[55:48];
                n_input_store2[6]  = inputs[47:40];
                n_input_store3[7]  = inputs[39:32];
                n_input_store4[8]  = inputs[31:24];
                n_input_store5[9]  = inputs[23:16];
                n_input_store6[10] = inputs[15:8];
                n_input_store7[11] = inputs[7:0];
            end
            else if(input_count==3'd5) begin
                n_input_count = input_count + 1;
                n_input_store0[5]  = inputs[63:56];
                n_input_store1[6]  = inputs[55:48];
                n_input_store2[7]  = inputs[47:40];
                n_input_store3[8]  = inputs[39:32];
                n_input_store4[9]  = inputs[31:24];
                n_input_store5[10] = inputs[23:16];
                n_input_store6[11] = inputs[15:8];
                n_input_store7[12] = inputs[7:0];
            end
            else if(input_count==3'd6) begin
                n_input_count = input_count + 1;
                n_input_store0[6]  = inputs[63:56];
                n_input_store1[7]  = inputs[55:48];
                n_input_store2[8]  = inputs[47:40];
                n_input_store3[9]  = inputs[39:32];
                n_input_store4[10] = inputs[31:24];
                n_input_store5[11] = inputs[23:16];
                n_input_store6[12] = inputs[15:8];
                n_input_store7[13] = inputs[7:0];
            end
            else if(input_count==3'd7) begin
                n_input_count = input_count + 1;
                n_input_store0[7]  = inputs[63:56];
                n_input_store1[8]  = inputs[55:48];
                n_input_store2[9]  = inputs[47:40];
                n_input_store3[10] = inputs[39:32];
                n_input_store4[11] = inputs[31:24];
                n_input_store5[12] = inputs[23:16];
                n_input_store6[13] = inputs[15:8];
                n_input_store7[14] = inputs[7:0];
            end

        end
    end

    //
    logic last_array_start;
    
    logic [4:0] n_load_count;
    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            load_count <= 0;
            last_array_start <= 0;
        end
        else begin
            load_count <= n_load_count;
            last_array_start <= array_start;
        end
    end

    always_comb begin
        n_load_count = load_count;
        for(int i = 0; i<8; i++)begin
            n_input0[i] = input0[i];
            n_input1[i] = input1[i];
            n_input2[i] = input2[i];
            n_input3[i] = input3[i];
            n_input4[i] = input4[i];
            n_input5[i] = input5[i];
            n_input6[i] = input6[i];
            n_input7[i] = input7[i];
        end
        if(last_array_start) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            if(load_count == 0) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[0];
            end

            else if(load_count == 1) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[1];
                n_input0[1] = input_store1[1];
            end

            else if(load_count == 2) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[2];
                n_input0[1] = input_store1[2]; 
                n_input0[2] = input_store2[2];
            end
            
            else if(load_count == 3) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[3];
                n_input0[1] = input_store1[3]; 
                n_input0[2] = input_store2[3];
                n_input0[3] = input_store3[3]; 
            end
            else if(load_count == 4) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[4];
                n_input0[1] = input_store1[4]; 
                n_input0[2] = input_store2[4];
                n_input0[3] = input_store3[4];
                n_input0[4] = input_store4[4];
            end
            else if(load_count == 5) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[5];
                n_input0[1] = input_store1[5]; 
                n_input0[2] = input_store2[5];
                n_input0[3] = input_store3[5];
                n_input0[4] = input_store4[5];
                n_input0[5] = input_store5[5];
            end
            else if(load_count == 6) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[6];
                n_input0[1] = input_store1[6]; 
                n_input0[2] = input_store2[6];
                n_input0[3] = input_store3[6];
                n_input0[4] = input_store4[6];
                n_input0[5] = input_store5[6];
                n_input0[6] = input_store6[6];
            end
            else if(load_count == 7) begin
                n_load_count = load_count + 1;
                n_input0[0] = input_store0[7];
                n_input0[1] = input_store1[7]; 
                n_input0[2] = input_store2[7];
                n_input0[3] = input_store3[7];
                n_input0[4] = input_store4[7];
                n_input0[5] = input_store5[7];
                n_input0[6] = input_store6[7];
                n_input0[7] = input_store7[7];
            end
        end
        if(load_count == 8) begin
             for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
            n_load_count = load_count + 1;
            n_input0[0] = input_store0[8];
            n_input0[1] = input_store1[8]; 
            n_input0[2] = input_store2[8];
            n_input0[3] = input_store3[8];
            n_input0[4] = input_store4[8];
            n_input0[5] = input_store5[8];
            n_input0[6] = input_store6[8];
            n_input0[7] = input_store7[8];
        end
        else if(load_count == 9) begin
             for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count = load_count + 1;
            n_input0[0] = input_store0[9];
            n_input0[1] = input_store1[9]; 
            n_input0[2] = input_store2[9];
            n_input0[3] = input_store3[9];
            n_input0[4] = input_store4[9];
            n_input0[5] = input_store5[9];
            n_input0[6] = input_store6[9];
            n_input0[7] = input_store7[9];
        end
        else if(load_count == 10) begin
             for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count = load_count + 1;
            n_input0[0] = input_store0[10];
            n_input0[1] = input_store1[10]; 
            n_input0[2] = input_store2[10];
            n_input0[3] = input_store3[10];
            n_input0[4] = input_store4[10];
            n_input0[5] = input_store5[10];
            n_input0[6] = input_store6[10];
            n_input0[7] = input_store7[10];
        end
        else if(load_count == 11) begin
             for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count = load_count + 1;
            n_input0[0] = input_store0[11];
            n_input0[1] = input_store1[11]; 
            n_input0[2] = input_store2[11];
            n_input0[3] = input_store3[11];
            n_input0[4] = input_store4[11];
            n_input0[5] = input_store5[11];
            n_input0[6] = input_store6[11];
            n_input0[7] = input_store7[11];
        end
        else if(load_count == 12) begin
             for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count = load_count + 1;
            n_input0[0] = input_store0[12];
            n_input0[1] = input_store1[12]; 
            n_input0[2] = input_store2[12];
            n_input0[3] = input_store3[12];
            n_input0[4] = input_store4[12];
            n_input0[5] = input_store5[12];
            n_input0[6] = input_store6[12];
            n_input0[7] = input_store7[12];
        end
        else if(load_count == 13) begin
             for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count = load_count + 1;
            n_input0[0] = input_store0[13];
            n_input0[1] = input_store1[13]; 
            n_input0[2] = input_store2[13];
            n_input0[3] = input_store3[13];
            n_input0[4] = input_store4[13];
            n_input0[5] = input_store5[13];
            n_input0[6] = input_store6[13];
            n_input0[7] = input_store7[13];
        end
        else if(load_count == 14) begin
             for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count = load_count + 1;
            n_input0[0] = input_store0[14];
            n_input0[1] = input_store1[14]; 
            n_input0[2] = input_store2[14];
            n_input0[3] = input_store3[14];
            n_input0[4] = input_store4[14];
            n_input0[5] = input_store5[14];
            n_input0[6] = input_store6[14];
            n_input0[7] = input_store7[14];
        end

        else if(load_count == 15) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =load_count + 1;
        end
        else if(load_count == 16) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =load_count + 1;
        end
        else if(load_count == 17) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =load_count + 1;
        end
        else if(load_count == 18) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =load_count + 1;
        end
        else if(load_count == 19) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =load_count + 1;
        end
        else if(load_count == 20) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =load_count + 1;
        end
        else if(load_count == 21) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =load_count + 1;
        end
        else if(load_count == 22) begin
            for(int i = 0; i<8; i++)begin
                n_input1[i] = input0[i];
                n_input2[i] = input1[i];
                n_input3[i] = input2[i];
                n_input4[i] = input3[i];
                n_input5[i] = input4[i];
                n_input6[i] = input5[i];
                n_input7[i] = input6[i];
            end
                
            n_load_count =0;
        end
    end
    
    
    logic [4:0] n_subsum7_count;
    always_ff @( posedge clk, negedge n_rst ) begin
        if(!n_rst)
            subsum7_count <= 0;
        else
            subsum7_count <= n_subsum7_count;
    end

    logic [7:0] real_subsum0 [7:0];
    logic [7:0] real_subsum1 [7:0];
    logic [7:0] real_subsum2 [7:0];
    logic [7:0] real_subsum3 [7:0];
    logic [7:0] real_subsum4 [7:0];
    logic [7:0] real_subsum5 [7:0];
    logic [7:0] real_subsum6 [7:0];
    logic [7:0] real_subsum7 [7:0];

    logic [7:0] n_real_subsum0 [7:0];
    logic [7:0] n_real_subsum1 [7:0];
    logic [7:0] n_real_subsum2 [7:0];
    logic [7:0] n_real_subsum3 [7:0];
    logic [7:0] n_real_subsum4 [7:0];
    logic [7:0] n_real_subsum5 [7:0];
    logic [7:0] n_real_subsum6 [7:0];
    logic [7:0] n_real_subsum7 [7:0];

    logic err, n_err;

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            for(int i = 0; i < 8; i++) begin
                err <= 0;
                real_subsum0[i] <= '0;
                real_subsum1[i] <= '0;
                real_subsum2[i] <= '0;
                real_subsum3[i] <= '0;
                real_subsum4[i] <= '0;
                real_subsum5[i] <= '0;
                real_subsum6[i] <= '0;
                real_subsum7[i] <= '0;
            end
        end
        else begin
            for(int i = 0; i < 8; i++) begin
                err <= n_err;
                real_subsum0[i] <= n_real_subsum0[i];
                real_subsum1[i] <= n_real_subsum1[i];
                real_subsum2[i] <= n_real_subsum2[i];
                real_subsum3[i] <= n_real_subsum3[i];
                real_subsum4[i] <= n_real_subsum4[i];
                real_subsum5[i] <= n_real_subsum5[i];
                real_subsum6[i] <= n_real_subsum6[i];
                real_subsum7[i] <= n_real_subsum7[i];
            end
        end
    end

    logic [16:0] reg0, reg2, reg3, reg4, reg5, reg6, reg7, reg1;
    //subsum logic
    always_comb begin
        n_err = err;
        n_subsum0 = subsum0;
        n_subsum1 = subsum1;
        n_subsum2 = subsum2;
        n_subsum3 = subsum3;
        n_subsum4 = subsum4;
        n_subsum5 = subsum5;
        n_subsum6 = subsum6;
        n_subsum7 = subsum7;

        n_real_subsum0 = real_subsum0;
        n_real_subsum1 = real_subsum1;
        n_real_subsum2 = real_subsum2;
        n_real_subsum3 = real_subsum3;
        n_real_subsum4 = real_subsum4;
        n_real_subsum5 = real_subsum5;
        n_real_subsum6 = real_subsum6;
        n_real_subsum7 = real_subsum7;

        n_output_store0  = output_store0;
        n_output_store1  = output_store1;
        n_output_store2  = output_store2;
        n_output_store3  = output_store3;
        n_output_store4  = output_store4;
        n_output_store5  = output_store5;
        n_output_store6  = output_store6;
        n_output_store7  = output_store7;
        n_output_store8  = output_store8;
        n_output_store9  = output_store9;
        n_output_store10 = output_store10;
        n_output_store11 = output_store11;
        n_output_store12 = output_store12;
        n_output_store13 = output_store13;
        n_output_store14 = output_store14;

        n_output0 = output0;
        n_output1 = output1;
        n_output2 = output2;
        n_output3 = output3;
        n_output4 = output4;
        n_output5 = output5;
        n_output6 = output6;
        n_output7 = output7;

        n_subsum7_count = subsum7_count;

        // load_count >= 1
        if(load_count >= 1) begin
            n_subsum0[7] = input0[0] * weight0[7];

            reg0 = input0[0] * weight0[7];
            if(|reg0[16:8]) n_err = 1;

            if(load_count != n_load_count)
                n_real_subsum0[7] = n_subsum0[7];
        end

        // load_count >= 2
        if(load_count >= 2) begin
            n_subsum0[6] = input1[0] * weight0[6];
            n_subsum1[7] = real_subsum0[7] + input0[1] * weight1[7];

            reg0 = input1[0] * weight0[6];
            reg1 = real_subsum0[7] + input0[1] * weight1[7];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum0[6] = n_subsum0[6];
                n_real_subsum1[7] = n_subsum1[7];
            end
        end

        // load_count >= 3
        if(load_count >= 3) begin
            n_subsum0[5] = input2[0] * weight0[5];
            n_subsum1[6] = real_subsum0[6] + input1[1] * weight1[6];
            n_subsum2[7] = real_subsum1[7] + input0[2] * weight2[7];

            // overflow checks
            reg0 = input2[0] * weight0[5];
            if(|reg0[16:8]) n_err = 1;

            reg1 = real_subsum0[6] + input1[1] * weight1[6];
            if(|reg1[16:8]) n_err = 1;

            reg2 = real_subsum1[7] + input0[2] * weight2[7];
            if(|reg2[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum0[5] = n_subsum0[5];
                n_real_subsum1[6] = n_subsum1[6];
                n_real_subsum2[7] = n_subsum2[7];
            end
        end


        // load_count >= 4
        if(load_count >= 4) begin
            // arithmetic
            n_subsum0[4] = input3[0] * weight0[4];
            n_subsum1[5] = real_subsum0[5] + input2[1] * weight1[5];
            n_subsum2[6] = real_subsum1[6] + input1[2] * weight2[6];
            n_subsum3[7] = real_subsum2[7] + input0[3] * weight3[7];

            // overflow checks
            reg0 = input3[0] * weight0[4];
            if(|reg0[16:8]) n_err = 1;

            reg1 = real_subsum0[5] + input2[1] * weight1[5];
            if(|reg1[16:8]) n_err = 1;

            reg2 = real_subsum1[6] + input1[2] * weight2[6];
            if(|reg2[16:8]) n_err = 1;

            reg3 = real_subsum2[7] + input0[3] * weight3[7];
            if(|reg3[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum0[4] = n_subsum0[4];
                n_real_subsum1[5] = n_subsum1[5];
                n_real_subsum2[6] = n_subsum2[6];
                n_real_subsum3[7] = n_subsum3[7];
            end
        end

        // load_count >= 5
        if(load_count >= 5) begin
            n_subsum0[3] = input4[0] * weight0[3];
            n_subsum1[4] = real_subsum0[4] + input3[1] * weight1[4];
            n_subsum2[5] = real_subsum1[5] + input2[2] * weight2[5];
            n_subsum3[6] = real_subsum2[6] + input1[3] * weight3[6];
            n_subsum4[7] = real_subsum3[7] + input0[4] * weight4[7];

            reg0 = input4[0] * weight0[3];
            if(|reg0[16:8]) n_err = 1;

            reg1 = real_subsum0[4] + input3[1] * weight1[4];
            if(|reg1[16:8]) n_err = 1;

            reg2 = real_subsum1[5] + input2[2] * weight2[5];
            if(|reg2[16:8]) n_err = 1;

            reg3 = real_subsum2[6] + input1[3] * weight3[6];
            if(|reg3[16:8]) n_err = 1;

            reg4 = real_subsum3[7] + input0[4] * weight4[7];
            if(|reg4[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum0[3] = n_subsum0[3];
                n_real_subsum1[4] = n_subsum1[4];
                n_real_subsum2[5] = n_subsum2[5];
                n_real_subsum3[6] = n_subsum3[6];
                n_real_subsum4[7] = n_subsum4[7];
            end
        end

        // load_count >= 6
        if(load_count >= 6) begin
            n_subsum0[2] = input5[0] * weight0[2];
            n_subsum1[3] = real_subsum0[3] + input4[1] * weight1[3];
            n_subsum2[4] = real_subsum1[4] + input3[2] * weight2[4];
            n_subsum3[5] = real_subsum2[5] + input2[3] * weight3[5];
            n_subsum4[6] = real_subsum3[6] + input1[4] * weight4[6];
            n_subsum5[7] = real_subsum4[7] + input0[5] * weight5[7];

            // overflow checks
            reg0 = input5[0] * weight0[2];
            reg1 = real_subsum0[3] + input4[1] * weight1[3];
            reg2 = real_subsum1[4] + input3[2] * weight2[4];
            reg3 = real_subsum2[5] + input2[3] * weight3[5];
            reg4 = real_subsum3[6] + input1[4] * weight4[6];
            reg5 = real_subsum4[7] + input0[5] * weight5[7];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;
            if(|reg3[16:8]) n_err = 1;
            if(|reg4[16:8]) n_err = 1;
            if(|reg5[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum0[2] = n_subsum0[2];
                n_real_subsum1[3] = n_subsum1[3];
                n_real_subsum2[4] = n_subsum2[4];
                n_real_subsum3[5] = n_subsum3[5];
                n_real_subsum4[6] = n_subsum4[6];
                n_real_subsum5[7] = n_subsum5[7];
            end
        end

        // load_count >= 7
        if(load_count >= 7) begin
            n_subsum0[1] = input6[0] * weight0[1];
            n_subsum1[2] = real_subsum0[2] + input5[1] * weight1[2];
            n_subsum2[3] = real_subsum1[3] + input4[2] * weight2[3];
            n_subsum3[4] = real_subsum2[4] + input3[3] * weight3[4];
            n_subsum4[5] = real_subsum3[5] + input2[4] * weight4[5];
            n_subsum5[6] = real_subsum4[6] + input1[5] * weight5[6];
            n_subsum6[7] = real_subsum5[7] + input0[6] * weight6[7];

            // overflow checks
            reg0 = input6[0] * weight0[1];
            reg1 = real_subsum0[2] + input5[1] * weight1[2];
            reg2 = real_subsum1[3] + input4[2] * weight2[3];
            reg3 = real_subsum2[4] + input3[3] * weight3[4];
            reg4 = real_subsum3[5] + input2[4] * weight4[5];
            reg5 = real_subsum4[6] + input1[5] * weight5[6];
            reg6 = real_subsum5[7] + input0[6] * weight6[7];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;
            if(|reg3[16:8]) n_err = 1;
            if(|reg4[16:8]) n_err = 1;
            if(|reg5[16:8]) n_err = 1;
            if(|reg6[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum0[1] = n_subsum0[1];
                n_real_subsum1[2] = n_subsum1[2];
                n_real_subsum2[3] = n_subsum2[3];
                n_real_subsum3[4] = n_subsum3[4];
                n_real_subsum4[5] = n_subsum4[5];
                n_real_subsum5[6] = n_subsum5[6];
                n_real_subsum6[7] = n_subsum6[7];
            end
        end

        // load_count >= 8
        if(load_count >= 8) begin
            n_subsum0[0] = input7[0] * weight0[0];
            n_subsum1[1] = real_subsum0[1] + input6[1] * weight1[1];
            n_subsum2[2] = real_subsum1[2] + input5[2] * weight2[2];
            n_subsum3[3] = real_subsum2[3] + input4[3] * weight3[3];
            n_subsum4[4] = real_subsum3[4] + input3[4] * weight4[4];
            n_subsum5[5] = real_subsum4[5] + input2[5] * weight5[5];
            n_subsum6[6] = real_subsum5[6] + input1[6] * weight6[6];
            n_subsum7[7] = real_subsum6[7] + input0[7] * weight7[7];

            // overflow checks
            reg0 = input7[0] * weight0[0];
            reg1 = real_subsum0[1] + input6[1] * weight1[1];
            reg2 = real_subsum1[2] + input5[2] * weight2[2];
            reg3 = real_subsum2[3] + input4[3] * weight3[3];
            reg4 = real_subsum3[4] + input3[4] * weight4[4];
            reg5 = real_subsum4[5] + input2[5] * weight5[5];
            reg6 = real_subsum5[6] + input1[6] * weight6[6];
            reg7 = real_subsum6[7] + input0[7] * weight7[7];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;
            if(|reg3[16:8]) n_err = 1;
            if(|reg4[16:8]) n_err = 1;
            if(|reg5[16:8]) n_err = 1;
            if(|reg6[16:8]) n_err = 1;
            if(|reg7[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum0[0] = n_subsum0[0];
                n_real_subsum1[1] = n_subsum1[1];
                n_real_subsum2[2] = n_subsum2[2];
                n_real_subsum3[3] = n_subsum3[3];
                n_real_subsum4[4] = n_subsum4[4];
                n_real_subsum5[5] = n_subsum5[5];
                n_real_subsum6[6] = n_subsum6[6];
                n_real_subsum7[7] = n_subsum7[7];
            end
        end

        if(load_count == 9) begin
            for(int i = 0; i<8; i++) begin
                n_output_store0[i] = real_subsum7[i];
            end
        end

        // load_count >= 9
        if(load_count >= 9) begin
            n_subsum7_count = subsum7_count + 1;
            n_subsum1[0] = real_subsum0[0] + input7[1] * weight1[0];
            n_subsum2[1] = real_subsum1[1] + input6[2] * weight2[1];
            n_subsum3[2] = real_subsum2[2] + input5[3] * weight3[2];
            n_subsum4[3] = real_subsum3[3] + input4[4] * weight4[3];
            n_subsum5[4] = real_subsum4[4] + input3[5] * weight5[4];
            n_subsum6[5] = real_subsum5[5] + input2[6] * weight6[5];
            n_subsum7[6] = real_subsum6[6] + input1[7] * weight7[6];

            // overflow checks
            reg0 = real_subsum0[0] + input7[1] * weight1[0];
            reg1 = real_subsum1[1] + input6[2] * weight2[1];
            reg2 = real_subsum2[2] + input5[3] * weight3[2];
            reg3 = real_subsum3[3] + input4[4] * weight4[3];
            reg4 = real_subsum4[4] + input3[5] * weight5[4];
            reg5 = real_subsum5[5] + input2[6] * weight6[5];
            reg6 = real_subsum6[6] + input1[7] * weight7[6];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;
            if(|reg3[16:8]) n_err = 1;
            if(|reg4[16:8]) n_err = 1;
            if(|reg5[16:8]) n_err = 1;
            if(|reg6[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum1[0] = n_subsum1[0];
                n_real_subsum2[1] = n_subsum2[1];
                n_real_subsum3[2] = n_subsum3[2];
                n_real_subsum4[3] = n_subsum4[3];
                n_real_subsum5[4] = n_subsum5[4];
                n_real_subsum6[5] = n_subsum6[5];
                n_real_subsum7[6] = n_subsum7[6];
            end
        end

        if(load_count == 10) begin
            for(int i = 0; i<8; i++) begin
                n_output_store1[i] = real_subsum7[i];
            end
        end

        // load_count >= 10
        if(load_count >= 10) begin

            n_output0[7] = output_store0[7];

            n_subsum7_count = subsum7_count + 1;
            n_subsum2[0] = real_subsum1[0] + input7[2] * weight2[0];
            n_subsum3[1] = real_subsum2[1] + input6[3] * weight3[1];
            n_subsum4[2] = real_subsum3[2] + input5[4] * weight4[2];
            n_subsum5[3] = real_subsum4[3] + input4[5] * weight5[3];
            n_subsum6[4] = real_subsum5[4] + input3[6] * weight6[4];
            n_subsum7[5] = real_subsum6[5] + input2[7] * weight7[5];

            // overflow checks
            reg0 = real_subsum1[0] + input7[2] * weight2[0];
            reg1 = real_subsum2[1] + input6[3] * weight3[1];
            reg2 = real_subsum3[2] + input5[4] * weight4[2];
            reg3 = real_subsum4[3] + input4[5] * weight5[3];
            reg4 = real_subsum5[4] + input3[6] * weight6[4];
            reg5 = real_subsum6[5] + input2[7] * weight7[5];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;
            if(|reg3[16:8]) n_err = 1;
            if(|reg4[16:8]) n_err = 1;
            if(|reg5[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum2[0] = n_subsum2[0];
                n_real_subsum3[1] = n_subsum3[1];
                n_real_subsum4[2] = n_subsum4[2];
                n_real_subsum5[3] = n_subsum5[3];
                n_real_subsum6[4] = n_subsum6[4];
                n_real_subsum7[5] = n_subsum7[5];
            end
        end

        if(load_count == 11) begin
            for(int i = 0; i<8; i++) begin
                n_output_store2[i] = real_subsum7[i];
            end
        end

        // load_count >= 11
        if(load_count >= 11) begin

            n_output0[6] = output_store1[6];
            n_output1[7] = output_store1[7];

            n_subsum7_count = subsum7_count + 1;
            n_subsum3[0] = real_subsum2[0] + input7[3] * weight3[0];
            n_subsum4[1] = real_subsum3[1] + input6[4] * weight4[1];
            n_subsum5[2] = real_subsum4[2] + input5[5] * weight5[2];
            n_subsum6[3] = real_subsum5[3] + input4[6] * weight6[3];
            n_subsum7[4] = real_subsum6[4] + input3[7] * weight7[4];

            // overflow checks
            reg0 = real_subsum2[0] + input7[3] * weight3[0];
            reg1 = real_subsum3[1] + input6[4] * weight4[1];
            reg2 = real_subsum4[2] + input5[5] * weight5[2];
            reg3 = real_subsum5[3] + input4[6] * weight6[3];
            reg4 = real_subsum6[4] + input3[7] * weight7[4];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;
            if(|reg3[16:8]) n_err = 1;
            if(|reg4[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum3[0] = n_subsum3[0];
                n_real_subsum4[1] = n_subsum4[1];
                n_real_subsum5[2] = n_subsum5[2];
                n_real_subsum6[3] = n_subsum6[3];
                n_real_subsum7[4] = n_subsum7[4];
            end
        end

        if(load_count == 12) begin
            for(int i = 0; i<8; i++) begin
                n_output_store3[i] = real_subsum7[i];
            end
        end

        // load_count >= 12
        if(load_count >= 12) begin

            n_output0[5] = output_store2[5];
            n_output1[6] = output_store2[6];
            n_output2[7] = output_store2[7];

            n_subsum7_count = subsum7_count + 1;
            n_subsum4[0] = real_subsum3[0] + input7[4] * weight4[0];
            n_subsum5[1] = real_subsum4[1] + input6[5] * weight5[1];
            n_subsum6[2] = real_subsum5[2] + input5[6] * weight6[2];
            n_subsum7[3] = real_subsum6[3] + input4[7] * weight7[3];

            // overflow checks
            reg0 = real_subsum3[0] + input7[4] * weight4[0];
            reg1 = real_subsum4[1] + input6[5] * weight5[1];
            reg2 = real_subsum5[2] + input5[6] * weight6[2];
            reg3 = real_subsum6[3] + input4[7] * weight7[3];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;
            if(|reg3[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum4[0] = n_subsum4[0];
                n_real_subsum5[1] = n_subsum5[1];
                n_real_subsum6[2] = n_subsum6[2];
                n_real_subsum7[3] = n_subsum7[3];
            end
        end

        if(load_count == 13) begin
            for(int i = 0; i<8; i++) begin
                n_output_store4[i] = real_subsum7[i];
            end
        end

        // load_count >= 13
        if(load_count >= 13) begin

            n_output0[4] = output_store3[4];
            n_output1[5] = output_store3[5];
            n_output2[6] = output_store3[6];
            n_output3[7] = output_store3[7];

            n_subsum7_count = subsum7_count + 1;
            n_subsum5[0] = real_subsum4[0] + input7[5] * weight5[0];
            n_subsum6[1] = real_subsum5[1] + input6[6] * weight6[1];
            n_subsum7[2] = real_subsum6[2] + input5[7] * weight7[2];

            // overflow checks
            reg0 = real_subsum4[0] + input7[5] * weight5[0];
            reg1 = real_subsum5[1] + input6[6] * weight6[1];
            reg2 = real_subsum6[2] + input5[7] * weight7[2];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;
            if(|reg2[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum5[0] = n_subsum5[0];
                n_real_subsum6[1] = n_subsum6[1];
                n_real_subsum7[2] = n_subsum7[2];
            end
        end

        if(load_count == 14) begin
            for(int i = 0; i<8; i++) begin
                n_output_store5[i] = real_subsum7[i];
            end
        end

        // load_count >= 14
        if(load_count >= 14) begin

            n_output0[3] = output_store4[3];
            n_output1[4] = output_store4[4];
            n_output2[5] = output_store4[5];
            n_output3[6] = output_store4[6];
            n_output4[7] = output_store4[7];

            n_subsum7_count = subsum7_count + 1;
            n_subsum6[0] = real_subsum5[0] + input7[6] * weight6[0];
            n_subsum7[1] = real_subsum6[1] + input6[7] * weight7[1];

            // overflow checks
            reg0 = real_subsum5[0] + input7[6] * weight6[0];
            reg1 = real_subsum6[1] + input6[7] * weight7[1];
            if(|reg0[16:8]) n_err = 1;
            if(|reg1[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum6[0] = n_subsum6[0];
                n_real_subsum7[1] = n_subsum7[1];
            end
        end

        if(load_count == 15) begin
            for(int i = 0; i<8; i++) begin
                n_output_store6[i] = real_subsum7[i];
            end
        end

        // load_count >= 15
        if(load_count >= 15) begin

            n_output0[2] = output_store5[2];
            n_output1[3] = output_store5[3];
            n_output2[4] = output_store5[4];
            n_output3[5] = output_store5[5];
            n_output4[6] = output_store5[6];
            n_output5[7] = output_store5[7];

            n_subsum7_count = subsum7_count + 1;
            n_subsum7[0] = real_subsum6[0] + input7[7] * weight7[0];

            // overflow check
            reg0 = real_subsum6[0] + input7[7] * weight7[0];
            if(|reg0[16:8]) n_err = 1;

            if(load_count != n_load_count) begin
                n_real_subsum7[0] = n_subsum7[0];
            end
        end



        if(subsum7_count == 7) begin
            n_subsum7_count = subsum7_count + 1;

            n_output0[1] = output_store6[1];
            n_output1[2] = output_store6[2];
            n_output2[3] = output_store6[3];
            n_output3[4] = output_store6[4];
            n_output4[5] = output_store6[5];
            n_output5[6] = output_store6[6];
            n_output6[7] = output_store6[7];

            for(int i = 0; i<8; i++)begin
                n_output_store7[i] = subsum7[i];
            end
        end

        if(subsum7_count == 8) begin
            n_subsum7_count = subsum7_count + 1;

            n_output0[0] = output_store7[0];
            n_output1[1] = output_store7[1];
            n_output2[2] = output_store7[2];
            n_output3[3] = output_store7[3];
            n_output4[4] = output_store7[4];
            n_output5[5] = output_store7[5];
            n_output6[6] = output_store7[6];
            n_output7[7] = output_store7[7];

            for(int i = 0; i<8; i++)begin
                n_output_store8[i] = subsum7[i];
            end
        end

        if(subsum7_count == 9) begin
            n_subsum7_count = subsum7_count + 1;

            n_output1[0] = output_store8[0];
            n_output2[1] = output_store8[1];
            n_output3[2] = output_store8[2];
            n_output4[3] = output_store8[3];
            n_output5[4] = output_store8[4];
            n_output6[5] = output_store8[5];
            n_output7[6] = output_store8[6];

            for(int i = 0; i<8; i++)begin
                n_output_store9[i] = subsum7[i];
            end

        end

        if(subsum7_count == 10) begin
            n_subsum7_count = subsum7_count + 1;

            n_output2[0] = output_store9[0];
            n_output3[1] = output_store9[1];
            n_output4[2] = output_store9[2];
            n_output5[3] = output_store9[3];
            n_output6[4] = output_store9[4];
            n_output7[5] = output_store9[5];

            for(int i = 0; i<8; i++)begin
                n_output_store10[i] = subsum7[i];
            end
        end

        if(subsum7_count == 11) begin
            n_subsum7_count = subsum7_count + 1;

            n_output3[0] = output_store10[0];
            n_output4[1] = output_store10[1];
            n_output5[2] = output_store10[2];
            n_output6[3] = output_store10[3];
            n_output7[4] = output_store10[4];

            for(int i = 0; i<8; i++)begin
                n_output_store11[i] = subsum7[i];
            end
        end

        if(subsum7_count == 12) begin
            n_subsum7_count = subsum7_count + 1;

            n_output4[0] = output_store11[0];
            n_output5[1] = output_store11[1];
            n_output6[2] = output_store11[2];
            n_output7[3] = output_store11[3];

            for(int i = 0; i<8; i++)begin
                n_output_store12[i] = subsum7[i];
            end
        end

        if(subsum7_count == 13) begin
            n_subsum7_count = subsum7_count + 1;

            n_output5[0] = output_store12[0];
            n_output6[1] = output_store12[1];
            n_output7[2] = output_store12[2];

            for(int i = 0; i<8; i++)begin
                n_output_store13[i] = subsum7[i];
            end
        end

        if(subsum7_count == 14) begin
            n_subsum7_count = subsum7_count + 1;

            n_output6[0] = output_store13[0];
            n_output7[1] = output_store13[1];

            for(int i = 0; i<8; i++)begin
                n_output_store14[i] = subsum7[i];
            end
        end

        if(subsum7_count == 15) begin
            n_output7[0] = output_store14[0];
            n_subsum7_count = 0;
        end

    end

    //outputs
    typedef enum logic [4:0] {
        IDLE,           //000
        SEND_1,       //001
        SEND_1_WAIT,
        SEND_2,
        SEND_2_WAIT,  //010
        SEND_3,      //011
        SEND_3_WAIT,
        SEND_4, //100
        SEND_4_WAIT,
        SEND_5,       //101
        SEND_5_WAIT,
        SEND_6,
        SEND_6_WAIT,
        SEND_7,
        SEND_7_WAIT,
        SEND_8,   //110
        SEND_8_WAIT
    } state_t;

    state_t state, next_state;

    always_comb begin
        activations_valid = 0;
        outputs = '0;
        next_state = state;
        case (state)
        IDLE: begin
            if (subsum7_count>=8 && !err) 
                next_state = SEND_1;
        end
        SEND_1: begin
            activations_valid = 1;
            if (!design_busy)
                next_state = SEND_1_WAIT;
        end
        SEND_1_WAIT: begin
            outputs[7:0]   = output0[0];
            outputs[15:8]  = output0[1];
            outputs[23:16] = output0[2];
            outputs[31:24] = output0[3];
            outputs[39:32] = output0[4];
            outputs[47:40] = output0[5];
            outputs[55:48] = output0[6];
            outputs[63:56] = output0[7];
            activations_valid = 0;
            next_state = SEND_2;
        end
        SEND_2: begin
            outputs[7:0]   = output0[0];
            outputs[15:8]  = output0[1];
            outputs[23:16] = output0[2];
            outputs[31:24] = output0[3];
            outputs[39:32] = output0[4];
            outputs[47:40] = output0[5];
            outputs[55:48] = output0[6];
            outputs[63:56] = output0[7];
            activations_valid = 1;
            if (!design_busy) 
                next_state = SEND_2_WAIT;
        end
        SEND_2_WAIT: begin
            outputs[7:0]   = output1[0];
            outputs[15:8]  = output1[1];
            outputs[23:16] = output1[2];
            outputs[31:24] = output1[3];
            outputs[39:32] = output1[4];
            outputs[47:40] = output1[5];
            outputs[55:48] = output1[6];
            outputs[63:56] = output1[7];
            activations_valid = 0;
            next_state = SEND_3;
        end
        SEND_3: begin
            outputs[7:0]   = output1[0];
            outputs[15:8]  = output1[1];
            outputs[23:16] = output1[2];
            outputs[31:24] = output1[3];
            outputs[39:32] = output1[4];
            outputs[47:40] = output1[5];
            outputs[55:48] = output1[6];
            outputs[63:56] = output1[7];
            activations_valid = 1;
            if (!design_busy) 
                next_state = SEND_3_WAIT;
        end
        SEND_3_WAIT: begin
            outputs[7:0]   = output2[0];
            outputs[15:8]  = output2[1];
            outputs[23:16] = output2[2];
            outputs[31:24] = output2[3];
            outputs[39:32] = output2[4];
            outputs[47:40] = output2[5];
            outputs[55:48] = output2[6];
            outputs[63:56] = output2[7];
            activations_valid = 0;
            next_state = SEND_4;
        end
        SEND_4: begin
            outputs[7:0]   = output2[0];
            outputs[15:8]  = output2[1];
            outputs[23:16] = output2[2];
            outputs[31:24] = output2[3];
            outputs[39:32] = output2[4];
            outputs[47:40] = output2[5];
            outputs[55:48] = output2[6];
            outputs[63:56] = output2[7];
            activations_valid = 1;
            if (!design_busy)
                next_state = SEND_4_WAIT;
        end
        SEND_4_WAIT: begin
            outputs[7:0]   = output3[0];
            outputs[15:8]  = output3[1];
            outputs[23:16] = output3[2];
            outputs[31:24] = output3[3];
            outputs[39:32] = output3[4];
            outputs[47:40] = output3[5];
            outputs[55:48] = output3[6];
            outputs[63:56] = output3[7];
            activations_valid = 0;
            next_state = SEND_5;
        end
        SEND_5: begin
            outputs[7:0]   = output3[0];
            outputs[15:8]  = output3[1];
            outputs[23:16] = output3[2];
            outputs[31:24] = output3[3];
            outputs[39:32] = output3[4];
            outputs[47:40] = output3[5];
            outputs[55:48] = output3[6];
            outputs[63:56] = output3[7];
            activations_valid = 1;
            if (!design_busy)
                next_state = SEND_5_WAIT;
        end
        SEND_5_WAIT: begin
            outputs[7:0]   = output4[0];
            outputs[15:8]  = output4[1];
            outputs[23:16] = output4[2];
            outputs[31:24] = output4[3];
            outputs[39:32] = output4[4];
            outputs[47:40] = output4[5];
            outputs[55:48] = output4[6];
            outputs[63:56] = output4[7];
            activations_valid = 0;
            next_state = SEND_6;
        end
        SEND_6: begin
            outputs[7:0]   = output4[0];
            outputs[15:8]  = output4[1];
            outputs[23:16] = output4[2];
            outputs[31:24] = output4[3];
            outputs[39:32] = output4[4];
            outputs[47:40] = output4[5];
            outputs[55:48] = output4[6];
            outputs[63:56] = output4[7];
            activations_valid = 1;
            if (!design_busy)
                next_state = SEND_6_WAIT;
        end
        SEND_6_WAIT: begin
            outputs[7:0]   = output5[0];
            outputs[15:8]  = output5[1];
            outputs[23:16] = output5[2];
            outputs[31:24] = output5[3];
            outputs[39:32] = output5[4];
            outputs[47:40] = output5[5];
            outputs[55:48] = output5[6];
            outputs[63:56] = output5[7];
            activations_valid = 0;
            next_state = SEND_7;
        end
        SEND_7: begin
            outputs[7:0]   = output5[0];
            outputs[15:8]  = output5[1];
            outputs[23:16] = output5[2];
            outputs[31:24] = output5[3];
            outputs[39:32] = output5[4];
            outputs[47:40] = output5[5];
            outputs[55:48] = output5[6];
            outputs[63:56] = output5[7];
            activations_valid = 1;
            if (!design_busy)
                next_state = SEND_7_WAIT;
        end
        SEND_7_WAIT: begin
            outputs[7:0]   = output6[0];
            outputs[15:8]  = output6[1];
            outputs[23:16] = output6[2];
            outputs[31:24] = output6[3];
            outputs[39:32] = output6[4];
            outputs[47:40] = output6[5];
            outputs[55:48] = output6[6];
            outputs[63:56] = output6[7];
            activations_valid = 0;
            next_state = SEND_8;
        end
        SEND_8: begin
            outputs[7:0]   = output6[0];
            outputs[15:8]  = output6[1];
            outputs[23:16] = output6[2];
            outputs[31:24] = output6[3];
            outputs[39:32] = output6[4];
            outputs[47:40] = output6[5];
            outputs[55:48] = output6[6];
            outputs[63:56] = output6[7];
            activations_valid = 1;
            if (!design_busy)
                next_state = SEND_8_WAIT;
        end
        SEND_8_WAIT: begin
            outputs[7:0]   = output7[0];
            outputs[15:8]  = output7[1];
            outputs[23:16] = output7[2];
            outputs[31:24] = output7[3];
            outputs[39:32] = output7[4];
            outputs[47:40] = output7[5];
            outputs[55:48] = output7[6];
            outputs[63:56] = output7[7];
            activations_valid = 0;
            if (!design_busy)
                next_state = IDLE;
        end
        endcase
    end

    always_ff @( posedge clk, negedge n_rst ) begin 
        if (!n_rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end


    
    

    



endmodule

