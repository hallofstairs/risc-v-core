trap 'kill_gtkwave' INT

# Function to kill the GTKWave process
kill_gtkwave() {
    gtkwave_pid=$(pgrep gtkwave)
    if [ -n "$gtkwave_pid" ]; then
        kill $gtkwave_pid
        echo "GTKWave process terminated."
    fi
    exit 1
}

# Compile verilog code to executable with icarus
iverilog -g2012 -o build/sim.vvp cpu.sv cpu_tb.sv

# Run the simulation
vvp build/sim.vvp 

# Observe the waveform
gtkwave build/waveform.vcd &

# Wait for the GTKWave process to finish
wait