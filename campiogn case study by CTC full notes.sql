USE campaignSQL

--first step for replace the null value from data create a new table for cahek campaigns to campaign  
SELECT * , 
     CASE WHEN  Campaigns IS NULL THEN (SELECT TOP (1) Campaigns
	                                     FROM Campaign
										  WHERE Campaigns IS NOT NULL AND A.[S No ]>= A.[S No ]
										  ORDER BY A.[S No ] DESC )
										  ELSE A.Campaigns
										  END AS CAMPAIGN 
FROM Campaign A


                 /*case study start  full code notes dated 02-08-2023*/

--1)   --first step for replace the null value from data create a new table for cahek stares to campaign  
SELECT * , 
     CASE WHEN  Campaigns IS NULL THEN (SELECT TOP (1) Campaigns
	                                     FROM Campaign
										  WHERE Campaigns IS NOT NULL AND A.[S No ]>= A.[S No ]
										  ORDER BY A.[S No ] DESC )
										  ELSE A.Campaigns
										  END AS CAMPAIGN 
 --2) --second step  replace the null value from duration create a new table for cheak duration to durations1  
                                  ,
										  case 
			when Duration is null then (
			select top 1 Duration 
			from Sheet1$
			where a.[S No ]>[S No ] and Duration is not null
			order by [S No ] desc )
			else Duration end as Duration1
--3)  --third  step  replace the null value from prducts create a new table for cheak product to product1
                  ,case 
			when [product ] is null then (
			select top 1 [product ] 
			from Sheet1$
			where a.[S No ]>[S No ] and [product ] is not null
			order by [S No ] desc )
			else [product ] end as [Products]
			                          --CREATE A TEMT TABE
			INTO #CAMPAIGN_TEMT_FILE
			from Campaign a



--4) --CREATE START DATE AND END DATE BY USING THE SUBSTRING FUNCTION
			   Select *,
SUBSTRING(Duration1,0,CHARINDEX('-',Duration1)) Start_Date,
SUBSTRING(Duration1,CHARINDEX('-',Duration1)+1,10) End_Date
into temt_4
FROM #CAMPAIGN_TEMT_FILE



--5)  --change data type startr_date and end_date

  select * , convert(date,Start_Date,3) [start_date_Nr] ,
              convert(date,End_date,3) [end_date_Nr]
          INTO #TMPT3
  from temt_4



                            --6) CHEAK WEEKDAYS NAMES
  SELECT *,
 DATENAME (WEEKDAY ,[START_DATE_NR])
  FROM #TMPT3

 
                            --7) CONVERT WEEKDAYS NAMES TO FRIDAY STAR DATE 
 SELECT * ,
 CASE WHEN DATENAME (WEEKDAY,[START_DATE_NR]) = 'MONDAY' THEN DATEADD(DAY,4,[START_DATE_NR])
   WHEN DATENAME (WEEKDAY,[START_DATE_NR]) = 'TUESDAY' THEN DATEADD(DAY,3,[START_DATE_NR])
    WHEN DATENAME (WEEKDAY,[START_DATE_NR]) = 'WEDNESDAY' THEN DATEADD(DAY,2,[START_DATE_NR])
     WHEN DATENAME (WEEKDAY,[START_DATE_NR]) = 'THURSDAY' THEN DATEADD(DAY,1,[START_DATE_NR])
       WHEN DATENAME (WEEKDAY,[START_DATE_NR]) = 'FRIDAY' THEN DATEADD(DAY,0,[START_DATE_NR])
	     WHEN DATENAME (WEEKDAY,[START_DATE_NR]) = 'SATURDAY' THEN DATEADD(DAY,6,[START_DATE_NR])
	       WHEN DATENAME (WEEKDAY,[START_DATE_NR]) = 'SUNDAY' THEN DATEADD(DAY,5,[START_DATE_NR])
			 END AS FRIDAY_STAR 
			   
			            --8) CONVERT WEEKDAY NAMES TO FRIDAY END DATE 
			 ,
CASE WHEN DATENAME (WEEKDAY,[end_date_Nr]) = 'MONDAY' THEN DATEADD(DAY,4,[end_date_Nr])
    WHEN DATENAME (WEEKDAY,[end_date_Nr]) = 'TUESDAY' THEN DATEADD(DAY,3,[end_date_Nr])
       WHEN DATENAME (WEEKDAY,[end_date_Nr]) = 'WEDNESDAY' THEN DATEADD(DAY,2,[end_date_Nr])
         WHEN DATENAME (WEEKDAY,[end_date_Nr]) = 'THURSDAY' THEN DATEADD(DAY,1,[end_date_Nr])
           WHEN DATENAME (WEEKDAY,[end_date_Nr]) = 'FRIDAY' THEN DATEADD(DAY,0,[end_date_Nr])
	          WHEN DATENAME (WEEKDAY,[end_date_Nr]) = 'SATURDAY' THEN DATEADD(DAY,6,[end_date_Nr])
	             WHEN DATENAME (WEEKDAY,[end_date_Nr]) = 'SUNDAY' THEN DATEADD(DAY,5,[end_date_Nr])
			         END AS FRIDAY_END

               --9) find the no of products by usibg lenth function
			        ,
			   len([products])-len(REPLACE([products] ,'-',''))+1  as Count_products 
            
			
			--10) replace $ and coma sign in spend column  using two times replace function 
			, 
 			replace(replace([spend],'$',''),',','')   as spend_NR 

			--11) find the per_product_spend   (spend_NR/count_products )
			 , 
			replace(replace([spend],'$',''),',','')    /
        (len([products])-len(REPLACE([products] ,'-',''))+1 )
 as per_product_spend 

             --12) COUNT NO DAYS  RUN CAMPAIGN
			 ,
              DATEDIFF(DAY,START_DATE_NR,END_DATE_NR) AS NO_OF_DAY
			  INTO #TMPT7
from #TMPT3

select *  from 
#TMPT7
         --12)--create dates by using the (date+7) for find the weeks and import sql create a temt table dates  
            /* create a table in excel  where [friday-star + 7] = friday7 then friday7+7  logic
			  and the data save in the csv format then import the data then going the advance mode then 
			   change the data type varhar to date */

             SELECT * FROM all_dates
		 
             --13) use cross joins tables tmpt3  and dates

				 select    * ,    case  

		      /*you can use as well step --14
			  */ 
			  when b.FRIDAY_END_DATE >= a.Friday_Star and b.FRIDAY_END_DATE <= a.Friday_End   then 1
		           else 0 end as [Validation]
				 
				 
				 INTO #FINAL


				 From #TMPT7 A
				  cross join CSV_DATES B
 				  WHERE FRIDAY_END_DATE IS NOT NULL

SELECT * FROM #FINAL


				  --14) INVALID SYNTAX AND THIS IS NOT WORKING
				  select *,
		            case 
		          when FRIDAY_END_DATE >= Friday_Star and FRIDAY_END_DATE <= Friday_End   then 1
		           else 0 end as [Validation]
		         FROM #FINAL --YOU CAM USED YOUR TEMP FILE

					  
                --15) REMOVE THE ALL 0 ROM VALIDATION COLUMN BECAUSE ITS NOT IMPORTAN FOR ME 
				--ZERO IS END CAMPAIGN AND ONE  IS CAMPAIGN IS RUNING 
				        SELECT *
						INTO #LAST
						FROM  #FINAL
					  WHERE Validation = 1
				 

				 --16) CREATE A COLUMN HOW MANY DAYS USE IN  A WEEK FOR OUR CAMPAIGN
				 SELECT *
				 , CASE WHEN DATEDIFF(DAY,START_DATE_NR,FRIDAY_END_DATE) <7 
				 THEN DATEDIFF(DAY,START_DATE_NR,FRIDAY_END_DATE)
				 
				 WHEN DATEDIFF(DAY,END_DATE_NR,FRIDAY_END_DATE) >0 
				 THEN 7-DATEDIFF(DAY,END_DATE_NR,FRIDAY_END_DATE)
				 ELSE 7

				 END AS NO_OF_DAYS

				 INTO #output
				 FROM #LAST 
			  CROSS APPLY 
			  string_split (PRODUCTS,'-')    /*THIS IS A SORTCUT WAY TO DO IT BUT 
			        BUT DO IS VIA UNNION ALL */
                    
					--LAST THING CREATE A INDICATOR KEEP OR REMOVE THE CAMPAIGN
					Select *,
                           case 
	                          when len(Product)<3 Then 'Remove'
	                               else 'Keep'
	                                 end as Indicatore
									 into #final_output_campaign_file
                                        FROM #output


			select * from #final_output_campaign_file  
					
					
					      /*campaign case study is complete */





				--do via unnion all
			
			Select *,
       case 
	   when len(Product)<3 Then 'Remove'
	   else 'Keep'
	   end as Indicatore
FROM #LAST
			select * from #LAST

			select *,
		SUBSTRING(Products,1,CHARINDEX('-',Products)-1) as Product1,
		SUBSTRING(Products,CHARINDEX('-',Products)+1,5) as Product2,
		SUBSTRING(Products,CHARINDEX('-',Products)+7,5) as Product3
		
		INTO #999
		FROM #LAST

select a.*
----into Campaign_Final_Output
from
(Select a.*,
       case 
	   when len(a.Product)<3 Then 'Remove'
	   else 'Keep'
	   end as Indicatore
From 
(select a.[channel ],a.Category,a.Product1 as Product,a.Campaign,a.start_date_Nr,a.end_date_Nr,a.per_product_spend ,a.FRIDAY_END_DATE,a.NO_OF_DAY
from #999 a
union all
select a.[channel ],a.Category,a.Product2 as Product,a.Campaign,A.start_date_Nr,a.end_date_Nr,a.per_product_spend ,a.FRIDAY_END_DATE,a.NO_OF_DAY
from #999 a
union all
select a.[channel ],a.Category,a.Product3 as Product,a.Campaign,a.start_date_Nr,a.end_date_Nr,a.per_product_spend,a.FRIDAY_END_DATE,a.No_Of_Days
from #999
) a) a
where a.Indicatore = 'Keep'
