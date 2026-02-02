alter session set current_schema = dotientri;

-- dọn dẹp bảng cũ nếu có
drop table tai_khoan_goi cascade constraints;
drop table tai_khoan_vay cascade constraints;
drop table chi_nhanh cascade constraints;
drop table ngan_hang cascade constraints;
drop table khach_hang cascade constraints;

-- 1. bảng ngân hàng
create table ngan_hang (
                           manh varchar2(10),
                           tennh varchar2(100),
                           primary key (manh)
);

-- 2. bảng chi nhánh (thuộc ngân hàng)
create table chi_nhanh (
                           macn varchar2(10),
                           manh varchar2(10),
                           thanhphocn varchar2(50),
                           taisan number(15,2),
                           primary key (macn),
                           foreign key (manh) references ngan_hang(manh)
);

-- 3. bảng khách hàng
create table khach_hang (
                            makh varchar2(10),
                            tenkh varchar2(100),
                            diachi varchar2(200),
                            primary key (makh)
);

-- 4. bảng tài khoản vay (nối khách hàng và chi nhánh)
create table tai_khoan_vay (
                               sotkv varchar2(20),
                               makh varchar2(10),
                               macn varchar2(10),
                               sotienvay number(15,2),
                               primary key (sotkv),
                               foreign key (makh) references khach_hang(makh),
                               foreign key (macn) references chi_nhanh(macn)
);

-- 5. bảng tài khoản gởi (nối khách hàng và chi nhánh)
create table tai_khoan_goi (
                               sotkg varchar2(20),
                               makh varchar2(10),
                               macn varchar2(10),
                               sotiengoi number(15,2),
                               primary key (sotkg),
                               foreign key (makh) references khach_hang(makh),
                               foreign key (macn) references chi_nhanh(macn)
);
insert into ngan_hang values ('1', 'ngan hang cong thuong');
insert into ngan_hang values ('2', 'ngan hang ngoai thuong');
insert into ngan_hang values ('3', 'ngan hang nong nghiep');
insert into ngan_hang values ('4', 'ngan hang a chau');
insert into ngan_hang values ('5', 'ngan hang thuong tin');

insert into chi_nhanh values ('CN01', '1', 'da lat', 2000000000);
insert into chi_nhanh values ('CN02', '2', 'nha trang', 2700000000);
insert into chi_nhanh values ('CN03', '3', 'thanh hoa', 4500000000);
insert into chi_nhanh values ('CN04', '4', 'tp hcm', 6000000000);
insert into chi_nhanh values ('CN05', '5', 'da nang', 7000000000);
insert into chi_nhanh values ('CN11', '1', 'tp hcm', 5000000000);
insert into chi_nhanh values ('CN12', '2', 'hue', 1400000000);
insert into chi_nhanh values ('CN13', '3', 'da nang', 3600000000);
insert into chi_nhanh values ('CN14', '4', 'ha noi', 5700000000);
insert into chi_nhanh values ('CN21', '1', 'ha noi', 3500000000);
insert into chi_nhanh values ('CN22', '2', 'ha noi', 4500000000);
insert into chi_nhanh values ('CN23', '3', 'da lat', 2400000000);
insert into chi_nhanh values ('CN31', '1', 'da nang', 4000000000);
insert into chi_nhanh values ('CN32', '2', 'tp hcm', 5600000000);
insert into chi_nhanh values ('CN33', '3', 'can tho', 5400000000);
insert into chi_nhanh values ('CN43', '3', 'nam dinh', 3600000000);

insert into khach_hang values ('111222333', 'ho thi thanh thao', '456 le duan, ha noi');
insert into khach_hang values ('112233445', 'tran van tien', '12 dien bien phu, q1, tp hcm');
insert into khach_hang values ('123123123', 'phan thi quynh nhu', '54 hai ba trung, ha noi');
insert into khach_hang values ('123412341', 'nguyen van thao', '34 tran phu, tp nha trang');
insert into khach_hang values ('123456789', 'nguyen thi hoa', '1/4 hoang van thu, da lat');
insert into khach_hang values ('221133445', 'nguyen thi kim mai', '4 tran binh trong, da lat');
insert into khach_hang values ('222111333', 'do tien dong', '123 tran phu, nam dinh');
insert into khach_hang values ('331122445', 'bui thi dong', '345 tran hung dao, thanh hoa');
insert into khach_hang values ('333111222', 'tran dinh hung', '783 ly thuong kiet, can tho');
insert into khach_hang values ('441122335', 'nguyen dinh cuong', 'p12 thanh xuan nam, q thanh xuan');
insert into khach_hang values ('456456456', 'tran nam son', '5 le duan, tp da nang');
insert into khach_hang values ('551122334', 'tran thi khanh van', '1a ho tung mau, da lat');
insert into khach_hang values ('987654321', 'ho thanh son', '209 tran hung dao, q5, tp hcm');

insert into tai_khoan_goi values ('00001A', '123123123', 'CN01', 10000000);
insert into tai_khoan_goi values ('00001C', '123456789', 'CN01', 127000000);
insert into tai_khoan_goi values ('00002A', '221133445', 'CN02', 12500000);
insert into tai_khoan_goi values ('00003H', '456456456', 'CN03', 123000000);
insert into tai_khoan_goi values ('00005A', '222111333', 'CN05', 1200000);
insert into tai_khoan_goi values ('00005D', '987654321', 'CN05', 345000000);
insert into tai_khoan_goi values ('00005N', '123412341', 'CN05', 45000000);
insert into tai_khoan_goi values ('00003A', '331122445', 'CN13', 27000000);
insert into tai_khoan_goi values ('00004D', '551122334', 'CN14', 560000000);
insert into tai_khoan_goi values ('00004P', '123456789', 'CN14', 35400000);
insert into tai_khoan_goi values ('00001B', '123412341', 'CN21', 67000000);
insert into tai_khoan_goi values ('00002G', '222111333', 'CN22', 56000000);
insert into tai_khoan_goi values ('00004F', '987654321', 'CN23', 4500000);
insert into tai_khoan_goi values ('00003D', '333111222', 'CN33', 47000000);

insert into tai_khoan_vay values ('10001A', '111222333', 'CN01', 10000000);
insert into tai_khoan_vay values ('10002A', '333111222', 'CN02', 6000000);
insert into tai_khoan_vay values ('10004A', '551122334', 'CN04', 20000000);
insert into tai_khoan_vay values ('10005G', '221133445', 'CN05', 15000000);
insert into tai_khoan_vay values ('10001D', '987654321', 'CN11', 45000000);
insert into tai_khoan_vay values ('10002D', '112233445', 'CN12', 12000000);
insert into tai_khoan_vay values ('10003F', '441122335', 'CN13', 5500000);
insert into tai_khoan_vay values ('10005A', '123123123', 'CN14', 12500000);

commit;


-- 1
select distinct n.tennh from ngan_hang n
join chi_nhanh c on n.manh = c.manh
where lower(c.thanhphocn) = 'da lat';
-- 2
select distinct c.thanhphocn from chi_nhanh c
join ngan_hang n on c.manh = n.manh
where lower(n.tennh) like '%cong thuong%';
-- 3
select c.* from chi_nhanh c
join ngan_hang n on c.manh = n.manh
where lower(n.tennh) like '%cong thuong%' and lower(c.thanhphocn) = 'tp hcm';
-- 4
select n.tennh, c.macn, c.thanhphocn, c.taisan
from ngan_hang n join chi_nhanh c on n.manh = c.manh;
-- 5
select * from khach_hang where lower(diachi) like '%ha noi%';
-- 6
select * from khach_hang where lower(tenkh) like '% son';
-- 7
select * from khach_hang where lower(diachi) like '%tran hung dao%';
-- 8
select * from khach_hang where lower(tenkh) like '% thao';
-- 9
select * from khach_hang
where makh like '11%' and lower(diachi) like '%tp hcm%';
-- 10
select n.tennh, c.thanhphocn, c.taisan
from ngan_hang n join chi_nhanh c on n.manh = c.manh
order by c.taisan asc, c.thanhphocn asc;
-- 11
select n.*, c.* from ngan_hang n
join chi_nhanh c on n.manh = c.manh
where c.taisan > 3000000000 and c.taisan < 5000000000;
-- 12
select n.tennh, avg(c.taisan) as trung_binh_ts
from ngan_hang n join chi_nhanh c on n.manh = c.manh
group by n.tennh;
-- 13
select k.* from khach_hang k
                    join tai_khoan_vay v on k.makh = v.makh
                    join chi_nhanh c on v.macn = c.macn
                    join ngan_hang n on c.manh = n.manh
where lower(n.tennh) like '%cong thuong%' and lower(k.tenkh) like '% thao';
-- 14
select n.tennh, sum(c.taisan) as tong_tai_san
from ngan_hang n join chi_nhanh c on n.manh = c.manh
group by n.tennh;
-- 15
select macn, taisan from chi_nhanh
where taisan = (select max(taisan) from chi_nhanh);
-- 16
select distinct k.* from khach_hang k
                             join tai_khoan_goi g on k.makh = g.makh
                             join chi_nhanh c on g.macn = c.macn
                             join ngan_hang n on c.manh = n.manh
where lower(n.tennh) like '%a chau%';
-- 17
select v.sotkv from tai_khoan_vay v
                        join chi_nhanh c on v.macn = c.macn
                        join ngan_hang n on c.manh = n.manh
where lower(n.tennh) like '%ngoai thuong%' and v.sotienvay > 1200000;
-- 18
select macn, sum(sotiengoi) as tong_tien_goi
from tai_khoan_goi group by macn;
-- 19
select k.tenkh, v.sotkv, v.sotienvay, g.sotkg, g.sotiengoi
from khach_hang k
         left join tai_khoan_vay v on k.makh = v.makh
         left join tai_khoan_goi g on k.makh = g.makh
where lower(k.tenkh) like '% son';
-- 20
select k.tenkh, sum(v.sotienvay) as tong_vay
from khach_hang k join tai_khoan_vay v on k.makh = v.makh
group by k.makh, k.tenkh
having sum(v.sotienvay) > 30000000;

