import numpy as np
import struct

N = 512

def f32(x) -> np.float32:
    return np.float32(x)

def f32_to_u32(x: np.float32) -> int:
    # pack float32 -> uint32 bit pattern (IEEE754)
    return struct.unpack(">I", struct.pack(">f", float(x)))[0]

def f32_to_hex(x: np.float32) -> str:
    return f"{f32_to_u32(x):08x}"

def clean_f32(x: np.float32) -> np.float32:
    # tránh -0.0 (hay làm lệch compare theo đường bit)
    if x == np.float32(0.0):
        return np.float32(0.0)

    # tránh subnormal/denormal (nếu core FP của bạn xử lý chưa chuẩn)
    # float32 min normal ~ 1.17549435e-38
    if 0 < abs(float(x)) < 1.17549435e-38:
        return np.float32(0.0)

    return x

def gen_twiddle_hex(filename="twiddle_512.hex"):
    with open(filename, "w") as f:
        for k in range(N):
            theta = -2.0 * np.pi * (k / N)

            wr = f32(np.cos(theta))
            wi = f32(np.sin(theta))

            # làm sạch corner-case
            wr = clean_f32(wr)
            wi = clean_f32(wi)

            # “chốt” một số điểm đặc biệt để khỏi lệch rounding cực nhỏ
            # k = 0 => (1, 0)
            if k == 0:
                wr, wi = np.float32(1.0), np.float32(0.0)
            # k = N/4 => (0, -1)
            if k == N // 4:
                wr, wi = np.float32(0.0), np.float32(-1.0)
            # k = N/2 => (-1, 0)
            if k == N // 2:
                wr, wi = np.float32(-1.0), np.float32(0.0)
            # k = 3N/4 => (0, 1)
            if k == 3 * N // 4:
                wr, wi = np.float32(0.0), np.float32(1.0)

            # 64-bit: {wr}{wi}
            f.write(f"{f32_to_hex(wr)}{f32_to_hex(wi)}\n")

def gen_input_hex(filename="input.hex", amp=0.25, seed=1):
    """
    Sinh input “an toàn”:
    - Biên độ nhỏ (mặc định ±0.25)
    - Giá trị nằm trên lưới bội của 1/256 => biểu diễn float32 rất ổn định
    """
    rng = np.random.default_rng(seed)

    step = 1.0 / 256.0
    max_q = int(round(amp / step))
    grid = (np.arange(-max_q, max_q + 1, dtype=np.int32) * step).astype(np.float32)

    with open(filename, "w") as f:
        for _ in range(N):
            re = f32(rng.choice(grid))
            im = f32(rng.choice(grid))

            re = clean_f32(re)
            im = clean_f32(im)

            f.write(f"{f32_to_hex(re)}{f32_to_hex(im)}\n")

if __name__ == "__main__":
    gen_twiddle_hex("twiddle_512.hex")
    gen_input_hex("input.hex", amp=0.25, seed=2026)
    print("Generated: twiddle_512.hex, input.hex")
