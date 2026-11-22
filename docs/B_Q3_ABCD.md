# B：Q3研究A–D报告文字

状态：已完成（2026-11-22）。代码见 scripts/03_B_Q3_ABCD.R；图见 figures/Q3_A_diagnostics.png、Q3_B_diagnostics.png、Q3_D_distributions.png；完整运行记录（含所有前置检查与sessionInfo）见 results/Q3/Q3_ABCD_results.txt。

# Question 3 — Studies A–D

All tests are two-sided with α = 0.05 and 95% confidence intervals. Every test call is the version taught in the course slides (Weeks 6–8). Each study keeps the full set of records defined by the assignment's own filtering code, and the four studies answer their own questions: Study A and B target population means, Study C a sign probability, Study D whole distributions — the four are not interchangeable conclusions.

### Study A — Is there a league salary gap?

**Design.** The response is the natural log of 1987 salary, a quantitative variable; the two leagues are independent groups. Of 322 players, 59 have missing salaries and none has a non-positive salary, leaving n = 139 American and n = 124 National. H₀: the two population mean log salaries are equal; H₁: they differ.

**Method.** Shapiro–Wilk rejects normality in both groups (W = 0.974, p = 0.009; W = 0.962, p = 0.002), but both samples are large (Week 6: n ≥ 30, CLT) and the question asks about the population *mean*, so a two-sample t-test is the course method here. The Week 7 F-test for equal variances gave F(138, 123) = 1.031, p = 0.867, so there is no evidence against equal variances and the pooled t-test is used.

**Result.** t(261) = 0.104, p = 0.917, 95% CI for the difference in means [−0.205, 0.228]. Group means are nearly identical (5.933 vs 5.921). We fail to reject H₀: the data provide no evidence of a league gap in mean log salary. On the salary scale the interval corresponds to a multiplicative factor between about 0.81 and 1.26, so a practically meaningful gap in either direction is not supported either.

[Diagnostics: boxplot and Q–Q plots](../figures/Q3_A_diagnostics.png)

### Study B — Tuition versus living costs

**Design.** Each college contributes both measurements, so the design is paired; all 777 colleges are retained (no missing or non-positive values). The response is the difference log(Outstate) − log(Room.Board). H₀: the population mean difference is zero; H₁: it is not.

**Method.** Following the Week 8 pattern, the differences were checked first: Shapiro–Wilk rejects strict normality (W = 0.987, p < 0.001), but with 777 pairs (n ≥ 30, CLT) and a mean-difference question, the Week 7 paired t-test is the course method.

**Result.** The mean log difference is 0.828 (SD 0.304), t(776) = 75.774, p < 0.001, 95% CI [0.806, 0.849]. We reject H₀. Out-of-state tuition is clearly the larger bill: exp(0.828) ≈ 2.29, so tuition is on average about 2.3 times room-and-board costs, with the interval corresponding to factors from 2.24 to 2.34.

[Diagnostics: histogram and Q–Q plot of the paired differences](../figures/Q3_B_diagnostics.png)

### Study C — Which bill is more often larger?

**Design.** Same 777 colleges, but only the sign of Outstate − Room.Board matters: 767 positive, 10 negative, 0 ties. H₀: among colleges where the two costs differ, P(tuition > room-and-board) = 0.5; H₁: the probability differs from 0.5.

**Method.** This is a sign test, done with the Week 6 one-sample proportion test `prop.test(x, n, p = 0.5)`. It uses only the counts of positive and negative differences, so it assumes nothing about the shape of the cost distributions — exactly what the question requires.

**Result.** p̂ = 0.987, 95% CI [0.976, 0.993], χ²(1) = 735.570 with continuity correction, p < 0.001. We reject H₀: at almost every college, tuition is the larger bill. An exact binomial test was run as a cross-check and gives the same decision, but the course method is what is reported here.

**Compared with Study B.** Study B asks how large the gap is on average (a mean log difference); Study C asks only which side is larger (a probability). The two can disagree in principle — a large-but-balanced gap would make B significant and C not — but here they agree: tuition is both consistently the larger bill and much larger on average. C says nothing about magnitude, B says nothing about consistency; together they describe the gap fully.

### Study D — American versus Japanese fuel economy

**Design.** mpg is quantitative; the two origin groups are independent (n = 245 American, n = 79 Japanese; all 324 retained cars have valid mpg). H₀: the two mpg distributions are identical; H₁: they differ.

**Method.** Week 8 flow: Shapiro–Wilk per group rejects normality for American cars (W = 0.934, p < 0.001), so the two-sample t-test is not appropriate for comparing distributions; the Mann–Whitney U test (Wilcoxon rank-sum) is used instead. mpg contains tied values, so R automatically uses the normal approximation of W with continuity correction.

**Result.** W = 2456.5, p < 0.001. We reject H₀: the distributions differ. Japanese cars have systematically higher fuel economy — median 31.6 mpg (IQR 8.4) versus 18.5 (IQR 9.0) for American cars. As in any observational comparison of groups, this is a difference between the cars in this 1993-era dataset, not an effect of origin itself.

[Diagnostics: boxplot and empirical CDFs](../figures/Q3_D_distributions.png)

**Integration note.** Studies A–D deliberately do not adjust for multiple comparisons: the assignment states the seven studies are separate research questions. Code comments, this report section and the checks above were prepared with AI assistance and verified by rerunning the script from the raw ISLR2 datasets; disclose this in the final group report as required by the course policy.
