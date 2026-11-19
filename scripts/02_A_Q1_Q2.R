# 成员A：Q1广告比较、Q2小鸡饲料ANOVA
# 状态：Q1、Q2 均完成（2026-11-19）。以项目根目录为工作目录。

# ---- Q1 ----
red   <- c(80, 80, 78, 81, 72, 85, 96, 84, 71, 75, 98)
white <- c(75, 55, 98, 92, 86, 78, 87, 79, 88, 87, 85, 94, 99)
blue  <- c(72, 76, 70, 77, 68, 82, 85, 81, 65, 69)
ads <- data.frame(
  score = c(red, white, blue),
  advertisement = factor(rep(c("Red", "White", "Blue"), times = c(11, 13, 10)))
)
dim(ads); table(ads$advertisement)
any(is.na(ads$score))

boxplot(score ~ advertisement, data = ads,
        col  = c("blue", "red", "white"),
        main = "Consumer reaction scores by advertisement",
        xlab = "Advertisement", ylab = "Ordered reaction score")
kruskal.test(score ~ advertisement, data = ads)

# ---- Q2 ----
data("chickwts", package = "datasets")
chicks <- chickwts
dim(chicks); table(chicks$feed)
any(is.na(chicks$weight))

fit <- aov(weight ~ feed, data = chicks)
shapiro.test(residuals(fit))

qqnorm(residuals(fit), main = "Normal Q-Q Plot of ANOVA Residuals")
qqline(residuals(fit), col = "red")

library(car)
leveneTest(weight ~ feed, data = chicks)
leveneTest(weight ~ feed, data = chicks, center = "mean")

boxplot(weight ~ feed, data = chicks, las = 2,
        main = "Chick weight at 6 weeks by feed supplement",
        xlab = "Feed supplement", ylab = "Weight (g)")
anova(fit)

tapply(chicks$weight, chicks$feed, mean)
