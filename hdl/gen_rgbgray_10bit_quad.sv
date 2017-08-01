`include "color_cols_generator.sv"

module gen_rgbgray_10bit_quad
#(
    parameter int N_MIPI_LANES         = 2,
    parameter int PIXELS_8BIT_PER_LINE = 3240,//80,//Should be 3240,
    parameter int BUS_WIDTH            = 8,
    parameter int WIDTH_N_PIXELS       = 13,
    parameter int BPP                  = 10 //bits per pixel
)
(
    input  logic [WIDTH_N_PIXELS - 1 : 0] pixel_index, //increments by N_MIPI_LANES, so need to take care of it
    input  logic is_even_line,
/* verilator lint_off UNUSED */
    input  logic [15 : 0] frame_number, 
/* verilator lint_on UNUSED */    
    output logic [N_MIPI_LANES*BUS_WIDTH-1:0] rgbgray_pattern_out
); 


typedef enum int {  FIRST_PAIR_OF_PIXELS,
                    SECOND_PAIR_OF_PIXELS,
                    FIFTH_PIXEL_AND_SIXTH_PIXELS,
                    SEVENTH_AND_EIGHTS_PIXELS,
                    NINETH_AND_TENTH} pixel_state_type;	
pixel_state_type pixel_state;
int  pix_ind_mod10_div2;


logic [WIDTH_N_PIXELS - 1 : 0] cols_offset;
logic [WIDTH_N_PIXELS - 1 : 0] pixel8b_ind;

/* verilator lint_off UNUSED */
logic [BPP-1 : 0] r0,g0,b0;
logic [BPP-1 : 0] r1,g1,b1;
logic [BPP-1 : 0] r2,g2,b2;
logic [BPP-1 : 0] r3,g3,b3;
logic [BPP-1 : 0] r4,g4,b4;
logic [BPP-1 : 0] r5,g5,b5;
logic [BPP-1 : 0] r6,g6,b6;
logic [BPP-1 : 0] r7,g7,b7;
/* verilator lint_on UNUSED */


assign pix_ind_mod10_div2[31 : WIDTH_N_PIXELS] = 0;
assign pix_ind_mod10_div2[WIDTH_N_PIXELS - 1 : 0] = (pixel_index % 10) >> 1;
assign pixel_state = pixel_state_type'(pix_ind_mod10_div2);

assign cols_offset  = frame_number[WIDTH_N_PIXELS - 1 : 0]; //BUG!! Solveit
assign pixel8b_ind = ((pixel_index - (pixel_index % 10)) / 10 ) * 8;
//assign pixel8b_ind = pixel_index;

color_cols_generator  color_cols0(.pixel_index(pixel8b_ind),.cols_offset,
                                .r(r0),.g(g0),.b(b0));                                                            
color_cols_generator  color_cols1(.pixel_index(pixel8b_ind +1),.cols_offset,
                                .r(r1),.g(g1),.b(b1));
color_cols_generator  color_cols2(.pixel_index(pixel8b_ind +2),.cols_offset,
                                .r(r2),.g(g2),.b(b2));
color_cols_generator  color_cols3(.pixel_index(pixel8b_ind +3),.cols_offset,
                                .r(r3),.g(g3),.b(b3));

color_cols_generator  color_cols4(.pixel_index(pixel8b_ind +4),.cols_offset,
                                .r(r4),.g(g4),.b(b4));
color_cols_generator  color_cols5(.pixel_index(pixel8b_ind +5),.cols_offset,
                                .r(r5),.g(g5),.b(b5));
color_cols_generator  color_cols6(.pixel_index(pixel8b_ind +6),.cols_offset,
                                .r(r6),.g(g6),.b(b6));
color_cols_generator  color_cols7(.pixel_index(pixel8b_ind +7),.cols_offset,
                                .r(r7),.g(g7),.b(b7));                                                                                                                                                                                                            

//generating BGGR bayer,10 bits
always_comb begin : gen_rgbgray_10bit_quad

    rgbgray_pattern_out = 16'h0000;
    //rgbgray_pattern_out[WIDTH_N_PIXELS - 1 : 0] = pixel_index; //for test

    if ( is_even_line == 1) begin
        //even
        case (pixel_state)
            //FIRST_PAIR_OF_PIXELS: begin rgbgray_pattern_out = 16'h2211; end //G(1)B(0)
            FIRST_PAIR_OF_PIXELS:         begin rgbgray_pattern_out[15:8] = g1[7:0];  rgbgray_pattern_out[7:0] = b0[7:0]; end //G(1)B(0)
            SECOND_PAIR_OF_PIXELS:        begin rgbgray_pattern_out[15:8] = g3[7:0];  rgbgray_pattern_out[7:0] = b2[7:0]; end //G(3)B(2)
            FIFTH_PIXEL_AND_SIXTH_PIXELS: begin rgbgray_pattern_out[15:8] = b4[7:0]; //(B4)_(compilment 2 bits from  B(0)G(1)B(2)G(3))
                                                rgbgray_pattern_out[7:6]  = g3[9:8]; 
                                                rgbgray_pattern_out[5:4]  = b2[9:8]; 
                                                rgbgray_pattern_out[3:2]  = g1[9:8]; 
                                                rgbgray_pattern_out[1:0]  = b0[9:8]; 
                                                
                                                end 
            SEVENTH_AND_EIGHTS_PIXELS:    begin rgbgray_pattern_out[15:8] = b6[7:0];  rgbgray_pattern_out[7:0] = g0[7:0]; end //B(6)G(5)
            NINETH_AND_TENTH:             begin rgbgray_pattern_out[15:14] = g7[9:8];
                                                rgbgray_pattern_out[13:12] = b6[9:8]; 
                                                rgbgray_pattern_out[11:10] = g5[9:8]; 
                                                rgbgray_pattern_out[9:8] =   b4[9:8];         
                                                rgbgray_pattern_out[7:0] =   g7[7:0]; end //(compilment 2 bits from  B(4)G(5)B(6)G(7))_G(7)

            default: rgbgray_pattern_out = 16'hCAFE;
        endcase
        
    end else begin
        //odd
        case (pixel_state)

            FIRST_PAIR_OF_PIXELS:         begin rgbgray_pattern_out[15:8] = r1[7:0];  rgbgray_pattern_out[7:0] = g0[7:0]; end //R(1)G(0)
            SECOND_PAIR_OF_PIXELS:        begin rgbgray_pattern_out[15:8] = r3[7:0];  rgbgray_pattern_out[7:0] = g2[7:0]; end //R(3)G(2)
            FIFTH_PIXEL_AND_SIXTH_PIXELS: begin rgbgray_pattern_out[15:8] = g4[7:0]; //(G4)_(compilment 2 bits from  G(0)R(1)G(2)R(3))
                                                rgbgray_pattern_out[7:6]  = r3[9:8]; 
                                                rgbgray_pattern_out[5:4]  = g2[9:8]; 
                                                rgbgray_pattern_out[3:2]  = r1[9:8]; 
                                                rgbgray_pattern_out[1:0]  = g0[9:8];                                                 
                                                end 
            SEVENTH_AND_EIGHTS_PIXELS:    begin rgbgray_pattern_out[15:8] = g6[7:0];  rgbgray_pattern_out[7:0] = r0[7:0]; end //G(6)R(5)

            NINETH_AND_TENTH:             begin rgbgray_pattern_out[15:14] = r7[9:8];
                                                rgbgray_pattern_out[13:12] = g6[9:8]; 
                                                rgbgray_pattern_out[11:10] = r5[9:8]; 
                                                rgbgray_pattern_out[9:8] =   g4[9:8];         
                                                rgbgray_pattern_out[7:0] =   r7[7:0]; end //(compilment 2 bits from  G(4)R(5)G(6)R(7))_R(7)

        default: rgbgray_pattern_out = 16'hBABE;
        endcase

    end //if-else even/odd lines

end //gen_rgbgray_10bit_quad


endmodule //gen_rgbgray_10bit_quad