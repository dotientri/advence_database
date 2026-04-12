select last_name, salary
from employees
where salary > 12000;

select last_name, salary
from employees
where salary not between 5000 and 12000;

select last_name, job_id, hire_date
from employees
where hire_date between to_date('20/02/1998','dd/mm/yyyy') and to_date('01/05/1998','dd/mm/yyyy')
order by hire_date asc;

select last_name, department_id
from employees
where department_id in (20, 50)
order by last_name asc;

select last_name, hire_date
from employees
where to_char(hire_date, 'yyyy') = '1994';

select last_name, job_id
from employees
where manager_id is null;

select last_name, salary, commission_pct
from employees
where commission_pct is not null
order by salary desc, commission_pct desc;

select last_name
from employees
where last_name like '__a%';

select last_name
from employees
where last_name like '%a%' and last_name like '%e%';

select last_name, job_id, salary
from employees
where job_id in ('SA_REP', 'ST_CLERK') and salary not in (2500, 3500, 7000);

select employee_id, last_name, round(salary * 1.15, 0) as "new salary"
from employees;

select initcap(last_name) as "ten nhan vien", length(last_name) as "chieu dai"
from employees
where substr(last_name, 1, 1) in ('J','A','L','M')
order by last_name asc;

select last_name, trunc(months_between(sysdate, hire_date)) as "so thang lam viec"
from employees
order by months_between(sysdate, hire_date) asc;

select last_name || ' earns ' || to_char(salary, '$99,999') || ' monthly but wants ' || to_char(salary*3, '$99,999') as "dream salaries"
from employees;

select last_name, case when commission_pct is null then 'no commission' else to_char(commission_pct) end as "commission"
from employees;

select job_id, decode(job_id, 'AD_PRES', 'A', 'ST_MAN', 'B', 'IT_PROG', 'C', 'SA_REP', 'D', 'ST_CLERK', 'E', '0') as "grade"
from employees;

select e.last_name, e.department_id, d.department_name
from employees e, departments d, locations l
where e.department_id = d.department_id and d.location_id = l.location_id and upper(l.city) = 'TORONTO';

select e.employee_id as "ma nv", e.last_name as "ten nv", m.employee_id as "ma quan ly", m.last_name as "ten quan ly"
from employees e, employees m
where e.manager_id = m.employee_id;

select e1.last_name as "nhan vien 1", e2.last_name as "nhan vien 2", e1.department_id as "phong ban"
from employees e1, employees e2
where e1.department_id = e2.department_id and e1.employee_id < e2.employee_id
order by e1.department_id, e1.last_name;

select last_name, hire_date
from employees
where hire_date > (select hire_date
from employees
where last_name = 'Davies');

select e.last_name as "nhan vien", e.hire_date as "ngay vao", m.last_name as "quan ly", m.hire_date as "quan ly vao"
from employees e, employees m
where e.manager_id = m.employee_id and e.hire_date < m.hire_date;

select job_id, min(salary) as "luong thap nhat", max(salary) as "luong cao nhat", round(avg(salary),2) as "luong trung binh", sum(salary) as "tong luong"
from employees
group by job_id
order by job_id;

select d.department_id, d.department_name, count(e.employee_id) as "so nhan vien"
from departments d left join employees e on d.department_id = e.department_id
group by d.department_id, d.department_name
order by d.department_id;

select count(*) as "tong nv", sum(case when to_char(hire_date,'yyyy')='1995' then 1 else 0 end) as "nam 1995", sum(case when to_char(hire_date,'yyyy')='1996' then 1 else 0 end) as "nam 1996", sum(case when to_char(hire_date,'yyyy')='1997' then 1 else 0 end) as "nam 1997", sum(case when to_char(hire_date,'yyyy')='1998' then 1 else 0 end) as "nam 1998"
from employees;

select last_name, hire_date
from employees
where department_id = (select department_id
    from employees
    where last_name = 'Zlotkey') and last_name <> 'Zlotkey';

select last_name, department_id, job_id
from employees
where department_id in (select department_id
from departments
where location_id = 1700);

select last_name, manager_id
from employees
where manager_id in (select employee_id
from employees
where last_name = 'King');

select last_name, salary, department_id
from employees
where salary > (select avg(salary)
    from employees) and department_id in (select department_id
    from employees
    where last_name like '%n');

select d.department_id, d.department_name, count(e.employee_id) as "so nv"
from departments d left join employees e on d.department_id = e.department_id
group by d.department_id, d.department_name
having count(e.employee_id) < 3
order by d.department_id;

    select department_id, count(*) as "so nhan vien", 'dong nhat' as "loai"
    from employees
    group by department_id
    having count(*) = (select max(count(*))
    from employees
    group by department_id)
union all
    select department_id, count(*), 'it nhat'
    from employees
    group by department_id
    having count(*) = (select min(count(*))
    from employees
    group by department_id);

select last_name, hire_date, to_char(hire_date,'day') as "thu trong tuan"
from employees
where to_char(hire_date,'day') = (select to_char(hire_date,'day')
from employees
group by to_char(hire_date,'day')
having count(*) = (select max(count(*))
from employees
group by to_char(hire_date,'day')));

select last_name, salary
from (select last_name, salary
    from employees
    order by salary desc)
where rownum <= 3;

select e.last_name, e.department_id
from employees e, departments d, locations l
where e.department_id = d.department_id and d.location_id = l.location_id and upper(l.state_province) = 'CALIFORNIA';

update employees set last_name = 'Drexler' where employee_id = 3;

commit;

select e1.last_name, e1.salary, e1.department_id
from employees e1
where e1.salary < (select avg(e2.salary)
from employees e2
where e2.department_id = e1.department_id)
order by e1.department_id;

update employees set salary = salary + 100 where salary < 900;

commit;

update employees set department_id = null where department_id = 500;

delete from departments where department_id = 500;

commit;

delete from departments where department_id not in (select distinct department_id
from employees
where department_id is not null);

commit;

create table dmkhoa
(
    makhoa char(2) primary key,
    tenkhoa nvarchar2(30)
);

create table dmmh
(
    mamh char(2) primary key,
    tenmh nvarchar2(35),
    sotiet number(3)
);

create table dmsv
(
    masv char(3) primary key,
    hosv nvarchar2(30),
    tensv nvarchar2(10),
    phai nvarchar2(3),
    ngaysinh date,
    noisinh nvarchar2(25),
    makh char(2) references dmkhoa(makhoa),
    hocbong number(10,0)
);

create table ketqua
(
    masv char(3) references dmsv(masv),
    mamh char(2) references dmmh(mamh),
    primary key (masv, mamh)
);

create table phongban
(
    maphg number(2) primary key,
    tenphg nvarchar2(30),
    trphg number(5),
    ng_nhanchuc date
);

create table nhanvien
(
    manv number(5) primary key,
    honv nvarchar2(15),
    tenlot nvarchar2(15),
    tennv nvarchar2(15),
    ngaysinh date,
    dchi nvarchar2(50),
    phai nvarchar2(3),
    luong number(10,2),
    ma_nql number(5) references nhanvien(manv),
    phg number(2) references phongban(maphg)
);

alter table phongban add constraint fk_phongban_nhanvien foreign key (trphg) references nhanvien(manv);

create table diadiem_phg
(
    maphg number(2) references phongban(maphg),
    diadiem nvarchar2(20),
    primary key (maphg, diadiem)
);

create table dean
(
    mada number(3) primary key,
    tenda nvarchar2(30),
    ddiem_da nvarchar2(20),
    phong number(2) references phongban(maphg)
);

create table phancong
(
    ma_nvien number(5) references nhanvien(manv),
    mada number(3) references dean(mada),
    thoigian number(5,1),
    primary key (ma_nvien, mada)
);

create table thannhan
(
    ma_nvien number(5) references nhanvien(manv),
    tentn nvarchar2(15),
    phai nvarchar2(3),
    ngaysinh date,
    quanhe nvarchar2(15),
    primary key (ma_nvien, tentn)
);

show user;

spool tuan2_mssv.sql;

desc employees;

desc departments;

desc locations;

select distinct job_id, job_title
from jobs
order by job_id;

select count(*)
from employees;

spool off;