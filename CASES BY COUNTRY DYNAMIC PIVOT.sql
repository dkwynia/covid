/* BOTTOM CREATES A QUERY USING THE LIST OF COUNTRIES IN THE VARIABLE @cols           */

DECLARE @cols AS NVARCHAR(MAX);
DECLARE @query AS NVARCHAR(MAX);
--creates a variable that contains the set of category names in use
SELECT @cols = STUFF(
       (SELECT DISTINCT ',' + QUOTENAME(country) 
       FROM (
              SELECT DISTINCT country
              FROM f_covid_data_complete f
			  where f.country in ('germany','italy','brazil', 'us')
       ) D 

FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)'),1,1, '');

--SELECT @cols

SELECT @QUERY = 
'
       SELECT PVT.*
	  -- INTO #TEMP_PVT
       FROM (
              SELECT F.THEDATE
                     , country
                     , SUM(F.CASES) AS CASES
              FROM f_covid_data_complete F
              WHERE 1=1                     
                     AND F.thedate >= ''2/23/2020''					 
              GROUP BY F.theDATE
				, country
       ) DATA
       PIVOT (sum(cases)
       FOR COUNTRY IN( ' + @cols + ')' + '
       ) AS PVT
       ORDER BY 1; 
'
EXECUTE(@query);


--SELECT * FROM #TEMP_PVT