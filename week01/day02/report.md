## Report for Week 1 - Day 2
### Section 1: What are probability distributions?
To simplify, probability distribution is a model that describes all possible outcomes and their associated probability of occuring. Probability distribution can be presented in terms of table of values, function, or graph. The shape of the graph of the probability distribution can reveal some properties such as the central tendency (median, mode), variablility (high - heavy-tailed or low - light-tailed), and skewness (right or left or symmetrical).<br>
Based on the shape of the graph, biostatisticians can draw out the very first conclusion regarding the probability distribution such as which outcomes are likely to happen and which outcomes are not

### Section 2: Comparing the three distributions
Among the three generated distribution:
* The generated normal distribution and generated uniform distribution are symmetrical with the skewness is equal to zero. The skewness of the generated exponential distribution is 2.1, therefore, it is highly skewed to the right.
* The larger the skewness, the larger the distance between the mean and the median. With the generated exponential distribution, the skewness is 2.1, which means that the mean is largely greater than the median. With the generated generated normal distribution and generated uniform distribution, the skewness is zero, which means that the mean is equal to the median
* There are some biological phenomena related to each type of distribution: 
  * The normal distribution may be used to describe the height of the population
  * The exponential distribution may be used to describe the survival time until an event such as death or progression
  * The uniform distribution may be used to describe any phenomenon when we have no prior information and assume that any outcomes are equally likely to occur
### Section 3: Does the lung data follow a known distribution?
* Based on the fitted curves and the QQ plot, the exponential distribution fits the survival time better because:
  * The fitted central tendency and the skewness the normal distribution do not fit the actual shape of the distribution, the actual distribution is more right-skewed. In addition, the QQ plot against normal distribution also does not show a good fit with the reference line.
  * The shape of the fitted exponential curve better describe the skewness of the actual distribution. In the QQ plot, the points are better fit with the reference line
* In the QQ plots, both fits break down at the tail and the head. It means that the actual data differs from the fitted models at its extremes and there are more outliers.

### Section 4: Reflection
* Attention should be paid to the input and output of a function. Some functions only take the dataframe as the input, not the vector, and vice versa. Therefore, make sure that the correct data format is used
* There is one confusion with the QQ plot, with `ggplot2` library, the QQ plot can be created without specifying any further details about the reference distribution. Does `R` automatically compare the actual data with the best reference distribution? Further investigation should be performed

### Bonus: Weibull distribution
The Weibull distribution is a versatile probability distribution with shape parameter $k$ shape and scale parameter $\lambda$. It is commonly used in survival analysis because its shape parameter $k$ can model increasing, decreasing, or constant failure rates, allowing it to accurately fit diverse data types