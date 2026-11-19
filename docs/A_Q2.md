# A：Q2小鸡饲料ANOVA报告文字

状态：已完成（2026-11-19）。图见 figures/Q2-1_boxplot.png（正文图）、figures/Q2-2_qqplot.png（正文图）；代码见 scripts/02_A_Q1_Q2.R。

## Question 2: Which Feed Helps Chicks Grow?

The chickwts dataset is complete with 71 observations and no missing values on either variable. All 71 chicks were retained in the analysis; the residual degrees of freedom (65 = 71 - 6) confirm that the full sample entered the model.

### (a) Hypotheses and assumptions

Define μ_i is the population mean of the body weight of chicks after six weeks of being fed the feed i (i = casein, horsebean, linseed, meatmeal, soybean, sunflower).

H0: μ1 = μ2 = μ3 = μ4 = μ5 = μ6
Ha: At least one feed has a different population mean. (α = 0.05)

Three main assumptions apply.

Independence: The observations should not influence one another, within or between groups. This assumption is supported by the study design rather than by a statistical test: newly hatched chicks were randomly allocated to the six feed groups, and each chick is an independent experimental unit.

Normality: The weights within each feed group should be approximately normally distributed. This is assessed from the data: a Shapiro–Wilk test on the ANOVA residuals gives W = 0.986, p = 0.627, and the residual Q–Q plot (Figure Q2-2) shows the points lying close to the reference line with no systematic departure. Approximate normality is therefore reasonable.

Homogeneity of variance: The six population variances should be equal. This is checked with Levene's test centred on group medians (the default in the car package), F(5, 65) = 0.749, p = 0.590; the mean-centred version gives F = 0.987, p = 0.432, with the same conclusion. Neither version rejects equal variances.

All three assumptions are acceptable, so a one-way ANOVA is appropriate for these data.

### (b) Plot, ANOVA table and decision

Table Q2-1: One-way ANOVA of six-week chick weight by feed supplement.

Source | df | SS | MS | F | p
Feed | 5 | 231129 | 46226 | 15.365 | < 0.001
Residuals | 65 | 195556 | 3009 | |
Total | 70 | 426685 | | |

Figure Q2-1 (labelled boxplot of weight by feed) shows the highest weights under casein and sunflower and clearly lower weights under horsebean. The one-way ANOVA table (Table Q2-1) gives SS(feed) = 231129 on 5 df, SS(residuals) = 195556 on 65 df, MS(feed) = 46226, MS(residuals) = 3009, F(5, 65) = 15.365 with p < 0.001. Since p < 0.05 we reject H0 and conclude that the six feed types do not all have the same population mean chick weight after six weeks; feed explains about 54.2% of the variation in weight (R² = SS(feed)/SS(total) = 231129/426685 = 0.542). Which particular feeds differ would require post-hoc comparisons, which are beyond the required scope.

### (c) Interpretation of the claim

This argument does not hold. A significant ANOVA F-test is an omnibus result: it only rejects the null hypothesis that "all six population means are equal," establishing that "at least one feed is different," but it does not establish that "each feed is different from every other feed." For example, a data pattern where "five feeds share the same mean and only one is lower" would also yield a significant F-statistic.

The highest sample mean does not imply that it is significantly superior to all other groups: sunflower (328.9 g) exceeded casein (323.6 g) by only 5.3 g, while the standard error of the difference between the two group means is approximately 22 g, which is a gap that is far from significant.

A reliable conclusion that can be drawn from this analysis is that the average weights of the six feeds are not all equal (F(5, 65) = 15.365, p < 0.001); descriptive evidence indicates that the weight for horsebean is lower, while those for sunflower and casein are higher. To identify which specific pairings differ, we would need to perform post-hoc multiple comparisons, such as Tukey's HSD, which controls the family-wise error rate across all 15 pairwise comparisons; however, this is not required for this problem.
