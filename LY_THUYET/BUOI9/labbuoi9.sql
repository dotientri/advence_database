alter session set current_schema = dotientri;



-- Lab 1
-- a. Thu tuc Nhap HangSX
create or replace procedure sp_NhapHangSX(
    p_MaHangSX in varchar2,
    p_TenHang in varchar2,
    p_DiaChi in varchar2,
    p_SoDT in varchar2,
    p_Email in varchar2
)
is
    v_count number;
begin
    if p_MaHangSX is null then raise_application_error(-20000, 'Ma hang khong duoc de trong'); end if;
    if p_TenHang is null then raise_application_error(-20000, 'Ten hang khong duoc de trong'); end if;

    select count(*) into v_count from HangSX where MaHangSX = p_MaHangSX;
    if v_count > 0 then
        raise_application_error(-20000, 'Ma hang da ton tai');
    end if;

    select count(*) into v_count from HangSX where TenHang = p_TenHang;
    if v_count > 0 then
        raise_application_error(-20000, 'Ten hang da ton tai');
    else
        insert into HangSX(MaHangSX, TenHang, DiaChi, SoDT, Email)
        values(p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);
    end if;
end;
/

-- b. Thu tuc Nhap SanPham
create or replace procedure sp_NhapSP(
    p_MaSP in varchar2,
    p_TenHang in varchar2,
    p_TenSP in varchar2,
    p_SoLuong in number,
    p_MauSac in varchar2,
    p_GiaBan in number,
    p_DonViTinh in varchar2,
    p_MoTa in varchar2
)
is
    v_MaHangSX varchar2(10);
    v_count number;
begin
    if p_MaSP is null then raise_application_error(-20000, 'Ma san pham khong duoc de trong'); end if;
    if p_TenSP is null then raise_application_error(-20000, 'Ten san pham khong duoc de trong'); end if;

    begin
        select MaHangSX into v_MaHangSX from HangSX where TenHang = p_TenHang;
    exception when no_data_found then
        raise_application_error(-20001, 'Ten hang khong ton tai');
    end;

    select count(*) into v_count from SanPham where MaSP = p_MaSP;
    if v_count > 0 then
        update SanPham set MaHangSX = v_MaHangSX, TenSP = p_TenSP, SoLuong = p_SoLuong,
            MauSac = p_MauSac, GiaBan = p_GiaBan, DonViTinh = p_DonViTinh, MoTa = p_MoTa
        where MaSP = p_MaSP;
    else
        insert into SanPham(MaSP, MaHangSX, TenSP, SoLuong, MauSac, GiaBan, DonViTinh, MoTa)
        values(p_MaSP, v_MaHangSX, p_TenSP, p_SoLuong, p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);
    end if;
end;
/

-- c. Thu tuc Xoa HangSX
create or replace procedure sp_xoaHangSX(
    p_TenHang in varchar2
)
is
    v_MaHangSX varchar2(10);
begin
    begin
        select MaHangSX into v_MaHangSX from HangSX where TenHang = p_TenHang;
    exception when no_data_found then
        raise_application_error(-20002, 'Ten hang khong ton tai');
    end;

    delete from Nhap where MaSP in (select MaSP from SanPham where MaHangSX = v_MaHangSX);
    delete from Xuat where MaSP in (select MaSP from SanPham where MaHangSX = v_MaHangSX);

    delete from SanPham where MaHangSX = v_MaHangSX;
    delete from HangSX where MaHangSX = v_MaHangSX;
end;
/

-- d. Thu tuc Nhap NhanVien
create or replace procedure sp_NhapNhanVien(
    p_MaNV in varchar2,
    p_TenNV in varchar2,
    p_GioiTinh in varchar2,
    p_DiaChi in varchar2,
    p_SoDT in varchar2,
    p_Email in varchar2,
    p_TenPhong in varchar2,
    p_Flag in number
)
is
begin
    if p_MaNV is null then raise_application_error(-20000, 'Ma nhan vien khong duoc de trong'); end if;
    if p_TenNV is null then raise_application_error(-20000, 'Ten nhan vien khong duoc de trong'); end if;

    if p_Flag = 0 then
        update NhanVien set TenNV = p_TenNV, GioiTinh = p_GioiTinh, DiaChi = p_DiaChi,
            SoDT = p_SoDT, Email = p_Email, TenPhong = p_TenPhong
        where MaNV = p_MaNV;
    else
        insert into NhanVien(MaNV, TenNV, GioiTinh, DiaChi, SoDT, Email, TenPhong)
        values(p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi, p_SoDT, p_Email, p_TenPhong);
    end if;
end;
/

-- e. Thu tuc Nhap bang Nhap
create or replace procedure sp_NhapNhap(
    p_SoHDN in varchar2,
    p_MaSP in varchar2,
    p_MaNV in varchar2,
    p_NgayNhap in date,
    p_SoLuongN in number,
    p_DonGiaN in number
)
is
    v_count number;
begin
    if p_SoHDN is null then raise_application_error(-20000, 'So hoa don khong duoc de trong'); end if;

    select count(*) into v_count from SanPham where MaSP = p_MaSP;
    if v_count = 0 then
        raise_application_error(-20003, 'Ma san pham khong ton tai');
    end if;

    select count(*) into v_count from NhanVien where MaNV = p_MaNV;
    if v_count = 0 then
        raise_application_error(-20004, 'Ma nhan vien khong ton tai');
    end if;

    select count(*) into v_count from PNhap where SoHDN = p_SoHDN;
    if v_count > 0 then
        update PNhap set NgayNhap = p_NgayNhap, MaNV = p_MaNV where SoHDN = p_SoHDN;
        
        select count(*) into v_count from Nhap where SoHDN = p_SoHDN and MaSP = p_MaSP;
        if v_count > 0 then
            update Nhap set SoLuongN = p_SoLuongN, DonGiaN = p_DonGiaN
            where SoHDN = p_SoHDN and MaSP = p_MaSP;
        else
            insert into Nhap(SoHDN, MaSP, SoLuongN, DonGiaN)
            values(p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
        end if;
    else
        insert into PNhap(SoHDN, NgayNhap, MaNV) values(p_SoHDN, p_NgayNhap, p_MaNV);
        insert into Nhap(SoHDN, MaSP, SoLuongN, DonGiaN) values(p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
    end if;
end;
/

-- f. Thu tuc Nhap bang Xuat
create or replace procedure sp_NhapXuat(
    p_SoHDX in varchar2,
    p_MaSP in varchar2,
    p_MaNV in varchar2,
    p_NgayXuat in date,
    p_SoLuongX in number
)
is
    v_count number;
    v_SoLuongTon number;
begin
    if p_SoHDX is null then raise_application_error(-20000, 'So hoa don khong duoc de trong'); end if;

    begin
        select SoLuong into v_SoLuongTon from SanPham where MaSP = p_MaSP;
    exception when no_data_found then
        raise_application_error(-20005, 'Ma san pham khong ton tai');
    end;

    select count(*) into v_count from NhanVien where MaNV = p_MaNV;
    if v_count = 0 then
        raise_application_error(-20006, 'Ma nhan vien khong ton tai');
    end if;

    if p_SoLuongX > v_SoLuongTon then
        raise_application_error(-20007, 'So luong xuat vuot qua ton kho');
    end if;

    select count(*) into v_count from PXuat where SoHDX = p_SoHDX;
    if v_count > 0 then
        update PXuat set NgayXuat = p_NgayXuat, MaNV = p_MaNV where SoHDX = p_SoHDX;
        
        select count(*) into v_count from Xuat where SoHDX = p_SoHDX and MaSP = p_MaSP;
        if v_count > 0 then
            update Xuat set SoLuongX = p_SoLuongX where SoHDX = p_SoHDX and MaSP = p_MaSP;
        else
            insert into Xuat(SoHDX, MaSP, SoLuongX) values(p_SoHDX, p_MaSP, p_SoLuongX);
        end if;
    else
        insert into PXuat(SoHDX, NgayXuat, MaNV) values(p_SoHDX, p_NgayXuat, p_MaNV);
        insert into Xuat(SoHDX, MaSP, SoLuongX) values(p_SoHDX, p_MaSP, p_SoLuongX);
    end if;
end;
/

-- g. Thu tuc Xoa NhanVien
create or replace procedure sp_xoaNhanVien(
    p_MaNV in varchar2
)
is
    v_count number;
begin
    select count(*) into v_count from NhanVien where MaNV = p_MaNV;
    if v_count = 0 then
        raise_application_error(-20008, 'Ma nhan vien khong ton tai');
    end if;

    delete from Nhap where SoHDN in (select SoHDN from PNhap where MaNV = p_MaNV);
    delete from PNhap where MaNV = p_MaNV;
    delete from Xuat where SoHDX in (select SoHDX from PXuat where MaNV = p_MaNV);
    delete from PXuat where MaNV = p_MaNV;
    delete from NhanVien where MaNV = p_MaNV;
end;
/

-- h. Thu tuc Xoa SanPham
create or replace procedure sp_xoaSanPham(
    p_MaSP in varchar2
)
is
    v_count number;
begin
    select count(*) into v_count from SanPham where MaSP = p_MaSP;
    if v_count = 0 then
        raise_application_error(-20009, 'Ma san pham khong ton tai');
    end if;

    delete from Nhap where MaSP = p_MaSP;
    delete from Xuat where MaSP = p_MaSP;
    delete from SanPham where MaSP = p_MaSP;
end;
/

-- phieu bai tap 2

-- a. thu tuc them nhan vien
create or replace procedure sp_ThemNhanVien(
    p_MaNV in varchar2,
    p_TenNV in varchar2,
    p_GioiTinh in varchar2,
    p_DiaChi in varchar2,
    p_SoDT in varchar2,
    p_Email in varchar2,
    p_TenPhong in varchar2,
    p_Flag in number,
    p_KQ out number
)
is
begin
    if p_MaNV is null then p_KQ := 1; return; end if;
    if p_TenNV is null then p_KQ := 1; return; end if;

    if p_GioiTinh != 'Nam' and p_GioiTinh != 'Nữ' then
        p_KQ := 1;
        return;
    end if;
    
    if p_Flag = 0 then
        insert into NhanVien(MaNV, TenNV, GioiTinh, DiaChi, SoDT, Email, TenPhong)
        values(p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi, p_SoDT, p_Email, p_TenPhong);
    else
        update NhanVien set TenNV = p_TenNV, GioiTinh = p_GioiTinh, DiaChi = p_DiaChi,
            SoDT = p_SoDT, Email = p_Email, TenPhong = p_TenPhong
        where MaNV = p_MaNV;
    end if;
    p_KQ := 0;
end;
/

-- b. thu tuc them moi san pham
create or replace procedure sp_ThemMoiSP(
    p_MaSP in varchar2,
    p_TenHang in varchar2,
    p_TenSP in varchar2,
    p_SoLuong in number,
    p_MauSac in varchar2,
    p_GiaBan in number,
    p_DonViTinh in varchar2,
    p_MoTa in varchar2,
    p_Flag in number,
    p_KQ out number
)
is
    v_MaHangSX varchar2(10);
    v_count number;
begin
    if p_MaSP is null then p_KQ := 1; return; end if;
    if p_TenSP is null then p_KQ := 1; return; end if;

    select count(*) into v_count from HangSX where TenHang = p_TenHang;
    if v_count = 0 then
        p_KQ := 1;
        return;
    end if;
    
    if p_SoLuong < 0 then
        p_KQ := 2;
        return;
    end if;
    
    select MaHangSX into v_MaHangSX from HangSX where TenHang = p_TenHang;
    
    if p_Flag = 0 then
        insert into SanPham(MaSP, MaHangSX, TenSP, SoLuong, MauSac, GiaBan, DonViTinh, MoTa)
        values(p_MaSP, v_MaHangSX, p_TenSP, p_SoLuong, p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);
    else
        update SanPham set MaHangSX = v_MaHangSX, TenSP = p_TenSP, SoLuong = p_SoLuong,
            MauSac = p_MauSac, GiaBan = p_GiaBan, DonViTinh = p_DonViTinh, MoTa = p_MoTa
        where MaSP = p_MaSP;
    end if;
    p_KQ := 0;
end;
/

-- c. thu tuc xoa nhan vien (co out)
create or replace procedure sp_xoaNhanVien_2(
    p_MaNV in varchar2,
    p_KQ out number
)
is
    v_count number;
begin
    select count(*) into v_count from NhanVien where MaNV = p_MaNV;
    if v_count = 0 then
        p_KQ := 1;
        return;
    end if;
    
    delete from Nhap where SoHDN in (select SoHDN from PNhap where MaNV = p_MaNV);
    delete from PNhap where MaNV = p_MaNV;
    delete from Xuat where SoHDX in (select SoHDX from PXuat where MaNV = p_MaNV);
    delete from PXuat where MaNV = p_MaNV;
    delete from NhanVien where MaNV = p_MaNV;
    p_KQ := 0;
end;
/

-- d. thu tuc xoa san pham (co out)
create or replace procedure sp_xoaSanPham_2(
    p_MaSP in varchar2,
    p_KQ out number
)
is
    v_count number;
begin
    select count(*) into v_count from SanPham where MaSP = p_MaSP;
    if v_count = 0 then
        p_KQ := 1;
        return;
    end if;
    
    delete from Nhap where MaSP = p_MaSP;
    delete from Xuat where MaSP = p_MaSP;
    delete from SanPham where MaSP = p_MaSP;
    p_KQ := 0;
end;
/

-- e. thu tuc nhap hang sx (co out)
create or replace procedure sp_NhapHangSX_2(
    p_MaHangSX in varchar2,
    p_TenHang in varchar2,
    p_DiaChi in varchar2,
    p_SoDT in varchar2,
    p_Email in varchar2,
    p_KQ out number
)
is
    v_count number;
begin
    if p_MaHangSX is null then p_KQ := 1; return; end if;
    if p_TenHang is null then p_KQ := 1; return; end if;

    select count(*) into v_count from HangSX where MaHangSX = p_MaHangSX;
    if v_count > 0 then
        p_KQ := 1; return;
    end if;

    select count(*) into v_count from HangSX where TenHang = p_TenHang;
    if v_count > 0 then
        p_KQ := 1;
        return;
    end if;
    
    insert into HangSX(MaHangSX, TenHang, DiaChi, SoDT, Email)
    values(p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);
    p_KQ := 0;
end;
/

-- f. thu tuc nhap bang nhap (co out)
create or replace procedure sp_NhapNhap_2(
    p_SoHDN in varchar2,
    p_MaSP in varchar2,
    p_MaNV in varchar2,
    p_NgayNhap in date,
    p_SoLuongN in number,
    p_DonGiaN in number,
    p_KQ out number
)
is
    v_count number;
begin
    if p_SoHDN is null then p_KQ := 1; return; end if;

    select count(*) into v_count from SanPham where MaSP = p_MaSP;
    if v_count = 0 then
        p_KQ := 1;
        return;
    end if;
    
    select count(*) into v_count from NhanVien where MaNV = p_MaNV;
    if v_count = 0 then
        p_KQ := 2;
        return;
    end if;
    
    select count(*) into v_count from PNhap where SoHDN = p_SoHDN;
    if v_count > 0 then
        update PNhap set NgayNhap = p_NgayNhap, MaNV = p_MaNV where SoHDN = p_SoHDN;
        
        select count(*) into v_count from Nhap where SoHDN = p_SoHDN and MaSP = p_MaSP;
        if v_count > 0 then
            update Nhap set SoLuongN = p_SoLuongN, DonGiaN = p_DonGiaN
            where SoHDN = p_SoHDN and MaSP = p_MaSP;
        else
            insert into Nhap(SoHDN, MaSP, SoLuongN, DonGiaN)
            values(p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
        end if;
    else
        insert into PNhap(SoHDN, NgayNhap, MaNV) values(p_SoHDN, p_NgayNhap, p_MaNV);
        insert into Nhap(SoHDN, MaSP, SoLuongN, DonGiaN) values(p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
    end if;
    p_KQ := 0;
end;
/

-- g. thu tuc nhap bang xuat (co out)
create or replace procedure sp_NhapXuat_2(
    p_SoHDX in varchar2,
    p_MaSP in varchar2,
    p_MaNV in varchar2,
    p_NgayXuat in date,
    p_SoLuongX in number,
    p_KQ out number
)
is
    v_count number;
    v_SoLuongTon number;
begin
    if p_SoHDX is null then p_KQ := 1; return; end if;

    select count(*) into v_count from SanPham where MaSP = p_MaSP;
    if v_count = 0 then
        p_KQ := 1;
        return;
    end if;
    
    select count(*) into v_count from NhanVien where MaNV = p_MaNV;
    if v_count = 0 then
        p_KQ := 2;
        return;
    end if;
    
    select SoLuong into v_SoLuongTon from SanPham where MaSP = p_MaSP;
    if p_SoLuongX > v_SoLuongTon then
        p_KQ := 3;
        return;
    end if;
    
    select count(*) into v_count from PXuat where SoHDX = p_SoHDX;
    if v_count > 0 then
        update PXuat set NgayXuat = p_NgayXuat, MaNV = p_MaNV where SoHDX = p_SoHDX;
        
        select count(*) into v_count from Xuat where SoHDX = p_SoHDX and MaSP = p_MaSP;
        if v_count > 0 then
            update Xuat set SoLuongX = p_SoLuongX where SoHDX = p_SoHDX and MaSP = p_MaSP;
        else
            insert into Xuat(SoHDX, MaSP, SoLuongX) values(p_SoHDX, p_MaSP, p_SoLuongX);
        end if;
    else
        insert into PXuat(SoHDX, NgayXuat, MaNV) values(p_SoHDX, p_NgayXuat, p_MaNV);
        insert into Xuat(SoHDX, MaSP, SoLuongX) values(p_SoHDX, p_MaSP, p_SoLuongX);
    end if;
    p_KQ := 0;
end;
/

-- Script them du lieu mau (chay cai nay de test)
begin
    -- 1. HangSX (bo qua loi neu da ton tai)
    begin sp_NhapHangSX('H01', 'Samsung', 'Korea', '0123456789', 'ss@test.com'); exception when others then null; end;
    begin sp_NhapHangSX('H02', 'Apple', 'USA', '0987654321', 'apple@test.com'); exception when others then null; end;
    begin sp_NhapHangSX('H03', 'Xiaomi', 'China', '0988777666', 'mi@test.com'); exception when others then null; end;
    begin sp_NhapHangSX('H04', 'Sony', 'Japan', '0911223344', 'sony@test.com'); exception when others then null; end;
    begin sp_NhapHangSX('H05', 'Oppo', 'China', '0905554443', 'oppo@test.com'); exception when others then null; end;

    -- 2. NhanVien (flag=1 la them moi)
    begin sp_NhapNhanVien('NV01', 'Nguyen Van A', 'Nam', 'Ha Noi', '0901234567', 'nva@test.com', 'Ke Toan', 1); exception when others then null; end;
    begin sp_NhapNhanVien('NV02', 'Tran Thi B', 'Nu', 'HCM', '0909876543', 'ttb@test.com', 'Ban Hang', 1); exception when others then null; end;
    begin sp_NhapNhanVien('NV03', 'Le Van C', 'Nam', 'Da Nang', '0912345678', 'lvc@test.com', 'Kho', 1); exception when others then null; end;
    begin sp_NhapNhanVien('NV04', 'Pham Thi D', 'Nu', 'Can Tho', '0933445566', 'ptd@test.com', 'Hanh Chinh', 1); exception when others then null; end;
    begin sp_NhapNhanVien('NV05', 'Hoang Van E', 'Nam', 'Hai Phong', '0988776655', 'hve@test.com', 'Giam Doc', 1); exception when others then null; end;

    -- 3. SanPham (tu dong update neu da co)
    sp_NhapSP('SP01', 'Samsung', 'Galaxy S24', 100, 'Den', 20000000, 'Cai', 'Flagship');
    sp_NhapSP('SP02', 'Apple', 'iPhone 15', 50, 'Trang', 30000000, 'Cai', 'Flagship');
    sp_NhapSP('SP03', 'Samsung', 'Galaxy A54', 200, 'Xanh', 8000000, 'Cai', 'Mid-range');
    sp_NhapSP('SP04', 'Xiaomi', 'Xiaomi 14', 80, 'Den', 15000000, 'Cai', 'Flagship');
    sp_NhapSP('SP05', 'Sony', 'Xperia 1 V', 30, 'Tim', 25000000, 'Cai', 'Camera phone');

    -- 4. Nhap (tu dong update neu da co)
    sp_NhapNhap('PN01', 'SP01', 'NV01', sysdate-60, 10, 18000000);
    sp_NhapNhap('PN01', 'SP02', 'NV01', sysdate-60, 5, 28000000);
    sp_NhapNhap('PN02', 'SP03', 'NV02', sysdate-30, 20, 7000000);
    sp_NhapNhap('PN03', 'SP04', 'NV03', sysdate-10, 15, 13000000);
    sp_NhapNhap('PN04', 'SP05', 'NV01', sysdate-5, 5, 22000000);

    -- 5. Xuat (tu dong update neu da co)
    sp_NhapXuat('PX01', 'SP01', 'NV02', sysdate-20, 2);
    sp_NhapXuat('PX01', 'SP02', 'NV02', sysdate-20, 1);
    sp_NhapXuat('PX02', 'SP03', 'NV01', sysdate-15, 5);
    sp_NhapXuat('PX03', 'SP04', 'NV03', sysdate-5, 3);
    sp_NhapXuat('PX04', 'SP05', 'NV02', sysdate-1, 1);
    
    commit;
end;
/
