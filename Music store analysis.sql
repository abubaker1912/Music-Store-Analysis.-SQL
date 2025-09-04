--Q.1 Who is the senior most employee based on the job title?
select * from employee
order by levels desc
limit 1

--Q.2 Which countries have the most invoices?
select billing_country,count(total) as Total_invoice
from invoice
group by billing_country
order by Total_invoice desc

--Q.3 What are top three values of total invoice
select * from invoice
order by total desc
limit 3

--Q.4 which city has the best customer(We would do promotional music festival in the city we
--made the most money.Write a query that return one city that has the highest sum of invoice
--totals.Return both the city name & sum of all invoice)

select billing_city,sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc

--Q.5 who is the best customer(The customer who has spend the most money will be declared the best customer.
--Write a Query that returns the person who has spend the most money)

select c.first_name,c.last_name,sum(i.total) as Total_sum
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by first_name,last_name
order by Total_sum desc
limit 1

--Q.6 Write a query to return the email,first_name,last_name,& Genre of all Rock music listeners.
--Return your list order alphabetically by email staring with A

select distinct email,first_name,last_name 
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email


--Q.7 let's invite the artist who have written the most rock music in our dataset.
--Write a query that returns the artist name and total track count of the top 10 rock bands.

select a.artist_id ,a.name ,count(a.artist_id) as Number_of_songs
from artist as a
join album as al on a.artist_id=al.artist_id
join track as t on al.album_id=t.album_id
join genre as g on t.genre_id=g.genre_id
	where g.name like 'Rock'
	group by a.artist_id
	order by number_of_songs desc
	limit 10


--Q.8 Returns all the names that have the song length longer than the average song length.
--return the name and milliseconds for each track. order by the song length with the longest songs listed first
select * from track

select name , milliseconds
from track
where milliseconds > (
select avg(milliseconds) as song_length
from track)
order by milliseconds desc

------------or--------------
--But this is not dynamic
select name , milliseconds
from track
where milliseconds > 393599   --Average of milliseconds column
order by milliseconds desc


--Q.9 Find how much amount spent by each customer on artists? write a query to return customer name, artist name ,and total spent 

--Use of CTE Function
with best_selling_artist as(
select a.artist_id as artist_id , a.name as artist_name , sum(il.unit_price*il.quantity) as total_sales
from invoice_line as il
join track as t on il.track_id = t.track_id
join album as al on t.album_id = al.album_id
join artist as a on al.artist_id = a.artist_id
group by a.artist_id
order by total_sales desc
limit 1
)
select c.customer_id , c.first_name , c.last_name, bsa.artist_name,
sum(il.unit_price * il.quantity) as amount_spent
from invoice i
join customer as c on c.customer_id=i.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
join track as t on t.track_id=il.track_id
join album as alb on alb.album_id=t.album_id
join best_selling_artist as bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc

------------or-------------
-----Another method--------
select c.customer_id,c.first_name, c.last_name , a.name , sum(il.unit_price*il.quantity) as Amount_spent
from customer as c
join invoice as i on c.customer_id=i.customer_id
join invoice_line as il on i.invoice_id=il.invoice_id
join track as t on il.track_id=t.track_id
join album as alb on t.album_id=alb.album_id
join artist as a on alb.artist_id=a.artist_id
group by 1,2,3,4
order by 5 desc


--Q.10 we want to find out the most popular music genre for each country.We determine the most popular genre as genre with
--the highest amount of purchase.Write a query to return each country along with the top genre.
--For countries where the maximum no. of purchases is shared return all genre

with popular_genre as
(
	select g.genre_id, g.name, c.country, count(il.quantity) as purchase,
	Row_number() over(partition by c.country order by count(il.quantity) desc) as Row_No
	from customer as c
	join invoice as i on c.customer_id=i.customer_id
	join invoice_line as il on i.invoice_id=il.invoice_id
	join track as t on il.track_id=t.track_id
	join genre as g on t.genre_id=g.genre_id
	group by 1,2,3
	order by 3 asc ,4 desc
)
select * from popular_genre where Row_No <=1


--Q.11 write a query that determines the customer that has spent the most on music for each country.
--write a query that returns the country along with the top customer and how much they spent.
--for countries where the top amount spent is shared ,provide all customer who spent the amount.
with customer_with_country as(
	select c.customer_id, c.first_name ,c.last_name, i.billing_country, sum(i.total) as Total_spending,
	row_number() over(partition by i.billing_country order by sum(i.total)desc) as Row_No
	from customer as c
	join invoice as i
	on c.customer_id=i.customer_id
	group by 1,2,3,4
	order by 4 asc ,5 desc)
select * from customer_with_country where Row_No <= 1









