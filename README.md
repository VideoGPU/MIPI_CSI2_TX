# MIPI_CSI2_TX 
VHDL code for using LVDS lines of Xilinx FPGA  for MIPI CSI-2 TX  protocol.
The goal is to support sending video or any other data using  FPGA that
don't have a dedicated D-PHY compatible outputs. (HS and LP outputs modes).
The code was tested and works as expected on KC705 evaluation board.
The custom PCB board was also developed, and available in this repo:
https://github.com/VideoGPU/FMC_MIPI
The board connects between KC705 FMC  and a camera connector of Jetson TX2.
Customisation for other boards is straightforward.
VHDL code  ~fully duplicates the behaviour of the camera board shipped with Jetson TX2 development kit.
I2C slave code is from https://github.com/tirfil/VhdI2CSlave repo. 

```
```
[![Alt text](https://cdn.britannica.com/84/73184-050-05ED59CB/Sunflower-field-Fargo-North-Dakota.jpg?w=400&h=300&c=crop)](https://digitalocean.com)
```
```

For educational purposes
