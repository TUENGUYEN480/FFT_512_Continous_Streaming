# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Pipeline optimization for butterfly PE
- Formal verification with JasperGold
- Synthesis scripts for ASIC/FPGA
- Performance benchmarking suite

## [1.0.0] - 2026-02-25

### Added
- Initial release of FFT 512-point continuous streaming implementation
- Complete FFT core with radix-2 DIF algorithm
- Custom floating-point arithmetic units:
  - IEEE 754 single precision adder
  - IEEE 754 single precision multiplier
  - Complex number multiplication
- Butterfly processing element (PE) with complex arithmetic
- Dual RAM architecture (ping-pong buffers) for continuous streaming
- ROM-based twiddle factor storage
- Comprehensive testbench with:
  - Golden DFT model for verification
  - Bit-reverse addressing support
  - Automatic result comparison
- Python verification scripts:
  - Twiddle factor generator (gen_twiddle.py)
  - FFT result verification (verify_fft.py)
- Makefile for simulation automation
- Complete project documentation:
  - README with setup instructions
  - CONTRIBUTING guidelines
  - MIT License
  - .gitignore for version control

### Features
- 512-point FFT transform
- IEEE 754 single precision (32-bit) floating-point
- Complex input/output support
- Continuous streaming capability
- ~5000 clock cycles latency
- < 5% error tolerance vs golden model

### Module Structure
```
00_src/
├── fft_core/          # FFT implementation
├── Adder_Fp/          # FP adder modules
├── mul_FP/            # FP multiplier modules
└── fp_complex_mult_top.sv
01_tb/
└── test_bench_final.sv
02_sim/
├── Makefile
├── gen_twiddle.py
└── verify_fft.py
```

### Testing
- Comprehensive SystemVerilog testbench
- Python-based golden model verification
- Support for Cadence Xcelium simulator
- Automated test flow with Makefile

### Documentation
- Detailed README with usage instructions
- Architecture overview
- Module descriptions
- Setup and installation guide
- Contributing guidelines
- Code of conduct

## Release Notes

### Version 1.0.0 Highlights

This is the first stable release of the FFT 512-Point Continuous Streaming project, developed at BKU (Ho Chi Minh City University of Technology).

**Key Features:**
- Production-ready FFT implementation
- Full IEEE 754 floating-point support
- Verified against golden DFT model
- Ready for synthesis and FPGA implementation

**Target Applications:**
- Digital signal processing
- Audio/video processing
- Wireless communications
- Radar systems
- Spectral analysis

**Known Limitations:**
- Fixed to 512 points (not parameterizable yet)
- Single precision only (no double precision)
- No pipeline stages (combinational butterfly)
- Basic error handling

**Future Work:**
- Parameterizable FFT size
- Pipeline stages for higher frequency
- IFFT (Inverse FFT) support
- Fixed-point arithmetic option
- Synthesis constraints and scripts

---

For more details, see the [README](README.md) and [CONTRIBUTING](CONTRIBUTING.md) files.

[Unreleased]: https://github.com/yourusername/FFT_512_Continous_Streaming/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/FFT_512_Continous_Streaming/releases/tag/v1.0.0
