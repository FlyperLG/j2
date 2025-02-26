create_clock -period 10.000 -name clock -waveform {0.000 5.000} [get_ports clock]

set_property PACKAGE_PIN E3 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]

set_property PACKAGE_PIN C12 [get_ports active_low_reset]
set_property IOSTANDARD LVCMOS33 [get_ports active_low_reset]

set_property PACKAGE_PIN H17 [get_ports led01]
set_property IOSTANDARD LVCMOS33 [get_ports led01]
set_property SLEW FAST [get_ports led01]

set_property PACKAGE_PIN K15 [get_ports led02]
set_property IOSTANDARD LVCMOS33 [get_ports led02]
set_property SLEW FAST [get_ports led02]

set_property PACKAGE_PIN V11 [get_ports led03]
set_property IOSTANDARD LVCMOS33 [get_ports led03]
set_property SLEW FAST [get_ports led03]