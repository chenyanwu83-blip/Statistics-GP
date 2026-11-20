# Required packages: ISLR2 and car.

# ---- Q3 Study E: Public vs Private Colleges ----
library(ISLR2)
data(College)
private_counts <- table(College$Private)
print(private_counts)

test_E <- chisq.test(private_counts, p = c(0.5, 0.5))
print(test_E)
print(test_E$expected)
