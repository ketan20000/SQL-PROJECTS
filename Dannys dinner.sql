create database dannys_diner

use  dannys_diner
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

--three tables 
select * from sales
select * from menu
select * from members

---1.What is the total amount each customer spent at the restaurant?


select  customer_id,sum(price) as total_spent
from sales inner join menu
on sales.product_id=menu.product_id
group by customer_id
order by total_spent desc;


--2.How many days has each customer visited the restaurant?
select customer_id,count(customer_id) as visited_days
from sales
group by customer_id;


--3.what was the first item from the menu purchased by each customer?

with cte as(
select customer_id,product_name as first_product_order ,order_date,
row_number() over(PARTITION by customer_id order by order_date asc) as row_nuber
from sales inner join menu
on sales.product_id=menu.product_id)


select customer_id,first_product_order,order_date
from cte 
where row_nuber=1


---4.What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1  
product_name,
count(product_name) as no_time_purchased
from sales inner join menu
on sales.product_id=menu.product_id
group by product_name
order by no_time_purchased desc;


--5--Which item was the most popular for each customer?
with cte as(
select customer_id, 
product_name,
count(product_name) as orders,
rank() over(partition by customer_id order by count(product_name) desc ) as ranks 
from sales inner join menu
on sales.product_id=menu.product_id
group by product_name,customer_id)


select customer_id, 
product_name,orders
from cte 
where ranks=1



--6-Which item was purchased first by the customer after they became a member

with cte as(
select s.customer_id, m.product_name,members.join_date,s.order_date,
rank() over(partition by s.customer_id order by  s.order_date asc) as ranks 
from sales s
inner join members on s.customer_id=members.customer_id
inner join menu m on s.product_id=m.product_id
where order_date>=join_date)

select customer_id, product_name as purchased_item,join_date,order_date 
from cte 
where ranks=1


--7-Which item was purchased just before the customer became a member?


with cte as(
select s.customer_id, m.product_name,members.join_date,s.order_date,
row_number() over(partition by s.customer_id order by  s.order_date desc) as ranks 
from sales s
inner join members on s.customer_id=members.customer_id
inner join menu m on s.product_id=m.product_id
where order_date<join_date)

select customer_id, product_name as purchased_item,join_date,order_date 
from cte 
where ranks=1


--8.What is the total items and amount spent for each member before they became a member?


select s.customer_id,sum(m.price) as totals_spend_before_membership,count(s.product_id)as total_item
from sales s
inner join members on s.customer_id=members.customer_id
inner join menu m on s.product_id=m.product_id
where s.order_date< members.join_date
group by  s.customer_id


--9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select * ,
 case when product_name='sushi' then price*10*2 
 else price*10  end as pointer
 from menu




 ---Bonus Questions

 --1.Join All The Things
 select s.customer_id,order_date,product_name,price,
 case when s.order_date>=members.join_date then 'y'
 else 'n' end as members 
 from 
 sales s left join menu m on s.product_id=m.product_id
 left join  members   on members.customer_id=s.customer_id
 
 
 --2.Rank All The Things
 with cte as(
 select s.customer_id,order_date,product_name,price,
 case when s.order_date>=members.join_date then 'y'
 else 'n' end as members 
 from 
 sales s left join menu m on s.product_id=m.product_id
 left join  members   on members.customer_id=s.customer_id)
 
 select *,
 case when cte.members='N' then Null
 else  rank() over(partition by customer_id,members  order by  order_date)
 end as ranks
 from cte;


