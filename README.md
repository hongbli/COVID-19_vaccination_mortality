# Readme

Replicated codes and data for **Association of Covid-19 Vaccination with non-Covid-19 Mortality in China** by Dandan Zhang et al.

**Abstract**: Covid-19 vaccination uptake and non-Covid-19 mortality risk have not been well studied. With its zero-Covid practice for three years, China provides a unique opportunity for examining the impact of Covid-19 vaccination on non-Covid-19 mortality. Based on death records and Covid-19 vaccination data from the China Center for Disease Control and Prevention, we constructed monthly county-level panel data for December 2020 through January 2022, before any city-level outbreaks, such as those in Shanghai and Guangzhou. We used a fixed-effects model to quantify the impact of vaccination on non-Covid mortality. As of January 2022, China had vaccinated 88% of its population with the full dose, while the oldest (aged 80 and over) had the lowest vaccination rate, 58%. Our empirical results show that full-dose vaccination is negatively associated with mortality; an additional 10,000 people completing the full vaccination within a month could avert 1·07 non-Covid-19 deaths in a Chinese county. Our back-of-the-envelope calculation shows that 132,700 lives may have been saved from non-Covid-19 diseases due to the vaccination status in China; of these, 75% are aged ones. Covid-19 vaccination uptake was associated with a lower risk of non-Covid-19 mortality in China, with few infectious cases due to zero-Covid practices. The association was more pronounced in vulnerable populations, such as the oldest people and people in less developed regions. This result is due to other health interventions accompanying the vaccination campaign.

## Replication

**Software and Codes:** STATA 16.0 or above is recommended in running the following do-file:

vaccination_mortality.do

**Data:** all the data to replicate the results will be posted upon publication.

1. summarized_vac.dta & vac_pop.dta
   1. Figure2: monthly vaccination rate in China; monthly vaccination rate by age groups
2. vaccination_mortality_deidentified.dta (You may unzip the file first)
   1. Table1, Table2
   2. Figure3, FigureS1
   3. TableS1, TableS2, TableS3, TableS4

## Acknowledgments

In doing this project, we thank all the staff who work in the primary health facilities, hospitals, and Center for Disease Control and Prevention for death reporting at county/district, city, province, and national levels. 

Last update: 19th June 2023
