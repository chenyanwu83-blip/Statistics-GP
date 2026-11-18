# CDS533 Assignment 3 | Member D | ZHANG Yijie
# Research question: How is QQ playlist inclusion associated with log streams,
# accounting for artist count, release year, danceability, energy and acousticness?
# Data: C's trial_v1. Run from the Statistics-GP project root.
# Status: D analysis, figures, tables and reviewed report text prepared (2026-11-19).
# Course methods: R Lab 2/3; regression lectures (correlation, log transforms, VIF).
# C's preparation preserves the original data and documents the invalid stream cell.

# 1. Load the shared data and select a consistent analysis sample
source("scripts/01_C_data_preparation.R")
variables_d <- c("streams", "in_QQ_playlists", "artist_count", "released_year",
                 "danceability_%", "energy_%", "acousticness_%")
# Only these seven variables determine completeness; key is not used.
qq_d <- qq_work[, variables_d]
qq_d <- qq_d[complete.cases(qq_d), ]
# trial_v1: 843 records; the one missing streams record is not analysed.
# complete.cases() is a data-handling step, not an additional statistical method.

# 2. Summary statistics on the original scales
print(summary(qq_d))
print(table(qq_d$artist_count))

# 3. Five numbered EDA figures (base graphics taught in R Lab 3)
# Titles and axis labels follow the regression lecture's labelled plot examples.
# All figures use the same 843-record complete-case sample.
hist(qq_d$streams / 1e9,
     main = "Figure Q4-D1  Distribution of total streams",
     xlab = "Total streams (billions)", ylab = "Number of song records",
     sub = "Data: C trial_v1 | Complete cases: n = 843", col = "grey85")
hist(log(qq_d$streams),
     main = "Figure Q4-D2  Distribution of log streams",
     xlab = "Natural logarithm of total streams", ylab = "Number of song records",
     sub = "Data: C trial_v1 | Complete cases: n = 843", col = "grey85")
plot(qq_d$in_QQ_playlists, log(qq_d$streams),
     main = "Figure Q4-D3  Playlist inclusions and log streams",
     xlab = "QQ Music playlist inclusions (count)",
     ylab = "Natural logarithm of total streams",
     sub = "Data: C trial_v1 | Complete cases: n = 843", pch = 1, cex = 0.65)
plot(log(qq_d$in_QQ_playlists), log(qq_d$streams),
     main = "Figure Q4-D4  Log playlist inclusions and log streams",
     xlab = "Natural logarithm of QQ Music playlist inclusions",
     ylab = "Natural logarithm of total streams",
     sub = "Data: C trial_v1 | Complete cases: n = 843", pch = 1, cex = 0.65)
plot(qq_d[["energy_%"]], qq_d[["acousticness_%"]],
     main = "Figure Q4-D5  Energy and acousticness",
     xlab = "Energy (0-100 score)", ylab = "Acousticness (0-100 score)",
     sub = "Data: C trial_v1 | Complete cases: n = 843", pch = 1, cex = 0.65)
# Raw-stream units above are rescaled only for legible axis labels.
# The 0-100 audio features are scores, not percentages of time or songs.
# These are unadjusted associations, not causal effects or final model validation.

# 4. Correlations among numerical predictors only
x_d <- qq_d[, variables_d[-1]]
x_d$in_QQ_playlists <- log(x_d$in_QQ_playlists)
# The first column below represents log(in_QQ_playlists), not raw counts.
print(cor(x_d))
print(summary(x_d))

# 5. VIF for the specified candidate model
# Install car once if needed; do not reinstall during each analysis run.
# install.packages("car")
library(car)
model_d <- lm(log(streams) ~ log(in_QQ_playlists) +
                artist_count + released_year +
                `danceability_%` + `energy_%` + `acousticness_%`,
              data = qq_d)
print(vif(model_d))
# Final model selection, residual diagnostics and prediction are E's next-stage work.
