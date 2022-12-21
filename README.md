# ECE 385 Project: Pac-Man

### Contributers:
Jake Li

Paul Jeong

## Project Report

[FinalProjectReport-jli301-paulj3.pdf](https://github.com/jakel2014/ECE385FinalProjectFA2022/files/10282266/FinalProjectReport-jli301-paulj3.pdf)

## Demo
https://user-images.githubusercontent.com/70673304/209016829-6b85c6de-0d25-4a38-96be-965a24988bd1.mov

## Project Setup
### To run this project, import the following files into a quartus project:
pacman_chomp_pcm.sv

pacman_chom_pcm.txt

endScreen/endScreen_rom.sv

endScreen/endScreen_palette.sv

endScreen/endScreen.mif

ghostOrange/ghostOrange_rom.sv

ghostOrange/ghostOrange_palette.sv

ghostOrange/ghostOrange.mif

ghostBlue/ghostBlue_rom.sv

ghostBlue/ghostBlue_palette.sv

ghostBlue/ghostBlue.mif

StartScreen/StartScreen_rom.sv

StartScreen/StartScreen_palette.sv

StartScreen/StartScreen.mif

ghostPink/ghostPink_rom.sv

ghostPink/ghostPink_palette.sv

ghostPink/ghostPink.mif

ghostRed/ghostRed_rom.sv

ghostRed/ghostRed_palette.sv

ghostRed/ghostRed.mif

pacManOpenD/pacManOpenD_palette.sv

pacManOpenD/pacManOpenD_rom.sv

pacManOpenD/pacManOpenD.mif

pacManOpenU/pacManOpenU_palette.sv

pacManOpenU/pacManOpenU_rom.sv

pacManOpenU/pacManOpenU.mif

pacManOpenL/pacManOpenL_palette.sv

pacManOpenL/pacManOpenL_rom.sv

pacManOpenL/pacManOpenL.mif

pacManOpenR/pacManOpenR_palette.sv

pacManOpenR/pacManOpenR_rom.sv

pacManOpenR/pacManOpenR.mif

map/map_rom.sv

map/map_palette.sv

map/map_mapper.sv

map/map.mif

lab6.sdc

FinalProject1_soc/synthesis/FinalProject1_soc.qip

Lab 62 Provided files (FP)/VGA_controller.sv

Lab 62 Provided files (FP)/HexDriver.sv

Lab 62 Provided files (FP)/Color_Mapper.sv

Lab 62 Provided files (FP)/ball.sv

FinalProject1.sv

ghost.sv

FSM.sv

shift_reg.sv

### Other Steps:

Import the pin assignment file FinalProject1.qsf and import FinalProject1_soc.qsys into Platform Designer

Copy over all software components into the folder being used in Eclipse

Plug in a USB keyboard and 3.5 mm audio jack to the DE-10 board. Connect a VGA cable from the FPGA to a monitor

Running the project should include generating HDL, compiling the project in quartus, programming the FPGA, generating BSP in Eclipse, building the project file in eclipse, and finally running it in Eclipse

