-- =====================================================================
-- HỆ THỐNG QUẢN LÝ KHO VÀ TỒN KHO – Script cơ sở dữ liệu (MySQL 8.0)
-- Phần 1: Tạo database và bảng   Phần 2: Dữ liệu mẫu
-- Phần 3: Truy vấn nghiệp vụ     Phần 4: Thủ tục lưu trữ (tùy chọn)
-- =====================================================================

DROP DATABASE IF EXISTS quan_ly_kho;
CREATE DATABASE quan_ly_kho CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE quan_ly_kho;
SET NAMES utf8mb4;

-- ---------- PHẦN 1: TẠO BẢNG ----------
CREATE TABLE VaiTro (
  MaVaiTro VARCHAR(20) NOT NULL,
  TenVaiTro VARCHAR(50) NOT NULL UNIQUE,
  MoTa VARCHAR(200) NULL,
  PRIMARY KEY (MaVaiTro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE NguoiDung (
  MaND VARCHAR(20) NOT NULL,
  TenDangNhap VARCHAR(50) NOT NULL UNIQUE,
  MatKhauHash VARCHAR(255) NOT NULL,
  HoTen VARCHAR(100) NOT NULL,
  Email VARCHAR(100) NULL,
  MaVaiTro VARCHAR(20) NOT NULL,
  TrangThai ENUM('HoatDong','VoHieuHoa') NOT NULL DEFAULT 'HoatDong',
  NgayTao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (MaND),
  CONSTRAINT fk_NguoiDung_MaVaiTro FOREIGN KEY (MaVaiTro) REFERENCES VaiTro(MaVaiTro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE LoaiSanPham (
  MaLoai VARCHAR(20) NOT NULL,
  TenLoai VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (MaLoai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE SanPham (
  MaSP VARCHAR(20) NOT NULL,
  TenSP VARCHAR(150) NOT NULL,
  MaLoai VARCHAR(20) NOT NULL,
  DonViTinh VARCHAR(20) NOT NULL,
  MucTonToiThieu INT NOT NULL DEFAULT 0,
  TrangThai ENUM('KinhDoanh','NgungKinhDoanh') NOT NULL DEFAULT 'KinhDoanh',
  PRIMARY KEY (MaSP),
  CONSTRAINT fk_SanPham_MaLoai FOREIGN KEY (MaLoai) REFERENCES LoaiSanPham(MaLoai),
  CHECK (MucTonToiThieu >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE NhaCungCap (
  MaNCC VARCHAR(20) NOT NULL,
  TenNCC VARCHAR(150) NOT NULL,
  SoDienThoai VARCHAR(20) NULL,
  DiaChi VARCHAR(255) NULL,
  PRIMARY KEY (MaNCC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Kho (
  MaKho VARCHAR(20) NOT NULL,
  TenKho VARCHAR(100) NOT NULL,
  ViTri VARCHAR(255) NULL,
  PRIMARY KEY (MaKho)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE TonKho (
  MaKho VARCHAR(20) NOT NULL,
  MaSP VARCHAR(20) NOT NULL,
  SoLuong INT NOT NULL DEFAULT 0,
  PRIMARY KEY (MaKho, MaSP),
  CONSTRAINT fk_TonKho_MaKho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
  CONSTRAINT fk_TonKho_MaSP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
  CHECK (SoLuong >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE PhieuNhap (
  MaPN VARCHAR(20) NOT NULL,
  NgayNhap DATE NOT NULL,
  MaKho VARCHAR(20) NOT NULL,
  MaNCC VARCHAR(20) NOT NULL,
  MaNguoiLap VARCHAR(20) NOT NULL,
  TrangThai ENUM('Nhap','DaXacNhan','DaHuy') NOT NULL DEFAULT 'Nhap',
  NgayXacNhan DATETIME NULL,
  GhiChu VARCHAR(255) NULL,
  PRIMARY KEY (MaPN),
  CONSTRAINT fk_PhieuNhap_MaKho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
  CONSTRAINT fk_PhieuNhap_MaNCC FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC),
  CONSTRAINT fk_PhieuNhap_MaNguoiLap FOREIGN KEY (MaNguoiLap) REFERENCES NguoiDung(MaND)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE ChiTietPhieuNhap (
  MaPN VARCHAR(20) NOT NULL,
  MaSP VARCHAR(20) NOT NULL,
  SoLuong INT NOT NULL,
  PRIMARY KEY (MaPN, MaSP),
  CONSTRAINT fk_ChiTietPhieuNhap_MaPN FOREIGN KEY (MaPN) REFERENCES PhieuNhap(MaPN),
  CONSTRAINT fk_ChiTietPhieuNhap_MaSP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
  CHECK (SoLuong > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE PhieuXuat (
  MaPX VARCHAR(20) NOT NULL,
  NgayXuat DATE NOT NULL,
  MaKho VARCHAR(20) NOT NULL,
  NguoiNhan VARCHAR(100) NOT NULL,
  MaNguoiLap VARCHAR(20) NOT NULL,
  TrangThai ENUM('Nhap','DaXacNhan','DaHuy') NOT NULL DEFAULT 'Nhap',
  NgayXacNhan DATETIME NULL,
  GhiChu VARCHAR(255) NULL,
  PRIMARY KEY (MaPX),
  CONSTRAINT fk_PhieuXuat_MaKho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
  CONSTRAINT fk_PhieuXuat_MaNguoiLap FOREIGN KEY (MaNguoiLap) REFERENCES NguoiDung(MaND)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE ChiTietPhieuXuat (
  MaPX VARCHAR(20) NOT NULL,
  MaSP VARCHAR(20) NOT NULL,
  SoLuong INT NOT NULL,
  PRIMARY KEY (MaPX, MaSP),
  CONSTRAINT fk_ChiTietPhieuXuat_MaPX FOREIGN KEY (MaPX) REFERENCES PhieuXuat(MaPX),
  CONSTRAINT fk_ChiTietPhieuXuat_MaSP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
  CHECK (SoLuong > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE KiemKe (
  MaKK VARCHAR(20) NOT NULL,
  MaKho VARCHAR(20) NOT NULL,
  NgayKiemKe DATE NOT NULL,
  MaNguoiThucHien VARCHAR(20) NOT NULL,
  TrangThai ENUM('DangKiemKe','HoanThanh') NOT NULL DEFAULT 'DangKiemKe',
  GhiChu VARCHAR(255) NULL,
  PRIMARY KEY (MaKK),
  CONSTRAINT fk_KiemKe_MaKho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
  CONSTRAINT fk_KiemKe_MaNguoiThucHien FOREIGN KEY (MaNguoiThucHien) REFERENCES NguoiDung(MaND)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE ChiTietKiemKe (
  MaKK VARCHAR(20) NOT NULL,
  MaSP VARCHAR(20) NOT NULL,
  SoLuongHeThong INT NOT NULL,
  SoLuongThucTe INT NOT NULL,
  ChenhLech INT GENERATED ALWAYS AS (SoLuongThucTe - SoLuongHeThong) STORED,
  PRIMARY KEY (MaKK, MaSP),
  CONSTRAINT fk_ChiTietKiemKe_MaKK FOREIGN KEY (MaKK) REFERENCES KiemKe(MaKK),
  CONSTRAINT fk_ChiTietKiemKe_MaSP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
  CHECK (SoLuongHeThong >= 0),
  CHECK (SoLuongThucTe >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE DieuChinhTonKho (
  MaDC VARCHAR(20) NOT NULL,
  MaKho VARCHAR(20) NOT NULL,
  MaSP VARCHAR(20) NOT NULL,
  SoLuongDieuChinh INT NOT NULL,
  LyDo VARCHAR(255) NOT NULL,
  MaKK VARCHAR(20) NULL,
  MaNguoiDeXuat VARCHAR(20) NOT NULL,
  NgayDeXuat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  TrangThai ENUM('ChoDuyet','DaDuyet','TuChoi') NOT NULL DEFAULT 'ChoDuyet',
  MaNguoiDuyet VARCHAR(20) NULL,
  NgayDuyet DATETIME NULL,
  LyDoTuChoi VARCHAR(255) NULL,
  PRIMARY KEY (MaDC),
  CONSTRAINT fk_DieuChinhTonKho_MaKho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
  CONSTRAINT fk_DieuChinhTonKho_MaSP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
  CONSTRAINT fk_DieuChinhTonKho_MaKK FOREIGN KEY (MaKK) REFERENCES KiemKe(MaKK),
  CONSTRAINT fk_DieuChinhTonKho_MaNguoiDeXuat FOREIGN KEY (MaNguoiDeXuat) REFERENCES NguoiDung(MaND),
  CONSTRAINT fk_DieuChinhTonKho_MaNguoiDuyet FOREIGN KEY (MaNguoiDuyet) REFERENCES NguoiDung(MaND),
  CHECK (SoLuongDieuChinh <> 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE LichSuGiaoDich (
  MaLS BIGINT NOT NULL AUTO_INCREMENT,
  LoaiGiaoDich ENUM('NHAP','XUAT','DIEUCHINH') NOT NULL,
  MaChungTu VARCHAR(20) NOT NULL,
  MaKho VARCHAR(20) NOT NULL,
  MaSP VARCHAR(20) NOT NULL,
  SoLuongThayDoi INT NOT NULL,
  SoLuongSau INT NOT NULL,
  MaNguoiThucHien VARCHAR(20) NOT NULL,
  ThoiGian DATETIME NOT NULL,
  PRIMARY KEY (MaLS),
  CONSTRAINT fk_LichSuGiaoDich_MaKho FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
  CONSTRAINT fk_LichSuGiaoDich_MaSP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
  CONSTRAINT fk_LichSuGiaoDich_MaNguoiThucHien FOREIGN KEY (MaNguoiThucHien) REFERENCES NguoiDung(MaND)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------- PHẦN 2: DỮ LIỆU MẪU ----------
INSERT INTO VaiTro VALUES
  ('NVK', 'Nhân viên kho', 'Lập phiếu nhập, xuất, kiểm kê, đề xuất điều chỉnh'),
  ('QLK', 'Quản lý kho', 'Quản lý danh mục, phê duyệt điều chỉnh, xem báo cáo'),
  ('ADMIN', 'Quản trị viên', 'Quản lý tài khoản và phân quyền');

INSERT INTO NguoiDung VALUES
  ('U01', 'admin', 'bcrypt_hash_mau', 'Trần Quốc Quản', 'admin@congty.vn', 'ADMIN', 'HoatDong', '2026-07-25 08:00:00'),
  ('U02', 'nvkho1', 'bcrypt_hash_mau', 'Nguyễn Văn An', 'an.nv@congty.vn', 'NVK', 'HoatDong', '2026-07-25 08:00:00'),
  ('U03', 'nvkho2', 'bcrypt_hash_mau', 'Lê Thị Bình', 'binh.lt@congty.vn', 'NVK', 'HoatDong', '2026-07-25 08:00:00'),
  ('U04', 'qlkho1', 'bcrypt_hash_mau', 'Phạm Minh Châu', 'chau.pm@congty.vn', 'QLK', 'HoatDong', '2026-07-25 08:00:00');

INSERT INTO LoaiSanPham VALUES
  ('L01', 'Đồ uống'),
  ('L02', 'Thực phẩm khô'),
  ('L03', 'Đồ gia dụng'),
  ('L04', 'Chăm sóc cá nhân');

INSERT INTO SanPham VALUES
  ('SP001', 'Nước suối 500ml', 'L01', 'chai', 200, 'KinhDoanh'),
  ('SP002', 'Nước ngọt lon 330ml', 'L01', 'lon', 150, 'KinhDoanh'),
  ('SP003', 'Mì gói', 'L02', 'gói', 300, 'KinhDoanh'),
  ('SP004', 'Gạo thơm 5kg', 'L02', 'túi', 40, 'KinhDoanh'),
  ('SP005', 'Dầu ăn 1 lít', 'L02', 'chai', 60, 'KinhDoanh'),
  ('SP006', 'Nước mắm 500ml', 'L02', 'chai', 50, 'KinhDoanh'),
  ('SP007', 'Bột giặt 3kg', 'L03', 'túi', 30, 'KinhDoanh'),
  ('SP008', 'Nước rửa chén 750ml', 'L03', 'chai', 40, 'KinhDoanh'),
  ('SP009', 'Dầu gội 650g', 'L04', 'chai', 30, 'KinhDoanh'),
  ('SP010', 'Kem đánh răng 180g', 'L04', 'tuýp', 50, 'KinhDoanh'),
  ('SP011', 'Nước ngọt chai 1,5 lít', 'L01', 'chai', 0, 'NgungKinhDoanh');

INSERT INTO NhaCungCap VALUES
  ('NCC01', 'Công ty TNHH Nước giải khát Thái Bình', '02811110001', 'Quận 7, TP. Hồ Chí Minh'),
  ('NCC02', 'Công ty TNHH Thực phẩm Minh Long', '02811110002', 'Bình Dương'),
  ('NCC03', 'Công ty TNHH Hóa mỹ phẩm An Phát', '02811110003', 'Quận Tân Bình, TP. Hồ Chí Minh'),
  ('NCC04', 'Công ty TNHH Gia dụng Việt Tiến', '02811110004', 'Đồng Nai');

INSERT INTO Kho VALUES
  ('K01', 'Kho A', 'Khu A, đường số 1'),
  ('K02', 'Kho B', 'Khu B, đường số 2');

INSERT INTO PhieuNhap (MaPN, NgayNhap, MaKho, MaNCC, MaNguoiLap, TrangThai, NgayXacNhan, GhiChu) VALUES
  ('PN001', '2026-08-01', 'K01', 'NCC01', 'U02', 'DaXacNhan', '2026-08-01 09:00:00', 'Nhập tồn đầu kỳ'),
  ('PN002', '2026-08-01', 'K01', 'NCC02', 'U02', 'DaXacNhan', '2026-08-01 09:00:00', 'Nhập tồn đầu kỳ'),
  ('PN003', '2026-08-01', 'K02', 'NCC03', 'U03', 'DaXacNhan', '2026-08-01 09:00:00', 'Nhập tồn đầu kỳ'),
  ('PN004', '2026-08-01', 'K02', 'NCC04', 'U03', 'DaXacNhan', '2026-08-01 09:00:00', 'Nhập tồn đầu kỳ'),
  ('PN005', '2026-08-20', 'K01', 'NCC01', 'U02', 'DaXacNhan', '2026-08-20 09:00:00', NULL),
  ('PN006', '2026-09-05', 'K01', 'NCC02', 'U02', 'DaXacNhan', '2026-09-05 09:00:00', NULL),
  ('PN007', '2026-09-12', 'K02', 'NCC04', 'U03', 'DaXacNhan', '2026-09-12 09:00:00', NULL),
  ('PN008', '2026-09-25', 'K01', 'NCC01', 'U02', 'DaXacNhan', '2026-09-25 09:00:00', NULL),
  ('PN009', '2026-10-06', 'K02', 'NCC03', 'U03', 'DaXacNhan', '2026-10-06 09:00:00', NULL),
  ('PN010', '2026-10-12', 'K01', 'NCC02', 'U02', 'Nhap', NULL, 'Phiếu nháp chờ xác nhận');

INSERT INTO ChiTietPhieuNhap VALUES
  ('PN001', 'SP001', 600),
  ('PN001', 'SP002', 400),
  ('PN002', 'SP003', 800),
  ('PN002', 'SP004', 100),
  ('PN002', 'SP005', 120),
  ('PN002', 'SP006', 90),
  ('PN003', 'SP009', 80),
  ('PN003', 'SP010', 150),
  ('PN004', 'SP007', 60),
  ('PN004', 'SP008', 90),
  ('PN005', 'SP001', 300),
  ('PN005', 'SP002', 200),
  ('PN006', 'SP003', 500),
  ('PN006', 'SP005', 60),
  ('PN007', 'SP007', 40),
  ('PN007', 'SP008', 50),
  ('PN008', 'SP001', 400),
  ('PN009', 'SP009', 60),
  ('PN009', 'SP010', 100),
  ('PN010', 'SP004', 50),
  ('PN010', 'SP006', 40);

INSERT INTO PhieuXuat (MaPX, NgayXuat, MaKho, NguoiNhan, MaNguoiLap, TrangThai, NgayXacNhan, GhiChu) VALUES
  ('PX001', '2026-08-10', 'K01', 'Cửa hàng bán lẻ 1', 'U02', 'DaXacNhan', '2026-08-10 14:00:00', NULL),
  ('PX002', '2026-08-18', 'K02', 'Bộ phận bán hàng', 'U03', 'DaXacNhan', '2026-08-18 14:00:00', NULL),
  ('PX003', '2026-08-28', 'K01', 'Cửa hàng bán lẻ 2', 'U02', 'DaXacNhan', '2026-08-28 14:00:00', NULL),
  ('PX004', '2026-09-03', 'K01', 'Bộ phận bán hàng', 'U02', 'DaXacNhan', '2026-09-03 14:00:00', NULL),
  ('PX005', '2026-09-15', 'K02', 'Cửa hàng bán lẻ 1', 'U03', 'DaXacNhan', '2026-09-15 14:00:00', NULL),
  ('PX006', '2026-09-22', 'K01', 'Bộ phận bán hàng', 'U02', 'DaXacNhan', '2026-09-22 14:00:00', NULL),
  ('PX007', '2026-10-02', 'K01', 'Cửa hàng bán lẻ 2', 'U02', 'DaXacNhan', '2026-10-02 14:00:00', NULL),
  ('PX008', '2026-10-08', 'K02', 'Bộ phận bán hàng', 'U03', 'DaXacNhan', '2026-10-08 14:00:00', NULL),
  ('PX009', '2026-10-13', 'K01', 'Cửa hàng bán lẻ 1', 'U02', 'Nhap', NULL, 'Phiếu nháp chờ xác nhận'),
  ('PX010', '2026-10-11', 'K02', 'Bộ phận bán hàng', 'U03', 'DaHuy', NULL, 'Hủy do khách đổi đơn');

INSERT INTO ChiTietPhieuXuat VALUES
  ('PX001', 'SP001', 150),
  ('PX001', 'SP003', 200),
  ('PX001', 'SP004', 30),
  ('PX002', 'SP007', 20),
  ('PX002', 'SP009', 25),
  ('PX002', 'SP010', 40),
  ('PX003', 'SP001', 250),
  ('PX003', 'SP002', 180),
  ('PX003', 'SP005', 40),
  ('PX004', 'SP003', 350),
  ('PX004', 'SP006', 45),
  ('PX004', 'SP004', 40),
  ('PX005', 'SP008', 60),
  ('PX005', 'SP007', 30),
  ('PX005', 'SP010', 70),
  ('PX006', 'SP001', 300),
  ('PX006', 'SP002', 100),
  ('PX006', 'SP003', 300),
  ('PX007', 'SP001', 280),
  ('PX007', 'SP005', 70),
  ('PX008', 'SP009', 70),
  ('PX008', 'SP010', 110),
  ('PX008', 'SP008', 20),
  ('PX009', 'SP002', 90),
  ('PX010', 'SP007', 10);

INSERT INTO KiemKe VALUES
  ('KK001', 'K01', '2026-09-30', 'U02', 'HoanThanh', 'Kiểm kê cuối tháng 9'),
  ('KK002', 'K02', '2026-10-10', 'U03', 'HoanThanh', 'Kiểm kê giữa tháng 10');

INSERT INTO ChiTietKiemKe (MaKK, MaSP, SoLuongHeThong, SoLuongThucTe) VALUES
  ('KK001', 'SP001', 600, 600),
  ('KK001', 'SP002', 320, 320),
  ('KK001', 'SP003', 450, 447),
  ('KK001', 'SP004', 30, 30),
  ('KK001', 'SP005', 140, 140),
  ('KK001', 'SP006', 45, 45),
  ('KK002', 'SP007', 50, 50),
  ('KK002', 'SP008', 60, 58),
  ('KK002', 'SP009', 45, 45),
  ('KK002', 'SP010', 30, 30);

INSERT INTO DieuChinhTonKho (MaDC, MaKho, MaSP, SoLuongDieuChinh, LyDo, MaKK, MaNguoiDeXuat, NgayDeXuat, TrangThai, MaNguoiDuyet, NgayDuyet, LyDoTuChoi) VALUES
  ('DC001', 'K01', 'SP003', -3, 'Kiểm kê thiếu 3 gói, nghi bể rách khi xếp kệ', 'KK001', 'U02', '2026-10-01 08:30:00', 'DaDuyet', 'U04', '2026-10-01 10:15:00', NULL),
  ('DC002', 'K02', 'SP008', -2, 'Kiểm kê thiếu 2 chai nước rửa chén', 'KK002', 'U03', '2026-10-10 16:00:00', 'ChoDuyet', NULL, NULL, NULL),
  ('DC003', 'K01', 'SP006', 5, 'Nghi đếm thiếu khi nhập, đề xuất tăng 5 chai', NULL, 'U02', '2026-10-05 09:00:00', 'TuChoi', 'U04', '2026-10-05 11:00:00', 'Chưa có biên bản đối chiếu với phiếu giao hàng');

INSERT INTO TonKho VALUES
  ('K01', 'SP001', 320),
  ('K01', 'SP002', 320),
  ('K01', 'SP003', 447),
  ('K01', 'SP004', 30),
  ('K01', 'SP005', 70),
  ('K01', 'SP006', 45),
  ('K02', 'SP007', 50),
  ('K02', 'SP008', 60),
  ('K02', 'SP009', 45),
  ('K02', 'SP010', 30);

INSERT INTO LichSuGiaoDich (LoaiGiaoDich, MaChungTu, MaKho, MaSP, SoLuongThayDoi, SoLuongSau, MaNguoiThucHien, ThoiGian) VALUES
  ('NHAP', 'PN001', 'K01', 'SP001', 600, 600, 'U02', '2026-08-01 09:00:00'),
  ('NHAP', 'PN001', 'K01', 'SP002', 400, 400, 'U02', '2026-08-01 09:00:00'),
  ('NHAP', 'PN002', 'K01', 'SP003', 800, 800, 'U02', '2026-08-01 09:00:00'),
  ('NHAP', 'PN002', 'K01', 'SP004', 100, 100, 'U02', '2026-08-01 09:00:00'),
  ('NHAP', 'PN002', 'K01', 'SP005', 120, 120, 'U02', '2026-08-01 09:00:00'),
  ('NHAP', 'PN002', 'K01', 'SP006', 90, 90, 'U02', '2026-08-01 09:00:00'),
  ('NHAP', 'PN003', 'K02', 'SP009', 80, 80, 'U03', '2026-08-01 09:00:00'),
  ('NHAP', 'PN003', 'K02', 'SP010', 150, 150, 'U03', '2026-08-01 09:00:00'),
  ('NHAP', 'PN004', 'K02', 'SP007', 60, 60, 'U03', '2026-08-01 09:00:00'),
  ('NHAP', 'PN004', 'K02', 'SP008', 90, 90, 'U03', '2026-08-01 09:00:00'),
  ('XUAT', 'PX001', 'K01', 'SP001', -150, 450, 'U02', '2026-08-10 14:00:00'),
  ('XUAT', 'PX001', 'K01', 'SP003', -200, 600, 'U02', '2026-08-10 14:00:00'),
  ('XUAT', 'PX001', 'K01', 'SP004', -30, 70, 'U02', '2026-08-10 14:00:00'),
  ('XUAT', 'PX002', 'K02', 'SP007', -20, 40, 'U03', '2026-08-18 14:00:00'),
  ('XUAT', 'PX002', 'K02', 'SP009', -25, 55, 'U03', '2026-08-18 14:00:00'),
  ('XUAT', 'PX002', 'K02', 'SP010', -40, 110, 'U03', '2026-08-18 14:00:00'),
  ('NHAP', 'PN005', 'K01', 'SP001', 300, 750, 'U02', '2026-08-20 09:00:00'),
  ('NHAP', 'PN005', 'K01', 'SP002', 200, 600, 'U02', '2026-08-20 09:00:00'),
  ('XUAT', 'PX003', 'K01', 'SP001', -250, 500, 'U02', '2026-08-28 14:00:00'),
  ('XUAT', 'PX003', 'K01', 'SP002', -180, 420, 'U02', '2026-08-28 14:00:00'),
  ('XUAT', 'PX003', 'K01', 'SP005', -40, 80, 'U02', '2026-08-28 14:00:00'),
  ('XUAT', 'PX004', 'K01', 'SP003', -350, 250, 'U02', '2026-09-03 14:00:00'),
  ('XUAT', 'PX004', 'K01', 'SP006', -45, 45, 'U02', '2026-09-03 14:00:00'),
  ('XUAT', 'PX004', 'K01', 'SP004', -40, 30, 'U02', '2026-09-03 14:00:00'),
  ('NHAP', 'PN006', 'K01', 'SP003', 500, 750, 'U02', '2026-09-05 09:00:00'),
  ('NHAP', 'PN006', 'K01', 'SP005', 60, 140, 'U02', '2026-09-05 09:00:00'),
  ('NHAP', 'PN007', 'K02', 'SP007', 40, 80, 'U03', '2026-09-12 09:00:00'),
  ('NHAP', 'PN007', 'K02', 'SP008', 50, 140, 'U03', '2026-09-12 09:00:00'),
  ('XUAT', 'PX005', 'K02', 'SP008', -60, 80, 'U03', '2026-09-15 14:00:00'),
  ('XUAT', 'PX005', 'K02', 'SP007', -30, 50, 'U03', '2026-09-15 14:00:00'),
  ('XUAT', 'PX005', 'K02', 'SP010', -70, 40, 'U03', '2026-09-15 14:00:00'),
  ('XUAT', 'PX006', 'K01', 'SP001', -300, 200, 'U02', '2026-09-22 14:00:00'),
  ('XUAT', 'PX006', 'K01', 'SP002', -100, 320, 'U02', '2026-09-22 14:00:00'),
  ('XUAT', 'PX006', 'K01', 'SP003', -300, 450, 'U02', '2026-09-22 14:00:00'),
  ('NHAP', 'PN008', 'K01', 'SP001', 400, 600, 'U02', '2026-09-25 09:00:00'),
  ('DIEUCHINH', 'DC001', 'K01', 'SP003', -3, 447, 'U04', '2026-10-01 10:15:00'),
  ('XUAT', 'PX007', 'K01', 'SP001', -280, 320, 'U02', '2026-10-02 14:00:00'),
  ('XUAT', 'PX007', 'K01', 'SP005', -70, 70, 'U02', '2026-10-02 14:00:00'),
  ('NHAP', 'PN009', 'K02', 'SP009', 60, 115, 'U03', '2026-10-06 09:00:00'),
  ('NHAP', 'PN009', 'K02', 'SP010', 100, 140, 'U03', '2026-10-06 09:00:00'),
  ('XUAT', 'PX008', 'K02', 'SP009', -70, 45, 'U03', '2026-10-08 14:00:00'),
  ('XUAT', 'PX008', 'K02', 'SP010', -110, 30, 'U03', '2026-10-08 14:00:00'),
  ('XUAT', 'PX008', 'K02', 'SP008', -20, 60, 'U03', '2026-10-08 14:00:00');

-- ---------- PHẦN 3: TRUY VẤN NGHIỆP VỤ ----------
-- Q1. Liệt kê sản phẩm có tổng tồn kho dưới mức tồn tối thiểu (BR-15)
SELECT sp.MaSP, sp.TenSP, sp.DonViTinh,
       COALESCE(SUM(tk.SoLuong), 0) AS TongTon,
       sp.MucTonToiThieu
FROM SanPham sp
LEFT JOIN TonKho tk ON tk.MaSP = sp.MaSP
WHERE sp.TrangThai = 'KinhDoanh'
GROUP BY sp.MaSP, sp.TenSP, sp.DonViTinh, sp.MucTonToiThieu
HAVING COALESCE(SUM(tk.SoLuong), 0) < sp.MucTonToiThieu
ORDER BY (sp.MucTonToiThieu - COALESCE(SUM(tk.SoLuong), 0)) DESC;

-- Q2. Tra cứu tồn kho theo từng kho, tìm theo tên sản phẩm (US-11)
SELECT k.TenKho, sp.MaSP, sp.TenSP, tk.SoLuong, sp.DonViTinh
FROM TonKho tk
JOIN Kho k ON k.MaKho = tk.MaKho
JOIN SanPham sp ON sp.MaSP = tk.MaSP
WHERE sp.TenSP LIKE '%Nước%'
ORDER BY k.TenKho, sp.MaSP;

-- Q3. Tính tổng số lượng hàng đã nhập theo tháng (chỉ phiếu đã xác nhận)
SELECT DATE_FORMAT(pn.NgayNhap, '%Y-%m') AS Thang,
       COUNT(DISTINCT pn.MaPN) AS SoPhieu,
       SUM(ct.SoLuong) AS TongSoLuongNhap
FROM PhieuNhap pn
JOIN ChiTietPhieuNhap ct ON ct.MaPN = pn.MaPN
WHERE pn.TrangThai = 'DaXacNhan'
GROUP BY DATE_FORMAT(pn.NgayNhap, '%Y-%m')
ORDER BY Thang;

-- Q4. Liệt kê 10 sản phẩm xuất kho nhiều nhất
SELECT sp.MaSP, sp.TenSP, SUM(ct.SoLuong) AS TongSoLuongXuat
FROM ChiTietPhieuXuat ct
JOIN PhieuXuat px ON px.MaPX = ct.MaPX
JOIN SanPham sp ON sp.MaSP = ct.MaSP
WHERE px.TrangThai = 'DaXacNhan'
GROUP BY sp.MaSP, sp.TenSP
ORDER BY TongSoLuongXuat DESC
LIMIT 10;

-- Q5. Xem lịch sử biến động của sản phẩm SP001 (US-17)
SELECT ls.ThoiGian, ls.LoaiGiaoDich, ls.MaChungTu, k.TenKho,
       ls.SoLuongThayDoi, ls.SoLuongSau, nd.HoTen AS NguoiThucHien
FROM LichSuGiaoDich ls
JOIN Kho k ON k.MaKho = ls.MaKho
JOIN NguoiDung nd ON nd.MaND = ls.MaNguoiThucHien
WHERE ls.MaSP = 'SP001'
ORDER BY ls.ThoiGian, ls.MaLS;

-- Q6. Báo cáo nhập – xuất – tồn tháng 9/2026 (BR-07, US-18)
SELECT sp.MaSP, sp.TenSP,
  COALESCE(SUM(CASE WHEN ls.ThoiGian < '2026-09-01' THEN ls.SoLuongThayDoi END), 0) AS TonDauKy,
  COALESCE(SUM(CASE WHEN ls.LoaiGiaoDich = 'NHAP' AND ls.ThoiGian >= '2026-09-01' AND ls.ThoiGian < '2026-10-01' THEN ls.SoLuongThayDoi END), 0) AS Nhap,
  COALESCE(-SUM(CASE WHEN ls.LoaiGiaoDich = 'XUAT' AND ls.ThoiGian >= '2026-09-01' AND ls.ThoiGian < '2026-10-01' THEN ls.SoLuongThayDoi END), 0) AS Xuat,
  COALESCE(SUM(CASE WHEN ls.LoaiGiaoDich = 'DIEUCHINH' AND ls.ThoiGian >= '2026-09-01' AND ls.ThoiGian < '2026-10-01' THEN ls.SoLuongThayDoi END), 0) AS DieuChinh,
  COALESCE(SUM(CASE WHEN ls.ThoiGian < '2026-10-01' THEN ls.SoLuongThayDoi END), 0) AS TonCuoiKy
FROM SanPham sp
LEFT JOIN LichSuGiaoDich ls ON ls.MaSP = sp.MaSP
WHERE sp.TrangThai = 'KinhDoanh'
GROUP BY sp.MaSP, sp.TenSP
ORDER BY sp.MaSP;

-- Q7. Tổng số lượng nhập theo nhà cung cấp
SELECT ncc.MaNCC, ncc.TenNCC, COUNT(DISTINCT pn.MaPN) AS SoPhieu, SUM(ct.SoLuong) AS TongSoLuongNhap
FROM NhaCungCap ncc
JOIN PhieuNhap pn ON pn.MaNCC = ncc.MaNCC AND pn.TrangThai = 'DaXacNhan'
JOIN ChiTietPhieuNhap ct ON ct.MaPN = pn.MaPN
GROUP BY ncc.MaNCC, ncc.TenNCC
ORDER BY TongSoLuongNhap DESC;

-- Q8. Danh sách đề xuất điều chỉnh đang chờ quản lý kho duyệt (US-15)
SELECT dc.MaDC, k.TenKho, sp.TenSP, dc.SoLuongDieuChinh, dc.LyDo,
       nd.HoTen AS NguoiDeXuat, dc.NgayDeXuat
FROM DieuChinhTonKho dc
JOIN Kho k ON k.MaKho = dc.MaKho
JOIN SanPham sp ON sp.MaSP = dc.MaSP
JOIN NguoiDung nd ON nd.MaND = dc.MaNguoiDeXuat
WHERE dc.TrangThai = 'ChoDuyet'
ORDER BY dc.NgayDeXuat;

-- Q9. Xem các dòng có chênh lệch trong đợt kiểm kê KK001 (US-13)
SELECT ct.MaSP, sp.TenSP, ct.SoLuongHeThong, ct.SoLuongThucTe, ct.ChenhLech
FROM ChiTietKiemKe ct
JOIN SanPham sp ON sp.MaSP = ct.MaSP
WHERE ct.MaKK = 'KK001' AND ct.ChenhLech <> 0;

-- Q10. Đối chiếu toàn vẹn: tồn kho phải bằng tổng biến động trong lịch sử (kết quả rỗng là đạt)
SELECT tk.MaKho, tk.MaSP, tk.SoLuong AS TonKho,
       COALESCE(SUM(ls.SoLuongThayDoi), 0) AS TongLichSu
FROM TonKho tk
LEFT JOIN LichSuGiaoDich ls ON ls.MaKho = tk.MaKho AND ls.MaSP = tk.MaSP
GROUP BY tk.MaKho, tk.MaSP, tk.SoLuong
HAVING tk.SoLuong <> COALESCE(SUM(ls.SoLuongThayDoi), 0);

-- Q11. Tìm sản phẩm chưa phát sinh giao dịch nào
SELECT sp.MaSP, sp.TenSP, sp.TrangThai
FROM SanPham sp
LEFT JOIN LichSuGiaoDich ls ON ls.MaSP = sp.MaSP
WHERE ls.MaLS IS NULL;

-- ---------- PHẦN 4: THỦ TỤC LƯU TRỮ ----------
DELIMITER $$

-- Xác nhận phiếu nhập: cộng tồn kho và ghi lịch sử trong cùng một giao dịch (BR-05, BR-11, NFR-04)
CREATE PROCEDURE sp_XacNhanPhieuNhap(IN p_MaPN VARCHAR(20), IN p_MaND VARCHAR(20))
BEGIN
  DECLARE v_MaKho VARCHAR(20);
  DECLARE v_TrangThai VARCHAR(20);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SELECT MaKho, TrangThai INTO v_MaKho, v_TrangThai
  FROM PhieuNhap WHERE MaPN = p_MaPN FOR UPDATE;

  IF v_TrangThai IS NULL OR v_TrangThai <> 'Nhap' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi xac nhan duoc phieu o trang thai Nhap';
  END IF;

  INSERT INTO TonKho (MaKho, MaSP, SoLuong)
  SELECT v_MaKho, ct.MaSP, ct.SoLuong FROM ChiTietPhieuNhap ct WHERE ct.MaPN = p_MaPN
  ON DUPLICATE KEY UPDATE SoLuong = TonKho.SoLuong + VALUES(SoLuong);

  INSERT INTO LichSuGiaoDich (LoaiGiaoDich, MaChungTu, MaKho, MaSP, SoLuongThayDoi, SoLuongSau, MaNguoiThucHien, ThoiGian)
  SELECT 'NHAP', p_MaPN, v_MaKho, ct.MaSP, ct.SoLuong, tk.SoLuong, p_MaND, NOW()
  FROM ChiTietPhieuNhap ct
  JOIN TonKho tk ON tk.MaKho = v_MaKho AND tk.MaSP = ct.MaSP
  WHERE ct.MaPN = p_MaPN;

  UPDATE PhieuNhap SET TrangThai = 'DaXacNhan', NgayXacNhan = NOW() WHERE MaPN = p_MaPN;
  COMMIT;
END$$

-- Xác nhận phiếu xuất: kiểm tra đủ tồn (BR-04), trừ tồn (BR-06), ghi lịch sử, không để tồn âm (BR-13)
CREATE PROCEDURE sp_XacNhanPhieuXuat(IN p_MaPX VARCHAR(20), IN p_MaND VARCHAR(20))
BEGIN
  DECLARE v_MaKho VARCHAR(20);
  DECLARE v_TrangThai VARCHAR(20);
  DECLARE v_Thieu INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SELECT MaKho, TrangThai INTO v_MaKho, v_TrangThai
  FROM PhieuXuat WHERE MaPX = p_MaPX FOR UPDATE;

  IF v_TrangThai IS NULL OR v_TrangThai <> 'Nhap' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi xac nhan duoc phieu o trang thai Nhap';
  END IF;

  SELECT COUNT(*) INTO v_Thieu
  FROM ChiTietPhieuXuat ct
  LEFT JOIN TonKho tk ON tk.MaKho = v_MaKho AND tk.MaSP = ct.MaSP
  WHERE ct.MaPX = p_MaPX AND COALESCE(tk.SoLuong, 0) < ct.SoLuong;

  IF v_Thieu > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ton kho khong du de xuat';
  END IF;

  UPDATE TonKho tk
  JOIN ChiTietPhieuXuat ct ON ct.MaSP = tk.MaSP
  SET tk.SoLuong = tk.SoLuong - ct.SoLuong
  WHERE tk.MaKho = v_MaKho AND ct.MaPX = p_MaPX;

  INSERT INTO LichSuGiaoDich (LoaiGiaoDich, MaChungTu, MaKho, MaSP, SoLuongThayDoi, SoLuongSau, MaNguoiThucHien, ThoiGian)
  SELECT 'XUAT', p_MaPX, v_MaKho, ct.MaSP, -ct.SoLuong, tk.SoLuong, p_MaND, NOW()
  FROM ChiTietPhieuXuat ct
  JOIN TonKho tk ON tk.MaKho = v_MaKho AND tk.MaSP = ct.MaSP
  WHERE ct.MaPX = p_MaPX;

  UPDATE PhieuXuat SET TrangThai = 'DaXacNhan', NgayXacNhan = NOW() WHERE MaPX = p_MaPX;
  COMMIT;
END$$

-- Phê duyệt hoặc từ chối điều chỉnh (BR-09, BR-10, BR-13)
CREATE PROCEDURE sp_XuLyDieuChinh(IN p_MaDC VARCHAR(20), IN p_MaND VARCHAR(20),
                                  IN p_QuyetDinh VARCHAR(10), IN p_LyDoTuChoi VARCHAR(255))
BEGIN
  DECLARE v_MaKho VARCHAR(20);
  DECLARE v_MaSP VARCHAR(20);
  DECLARE v_SL INT;
  DECLARE v_TrangThai VARCHAR(20);
  DECLARE v_Sau INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SELECT MaKho, MaSP, SoLuongDieuChinh, TrangThai INTO v_MaKho, v_MaSP, v_SL, v_TrangThai
  FROM DieuChinhTonKho WHERE MaDC = p_MaDC FOR UPDATE;

  IF v_TrangThai IS NULL OR v_TrangThai <> 'ChoDuyet' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'De xuat khong o trang thai Cho duyet';
  END IF;

  IF p_QuyetDinh = 'TUCHOI' THEN
    IF p_LyDoTuChoi IS NULL OR TRIM(p_LyDoTuChoi) = '' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phai nhap ly do khi tu choi';
    END IF;
    UPDATE DieuChinhTonKho
    SET TrangThai = 'TuChoi', MaNguoiDuyet = p_MaND, NgayDuyet = NOW(), LyDoTuChoi = p_LyDoTuChoi
    WHERE MaDC = p_MaDC;
  ELSE
    -- Nếu làm tồn âm, ràng buộc CHECK (SoLuong >= 0) sẽ báo lỗi và toàn bộ giao dịch bị hoàn tác
    UPDATE TonKho SET SoLuong = SoLuong + v_SL WHERE MaKho = v_MaKho AND MaSP = v_MaSP;
    IF ROW_COUNT() = 0 THEN
      IF v_SL < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong the dieu chinh giam: san pham chua co ton';
      END IF;
      INSERT INTO TonKho (MaKho, MaSP, SoLuong) VALUES (v_MaKho, v_MaSP, v_SL);
    END IF;

    SELECT SoLuong INTO v_Sau FROM TonKho WHERE MaKho = v_MaKho AND MaSP = v_MaSP;
    INSERT INTO LichSuGiaoDich (LoaiGiaoDich, MaChungTu, MaKho, MaSP, SoLuongThayDoi, SoLuongSau, MaNguoiThucHien, ThoiGian)
    VALUES ('DIEUCHINH', p_MaDC, v_MaKho, v_MaSP, v_SL, v_Sau, p_MaND, NOW());

    UPDATE DieuChinhTonKho
    SET TrangThai = 'DaDuyet', MaNguoiDuyet = p_MaND, NgayDuyet = NOW()
    WHERE MaDC = p_MaDC;
  END IF;
  COMMIT;
END$$

DELIMITER ;
