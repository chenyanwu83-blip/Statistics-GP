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
