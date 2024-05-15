select * from Book1
-- to change data type of any column we can use this below query:
-- query will run if data type of columns are correct 
ALTER TABLE Book1 
ALTER COLUMN S_No float NULL

--first step for replace the null value from data create a new table for cahek campaigns to campaign  

SELECT A.* , 
     CASE WHEN  a.Campaigns IS NULL THEN (SELECT TOP (1) b.Campaigns
	                                     FROM Book1 as b
										  WHERE b.Campaigns IS NOT NULL AND A.[S_No]>= b.[S_No]
										  ORDER BY b.[S_No] DESC )
										  ELSE A.Campaigns
										  END AS CAMPAIGN ,
     CASE WHEN  a.Duration IS NULL THEN (SELECT TOP (1) b.Duration
	                                     FROM Book1 as b
										  WHERE b.Duration IS NOT NULL AND A.[S_No]>= b.[S_No]
										  ORDER BY b.[S_No] DESC )
										  ELSE A.Duration
										  END AS Durations ,
     CASE WHEN  a.product IS NULL THEN (SELECT TOP (1) b.product
	                                     FROM Book1 as b
										  WHERE b.product IS NOT NULL AND A.[S_No]>= b.[S_No]
										  ORDER BY b.[S_No] DESC )
										  ELSE A.product
										  END AS products 
	into #b1
FROM Book1 as A

select *from #b1



select *,substring (durations,1,charindex('-',durations)-1) as start_date,
substring (durations,charindex('-',durations)+1,10) as end_date
into #b2
from #b1 

select * from #b2

 --convert data dype of start and end date 
 select*,
 convert (date,start_date,3) as start_dateNR,
 convert (date,end_date,3) as end_dateNR
 into #b3
 from #b2

select * from #b3

--find the weekday name

select *,
datename(weekday,start_dateNR) ,
datename(weekday,end_dateNR) 
from #b3

ALTER TABLE #b3
ALTER COLUMN spend int NULL
 
                            --7) CONVERT WEEKDAYS NAMES TO FRIDAY STAR DATE 
 SELECT * ,
 CASE WHEN DATENAME (WEEKDAY,[START_DATENR]) = 'MONDAY' THEN DATEADD(DAY,4,[START_DATENR])
   WHEN DATENAME (WEEKDAY,[START_DATENR]) = 'TUESDAY' THEN DATEADD(DAY,3,[START_DATENR])
    WHEN DATENAME (WEEKDAY,[START_DATENR]) = 'WEDNESDAY' THEN DATEADD(DAY,2,[START_DATENR])
     WHEN DATENAME (WEEKDAY,[START_DATENR]) = 'THURSDAY' THEN DATEADD(DAY,1,[START_DATENR])
       WHEN DATENAME (WEEKDAY,[START_DATENR]) = 'FRIDAY' THEN DATEADD(DAY,0,[START_DATENR])
	     WHEN DATENAME (WEEKDAY,[START_DATENR]) = 'SATURDAY' THEN DATEADD(DAY,6,[START_DATENR])
	       WHEN DATENAME (WEEKDAY,[START_DATENR]) = 'SUNDAY' THEN DATEADD(DAY,5,[START_DATENR])
			 END AS FRIDAY_START
			   
			            --8) CONVERT WEEKDAY NAMES TO FRIDAY END DATE 
			 ,
CASE WHEN DATENAME (WEEKDAY,[end_dateNr]) = 'MONDAY' THEN DATEADD(DAY,4,[end_dateNr])
    WHEN DATENAME (WEEKDAY,[end_dateNr]) = 'TUESDAY' THEN DATEADD(DAY,3,[end_dateNr])
       WHEN DATENAME (WEEKDAY,[end_dateNr]) = 'WEDNESDAY' THEN DATEADD(DAY,2,[end_dateNr])
         WHEN DATENAME (WEEKDAY,[end_dateNr]) = 'THURSDAY' THEN DATEADD(DAY,1,[end_dateNr])
           WHEN DATENAME (WEEKDAY,[end_dateNr]) = 'FRIDAY' THEN DATEADD(DAY,0,[end_dateNr])
	          WHEN DATENAME (WEEKDAY,[end_dateNr]) = 'SATURDAY' THEN DATEADD(DAY,6,[end_dateNr])
	             WHEN DATENAME (WEEKDAY,[end_dateNr]) = 'SUNDAY' THEN DATEADD(DAY,5,[end_dateNr])
			         END AS FRIDAY_END
               --9) find the no of products by usibg lenth function
			        ,
			   len([products])-len(REPLACE([products] ,'-',''))+1  as Count_products 
		INTO #b4
from #b3
            
select * from #b4	



			--10) replace $ and coma sign in spend column  using two times replace function 
			 
 			--replace(replace([spend],'$',''),',','')   as spend_NR 



			--11) find the per_product_spend   (spend_NR/count_products )
			 
		--replace(replace([spend],'$',''),',','')    /
        --(len([products])-len(REPLACE([products] ,'-',''))+1 )
        --as per_product_spend 


select *, spend/count_products as per_product_spend 

             --12) COUNT NO DAYS  RUN CAMPAIGN
			 ,
              DATEDIFF(DAY,START_DATENR,END_DATENR) AS NO_OF_DAY
	INTO #b5
from #b4

select * from #b5
select * from dates




