import cv2
import numpy as np
#import matplotlib.pyplot as plt

WIDTH  = 3240 #3240 #80
HEIGHT = 1944 #30

INPUT_FOLDER = "./obj_dir"

def get_byte(lane_in,index):
    curr_byte = np.uint8(0x00)
    for bit_index in range(0,8):
        curr_byte |=( lane_in[index + bit_index] << bit_index)

    return  curr_byte  

def get_4_10b_pixels_from_5bytes(arr_5bytesBG10):


    byte1 = np.uint16(arr_5bytesBG10[0])
    byte2 = np.uint16(arr_5bytesBG10[1])
    byte3 = np.uint16(arr_5bytesBG10[2])
    byte4 = np.uint16(arr_5bytesBG10[3])
    byte5_uint8 = arr_5bytesBG10[4]

    #print("byte5_uint8 =  %d" % byte5_uint8)

    byte1 = (byte1 << 2) | ((byte5_uint8 << 0)>> 6) 
    byte1 = (byte2 << 2) | ((byte5_uint8 << 2)>> 8) 
    byte3 = (byte3 << 2) | ((byte5_uint8 << 4)>> 10) 
    byte4 = (byte4 << 2) | ((byte5_uint8 << 6)>> 12) 
    return (byte1, byte2,byte3,byte4)

def get_4_8_pixels_from_5bytes_of_BG10(arr_5bytesBG10):


    byte1 = np.uint16(arr_5bytesBG10[0])
    byte2 = np.uint16(arr_5bytesBG10[1])
    byte3 = np.uint16(arr_5bytesBG10[2])
    byte4 = np.uint16(arr_5bytesBG10[3])
    byte5_uint8 = arr_5bytesBG10[4]

    #print("byte1 , =  %d" % byte5_uint8)

    #Correct
    # byte1 = np.uint8(float( (byte1 << 2) | ((byte5_uint8 << 0)>> 6) ) /4.0)
    # byte2 = np.uint8(float( (byte2 << 2) | ((byte5_uint8 << 2)>> 8) ) /4.0) 
    # byte3 = np.uint8(float( (byte3 << 2) | ((byte5_uint8 << 4)>> 10)) /4.0) 
    # byte4 = np.uint8(float( (byte4 << 2) | ((byte5_uint8 << 6)>> 12)) /4.0) 


    return (byte1, byte2,byte3,byte4)

if __name__ == "__main__":

    cv2.namedWindow("Input",cv2.WINDOW_NORMAL)

    for ind_file in range(0,3):

        raw_BG10 = np.fromfile(INPUT_FOLDER + "/frame_" + str(ind_file) + ".bin", dtype=np.uint8)

        raw_BG10 = np.reshape(raw_BG10,[HEIGHT ,WIDTH])

        bayer_bggr8bit = np.zeros((HEIGHT,int(WIDTH*4/5)),dtype=np.uint8)
        print("np.shape(bayer_bggr8bit)")
        print(np.shape(bayer_bggr8bit))

        np.set_printoptions(formatter={'int':hex})
        #for ind in range(0,HEIGHT):
        for ind in range(0,HEIGHT):
            
            single_rawBG10 = raw_BG10[ind]    
            for ind_raw in range(0,len(single_rawBG10),5):
                arr_in5bytes = single_rawBG10[ind_raw:ind_raw+5]
                (byte1, byte2,byte3,byte4) = get_4_8_pixels_from_5bytes_of_BG10(arr_in5bytes)
                
                ind_bayer = int(ind_raw*4/5)
                bayer_bggr8bit[ind,ind_bayer + 0] = byte1
                bayer_bggr8bit[ind,ind_bayer + 1] = byte2
                bayer_bggr8bit[ind,ind_bayer + 2] = byte3
                bayer_bggr8bit[ind,ind_bayer + 3] = byte4


        # print("raw_BG10[ind]")
        # for ind in range(0,2):
        #    print(raw_BG10[ind]) #prints one row 0..WIDTH = 0..80 for test

        # print("bayer_bggr8bit[ind]")
        # for ind in range(0,2):
        #    print(bayer_bggr8bit[ind]) 

        #print(bayer_bggr8bit) 
        #print(raw_BG10)

        # Read single frame avi
        # cap = cv2.imre('singleFrame.avi')
        # rval, frame = cap.read()

        #Show Bayer
        # cv2.imshow("Input", bayer_bggr8bit)
        # cv2.waitKey(0)

        #Show BGR
        bgr_colorbar8_bit = cv2.cvtColor(bayer_bggr8bit,cv2.COLOR_BayerBGGR2BGR)
        cv2.imshow("Input", bgr_colorbar8_bit)
        cv2.waitKey(5)