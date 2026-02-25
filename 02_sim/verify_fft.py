import numpy as np
import struct

def hex_to_float(h):
    # Chuyển 8 ký tự hex thành số float 32-bit
    return struct.unpack('>f', bytes.fromhex(h))[0]

def float_to_hex(f):
    # Chuyển số float 32-bit thành 8 ký tự hex
    return format(struct.unpack('>I', struct.pack('>f', np.float32(f)))[0], '08x')

def generate_golden(N=512):
    print(f"--- Đang tạo Golden Model cho {N}-point FFT ---")
    
    # 1. Đọc dữ liệu từ input.hex
    input_data = []
    try:
        with open('input.hex', 'r') as f:
            for line in f:
                line = line.strip()
                if not line: continue
                real_part = hex_to_float(line[0:8])
                imag_part = hex_to_float(line[8:16])
                input_data.append(complex(real_part, imag_part))
    except FileNotFoundError:
        print("Lỗi: Không tìm thấy file input.hex!")
        return

    # 2. Tính toán FFT chuẩn (Golden Model)
    x = np.array(input_data)
    golden_fft = np.fft.fft(x)

    # 3. Ghi kết quả ra file golden_out.hex
    with open('golden_out.hex', 'w') as f:
        for val in golden_fft:
            r_hex = float_to_hex(val.real)
            i_hex = float_to_hex(val.imag)
            f.write(f"{r_hex}{i_hex}\n")
    
    print("Thành công: Đã tạo file golden_out.hex")

    # 4. So sánh nhanh với rtl_out.hex (nếu có)
    try:
        with open('rtl_out.hex', 'r') as f:
            rtl_data = [line.strip() for line in f if line.strip()]
        
        # Kiểm tra sai số (tùy chọn)
        print("\n--- So sánh nhanh Golden vs RTL ---")
        max_diff = 0
        for k in range(N):
            g_r = golden_fft[k].real
            g_i = golden_fft[k].imag
            r_r = hex_to_float(rtl_data[k][0:8])
            r_i = hex_to_float(rtl_data[k][8:16])
            
            diff = abs(complex(g_r, g_i) - complex(r_r, r_i))
            if diff > max_diff: max_diff = diff
            
        print(f"Sai số lớn nhất (Absolute Error): {max_diff:.8f}")
    except FileNotFoundError:
        print("Lưu ý: Chưa có file rtl_out.hex để so sánh.")

if __name__ == "__main__":
    generate_golden(512)
