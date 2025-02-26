create_clock -period 10.000 -name clock -waveform {0.000 5.000} [get_ports clock]

set_property PACKAGE_PIN E3 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]

set_property PACKAGE_PIN C12 [get_ports active_low_reset]
set_property IOSTANDARD LVCMOS33 [get_ports active_low_reset]

set_property PACKAGE_PIN C4 [get_ports RXD]
set_property IOSTANDARD LVCMOS33 [get_ports RXD]

set_property PACKAGE_PIN D4 [get_ports TXD]
set_property IOSTANDARD LVCMOS33 [get_ports TXD]


set_property PACKAGE_PIN H17 [get_ports led01]
set_property IOSTANDARD LVCMOS33 [get_ports led01]
set_property SLEW FAST [get_ports led01]

set_property PACKAGE_PIN K15 [get_ports led02]
set_property IOSTANDARD LVCMOS33 [get_ports led02]
set_property SLEW FAST [get_ports led02]

set_property PACKAGE_PIN J13 [get_ports led03]
set_property IOSTANDARD LVCMOS33 [get_ports led03]
set_property SLEW FAST [get_ports led03]

set_property PACKAGE_PIN N14 [get_ports led04]
set_property IOSTANDARD LVCMOS33 [get_ports led04]
set_property SLEW FAST [get_ports led04]

set_property PACKAGE_PIN R18 [get_ports led05]
set_property IOSTANDARD LVCMOS33 [get_ports led05]
set_property SLEW FAST [get_ports led05]

set_property PACKAGE_PIN V17 [get_ports led06]
set_property IOSTANDARD LVCMOS33 [get_ports led06]
set_property SLEW FAST [get_ports led06]

set_property PACKAGE_PIN U17 [get_ports led07]
set_property IOSTANDARD LVCMOS33 [get_ports led07]
set_property SLEW FAST [get_ports led07]

set_property PACKAGE_PIN U16 [get_ports led08]
set_property IOSTANDARD LVCMOS33 [get_ports led08]
set_property SLEW FAST [get_ports led08]

set_property PACKAGE_PIN V16 [get_ports led09]
set_property IOSTANDARD LVCMOS33 [get_ports led09]
set_property SLEW FAST [get_ports led09]

set_property PACKAGE_PIN T15 [get_ports led10]
set_property IOSTANDARD LVCMOS33 [get_ports led10]
set_property SLEW FAST [get_ports led10]

set_property PACKAGE_PIN U14 [get_ports led11]
set_property IOSTANDARD LVCMOS33 [get_ports led11]
set_property SLEW FAST [get_ports led11]

set_property PACKAGE_PIN T16 [get_ports led12]
set_property IOSTANDARD LVCMOS33 [get_ports led12]
set_property SLEW FAST [get_ports led12]

set_property PACKAGE_PIN V15 [get_ports led13]
set_property IOSTANDARD LVCMOS33 [get_ports led13]
set_property SLEW FAST [get_ports led13]

set_property PACKAGE_PIN V14 [get_ports led14]
set_property IOSTANDARD LVCMOS33 [get_ports led14]
set_property SLEW FAST [get_ports led14]

set_property PACKAGE_PIN V12 [get_ports led15]
set_property IOSTANDARD LVCMOS33 [get_ports led15]
set_property SLEW FAST [get_ports led15]

set_property PACKAGE_PIN V11 [get_ports led16]
set_property IOSTANDARD LVCMOS33 [get_ports led16]
set_property SLEW FAST [get_ports led16]