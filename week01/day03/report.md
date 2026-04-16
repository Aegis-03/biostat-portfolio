## Report for Week 1 - Day 3
### Section 1: About NHANES
NHANES dataset is a subset of the data of a yearly survey conducted by the US National Center for Health Statistics (NCHS) since 1999. It contains 10,000 rows of data collected in 2009-2010 and 2011-2012 with 75 variables. <br>
It is useful for public health research because apart of survey questionnaires, it contains physical examinations and laboratory tests (blood/urine) to identify undiagnosed conditions. It also tracks the trends of disease prevalence nutritional status, and risk factors over decades. 

### Section 2: Key findings from the summary table
* The variable has the most missing data is the Total HDL cholesterol `TotChol` with 320 missing observations, accounting for 5.6%
* The most skewed variable is BMI with the skewness of 1.333. The positive skewness indicates that the distribution of BMI is highly right-skewed where the mean is largely greater than the median. The distribution of BMI might not be normal distribution.
* The variable has the most outliers by the 1.5 × IQR rule is BMI with 172 outliers. It can be explained that most of BMI value distributed around 25 kg/m² which is the normal BMI for adults. However, as the percentage of obesity in the US is quite high, there can be a lot of BMI values that are over 40 kg/m², which is the threshold for severe obesity. Therefore, the high number of BMI outliers is explainable

### Section 3: Gender differences
When we compare the Age, BMI, Combined Systolic blood pressure, Combined Diastolic blood pressure, and Total HDL cholesterol between 2 genders, no obvious differences can be noticed. The distributions between 2 genders are mostly overlap.<br>
According to this finding, physicians and public-health-related professionals should provide similar approaches for both genders, at least when facing blood pressure and cholesterol

### Section 4: BMI and age
* The LOESS curve plateaus with age. Therefor, when age increases, the BMI is not affected
* The trend is similar for both gender. The LOESS curves for both gender do not split apart, suggesting that BMI is not affected by gender
* The width of the confidence band for both genders is narrow, indicate high precision. However, it can be affected by the large sample size (over 5,000)

### Section 5: The value of a reusable function
Using reusable function brings a great advantage to biostatisticians. Of course it can reduce the amount of code by decreasing the repetition, leading to resources saving. In addtion, using reusable function also reduce the chance of mistakes associated with writing and/or pasting the same lines of code multiple times. Biostatisticians can fix the original function all apply it to all following cases.<br>
Personally, using reusable function is efficient in professional report

### Bonus: Shapiro-Wilk test
* With `BMI` The p-value is too small, suggesting that the Null Hypothesis of normal distribution is rejected. Therefor, `BMI` is not normally distributed.
* With `Age` The p-value is too small, suggesting that the Null Hypothesis of normal distribution is rejected. Therefor, `Age` is not normally distributed.
* With `BPSysAve` The p-value is too small, suggesting that the Null Hypothesis of normal distribution is rejected. Therefor, `BPSysAve` is not normally distributed.
* With `BPDiaAve` The p-value is too small, suggesting that the Null Hypothesis of normal distribution is rejected. Therefor, `BPDiaAve` is not normally distributed.
* With `TotChol` The p-value is too small, suggesting that the Null Hypothesis of normal distribution is rejected. Therefor, `TotChol` is not normally distributed.