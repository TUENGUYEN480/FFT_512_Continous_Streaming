# FFT 512-Point Continuous Streaming

## 📋 Giới thiệu

Dự án này triển khai phép biến đổi Fourier nhanh (Fast Fourier Transform - FFT) 512 điểm với khả năng streaming liên tục, sử dụng ngôn ngữ SystemVerilog. Thiết kế hỗ trợ tính toán số thực dấu phẩy động (floating-point) 32-bit theo chuẩn IEEE 754.

## ✨ Tính năng chính

- **FFT 512 điểm**: Triển khai thuật toán FFT với 512 điểm dữ liệu đầu vào
- **Số phẩy động IEEE 754**: Hỗ trợ tính toán với số thực 32-bit (single precision)
- **Butterfly Processing Element**: Đơn vị xử lý butterfly tối ưu cho FFT
- **Dual RAM Architecture**: Kiến trúc ping-pong buffer với 2 RAM để streaming liên tục
- **Twiddle Factor ROM**: Bộ nhớ ROM chứa các hệ số xoắn (twiddle factors) được tính sẵn
- **Custom Floating-Point Units**: 
  - FP Adder/Subtractor tùy chỉnh
  - FP Multiplier tùy chỉnh
  - Complex number multiplication

## 🏗️ Cấu trúc dự án

```
FFT_512_Continous_Streaming/
├── 00_src/                          # Source files
│   ├── fft_core/                    # FFT core modules
│   │   ├── fft_top.sv              # Top-level FFT module
│   │   ├── fft_control.sv          # FSM control logic
│   │   ├── butterfly_pe.sv         # Butterfly processing element
│   │   ├── ram_sp.sv               # Single-port RAM
│   │   └── rom_twiddle.sv          # Twiddle factor ROM
│   ├── Adder_Fp/                    # Floating-point adder
│   │   ├── TOP/
│   │   │   └── FP_ADDER_TOP.sv    # FP adder top module
│   │   ├── Adder/                  # Adder sub-modules
│   │   ├── LZC/                    # Leading zero counter
│   │   └── Normalization/          # Normalization logic
│   ├── mul_FP/                      # Floating-point multiplier
│   │   ├── FP_multiplier_top.sv   # FP multiplier top module
│   │   └── mul_unsign_24_bit/     # 24-bit unsigned multiplier
│   └── fp_complex_mult_top.sv      # Complex multiplication wrapper
├── 01_tb/                           # Testbenches
│   └── test_bench_final.sv         # Main FFT testbench
├── 02_sim/                          # Simulation files
│   ├── Makefile                    # Simulation makefile
│   ├── gen_twiddle.py              # Twiddle factor generator
│   └── verify_fft.py               # Python verification script
└── README.md                        # This file
```

## 🔧 Yêu cầu hệ thống

### Phần mềm cần thiết:
- **Cadence Xcelium** hoặc simulator SystemVerilog tương đương
- **Python 3.x** (cho scripts verification)
- **Make** utility

### Thư viện Python:
```bash
pip install numpy matplotlib
```

## 🚀 Hướng dẫn sử dụng

### 1. Clone repository

```bash
git clone https://github.com/yourusername/FFT_512_Continous_Streaming.git
cd FFT_512_Continous_Streaming
```

### 2. Generate Twiddle Factors

```bash
cd 02_sim
python gen_twiddle.py
```

### 3. Chạy simulation

```bash
# Chạy simulation không GUI
make sim

# Chạy simulation với GUI
make gui

# Xem waveform
make wave
```

### 4. Verify kết quả

```bash
python verify_fft.py
```

### 5. Clean simulation files

```bash
# Clean files tạm
make clean

# Clean toàn bộ (chỉ giữ source files)
make distclean
```

## 📊 Kiến trúc FFT

### Thuật toán
- **Radix-2 Decimation-in-Frequency (DIF)** FFT
- **9 stages** của butterfly operations (log₂(512) = 9)
- **Ping-pong buffer** architecture để tối ưu throughput

### Butterfly Processing Element
Mỗi butterfly PE thực hiện:
```
A' = A + W×B
B' = A - W×B
```
Trong đó W là twiddle factor (hệ số xoắn)

### Twiddle Factors
- Được tính trước và lưu trong ROM
- Format: IEEE 754 single precision (32-bit)
- Công thức: W(k,N) = e^(-j2πk/N)

## 🎯 Thông số kỹ thuật

| Thông số | Giá trị |
|----------|---------|
| FFT Size | 512 points |
| Data Format | IEEE 754 Single Precision (32-bit) |
| Input Format | Complex (Real + Imaginary) |
| Output Format | Complex (Real + Imaginary) |
| RAM Depth | 512 words × 64 bits |
| ROM Depth | 512 words × 64 bits |
| Clock Cycles | ~5000 cycles (typical) |

## 📈 Performance

- **Latency**: ~5000 clock cycles cho 1 FFT transform
- **Throughput**: Hỗ trợ streaming liên tục với ping-pong buffer
- **Accuracy**: Tolerance < 5% so với golden model (DFT)

## 🧪 Testing & Verification

### Testbench Features:
- Tự động generate input test vectors
- So sánh với golden DFT (Discrete Fourier Transform)
- Tính toán error và hiển thị kết quả
- Hỗ trợ bit-reverse addressing

### Verification Flow:
1. Generate random input signals
2. Calculate expected output (DFT)
3. Run FFT hardware simulation
4. Compare results với tolerance threshold
5. Report pass/fail status

## 📝 Module chính

### fft_top.sv
Module top-level của FFT, tích hợp:
- 2× Single-port RAM (ping-pong buffers)
- ROM chứa twiddle factors
- Butterfly processing element
- FSM control logic

### butterfly_pe.sv
Đơn vị xử lý butterfly với:
- Complex multiplication (A × W)
- Complex addition/subtraction
- Pipeline architecture

### FP_ADDER_TOP.sv
Bộ cộng số phẩy động với:
- Support cho close path và far path
- Normalization và rounding
- Special cases handling (NaN, Infinity, Zero)

### FP_multiplier_top.sv
Bộ nhân số phẩy động với:
- 24-bit mantissa multiplication (Wallace tree)
- Exponent addition
- Normalization và rounding

## 🐛 Debug & Troubleshooting

### Lỗi thường gặp:

1. **Compilation errors**
   - Kiểm tra file list trong `flist.f`
   - Đảm bảo tất cả module được include

2. **Simulation không chạy**
   - Kiểm tra Xcelium được cài đặt đúng
   - Verify license của simulator

3. **Kết quả không chính xác**
   - Tăng tolerance threshold trong testbench
   - Kiểm tra twiddle factors được generate đúng

## 🤝 Contributing

Contributions are welcome! Vui lòng:
1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Dự án này được phân phối dưới giấy phép MIT License - xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 👥 Authors

- **Nguyen** - *Initial work*

## 🙏 Acknowledgments

- Đại học Bách Khoa (BKU)
- IEEE 754 Floating-Point Standard
- Cooley-Tukey FFT Algorithm

## 📚 Tài liệu tham khảo

1. "Understanding Digital Signal Processing" - Richard G. Lyons
2. IEEE 754-2008 Standard for Floating-Point Arithmetic
3. "VLSI Digital Signal Processing Systems" - Keshab K. Parhi

## 📧 Contact

Nếu có câu hỏi hoặc góp ý, vui lòng:
- Mở issue trên GitHub
- Email: [your-email@example.com]

---

**Note**: Dự án này được phát triển cho mục đích học tập và nghiên cứu.
