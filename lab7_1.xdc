## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Buttons
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN T18 [get_ports {start}]
set_property IOSTANDARD LVCMOS33 [get_ports {start}]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
set_property PACKAGE_PIN V3 [get_ports {led[9]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
set_property PACKAGE_PIN W3 [get_ports {led[10]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
set_property PACKAGE_PIN U3 [get_ports {led[11]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
set_property PACKAGE_PIN P3 [get_ports {led[12]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
set_property PACKAGE_PIN N3 [get_ports {led[13]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
set_property PACKAGE_PIN P1 [get_ports {led[14]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
set_property PACKAGE_PIN L1 [get_ports {led[15]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]



# 7 segment display
 set_property PACKAGE_PIN W7 [get_ports {DISPLAY[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[0]}]
 set_property PACKAGE_PIN W6 [get_ports {DISPLAY[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[1]}]
 set_property PACKAGE_PIN U8 [get_ports {DISPLAY[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[2]}]
 set_property PACKAGE_PIN V8 [get_ports {DISPLAY[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[3]}]
 set_property PACKAGE_PIN U5 [get_ports {DISPLAY[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[4]}]
 set_property PACKAGE_PIN V5 [get_ports {DISPLAY[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[5]}]
 set_property PACKAGE_PIN U7 [get_ports {DISPLAY[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[6]}]

# set_property PACKAGE_PIN V7 [get_ports dp]
#    set_property IOSTANDARD LVCMOS33 [get_ports dp]
#
 set_property PACKAGE_PIN U2 [get_ports {DIGIT[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[0]}]
 set_property PACKAGE_PIN U4 [get_ports {DIGIT[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[1]}]
 set_property PACKAGE_PIN V4 [get_ports {DIGIT[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[2]}]
 set_property PACKAGE_PIN W4 [get_ports {DIGIT[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[3]}]


## Switches
# set_property PACKAGE_PIN V17 [get_ports en]
# set_property IOSTANDARD LVCMOS33 [get_ports en]
# set_property PACKAGE_PIN V16 [get_ports dir]
# set_property IOSTANDARD LVCMOS33 [get_ports dir]
# set_property PACKAGE_PIN W16 [get_ports vmir]
# set_property IOSTANDARD LVCMOS33 [get_ports vmir]
# set_property PACKAGE_PIN W17 [get_ports hmir]
# set_property IOSTANDARD LVCMOS33 [get_ports hmir]

## VGA Connector
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

## USB HID (PS/2)
 set_property PACKAGE_PIN C17 [get_ports PS2_CLK]
    set_property IOSTANDARD LVCMOS33 [get_ports PS2_CLK]
    set_property PULLUP true [get_ports PS2_CLK]
 set_property PACKAGE_PIN B17 [get_ports PS2_DATA]
    set_property IOSTANDARD LVCMOS33 [get_ports PS2_DATA]
    set_property PULLUP true [get_ports PS2_DATA]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

## where 3.3 is the voltage provided to configuration bank 0
    set_property CONFIG_VOLTAGE 3.3 [current_design]
## where value1 is either VCCO(for Vdd=3.3) or GND(for Vdd=1.8)
    set_property CFGBVS VCCO [current_design]

## AUDIO
## Pmod Header JB
## Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {audio_mclk}]
    set_property IOSTANDARD LVCMOS33 [get_ports {audio_mclk}]
## Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {audio_lrck}]
    set_property IOSTANDARD LVCMOS33 [get_ports {audio_lrck}]
## Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {audio_sck}]
    set_property IOSTANDARD LVCMOS33 [get_ports {audio_sck}]
## Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {audio_sdin}]
    set_property IOSTANDARD LVCMOS33 [get_ports {audio_sdin}]