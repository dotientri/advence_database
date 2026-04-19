-- 2. XÓA BẢNG CŨ (Xóa bảng con trước để tránh lỗi khóa ngoại)
DROP TABLE diem_so CASCADE CONSTRAINTS;
DROP TABLE dang_ky CASCADE CONSTRAINTS;
DROP TABLE lop_hoc CASCADE CONSTRAINTS;
DROP TABLE sinh_vien CASCADE CONSTRAINTS;
DROP TABLE giang_vien CASCADE CONSTRAINTS;
DROP TABLE mon_hoc CASCADE CONSTRAINTS;

-- 3. TẠO CẤU TRÚC BẢNG

-- Bảng Môn Học (COURSE)
CREATE TABLE mon_hoc (
    ma_mon_hoc NUMBER,
    mo_ta VARCHAR2(100),
    hoc_phi NUMBER(15,2),
    ma_mon_tien_quyet NUMBER,
    PRIMARY KEY (ma_mon_hoc),
    FOREIGN KEY (ma_mon_tien_quyet) REFERENCES mon_hoc(ma_mon_hoc)
);

-- Bảng Giảng Viên (INSTRUCTOR)
CREATE TABLE giang_vien (
    ma_giang_vien NUMBER,
    ho VARCHAR2(50),
    ten VARCHAR2(50),
    PRIMARY KEY (ma_giang_vien)
);

-- Bảng Sinh Viên (STUDENT)
CREATE TABLE sinh_vien (
    ma_sinh_vien NUMBER,
    ho VARCHAR2(50),
    ten VARCHAR2(50),
    ngay_dang_ky DATE DEFAULT SYSDATE,
    PRIMARY KEY (ma_sinh_vien)
);

-- Bảng Lớp Học (CLASS)
CREATE TABLE lop_hoc (
    ma_lop_hoc NUMBER,
    ma_mon_hoc NUMBER,
    so_hieu_lop NUMBER,
    thoi_gian_bat_dau DATE,
    ma_giang_vien NUMBER,
    suc_chua NUMBER,
    PRIMARY KEY (ma_lop_hoc),
    FOREIGN KEY (ma_mon_hoc) REFERENCES mon_hoc(ma_mon_hoc),
    FOREIGN KEY (ma_giang_vien) REFERENCES giang_vien(ma_giang_vien)
);

-- Bảng Đăng Ký (ENROLLMENT)
CREATE TABLE dang_ky (
    ma_sinh_vien NUMBER,
    ma_lop_hoc NUMBER,
    ngay_ghi_danh DATE DEFAULT SYSDATE,
    diem_tong_ket NUMBER(3,1),
    PRIMARY KEY (ma_sinh_vien, ma_lop_hoc),
    FOREIGN KEY (ma_sinh_vien) REFERENCES sinh_vien(ma_sinh_vien),
    FOREIGN KEY (ma_lop_hoc) REFERENCES lop_hoc(ma_lop_hoc)
);

-- Bảng Điểm Số (GRADE)
CREATE TABLE diem_so (
    ma_sinh_vien NUMBER,
    ma_lop_hoc NUMBER,
    diem_chu VARCHAR2(2),
    ghi_chu VARCHAR2(200),
    PRIMARY KEY (ma_sinh_vien, ma_lop_hoc),
    FOREIGN KEY (ma_sinh_vien, ma_lop_hoc) REFERENCES dang_ky(ma_sinh_vien, ma_lop_hoc)
);

-- 4. CHÈN DỮ LIỆU MẪU (10 DÒNG LỘN XỘN MỖI BẢNG)

-- Môn học
INSERT INTO mon_hoc VALUES (101, 'Co so du lieu', 500000, NULL);
INSERT INTO mon_hoc VALUES (102, 'SQL nang cao', 600000, 101);
INSERT INTO mon_hoc VALUES (103, 'Lap trinh Java', 750000, NULL);
INSERT INTO mon_hoc VALUES (104, 'Lap trinh Python', 700000, NULL);
INSERT INTO mon_hoc VALUES (105, 'Toan roi rac', 400000, NULL);
INSERT INTO mon_hoc VALUES (106, 'Cau truc du lieu', 550000, 101);
INSERT INTO mon_hoc VALUES (107, 'Mang may tinh', 600000, NULL);
INSERT INTO mon_hoc VALUES (108, 'He dieu hanh', 500000, NULL);
INSERT INTO mon_hoc VALUES (109, 'Tri tue nhan tao', 900000, 104);
INSERT INTO mon_hoc VALUES (110, 'Bao mat thong tin', 800000, 107);

-- Giảng viên
INSERT INTO giang_vien VALUES (1, 'Huynh', 'Kom');
INSERT INTO giang_vien VALUES (2, 'Nguyen', 'Van A');
INSERT INTO giang_vien VALUES (3, 'Tran', 'Thi B');
INSERT INTO giang_vien VALUES (4, 'Le', 'Van C');
INSERT INTO giang_vien VALUES (5, 'Pham', 'Thi D');
INSERT INTO giang_vien VALUES (6, 'Hoang', 'Van E');
INSERT INTO giang_vien VALUES (7, 'Do', 'Tien Tri');
INSERT INTO giang_vien VALUES (8, 'Phan', 'Thi F');
INSERT INTO giang_vien VALUES (9, 'Vu', 'Van G');
INSERT INTO giang_vien VALUES (10, 'Dang', 'Thi H');

-- Sinh viên
INSERT INTO sinh_vien VALUES (1, 'Nguyen', 'Thanh Thao', SYSDATE-100);
INSERT INTO sinh_vien VALUES (2, 'Tran', 'Nam Son', SYSDATE-90);
INSERT INTO sinh_vien VALUES (3, 'Le', 'Thi Hoa', SYSDATE-80);
INSERT INTO sinh_vien VALUES (4, 'Pham', 'Minh Quan', SYSDATE-70);
INSERT INTO sinh_vien VALUES (5, 'Hoang', 'Anh Tu', SYSDATE-60);
INSERT INTO sinh_vien VALUES (6, 'Do', 'Tien Dong', SYSDATE-50);
INSERT INTO sinh_vien VALUES (7, 'Phan', 'Quynh Nhu', SYSDATE-40);
INSERT INTO sinh_vien VALUES (8, 'Vu', 'Hoang Yen', SYSDATE-30);
INSERT INTO sinh_vien VALUES (9, 'Dang', 'Van Nam', SYSDATE-20);
INSERT INTO sinh_vien VALUES (10, 'Bui', 'Thi Dong', SYSDATE-10);

-- Lớp học
INSERT INTO lop_hoc VALUES (10, 101, 1, SYSDATE+10, 1, 30);
INSERT INTO lop_hoc VALUES (11, 102, 1, SYSDATE+15, 2, 25);
INSERT INTO lop_hoc VALUES (12, 103, 2, SYSDATE+20, 1, 30);
INSERT INTO lop_hoc VALUES (13, 101, 2, SYSDATE+5, 3, 20);
INSERT INTO lop_hoc VALUES (14, 105, 1, SYSDATE+30, 4, 40);
INSERT INTO lop_hoc VALUES (15, 106, 1, SYSDATE+12, 5, 15);
INSERT INTO lop_hoc VALUES (16, 104, 1, SYSDATE+18, 1, 30);
INSERT INTO lop_hoc VALUES (17, 107, 3, SYSDATE+25, 6, 20);
INSERT INTO lop_hoc VALUES (18, 109, 1, SYSDATE+40, 7, 10);
INSERT INTO lop_hoc VALUES (19, 101, 3, SYSDATE+50, 2, 35);

-- Đăng ký
INSERT INTO dang_ky VALUES (1, 10, SYSDATE-5, 8.5);
INSERT INTO dang_ky VALUES (2, 10, SYSDATE-4, 7.0);
INSERT INTO dang_ky VALUES (3, 11, SYSDATE-3, 9.0);
INSERT INTO dang_ky VALUES (1, 12, SYSDATE-2, 6.5);
INSERT INTO dang_ky VALUES (5, 13, SYSDATE-1, 5.0);
INSERT INTO dang_ky VALUES (6, 14, SYSDATE, 10.0);
INSERT INTO dang_ky VALUES (7, 15, SYSDATE, 4.5);
INSERT INTO dang_ky VALUES (8, 16, SYSDATE, 8.0);
INSERT INTO dang_ky VALUES (9, 17, SYSDATE, 7.5);
INSERT INTO dang_ky VALUES (10, 18, SYSDATE, 9.5);

-- Điểm số
INSERT INTO diem_so VALUES (1, 10, 'A', 'tot');
INSERT INTO diem_so VALUES (2, 10, 'B', 'kha');
INSERT INTO diem_so VALUES (3, 11, 'A', 'xuat sac');
INSERT INTO diem_so VALUES (1, 12, 'C', 'dat');
INSERT INTO diem_so VALUES (5, 13, 'D', 'can co gang');
INSERT INTO diem_so VALUES (6, 14, 'A', 'hoan hao');
INSERT INTO diem_so VALUES (7, 15, 'F', 'rot mon');
INSERT INTO diem_so VALUES (8, 16, 'B', 'tot');
INSERT INTO diem_so VALUES (9, 17, 'B', 'kha');
INSERT INTO diem_so VALUES (10, 18, 'A', 'tot');

COMMIT;

-- 5. KIỂM TRA
SELECT 'KHOI TAO THANH CONG' FROM DUAL;