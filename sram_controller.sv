`timescale 1ns / 10ps

module sram_controller #(
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

    // SRAM 
    input  logic [31:0] sram_read_data,
    input  logic [1:0]  sram_state,

    output logic        sram_read_en,
    output logic        sram_write_en,
    output logic [31:0] sram_write_data,
    output logic [9:0]  sram_addr,

    // systolic array 
    input  logic        array_busy,

    output logic        array_start,  
    output logic        load,
    output logic [63:0] inputs,

    // activation
    input  logic [63:0] activations,
    input  logic        activations_valid
);

    // Weight signals
    logic        n_weight_write_flag;
    logic        n_weight_read_flag;
    logic [8:0]  n_weight_write_count;
    logic [8:0]  n_weight_read_count;

    logic        weight_write_flag;
    logic        weight_read_flag;
    logic [8:0]  weight_write_count;
    logic [8:0]  weight_read_count;


    // Input signals
    logic        n_input_write_flag;
    logic        n_input_read_flag;
    logic [8:0]  n_input_write_count;
    logic [8:0]  n_input_read_count;

    logic        input_write_flag;
    logic        input_read_flag;
    logic [8:0]  input_write_count;
    logic [8:0]  input_read_count;

    // Output signals
    logic        n_output_write_flag;
    logic        n_output_read_flag;
    logic [8:0]  n_output_write_count;
    logic [8:0]  n_output_read_count;

    logic        output_write_flag;
    logic        output_read_flag;
    logic [8:0]  output_write_count;
    logic [8:0]  output_read_count;

    //read data
    logic [63:0] n_inputs;
    logic [63:0] n_output_data;

    // Byte count
    logic [3:0] output_count;
    logic [3:0] input_count;
    logic [3:0] weight_count;
    logic [3:0] n_input_count;
    logic [3:0] n_weight_count;
    logic [3:0] n_output_count;

    //empty full signals
    logic weight_empty;
    logic input_empty;
    logic output_empty;
    logic weight_full;
    logic input_full;
    logic output_full;

    localparam WEIGHTBASE = 10'd0;
    localparam INPUTBASE = 10'd336;
    localparam OUTPUTBASE = 10'd672;

typedef enum logic [5:0] {
    IDLE,

    // weight loading 
    WEIGHT_BYTE_INCR,
    LOAD_WEIGHT_H,
    WEIGHT_READ_SEC_INCR,
    WAIT_LOAD_WEIGHT_H,
    LOAD_WEIGHT_L,
    WEIGHT_READ_FIR_INCR,
    WAIT_LOAD_WEIGHT_L,

    // WEIGHT WRITE
    WEIGHT_WRITE_SEC_INCR,
    WRITE_WEIGHT_H,
    WAIT_WRITE_WEIGHT_H,
    WEIGHT_WRITE_FIR_INCR,
    WRITE_WEIGHT_L,
    WAIT_WRITE_WEIGHT_L,

    // output write / read
    OUTPUT_WRITE_SEC_INCR,
    WRITE_OUTPUT_H,
    WAIT_WRITE_OUTPUT_H,
    OUTPUT_WRITE_FIR_INCR,
    WRITE_OUTPUT_L,
    WAIT_WRITE_OUTPUT_L,

    OUTPUT_READ_SEC_INCR,
    WAIT_READ_OUTPUT_L,
    READ_OUTPUT_L,
    OUTPUT_READ_FIR_INCR,
    WAIT_READ_OUTPUT_H,
    READ_OUTPUT_H,

    // input write
    INPUT_WRITE_SEC_INCR,
    WRITE_INPUT_H,
    WAIT_WRITE_INPUT_H,
    INPUT_WRITE_FIR_INCR,
    WRITE_INPUT_L,
    WAIT_WRITE_INPUT_L,

    // input load / inference start
    INPUT_BYTE_INCR,
    INPUT_READ_SEC_INCR,
    LOAD_INPUT_H,
    WAIT_LOAD_INPUT_H,
    INPUT_READ_FIR_INCR,
    LOAD_INPUT_L,
    WAIT_LOAD_INPUT_L,

    // done + errors
    INF_DONE,
    BUSY_ERROR,
    BUSY_ERR,
    OCCU_WEIGHT_ERROR,
    OCCU_WEIGHT_ERR,
    OCCU_INPUT_ERROR,
    OCCU_INPUT_ERR,
    OCCU_OUTPUT_ERROR,
    OCCU_OUTPUT_ERR

} state_t;

state_t state, next_state;


always_ff @( posedge clk, negedge n_rst ) begin : state_ff
    if(!n_rst)
        state <= IDLE;
    else 
        state <= next_state;
end

always_ff @( posedge clk, negedge n_rst ) begin : count_ff
    if(!n_rst) begin
        input_write_count <= 0;
        input_read_count <= 0;
        weight_write_count <= 0;
        weight_read_count <= 0;
        output_write_count <= 0;
        output_read_count <= 0;

        output_count <= 0;
        weight_count <= 0;
        input_count <= 0;    
    end
    else begin
        input_write_count <= n_input_write_count;
        input_read_count <= n_input_read_count;
        weight_write_count <= n_weight_write_count;
        weight_read_count <= n_weight_read_count;
        output_write_count <= n_output_write_count;
        output_read_count <= n_output_read_count;
        weight_count <= n_weight_count;
        input_count <= n_input_count;
        output_count <= n_output_count;
    end
end

always_ff @(posedge clk, negedge n_rst) begin : flag_ff
    if(!n_rst) begin
        weight_write_flag <= 0;
        weight_read_flag <= 0;
        input_write_flag <= 0;
        input_read_flag <= 0;
        output_write_flag <= 0;
        output_read_flag <= 0;
    end
    else begin
        weight_write_flag <= n_weight_write_flag;
        weight_read_flag <= n_weight_read_flag;
        input_write_flag <= n_input_write_flag;
        input_read_flag <= n_input_read_flag;
        output_write_flag <= n_output_write_flag;
        output_read_flag <= n_output_read_flag;
    end
end

always_ff @( posedge clk, negedge n_rst ) begin : read_data_ff
    if(!n_rst) begin
        inputs <= 0;
        output_data <= 0;
    end
    else begin
        inputs <= n_inputs;
        output_data <= n_output_data;
    end
end


always_comb begin : nextstate_logic
    next_state = state;
    case (state)
    IDLE: begin
        if (load_weight) //weight
            next_state = WAIT_LOAD_WEIGHT_L;
        else if (write_weight) //weight
            next_state = WAIT_WRITE_WEIGHT_L;
        else if (start_inference) //input
            next_state = WAIT_LOAD_INPUT_L;
        else if (write_input) //input
            next_state = WAIT_WRITE_INPUT_L;
        else if (activations_valid) //output
            next_state = WAIT_WRITE_OUTPUT_L;
        else if (output_read)
            next_state = WAIT_READ_OUTPUT_L;
    end

    //  WEIGHT LOAD PATH
    WAIT_LOAD_WEIGHT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR;
        else if(weight_empty)
            next_state = OCCU_WEIGHT_ERROR;
        else if (sram_state == 2'd0 && !array_busy)
            next_state = LOAD_WEIGHT_L;
    end
    LOAD_WEIGHT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if(sram_state == 2'd2)
            next_state = WEIGHT_READ_FIR_INCR;
    end
    WEIGHT_READ_FIR_INCR: begin
        next_state = WAIT_LOAD_WEIGHT_H;
    end
    WAIT_LOAD_WEIGHT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR;
        else if(weight_empty)
            next_state = OCCU_WEIGHT_ERROR;
        else if (sram_state == 2'd0 && !array_busy)
            next_state = LOAD_WEIGHT_H;
    end
    LOAD_WEIGHT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if (sram_state == 2'd2)
            next_state = WEIGHT_READ_SEC_INCR;  // kicked off high-word read
    end
    WEIGHT_READ_SEC_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = WEIGHT_BYTE_INCR;
    end


    WEIGHT_BYTE_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (weight_count == 8)
            next_state = IDLE;
        else 
            next_state = WAIT_LOAD_WEIGHT_L;
    end

    //  WEIGHT WRITE PATH
    WAIT_WRITE_WEIGHT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR;
        else if(weight_full)
            next_state = OCCU_WEIGHT_ERROR;
        else if (sram_state == 2'd0)
            next_state = WRITE_WEIGHT_L;
    
    end

    WRITE_WEIGHT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if (sram_state == 2'd2)
            next_state = WEIGHT_WRITE_FIR_INCR; 
    end

    WEIGHT_WRITE_FIR_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = WAIT_WRITE_WEIGHT_H;
    end

    WAIT_WRITE_WEIGHT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if(weight_full)
            next_state = OCCU_WEIGHT_ERROR;
        else if (sram_state == 2'd0)
            next_state = WRITE_WEIGHT_H;  
    end

    WRITE_WEIGHT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3 )
            next_state = IDLE;
        else if(sram_state == 2'd2)
            next_state = WEIGHT_WRITE_SEC_INCR;
    end

    WEIGHT_WRITE_SEC_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = IDLE;
    end

    //  INPUT WRITE PATH (middle-bottom)
    WAIT_WRITE_INPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR;
        else if(input_full)
            next_state = OCCU_INPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = WRITE_INPUT_L;
    end

    WRITE_INPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR;
        else if(input_full)
            next_state = OCCU_INPUT_ERROR;
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if (sram_state ==2'd2)
            next_state = INPUT_WRITE_FIR_INCR;
    end

    INPUT_WRITE_FIR_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = WAIT_WRITE_INPUT_H;
    end

    WAIT_WRITE_INPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if(input_full)
            next_state = OCCU_INPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = WRITE_INPUT_H;    
        else if (sram_state == 2'd3)
            next_state = IDLE;
    end

    WRITE_INPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if (sram_state == 2'd2)
            next_state = INPUT_WRITE_SEC_INCR;
    end

    INPUT_WRITE_SEC_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = IDLE;
    end

    //  INPUT LOAD 
    WAIT_LOAD_INPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR;
        else if(input_empty)
            next_state = OCCU_INPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = LOAD_INPUT_L;
    end

    LOAD_INPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if (sram_state == 2'd2)
            next_state = INPUT_READ_FIR_INCR;
    end

    INPUT_READ_FIR_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = WAIT_LOAD_INPUT_H;
    end

    WAIT_LOAD_INPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR;
        else if(input_empty)
            next_state = OCCU_INPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = LOAD_INPUT_H;            
    end

    LOAD_INPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if (sram_state == 2'd2)
            next_state = INPUT_READ_SEC_INCR;
    end

    INPUT_READ_SEC_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = INPUT_BYTE_INCR;
    end

    INPUT_BYTE_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid || output_read)
            next_state= BUSY_ERROR; 
        else if (input_count == 8)            
            next_state = IDLE;               
        else
            next_state = WAIT_LOAD_INPUT_L;
    end

    //  OUTPUT WRITE PATH
    WAIT_WRITE_OUTPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference || output_read)
            next_state= BUSY_ERROR;
        else if (output_full)
            next_state = OCCU_OUTPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = WRITE_OUTPUT_L;
    end

    WRITE_OUTPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2)
            next_state = OUTPUT_WRITE_FIR_INCR;
        else if(sram_state == 2'd3)
            next_state = IDLE;
    end

    OUTPUT_WRITE_FIR_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || output_read)
            next_state= BUSY_ERROR; 
        else 
            next_state = WAIT_WRITE_OUTPUT_H;
    end

    WAIT_WRITE_OUTPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || output_read)
            next_state= BUSY_ERROR;
        else if (output_full)
            next_state = OCCU_OUTPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = WRITE_OUTPUT_H;
    end
    WRITE_OUTPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || output_read)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd2)
            next_state = OUTPUT_WRITE_SEC_INCR;
        else if (sram_state == 2'd3)
            next_state = IDLE;
    end

    OUTPUT_WRITE_SEC_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || output_read)
            next_state= BUSY_ERROR; 
        else if(output_count == 8)
            next_state = INF_DONE;
        else 
            next_state = IDLE;
    end

    //  OUTPUT READ PATH  (middle region)
    WAIT_READ_OUTPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid)
            next_state= BUSY_ERROR;
        else if (output_empty)
            next_state = OCCU_OUTPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = READ_OUTPUT_L;       
    end

    READ_OUTPUT_L: begin
        if(write_weight || write_input || load_weight || start_inference)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd3)
            next_state = IDLE;
        else if (sram_state == 2'd2)
            next_state = OUTPUT_READ_FIR_INCR; 
    end

    OUTPUT_READ_FIR_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid)
            next_state = BUSY_ERROR; 
        else
            next_state = WAIT_READ_OUTPUT_H;
    end

    WAIT_READ_OUTPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid)
            next_state= BUSY_ERROR;
        else if (output_empty)
            next_state = OCCU_OUTPUT_ERROR;
        else if (sram_state == 2'd0)
            next_state = READ_OUTPUT_H;      
    end

    READ_OUTPUT_H: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid)
            next_state= BUSY_ERROR; 
        else if (sram_state == 2'd2 || sram_state == 2'd3)
            next_state = OUTPUT_READ_SEC_INCR;
    end

    OUTPUT_READ_SEC_INCR: begin
        if(write_weight || write_input || load_weight || start_inference || activations_valid)
            next_state = BUSY_ERROR; 
        else
            next_state = IDLE;
    end

    
    //  INFERENCE DONE + ERROR STATES
    INF_DONE: begin
        
        if (load_weight) //weight read
            next_state = WAIT_LOAD_WEIGHT_L;
        else if (write_weight) //weight write
            next_state = WAIT_WRITE_WEIGHT_L;
        else if (start_inference) //input read
            next_state = WAIT_LOAD_INPUT_L;
        else if (write_input) //input write
            next_state = WAIT_WRITE_INPUT_L;
        else if (output_read) //output read
            next_state = WAIT_READ_OUTPUT_L;
        else if (activations_valid) //output write
            next_state = WAIT_WRITE_OUTPUT_L;
    end

    BUSY_ERROR: begin
        next_state = BUSY_ERR;
    end

    BUSY_ERR: begin
        next_state = IDLE;
    end

    OCCU_WEIGHT_ERROR: begin
        next_state = OCCU_WEIGHT_ERR;
    end

    OCCU_WEIGHT_ERR: begin
        next_state = IDLE;
    end

    OCCU_INPUT_ERROR: begin
        next_state = OCCU_INPUT_ERR;
    end

    OCCU_INPUT_ERR: begin
        next_state = IDLE;
    end

    OCCU_OUTPUT_ERROR: begin
        next_state = OCCU_OUTPUT_ERR;
    end

    OCCU_OUTPUT_ERR: begin
        next_state = IDLE;
    end
    endcase
end

always_comb begin : output_logic
    array_start      = 1'b0;
    load             = 1'b0;
    design_busy      = 1'b0;
    data_ready       = 1'b0;
    device_busy_err  = 1'b0;
    occupancy_err_w  = 1'b0;
    occupancy_err_i    = 1'b0;
    occupancy_err_o  = 1'b0;
    sram_read_en     = 1'b0;
    sram_write_en    = 1'b0;
    sram_addr        = 10'b0;
    sram_write_data  = 32'b0;

    //read data register
    n_inputs = '0;
    n_output_data = '0;
    //data counts
    n_weight_write_count = weight_write_count;
    n_weight_read_count = weight_read_count;
    n_input_write_count = input_write_count;
    n_input_read_count = input_read_count;
    n_output_write_count = output_write_count;
    n_output_read_count = output_read_count;
    //data flag
    n_weight_write_flag = weight_write_flag;
    n_weight_read_flag  = weight_read_flag;
    n_input_write_flag = input_write_flag;
    n_input_read_flag  = input_read_flag;
    n_output_write_flag = output_write_flag;
    n_output_read_flag  = output_read_flag;

    n_output_count = output_count;
    n_weight_count   = weight_count;
    n_input_count    = input_count;
    n_inputs = inputs;
    n_output_data = output_data;


    case (state) 

        IDLE: begin
            array_start      = 1'b0;
            load             = 1'b0;
            design_busy      = 1'b0;
            data_ready       = 1'b0;
            device_busy_err  = 1'b0;
            occupancy_err_w  = 1'b0;
            occupancy_err_i    = 1'b0;
            occupancy_err_o  = 1'b0;
            sram_read_en     = 1'b0;
            sram_write_en    = 1'b0;
            sram_addr        = 10'b0;
            sram_write_data  = 32'b0;
        end


        WAIT_LOAD_WEIGHT_L: begin
            load = 0;
            design_busy  = 1'b1;
            sram_read_en = 0;
        end

        LOAD_WEIGHT_L: begin
            design_busy  = 1'b1;
            sram_read_en = 1'b1;
            sram_addr = WEIGHTBASE + weight_read_count;
        end

        WEIGHT_READ_FIR_INCR: begin
            design_busy = 1;
            n_inputs [31:0] = sram_read_data;
            if(weight_write_count == 335)
                n_weight_read_count = 0;
            else
                n_weight_read_count = weight_read_count + 1;
        end

        WAIT_LOAD_WEIGHT_H: begin
            design_busy  = 1'b1;
            sram_read_en = 0;
        end

        LOAD_WEIGHT_H: begin
            design_busy  = 1'b1;
            sram_read_en = 1'b1;
            sram_addr = WEIGHTBASE + weight_read_count;
        end

        WEIGHT_READ_SEC_INCR: begin
            design_busy = 1;
            n_inputs [63:32] = sram_read_data;
            if(weight_write_count == 335) begin
                n_weight_read_flag = ~weight_read_flag;
                n_weight_read_count = 0;
            end
            else
                n_weight_read_count = weight_read_count + 1;
        end

        WEIGHT_BYTE_INCR: begin
            design_busy  = 1'b1;
            load = 1;
            if(weight_count == 8)
                n_weight_count = 0;
            else
                n_weight_count = weight_count + 1;
        end

        // WEIGHT WRITE PATH
        WAIT_WRITE_WEIGHT_L: begin
            design_busy   = 1'b1;
            sram_write_en = 0;
        end

        WRITE_WEIGHT_L: begin
            design_busy   = 1'b1;
            sram_write_en = 1'b1;
            sram_addr = WEIGHTBASE + weight_write_count;
            sram_write_data = weight_data [31:0];
        end

        WEIGHT_WRITE_FIR_INCR: begin
            design_busy = 1;
            if(weight_write_count == 335)
                n_weight_write_count = 0;
            else
                n_weight_write_count = weight_write_count + 1;
        end

        WAIT_WRITE_WEIGHT_H: begin
            design_busy   = 1'b1;
            sram_write_en = 0;
        end

        WRITE_WEIGHT_H: begin
            design_busy   = 1'b1;
            sram_write_en = 1'b1;
            sram_addr = WEIGHTBASE + weight_write_count;
            sram_write_data = weight_data [63:32];
        end

        WEIGHT_WRITE_SEC_INCR: begin
            design_busy = 1;
            if(weight_write_count == 335) begin
                n_weight_write_flag  = ~weight_write_flag;
                n_weight_write_count = 0;
            end
            else
                n_weight_write_count = weight_write_count + 1;
        end
                        
        // INPUT WRITE PATH
        WAIT_WRITE_INPUT_L: begin
            design_busy   = 1'b1;
            sram_write_en = 0;
        end

        WRITE_INPUT_L: begin
            design_busy   = 1'b1;
            sram_write_en = 1'b1;
            sram_addr = INPUTBASE + input_write_count;
            sram_write_data = input_data[31:0];
        end

        INPUT_WRITE_FIR_INCR: begin
            design_busy   = 1'b1;
            if (input_write_count == 335)begin 
                n_input_write_count = 0;
                n_input_write_flag  = ~input_write_flag;
            end
            else
                n_input_write_count = input_write_count + 1;
        end

        WAIT_WRITE_INPUT_H: begin
            design_busy   = 1'b1;
            sram_write_en = 0;
        end

        WRITE_INPUT_H: begin
            design_busy   = 1'b1;
            sram_write_en = 1'b1;
            sram_addr = INPUTBASE + input_write_count;
            sram_write_data = input_data[63:32];
        end

        INPUT_WRITE_SEC_INCR: begin
            design_busy   = 1'b1;
            if (input_write_count == 335) begin
                n_input_write_flag  = ~input_write_flag;
                n_input_write_count = 0;
            end
            else
                n_input_write_count = input_write_count + 1;
        end

        // INPUT LOAD PATH
        WAIT_LOAD_INPUT_L: begin
            design_busy   = 1'b1;
            sram_read_en = 0;
        end

        LOAD_INPUT_L: begin
            design_busy   = 1'b1;
            sram_read_en  = 1'b1;
            sram_addr = INPUTBASE + input_read_count;
            
        end

        INPUT_READ_FIR_INCR: begin
            design_busy = 1;
            n_inputs[31:0] = sram_read_data;
            if (input_read_count == 335) begin
                n_input_read_flag  = ~input_read_flag;
                n_input_read_count = 0;
            end
            else
                n_input_read_count = input_read_count + 1;
        end

        WAIT_LOAD_INPUT_H: begin
            design_busy   = 1'b1;
            sram_read_en = 0;
        end

        LOAD_INPUT_H: begin
            design_busy   = 1'b1;
            sram_read_en  = 1'b1;
            sram_addr = INPUTBASE + input_read_count;
        end

        INPUT_READ_SEC_INCR: begin
            design_busy = 1;
            n_inputs[63:32] = sram_read_data;
            if (input_read_count == 335) begin
                n_input_read_flag  = ~input_read_flag;
                n_input_read_count = 0;
            end
            else
                n_input_read_count = input_read_count + 1;
        end

        INPUT_BYTE_INCR: begin
            array_start = 1;
            design_busy   = 1'b1;
            if(input_count == 7)
                n_input_count = 0;
            else
                n_input_count = input_count + 1;
        end
    
        // OUTPUT WRITE PATH
        WAIT_WRITE_OUTPUT_L: begin
            design_busy   = 1'b1;
            sram_write_en = 0;
        end

        WRITE_OUTPUT_L: begin
            design_busy   = 1'b1;
            sram_write_en = 1'b1;
            sram_addr = OUTPUTBASE + output_write_count;
            sram_write_data = activations [31:0];
        end

        OUTPUT_WRITE_FIR_INCR: begin
            design_busy = 1;
            if (output_write_count == 352) begin
                n_output_write_flag  = ~output_write_flag;
            end
            else
                n_output_write_count = output_write_count + 1;
        end

        WAIT_WRITE_OUTPUT_H: begin
            design_busy   = 1'b1;
            sram_write_en = 0;
        end

        OUTPUT_WRITE_SEC_INCR: begin
            design_busy = 1;
            if(output_count == 7)
                n_output_count = 0;
            else
                n_output_count = output_count + 1;
            if (output_write_count == 352) begin
                n_output_write_flag  = ~output_write_flag;
            end
            else
                n_output_write_count = output_write_count + 1;
        end

        WRITE_OUTPUT_H: begin
            design_busy   = 1'b1;
            sram_write_en = 1'b1;
            sram_addr = OUTPUTBASE + output_write_count;
            sram_write_data = activations [63:32];
        end


        // OUTPUT READ PATH
        WAIT_READ_OUTPUT_L: begin
            design_busy   = 1'b1;
        end

        READ_OUTPUT_L: begin
            design_busy   = 1'b1;
            sram_read_en  = 1'b1;
            sram_addr = OUTPUTBASE + output_read_count;
            n_output_data[31:0] = sram_read_data;
        end

        OUTPUT_READ_FIR_INCR: begin
            design_busy = 1;
            if (output_read_count == 352) begin
                n_output_read_flag  = ~output_read_flag;
            end
            else
                n_output_read_count = output_read_count + 1;
        end

        WAIT_READ_OUTPUT_H: begin
            design_busy   = 1'b1;
            sram_read_en = 0;

        end

        READ_OUTPUT_H: begin
            design_busy   = 1'b1;
            sram_read_en  = 1'b1;
            sram_addr = OUTPUTBASE + output_read_count ;
            n_output_data[63:32] = sram_read_data;
        end

        OUTPUT_READ_SEC_INCR: begin
            design_busy = 1;
            if (output_read_count == 352) begin
                n_output_read_flag  = ~output_read_flag;
            end
            else
                n_output_read_count = output_read_count + 1;
        end

        // INF START / DONE
        INF_DONE: begin
            design_busy = 0;
            data_ready    = 1'b1;
        end

        // ERROR STATES
        BUSY_ERROR: begin
            design_busy = 0;
            device_busy_err = 1'b1;
        end

        BUSY_ERR: begin
            design_busy = 0;
            device_busy_err = 1'b1;
        end

        OCCU_WEIGHT_ERROR: begin
            design_busy = 0;
            occupancy_err_w = 1'b1;
        end

        OCCU_WEIGHT_ERR: begin
            design_busy = 0;
            occupancy_err_w = 1'b1;
        end

        OCCU_INPUT_ERROR: begin
            design_busy = 0;
            occupancy_err_i  = 1'b1;
        end

        OCCU_INPUT_ERR: begin
            design_busy = 0;
            occupancy_err_i  = 1'b1;
        end

        OCCU_OUTPUT_ERROR: begin
            design_busy = 0;
            occupancy_err_o = 1'b1;
        end

        OCCU_OUTPUT_ERR: begin
            design_busy = 0;
            occupancy_err_o = 1'b1;
        end
    endcase
end


always_comb begin : full_empty
    //weight full empty
    if (weight_write_count == weight_read_count) begin
        if (weight_write_flag == weight_read_flag) begin
            weight_empty = 1;
            weight_full  = 0;
        end
        else begin
            weight_full  = 1;
            weight_empty = 0;
        end
    end
    else begin
        weight_full  = 0;
        weight_empty = 0;
    end

    //input full empty
    if (input_write_count == input_read_count) begin
        if (input_write_flag == input_read_flag) begin
            input_empty = 1;
            input_full  = 0;
        end
        else begin
            input_full  = 1;
            input_empty = 0;
        end
    end
    else begin
        input_full  = 0;
        input_empty = 0;
    end

    //output full empty
    if (output_write_count == output_read_count) begin
        if (output_write_flag == output_read_flag) begin
            output_empty = 1;
            output_full  = 0;
        end
        else begin
            output_full  = 1;
            output_empty = 0;
        end
    end
    else begin
        output_full  = 0;
        output_empty = 0;
    end
end




endmodule



