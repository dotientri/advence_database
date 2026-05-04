set serveroutput on size 1000000;

-- 1. tao may cai view truoc

create or replace view vw_course_summary as
select co.ma_mon_hoc, co.mo_ta, co.hoc_phi, count(distinct cl.ma_lop_hoc) as so_lop, count(e.ma_sinh_vien) as tong_sv
from mon_hoc co
left join lop_hoc cl on co.ma_mon_hoc = cl.ma_mon_hoc
left join dang_ky e on cl.ma_lop_hoc = e.ma_lop_hoc
group by co.ma_mon_hoc, co.mo_ta, co.hoc_phi;
/

create or replace view vw_student_status as
select s.ma_sinh_vien, s.ho || ' ' || s.ten as ho_ten, count(e.ma_lop_hoc) as so_lop_hoc,
       nvl(sum(co.hoc_phi), 0) as tong_hoc_phi, round(avg(e.diem_tong_ket), 2) as diem_tb
from sinh_vien s
join dang_ky e on s.ma_sinh_vien = e.ma_sinh_vien
join lop_hoc cl on e.ma_lop_hoc = cl.ma_lop_hoc
join mon_hoc co on cl.ma_mon_hoc = co.ma_mon_hoc
group by s.ma_sinh_vien, s.ho, s.ten
having count(e.ma_lop_hoc) >= 1;
/

create or replace view vw_class_availability as
select cl.ma_lop_hoc, cl.ma_mon_hoc, co.mo_ta, i.ho || ' ' || i.ten as ten_giao_vien,
       cl.suc_chua, count(e.ma_sinh_vien) as so_da_dk,
       cl.suc_chua - count(e.ma_sinh_vien) as cho_trong,
       case when cl.suc_chua - count(e.ma_sinh_vien) > 0 then 'Con cho' else 'Het cho' end as trang_thai
from lop_hoc cl
join mon_hoc co on cl.ma_mon_hoc = co.ma_mon_hoc
join giang_vien i on cl.ma_giang_vien = i.ma_giang_vien
left join dang_ky e on cl.ma_lop_hoc = e.ma_lop_hoc
group by cl.ma_lop_hoc, cl.ma_mon_hoc, co.mo_ta, i.ho, i.ten, cl.suc_chua
having cl.suc_chua - count(e.ma_sinh_vien) > 0;
/

create or replace view vw_top_courses as
select ma_mon_hoc, mo_ta, hoc_phi, tong_dk, hang
from (
    select co.ma_mon_hoc, co.mo_ta, co.hoc_phi, count(e.ma_sinh_vien) as tong_dk,
           rank() over (order by count(e.ma_sinh_vien) desc) as hang
    from mon_hoc co
    left join lop_hoc cl on co.ma_mon_hoc = cl.ma_mon_hoc
    left join dang_ky e on cl.ma_lop_hoc = e.ma_lop_hoc
    group by co.ma_mon_hoc, co.mo_ta, co.hoc_phi
)
where hang <= 5 with read only;
/

create or replace view vw_pending_enrollment as
select ma_sinh_vien, ma_lop_hoc, ngay_ghi_danh, diem_tong_ket, tao_boi, ngay_tao, sua_boi, ngay_sua
from dang_ky
where diem_tong_ket is null
with check option;
/

create or replace view vw_instructor_workload as
select i.ma_giang_vien, i.ho || ' ' || i.ten as ho_ten, count(distinct cl.ma_lop_hoc) as so_lop,
       count(e.ma_sinh_vien) as tong_sv, round(avg(e.diem_tong_ket), 2) as diem_tb_chung,
       case
           when count(distinct cl.ma_lop_hoc) >= 3 then 'Ban nhieu'
           when count(distinct cl.ma_lop_hoc) = 2 then 'Binh thuong'
           else 'Nhe nhang'
       end as muc_ban
from giang_vien i
left join lop_hoc cl on i.ma_giang_vien = cl.ma_giang_vien
left join dang_ky e on cl.ma_lop_hoc = e.ma_lop_hoc
group by i.ma_giang_vien, i.ho, i.ten;
/

-- 2. cac thu tuc procedure

create or replace procedure enroll_student(p_studentid in number, p_classid in number) is
    v_check number;
    v_cap number;
    v_enrolled number;
begin
    select count(*) into v_check from sinh_vien where ma_sinh_vien = p_studentid;
    if v_check = 0 then
        dbms_output.put_line('loi: sv ' || p_studentid || ' k co');
        return;
    end if;

    select count(*) into v_check from lop_hoc where ma_lop_hoc = p_classid;
    if v_check = 0 then
        dbms_output.put_line('loi: lop ' || p_classid || ' k co');
        return;
    end if;

    select count(*) into v_check from dang_ky where ma_sinh_vien = p_studentid and ma_lop_hoc = p_classid;
    if v_check > 0 then
        dbms_output.put_line('loi: dang ky roi ma');
        return;
    end if;

    select count(*) into v_check from dang_ky where ma_sinh_vien = p_studentid;
    if v_check >= 3 then
        dbms_output.put_line('loi: max 3 mon thoi ba');
        return;
    end if;

    select suc_chua into v_cap from lop_hoc where ma_lop_hoc = p_classid;
    select count(*) into v_enrolled from dang_ky where ma_lop_hoc = p_classid;
    if v_enrolled >= v_cap then
        dbms_output.put_line('loi: lop ' || p_classid || ' day roi');
        return;
    end if;

    insert into dang_ky(ma_sinh_vien, ma_lop_hoc, ngay_ghi_danh, tao_boi, ngay_tao, sua_boi, ngay_sua)
    values(p_studentid, p_classid, sysdate, user, sysdate, user, sysdate);
    commit;
    dbms_output.put_line('ok da dang ky sv ' || p_studentid || ' vao lop ' || p_classid);
exception when others then
    rollback;
    dbms_output.put_line('loi: ' || sqlerrm);
end;
/
show errors;

create or replace procedure update_final_grade(p_studentid in number, p_classid in number, p_grade in number) is
    v_check number;
    v_old number;
begin
    if p_grade < 0 or p_grade > 100 then
        dbms_output.put_line('diem phai tu 0 den 100');
        return;
    end if;

    select count(*) into v_check from dang_ky where ma_sinh_vien = p_studentid and ma_lop_hoc = p_classid;
    if v_check = 0 then
        dbms_output.put_line('sv chua hoc lop nay');
        return;
    end if;

    select diem_tong_ket into v_old from dang_ky where ma_sinh_vien = p_studentid and ma_lop_hoc = p_classid;

    update dang_ky set diem_tong_ket = p_grade, sua_boi = user, ngay_sua = sysdate
    where ma_sinh_vien = p_studentid and ma_lop_hoc = p_classid;

    merge into diem_so g
    using (select p_studentid as sid, p_classid as cid, p_grade as gval from dual) src
    on (g.ma_sinh_vien = src.sid and g.ma_lop_hoc = src.cid)
    when matched then
        update set g.diem_so = src.gval, g.sua_boi = user, g.ngay_sua = sysdate
    when not matched then
        insert (ma_sinh_vien, ma_lop_hoc, diem_so, tao_boi, ngay_tao, sua_boi, ngay_sua)
        values (src.sid, src.cid, src.gval, user, sysdate, user, sysdate);

    commit;
    dbms_output.put_line('ok da cap nhat diem sv ' || p_studentid || ' (cu: ' || nvl(to_char(v_old), 'null') || ' -> moi: ' || p_grade || ')');
end;
/
show errors;

create or replace procedure transfer_student(p_studentid in number, p_old_classid in number, p_new_classid in number) is
    v_check number;
    v_cap number;
    v_enrolled number;
begin
    if p_old_classid = p_new_classid then
        dbms_output.put_line('2 lop giong nhau ba noi');
        return;
    end if;

    select count(*) into v_check from dang_ky where ma_sinh_vien = p_studentid and ma_lop_hoc = p_old_classid;
    if v_check = 0 then
        dbms_output.put_line('sv k hoc lop cu');
        return;
    end if;

    select count(*) into v_check from lop_hoc where ma_lop_hoc = p_new_classid;
    if v_check = 0 then
        dbms_output.put_line('lop moi k ton tai');
        return;
    end if;

    select count(*) into v_check from dang_ky where ma_sinh_vien = p_studentid and ma_lop_hoc = p_new_classid;
    if v_check > 0 then
        dbms_output.put_line('sv da co o lop moi roi');
        return;
    end if;

    select suc_chua into v_cap from lop_hoc where ma_lop_hoc = p_new_classid;
    select count(*) into v_enrolled from dang_ky where ma_lop_hoc = p_new_classid;
    if v_enrolled >= v_cap then
        dbms_output.put_line('lop moi full roi');
        return;
    end if;

    savepoint sp_chuyen;
    delete from diem_so where ma_sinh_vien = p_studentid and ma_lop_hoc = p_old_classid;
    delete from dang_ky where ma_sinh_vien = p_studentid and ma_lop_hoc = p_old_classid;

    insert into dang_ky(ma_sinh_vien, ma_lop_hoc, ngay_ghi_danh, tao_boi, ngay_tao, sua_boi, ngay_sua)
    values(p_studentid, p_new_classid, sysdate, user, sysdate, user, sysdate);

    commit;
    dbms_output.put_line('ok da chuyen sv ' || p_studentid || ' tu ' || p_old_classid || ' sang ' || p_new_classid);
exception when others then
    rollback to sp_chuyen;
    dbms_output.put_line('loi roi: ' || sqlerrm);
end;
/
show errors;

create or replace procedure report_class_detail(p_classid in number) is
    v_check number;
    v_course varchar2(100);
    v_courseno number;
    v_teacher varchar2(100);
    v_loc varchar2(50);
    v_cap number;
    v_stt number := 0;
    v_total number := 0;
    v_sum number := 0;
    v_count number := 0;
    v_rank varchar2(20);
begin
    select count(*) into v_check from lop_hoc where ma_lop_hoc = p_classid;
    if v_check = 0 then
        dbms_output.put_line('lop k ton tai');
        return;
    end if;

    select co.mo_ta, co.ma_mon_hoc, i.ho || ' ' || i.ten, cl.dia_diem, cl.suc_chua
    into v_course, v_courseno, v_teacher, v_loc, v_cap
    from lop_hoc cl
    join mon_hoc co on cl.ma_mon_hoc = co.ma_mon_hoc
    join giang_vien i on cl.ma_giang_vien = i.ma_giang_vien
    where cl.ma_lop_hoc = p_classid;

    dbms_output.put_line('===================================');
    dbms_output.put_line('BAO CAO LOP: ' || p_classid);
    dbms_output.put_line('Mon: ' || v_course);
    dbms_output.put_line('GV: ' || v_teacher);
    dbms_output.put_line('Phong: ' || nvl(v_loc, 'chua co'));
    dbms_output.put_line('Suc chua: ' || v_cap);
    dbms_output.put_line('-----------------------------------');

    for r in (
        select s.ho || ' ' || s.ten as hoten, e.diem_tong_ket as diem
        from dang_ky e
        join sinh_vien s on e.ma_sinh_vien = s.ma_sinh_vien
        where e.ma_lop_hoc = p_classid
        order by s.ho, s.ten
    ) loop
        v_stt := v_stt + 1;
        v_total := v_total + 1;

        if r.diem is null then v_rank := 'chua co diem';
        elsif r.diem >= 90 then v_rank := 'A'; v_sum := v_sum + r.diem; v_count := v_count + 1;
        elsif r.diem >= 80 then v_rank := 'B'; v_sum := v_sum + r.diem; v_count := v_count + 1;
        elsif r.diem >= 70 then v_rank := 'C'; v_sum := v_sum + r.diem; v_count := v_count + 1;
        elsif r.diem >= 50 then v_rank := 'D'; v_sum := v_sum + r.diem; v_count := v_count + 1;
        else v_rank := 'F'; v_sum := v_sum + r.diem; v_count := v_count + 1;
        end if;

        dbms_output.put_line(v_stt || '. ' || r.hoten || ' - ' || nvl(to_char(r.diem), 'null') || ' (' || v_rank || ')');
    end loop;
    dbms_output.put_line('-----------------------------------');
    dbms_output.put_line('Tong sv: ' || v_total);
    if v_count > 0 then
        dbms_output.put_line('Diem TB: ' || round(v_sum / v_count, 2));
    end if;
end;
/
show errors;

create or replace procedure sync_grade_from_enrollment is
    v_check number;
    v_ins number := 0;
    v_upd number := 0;
begin
    for r in (select ma_sinh_vien, ma_lop_hoc, diem_tong_ket from dang_ky where diem_tong_ket is not null) loop
        select count(*) into v_check from diem_so where ma_sinh_vien = r.ma_sinh_vien and ma_lop_hoc = r.ma_lop_hoc;
        if v_check = 0 then
            insert into diem_so(ma_sinh_vien, ma_lop_hoc, diem_so, tao_boi, ngay_tao, sua_boi, ngay_sua)
            values(r.ma_sinh_vien, r.ma_lop_hoc, r.diem_tong_ket, user, sysdate, user, sysdate);
            v_ins := v_ins + 1;
        else
            update diem_so set diem_so = r.diem_tong_ket, sua_boi = user, ngay_sua = sysdate
            where ma_sinh_vien = r.ma_sinh_vien and ma_lop_hoc = r.ma_lop_hoc;
            v_upd := v_upd + 1;
        end if;
    end loop;
    commit;
    dbms_output.put_line('ok dong bo xong. Insert: ' || v_ins || ', Update: ' || v_upd);
end;
/
show errors;

create or replace procedure print_system_report is
    v_mon number; v_lop number; v_sv number; v_gv number;
begin
    select count(*) into v_mon from mon_hoc;
    select count(*) into v_lop from lop_hoc;
    select count(*) into v_sv from sinh_vien;
    select count(*) into v_gv from giang_vien;

    dbms_output.put_line('===================================');
    dbms_output.put_line('BAO CAO TOAN HE THONG');
    dbms_output.put_line('===================================');
    dbms_output.put_line('Tong mon: ' || v_mon);
    dbms_output.put_line('Tong lop: ' || v_lop);
    dbms_output.put_line('Tong sv: ' || v_sv);
    dbms_output.put_line('Tong gv: ' || v_gv);
    dbms_output.put_line('-----------------------------------');
    dbms_output.put_line('THONG KE GV:');
    for r in (select * from vw_instructor_workload order by so_lop desc) loop
        dbms_output.put_line(r.ho_ten || ' - ' || r.so_lop || ' lop - ' || r.tong_sv || ' sv - muc do: ' || r.muc_ban);
    end loop;
    dbms_output.put_line('-----------------------------------');
    dbms_output.put_line('TOP 3 MON HOT NHAT:');
    for r in (select * from vw_top_courses where hang <= 3) loop
        dbms_output.put_line(r.hang || '. ' || r.mo_ta || ' (' || r.tong_dk || ' dk)');
    end loop;
end;
/
show errors;

-- 3. may cai trigger

create or replace trigger trg_check_capacity
for insert on dang_ky compound trigger
    type t_map is table of number index by varchar2(30);
    g_map t_map;

    after each row is
        v_k varchar2(30);
    begin
        v_k := to_char(:new.ma_lop_hoc);
        if g_map.exists(v_k) then g_map(v_k) := g_map(v_k) + 1; else g_map(v_k) := 1; end if;
    end after each row;

    after statement is
        v_k varchar2(30);
        v_cap number;
        v_enr number;
    begin
        v_k := g_map.first;
        while v_k is not null loop
            select suc_chua into v_cap from lop_hoc where ma_lop_hoc = to_number(v_k);
            select count(*) into v_enr from dang_ky where ma_lop_hoc = to_number(v_k);
            if v_enr > v_cap then
                raise_application_error(-20010, 'lop ' || v_k || ' full roi');
            end if;
            v_k := g_map.next(v_k);
        end loop;
    end after statement;
end trg_check_capacity;
/
show errors;

begin execute immediate 'drop table nhat_ky_sua_diem'; exception when others then null; end;
/
create table nhat_ky_sua_diem (
    id number generated always as identity primary key,
    ma_sv number, ma_lop number, diem_cu number, diem_moi number, nguoi_sua varchar2(30), luc date
);

create or replace trigger trg_grade_audit
after update of diem_tong_ket on dang_ky
for each row
begin
    if (:old.diem_tong_ket is null and :new.diem_tong_ket is not null) or
       (:old.diem_tong_ket is not null and :new.diem_tong_ket is null) or
       (:old.diem_tong_ket <> :new.diem_tong_ket) then
        insert into nhat_ky_sua_diem(ma_sv, ma_lop, diem_cu, diem_moi, nguoi_sua, luc)
        values(:old.ma_sinh_vien, :old.ma_lop_hoc, :old.diem_tong_ket, :new.diem_tong_ket, user, sysdate);
    end if;
end;
/
show errors;

create or replace trigger trg_no_del_course
before delete on mon_hoc
for each row
declare v_dem number;
begin
    select count(*) into v_dem from lop_hoc where ma_mon_hoc = :old.ma_mon_hoc;
    if v_dem > 0 then
        raise_application_error(-20020, 'mon nay dang co lop k duoc xoa');
    end if;
end;
/
show errors;

begin execute immediate 'drop table tong_hop_diem_lop'; exception when others then null; end;
/
create table tong_hop_diem_lop (
    ma_lop number primary key, so_sv number, diem_tb number(5,2), max_d number, min_d number, cap_nhat date
);

create or replace trigger trg_upd_summary
for insert or update or delete on dang_ky compound trigger
    type t_map is table of number index by varchar2(30);
    g_map t_map;

    procedure mark(p_id number) is v_k varchar2(30); begin v_k := to_char(p_id); g_map(v_k) := 1; end;

    after each row is begin
        if inserting then mark(:new.ma_lop_hoc);
        elsif updating then mark(:old.ma_lop_hoc); mark(:new.ma_lop_hoc);
        else mark(:old.ma_lop_hoc); end if;
    end after each row;

    after statement is
        v_k varchar2(30); v_lop number; v_so_sv number; v_tb number; v_max number; v_min number;
    begin
        v_k := g_map.first;
        while v_k is not null loop
            v_lop := to_number(v_k);
            select count(diem_tong_ket), round(avg(diem_tong_ket), 2), max(diem_tong_ket), min(diem_tong_ket)
            into v_so_sv, v_tb, v_max, v_min
            from dang_ky where ma_lop_hoc = v_lop and diem_tong_ket is not null;

            merge into tong_hop_diem_lop t
            using (select v_lop as cid from dual) s
            on (t.ma_lop = s.cid)
            when matched then
                update set so_sv = v_so_sv, diem_tb = v_tb, max_d = v_max, min_d = v_min, cap_nhat = sysdate
            when not matched then
                insert (ma_lop, so_sv, diem_tb, max_d, min_d, cap_nhat)
                values (v_lop, v_so_sv, v_tb, v_max, v_min, sysdate);
            v_k := g_map.next(v_k);
        end loop;
    end after statement;
end trg_upd_summary;
/
show errors;

-- tao du lieu tong hop
begin
    for r in (select distinct ma_lop_hoc from dang_ky) loop
        merge into tong_hop_diem_lop t
        using (select r.ma_lop_hoc as cid, count(diem_tong_ket) as so_sv, round(avg(diem_tong_ket), 2) as diem_tb, max(diem_tong_ket) as max_d, min(diem_tong_ket) as min_d from dang_ky where ma_lop_hoc = r.ma_lop_hoc and diem_tong_ket is not null group by r.ma_lop_hoc) s
        on (t.ma_lop = s.cid)
        when matched then update set so_sv = s.so_sv, diem_tb = s.diem_tb, max_d = s.max_d, min_d = s.min_d, cap_nhat = sysdate
        when not matched then insert (ma_lop, so_sv, diem_tb, max_d, min_d, cap_nhat) values (s.cid, s.so_sv, s.diem_tb, s.max_d, s.min_d, sysdate);
    end loop;
    commit;
end;
/

-- 4. Test code

-- thu sqlplus
prompt --- test may cai view ---
select * from vw_course_summary;
select * from vw_student_status;
select * from vw_class_availability;
select * from vw_top_courses;
select * from vw_pending_enrollment;
select * from vw_instructor_workload;

prompt --- test procedure ---
begin
    enroll_student(101, 5);
    enroll_student(999, 5);
    enroll_student(102, 7);
end;
/

begin
    update_final_grade(103, 2, 95);
    update_final_grade(103, 2, 150);
end;
/

begin
    transfer_student(105, 3, 7);
    transfer_student(105, 3, 8);
end;
/

begin
    report_class_detail(1);
    sync_grade_from_enrollment;
end;
/

prompt --- test trigger xoa mon ---
begin
    delete from mon_hoc where ma_mon_hoc = 10;
exception when others then
    dbms_output.put_line('loi expected: ' || sqlerrm);
end;
/
begin
    insert into mon_hoc values (999, 'mon ao', 100, null, user, sysdate, user, sysdate);
    delete from mon_hoc where ma_mon_hoc = 999;
    dbms_output.put_line('xoa ok mon 999');
    commit;
end;
/

prompt --- kiem tra nhat ky va tong hop ---
select * from nhat_ky_sua_diem;
select * from tong_hop_diem_lop;

prompt --- kiem tra object loi ---
select object_name, object_type, status from user_objects where status = 'INVALID';

prompt --- in bao cao he thong ---
begin
    print_system_report;
end;
/