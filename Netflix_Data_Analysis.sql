
-- NETFILX DATA ANALYSIS


drop table if exists netflix;
create table netflix(
show_id	varchar(5),
type varchar(10),
title varchar(150),
director varchar(210),
casts varchar(800),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(80),
description varchar(250)

);

select * from netflix;

select count(*)
from netflix;

select distinct type
from netflix;

-- Data analysis

--Q1 count the number of movies vs tv shows
select type,count(*) as Total_content
from netflix
group by type;

--Q2 find the most common rating for movies and tv shows

select type,rating
from (
select type,rating,count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by 1,2
) as t1
where ranking=1

--Q3 list all movies released in a specific year (eg.2020)
select * from netflix
where type='Movie'
and release_year=2020;

--Q4 find the top 5 countries with most content on netflix
select  unnest(string_to_array(country,',')) as new_country,
count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5

--Q5  Identify the longest movie?

select * from netflix
where type='Movie'
and duration=(select max(duration) from netflix)

--Q6 find content added in the last 5 years
select * from netflix
where to_date(date_added,'month dd,yyyy')>=current_date - interval '5 years'

--Q7  find all the movies/ Tv shows by director 'rajiv chilaka'

select * from netflix 
where director ilike '%Rajiv Chilaka%';

--Q8 list all tv shows with more than 5 seasons

select * from netflix 
where type='TV Show'
and split_part(duration,' ',1)::numeric >5

--Q9 Count the number of content items in each genre

select 
unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total_content
from netflix
group by 1

--Q10 find each year and the average number of content released by india on netflix
-- return top 5 year with highest avg content release

select 
extract (year from to_date(date_added,'month dd,yyyy')) as year,
count(*) as yearly_content,
round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric*100,2)
as avg_content_per_year
from netflix
where country='India'
group by 1

--Q11 List all movies that are documentries
select * from netflix
where type='Movie'
and listed_in ilike '%Documentaries%'

--Q12 find all content without a director

select * from netflix
where director is null

--Q13 find how many movies actor "salman khan " apperead in last 10 years

select * from netflix
where casts ilike '%Salman Khan%'
and release_year > extract (year from current_date )-10

--Q14 Find the top  10 actors who apperead in the highest number of movies 
--produced in india 

select unnest (string_to_array(casts,',' )) as actors,
count(*) as total_content
from netflix
where country ilike '%india'
group by 1
order by 2 desc
limit 10

--END