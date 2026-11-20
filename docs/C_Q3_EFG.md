# Question 3 — Studies E–G

All tests use α = 0.05. Each study uses the complete set of records available in the named dataset for its analysis variables.

### Study E — Representation of public and private colleges

`Private` is a nominal variable with two categories. Each college is treated as an independent observation. Using all 777 colleges in ISLR2::College, a chi-square goodness-of-fit test compares the observed counts with a specified 50:50 split. The null hypothesis (H₀) assigns a probability of 0.5 to each category. The alternative (H₁) allows the probabilities to differ from 0.5.

**Table Q3-E. Observed and expected college counts**

| College type | Observed | Expected under H₀ |
| --- | ---: | ---: |
| Public | 212 | 388.5 |
| Private | 565 | 388.5 |

Both expected counts exceed 5. The test gave χ²(1) = 160.372, *p* < 0.001. We reject H₀. The data provide strong evidence against a 50:50 split. Private colleges account for 72.72% of the records.

[RStudio run for group verification](../figures/Q3_E_screenshot.png)

### Study F — College status and incoming student profile

`Private` and the High/Lower student profile are categorical variables. A college is classified as High if at least 50% of its incoming students were in the top 10% of their high school class. Using the same 777 colleges, we apply Pearson’s chi-square test of independence without Yates’ correction, treating colleges as independent observations. H₀ states that college status and student profile are independent. H₁ states that they are associated.

**Table Q3-F. Student profile by college type**

| College type | Lower | High | Percent High |
| --- | ---: | ---: | ---: |
| Public | 198 | 14 | 6.60% |
| Private | 496 | 69 | 12.21% |

The minimum expected count was 22.65. The test gave χ²(1) = 5.083, *p* = 0.024. We reject H₀. The proportion of colleges classified as High was 12.21% among private colleges and 6.60% among public colleges. Study E tests whether a single variable follows a specified distribution, while Study F tests for an association between two variables. Because this is an observational comparison, the difference cannot be attributed to private status alone. Admissions selectivity, for example, may also contribute.

[RStudio run for group verification](../figures/Q3_F_screenshot.png)
