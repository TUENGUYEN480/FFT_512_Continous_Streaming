# Quick Start Guide

## 📦 Installation

### Prerequisites

1. **Simulator** (choose one):
   - Cadence Xcelium (recommended)
   - Synopsys VCS
   - Mentor ModelSim/QuestaSim

2. **Python 3.x**:
   ```bash
   python --version  # Should be 3.6+
   ```

3. **Required Python packages**:
   ```bash
   pip install numpy matplotlib scipy
   ```

### Clone Repository

```bash
git clone https://github.com/yourusername/FFT_512_Continous_Streaming.git
cd FFT_512_Continous_Streaming
```

## 🚀 Quick Start

### 1. Generate Twiddle Factors (First Time Only)

```bash
cd 02_sim
python gen_twiddle.py
```

This creates the twiddle factor ROM initialization file.

### 2. Run Your First Simulation

```bash
# Simple simulation (no GUI)
make sim
```

You should see output similar to:
```
-> SIMULATION
xrun +xm64bit -sv ...
...
[PASS] FFT verification successful!
Simulation completed successfully
```

### 3. View Waveforms (Optional)

```bash
# Run with GUI
make gui

# Or view saved waveforms
make wave
```

## 📊 Understanding the Output

### Console Output

The testbench will display:
```
==================================================
FFT 512-Point Verification Testbench
==================================================
[INFO] Loading input data...
[INFO] Starting FFT computation...
[INFO] FFT computation done after XXXX cycles
[INFO] Reading output data...
[INFO] Comparing with golden model...
[PASS] Point 0: Match (error < 0.1%)
[PASS] Point 1: Match (error < 0.1%)
...
[PASS] All 512 points verified successfully!
==================================================
```

### Waveform Signals to Observe

Key signals in SimVision:
- `clk` - System clock
- `rst_n` - Active-low reset
- `start` - Start FFT computation
- `done` - FFT computation complete
- `ext_data_in[63:0]` - Input data (Real[31:0] + Imag[31:0])
- `ext_data_out[63:0]` - Output data (Real[31:0] + Imag[31:0])

## 🎯 Common Use Cases

### Run Multiple Simulations

```bash
# Run 10 simulations with different random seeds
for i in {1..10}; do
    make sim
done
```

### Custom Test Vectors

Edit [test_bench_final.sv](01_tb/test_bench_final.sv) and modify the input generation:

```systemverilog
// Example: Sine wave input
for (int i = 0; i < N; i++) begin
    x_in_re[i] = $sin(2.0 * 3.14159 * i / N);
    x_in_im[i] = 0.0;
end
```

### Clean Up

```bash
# Remove simulation outputs
make clean

# Full clean (keep only source files)
make distclean
```

## 🐛 Troubleshooting

### Issue: "xrun: command not found"

**Solution**: Source Cadence tools:
```bash
source /path/to/cadence/xcelium/setup.sh
# Or add to your .bashrc
```

### Issue: "Python module not found"

**Solution**: Install required packages:
```bash
pip install numpy matplotlib scipy
```

### Issue: Simulation fails with "Unknown module"

**Solution**: Check file list in [00_src/flist.f](00_src/flist.f)
```bash
cd 00_src
cat flist.f  # Verify all paths are correct
```

### Issue: Results don't match

**Solution**: Check tolerance settings in testbench:
```systemverilog
parameter shortreal TOLERANCE = 0.05; // 5% error allowed
```

## 📚 Next Steps

1. **Explore the Code**:
   - Read [README.md](README.md) for architecture details
   - Check module descriptions in source files

2. **Modify and Experiment**:
   - Try different input signals
   - Adjust FFT parameters
   - Add custom processing

3. **Contribute**:
   - Read [CONTRIBUTING.md](CONTRIBUTING.md)
   - Submit issues or pull requests

## 💡 Tips

- **Performance**: Use `make sim` for faster runs without GUI
- **Debugging**: Use `make gui` to inspect waveforms
- **Verification**: Check Python scripts for golden model
- **Documentation**: All modules have inline comments

## 📞 Need Help?

- Check [Issues](https://github.com/yourusername/FFT_512_Continous_Streaming/issues)
- Read [FAQ](#faq) section in README
- Contact: your-email@example.com

---

Happy coding! 🎉
