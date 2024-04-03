use music_database;

select * from album;

select * from employee order by levels desc limit 1;

select billing_country, count(invoice_id) as invoice_count from invoice group by billing_country order by count(invoice_id) desc;

select * from invoice order by total desc limit 3;

select billing_city, sum(total) as Total_amt from invoice group by billing_city order by Total_amt desc;

select concat(first_name," ", a.last_name) as customer_name,sum(b.total) as Total_amt from customer as a join invoice as b
on a.customer_id = b.customer_id group by customer_name order by Total_amt desc limit 1;

select distinct a.first_name, a.last_name, a.email from customer as a
join invoice as b on a.customer_id = b.customer_id
join invoice_line as c on b.invoice_id = c.invoice_id
join track as d on c.track_id = d.track_id
join genre as e on d.genre_id = e.genre_id
where e.name = "Rock" order by a.email asc;

select distinct a.first_name, a.last_name, a.email from customer as a
join invoice as b on a.customer_id = b.customer_id
join invoice_line as c on b.invoice_id = c.invoice_id
where track_id in
(select a.track_id from track as a join genre as b on a.genre_id = b.genre_id where b.name = "Rock")
order by a.email asc;

select a.artist_id,a.name, count(c.track_id) as Songs_Count from artist as a
join album as b on a.artist_id=b.artist_id join track as c on
b.album_id = c.album_id where c.genre_id in (select genre_id from genre where name like "Rock")
group by a.artist_id,a.name order by Songs_Count desc limit 10;

select name, milliseconds from track where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1,2)

select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amt_spent from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

with popular_genre as (select invoice.billing_country, count(invoice.total),genre.name,
row_number() over(partition by invoice.billing_country) as row_numbers
from invoice
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 1,3
order by 2 desc)
select * from popular_genre where popular_genre.row_numbers<=1;

with cust_detail as ( 
	select customer.first_name, customer.last_name, customer.country,
	sum(invoice.total) as total_amt,
	row_number() over(partition by customer.country order by sum(invoice.total) desc) as row_numbers
	from
    customer
	join invoice on customer.customer_id = invoice.customer_id
	join invoice_line on invoice.invoice_id=invoice_line.invoice_id
	group by 1,2,3
    order by  3 asc)
select * from cust_detail where cust_detail.row_numbers=1;