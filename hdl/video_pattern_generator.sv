`include "gen_rgbgray_10bit_quad.sv"

typedef enum logic [1:0] {SVTPATTERN_0,SVTPATTERN_1,SVTPATTERN_2,SVTPATTERN_3}   test_svpattern_t;

module video_pattern_generator
#(
    parameter int N_MIPI_LANES = 2,
    parameter int PIXELS_8BIT_PER_LINE = 3240,//80,//Should be 3240,
    parameter int N_LINES         = 1944,//30,//Should be 1944,
    parameter int BUS_WIDTH       = 8,
    parameter int WIDTH_N_PIXELS   = 13,
    parameter int WIDTH_N_LINES    = 13
)
(
    input logic clk,
    input logic rst,
    input logic hs_active,    
    /* verilator lint_off UNUSED */
    input logic [15 : 0] frame_number,
    input logic [WIDTH_N_LINES -1 : 0] line_number,
    input test_svpattern_t test_patter_selector,
    /* verilator lint_on UNUSED */
    output logic [N_MIPI_LANES*BUS_WIDTH-1:0] video_data_out,
    output logic generator_output_valid
);    



typedef enum {PS_IDLE,PS_SKIP_Bytes1_2,PS_SKIP_Bytes3_4,PS_TRANSMIT} pattern_state_type;	
pattern_state_type pattern_state_reg, pattern_state_next;
logic[WIDTH_N_PIXELS - 1 : 0] pixel_counter_reg,pixel_counter_next;
logic[WIDTH_N_PIXELS - 1 : 0] pixel_index;
logic [N_MIPI_LANES*BUS_WIDTH-1:0] rgbgray_pattern_out;

logic is_even_line;

assign is_even_line = !line_number[0];
assign pixel_index = pixel_counter_reg;

gen_rgbgray_10bit_quad  rgbgrayquad(.pixel_index,.is_even_line,.frame_number,.rgbgray_pattern_out);

always_ff @(posedge clk,posedge rst) begin : vgen_state_and_data
    if (rst) begin
        pattern_state_reg <= PS_IDLE;
        pixel_counter_reg <= 0;
    end else begin
        pattern_state_reg <= pattern_state_next;
        pixel_counter_reg <= pixel_counter_next;
    end
end


//next state logic
always_comb begin : vgen_send_fsmd
    pattern_state_next          = pattern_state_reg;
    pixel_counter_next          = pixel_counter_reg;
    video_data_out              = 0; //TODO: think what should be here
    generator_output_valid      = 0; //TODO: think what should be here

    case (pattern_state_reg)
        PS_IDLE: 
            begin
                if (hs_active == 1) begin
                    pattern_state_next = PS_TRANSMIT;
                    pixel_counter_next = 0;
                end
            end
        PS_SKIP_Bytes1_2: pattern_state_next =  PS_TRANSMIT;
        PS_SKIP_Bytes3_4: pattern_state_next =  PS_TRANSMIT;   
        PS_TRANSMIT: begin
                // if (is_even_line == 0) begin
                //     //line 1
                //     video_data_out[15:8] =  8'hCA; //G
                //     video_data_out[7:0]  =  8'hFE; //B
                // end else begin
                //     //line 2
                //     video_data_out[15:8] =  8'hBA;  //R
                //     video_data_out[7:0]  =  8'hBE;  //G
                // end

                video_data_out = rgbgray_pattern_out;

                generator_output_valid = 1;
                pixel_counter_next = pixel_counter_reg + 2;
                if (pixel_counter_reg == (PIXELS_8BIT_PER_LINE[WIDTH_N_PIXELS - 1 : 0] - 2)) begin
                    pattern_state_next =  PS_IDLE;
                end 
            end
        default: pattern_state_next =  PS_IDLE;
    endcase

end  //vgen_send_fsmd

endmodule //video_pattern_generator