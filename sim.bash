# Compile verilog code to executable with icarus
iverilog -o build/sim.vvp cpu.sv cpu_tb.sv

# Run the simulation
vvp build/sim.vvp 

# Observe the waveform
gtkwave build/waveform.vcd