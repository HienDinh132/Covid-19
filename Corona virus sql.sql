SET ANSI_WARNINGS OFF
Select * from CovidDeath
-- Xem qua tổng quát dữ liệu

Select continent as N'Châu lục', Location as N'Quốc gia',
DATEFROMPARTS(YEAR(date), Month(date), Day(date)) as date, 
total_cases as N'Tổng số ca', new_cases as N'Số ca mới', 
total_deaths as N'Số ca chết', population as N'Tổng dân số',
Concat(Cast(Isnull(Round((total_cases/population)*100 ,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ mắc bệnh',
Concat(Cast(Isnull(round((total_deaths/total_cases)*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết'
From dbo.CovidDeath
Where continent is Not Null
Order by location, date

-- Tổng quát dữ liệu theo châu lục

Select continent as [Châu lục], Max(total_cases) as [Tổng số ca], Max(Total_deaths) as [Tổng số chết],
Concat(Cast(Round((Max(Total_deaths)/Max(total_cases)) * 100,2) as varchar(20)), ' ', '%') as [Tỉ lệ qua đời]
From CovidDeath
Where continent is not Null
Group by continent

-- Tỉ lệ nhiễm bệnh cao nhất theo từng quốc gia

Select location as [Quốc gia], population as [Dân số], Max(total_cases) as [Số ca mắc bệnh], Max(total_deaths) as [Số ca chết],
Concat(Cast(Isnull(Round(Max((total_cases/population)) * 100,2),0) as varchar(10)), ' ', '%') as [Tỉ lệ nhiễm bệnh cao nhất]
From CovidDeath
Where continent is Not Null
Group by location, population
Order by Max((total_cases/population)) desc

-- Thống kê tình hình dịch bệnh Covid theo tháng và từng quốc gia

Create or Alter procedure coviddeath1
@factor varchar(50), @location varchar(50) ='def'
as
If @factor = 'Total'
Begin
	With a
	AS
	(
	Select Location as N'Quốc gia', 
	DATEFROMPARTS(YEAR(date), Month(date), 1) as N'Tháng', 
	Max(total_cases) as N'Tổng số ca', Sum(new_cases) as N'Số ca mới', 
	Max(total_deaths) as N'Số ca chết',
	Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết',
	Sum(new_deaths) as N'Số ca chết mới'
	From dbo.CovidDeath
	Where continent is Not Null
	Group by Location, DATEFROMPARTS(YEAR(date), Month(date), 1)
	)
	,
	b
	as
	(
	Select [Quốc gia], [Tháng], [Tổng số ca], [Tỉ lệ chết],
	LAG([Tổng số ca],1,0) Over (Partition by [Quốc gia] Order by [Tháng]) as N'Tổng số ca tháng trước',
	LAG([Số ca chết],1,0) Over (Partition by [Quốc gia] Order by [Tháng]) as N'Số ca chết tháng trước',
	[Số ca mới], [Số ca chết], [Số ca chết mới]
	From a
	)

	Select b.[Quốc gia], b.[Tháng], b.[Tổng số ca], b.[Tổng số ca tháng trước],
	Concat(Cast(Round((([Tổng số ca] - [Tổng số ca tháng trước])/[Tổng số ca tháng trước])*100,2) as varchar(20)), ' ', '%') as N'Phần trăm gia tăng tỉ lệ mắc bệnh',
	--Sum(b.[Tổng số ca]) over(Partition by b.[Quốc gia] order by b.[Tháng]) as N'Tổng số ca lũy kế',
	b.[Số ca mới], Sum(b.[Số ca mới]) Over(Partition by b.[Quốc gia] Order by b.[Tháng]) as N'Số ca mới lũy kế',
	b.[Số ca chết], b.[Số ca chết tháng trước], ([Số ca chết] - [Số ca chết tháng trước]) as N'Số ca chết mới',
	--Sum(b.[Số ca chết mới]) Over(Partition by b.[Quốc gia] Order by b.[Tháng]) as N'Số ca chết lũy kế',
	Concat(Cast(Round((([Số ca chết] - [Số ca chết tháng trước])/[Số ca chết tháng trước])*100,2) as varchar(20)), ' ', '%') as N'Phần trăm gia tăng số ca chết',
	b.[Tỉ lệ chết]
	From b
	Where b.[Tổng số ca tháng trước] is not NUll and b.[Tổng số ca tháng trước] <> 0
	Order by b.[Quốc gia]
End
Else If @factor = 'Country'
Begin
	With a
	AS
	(
	Select Location as N'Quốc gia', 
	DATEFROMPARTS(YEAR(date), Month(date), 1) as N'Tháng', 
	Max(total_cases) as N'Tổng số ca', Sum(new_cases) as N'Số ca mới', 
	Max(total_deaths) as N'Số ca chết',
	Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết',
	Sum(new_deaths) as N'Số ca chết mới'
	From dbo.CovidDeath
	Where continent is Not Null
	Group by Location, DATEFROMPARTS(YEAR(date), Month(date), 1)
	)
	,
	b
	as
	(
	Select [Quốc gia], [Tháng], [Tổng số ca], [Tỉ lệ chết],
	LAG([Tổng số ca],1,0) Over (Partition by [Quốc gia] Order by [Tháng]) as N'Tổng số ca tháng trước',
	LAG([Số ca chết],1,0) Over (Partition by [Quốc gia] Order by [Tháng]) as N'Số ca chết tháng trước',
	[Số ca mới], [Số ca chết], [Số ca chết mới]
	From a
	)

	Select b.[Quốc gia], b.[Tháng], b.[Tổng số ca], b.[Tổng số ca tháng trước],
	Concat(Cast(Round((([Tổng số ca] - [Tổng số ca tháng trước])/[Tổng số ca tháng trước])*100,2) as varchar(20)), ' ', '%') as N'Phần trăm gia tăng tỉ lệ mắc bệnh',
	--Sum(b.[Tổng số ca]) Over(Partition by b.[Quốc gia] Order by b.[Tháng]) as N'Tổng số ca lũy kế',
	b.[Số ca mới], Sum(b.[Số ca mới]) Over(Partition by b.[Quốc gia] Order by b.[Tháng]) as N'Số ca mới lũy kế',
	b.[Số ca chết], b.[Số ca chết tháng trước], ([Số ca chết] - [Số ca chết tháng trước]) as N'Số ca chết mới',
	--Sum(b.[Số ca chết mới]) Over(Partition by b.[Quốc gia] Order by b.[Tháng]) as N'Số ca chết lũy kế',
	Concat(Cast(Round((([Số ca chết] - [Số ca chết tháng trước])/[Số ca chết tháng trước])*100,2) as varchar(20)), ' ', '%') as N'Phần trăm gia tăng số ca chết',
	b.[Tỉ lệ chết]
	From b
	Where b.[Tổng số ca tháng trước] is not NUll and b.[Tổng số ca tháng trước] <> 0
	and b.[Quốc gia] = @location
End
Go
Exec coviddeath1 @factor = 'Country', @location = 'Denmark'

-- Thống kê dữ liệu covid theo từng quốc gia và thời gian

Create or Alter Procedure covid
@date1 date,
@date2 date,
@input_country varchar(50)
as
Select Location as N'Quốc gia', 
DATEFROMPARTS(YEAR(date), Month(date), 1) as N'Tháng', 
Max(total_cases) as N'Tổng số ca', Sum(new_cases) as N'Số ca mới', 
Max(total_deaths) as N'Số ca chết',
Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết'
From dbo.CovidDeath as c
Where continent is Not Null
and (c.date between @date1 and @date2)
and c.location = @input_country
Group by Location, DATEFROMPARTS(YEAR(date), Month(date), 1)
Go
Exec covid @date1 = '2020-04-01', @date2 = '2022-12-01', @input_country = 'Vietnam'

-- Truy xuất quốc gia có top tỉ lệ chết theo yêu cầu

Create or Alter Procedure top_ti_le_chet
@rank int
as
Select t2.location, t2.[Tỉ lệ chết], t2.[rank]
From
(
Select *, Rank() Over(Order by [Tỉ lệ chết] desc) as [rank]
From
(
Select c.location, Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,5),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết' 
From CovidDeath as c
Group by c.location ) t1) t2
Where [rank] = @rank 
Go
Exec top_ti_le_chet @rank = 1

-- Truy xuất dữ liệu dịch bệnh theo tháng của từng năm theo quốc gia hay khu vực bất kỳ 

Create or Alter Procedure continent_location
@year int, @factor_group_by varchar(50), @continent varchar(50) = 'abc', @location varchar(50) ='def'
as
If @factor_group_by = 'continent'
	Begin
		Select *
		From
		(
		Select c.continent as N'Khu vực', DATEFROMPARTS(Year(c.date), Month(c.date),1) as N'Tháng',
		Max(total_cases) as N'Tổng số ca', Sum(new_cases) as N'Số ca mới', 
		Max(total_deaths) as N'Số ca chết',
		Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết'
		From CovidDeath as c
		Where Year(c.date) = @year
		Group by c.continent, DATEFROMPARTS(Year(c.date), Month(c.date),1)) t1
		Where t1.[Khu vực] = @continent
	End
Else if @factor_group_by = 'location'
	Begin
		Select *
		From
		(
		Select c.location as N'Quốc gia', DATEFROMPARTS(Year(c.date), Month(c.date),1) as N'Tháng',
		Max(total_cases) as N'Tổng số ca', Sum(new_cases) as N'Số ca mới', 
		Max(total_deaths) as N'Số ca chết',
		Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết'
		From CovidDeath as c
		Where Year(c.date) = @year
		Group by c.location, DATEFROMPARTS(Year(c.date), Month(c.date),1)) t1
		Where t1.[Quốc gia] = @location
	End
Go
Exec continent_location @year = 2021, @factor_group_by = 'continent', @continent = 'Europe'

-- So sánh tỉ lể chết của 2 quốc gia hoặc 2 khu vực bất kỳ trong khoảng thời gian nhất định

Create or Alter Procedure sosanh
@location as varchar(20) = 'abc', @continent varchar(50) = 'abc', @factor_group_by varchar(50), @date1 date, @date2 date
as
If @factor_group_by = 'location'
	Begin
		Select c.location as N'Quốc gia', Sum(total_cases) as N'Tổng số ca', Sum(new_cases) as N'Số ca mới', 
		Sum(total_deaths) as N'Số ca chết',
		Concat(Cast(Isnull(Round((Sum(total_deaths)/Sum(total_cases))*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết'
		From CovidDeath as c
		Where c.date between @date1 and @date2
		and c.location in (Select Value From string_split(@location, '|'))
		Group by c.location
	End
Else If @factor_group_by = 'continent'
	Begin
		Select c.continent as N'Khu vực', Max(total_cases) as N'Tổng số ca', Sum(new_cases) as N'Số ca mới', 
		Max(total_deaths) as N'Số ca chết',
		Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as N'Tỉ lệ chết'
		From CovidDeath as c
		Where c.date between @date1 and @date2
		and c.continent in (Select Value From string_split(@continent, '|'))
		Group by c.continent
	End
Go
Exec sosanh @date1 = '2020-05-07', @date2 = '2021-08-12', @factor_group_by = 'location', @location = 'India|China'

-- Truy xuất dữ liệu theo khu vực hay quốc gia với mốc thời gian tùy ý

Create or Alter procedure time_covid @factor1 varchar(50) = 'location', @factor2 varchar(50) = 'abc'
as
declare @sql nvarchar(max)
If @factor2 = 'D'
Begin
	Set @sql = 
	'Select '+ @factor1 +', Datefromparts(Year(date), Month(date), Day(date)) as Date, Max(total_cases) as [Total Cases], Sum(new_cases) as [New cases], 
	Max(total_deaths) as [Total deaths],
	Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),'' '', ''%'') as [Death rate]
	From CovidDeath
	Where continent is not Null
	Group by '+ @factor1 +', date
	Order by '+ @factor1 +' Asc, date Asc'
End
Else If @factor2 = 'M'
Begin
	Set @sql = 
	'Select '+ @factor1 +', Datefromparts(Year(date), Month(date), 1) as [Month], Max(total_cases) as [Total Cases], Sum(new_cases) as  [New cases], 
	Max(total_deaths) as [Total deaths],
	Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),'' '', ''%'') as [Death rate]
	From CovidDeath
	Where continent is not Null
	Group by '+ @factor1 +', Datefromparts(Year(date), Month(date), 1)
	Order by '+ @factor1 +' Asc, Datefromparts(Year(date), Month(date), 1) Asc'
End
Else If @factor2 = 'Y'
Begin
	Set @sql = 
	'Select '+ @factor1 +', Year(date) as [Year], Max(total_cases) as [Total Cases], Sum(new_cases) as [New cases], 
	Max(total_deaths) as [Total deaths],
	Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),'' '', ''%'') as [Death rate]
	From CovidDeath
	Where continent is not Null
	Group by '+ @factor1 +', Year(date)
	Order by '+ @factor1 +' Asc, Year(date) Asc'
End
Exec(@sql)
Go
Exec time_covid @factor1 = 'location', @factor2 = 'Y'

-- Truy xuất dữ liệu theo quốc gia và năm với tỉ lệ chết vượt hơn mức định trước

Create or Alter Function
table1(@year int, @deathrate float, @location varchar(50))
returns table as return
(Select location as Country, Datefromparts(Year(date), Month(date), Day(date)) as Date,
Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as [Death rate]
From CovidDeath
Where Year(date) = @year
and location = @location
and Round((total_deaths/total_cases)*100,2) >= @deathrate
Group by location, date
)
Go
Select * from dbo.table1(2021, 3.19, 'Germany')

-- Tạo ra các bảng phụ theo tháng của từng năm thống kê tình hình Covid giữa các Quốc gia

declare @date date = (Select Min(DATEFROMPARTS(Year(date), Month(date),1)) From CovidDeath)
declare @tablename varchar(max)
declare @sql_create varchar(max)
declare @sql_delete varchar(max)

while @date <= (Select Max(DATEFROMPARTS(Year(date), Month(date),1)) From CovidDeath)
Begin
	Set @tablename = 'Covid_Deate_' + replace(cast(@date as varchar(20)), '-', '_')
	;
	Set @sql_create =
	'Select * into '+ @tablename +' From
	(Select location as Country,
	DATEFROMPARTS(Year(date), Month(date), 1) as [Month],
	Max(total_cases) as [Total case], sum(new_cases) as [New cases], 
	Max(total_deaths) as [Total deaths],
	Concat(Cast(Isnull(round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),'' '', ''%'') as [Death rate]
	From CovidDeath as c
	Where DATEFROMPARTS(Year(date), Month(date), 1) = '''+Cast(@date as varchar(20))+'''
	Group by c.location, DATEFROMPARTS(Year(date), Month(date), 1)) as t1'
	;
	Set @sql_delete = 'Drop table if exists ' + @tablename
	;
	Exec(@sql_create)
	;
	Set @date = DATEADD(month, 1, @date)
End

-- Tổng số ca mắc theo từng quốc gia và trả lại tháng có tỉ lệ chết cao nhất

declare @location varchar(max)
declare @rank int = 1
declare @total float
declare @death float
declare @month date
declare @rate varchar(max)

Create table Covid1 
(
	Location varchar(20),
	[Month with Top 1 death rate] date,
	[Top 1 Death rate] varchar(20),
	[Total cases] float,
	[Total deaths] float
	)

while @rank <=(Select Count(Distinct location) From CovidDeath)
Begin
	--1. Gắn dữ liệu cho biến @location
	Set @location =
	(Select location
	From(
	Select *, Rank() Over (Order by location asc) as rank_
	From(
	Select Distinct(location)
	From CovidDeath) as t1) as t2
	Where rank_ = @rank)

	--2. Tính tổng số ca của từng location
	Set @total =
	(Select Max(total_cases) as [Tổng số ca]
	From CovidDeath
	Where location = @location)

	--3. Tính tổng số ca chết của từng location
	Set @death =
	(Select Max(total_deaths) as [Tổng số ca chết]
	From CovidDeath
	Where location = @location)

	--4. Tháng có tỉ lệ chết cao nhất
	Set @month =
	(
	Select [Tháng]
	From
	(Select Top 1 DATEFROMPARTS(Year(date), Month(date),1) as [Tháng],
	Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as [Tỉ lệ chết]
	From CovidDeath
	Where location = @location
	Group by DATEFROMPARTS(Year(date), Month(date),1)
	Order by [Tỉ lệ chết] desc) as t1)

	--5. Tỉ lệ chết cao nhất tương ứng của tháng và quốc gia
	Set @rate =
	(Select Concat(Cast(Isnull(Round((Max(total_deaths)/Max(total_cases))*100,2),0) as varchar(10)),' ', '%') as [Tỉ lệ chết]
	From CovidDeath
	Where location = @location and DATEFROMPARTS(Year(date), Month(date),1) = @month)

	Insert Into Covid1 Values(@location, @month, @rate, @total, @death)
	;
	Print('Total cases of ' + @location + ' is ' + cast(@total as varchar(max)) + ' , total deaths is ' + cast(@death as varchar(max)) + '. The month which death rate is top 1: '
	+ cast(@month as varchar(50)) + ' respectively ' + @rate)
	;
	Set @rank = @rank + 1
End
Go
Select * from Covid1
Drop table if exists Covid1

--- Tình trạng tiêm Vaccine ở các quốc gia

Create or Alter procedure vaccine1 @factor1 varchar(50) = 'abc', @location varchar(50) = 'def'
as
	Drop Table if exists #Ti_le_tiem_vaccine
	Create Table #Ti_le_tiem_vaccine
	(
	Continent varchar(50),
	Location varchar(50),
	Date date,
	Population float,
	New_vaccinations float,
	RollingPeopleVaccinated float
	)
If @factor1 = 'Total'
Begin
	Insert into #Ti_le_tiem_vaccine
	Select d.continent, d.location, d.date, d.population, c.new_vaccinations,
	Sum(c.new_vaccinations) Over(Partition by d.location Order by d.location, d.Date) as [RollingPeopleVaccinated]
	From CovidDeath as d
	Inner Join CovidVaccination as c
	on d.location = c.location and d.date = c.date
	Where d.continent is not null
	;
	Select *,
	Concat(Cast(Round(([RollingPeopleVaccinated]/Population)* 100,5) as varchar(20)), ' ', '%') as [Vaccinated rate]
	From #Ti_le_tiem_vaccine
	Where New_vaccinations is not NUll
	order by 2,3
End
Else if @factor1 = 'Location'
Begin
	Insert into #Ti_le_tiem_vaccine
	Select d.continent, d.location, d.date, d.population, c.new_vaccinations,
	Sum(c.new_vaccinations) Over(Partition by d.location Order by d.location, d.Date) as [RollingPeopleVaccinated]
	From CovidDeath as d
	Inner Join CovidVaccination as c
	on d.location = c.location and d.date = c.date
	Where d.continent is not null 
	;
	Select *,
	Concat(Cast(Round(([RollingPeopleVaccinated]/Population)* 100,5) as varchar(20)), ' ', '%') as [Vaccinated rate]
	From #Ti_le_tiem_vaccine
	Where New_vaccinations is not NUll and location = @location
	order by 2,3
End
Go
Exec vaccine1 @factor1 = 'Location', @location = 'South Korea'

--- Tạo view 

Create View Covid_rolling_vaccine as
Select d.continent, d.location, d.date, d.population, c.new_vaccinations,
Sum(c.new_vaccinations) Over(Partition by d.location Order by d.location, d.Date) as [RollingPeopleVaccinated]
From CovidDeath as d
Inner Join CovidVaccination as c
on d.location = c.location and d.date = c.date
Where d.continent is not null


--- Star Schema Power BI
--- Dim Territory
Select distinct iso_code, location , continent
From CovidDeath
Where continent is not null
Group by iso_code, location , continent

--- Dim Units
Select distinct tests_units,
				Case When tests_units = 'tests performed' Then 1
					When tests_units = 'samples tested' Then 2
					When tests_units = 'units unclear' Then 3
					When tests_units = 'people tested' Then 4
					Else 5
				End as key_units
From CovidVaccination

--- Dim Demographic
Select d.iso_code, avg(d.population) as population, round(avg(v.population_density),2) as population_density, 
round(avg(v.median_age),2) as median_age, round(avg(v.aged_65_older),2) as older65, round(avg(v.aged_70_older),2) as older70, 
round(avg(gdp_per_capita),2) as gdp_per_capita, round(avg(v.cardiovasc_death_rate),2) as cardiovasc_death_rate
, round(avg(v.diabetes_prevalence),2) as diabetes_prevalence, round(avg(v.life_expectancy),2) as life_expectancy, 
round(avg(v.human_development_index),2) as human_development_index
From CovidDeath as d
Inner Join CovidVaccination as v
on d.iso_code = v.iso_code and d.date = v.date
Group by d.iso_code

--- Fact Covid Death
Select d.iso_code, d.date, d.total_cases, d.new_cases, d.total_deaths, d.new_deaths, d.icu_patients, d.hosp_patients, v.hospital_beds_per_thousand
From CovidDeath as d
Inner Join CovidVaccination as v
On d.iso_code = v.iso_code and d.date = v.date
Where d.continent is not null

--- Fact Covid Vaccination
Select iso_code, date, total_tests, new_tests, total_vaccinations, people_vaccinated, people_fully_vaccinated,
Case When tests_units = 'tests performed' Then 1
	 When tests_units = 'samples tested' Then 2
	 When tests_units = 'units unclear' Then 3
	 When tests_units = 'people tested' Then 4
	 Else 5
End as key_units
From CovidVaccination
Where continent is not null 