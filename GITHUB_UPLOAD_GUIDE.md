# Hướng dẫn Upload Project lên GitHub

## 📋 Chuẩn bị

### 1. Tạo Repository trên GitHub

1. Đăng nhập vào [GitHub](https://github.com)
2. Click vào dấu **+** ở góc phải trên, chọn **New repository**
3. Điền thông tin:
   - **Repository name**: `FFT_512_Continous_Streaming`
   - **Description**: `512-Point FFT Implementation with Continuous Streaming in SystemVerilog`
   - **Visibility**: Public hoặc Private (tùy chọn)
   - **KHÔNG** tích "Initialize with README" (vì đã có sẵn)
4. Click **Create repository**

### 2. Cài đặt Git (nếu chưa có)

**Windows**:
```powershell
# Download từ https://git-scm.com/download/win
# Hoặc dùng Chocolatey:
choco install git
```

**Kiểm tra Git**:
```bash
git --version
```

### 3. Config Git (lần đầu tiên)

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

## 🚀 Upload Project lên GitHub

### Bước 1: Mở Terminal tại thư mục project

```bash
cd c:\Users\nguye\Desktop\BKU\FFT_512_Continous_Streaming\FFT_512_Continous_Streaming
```

### Bước 2: Initialize Git Repository

```bash
# Khởi tạo Git repo
git init

# Kiểm tra status
git status
```

### Bước 3: Add files vào Git

```bash
# Add tất cả files (trừ những file trong .gitignore)
git add .

# Kiểm tra files sẽ được commit
git status
```

### Bước 4: Commit

```bash
# Commit với message
git commit -m "Initial commit: FFT 512-Point Continuous Streaming implementation"
```

### Bước 5: Connect với GitHub Repository

```bash
# Thay YOUR_USERNAME bằng username GitHub của bạn
git remote add origin https://github.com/YOUR_USERNAME/FFT_512_Continous_Streaming.git

# Hoặc dùng SSH (nếu đã setup SSH key)
# git remote add origin git@github.com:YOUR_USERNAME/FFT_512_Continous_Streaming.git

# Kiểm tra remote
git remote -v
```

### Bước 6: Push lên GitHub

```bash
# Push to main branch
git branch -M main
git push -u origin main
```

### Nếu gặp lỗi authentication:

**Windows - Dùng Personal Access Token (PAT)**:

1. Vào GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Chọn scopes: `repo`, `workflow`
4. Copy token (CHỈ HIỆN 1 LẦN!)
5. Khi push, dùng PAT thay cho password:
   ```bash
   Username: YOUR_USERNAME
   Password: YOUR_PERSONAL_ACCESS_TOKEN
   ```

## ✅ Verify Upload

1. Vào repository trên GitHub
2. Refresh trang
3. Kiểm tra các files đã được upload

## 📝 Các bước tiếp theo (Optional)

### 1. Thêm Topics cho Repository

Trên trang GitHub repository:
- Click vào ⚙️ (Settings icon) bên cạnh About
- Thêm topics: `fft`, `systemverilog`, `fpga`, `dsp`, `digital-signal-processing`, `ieee-754`, `floating-point`

### 2. Tạo Release (Version 1.0.0)

```bash
# Tạo tag cho version 1.0.0
git tag -a v1.0.0 -m "Version 1.0.0 - Initial Release"

# Push tag lên GitHub
git push origin v1.0.0
```

Sau đó trên GitHub:
- Vào tab "Releases"
- Click "Create a new release"
- Chọn tag `v1.0.0`
- Điền Release notes từ CHANGELOG.md
- Click "Publish release"

### 3. Enable GitHub Pages (cho documentation)

1. Settings → Pages
2. Source: Deploy from a branch
3. Branch: main, folder: / (root)
4. Save

### 4. Add Badges vào README

Thêm vào đầu README.md:

```markdown
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![SystemVerilog](https://img.shields.io/badge/SystemVerilog-IEEE%201800-orange)
![FFT](https://img.shields.io/badge/FFT-512--point-green)
![Status](https://img.shields.io/badge/status-stable-brightgreen)
```

## 🔄 Update Project sau này

Khi có thay đổi:

```bash
# 1. Kiểm tra files thay đổi
git status

# 2. Add files đã thay đổi
git add .
# Hoặc add từng file cụ thể
git add path/to/modified/file.sv

# 3. Commit
git commit -m "feat: Add new feature description"

# 4. Push lên GitHub
git push
```

## 📊 Git Workflow thông dụng

### Tạo branch mới cho feature

```bash
# Tạo và chuyển sang branch mới
git checkout -b feature/new-feature

# Làm việc và commit
git add .
git commit -m "feat: Implement new feature"

# Push branch lên GitHub
git push -u origin feature/new-feature
```

### Merge branch về main

```bash
# Chuyển về main
git checkout main

# Merge branch
git merge feature/new-feature

# Push lên GitHub
git push
```

## 🐛 Troubleshooting

### Lỗi: "remote origin already exists"

```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/FFT_512_Continous_Streaming.git
```

### Lỗi: "failed to push some refs"

```bash
# Pull trước khi push
git pull origin main --rebase
git push origin main
```

### Xóa file khỏi Git nhưng giữ trong local

```bash
git rm --cached file-to-remove
git commit -m "Remove file from Git"
git push
```

### Undo commit cuối cùng (chưa push)

```bash
git reset --soft HEAD~1
```

## 📚 Tài liệu tham khảo

- [GitHub Docs](https://docs.github.com)
- [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- [Git Cheat Sheet](https://training.github.com/downloads/github-git-cheat-sheet.pdf)

## ✨ Tips

1. **Commit thường xuyên**: Commit các thay đổi nhỏ thay vì 1 commit lớn
2. **Viết commit message rõ ràng**: Tuân theo format trong CONTRIBUTING.md
3. **Sử dụng .gitignore**: Tránh commit files không cần thiết
4. **Review trước khi push**: Kiểm tra `git status` và `git diff`
5. **Tạo branches**: Dùng branches cho features mới, không commit trực tiếp vào main

---

