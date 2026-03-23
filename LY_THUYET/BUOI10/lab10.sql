-- phieu 1

create or replace trigger trg_nhap
   before insert on nhap
 for each row
       declare
  v_count number;
   begin
 select count(*) into v_count from sanpham where masp=:new.masp;

           if v_count=0 then
     raise_application_error(-20001, 'loi: ma san pham khong ton tai trong bang sanpham');
  end if;
        if :new.soluongn <=0 or :new.dongian<= 0 then
raise_application_error(-20002, 'loi: so luong nhap va don gia nhap phai lon hon 0');
     end if;
  update sanpham set soluong = nvl(soluong,0) + :new.soluongn where masp = :new.masp;
       end;
  /

      insert into hangsx(mahangsx, tenhang) values ('hsx01', 'apple');
 insert into sanpham(masp, mahangsx, tensp, soluong) values ('sp01', 'hsx01', 'iphone 15', 100);
   insert into nhanvien(manv, tennv) values ('nv01', 'nguyen van a');
insert into pnhap(sohdn, ngaynhap, manv) values ('hdn01', sysdate, 'nv01');
      insert into pxuat(sohdx, ngayxuat, manv) values ('hdx01', sysdate, 'nv01');

insert into nhap(sohdn, masp, soluongn, dongian) values ('hdn01','sp01', 50, 15000000);
          insert into nhap(sohdn, masp, soluongn, dongian) values ('hdn01', 'sp01', -50, 15000000);

 create or replace trigger trg_xuat
      before insert on xuat
   for each row
   declare
 v_count number;
v_soluong number;
         begin
   select count(*) into v_count from sanpham where masp =:new.masp;
if v_count=0 then
  raise_application_error(-20003, 'loi: ma san pham khong ton tai trong bang sanpham');
       end if;

      select nvl(soluong, 0) into v_soluong from sanpham where masp= :new.masp;
if :new.soluongx > v_soluong then
     raise_application_error(-20004, 'loi: so luong xuat lon hon so luong trong kho');
   end if;
  update sanpham set soluong=soluong-:new.soluongx where masp = :new.masp;
      end;
   /

insert into xuat(sohdx,masp,soluongx) values ('hdx01', 'sp01', 10);
    insert into xuat(sohdx,masp,soluongx) values ('hdx01', 'sp01', 9999);

     create or replace trigger trg_xoaxuat
  after delete on xuat
        for each row
 begin
  update sanpham set soluong = nvl(soluong,0) +:old.soluongx where masp=:old.masp;
      end;
  /

 delete from xuat where sohdx='hdx01' and masp='sp01';

   create or replace package pkg_state as
 v_count_xuat number := 0;
   v_count_nhap number := 0;
        end;
 /
--  phieu 2S
  create or replace trigger trg_capnhatxuat
for update on xuat
   compound trigger
 before statement is
       begin
  pkg_state.v_count_xuat := 0;
    end before statement;

 before each row is
  v_soluong_ton number;
  begin
pkg_state.v_count_xuat := pkg_state.v_count_xuat + 1;
     if pkg_state.v_count_xuat > 1 then
  raise_application_error(-20020, 'loi: khong duoc update > 1 dong trong bang xuat');
   end if;
      
 if :new.soluongx != :old.soluongx then
  select nvl(soluong, 0) into v_soluong_ton from sanpham where masp = :new.masp;
 if v_soluong_ton < (:new.soluongx - :old.soluongx) then
 raise_application_error(-20021, 'loi: khong du hang xuat de bu chenh lech');
      end if;
       end if;
   end before each row;

    after each row is
 begin
if :new.soluongx != :old.soluongx then
  update sanpham set soluong = soluong - (:new.soluongx - :old.soluongx) where masp = :new.masp;
     end if;
  end after each row;
     end trg_capnhatxuat;
   /

create or replace trigger trg_capnhatnhap
   for update on nhap
      compound trigger
 before statement is
  begin
 pkg_state.v_count_nhap := 0;
     end before statement;

   before each row is
begin
 pkg_state.v_count_nhap := pkg_state.v_count_nhap + 1;
      if pkg_state.v_count_nhap > 1 then
 raise_application_error(-20022, 'loi: khong duoc update > 1 dong trong bang nhap');
   end if;
  end before each row;

 after each row is
       begin
 if :new.soluongn != :old.soluongn then
 update sanpham set soluong = nvl(soluong, 0) + (:new.soluongn - :old.soluongn) where masp = :new.masp;
     end if;
  end after each row;
       end trg_capnhatnhap;
  /

 create or replace trigger trg_xoanhap
  after delete on nhap
 for each row
       begin
 update sanpham set soluong = nvl(soluong, 0) - :old.soluongn where masp = :old.masp;
  end;
 /


     create sequence seq_hd start with 1 increment by 1;
 create sequence seq_ls start with 1 increment by 1;
-- phieu 3
create or replace trigger trg_datphong
  for insert on hoadon
 compound trigger
       v_phong phong%rowtype;
     before each row is
  v_count_kh number;
  begin
select count(*) into v_count_kh from khachhang where makh = :new.makh;
    if v_count_kh = 0 then
 raise_application_error(-20030, 'loi: khach hang khong ton tai');
  end if;
        
 begin
       select * into v_phong from phong where maphong = :new.maphong;
   exception
 when no_data_found then
 raise_application_error(-20031, 'loi: phong khong ton tai');
       end;

     if v_phong.trangthai != 'trong' then
   raise_application_error(-20032, 'loi: phong dang khong trong');
  end if;

 if :new.songuoi > v_phong.songuoitoida then
  raise_application_error(-20033, 'loi: vuot qua so nguoi toi da cua phong');
       end if;

 if :new.ngaynhan >= :new.ngaytra or :new.ngaynhan < trunc(sysdate) then
  raise_application_error(-20034, 'loi: ngay nhan tra phong khong hop le');
  end if;

 :new.tongtien := greatest(1, trunc(:new.ngaytra) - trunc(:new.ngaynhan)) * v_phong.giatheongay;
       :new.trangthai := 'cho_nhan';
  end before each row;

    after each row is
 begin
  update phong set trangthai = 'da_thue' where maphong = :new.maphong;
  end after each row;
     end trg_datphong;
  /

create or replace trigger trg_capnhattrangthaihd
   for update of trangthai on hoadon
 compound trigger
       before each row is
  begin
 if :old.trangthai = 'cho_nhan' and :new.trangthai not in ('dang_o', 'huy') then
 raise_application_error(-20035, 'loi: tu cho_nhan chi co the chuyen sang dang_o hoac huy');
 elsif :old.trangthai = 'dang_o' and :new.trangthai != 'da_tra' then
   raise_application_error(-20036, 'loi: tu dang_o chi co the chuyen sang da_tra');
 elsif :old.trangthai in ('da_tra', 'huy') and :old.trangthai != :new.trangthai then
 raise_application_error(-20037, 'loi: khong the thay doi trang thai khi da da_tra hoac huy');
  end if;
       end before each row;

 after each row is
  v_mals varchar2(20);
 begin
       if :new.trangthai = 'da_tra' then
  update phong set trangthai = 'trong' where maphong = :new.maphong;
 v_mals := 'ls' || to_char(seq_ls.nextval, 'fm000000');
   insert into lichsuphong(mals, maphong, mahd, ngaynhan, ngaytra, ghichu)
  values (v_mals, :new.maphong, :new.mahd, :new.ngaynhan, :new.ngaytra, 'hoan tat tra phong');
 elsif :new.trangthai = 'huy' then
   update phong set trangthai = 'trong' where maphong = :new.maphong;
  end if;
       end after each row;
     end trg_capnhattrangthaihd;
   /

  create or replace trigger trg_suachiphi
 for insert or update on chiphiphuthu
  compound trigger
 v_count number := 0;
 type t_hd_list is table of hoadon.mahd%type;
       v_hds t_hd_list := t_hd_list();
        
 before statement is
      begin
 v_count := 0;
  v_hds.delete;
  end before statement;

       before each row is
 begin
  v_count := v_count + 1;
 if v_count > 5 then
   raise_application_error(-20038, 'loi: chi duoc tao/sua toi da 5 chi phi 1 lan');
  end if;
 if :new.sotien <= 0 or :new.sotien >= 50000000 then
 raise_application_error(-20039, 'loi: so tien chi phi vuot muc quy dinh');
       end if;
  end before each row;

 after each row is
 v_exists boolean := false;
       begin
 for i in 1 .. v_hds.count loop
  if v_hds(i) = :new.mahd then
  v_exists := true;
 exit;
  end if;
       end loop;
 if not v_exists then
  v_hds.extend;
 v_hds(v_hds.last) := :new.mahd;
       end if;
  end after each row;

    after statement is
 v_tong_phu_thu number;
       v_phong phong%rowtype;
 v_hd hoadon%rowtype;
  begin
 for i in 1 .. v_hds.count loop
 select nvl(sum(sotien), 0) into v_tong_phu_thu from chiphiphuthu where mahd = v_hds(i);
                
  select * into v_hd from hoadon where mahd = v_hds(i);
 select * into v_phong from phong where maphong = v_hd.maphong;
                
 update hoadon 
  set tongtien = (greatest(1, trunc(v_hd.ngaytra) - trunc(v_hd.ngaynhan)) * v_phong.giatheongay) + v_tong_phu_thu 
       where mahd = v_hds(i);
  end loop;
  end after statement;
     end trg_suachiphi;
 /

create or replace view vw_phongtrong as
       select maphong, loaiphong, trangthai, giatheogio, giatheongay, songuoitoida
 from phong where trangthai = 'trong';

  create or replace trigger trg_vwphongtrong_ins
 instead of insert on vw_phongtrong
  for each row
       declare
 v_mahd varchar2(20);
 v_makh varchar2(10);
  begin
 select min(makh) into v_makh from khachhang;
            
 if v_makh is null then
  raise_application_error(-20040, 'loi: chua co khach hang nao trong he thong');
       end if;
            
  v_mahd := 'hd' || to_char(seq_hd.nextval, 'fm0000');
            
 insert into hoadon(mahd, makh, maphong, ngaynhan, ngaytra, songuoi)
  values (v_mahd, v_makh, :new.maphong, trunc(sysdate), trunc(sysdate) + 1, 1);
       end;
  /