SELECT C.thedate
	, dateadd(d,-((datepart(dw,c.thedate)-datepart(dw,getdate()) % 7) + 7) % 7,c.thedate) as theweek
	, C.country
	, CASE WHEN DATEDIFF(D,MD.MINDATE,C.THEDATE) >= 0 THEN DATEDIFF(D,MD.MINDATE,C.THEDATE)+1  ELSE NULL END AS DAYNUMBER
	, CASES - ISNULL(LAG(CASES) OVER (PARTITION BY C.COUNTRY ORDER BY THEDATE),0) AS NEW_CASES
	, CASES AS CUMULATIVE_CASES
	, DEATHS - ISNULL(LAG(DEATHS) OVER (PARTITION BY C.COUNTRY ORDER BY THEDATE),0) AS NEW_DEATHS
	, DEATHS AS CUMULATIVE_DEATHS
	, W.POPULATION_2020
FROM (select 
		d.thedate		
		, case when c.[Country Name] is null then d.country else c.[Country Name] end as country
		, sum(d.cases) as cases
		, sum(d.deaths) as deaths
	from f_covid_data_complete d 
	left join d_country_names c 
		on c.Entry = d.country
	where (state <> 'Diamond Princess' or state is null)
	group by d.thedate
		,case when c.[Country Name] is null then d.country else c.[Country Name] end	
) C
JOIN ( --GET THE FIRST DATE TO COUNT FOR EACH STATE 
		SELECT 
			MIN(F.thedate) AS MINDATE
			, case when c.[Country Name] is null then F.country else c.[Country Name] end as country		 
			FROM f_covid_data_complete F	
			left join d_country_names c 
				on c.Entry = F.country
			WHERE CASES > 4
			GROUP BY case when c.[Country Name] is null then F.country else c.[Country Name] end
) MD
ON MD.COUNTRY = C.COUNTRY	
LEFT JOIN (SELECT case when c.[Country Name] is null then W.COUNTRY_NAME else c.[Country Name] end as country
	, W.POPULATION_2020
	FROM F_WORLD_POPULATION W
	LEFT JOIN d_country_names C
		ON C.Entry = W.COUNTRY_NAME
) W
	ON W.COUNTRY = C.country
WHERE CASE WHEN DATEDIFF(D,MD.MINDATE,C.THEDATE) >= 0 THEN DATEDIFF(D,MD.MINDATE,C.THEDATE)+1  ELSE NULL END IS NOT NULL

ORDER BY COUNTRY, DAYNUMBER
