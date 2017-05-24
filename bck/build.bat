@echo off
echo Analyzing test/testbench.vhd test/ram.vhd and src/*.vhd
ghdl -a --ieee=synopsys -fexplicit --workdir=simu --work=work test/testbench.vhd test/ram.vhd src/*.vhd
echo Elaborating testbench
ghdl -e --ieee=synopsys -fexplicit --workdir=simu --work=work testbench
echo Running testbench
ghdl -r --ieee=synopsys -fexplicit --workdir=simu --work=work testbench --vcd=results.vcd --stop-time=40us --ieee-asserts=disable
pause