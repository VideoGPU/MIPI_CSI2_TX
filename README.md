# MIPI_CSI2_TX 
VHDL code for using LVDS lines of Xilinx FPGA  for MIPI CSI-2 TX  protocol.
The goal is to support sending video or any other data using  FPGA that
don't have a dedicated D-PHY compatible outputs. (HS and LP outputs modes).
The rate is 800Mbit/Sec per lane, two lanes total + DDR clock.
The code was tested and works as expected on KC705 evaluation board.
The custom PCB board was also developed, and available in this repo:
https://github.com/VideoGPU/FMC_MIPI
The board connects between KC705 FMC  and a camera connector of Jetson TX2.
Customisation for other boards is straightforward.
VHDL code  ~fully duplicates the behaviour of the camera board shipped with Jetson TX2 development kit.
I2C slave code is from https://github.com/tirfil/VhdI2CSlave repo. 

For educational purposes.

## Install notes:
1.Clone the repo

git clone git@github.com:VideoGPU/MIPI_CSI2_TX.git

2.Inside Vivado Tcl console,navigate to the repo dir. In my case it was

cd /home/videogpu/MIPI_CSI2_TX

3.Run the installation script:

source csi_tx.tcl

It will create a ready to use project for Kintex-7 KC705 evaluation board.
Now you can generate a bitstream, or run the simulation. 

## Some pictures:
Terminal output:
![Alt text](https://github.com/VideoGPU/MIPI_CSI2_TX/blob/master/pictures/terminal_output.jpg?raw=true)
Example output:
The vertical line position in magenta strip indicates a frame number
![Alt text](https://github.com/VideoGPU/MIPI_CSI2_TX/blob/master/pictures/IMG_6613.jpg?raw=true)

The whole setup:
![Alt text](https://github.com/VideoGPU/MIPI_CSI2_TX/blob/master/pictures/IMG_6612.jpg?raw=true)

Interconnector board:
![Alt text](https://github.com/VideoGPU/MIPI_CSI2_TX/blob/master/pictures/IMG_6610.jpg?raw=true)

![Alt text](https://github.com/VideoGPU/MIPI_CSI2_TX/blob/master/pictures/IMG_6611.jpg?raw=true)


