 create table waiter(
 waiter_id integer primary key, 
 waiter_fname varchar(50) not null, 
  waiter_lname varchar(50)
  );

  create table customer(
  cust_id integer primary key, 
  cust_fname varchar(50) not null,
  cust_lname varchar(50), 
  contact_no integer
  );

  create table tips( 
     waiter_id integer references waiter(waiter_id), 
     cust_id integer references customer(cust_id), 
     tips integer
  );

  create table ord(
  ord_no integer primary key, 
  rd_date date not null,
  cust_id integer references customer(cust_id), 
  waiter_id integer references waiter(waiter_id)
  );

  create table chef(
  chef_id integer primary key, 
  chef_fname varchar(50) not null, 
  chef_lname varchar(50), 
  chef_type varchar(50) not null
  );

  create table food(
  item_no integer primary key, 
  item_name varchar(50) not null, 
  item_type varchar(50) not null, 
  item_price integer not null, 
  item_stock integer
  );

  create table contains(
  ord_no integer references ord(ord_no), 
  item_no integer references food(item_no)
  );


  create table prepares(
  item_type varchar(50) primary key, 
  chef_id integer references chef(chef_id)
  );

  create table bill(
  bill_no integer primary key, 
  tot_price integer not null, 
  tax float default 5, 
  discount integer default 0, 
  net_payable float as
  (tot_price+(tot_price*tax/100)-(tot_price*discount/100)), 
  ord_no integer references ord(ord_no)
  );

CREATE TABLE inventory (
  ingredient_id INTEGER PRIMARY KEY,
  ingredient_name VARCHAR(50) NOT NULL,
  unit_price INTEGER NOT NULL,
  stock INTEGER NOT NULL
);



CREATE TABLE payment (
  bill_no INTEGER REFERENCES bill(bill_no),
  payment_type VARCHAR(50) NOT NULL,
  amount_paid INTEGER NOT NULL,
  CONSTRAINT pk_payment PRIMARY KEY (bill_no)
);


  insert into waiter values(1,'John','Doe');
  insert into waiter values(2,'Jane','Smith');
  insert into waiter values(3,'Bob','Johnson');
  select * from waiter;

  insert into customer values(1,'Alice','Brown',900000001);
  insert into customer values(2,'Bob','Green',900000002);
  insert into customer values(3,'Charlie','Blue',900000003);
  select * from customer;

  insert into ord values(1,'15-APR-2023',1,1);
  insert into ord values(2,'16-APR-2023',2,2);
  insert into ord values(3,'17-APR-2023',3,1);
  select * from ord ;

  insert into chef values(1,'John','Wick','Head_Chef');
  insert into chef values(2,'Sarah','Curry','Sous_Chef');
  insert into chef values(3,'Robert','Gun','Sous_Chef');
  select * from chef ;

  insert into prepares values('Main_course',1);
  insert into prepares values('Appetizer',2);
  insert into prepares values('Dessert',3);
  select * from prepares ;

  insert into food values(1,'Cheeseburger','Main Course',100,50);
  insert into food values(2,'French_Fries','Appetizer',50,100);
  insert into food values(3,'Chocolate_cake','Dessert',80,30);
  select * from food ;

  insert into contains values(1,1);
  insert into contains values(1,2);
  insert into contains values(2,2);
  insert into contains values(2,3);
  insert into contains values(3,1);
  insert into contains values(3,3);
  select * from contains ;

  insert into tips values(1,1,10);
  insert into tips values(1,3,20);
  select * from tips ;

INSERT INTO inventory (ingredient_id, ingredient_name, unit_price, stock)
VALUES (1, 'Beef Patty', 50, 20);
INSERT INTO inventory (ingredient_id, ingredient_name, unit_price, stock)
VALUES (2, 'Bun', 10, 30);
INSERT INTO inventory (ingredient_id, ingredient_name, unit_price, stock)
VALUES (3, 'French Fries (Frozen)', 20, 50);
INSERT INTO inventory (ingredient_id, ingredient_name, unit_price, stock)
VALUES (4, 'Chocolate', 30, 15);
INSERT INTO inventory (ingredient_id, ingredient_name, unit_price, stock)
VALUES (5, 'Flour', 15, 40);
select * from inventory;

INSERT INTO bill (bill_no,tax, tot_price, discount, ord_no)
VALUES ((SELECT COUNT(*) + 1 FROM bill),12, 230, 6, 4);
INSERT INTO bill (bill_no,tax, tot_price, discount, ord_no)
VALUES ((SELECT COUNT(*) + 1 FROM bill),12, 180, 8, 3);
INSERT INTO bill (bill_no,tax, tot_price, discount, ord_no)
VALUES ((SELECT COUNT(*) + 1 FROM bill),10, 150, 5, 2);
INSERT INTO bill (bill_no,tax, tot_price, discount, ord_no)
VALUES ((SELECT COUNT(*) + 1 FROM bill),10, 150, 5, 1);

select * from bill;


INSERT INTO payment (bill_no, payment_type, amount_paid)
VALUES ( (SELECT bill_no FROM bill WHERE ord_no = 1), 'Cash', 230);
INSERT INTO payment (bill_no, payment_type, amount_paid)
VALUES ( (SELECT bill_no FROM bill WHERE ord_no = 3), 'Credit Card', 180);
INSERT INTO payment (bill_no, payment_type, amount_paid)
VALUES ( (SELECT bill_no FROM bill WHERE ord_no = 2), 'UPI wallet',150 );
select * from payment;


set serveroutput on;
  declare
  cursor c1 is select item_name,item_price from food;
  rec1 c1%rowtype;
  procedure show_menu is
  	begin
  	open c1;
  	loop
      	fetch c1 into rec1;
  		exit when c1%notfound;
  		dbms_output.Put_line('Item :'||rec1.item_name||'  Price : '||rec1.item_price);
  	end loop;
  	close c1;
  end;
  begin
  show_menu;
  end;
/

  declare
  id integer;
  if_exists integer:=0;
  function get_cust_id(fname in varchar,lname in varchar,contact in integer,wait_id in integer) return number is
  	begin 
      	select count(*) into if_exists from customer where cust_fname=fname and cust_lname=lname and contact_no=contact;
  		if if_exists>0 then 
              select cust_id into id from customer where cust_fname=fname and cust_lname=lname and contact_no=contact;
  			return(id);
  		else
              select count(*)+1 into id from customer;
  			insert into customer values(id,fname,lname,contact);
  			insert into tips(waiter_id,cust_id) values(wait_id,id);
  			return(id);
  		end if;
  	end;

  begin
  id:=get_cust_id('Blake','Ryan',9891008912,2);
  dbms_output.Put_line('Customer Id is ' || id);
  end;
/

  create or replace trigger in_stock
  before insert on contains for each row
  declare
      stock integer;
  begin
      select item_stock into stock from food where food.item_no=:new.item_no;
      if stock=0 then raise_application_error(-20000,'Out Of Stock');
  	else dbms_output.Put_line('In stock');
  	end if;
  end;
/
  create or replace trigger after_order
  after insert on contains for each row
  begin
      update food set item_stock=item_stock-1 where item_no=:new.item_no;
  end;
/

  declare
  type num_array is varray(50) of integer;
  items num_array;
  order_no integer;

  function place_order(id in integer,items in num_array,wait_id in number) return integer is
  begin
        select count(*)+1 into order_no from ord; 
  	insert into ord values(order_no,sysdate,id,wait_id);
  	for i in 1..items.count loop
  		insert into contains values(order_no,items(i));
  	end loop;
  	return (order_no);
  end;

  begin
  items:=num_array(1,2);
  order_no:=place_order(4,items,3);
  dbms_output.put_line('Order No: ' || order_no);
  end;
/
  declare
  type num_array is varray(50) of integer;
  items num_array;
  order_no integer;

  procedure add_order(order_no in integer,items in num_array) is
  begin
  	for i in 1..items.count loop
  		insert into contains values(order_no,items(i));
  	end loop;
  end;

  begin
  items:=num_array(3);
  add_order(4,items);
  end;
/
  create or replace trigger display_bill
  after insert on bill for each row
  begin
      dbms_output.Put_line('Total Price: '||:new.tot_price);
  	dbms_output.Put_line('Tax: '||:new.tax);
  	dbms_output.Put_line('Discount: '||:new.discount);
  	dbms_output.Put_line('Net Payable Amount '||:new.net_payable);
  end;
/
  declare 
  cursor c2 (n integer) is select f.item_no,f.item_name,f.item_price,c.ord_no from food f,contains c where f.item_no=c.item_no and c.ord_no=n; 
  rec2 c2%rowtype; 
  total integer:=0; 
  b_no integer; 
 
  procedure generate_bill(order_no in integer, disc in float) is 
  begin 
  	open c2(order_no); 
  	select count(*)+1 into b_no from bill; 
  	dbms_output.Put_line('Bill No: '||b_no||' Order_no: '||order_no); 
  	loop 
          fetch c2 into rec2; 
  		exit when c2%notfound; 
  		dbms_output.Put_line('Item: '||rec2.item_name||'  Price: ₹'|| rec2.item_price); 
  		total:=total+rec2.item_price; 
      end loop; 
  	insert into bill(bill_no,tot_price,discount,ord_no) values(b_no,total,disc,order_no); 
  end; 
 
  begin 
  generate_bill(4,0); 
  end;
/
  declare 
  procedure give_tip(id in integer, wait_id in integer , t in integer) is
  begin 
  insert into tips values(wait_id , id , t);
  dbms_output.Put_line('Waiter 3 Received ₹' || t || 'tip');
  end;

  begin
  give_tip(4,3,10);
  end;
/
  declare 
  tot integer; 
  procedure display_waiter_tip(wait_id in integer) is 
  begin  
  	select sum(tips) into tot from tips where waiter_id=wait_id; 
  	dbms_output.put_line('Total tip for waiter id '||wait_id||' is ₹'||tot); 
  end; 
 
  begin 
  display_waiter_tip(3); 
  end;
/

CREATE OR REPLACE FUNCTION calculate_bill(p_bill_no INT) RETURN INT AS
  v_total_price INT;
  v_tax INT;
  v_discount INT;
BEGIN
  -- Retrieve the total price, tax, and discount for the given bill number
  SELECT tot_price, tax, discount INTO v_total_price, v_tax, v_discount
  FROM bill
  WHERE bill_no = p_bill_no;
  
  -- Calculate the final amount including tax and discount
  RETURN (v_total_price + v_tax - v_discount);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END calculate_bill;
/

CREATE OR REPLACE PROCEDURE check_ingredient_availability(p_ingredient_id INT, p_quantity INT) AS
  v_stock INT;
BEGIN
  -- Retrieve the stock for the given ingredient id
  SELECT stock INTO v_stock
  FROM inventory
  WHERE ingredient_id = p_ingredient_id;
  
  -- Check if the required quantity is available
  IF v_stock >= p_quantity THEN
    DBMS_OUTPUT.PUT_LINE('Ingredient is available in sufficient quantity.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Insufficient quantity of ingredient.');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Ingredient not found.');
END check_ingredient_availability;
/

DECLARE
  v_bill_no INT := 1; -- Provide the bill number for which you want to calculate the bill
  v_final_amount INT;
BEGIN
  v_final_amount := calculate_bill(v_bill_no);
  IF v_final_amount IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Final Amount for Bill ' || v_bill_no || ': ' || v_final_amount);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Invalid Bill Number.');
  END IF;
END;
/

-- Calling the check_ingredient_availability procedure
DECLARE
  v_ingredient_id INT := 1; -- Provide the ingredient ID you want to check
  v_quantity_needed INT := 25; -- Provide the quantity you need
BEGIN
  check_ingredient_availability(v_ingredient_id, v_quantity_needed);
END;
/