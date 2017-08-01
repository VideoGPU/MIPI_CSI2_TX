//Generates eight colomns color pattern, with optional shift, 10 bits ouput

module color_cols_generator
#(
    parameter int PIXELS_8BIT_PER_LINE = 3240,//80 //Should be 3240,
    parameter int WIDTH_N_PIXELS       = 13,
    /* verilator lint_off UNUSED */
    parameter int N_LINES              = 1944,//30,//Should be 1944,
    parameter int WIDTH_N_LINES        = 13,
    /* verilator lint_on UNUSED */
    parameter int BPP                  = 10, //bits per pixel
    parameter int N_COLORS                  = 8 //Number of color is colorbar
)
(
    input  logic [WIDTH_N_PIXELS - 1 : 0] pixel_index, //10 bit's pixel index, not 8 bits
    /* verilator lint_off UNUSED */
    input  logic [WIDTH_N_PIXELS - 1 : 0] cols_offset,
    /* verilator lint_on UNUSED */
    output logic [BPP-1:0] r,
    output logic [BPP-1:0] g,
    output logic [BPP-1:0] b
); 

typedef enum {
              WHITE=0,
              YELLOW,
              CYAN,
              GREEN,
              MAGENTA,
              RED,
              BLUE,
              BLACK
              } color_names_type;	

//N_COLORS for n of colors, 3 for RGB
logic [BPP-1:0] all_colors[N_COLORS][3] = '{ 
    '{10'h3FF,10'h000,10'h000}, //RED
    '{10'h3FF,10'h3FF,10'h3FF}, //WHITE
    '{10'h3FF,10'h3FF,10'h000}, //YELLOW
    '{10'h000,10'h3FF,10'h3FF}, //CYAN
    '{10'h000,10'h3FF,10'h000}, //GREEN
    '{10'h3FF,10'h000,10'h3FF}, //MAGENTA
    //'{10'h3FF,10'h000,10'h000}, //RED
    '{10'h000,10'h000,10'h3FF}, //BLUE
    '{10'h000,10'h000,10'h000}  //BLACK
};            

//Number of 10 or whatever BPP is, total pixels in line
localparam int N_PIXELS = PIXELS_8BIT_PER_LINE*8/BPP;
localparam int PIX_PER_COLOR = N_PIXELS/N_COLORS;

localparam int colors_ranges[N_COLORS][2] = '{ 
    '{0,PIX_PER_COLOR},                         //WHITE
    '{1*PIX_PER_COLOR,2*PIX_PER_COLOR},         //YELLOW
    '{2*PIX_PER_COLOR,3*PIX_PER_COLOR},         //CYAN
    '{3*PIX_PER_COLOR,4*PIX_PER_COLOR},         //GREEN
    '{4*PIX_PER_COLOR,5*PIX_PER_COLOR},         //MAGENTA
    '{5*PIX_PER_COLOR,6*PIX_PER_COLOR},         //RED
    '{6*PIX_PER_COLOR,7*PIX_PER_COLOR},         //BLUE
    '{7*PIX_PER_COLOR,N_COLORS*PIX_PER_COLOR}   //BLACK
                                                
};

//-------Variables---------
int valid_index;
int pixel_index_with_offset;
int int_pix_index;
//-------Implementation---------

//TODO: fix the below expression
assign valid_index[31 : WIDTH_N_PIXELS] = 0;
//assign valid_index[WIDTH_N_PIXELS - 1 : 0]   = pixel_index; //pixel index in N_PIXELS range

assign int_pix_index[31 : WIDTH_N_PIXELS] = 0;
assign int_pix_index[WIDTH_N_PIXELS - 1 : 0]    = pixel_index; //pixel index in N_PIXELS range

//assign pixel_index_with_offset[31 : WIDTH_N_PIXELS] = 0;
assign pixel_index_with_offset = int_pix_index - 10*(int'(cols_offset));//PIX_PER_COLOR*x gives best visual presentation after demosaicing



always_comb begin : wrap_pixel_index
    
    valid_index[WIDTH_N_PIXELS - 1 : 0]   = pixel_index_with_offset[WIDTH_N_PIXELS - 1 : 0]; //pixel index in N_PIXELS range

    if (pixel_index_with_offset < 0 )
        valid_index[WIDTH_N_PIXELS - 1 : 0]  = (N_PIXELS - (-pixel_index_with_offset) % N_PIXELS);


end //wrap_pixel_index

//generating BGGR bayer,10 bits
always_comb begin : gen_rgb_vertical_bar
    r = all_colors[YELLOW][0];
    g = all_colors[YELLOW][1];
    b = all_colors[YELLOW][2];

   
    if (valid_index >= colors_ranges[0][0] && valid_index < colors_ranges[0][1]) begin
        //WHITE
            r = all_colors[WHITE][0];
            g = all_colors[WHITE][1];
            b = all_colors[WHITE][2];
    end else begin 
    if (valid_index >= colors_ranges[1][0] && valid_index < colors_ranges[1][1]) begin
        //YELLOW
            r = all_colors[YELLOW][0];
            g = all_colors[YELLOW][1];
            b = all_colors[YELLOW][2];
    end else begin         
    if (valid_index >= colors_ranges[2][0] && valid_index < colors_ranges[2][1]) begin
        //CYAN
            r = all_colors[CYAN][0];
            g = all_colors[CYAN][1];
            b = all_colors[CYAN][2];
    end else begin 
    if (valid_index >= colors_ranges[3][0] && valid_index < colors_ranges[3][1]) begin
        //GREEN
            r = all_colors[GREEN][0];
            g = all_colors[GREEN][1];
            b = all_colors[GREEN][2];
    end else begin 
    if (valid_index >= colors_ranges[4][0] && valid_index < colors_ranges[4][1]) begin
        //MAGENTA
            r = all_colors[MAGENTA][0];
            g = all_colors[MAGENTA][1];
            b = all_colors[MAGENTA][2];
    end else begin 
    if (valid_index >= colors_ranges[5][0] && valid_index < colors_ranges[5][1]) begin
        //RED
            r = all_colors[RED][0];
            g = all_colors[RED][1];
            b = all_colors[RED][2];
    end else begin 
    if (valid_index >= colors_ranges[6][0] && valid_index < colors_ranges[6][1]) begin
        //BLUE
            r = all_colors[BLUE][0];
            g = all_colors[BLUE][1];
            b = all_colors[BLUE][2];
    end else begin 
    if (valid_index >= colors_ranges[7][0] && valid_index < colors_ranges[7][1]) begin
        //BLACK
            r = all_colors[BLACK][0];
            g = all_colors[BLACK][1];
            b = all_colors[BLACK][2];
    end //BLACK
    end //BLUE
    end //RED
    end //MAGENTA
    end //GREEN
    end //CYAN
    end //YELLOW   
    end //WHITE                                        


end //gen_rgb_vertical_bar


endmodule //color_cols_generator