select * from employee;
--  Who is the senior most employee based on job title?
SELECT * 
FROM employee
order by levels desc
limit 1;

-- which countries have most invoices?
select * from invoice;
select billing_country, count(*) as 'no. of invoices'
from invoice
group by billing_country
order by count(*) desc
limit 1;

-- What are the top 3 values of total invoices?
select * 
from invoice
order by total desc
limit 3;

-- Which city has the best customer? We would like to through a promotional music festivle we made the most money from.
-- write a query that returens one city that has highest sum of total invoices.
-- Return both the citys name and sum of all the invoices

select billing_city, sum(total) 'Total invoices'
from invoice
group by billing_city
order by sum(total) desc
limit 1;

-- Who is the best customer? the customer who have spent the most money will be decleared the best customer.
-- Write a query that returns the customer who speend most money?
select * from customer;
select * from invoice;

select c.first_name,c.last_name, sum(i.total) 'Sold Total'
from customer c
join invoice i on i.customer_id=c.customer_id
group by c.first_name, c.last_name
order by sum(i.total) desc
limit 1;

-- Write a query to return first name, lastname, email and genre of all rock music listeners.
-- return your list orded alphabatically by email staring with A
select * from genre;
select c.first_name,c.last_name,c.email
from customer c
join invoice i on i.customer_id=c.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
where g.name = 'Rock'
group by c.first_name,c.last_name,c.email
order by c.email;

-- let's invite the artists who have written the most rock music in the dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
select *from artist;
select * from track;

select a.name , count(t.track_id) 'No. of tracks'
from artist a
join album al on al.artist_id=a.artist_id
join track t on t.album_id=t.album_id
join genre g on g.genre_id=t.genre_id
where g.name='Rock'
group by  a.name
order by count(t.track_id) desc
limit 10;

-- return all the teack names that have a song length longer then the average song length.
-- return the Name and Milliseconds for each tacks.  
-- Order by the song length with the longest songs listed first.
select name, milliseconds as 'track length in Milliseconds'
from track
where milliseconds > (
select avg(milliseconds) 
from track)
order by milliseconds desc;

-- find how much amount spent by each customer on artists ? 
-- write a quary to return customer name, artist name an total spent
select * from customer;
select * from invoice;
select * from invoice_line;
select * from track;
select * from album;
select * from artist;

select concat(c.first_name,' ',c.last_name) Customer_Name , ar.name artist_name , sum(i.total*il.unit_price) total_spent
from customer c
join invoice i on i.customer_id=c.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album a on a.album_id=t.album_id
join artist ar on ar.artist_id=a.artist_id
group by c.first_name,c.last_name,ar.name
order by total_spent desc;

-- we want to find the most populer music genre for each country.
-- we determine the most populer genre as the genre with the highest amount of purchases.
-- write a query that returns each country along with the top  genre. For countries where the 
-- max mumber of purchases is shared return all genres.
select * from invoice_line;
select * from track;
select * from genre;

with popu_genre as(
SELECT 
    COUNT(il.quantity) AS perchases,  -- Count the total quantity of tracks purchased and label it as 'Purchases'
    c.country,                        -- Select the country of the customer
    g.name,                           -- Select the name of the genre
    ROW_NUMBER() OVER(
        PARTITION BY c.country         -- For each country separately
        ORDER BY COUNT(il.quantity) DESC -- Assign a unique number to each genre, sorted by the number of purchases in descending order (most purchases first)
    ) AS rowno                        -- Label this number as 'rowno'
from genre g
join track t on t.genre_id=g.genre_id
join invoice_line il on il.track_id=t.track_id
join invoice i on i.invoice_id=il.invoice_id
join customer c on c.customer_id=i.customer_id
group by 2,3
order by 2 asc, 1 desc
)
select country,name Genre ,perchases
from popu_genre 
where rowno=1
order by perchases desc;

-- Write a query that determines the customer that has spent the most on music for each country.
-- write a query that returns the country along with the top customer and how much they spend.
with cust_with_cont as(
select c.customer_id c_id, concat(c.first_name,' ', c.last_name) Customer_Name, i.billing_country Country, sum(i.total) total_spent,
 row_number() over(
        partition by i.billing_country        
        order by sum(i.total) desc
    ) as rowno                  
from customer c
join invoice i on i.customer_id=c.customer_id
group by c_id,c.first_name, c.last_name,i.billing_country
order by sum(i.total) asc, 5 desc
)
select c_id,Customer_Name,Country,total_spent from cust_with_cont 
where rowno <=1
order by total_spent desc;


