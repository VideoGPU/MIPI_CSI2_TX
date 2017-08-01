// Verilator Example
// Norbertas Kremeris 2021
#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vvideo_pattern_generator.h"
#include "Vvideo_pattern_generator___024unit.h"

//Top module params
#define PIXELS_8BIT_PER_LINE 3240//80//3240
#define N_LINES             1944//30//1944 //NOTE: should be in sync with .sv implementation
//End of top module params

#define MAX_SIM_TIME        (9500000*3)//(10000*20*60)//(9500000*3)
#define VERIF_START_TIME    7

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

uint16_t frame_out[PIXELS_8BIT_PER_LINE*N_LINES/2]; // divide by two because 16 bits per clock
static const char *out_folder = "./obj_dir";
FILE *frame_outf=0;


void dut_reset (Vvideo_pattern_generator *dut, vluint64_t &sim_time){
     dut->rst = 0;

    VL_OUT16(video_data_out,15,0);
    VL_OUT(generator_output_valid,1,0);

    if(sim_time >= 3 && sim_time < 6){
        dut->rst = 1;
        dut->hs_active = 0;
        dut->test_patter_selector = 0;
        dut->frame_number = 0;
        dut->line_number= 0;
    }
    
}


// void set_hs_active(Vvideo_pattern_generator *dut, vluint64_t &sim_time){

//     if (sim_time >= VERIF_START_TIME) {
//         dut->hs_active = 1;
//     }

// }

enum FRAME_STATE {NOT_STARTED=0,
                  BETWEEN_FRAMES,
                  FRAME_START,                  
                  BETWEEN_LINES,
                  SEND_LINE,
                  LINE_END,
                  FRAME_END
                  
                  };



void set_pixel_and_line_and_frame_counter(Vvideo_pattern_generator *dut, vluint64_t &sim_time){

    static FRAME_STATE frame_state = NOT_STARTED;
    static bool first_time = true;
    static int  delay_counter = 0;
    static int  pixel_counter = 0;
    static FILE *fout;

        //Logging
    if (first_time) {
        fout = fopen("tb_logs.txt","wt");
    } 


    switch (frame_state)
    {
    case NOT_STARTED:
        fprintf(fout,"NOT_STARTED \n");
        if (sim_time >= VERIF_START_TIME) {        
            frame_state = BETWEEN_FRAMES;
            dut->hs_active = 0;
            delay_counter=0;
            pixel_counter = 0;
        }
        break;

    case BETWEEN_FRAMES:
        fprintf(fout,"BETWEEN_FRAMES \n");
        delay_counter++;
        if (delay_counter >= 5) {        
            frame_state = FRAME_START;
            delay_counter=0;
            pixel_counter = 0;
        }
        break;     

    case FRAME_START:
        fprintf(fout,"FRAME_START %d \n",dut->frame_number);
        dut->hs_active = 0;        
        frame_state = BETWEEN_LINES;        
        delay_counter=0;        
        pixel_counter = 0;
        break;         

    case BETWEEN_LINES:
        fprintf(fout,"BETWEEN_LINES \n");
        if (dut->line_number < N_LINES) {
            dut->hs_active = 1;        
            frame_state = SEND_LINE;        
        } else {
            dut->hs_active = 0;        
            frame_state = FRAME_END;        
        }
        delay_counter=0;        
        pixel_counter = 0;
        break;         

    case SEND_LINE:
        if (pixel_counter == 0) {
            fprintf(fout,"SEND_LINE %d \n",dut->line_number);
        }
        
        if (dut->generator_output_valid == 1) {

            if (pixel_counter  >= PIXELS_8BIT_PER_LINE) {        
                frame_state = LINE_END;    //Actually line end
                fprintf(fout,"SEND_LINE, LINE_END 1\n");
                pixel_counter = 0;        
                dut->hs_active = 0;
            } else {
                //HERE WE CAN DUMP PIXELS TO BINARY
                uint16_t two_bytes_of_data = dut->video_data_out;
                //debug
                // uint8_t dbg_data[2];
                // dbg_data[0] = pixel_counter;
                // dbg_data[1] = pixel_counter+1;
                // two_bytes_of_data = *((uint16_t*)dbg_data);
                //end of debug
                frame_out[dut->line_number*PIXELS_8BIT_PER_LINE/2 + (pixel_counter >> 1)] = two_bytes_of_data; //Divide by two because 2 bytes
                pixel_counter+=2; //Output is two pixels at once
            }
        } else {
            if (pixel_counter > 0) {
                 dut->hs_active = 0;
                 frame_state = LINE_END;    //Actually line end
                 fprintf(fout,"SEND_LINE, LINE_END 2\n");
            }
            pixel_counter = 0; 
        }
        break;       
        
    case LINE_END:
        //fprintf(fout,"LINE_END \n");
        delay_counter++;
        if (delay_counter >= 10) {        
            frame_state = BETWEEN_LINES; //TODO add line counter and at the end of frame state is BETWEEN_FRAMES
            delay_counter=0;
            dut->hs_active = 0;
            dut->line_number++;
        }
        break;             

    case FRAME_END:
        fprintf(fout,"FRAME_END \n");
        delay_counter++;
        if (delay_counter >= 10) {                    
            frame_state = BETWEEN_FRAMES; //TODO add frame counter

            //Dump binary frame out
            char fname_out[256];
            sprintf(fname_out,"%s/frame_%d.bin",out_folder,dut->frame_number);
            frame_outf = fopen(fname_out,"wb");
            fwrite(frame_out,1,sizeof(frame_out),frame_outf);
            fclose(frame_outf);

            delay_counter=0;
            dut->hs_active = 0;
            dut->line_number = 0;
            dut->frame_number++;
        }
        break;             
    
    default:
        break;
    }
    

    //fprintf(fout,"pixel_counter= %d \n",pixel_counter);
    first_time=false;
}


int main(int argc, char** argv, char** env) {
    srand (time(NULL));
    Verilated::commandArgs(argc, argv);
    Vvideo_pattern_generator *dut = new Vvideo_pattern_generator;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);

        dut->clk ^= 1;
        dut->eval();

        if (dut->clk == 1){
            posedge_cnt++;
            //set_hs_active(dut, sim_time);
            set_pixel_and_line_and_frame_counter(dut,sim_time);
        }

        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
