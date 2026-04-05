### Dataset description
The `lung` dataset in R's `survival` package is derived from a study in patients with advanced lung cancer in North Central Cancer Treatment Group, published in 1994. It contains the survival time (measured in days) and survival status (censored or death) of 228 participants along with 7 related variables.

### Key findings
* The mean of survival time was 305.23 days with considerable spread (the standard deviation was 210.65 days)
* There were more than 70% of participants having the event of interest (death) at the end of the observation period
* The study population mostly consisted of the old group ($\geq$ 60 years old) with the mean is 62.45 years old and standard deviation of 9.07
* There were more male participants (60.5%) than female participants (39.5%) in the study population
* The distributions of Karnofsky performance score were quite similar between scores rated by physician and scores rated by participant. The mean scores were 81.94 and 79.96, respectively and the standard deviations were 12.33 and 14.62, respectively. The scores rated by participants were slightly lower and slightly more spread than those rated by physician  

### Data quality
Overall, the data quality is good. There was only one variable having more than 10% of missing data which were the **Calories consumed at meals** (20.61%). There were 4 more variables having missing data, which were **ECOG** (0.44%), **Karnofsky performance score rated by physician** (0.44%), **Karnofsky performance score rated by participant** (1.32%), and **Weight loss in last six months** (6.14%).<br> 
Cautions should be made when using **Calories consumed at meals** as more than one-fifth of the data were missing <br> 
The key variables, **Survival time** and **Survival status**, were fully recorded without any missing data. **Age** and **Sex** were also fully recorded

### Visualisation
Both distributions of the censored and dead are right-skewed. However, most of the death cases were recorded around 150 days after participation while the censored cases highly recorded around 250 days after participation.

### Next step
After summarzing the data, the next step would be to identify the relationship between survival time and related variables as well as to identify any potential correlation between variables