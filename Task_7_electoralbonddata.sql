use electoralbonddata;

-- 1.Find out how much donors spent on bonds

SELECT sum(denomination)
FROM bonddata
JOIN donordata
ON bonddata.Unique_key=donordata.Unique_key;

-- 2.Find out total fund politicians got

SELECT sum(denomination) AS Total_fund_recieved_by_politicians
FROM bonddata
JOIN receiverdata
ON bonddata.Unique_key=receiverdata.Unique_key;


-- 3. Find out the total amount of unaccounted money received by parties

SELECT SUM(b.Denomination) as total_unaccounted_money
FROM bonddata b 
JOIN receiverdata r 
ON b.Unique_key = r.Unique_key
LEFT JOIN donordata d 
ON d.Unique_key = r.Unique_key
WHERE d.Purchaser IS NULL;

-- 4. Find year wise how much money is spend on bonds

WITH money AS(
SELECT bonddata.Denomination,bonddata.Unique_key,
donordata.purchasedate
FROM bonddata
JOIN donordata
ON donordata.Unique_key=bonddata.Unique_key
)SELECT YEAR(purchasedate) AS year_,sum(denomination) AS money_spent
FROM money
GROUP BY year_
ORDER BY year_;

-- 5. In which month most amount is spent on bonds

WITH max_month1 AS (
SELECT monthname(d.PurchaseDate) as mon,
sum(b.Denomination) as sd
FROM donordata d
JOIN bonddata b
ON d.Unique_key=b.Unique_key
group by mon
order by sd desc
)SELECT mon AS month_with_highest_amount_spent 
from max_month1
where sd=(select max(sd) from max_month1);

-- 6. Find out which company bought the highest number of bonds.
with dhb as(
select Purchaser as company_with_highest_numberofbonds,count(urn) as no_of_bonds
from donordata 
group by purchaser
order by count(urn)desc)
select company_with_highest_numberofbonds
from dhb
where no_of_bonds= (select max(no_of_bonds) 
					  from dhb);

-- 7. Find out which company spent the most on electoral bonds.

with highest_spent_company as (
select SUM(b.Denomination) as "total_spending",d.purchaser as csm
from bonddata b
join donordata d
on b.Unique_key=d.Unique_key
GROUP BY d.purchaser
ORDER BY `total_spending` DESC
)
SELECT csm
FROM highest_spent_company
WHERE total_spending = (select max(total_spending)
from highest_spent_company);

-- 8. List companies/Individuals which paid the least to political parties.

with leastpaid_companies as(
select d.purchaser,sum(b.denomination) as lpd
from donordata d
join bonddata b
on d.Unique_key=b.Unique_key
group by d.purchaser
order by lpd
)
select purchaser as least_paid_donors
from leastpaid_companies 
where lpd in ( select min(lpd) 
			   from leastpaid_companies);

-- 9. Which political party received the highest cash?

with prhc as (
select r.partyname,sum(b.denomination) as dnm
from receiverdata r
join bonddata b
on r.Unique_key=b.Unique_key
group by PartyName
order by dnm desc
) 
select partyname as party_receiving_highest_cash
  from prhc 
  where dnm in(
			   select max(dnm) 
               from prhc);

-- 10. Which political party received the highest number of electoral bonds?

with prheb as(
select r.partyname,count(d.urn) as cou
from receiverdata r
join donordata d
on r.unique_key=d.unique_key
group by PartyName
order by cou desc
) 
select partyname as party_with_highest_electoral_bond
from prheb 
where cou in(
			 select max(cou)
             from prheb) ;

-- 11. Which political party received the least cash?
with prlc as (
select r.partyname,sum(b.denomination) as dnm
from receiverdata r
join bonddata b
on r.Unique_key=b.Unique_key
group by PartyName
order by dnm 
) 
select partyname as party_receiving_lowest_cash
  from prlc 
  where dnm in(
			   select min(dnm) 
               from prlc);
               
-- 12. Which political party received the least number of electoral bonds?
with prleb as(
select r.partyname,count(d.urn) as cou
from receiverdata r
join donordata d
on r.unique_key=d.unique_key
group by PartyName
order by cou
) 
select partyname as party_with_lowest_electoral_bond
from prleb 
where cou in(
			 select min(cou)
             from prleb) ;
-- 13. Find the 2nd highest donor in terms of amount he paid?
with sec_high_donor as(
select d.purchaser,sum(b.denomination) as sum_d
from donordata d
join bonddata b
on d.Unique_key=b.Unique_key
group by purchaser
order by sum_d desc
) select max(sum_d) as amount,purchaser as second_highest_donor from sec_high_donor
group by second_highest_donor
order by  max(sum_d) desc
limit 1,1;

-- 14. Find the party which received the second highest donations?

with prshc as (
select r.partyname,sum(b.denomination) as dnm
from receiverdata r
join bonddata b
on r.Unique_key=b.Unique_key
group by PartyName
order by dnm desc
) select partyname,max(dnm) as party_receiving_highest_cash
  from prshc 
  where dnm <(
			   select max(dnm) 
               from prshc) group by partyname limit 1;
             
-- 15. Find the party which received the second highest number of bonds? --- check

with prsheb as(
select r.partyname,count(d.urn) as cou
from receiverdata r
left join donordata d
on r.unique_key=d.unique_key
group by PartyName
order by cou desc
) 
select max(cou) as cu,partyname as party_with_secondhighest_electoral_bond
from prsheb 
where cou <(select max(cou)
			from prsheb) group by partyname limit 1;
             
-- 16. In which city were the most number of bonds purchased?

with mbp as(
select b.city,count(d.urn) as curn
from bankdata as b
join donordata d 
on b.branchCodeNo=d.PayBranchCode 
group by city
) select city as 'city_where_max_bonds_purchased'
from mbp
where curn=(select max(curn) 
			from mbp);

-- 17. In which city was the highest amount spent on electoral bonds?
with hsc as(
SELECT bk.CITY, sum(b.Denomination) as mx
FROM bonddata b 
JOIN donordata d ON b.Unique_key = d.Unique_key
JOIN bankdata bk ON d.PayBranchCode = bk.branchCodeNo
GROUP BY bk.CITY
) select city as 'city_which_spenthighest_amount'from hsc 
  where mx =(select max(mx)  from hsc order by mx desc);

-- 18. In which city were the least number of bonds purchased?

with cwlnb as(
select b.city,count(d.Urn) as crn 
from bankdata b 
join donordata d 
on d.paybranchcode=b.branchCodeNo 
group by city
order by crn ) SELECT city AS 'city_where_minimumbonds_purchased'
			   FROM cwlnb 
               WHERE crn=(SELECT min(crn) FROM cwlnb);

-- 19. In which city were the most number of bonds enchased?

with cwhbe as(
select b.city,count(r.DateEncashment) as 'de'
from bankdata b 
join receiverdata r
on b.branchCodeNo=r.PayBranchCode
group by b.city)select city as 'city_where_mostbonds_encashed'
				from cwhbe 
                where de=(select max(de) 
						  from cwhbe);
 
-- 20. In which city were the least number of bonds enchased?

with cwlbe as(
select b.city,count(r.DateEncashment) as 'de'
from bankdata b 
join receiverdata r
on b.branchCodeNo=r.PayBranchCode
group by b.city) select city as 'city_where_leastbonds_encashed'
				 from cwlbe 
                 where de=(select min(de)
						   from cwlbe);
                          
-- 21. List receiverdata the branches where no electoral bonds were bought; if none, mention it as null.

SELECT DISTINCT bk.city
FROM bankdata bk 
LEFT JOIN donordata d 
ON d.PayBranchCode = bk.branchCodeNo
WHERE d.PayBranchCode is NULL; 


-- 22. Break down how much money is spent on electoral bonds for each year.

select year(d.purchasedate) as 'year_' ,sum(b.Denomination) as 'Total_money_spent_'
from bonddata b 
join donordata d 
on b.Unique_key=d.Unique_key
group by year_
order by `Total_money_spent_` DESC;

/*23. Break down how much money is spent on electoral bonds for each year and provide the year and the amount. Provide values
for the highest and least year and amount.*/

with aa as(
SELECT YEAR(d.purchasedate) as 'year_' ,sum(b.Denomination) as 'Highest_and_lowest_Money'
from bonddata b 
JOIN donordata d           
ON b.Unique_key=d.Unique_key
GROUP BY year_
ORDER BY year_) 
SELECT * 
FROM aa
WHERE `Highest_and_lowest_Money` IN ((SELECT max(Highest_and_lowest_Money) 
                                      FROM aa) , (SELECT min(Highest_and_lowest_Money) 
                                                  FROM aa))
												  ORDER BY `Highest_and_lowest_Money` DESC ;


/*24. Find out how many donors bought the bonds but did not donate to any political party?*/

SELECT COUNT(*)
FROM donordata d 
LEFT JOIN receiverdata r
ON d.Unique_key = r.Unique_key
WHERE r.PartyName IS NULL; 

-- 25. Find out the money that could have gone to the PM Office, assuming the above question assumption (Domain Knowledge)

SELECT  sum(b.denomination)
from bonddata b
left JOIN receiverdata r
ON b.Unique_key=r.Unique_key
WHERE r.PayBranchCode IS NULL;

-- 26. Find out how many bonds don't have donors associated with them.

SELECT  count(*) as 'count_ofbonds_having_unknowndonors'
FROM donordata d 
right join bonddata b
on d.Unique_key=b.Unique_key
WHERE d.Purchaser IS NULL;

/*27. Pay Teller is the employee ID who either created the bond or redeemed it. So find the employee ID who issued the highest
number of bonds.*/

WITH EMPH AS (
SELECT PayTeller,COUNT(payteller) AS HPT
FROM donordata 
GROUP BY PayTeller 
ORDER BY HPT DESC
) select payteller AS emp_isuued_maxbonds 
  from EMPH
  WHERE HPT =(select MAX(HPT) 
			 FROM EMPH);

-- 28. Find the employee ID who issued the least number of bonds.

WITH EMPL AS (
SELECT PayTeller,COUNT(payteller) AS LPT
FROM donordata 
GROUP BY PayTeller 
ORDER BY LPT 
) select payteller AS emp_isuued_lessbonds 
  from EMPL 
  WHERE LPT IN (select MIN(LPT) 
			 FROM EMPL);
             
-- 29. Find the employee ID who assisted in redeeming or enchasing bonds the most.

WITH erhb AS(
select payteller,count(payteller) as 'cpt'
from receiverdata 
group by PayTeller 
order by 'cpt'
) select payteller as 'emp_reedemed_highest_bonds' 
  from erhb 
  where cpt =(select max(cpt) 
		      from erhb);

-- 30. Find the employee ID who assisted in redeeming or enchasing bonds the least

WITH erlb AS(
select payteller,count(payteller) as 'cpt'
from receiverdata 
group by PayTeller 
order by 'cpt'
) select payteller 
  from erlb 
  where cpt = (select min(cpt) 
			   from erlb);
               
-- ----------------------------------------------------------------------------------------------------------

-- 1. Tell me total how many bonds are created?

select count(*) from bonddata;

-- 2. Find the count of Unique Denominations provided by SBI?

SELECT COUNT(DISTINCT denomination) AS 'no_of_unique_denominations' 
FROM bonddata;

-- 3. List all the unique denominations that are available?

SELECT DISTINCT denomination AS 'unique_denominations' 
FROM bonddata;

-- 4. Total money received by the bank for selling bonds

SELECT sum(denomination)
FROM bonddata;

-- 5. Find the count of bonds for each denominations that are created.

select denomination,count(Unique_key) as 'count_of_bonds'
from bonddata 
group by Denomination
order by Denomination;
 
-- 6. Find the count and Amount or Valuation of electoral bonds for each denominations.

select count(Unique_key) as 'count_of_electoralbonds',denomination,sum(Denomination) as 'valuation_of_electoral_bond'
from bonddata 
group by Denomination
order by denomination;

-- 7. Number of unique bank branches where we can buy electoral bond?

select count(distinct b.city) as 'countof_uniquebranches_tobuy_elcetoralbond' 
from bankdata b;

-- 8. How many companies bought electoral bonds

SELECT count(DISTINCT purchaser) 
FROM donordata;

-- 9. How many companies made political donations

SELECT COUNT(DISTINCT d.purchaser) 
FROM donordata d
join receiverdata r
on d.Unique_key=r.Unique_key;

-- 10. How many number of parties received donations

SELECT count(DISTINCT partyname) as 'no_of_parties_received_donations' 
FROM receiverdata; 

-- 11. List all the political parties that received donations
SELECT DISTINCT partyname 
FROM receiverdata;

-- 12. What is the average amount that each political party received

SELECT r.PartyName,avg(b.denomination) AS 'average_ammount_eachparty_received' 
FROM bonddata b 
JOIN receiverdata r 
ON b.unique_key=r.Unique_key 
GROUP BY r.PartyName;

-- 13. What is the average bond value produced by bank

SELECT AVG(denomination) AS 'average_bond_value'
FROM bonddata;

-- 14. List the political parties which have enchased bonds in different cities?

SELECT r.partyname
FROM receiverdata r 
JOIN bankdata b on r.PayBranchCode=b.branchCodeNo
GROUP BY r.partyname
HAVING COUNT(DISTINCT b.city)>1;

/*15. List the political parties which have enchased bonds in different cities and list the cities in which the bonds have enchased
as well?*/

SELECT distinct r.PartyName,b.city 
from bankdata b  
join receiverdata r 
on b.branchCodeNo=r.PayBranchCode 
where r.PartyName in( SELECT r.partyname
					  FROM receiverdata r 
                      JOIN bankdata b on r.PayBranchCode=b.branchCodeNo
					  GROUP BY r.partyname
                      HAVING COUNT(DISTINCT b.city)>1);
