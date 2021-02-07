SELECT X.thedate
	, X.todays_week
	, X.county + ', ' + X.STATE as [County/State]
	, x.county
	, x.state
	, pop.POPESTIMATE2019
	, MAX(X.CUMULATIVE_CASES) AS CUMULATIVE_CASES
	, MAX(X.CUMULATIVE_DEATHS) AS CUMULATIVE_DEATHS
	, SUM(X.NEW_CASES) AS NEW_CASES
	, SUM(X.NEW_DEATHS) AS NEW_DEATHS
	, SUM(X.NEW_CASES)/7 AS AVG_CASES_LAST_7
	, ISNULL(SUM(CONVERT(FLOAT,X.NEW_CASES)) / (NULLIF(CONVERT(FLOAT,POP.POPESTIMATE2019),0)/100000),0) AS NEW_CASES_PER_100K
	, ISNULL(MAX(CONVERT(FLOAT,X.CUMULATIVE_CASES)) / (NULLIF(CONVERT(FLOAT,POP.POPESTIMATE2019),0)/100000),0) AS TOTAL_CASES_PER_100K
	, ISNULL(SUM(CONVERT(FLOAT,X.NEW_CASES)/7) / (NULLIF(CONVERT(FLOAT,POP.POPESTIMATE2019),0)/100000),0) AS AVG_NEW_CASES_PER_100K
FROM (
select dateadd(d,-((datepart(dw,f.thedate)-datepart(dw,getdate()) % 7) + 7) % 7,f.thedate) as todays_week
	, f.thedate
	, f.country
	, f.state
	, f.county
	, CONVERT(FLOAT,CASES - ISNULL(LAG(CASES) OVER (PARTITION BY f.state,F.COUNTY ORDER BY THEDATE),0)) AS NEW_CASES
	, CASES AS CUMULATIVE_CASES
	, DEATHS - ISNULL(LAG(DEATHS) OVER (PARTITION BY f.state,F.COUNTY ORDER BY THEDATE),0) AS NEW_DEATHS
	, DEATHS AS CUMULATIVE_DEATHS		
from f_covid_data_complete f
WHERE F.STATE <> F.COUNTY
) X
join f_county_population pop
	on pop.county_base_name = X.county
	and pop.STNAME = X.state
WHERE 1=1
--	AND X.todays_week = CONVERT(DATE,dateadd(d,-((datepart(dw,GETDATE()-1)-datepart(dw,getdate()) % 7) + 7) % 7,GETDATE()-1))
	--AND X.STATE = 'MINNESOTA'
	--AND X.county = 'CARVER'
GROUP BY X.thedate
	, X.todays_week
	, X.state
	, X.county
	, POP.POPESTIMATE2019
ORDER BY TODAYS_WEEK,AVG_NEW_CASES_PER_100K DESC