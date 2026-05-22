CREATE DATABASE warehouse_management;
USE warehouse_management;

-- BẢNG PRODUCTS
CREATE TABLE products (
	product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    sku_code VARCHAR(20) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    manufacture_date date check (manufacture_date < '2026-05-22')
);

CREATE TABLE employees (
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    ro_le varchar(50) NOT NULL,
    phone_number VARCHAR(12) NOT NULL UNIQUE,
    performance_score DECIMAL(2, 1) default 5.0 check (performance_score between 0.0 AND 5.0)
);

-- BANG STOCK_ORDERS
CREATE TABLE stock_orders (
	order_id INT PRIMARY KEY auto_increment,
    product_id int,
    employee_id INT,
    order_time DATETIME NOT NULL,
    quantity INT CHECK (quantity > 0),
    sta_tus ENUM ('Pending', 'Completed', 'Cancelled'),
    constraint foreign key (product_id) references products(product_id),
    constraint foreign key (employee_id)  references employees(employee_id)
);

-- bang order_details
CREATE TABLE order_details (
	detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    storage_zone VARCHAR(20) NOT NULL,
    condition_check VARCHAR(50) NOT NULL,
    handling_method TEXT,
    detail_date DATETIME DEFAULT current_timestamp,
    constraint foreign key (order_id) references stock_orders(order_id)
); 

-- BANG TRANSACTION_LOGS
CREATE TABLE transaction_logs (
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    detail_id INT, 
    employee_id INT,
    log_time DATETIME NOT NULL,
    note TEXT,
    constraint foreign key (detail_id) references order_details(detail_id),
    constraint foreign key ( employee_id)  references employees( employee_id)
);

insert into products
values 
(1, 'Laptop Dell XPX', 'DELL01', 'Điện tử', '2023-12-03'),
(2, 'Bàn phím cơ', 'KEY02', 'Phụ kiện', '1996-11-25'),
(3, 'Chuột Logitech', 'LOG03', 'Phụ kiện', '2001-07-08'),
(4, 'Màn hình LG 27 inch', 'LG04', 'Điện tử', '1998-01-19'),
(5, 'Tai nghe Sony', 'SONY05', 'Âm thanh', '2000-09-30');

insert into employees
values
(1, 'Nguyễn Văn Hải', 'Chủ kho', '0931112223', 4.8),
(2, 'Trần Thu Hà', 'Thủ kho', '0932223334', 5.0),
(3, 'Lê Quốc Tuấn', 'Tài xế', '0933334445', 4.6),
(4, 'Phạm Minh Châu', 'Kiểm kê', '0934445556', 4.9),
(5, 'Hoàng Gia Bảo', 'Thủ kho', '0935556667', 4.7);

insert into stock_orders
values 
(7001, 1, 1, '2024-05-20 08:00', 200, 'Pending'),
(7002, 2, 2, '2024-05-20 09:30', 250, 'Completed'),
(7003, 3, 3, '2024-05-20 10:15', 300, 'Pending'),
(7004, 4, 5, '2024-05-21 07:00', 350, 'Completed'),
(7005, 5, 4, '2024-05-21 08:45', 220, 'Cancelled');

insert into order_details
values
(8001, 7002, 'Khu A1', 'Bao bì nguyên vẹn', 'Nhập kho', '2024-05-20 10:00'),
(8002, 7004, 'Khu B2', 'Thùng móp nhẹ', 'Kiểm tra kỹ + Nhập', '2024-05-21 08:00'),
(8003, 7001, 'Khu C1', 'Đang tháo dỡ', 'Phân loại', '2024-05-20 9:00'),
(8004, 7003, 'Khu A2', 'Chơ xe nâng', 'Sắp xếp pallet', '2024-05-20 11:00'),
(8005, 7005, 'Khu D1', 'Sai mã hàng', 'Trả về NCC', '2024-05-1 9:00');

insert into transaction_logs
values
(1, 8003, 1, '2024-05-20 09:05', 'Bắt đầu dỡ hàng'),
(2, 8001, 2, '2024-05-20 10:05', 'Hoàn tất nhập kho'),
(3, 8004, 3, '2024-05-20 11:10', 'Đang vận chuyển nội bộ'),
(4, 8002, 5, '2024-05-21 08:10', 'Chờ phê duyệt ngoại lệ'),
(5, 8005, 4, '2024-05-21 09:05', 'Hủy do sai mã');
set sql_safe_updates = 0;

-- CAU 2
-- update
UPDATE stock_orders as so
inner join products as p on so.product_id = p.product_id
SET so.quantity = so.quantity * 1.1
where sta_tus = 'Completed' 
	and p.manufacture_date < '2000-01-01';
    
-- xóa
delete from transaction_logs
where log_time < '2024-05-20';

-- truy vấn cơ bản
-- câu 1:
select full_name, ro_le, performance_score
from employees 
where performance_score > 4.7
OR ro_le = 'Thủ kho';

-- câu 2
select product_name,sku_code
from products
where (manufacture_date >= '1998-01-01' and manufacture_date <= '2001-12-31')
	and sku_code like 'L%';

-- câu 3:
select order_id,order_time,quantity
from stock_orders 
order by quantity desc
limit 2 offset 2;

-- truy vấn nâng cao
-- câu 1:tên sản phầm, họ tên nhân viên, chức vụ, số lượng, thời gian tạo phiếu
select p.product_name, e.full_name, e.ro_le, so.quantity, so.order_time
from stock_orders as so
inner join employees as e on so.employee_id = e.employee_id
inner join products as p on so.product_id = p.product_id;

-- câu 2: họ tên nhân viên, tổng số lượng hàng hóa
select full_name, sum(so.quantity) as 'Tổng số lượng hàng hóa'
from stock_orders as so
inner join employees as e on so.employee_id = e.employee_id
where so.sta_tus = 'Completed'
group by e.employee_id, e.full_name
having sum(so.quantity) > 500;

select employee_id, full_name, performance_score
from employees 
where performance_score = (
	select max(performance_score)
    from employees
);
-- index & view
-- câu 1:
create index idx_stock 
on stock_orders (sta_tus,quantity);

-- câu 2: họ tên nhân viên employ, tổng số phiếu kho stock, tổng số lượng hàng hóa stock
create or replace view v_stock_employ as
select e.full_name, count(so.order_id),sum(so.quantity)
from stock_orders as so
inner join employees as e on so.employee_id = e.employee_id
where so.sta_tus != 'Cancelled';

-- TRIGGER
-- CAU 1
-- DELIMITER //
-- create trigger trg_after_stock
-- from stock_orders
-- for each row
-- begin
-- 	if new.sta_tus = 'Completed' then
--     
--     
--     end ;
-- DELIMITER ;	