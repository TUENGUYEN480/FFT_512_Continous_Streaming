# Contributing to FFT 512-Point Continuous Streaming

Cảm ơn bạn đã quan tâm đến việc đóng góp cho dự án! Dưới đây là hướng dẫn để giúp bạn bắt đầu.

## 🔧 Quy trình đóng góp

### 1. Fork và Clone

```bash
# Fork repository trên GitHub, sau đó:
git clone https://github.com/your-username/FFT_512_Continous_Streaming.git
cd FFT_512_Continous_Streaming
```

### 2. Tạo Branch mới

```bash
git checkout -b feature/your-feature-name
# hoặc
git checkout -b bugfix/issue-description
```

### 3. Coding Standards

#### SystemVerilog Code Style
- **Indentation**: Sử dụng 4 spaces (không dùng tabs)
- **Naming conventions**:
  - Modules: `snake_case` (ví dụ: `fft_top`, `butterfly_pe`)
  - Signals: `snake_case` (ví dụ: `clk`, `rst_n`, `data_valid`)
  - Parameters: `UPPER_CASE` (ví dụ: `DATA_WIDTH`, `ADDR_WIDTH`)
  - Constants: `UPPER_CASE`
- **Comments**: Sử dụng tiếng Anh hoặc tiếng Việt nhất quán
- **File headers**: Thêm header mô tả module

```systemverilog
//============================================================================
// Module: module_name
// Description: Brief description of the module
// Author: Your Name
// Date: YYYY-MM-DD
//============================================================================
```

#### Python Code Style
- Follow PEP 8
- Sử dụng 4 spaces cho indentation
- Docstrings cho functions và classes
- Type hints khi có thể

### 4. Testing

Trước khi commit, đảm bảo:

```bash
# Chạy simulation
cd 02_sim
make sim

# Verify kết quả
python verify_fft.py

# Clean up
make clean
```

### 5. Commit Messages

Format commit messages:

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat`: Tính năng mới
- `fix`: Bug fix
- `docs`: Cập nhật documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Thêm/sửa tests
- `chore`: Maintenance tasks

**Ví dụ:**
```
feat: Add pipelined butterfly processing element

- Implement 3-stage pipeline for butterfly PE
- Reduce critical path delay by 30%
- Update testbench to verify pipelined operation

Closes #123
```

### 6. Pull Request

1. Push branch của bạn:
```bash
git push origin feature/your-feature-name
```

2. Mở Pull Request trên GitHub
3. Mô tả rõ ràng:
   - Mục đích của thay đổi
   - Các test cases đã chạy
   - Screenshots/waveforms nếu cần
   - Liên kết đến issues liên quan

## 📋 Checklist trước khi submit PR

- [ ] Code tuân theo style guide
- [ ] Đã thêm/cập nhật comments và documentation
- [ ] Simulation pass without errors
- [ ] Verification scripts pass
- [ ] Không có warnings không cần thiết
- [ ] Cập nhật README.md nếu cần
- [ ] Branch được sync với main/master

## 🐛 Báo cáo Bug

Khi báo cáo bug, vui lòng bao gồm:

1. **Mô tả bug**: Mô tả rõ ràng và ngắn gọn
2. **Các bước tái hiện**:
   - Bước 1
   - Bước 2
   - ...
3. **Kết quả mong đợi**: Điều gì nên xảy ra
4. **Kết quả thực tế**: Điều gì đã xảy ra
5. **Screenshots/Waveforms**: Nếu có
6. **Environment**:
   - OS: [e.g., Ubuntu 20.04]
   - Simulator: [e.g., Xcelium 20.09]
   - Python version: [e.g., 3.8]

## 💡 Đề xuất tính năng

Khi đề xuất tính năng mới:

1. **Mô tả tính năng**: Giải thích rõ ràng tính năng
2. **Use case**: Tại sao tính năng này hữu ích?
3. **Implementation ideas**: Ý tưởng cách implement (nếu có)
4. **Alternatives**: Các phương án khác đã xem xét

## 📚 Development Setup

### Cài đặt môi trường phát triển:

```bash
# Clone repository
git clone https://github.com/yourusername/FFT_512_Continous_Streaming.git

# Cài đặt Python dependencies
pip install numpy matplotlib scipy

# Verify simulation environment
cd 02_sim
make sim
```

### Công cụ hữu ích:
- **Linter**: SystemVerilog linters (sv-parser, svlint)
- **Formatter**: Verible formatter
- **Wave viewer**: SimVision, GTKWave

## 🎯 Areas for Contribution

Các lĩnh vực cần đóng góp:

### High Priority:
- [ ] Tối ưu timing và area
- [ ] Thêm pipeline stages
- [ ] Power optimization
- [ ] Formal verification scripts

### Medium Priority:
- [ ] Cải thiện documentation
- [ ] Thêm test cases
- [ ] Performance benchmarking
- [ ] Synthesis scripts

### Low Priority:
- [ ] Code refactoring
- [ ] Style improvements
- [ ] Additional examples

## ❓ Questions?

Nếu bạn có câu hỏi:
1. Kiểm tra [Issues](https://github.com/yourusername/FFT_512_Continous_Streaming/issues)
2. Mở issue mới với label "question"
3. Email: your-email@example.com

## 🙏 Code of Conduct

- Tôn trọng tất cả contributors
- Constructive feedback
- Chấp nhận các quan điểm khác nhau
- Tập trung vào cái tốt nhất cho project

---

Cảm ơn bạn đã đóng góp! 🚀
