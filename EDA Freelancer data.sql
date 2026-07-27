SELECT * FROM global_freelancer.clean_staging_table2;

with freelancer_cte as 
( 
select *,
row_number() over(partition by freelancer_ID,full_name,gender,age,country,`language`, primary_skill
,years_of_experience, hourly_rate_USD,rating, is_active, client_satisfaction) as row_num 
from clean_staging_table2
)
select *
from freelancer_cte
where row_num > 1; 


/*
Global Freelancer Data Exploration 

Skills used: Aggregate function, Case statement, cte's, create view

*/

 -- freelancers profiles (age, gender, country, etc)
 
 select *
 from clean_staging_table2;
 
 select max(age) as oldest, min(age) as youngest, round(avg(age),1) as avg_age
 from clean_staging_table2;
 
select *
from clean_staging_table2
where age = 20 or age = 60 
order by age desc;

select age, COUNT(*) as total_count
from clean_staging_table2
where age in (20, 60)
group by age;
 -- there is 23 people age is 20 as the youngest and there is 19 people that age 60 as the oldest 
 select count(*)
from clean_staging_table2
where age > 20 and age < 60 ;
 -- and there is 863 people that age between 21 and 59
 
 select gender, age, count(gender) 
 from clean_staging_table2
 group by gender, age 
 order by count(gender)  desc;

select gender, count(gender)
from clean_staging_table2
group by gender;

-- show percentage female and male 
select gender, count(*),
round(count(*) * 100.0 / sum(count(*)) over(), 1) as percentage
from clean_staging_table2
group by gender;

select gender,
round(count(*) * 100.0 / sum(count(*)) over(), 1) as percentage, 
min(hourly_rate_USD) as min_rate, max(hourly_rate_USD)as max_rate 
from clean_staging_table2
group by gender;
-- female and male have the same max and min hourly rate 

-- top 5 coutry have freelacer 
select country, count(*) as total_freelancer
from clean_staging_table2
group by country 
order by total_freelancer desc 
limit 5; 

select *
from clean_staging_table2;

-- how may people that have certain skills
select primary_skill, count(primary_skill)
from clean_staging_table2
group by primary_skill ;

-- avg hourly rate by skill
select primary_skill, round(avg(hourly_rate_USD)) as avg_rate, min(hourly_rate_USD) as min_rate, max(hourly_rate_USD) as max_rate
from clean_staging_table2
where hourly_rate_USD is not null 
group by primary_skill
order by avg_rate desc;

select *
from clean_staging_table2;

-- avg hourly rate by year of experience 
select years_of_experience, round(avg(hourly_rate_USD)) as  avg_rate, count(*) as freelancer_count
from clean_staging_table2
where hourly_rate_USD is not null and years_of_experience is not null
group by years_of_experience
order by years_of_experience asc;

-- hourly rate by country 
select country, round(avg(hourly_rate_USD)) as avg_rate, count(*) as freelancer_count
from clean_staging_table2
where hourly_rate_USD is not null 
group by country 
order by avg_rate desc;

-- hourly rate by clien statisfaction and years of experience
select client_satisfaction, round(avg(hourly_rate_USD)) as  avg_rate, max(years_of_experience)
from clean_staging_table2
where hourly_rate_USD is not null and years_of_experience is not null
group by client_satisfaction
order by 1 desc;

select client_satisfaction
from clean_staging_table2
group by client_satisfaction
order by  1 desc;

-- houry rate by gender 
select gender, round(avg(hourly_rate_USD)) as  avg_rate, count(*) as freelancer_count
from clean_staging_table2
where hourly_rate_USD is not null 
group by gender 
order by 1;

-- avg rating by skill 
select primary_skill, round(avg(rating)) as avg_rating, round(avg(client_satisfaction)) as avg_satisfaction,
count(*) as freelancer_count
from clean_staging_table2
where rating is not null and client_satisfaction is not null 
group by primary_skill
order by 2 desc;

-- 
select max(hourly_rate_USD), min(hourly_rate_USD)
from clean_staging_table2;

-- does high hour rates means rating ?
Select case
when hourly_rate_USD < 30 then 'Lowest'
when hourly_rate_USD between 30 and 70 then 'Middle'
when hourly_rate_USD > 70 then 'Highest'
end as hourly_rate_bracket,
round(avg(rating)) as avg_rating,
round(avg(client_satisfaction)) as avg_satisfaction,
count(*) as freelancer_count
from clean_staging_table2
where hourly_rate_USD is not null and rating is not null
group by hourly_rate_bracket
order by avg_rating desc;
-- high hour rate does not equal to high rating, result show middle hourly rate have the lowest rating

-- 
select *
from clean_staging_table2;

-- does higher experience equal to high hour rate 
select max(years_of_experience), min(years_of_experience)
from clean_staging_table2;

select case 
when years_of_experience <= 5 then 'Junior'
when years_of_experience between 5 and 30 then 'middle'
when years_of_experience >= 30 then 'Senior'
end as experience_bracket, 
round(avg(hourly_rate_USD)) as avg_rate,
count(*) as freelancer_count
from clean_staging_table2
where years_of_experience is not null and hourly_rate_USD is not null 
group by experience_bracket
order by avg_rate desc;
-- high experience does equal to high hourly rate 

-- total freelancer had rating bracket 

select max(rating), min(rating)
from clean_staging_table2;

select rating 
from clean_staging_table2
where rating <2
group by rating;

select case 
when rating <= 2 then 'Low'
when rating between 2 and 4 then 'Mid'
when rating >= 4 then 'High'
end as rating_bracket, 
count(*) as freelancer_count
from clean_staging_table2
where rating is not null and client_satisfaction is not null
group by rating_bracket
order by freelancer_count  desc;

-- breakdown active and inactive, how many is acive freelancer and how many is inactive freelancer 
select is_active, count(*) as total
from clean_staging_table2
where is_active is not null 
group by is_active; 

-- top 5 skill have the most inactive freelancer 
select primary_skill, 
count(case when is_active = 'active' then 1 end ) as active_freelancer,
count(case when is_active = 'inactive' then 1 end) as inactive_freelancer, count(*) as total_freelancer
from clean_staging_table2
where is_active is not null
group by primary_skill
order by inactive_freelancer desc
limit 5;

-- creating view 
create view experience_and_rate as
select case 
when years_of_experience <= 5 then 'Junior'
when years_of_experience between 5 and 30 then 'middle'
when years_of_experience >= 30 then 'Senior'
end as experience_bracket, 
round(avg(hourly_rate_USD)) as avg_rate,
count(*) as freelancer_count
from clean_staging_table2
where years_of_experience is not null and hourly_rate_USD is not null 
group by experience_bracket
order by avg_rate desc;

select *
from experience_and_rate;
