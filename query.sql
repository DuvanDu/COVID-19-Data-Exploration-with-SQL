-- ============================================================
-- COVID-19 DATA EXPLORATION
-- Skills used: Joins, CTEs, Temp Tables, Windows Functions,
--              Aggregate Functions, Creating Views, 
--              Converting Data Types
-- ============================================================


-- ============================================================
-- 1. INITIAL DATA EXPLORATION
-- ============================================================

SELECT * 
FROM coviddeaths 
ORDER BY 3, 4;

SELECT * 
FROM covidvaccinations 
ORDER BY 3, 4;

-- Select the core columns we are going to be working with
SELECT 
    country, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population 
FROM coviddeaths 
ORDER BY 1, 2;


-- ============================================================
-- 2. TOTAL CASES VS TOTAL DEATHS
-- Shows the likelihood of dying if you contracted COVID in Colombia
-- ============================================================

SELECT 
    country, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths / NULLIF(total_cases, 0)) * 100 AS death_percentage
FROM coviddeaths
WHERE country LIKE '%Colombia%'
ORDER BY 1, 2;


-- ============================================================
-- 3. TOTAL CASES VS POPULATION
-- Shows the percentage of Colombia's population that got COVID
-- ============================================================

SELECT 
    country, 
    date, 
    total_cases, 
    population, 
    (total_cases / NULLIF(population, 0)) * 100 AS infected_percentage
FROM coviddeaths
WHERE country LIKE '%Colombia%'
ORDER BY 1, 2;


-- ============================================================
-- 4. COUNTRIES WITH THE HIGHEST INFECTION RATE VS POPULATION
-- ============================================================

SELECT 
    country, 
    population, 
    MAX(total_cases) AS highest_infection_count, 
    MAX((total_cases) / NULLIF(population, 0)) * 100 AS percentage_population_infected
FROM coviddeaths
GROUP BY country, population
ORDER BY 4 DESC NULLS LAST;


-- ============================================================
-- 5. COUNTRIES WITH THE HIGHEST DEATH COUNT VS POPULATION
-- ============================================================

SELECT 
    country, 
    population, 
    MAX(total_deaths) AS total_death_count, 
    MAX(total_deaths / NULLIF(population, 0)) * 100 AS percentage_population_death
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY country, population
ORDER BY 3 DESC NULLS LAST;


-- ============================================================
-- 6. CONTINENTS WITH THE HIGHEST DEATH COUNT VS POPULATION
-- ============================================================

SELECT 
    continent,
    MAX(total_deaths) AS total_death_count, 
    MAX(total_deaths / NULLIF(population, 0)) * 100 AS percentage_population_death
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC NULLS LAST;


-- ============================================================
-- 7. GLOBAL AGGREGATES WITH THE HIGHEST DEATH COUNT
-- (When continent IS NULL, country column holds global aggregates
--  such as continents, income groups and world totals)
-- ============================================================

SELECT 
    country,
    MAX(total_deaths) AS total_death_count, 
    MAX(total_deaths / NULLIF(population, 0)) * 100 AS percentage_population_death
FROM coviddeaths
WHERE continent IS NULL
GROUP BY country
ORDER BY 2 DESC NULLS LAST;


-- ============================================================
-- 8. GLOBAL NUMBERS
-- ============================================================

-- Overall global totals: ~1% of all infected people died from COVID-19
SELECT 
    SUM(new_cases)                                    AS total_cases,
    SUM(new_deaths)                                   AS total_deaths, 
    SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1;

-- Daily global numbers: new cases, deaths and death rate per day worldwide
SELECT 
    date,
    SUM(new_cases)                                    AS total_cases,
    SUM(new_deaths)                                   AS total_deaths, 
    SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;


-- ============================================================
-- 9. TOTAL POPULATION VS VACCINATIONS
-- Rolling cumulative vaccination count per country over time
-- ============================================================

SELECT 
    dea.continent, 
    dea.country, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.country 
        ORDER BY dea.date
    ) AS rolling_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON  dea.country = vac.country
    AND dea.date    = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- ============================================================
-- 10. POPULATION VS VACCINATIONS PERCENTAGE (CTE)
-- Uses a CTE to calculate vaccination percentage from rolling total
-- ============================================================

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.country, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dea.country 
            ORDER BY dea.date
        ) AS rolling_vaccinations
    FROM coviddeaths dea
    JOIN covidvaccinations vac
        ON  dea.country = vac.country
        AND dea.date    = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, 
    (rolling_vaccinations / NULLIF(population, 0)) * 100 AS vaccination_percentage
FROM PopvsVac
ORDER BY 2, 3;


-- ============================================================
-- 11. POPULATION VS VACCINATIONS PERCENTAGE (TEMP TABLE)
-- Same as above but using a Temp Table for reusability
-- ============================================================

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMP TABLE PercentPopulationVaccinated (
    continent            VARCHAR,
    country              VARCHAR,
    date                 DATE,
    population           BIGINT,
    new_vaccinations     NUMERIC,
    rolling_vaccinations NUMERIC
);

INSERT INTO PercentPopulationVaccinated
    SELECT 
        dea.continent, 
        dea.country, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dea.country 
            ORDER BY dea.date
        ) AS rolling_vaccinations
    FROM coviddeaths dea
    JOIN covidvaccinations vac
        ON  dea.country = vac.country
        AND dea.date    = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 2, 3;

SELECT *, 
    (rolling_vaccinations / NULLIF(population, 0)) * 100 AS vaccination_percentage
FROM PercentPopulationVaccinated
ORDER BY 2, 3;


-- ============================================================
-- 12. CREATE VIEW FOR VISUALIZATIONS
-- Stores rolling vaccination data for use in dashboards/reports
-- ============================================================

CREATE OR REPLACE VIEW PercentagePopulationVaccinated AS
    SELECT 
        dea.continent, 
        dea.country, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dea.country 
            ORDER BY dea.date
        ) AS rolling_vaccinations
    FROM coviddeaths dea
    JOIN covidvaccinations vac
        ON  dea.country = vac.country
        AND dea.date    = vac.date
    WHERE dea.continent IS NOT NULL;

-- Query the view
SELECT * FROM PercentagePopulationVaccinated
ORDER BY 2, 3;