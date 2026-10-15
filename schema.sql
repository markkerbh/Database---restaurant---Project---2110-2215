-- ============================================================
--  schema.sql — ระบบร้านอาหาร (นิสิตออกแบบและเขียนเอง)
--  กติกา: 1 ออเดอร์มีหลายเมนู (M:N: order × menu_item ผ่าน order_item),
--         เมนูชุด combo = M:N (menu_item × menu_item)
--  ต้องมี: PK ทุกตาราง, FK ครบ, ชื่อตรงกับ db.py, sample data
-- ============================================================

-- DROP TABLE IF EXISTS combo;
-- DROP TABLE IF EXISTS order_item;
-- DROP TABLE IF EXISTS food_order;
-- DROP TABLE IF EXISTS dining_table;
-- DROP TABLE IF EXISTS menu_item;
-- DROP TABLE IF EXISTS customer;
-- 
-- DELETE FROM combo;
-- DELETE FROM order_item;
-- DELETE FROM food_order;
-- DELETE FROM dining_table;
-- DELETE FROM menu_item;
-- DELETE FROM customer;
-- 
-- ALTER TABLE combo AUTO_INCREMENT = 1;
-- ALTER TABLE food_order AUTO_INCREMENT = 1;
-- ALTER TABLE dining_table AUTO_INCREMENT = 1;
-- ALTER TABLE menu_item AUTO_INCREMENT = 1;
-- ALTER TABLE customer AUTO_INCREMENT = 1;

CREATE TABLE customer (
	cust_id			int 				auto_increment,
    name			varchar(100)       	NOT NULL,
    phone			varchar(10),
    member_tier		varchar(10)			DEFAULT 'normal',
  
constraint cus_pk			PRIMARY KEY (cust_id),
CONSTRAINT cus_chk_member	check		(member_tier in ('normal', 'silver', 'gold' , 'vip'))    
);

CREATE TABLE menu_item (
    item_id			int 				auto_increment,
    name			varchar(100)		NOT NULL,
    category		varchar(100),
    price 			DECIMAL(10,2) 		NOT NULL,
    is_available    varchar(100)		DEFAULT 'ขายปกติ',

CONSTRAINT itm_pk			PRIMARY KEY (item_id),
CONSTRAINT itm_chk_ava		CHECK		(is_available IN ('ขายปกติ', 'หมด', 'ยกเลิกถาวร'))
);

CREATE TABLE dining_table (
    table_id		int					auto_increment,
    seats 			int,
    zones			varchar(100),
    
CONSTRAINT tab_pk			PRIMARY KEY (table_id)
);

CREATE TABLE food_order (
    order_id		int					auto_increment,
    cust_id			int,
    table_id		int,
    order_time		datetime 			DEFAULT CURRENT_TIMESTAMP,
    status			varchar(100)		DEFAULT	'open',
    
CONSTRAINT	ord_pk			PRIMARY KEY (order_id),
CONSTRAINT	ord_fk_cus		FOREIGN KEY (cust_id)  REFERENCES customer(cust_id),
CONSTRAINT	ord_fk_tab		FOREIGN KEY (table_id) REFERENCES dining_table(table_id),
CONSTRAINT	ord_chk_status	CHECK		(status IN ('open', 'paid'))
);

CREATE TABLE order_item (         -- M:N: food_order × menu_item
	order_id		int					NOT NULL,
	item_id			int					NOT NULL,
	unit_price 		decimal(10,2) 		NOT NULL,
	qty				int					DEFAULT 1,
	note			varchar(255),
-- TODO: order_id (FK), item_id (FK), qty, note ; PRIMARY KEY (order_id, item_id)
CONSTRAINT	ord_itm_pk		PRIMARY KEY (order_id, item_id),
CONSTRAINT	ord_fk_food		FOREIGN KEY (order_id)  REFERENCES food_order(order_id),
constraint	ord_fk_menu		FOREIGN KEY (item_id)  REFERENCES menu_item(item_id),
constraint	ori_chk_qty		CHECK 		(qty > 0),
CONSTRAINT 	ori_chk_price 	CHECK 		(unit_price >= 0)
);

CREATE TABLE combo (              -- M:N: menu_item × menu_item
    combo_id		int					auto_increment,
    item_id			int					NOT NULL,
    sub_item_id		int					NOT NULL,
    amount			int					DEFAULT 1,
    
CONSTRAINT	cob_pk				PRIMARY KEY (combo_id),
CONSTRAINT	itm_fk_mnu			foreign KEY (item_id)				REFERENCES	menu_item(item_id),
constraint	sitm_fk_mnu			FOREIGN KEY (sub_item_id)			REFERENCES 	menu_item(item_id),
CONSTRAINT 	cmb_uq_pair      	UNIQUE 		(item_id, sub_item_id),
CONSTRAINT 	cmb_chk_amt      	CHECK 		(amount > 0)
-- TODO: item_id (FK -> menu_item), sub_item_id (FK -> menu_item), amount
);
-- TODO: INSERT ข้อมูลตัวอย่างทุกตาราง
-- เพิ่มข้อมูลลูกค้า
-- 1. เพิ่มข้อมูลตาราง customer (ลูกค้า)
INSERT INTO customer (name, phone, member_tier) VALUES
('สมชาย ใจดี', '0812345678', 'normal'),
('วิภาดา มีสุข', '0898765432', 'silver'),
('กิตติพงษ์ ยอดเยี่ยม', '0821112223', 'gold'),
('นภา สว่างไสว', '0863334445', 'vip'),
('ชาญชัย เกรียงไกร', '0855556667', 'normal'),
('อนันต์ มั่งมี', '0847778889', 'silver');

-- 2. เพิ่มข้อมูลตาราง menu_item (เมนูอาหาร)
-- หมายเหตุ: กำหนดค่า is_available ให้ตรงตาม CHECK Constraint ('ขายปกติ', 'หมด', 'ยกเลิกถาวร')
INSERT INTO menu_item (name, category, price, is_available) VALUES
('ข้าวผัดกุ้ง', 'อาหารจานเดียว', 80, 'ขายปกติ'),
('ผัดไทยกุ้งสด', 'อาหารจานเดียว', 90, 'ขายปกติ'),
('ต้มยำกุ้ง', 'ต้ม/แกง', 150, 'ขายปกติ'),
('ส้มตำไทย', 'ส้มตำ/ยำ', 60, 'ขายปกติ'),
('ไก่ย่าง (ครึ่งตัว)', 'ทานเล่น', 120, 'ขายปกติ'),
('น้ำโค้ก (กระป๋อง)', 'เครื่องดื่ม', 25, 'ขายปกติ'),
('น้ำเปล่า', 'เครื่องดื่ม', 15, 'ขายปกติ'),
('ชุดเซตสุดคุ้ม A', 'ชุดเซต/คอมโบ', 220, 'ขายปกติ'),
('ปูผัดผงกะหรี่', 'กับข้าว', 350, 'หมด'),
('เฉาก๊วยชากังราว', 'ของหวาน', 35, 'ขายปกติ');

-- 3. เพิ่มข้อมูลตาราง dining_table (โต๊ะอาหาร)
INSERT INTO dining_table (seats, zones) VALUES
(2, 'Indoor'),
(2, 'Indoor'),
(4, 'Indoor'),
(4, 'Outdoor'),
(6, 'VIP Room'),
(8, 'VIP Room'),
(4, 'Terrace');

-- 4. เพิ่มข้อมูลตาราง food_order (ออเดอร์)
-- หมายเหตุ: status ต้องตรงตาม CHECK Constraint ('open', 'paid')
INSERT INTO food_order (cust_id, table_id, status) VALUES
(1, 1, 'paid'),
(2, 3, 'paid'),
(3, 5, 'open'),
(NULL, 2, 'paid'), -- ลูกค้า walk-in ไม่ได้เป็นสมาชิก
(4, 6, 'open'),
(5, 4, 'paid');

-- 5. เพิ่มข้อมูลตาราง order_item (รายการอาหารในแต่ละออเดอร์)
INSERT INTO order_item (order_id, item_id, qty, unit_price, note)
VALUES
(1, 1, 2, 80.00, 'ไม่ใส่ผักชี'),
(1, 6, 2, 25.00, 'ขอน้ำแข็ง 2 แก้ว'),
(2, 3, 1, 150.00, 'เผ็ดน้อย'),
(2, 4, 1, 60.00, 'ไม่ใส่ปู'),
(2, 7, 2, 15.00, NULL);

-- 6. เพิ่มข้อมูลตาราง combo (ชุดจับคู่/คอมโบ)
-- หมายเหตุ: item_id คือเมนูเซตหลัก และ sub_item_id คือเมนูย่อยที่รวมอยู่ในเซต
INSERT INTO combo (item_id, sub_item_id, amount) VALUES
(8, 4, 1), -- ชุดเซตสุดคุ้ม A (item_id 8) ประกอบด้วย ส้มตำไทย 1 จาน
(8, 5, 1), -- + ไก่ย่าง 1 จาน
(8, 6, 2), -- + น้ำโค้ก 2 กระป๋อง
(8, 7, 2),
(8, 10, 1);



