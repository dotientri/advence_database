SHOW USER;

CREATE TABLE s_region (
                          id NUMBER(7) CONSTRAINT s_region_id_pk PRIMARY KEY,
                          name VARCHAR2(50) NOT NULL
);

CREATE TABLE s_title (
                         title VARCHAR2(25) PRIMARY KEY
);

CREATE TABLE s_image (
                         id NUMBER(7) PRIMARY KEY,
                         format VARCHAR2(25),
                         use_filename VARCHAR2(1),
                         filename VARCHAR2(255),
                         image BLOB
);

CREATE TABLE s_longtext (
                            id NUMBER(7) PRIMARY KEY,
                            use_filename VARCHAR2(1),
                            filename VARCHAR2(255),
                            text CLOB
);

CREATE TABLE s_dept (
                        id NUMBER(7) CONSTRAINT s_dept_id_pk PRIMARY KEY,
                        name VARCHAR2(25) NOT NULL,
                        region_id NUMBER(7) CONSTRAINT s_dept_region_id_fk REFERENCES s_region(id)
);

CREATE TABLE s_emp (
                       id NUMBER(7) CONSTRAINT s_emp_id_pk PRIMARY KEY,
                       last_name VARCHAR2(25) NOT NULL,
                       first_name VARCHAR2(25),
                       userid VARCHAR2(8) UNIQUE,
                       start_date DATE,
                       comments VARCHAR2(255),
                       manager_id NUMBER(7),
                       title VARCHAR2(25),
                       dept_id NUMBER(7) REFERENCES s_dept(id),
                       salary NUMBER(11,2),
                       commission_pct NUMBER(4,2)
);

CREATE TABLE s_customer (
                            id NUMBER(7) PRIMARY KEY,
                            name VARCHAR2(50) NOT NULL,
                            phone VARCHAR2(25),
                            address VARCHAR2(100),
                            city VARCHAR2(30),
                            state VARCHAR2(20),
                            country VARCHAR2(30),
                            zip_code VARCHAR2(15),
                            credit_rating VARCHAR2(9),
                            sales_rep_id NUMBER(7) REFERENCES s_emp(id),
                            region_id NUMBER(7) REFERENCES s_region(id),
                            comments VARCHAR2(255)
);

CREATE TABLE s_warehouse (
                             id NUMBER(7) PRIMARY KEY,
                             region_id NUMBER(7) REFERENCES s_region(id),
                             address VARCHAR2(100),
                             city VARCHAR2(30),
                             state VARCHAR2(20),
                             country VARCHAR2(30),
                             zip_code VARCHAR2(15),
                             phone VARCHAR2(25),
                             manager_id NUMBER(7) REFERENCES s_emp(id)
);

CREATE TABLE s_product (
                           id NUMBER(7) PRIMARY KEY,
                           name VARCHAR2(50) NOT NULL,
                           short_desc VARCHAR2(255),
                           longtext_id NUMBER(7) REFERENCES s_longtext(id),
                           image_id NUMBER(7) REFERENCES s_image(id),
                           suggested_whlsl_price NUMBER(11,2),
                           whlsl_units VARCHAR2(25)
);

CREATE TABLE s_ord (
                       id NUMBER(7) PRIMARY KEY,
                       customer_id NUMBER(7) REFERENCES s_customer(id),
                       date_ordered DATE,
                       date_shipped DATE,
                       sales_rep_id NUMBER(7) REFERENCES s_emp(id),
                       total NUMBER(11,2),
                       payment_type VARCHAR2(15),
                       order_filled VARCHAR2(1)
);

CREATE TABLE s_item (
                        ord_id NUMBER(7) REFERENCES s_ord(id),
                        item_id NUMBER(7),
                        product_id NUMBER(7) REFERENCES s_product(id),
                        price NUMBER(11,2),
                        quantity NUMBER(7),
                        quantity_shipped NUMBER(7),
                        PRIMARY KEY (ord_id, item_id)
);

CREATE TABLE s_inventory (
                             product_id NUMBER(7) REFERENCES s_product(id),
                             warehouse_id NUMBER(7) REFERENCES s_warehouse(id),
                             amount_in_stock NUMBER(7),
                             reorder_point NUMBER(7),
                             max_in_stock NUMBER(7),
                             out_of_stock_explanation VARCHAR2(255),
                             restock_date DATE,
                             PRIMARY KEY (product_id, warehouse_id)
);

DESC s_region;
DESC s_title;
DESC s_image;
DESC s_longtext;
DESC s_dept;
DESC s_emp;
DESC s_customer;
DESC s_warehouse;
DESC s_product;
DESC s_ord;
DESC s_item;
DESC s_inventory;

SELECT table_name FROM user_tables ORDER BY table_name;

INSERT INTO s_region VALUES (1, 'North America');
INSERT INTO s_region VALUES (2, 'South America');
INSERT INTO s_region VALUES (3, 'Asia');
INSERT INTO s_region VALUES (4, 'Europe');
INSERT INTO s_region VALUES (5, 'Africa');
COMMIT;
SELECT * FROM s_region;

INSERT INTO s_title VALUES ('President');
INSERT INTO s_title VALUES ('VP Sales');
INSERT INTO s_title VALUES ('Manager');
INSERT INTO s_title VALUES ('Sales Rep');
INSERT INTO s_title VALUES ('Clerk');
COMMIT;
SELECT * FROM s_title;

INSERT INTO s_image VALUES (1, 'JPEG', 'Y', 'img1.jpg', EMPTY_BLOB());
INSERT INTO s_image VALUES (2, 'PNG', 'Y', 'img2.png', EMPTY_BLOB());
INSERT INTO s_image VALUES (3, 'JPEG', 'N', 'img3.jpg', EMPTY_BLOB());
INSERT INTO s_image VALUES (4, 'GIF', 'Y', 'img4.gif', EMPTY_BLOB());
INSERT INTO s_image VALUES (5, 'PNG', 'N', 'img5.png', EMPTY_BLOB());
COMMIT;
SELECT * FROM s_image;

INSERT INTO s_longtext VALUES (1, 'Y', 'desc1.txt', 'Description 1');
INSERT INTO s_longtext VALUES (2, 'N', 'desc2.txt', 'Description 2');
INSERT INTO s_longtext VALUES (3, 'Y', 'desc3.txt', 'Description 3');
INSERT INTO s_longtext VALUES (4, 'Y', 'desc4.txt', 'Description 4');
INSERT INTO s_longtext VALUES (5, 'N', 'desc5.txt', 'Description 5');
COMMIT;
SELECT * FROM s_longtext;

INSERT INTO s_dept VALUES (10, 'Finance', 1);
INSERT INTO s_dept VALUES (20, 'Sales', 2);
INSERT INTO s_dept VALUES (31, 'Marketing', 3);
INSERT INTO s_dept VALUES (42, 'IT', 4);
INSERT INTO s_dept VALUES (50, 'Administration', 5);
COMMIT;
SELECT * FROM s_dept;

INSERT INTO s_emp VALUES (1, 'Smith', 'John', 'jsmith', TO_DATE('14/05/1990', 'DD/MM/YYYY'), NULL, NULL, 'President', 50, 5000, NULL);
INSERT INTO s_emp VALUES (2, 'Doe', 'Jane', 'jdoe', TO_DATE('26/05/1991', 'DD/MM/YYYY'), NULL, 1, 'VP Sales', 20, 3500, 10);
INSERT INTO s_emp VALUES (3, 'Nga', 'Lan', 'nlan', TO_DATE('10/01/1991', 'DD/MM/YYYY'), NULL, 2, 'Sales Rep', 20, 1500, 15);
INSERT INTO s_emp VALUES (4, 'Nguyen', 'Nam', 'nnam', TO_DATE('15/06/1991', 'DD/MM/YYYY'), NULL, 1, 'Manager', 10, 2000, NULL);
INSERT INTO s_emp VALUES (5, 'Tran', 'Binh', 'tbinh', TO_DATE('05/04/1992', 'DD/MM/YYYY'), NULL, 4, 'Clerk', 31, 1400, NULL);
COMMIT;
SELECT * FROM s_emp;

INSERT INTO s_customer VALUES (101, 'Cust A', '111-222', '123 Main St', 'City A', 'State A', 'USA', '10001', 'EXCELLENT', 3, 1, 'Good');
INSERT INTO s_customer VALUES (102, 'Cust B', '333-444', '456 Oak St', 'City B', 'State B', 'USA', '20002', 'GOOD', 3, 2, NULL);
INSERT INTO s_customer VALUES (103, 'Cust C', '555-666', '789 Pine St', 'City C', 'State C', 'USA', '30003', 'POOR', 3, 1, 'Late');
INSERT INTO s_customer VALUES (104, 'Cust D', '777-888', '321 Elm St', 'City D', 'State D', 'USA', '40004', 'EXCELLENT', 3, 3, NULL);
INSERT INTO s_customer VALUES (105, 'Cust E', '999-000', '654 Maple St', 'City E', 'State E', 'USA', '50005', 'GOOD', 3, 4, 'Ok');
COMMIT;
SELECT * FROM s_customer;

INSERT INTO s_warehouse VALUES (1, 1, '100 Warehouse Rd', 'City A', 'State A', 'USA', '10001', '111-111', 4);
INSERT INTO s_warehouse VALUES (2, 2, '200 Warehouse Rd', 'City B', 'State B', 'USA', '20002', '222-222', 4);
INSERT INTO s_warehouse VALUES (3, 3, '300 Warehouse Rd', 'City C', 'State C', 'USA', '30003', '333-333', 4);
INSERT INTO s_warehouse VALUES (4, 4, '400 Warehouse Rd', 'City D', 'State D', 'USA', '40004', '444-444', 4);
INSERT INTO s_warehouse VALUES (5, 5, '500 Warehouse Rd', 'City E', 'State E', 'USA', '50005', '555-555', 4);
COMMIT;
SELECT * FROM s_warehouse;

INSERT INTO s_product VALUES (1, 'Pro Ski', 'bicycle and ski equipment', 1, 1, 150.00, 'Ea');
INSERT INTO s_product VALUES (2, 'Pro Bike', 'mountain bicycle', 2, 2, 500.00, 'Ea');
INSERT INTO s_product VALUES (3, 'Helmet', 'safety helmet', 3, 3, 45.00, 'Ea');
INSERT INTO s_product VALUES (4, 'Gloves', 'winter gloves', 4, 4, 25.00, 'Pr');
INSERT INTO s_product VALUES (5, 'Boots', 'hiking boots', 5, 5, 120.00, 'Pr');
COMMIT;
SELECT * FROM s_product;

INSERT INTO s_ord VALUES (101, 101, TO_DATE('01/01/2026', 'DD/MM/YYYY'), TO_DATE('05/01/2026', 'DD/MM/YYYY'), 3, 150000, 'CREDIT', 'Y');
INSERT INTO s_ord VALUES (102, 102, TO_DATE('10/01/2026', 'DD/MM/YYYY'), TO_DATE('15/01/2026', 'DD/MM/YYYY'), 3, 85000, 'CASH', 'Y');
INSERT INTO s_ord VALUES (103, 103, TO_DATE('20/01/2026', 'DD/MM/YYYY'), NULL, 3, 120000, 'CREDIT', 'N');
INSERT INTO s_ord VALUES (104, 104, TO_DATE('05/02/2026', 'DD/MM/YYYY'), TO_DATE('10/02/2026', 'DD/MM/YYYY'), 3, 200000, 'CREDIT', 'Y');
INSERT INTO s_ord VALUES (105, 105, TO_DATE('15/02/2026', 'DD/MM/YYYY'), NULL, 3, 50000, 'CASH', 'N');
COMMIT;
SELECT * FROM s_ord;

INSERT INTO s_item VALUES (101, 1, 1, 150.00, 10, 10);
INSERT INTO s_item VALUES (101, 2, 2, 500.00, 5, 5);
INSERT INTO s_item VALUES (102, 1, 3, 45.00, 20, 20);
INSERT INTO s_item VALUES (103, 1, 4, 25.00, 50, 0);
INSERT INTO s_item VALUES (104, 1, 5, 120.00, 15, 15);
COMMIT;
SELECT * FROM s_item;

INSERT INTO s_inventory VALUES (1, 1, 500, 50, 1000, NULL, TO_DATE('01/03/2026', 'DD/MM/YYYY'));
INSERT INTO s_inventory VALUES (2, 2, 300, 30, 800, NULL, TO_DATE('02/03/2026', 'DD/MM/YYYY'));
INSERT INTO s_inventory VALUES (3, 3, 150, 20, 500, 'Supplier delay', TO_DATE('05/03/2026', 'DD/MM/YYYY'));
INSERT INTO s_inventory VALUES (4, 4, 0, 100, 2000, 'Out of stock', NULL);
INSERT INTO s_inventory VALUES (5, 5, 800, 100, 1500, NULL, TO_DATE('10/03/2026', 'DD/MM/YYYY'));
COMMIT;
SELECT * FROM s_inventory;