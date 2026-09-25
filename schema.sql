-- ============================================================
--  schema.sql — ระบบร้านอาหาร (นิสิตออกแบบและเขียนเอง)
--  กติกา: 1 ออเดอร์มีหลายเมนู (M:N: order × menu_item ผ่าน order_item),
--         เมนูชุด combo = M:N (menu_item × menu_item)
--  ต้องมี: PK ทุกตาราง, FK ครบ, ชื่อตรงกับ db.py, sample data
-- ============================================================
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
    price			int					NOT NULL,
    is_available    varchar(100)		DEFAULT 'มีอยู๋',

CONSTRAINT itm_pk			PRIMARY KEY (item_id),
CONSTRAINT itm_chk_ava		CHECK		(is_available IN ('ขายปกติ', 'หมด', 'ยกเลิกข้อมูล'))
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
	qty				int					DEFAULT 1,
	note			varchar(255),
    -- TODO: order_id (FK), item_id (FK), qty, note ; PRIMARY KEY (order_id, item_id)
CONSTRAINT	ord_itm_pk		PRIMARY KEY (order_id, item_id),
CONSTRAINT	ord_fk_food		FOREIGN KEY (order_id)  REFERENCES food_order(order_id),
CONSTRAINT	ord_fk_menu		FOREIGN KEY (item_id)  REFERENCES menu_item(item_id),
CONSTRAINT ori_chk_qty      CHECK (qty > 0)
);

CREATE TABLE combo (              -- M:N: menu_item × menu_item
    combo_id		int					auto_increment,
    item_id			int					NOT NULL,
    sub_item_id		int					NOT NULL,
    amount			int					DEFAULT 1,
    
CONSTRAINT	cob_pk			PRIMARY KEY (combo_id),
CONSTRAINT	itm_fk_mnu		foreign KEY (item_id)	REFERENCES	menu_item(item_id),
CONSTRAINT	sitm_fk_mnu		FOREIGN KEY (sub_item_id)	REFERENCES menu_item(item_id),
CONSTRAINT cmb_uq_pair      UNIQUE (item_id, sub_item_id),
CONSTRAINT cmb_chk_amt      CHECK (amount > 0)
    -- TODO: item_id (FK -> menu_item), sub_item_id (FK -> menu_item), amount
);
-- TODO: INSERT ข้อมูลตัวอย่างทุกตาราง
-- เพิ่มข้อมูลลูกค้า
INSERT INTO customer (name, phone, member_tier) VALUES
('สมชาย ใจดี', '0812345678', 'gold'),
('สายสมร กาญจนา', '0898765432', 'normal'),
('กิตติศักดิ์ มีสุข', '0861112233', 'vip');

-- เพิ่มข้อมูลรายการอาหาร
INSERT INTO menu_item (name, category, price, is_available) VALUES
('ส้มตำไทย', 'ส้มตำ', 60, 'ขายปกติ'),
('ไก่ย่าง (ครึ่งตัว)', 'จานหลัก', 120, 'ขายปกติ'),
('ข้าวเหนียว', 'เครื่องเคียง', 15, 'ขายปกติ'),
('น้ำอัดลม', 'เครื่องดื่ม', 20, 'ขายปกติ'),
('ชุดสุดคุ้มอีสานแซ่บ (Combo)', 'ชุดโปรโมชั่น', 180, 'ขายปกติ'),
('เบียร์เย็น', 'เครื่องดื่ม', 90, 'หมด');

-- เพิ่มข้อมูลโต๊ะอาหาร
INSERT INTO dining_table (seats, zones) VALUES
(4, 'Indoor แอร์'),
(2, 'Indoor แอร์'),
(6, 'Outdoor สวน'),
(8, 'VIP Room');

-- เพิ่มข้อมูลออเดอร์
INSERT INTO food_order (cust_id, table_id, status) VALUES
(1, 1, 'paid'),
(2, 3, 'open');

-- เพิ่มรายการอาหารลงในออเดอร์ (order_item)
INSERT INTO order_item (order_id, item_id, qty, note) VALUES
(1, 1, 2, 'เผ็ดน้อย ไม่ใส่ปูดอง'),
(1, 2, 1, 'ขอหนังกรอบๆ'),
(1, 3, 3, NULL),
(2, 5, 1, 'ชุดคอมโบ'),
(2, 4, 2, 'ขอแก้วใส่น้ำแข็งด้วย');

-- เพิ่มโครงสร้างเมนูชุด Combo (combo)
-- เช่น ชุดสุดคุ้มอีสานแซ่บ (item_id: 5) ประกอบด้วย ส้มตำไทย (1), ไก่ย่าง (1), ข้าวเหนียว (2)
INSERT INTO combo (item_id, sub_item_id, amount) VALUES
(5, 1, 1), -- ส้มตำไทย 1 จาน
(5, 2, 1), -- ไก่ย่าง 1 จาน
(5, 3, 2); -- ข้าวเหนียว 2 ห่อ

-- select *
-- from 	customer
-- where   member_tier = 'vip'

