# A：Q1广告比较报告文字

状态：已完成（2026-11-12）。图见 figures/Q1-1_screenshot.png；代码见 scripts/02_A_Q1_Q2.R。

## Question 1: Choosing an Advertisement

The 34 response scores were entered value by value from the original assignment text. All values are numeric and no group contains missing values (verified using is.na() in R); no observations were excluded, imputed, or modified. The score of 55 in the White group is a plausibly observed low response rather than an invalid entry, and it was retained.

### (a) Response scale, design and choice of test

The response is measured on an ordinal scale: the question explicitly states that the response is an ordered reaction score—the values are ranked in order, but the differences between scores do not carry a strict numerical meaning, since the score is an evaluation of the advertisement. There are three groups (Red, White and Blue). The observations are independent: consumers selected at random are each shown only one advertisement, so the design is independent rather than paired. With an ordinal response, three independent groups, and no normality assumption required, the appropriate method is the Kruskal–Wallis test. The hypotheses are

H0: the score distributions are identical across the three advertisements,
H1: at least one advertisement has a different distribution (α = 0.05).

### (b) Descriptives, plot and test

Figure Q1-1 shows a box plot of the three advertisement response scores: White has the highest median, followed by Red and Blue; the group means follow the same order. The Kruskal–Wallis test yields χ²(2) = 8.202, p = 0.017. Since p < 0.05, we reject H0 and conclude that consumer responses to the three advertisements are not all identical.

Figure Q1-1: Consumer reaction scores by advertisement: boxplot and Kruskal–Wallis test output in RStudio (n = 34).

### (c) Recommendation and what the overall test cannot establish

We recommend White: it has the highest median in the descriptive statistics, and the overall test is significant, indicating that the difference is unlikely to be due to chance. Two limitations should be noted. First, the Kruskal–Wallis test is an omnibus test: it can only conclude that at least one group differs, but cannot specify which pairs differ—whether White is significantly better than Red was not tested in this question (post-hoc tests would be required to identify specific pairs). Second, the White group exhibits the greatest internal variability, so its stability is inferior to that of Red; if the team prioritises a stable, upper-middle response, Red is the defensible conservative choice. Blue ranks lowest on both kinds of evidence.
