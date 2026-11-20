# Required packages: ISLR2 and car.

# ---- Q3 Study E: Public vs Private Colleges ----
library(ISLR2)
data(College)
private_counts <- table(College$Private)
print(private_counts)

test_E <- chisq.test(private_counts, p = c(0.5, 0.5))
print(test_E)
print(test_E$expected)

# ---- Q3 Study F: Private Colleges and Student Profiles ----
College$top10_group <- ifelse(College$Top10perc >= 50, "High", "Lower")

private_top10 <- table(College$Private, College$top10_group)
print(private_top10)

test_F <- chisq.test(private_top10, correct = FALSE)
print(test_F)
print(test_F$expected)
print(prop.table(private_top10, margin = 1))

# ---- Q3 Study G: Fuel Economy Variability ----
auto <- ISLR2::Auto
auto$origin_group <- factor(
  auto$origin,
  levels = c(1, 2, 3),
  labels = c("American", "European", "Japanese")
)

print(table(auto$origin_group))
print(tapply(auto$mpg, auto$origin_group, var))
print(car::leveneTest(mpg ~ origin_group, data = auto, center = median))
