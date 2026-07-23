/*

Cleaning Data in SQL Queries

*/



select * from global_freelancer.global_freelancer;

-- Create staging table
create table freelancer_staging1
like global_freelancer;

insert freelancer_staging1
select *
from global_freelancer;

-- check if its properly created 
select *
from freelancer_staging1;

-- -----------------------------------------------------

-- checking duplicates 
select *,
row_number() over(partition by freelancer_ID,`name`,age,country, primary_skill) as row_num 
from freelancer_staging1;

with freelancer_cte as ( select *,
					row_number() over(partition by freelancer_ID,`name`,age,country, primary_skill) as row_num 
					from global_freelancer)
select *
from freelancer_cte
where row_num > 1; 
-- the result show no duplicates 

-- ---------------------------------------------------------------

-- standarisation data 
select *
from freelancer_staging1;

-- standarizing coloums name
alter table freelancer_staging1 rename column `name` to full_name;
alter table freelancer_staging1 rename column `hourly_rate (USD)` to hourly_rate;

-- stadarizing full_name coloumn 
select full_name, count(full_name)
from freelancer_staging1
where full_name like 'Mr%' or full_name like 'Ms%'
group by full_name;

select full_name, count(full_name)
from freelancer_staging1
where full_name like 'Mr%' and not full_name like 'Mrs%'
group by full_name;

update freelancer_staging1
set full_name = replace(full_name, 'Mr. ', '');


select full_name, freelancer_ID
from freelancer_staging1
where full_name like '%robert m___'
group by full_name, freelancer_ID;

-- 
select freelancer_ID, full_name, count(full_name)
from freelancer_staging1
where full_name like 'Mrs%' and not full_name like 'Ms%'
group by freelancer_ID, full_name;

update freelancer_staging1
set full_name = replace(full_name, 'Mrs. ', '');

select full_name, freelancer_ID
from freelancer_staging1
where full_name like 'amy b%'
group by full_name, freelancer_ID; 

-- 
select freelancer_ID, full_name, count(full_name)
from freelancer_staging1
where full_name like 'Ms%' 
group by freelancer_ID, full_name;

update freelancer_staging1
set full_name = replace(full_name, 'Ms. ', '');

select full_name, freelancer_ID
from freelancer_staging1
where full_name like '%kidd%'
group by full_name, freelancer_ID; 

-- make sure we had not deleted people name that contain %mr/ms/mrs%
select *
from freelancer_staging1
where full_name like '%ms%';
-- we got return from people that have %ms% in their name

-- 
-- I have noticed people that have other than %mr/ms/mrs% before their name
select freelancer_ID, full_name, count(full_name)
from freelancer_staging1
where full_name like '%. %' 
group by freelancer_ID, full_name; 

select freelancer_ID, full_name, count(full_name)
from freelancer_staging1
where full_name like 'dr.%' 
group by freelancer_ID, full_name;

update freelancer_staging1
set full_name = replace(full_name, 'Dr. ', '');
-- updated sucesfully 
select full_name
from freelancer_staging1;


-- stadarizing gender coloum  
select gender 
from freelancer_staging1
where gender like 'F%';

select gender 
from freelancer_staging1
where gender like 'M%';

select gender 
from freelancer_staging1
group by gender ;


update freelancer_staging1 
set gender = 'Female'
where gender like 'f';

update freelancer_staging1 
set gender = 'Female'
where gender like 'FEMALE';

update freelancer_staging1 
set gender = 'Male'
where gender like 'MALE';

update freelancer_staging1 
set gender = 'Male'
where gender like 'm';


select gender
from freelancer_staging1
where gender = 'm';

-- -----------------------------------------------------

-- standarizing coloum is_active 

select *
from freelancer_staging1;

update freelancer_staging1 
set is_active = 'Active'
where is_active like 1;

update freelancer_staging1 
set is_active = 'Active'
where is_active like 'yes';

update freelancer_staging1 
set is_active = 'Active'
where is_active like 'Y';

update freelancer_staging1 
set is_active = 'Active'
where is_active like 'true';

select is_active
from freelancer_staging1
group by is_active;

update freelancer_staging1 
set is_active = 'Inactive'
where is_active like 0;

update freelancer_staging1 
set is_active = 'Inactive'
where is_active like 'N';

update freelancer_staging1 
set is_active = 'Inactive'
where is_active like 'False';

update freelancer_staging1 
set is_active = 'Inactive'
where is_active like 'no';

-- ---------------------------------

-- standarizing hourly_rate colum
select *
from freelancer_staging1;

select hourly_rate
from freelancer_staging1
group by hourly_rate;

-- remove $ sign and USD 
select replace(hourly_rate, '$', '') as clean_price 
from freelancer_staging1;

update freelancer_staging1 
set hourly_rate = replace(hourly_rate, '$', '');


select trim('USD' from hourly_rate) AS clean_price
from freelancer_staging1
where hourly_rate like 'USD%';

update freelancer_staging1
set hourly_rate = trim('USD' from hourly_rate)
where hourly_rate like 'USD%';

select *
from freelancer_staging1;

-- left trim space
select ltrim(hourly_rate)
from freelancer_staging1;

update freelancer_staging1
set hourly_rate = ltrim(hourly_rate);

-- change coloum name 
alter table freelancer_staging1 rename column `hourly_rate` to hourly_rate_USD;


-- standarizing client statisfaction coloumn 
-- change % into decimal 
select *
from freelancer_staging1;

select client_satisfaction
from freelancer_staging1
group by client_satisfaction
order by client_satisfaction desc ;

-- changing % into decimal number 
select client_satisfaction,
case 
        when client_satisfaction like '%%' then replace(client_satisfaction, '%', '') / 100
        else client_satisfaction / 100 
end as descimal_num
from freelancer_staging1 ;

-- Update into the data 
update freelancer_staging1
set client_satisfaction = case 
        when client_satisfaction like '%%' then replace(client_satisfaction, '%', '') / 100
        else client_satisfaction / 100 
end;

select client_satisfaction
from freelancer_staging1
group by client_satisfaction
;
select *
from freelancer_staging1;

-- -----------------

-- ________________handling Blank Values
select *
from freelancer_staging1
where years_of_experience = '' and hourly_rate_USD = ''; 

select *
from freelancer_staging1
where rating = '' and is_active = '';


-- update blank values into null values
update freelancer_staging1
set years_of_experience = null
where years_of_experience = '' ;

update freelancer_staging1
set rating = null
where rating = '' ;

update freelancer_staging1
set hourly_rate_USD = null
where hourly_rate_USD = '' ;

update freelancer_staging1
set is_active = null
where is_active = '' ;
-- ____________check 
select *
from freelancer_staging1
where years_of_experience is null and hourly_rate_USD is null ;

select *
from freelancer_staging1
where rating is null and is_active is null ;


select *
from freelancer_staging1
where years_of_experience is null ;

--  removing years_of_experience null values and hourly_rate_USD null values
delete 
from freelancer_staging1
where years_of_experience is null and hourly_rate_USD is null;

select *
from freelancer_staging1
where years_of_experience is null and hourly_rate_USD is null;

-- removing hourly_rate_USD null values and rating null values 
delete 
from freelancer_staging1
where hourly_rate_USD is null and rating is null;

select *
from freelancer_staging1
where hourly_rate_USD is null and rating is null;

select *
from freelancer_staging1
where rating is null ;

-- removing hourly_rate_USD null values and is_active null values 
delete 
from freelancer_staging1
where hourly_rate_USD is null and is_active is null;

select *
from freelancer_staging1
where hourly_rate_USD is null and is_active is null;

-- _______________________________________-

-- standarizing data type 

select *
from freelancer_staging1;

describe freelancer_staging1;

-- update text to varchar in coloumn freelancer_id
select length(freelancer_ID)
from freelancer_staging1;

alter table freelancer_staging1
modify column freelancer_ID varchar(50) ;

select *
from freelancer_staging1;

-- update text to varchar in full_name coloumn 
select length(full_name)
from freelancer_staging1
where length(full_name) > 50 or length(full_name) < 50
order by length(full_name) desc ;

alter table freelancer_staging1
modify column full_name varchar(50) ;

describe freelancer_staging1;

-- update text to varchar in gender coloumn 
alter table freelancer_staging1
modify column gender varchar(50) ;

select *
from freelancer_staging1;

describe freelancer_staging1; 

-- update double to int in age coloumn 
select max(age), avg(age), min(age)
from freelancer_staging1;

alter table freelancer_staging1
modify column age INT ;

describe freelancer_staging1; 

-- update text to varchar in country coloumn  
select length(country)
from freelancer_staging1
where length(country) < 50
order by length(country) desc;

alter table freelancer_staging1
modify column country varchar(50) ;

describe freelancer_staging1;

select *
from freelancer_staging1;

-- update text to varchar in language coloumn 
select length(`language`)
from freelancer_staging1
order by length(`language`) desc;

alter table freelancer_staging1
modify column `language` varchar(50) ;

describe freelancer_staging1;

-- update text to varchar in primary_skill coloumn 
select length(primary_skill)
from freelancer_staging1
order by length(primary_skill) desc;

alter table freelancer_staging1
modify column primary_skill varchar(100) ;

select *
from freelancer_staging1;

describe freelancer_staging1;

-- update double to INT in coloumn years_of_experiece 
UPDATE freelancer_staging1
SET years_of_experience = FLOOR(years_of_experience);

alter table freelancer_staging1
modify column years_of_experience INT ;

describe freelancer_staging1;

select *
from freelancer_staging1;

-- update text to int in coloumn hourly_rate_USD
select hourly_rate_USD
from freelancer_staging1
where hourly_rate_USD >= 100
group by hourly_rate_USD;

alter table freelancer_staging1
modify column hourly_rate_USD int ;

select max(hourly_rate_USD)
from freelancer_staging1; -- suscessfully updated

describe freelancer_staging1;

-- update text to decimal in coloumn rating
select rating, length(rating)
from freelancer_staging1
group by rating;

alter table freelancer_staging1
modify column rating decimal(10, 1) ;

select rating
from freelancer_staging1;

select f1.rating as f1, f2.rating as f2
from global_freelancer as f1
join freelancer_staging1 as f2
on f1.freelancer_ID = f2.freelancer_ID
group by f1.rating, f2.rating; -- compared to original tabel

describe freelancer_staging1;

-- update text to varchar in coloumn is_active
select f1.is_active as gf1, f2.is_active as f2
from global_freelancer as f1
join freelancer_staging1 as f2
on f1.freelancer_ID = f2.freelancer_ID
group by f1.is_active, f2.is_active; -- compared to original tabel


alter table freelancer_staging1
modify column is_active varchar (50) ;

select is_active
from freelancer_staging1
group by is_active;

describe freelancer_staging1;

-- update text to decimal in coloumn client_satisfaction
select *
from freelancer_staging1;


select client_satisfaction, length(client_satisfaction)
from freelancer_staging1
group by client_satisfaction
order by client_satisfaction desc;

alter table freelancer_staging1
modify column client_satisfaction decimal(10, 2) ;

select client_satisfaction
from freelancer_staging1;

describe freelancer_staging1;

select f1.client_satisfaction as f1, f2.client_satisfaction as glbf2
from freelancer_staging1 as f1
join global_freelancer as f2
on f1.freelancer_ID = f2.freelancer_ID
group by f1.client_satisfaction, f2.client_satisfaction
order by f1.client_satisfaction desc;

-- ____________________________ 
describe freelancer_staging1;
-- all colomn data type sucsesfully stadarize
-- _______________________________________
-- _______________________________________
-- _______________________________________

-- check duplicates
select freelancer_ID, full_name, count(freelancer_ID)
from freelancer_staging1
group by freelancer_ID, full_name;

select *,
row_number() over(partition by freelancer_ID,full_name,gender,age,country,`language`, primary_skill
,years_of_experience, hourly_rate_USD,rating, is_active, client_satisfaction) as row_num 
from freelancer_staging1;

with freelancer_cte as 
( 
select *,
row_number() over(partition by freelancer_ID,full_name,gender,age,country,`language`, primary_skill
,years_of_experience, hourly_rate_USD,rating, is_active, client_satisfaction) as row_num 
from freelancer_staging1
)
select *
from freelancer_cte
where row_num > 1; 

-- deleted duplicates 
select distinct * 
from freelancer_staging1;

select  * 
from freelancer_staging1
where full_name like 'nicole_____';

select *
from freelancer_staging1
where freelancer_ID like '%005';

-- create staging table 2 to deleted duplicates
create table clean_staging_table2 as
select distinct * 
from freelancer_staging1;

select *
from clean_staging_table2;

select freelancer_ID, full_name, count(freelancer_ID)
from clean_staging_table2
group by freelancer_ID, full_name;

describe clean_staging_table2;

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

select  * 
from clean_staging_table2
where full_name like 'nicole_____';
-- 

select freelancer_ID, count(freelancer_ID)
from clean_staging_table2
group by freelancer_ID;

select freelancer_ID, full_name, count(freelancer_ID)
from freelancer_staging1
group by freelancer_ID, full_name;
