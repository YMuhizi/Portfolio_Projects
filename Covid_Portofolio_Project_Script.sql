SELECT *
FROM Portifolio_Project..Covid_Deaths
ORDER BY 3,4

--SELECT *
--FROM Portifolio_Project..Covid_Vaccinations
--ORDER BY 3,4

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM Portifolio_Project..Covid_Deaths
ORDER BY 1,2

-- Looking at total deaths vs total cases
-- shows the likelihood of dying

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Portifolio_Project..Covid_Deaths
WHERE location LIKE '%india%'
ORDER BY 1,2

-- looking at the total cases vs population
-- shows what perentage of population has got covid 
SELECT location, date, total_cases, population, (total_cases/population)*100 AS likelihood
FROM Portifolio_Project..Covid_Deaths
WHERE location LIKE '%Rwanda%'
ORDER BY 1,2

-- looking at countries with highest infection rate vs population

SELECT location, population, MAX(total_cases) AS Highset_Infection_Count, MAX((total_cases/population))*100 AS likelihood
FROM Portifolio_Project..Covid_Deaths
WHERE location LIKE '%Rwanda%'
GROUP BY location, population
ORDER BY likelihood DESC

-- Looking at highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM Portifolio_Project..Covid_Deaths
--WHERE location LIKE '%Rwanda%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Total_Death_Count DESC

-- breaking things down to continent

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM Portifolio_Project..Covid_Deaths
--WHERE location LIKE '%Rwanda%'
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Across the world

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths
FROM Portifolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

-- percentage of deaths across the world 

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM Portifolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

-- Overall 

SELECT  SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM Portifolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

-- Looking at total population vs total vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY  dea.location, dea.date) AS Rolling_People_Vaccinated 
FROM Portifolio_Project..Covid_Deaths AS dea
 JOIN  Portifolio_Project..Covid_Vaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 

-- by using CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY  dea.location, dea.date) AS Rolling_People_Vaccinated 
FROM Portifolio_Project..Covid_Deaths AS dea
 JOIN  Portifolio_Project..Covid_Vaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (Rolling_People_Vaccinated/population)*100 
FROM PopvsVac


-- Creating view to store data for visualization

CREATE VIEW Percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY  dea.location, dea.date) AS Rolling_People_Vaccinated 
FROM Portifolio_Project..Covid_Deaths AS dea
 JOIN  Portifolio_Project..Covid_Vaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM Percent_population_vaccinated