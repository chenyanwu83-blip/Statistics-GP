# 成员B：Q3研究A-D
# 状态：已完成（2026-11-22）。报告文字见 docs/B_Q3_ABCD.md。
# 以项目根目录为工作目录：source("scripts/03_B_Q3_ABCD.R")
# 图输出到 figures/，检验结果文本输出到 results/Q3/。
# 检验全部用课件教过的调用：
#   Week 6: prop.test(x, n, p) 单样本比例检验（C的符号检验）、n >= 30 / CLT 大样本均值规则
#   Week 7: var.test(x, y) F检验；t.test(x, y, var.equal = TRUE) 合并方差t检验；
#           t.test(x, y, paired = TRUE) 配对t检验
#   Week 8: shapiro.test() 正态性检查；wilcox.test(y ~ group, data) Mann-Whitney U检验
# 绘图函数（boxplot/hist/qqnorm/qqline/ecdf）为 Week 3/5/8 课件内容。
# 所有检验双侧，alpha = 0.05，95% 置信区间（R 默认值，与课件示例一致）。
if (!requireNamespace('ISLR2', quietly = TRUE)) {
  stop('Install ISLR2 first: install.packages("ISLR2")')
}
fig_dir <- 'figures'
res_dir <- 'results/Q3'
dir.create(fig_dir, showWarnings = FALSE)
dir.create(res_dir, showWarnings = FALSE)

# A: independent groups, natural log salary
hitters <- as.data.frame(ISLR2::Hitters)
hitters_salary <- subset(hitters, !is.na(Salary) & Salary > 0)
hitters_salary$log_salary <- log(hitters_salary$Salary)
a_x <- hitters_salary$log_salary[hitters_salary$League == 'A']
a_y <- hitters_salary$log_salary[hitters_salary$League == 'N']

# Week 8: Shapiro-Wilk in each group. Both p < 0.05, but n = 139 and 124 are
# large (Week 6: n >= 30, CLT), and the question asks about the population
# MEAN log salary, so the two-sample t-test stays the right course method.
shapiro_A_leagueA <- shapiro.test(a_x)
shapiro_A_leagueN <- shapiro.test(a_y)

# Week 7: F-test for equal variances first, then pooled vs Welch.
# p = 0.867 > 0.05 -> no evidence of unequal variances -> pooled t-test,
# same decision rule as the lecture example (F p = 0.84 -> var.equal = TRUE).
variance_check_A <- var.test(a_x, a_y)
result_A <- t.test(a_x, a_y, var.equal = TRUE)

# B: two measurements on the SAME college; tuition minus living
colleges <- as.data.frame(ISLR2::College)
college_costs <- subset(colleges, !is.na(Outstate) & !is.na(Room.Board) &
                          Outstate > 0 & Room.Board > 0)
college_costs$log_tuition <- log(college_costs$Outstate)
college_costs$log_living <- log(college_costs$Room.Board)
difference <- college_costs$log_tuition - college_costs$log_living

# Week 8 pattern (sleep example): look at the differences first, then test.
# Shapiro p = 1.5e-06 < 0.05, but with 777 paired differences (n >= 30, CLT)
# and a question about the MEAN difference, the paired t-test is the course method.
shapiro_B_diff <- shapiro.test(difference)
result_B <- t.test(college_costs$log_tuition, college_costs$log_living,
                   paired = TRUE)

# C: sign test on which cost is larger; no normality or symmetry assumption.
# Week 6 tool: one-sample proportion test prop.test(x, n, p).
# Counts: 767 positive, 10 negative, 0 ties; ties carry no sign information.
cost_difference <- college_costs$Outstate - college_costs$Room.Board
non_ties <- cost_difference[cost_difference != 0]
successes <- sum(non_ties > 0)
result_C <- prop.test(successes, length(non_ties), p = 0.5)
# Cross-check (not from the slides): binom.test(successes, length(non_ties),
# p = 0.5) also gives p < 0.001 with p-hat = 0.987, so the decision is the same.

# D: independent American vs Japanese cars; compare mpg distributions
cars_two <- subset(as.data.frame(ISLR2::Auto), origin %in% c(1, 3))
cars_two$origin_group <- factor(cars_two$origin, levels = c(1, 3),
                                 labels = c('American', 'Japanese'))
d_x <- cars_two$mpg[cars_two$origin_group == 'American']
d_y <- cars_two$mpg[cars_two$origin_group == 'Japanese']
stopifnot(!anyNA(d_x), !anyNA(d_y))

# Week 8 flow (ToothGrowth example): Shapiro-Wilk per group. American mpg is
# clearly non-normal (p = 4.8e-09), so the two-sample t-test is not appropriate
# and we use the Mann-Whitney U test for the distribution comparison.
shapiro_D_us <- shapiro.test(d_x)
shapiro_D_jp <- shapiro.test(d_y)

# Week 8 course call. mpg has ties, so R automatically switches to the normal
# approximation of W with continuity correction (same numbers as spelling out
# exact = FALSE, correct = TRUE).
result_D <- wilcox.test(mpg ~ origin_group, data = cars_two)

summary_A <- aggregate(log_salary ~ League, hitters_salary,
  function(z) c(n = length(z), mean = mean(z), sd = sd(z)))
summary_D <- aggregate(mpg ~ origin_group, cars_two,
  function(z) c(n = length(z), mean = mean(z), median = median(z), IQR = IQR(z)))

png(file.path(fig_dir, 'Q3_A_diagnostics.png'), width = 1500, height = 500)
par(mfrow = c(1, 3))
boxplot(log_salary ~ League, hitters_salary, xlab = 'League', ylab = 'log salary',
        main = 'A: log salary by league')
qqnorm(a_x, main = 'A: American league Q-Q'); qqline(a_x)
qqnorm(a_y, main = 'A: National league Q-Q'); qqline(a_y)
dev.off()
png(file.path(fig_dir, 'Q3_B_diagnostics.png'), width = 1100, height = 500)
par(mfrow = c(1, 2))
hist(difference, xlab = 'log tuition - log living', main = 'B: paired log differences')
qqnorm(difference, main = 'B: differences Q-Q'); qqline(difference)
dev.off()
png(file.path(fig_dir, 'Q3_D_distributions.png'), width = 1100, height = 500)
par(mfrow = c(1, 2))
boxplot(mpg ~ origin_group, cars_two, xlab = 'Origin', ylab = 'mpg',
        main = 'D: mpg by origin')
plot(ecdf(d_x), col = 'steelblue', xlab = 'mpg', ylab = 'Cumulative proportion',
     main = 'D: empirical distributions', xlim = range(c(d_x, d_y)))
lines(ecdf(d_y), col = 'firebrick')
legend('bottomright', c('American', 'Japanese'),
       col = c('steelblue', 'firebrick'), lty = 1)
dev.off()

sink(file.path(res_dir, 'Q3_ABCD_results.txt'))
cat('Run date:', format(Sys.time(), '%Y-%m-%d %H:%M %Z'), '\n\n')
cat('A raw:', nrow(hitters), 'retained:', nrow(hitters_salary),
    'missing salary:', sum(is.na(hitters$Salary)), '\n')
cat('Normality checks (Week 8):\n'); print(shapiro_A_leagueA); print(shapiro_A_leagueN)
print(variance_check_A)
print(summary_A); print(result_A)
cat('\nB raw:', nrow(colleges), 'retained pairs:', nrow(college_costs), '\n')
cat('Mean log difference:', mean(difference), 'SD:', sd(difference), '\n')
print(shapiro_B_diff)
print(result_B)
cat('Geometric mean ratio:', exp(mean(difference)), '\n')
cat('\nC positive:', successes, 'negative:', sum(non_ties < 0),
    'ties:', sum(cost_difference == 0), '\n'); print(result_C)
cat('\nD retained:', nrow(cars_two), '\n')
print(shapiro_D_us); print(shapiro_D_jp)
print(summary_D); print(result_D)
print(sessionInfo())
sink()
print(result_A); print(result_B); print(result_C); print(result_D)
cat('\nFigures in:', normalizePath(fig_dir), '\nResults in:', normalizePath(res_dir), '\n')
