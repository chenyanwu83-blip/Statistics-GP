# CDS533 Assignment 3 | Reproducible group analysis
# Run from the project root: Rscript --vanilla CDS533_A3_Group.R
# Put the original QQ_Music.csv beside this script or at data/raw/QQ_Music.csv.
# Install ISLR2 and car first. Output is written under the working directory.

packages <- c("ISLR2", "car")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
  stop("Install required packages: ", paste(missing_packages, collapse = ", "))
}
dir.create("figures", showWarnings = FALSE)

# ---- Member A | Q1 Advertisement comparison and Q2 Feed ANOVA ----
local({

  # ---- Q1 ----
  red   <- c(80, 80, 78, 81, 72, 85, 96, 84, 71, 75, 98)
  white <- c(75, 55, 98, 92, 86, 78, 87, 79, 88, 87, 85, 94, 99)
  blue  <- c(72, 76, 70, 77, 68, 82, 85, 81, 65, 69)
  ads <- data.frame(
    score = c(red, white, blue),
    advertisement = factor(rep(c("Red", "White", "Blue"), times = c(11, 13, 10)))
  )
  print(dim(ads)); print(table(ads$advertisement))
  print(anyNA(ads$score))

  png("figures/Q1-1_boxplot.png", width = 1400, height = 900, res = 150)
  boxplot(score ~ advertisement, data = ads,
          col  = c("blue", "red", "white"),
          main = "Consumer reaction scores by advertisement",
          xlab = "Advertisement", ylab = "Ordered reaction score")
  invisible(dev.off())
  print(kruskal.test(score ~ advertisement, data = ads))
  print(aggregate(score ~ advertisement, data = ads,
                  FUN = function(x) c(n = length(x), mean = mean(x),
                                      median = median(x), SD = sd(x))))

  # ---- Q2 ----
  data("chickwts", package = "datasets")
  chicks <- chickwts
  print(dim(chicks)); print(table(chicks$feed))
  print(anyNA(chicks$weight))

  fit <- aov(weight ~ feed, data = chicks)
  print(shapiro.test(residuals(fit)))

  png("figures/Q2-2_qqplot.png", width = 1400, height = 900, res = 150)
  qqnorm(residuals(fit), main = "Normal Q-Q Plot of ANOVA Residuals")
  qqline(residuals(fit), col = "red")
  invisible(dev.off())

  print(car::leveneTest(weight ~ feed, data = chicks))
  print(car::leveneTest(weight ~ feed, data = chicks, center = "mean"))

  png("figures/Q2-1_boxplot.png", width = 1400, height = 1050, res = 150)
  boxplot(weight ~ feed, data = chicks, las = 2,
          main = "Chick weight at 6 weeks by feed supplement",
          xlab = "Feed supplement", ylab = "Weight (g)")
  invisible(dev.off())
  print(anova(fit))

  print(tapply(chicks$weight, chicks$feed, mean))
})

# ---- Member B | Q3 Studies A-D ----
local({
  if (!requireNamespace('ISLR2', quietly = TRUE)) {
    stop('Install ISLR2 first: install.packages("ISLR2")')
  }
  fig_dir <- 'figures'
  res_dir <- 'results/Q3'
  dir.create(fig_dir, showWarnings = FALSE)
  dir.create(res_dir, recursive = TRUE, showWarnings = FALSE)

  # A: independent groups, natural log salary
  hitters <- as.data.frame(ISLR2::Hitters)
  hitters_salary <- subset(hitters, !is.na(Salary) & Salary > 0)
  hitters_salary$log_salary <- log(hitters_salary$Salary)
  a_x <- hitters_salary$log_salary[hitters_salary$League == 'A']
  a_y <- hitters_salary$log_salary[hitters_salary$League == 'N']

  # Check each league before comparing mean log salaries.
  shapiro_A_leagueA <- shapiro.test(a_x)
  shapiro_A_leagueN <- shapiro.test(a_y)

  # Check the equal-variance assumption for the pooled t-test.
  variance_check_A <- var.test(a_x, a_y)
  result_A <- t.test(a_x, a_y, var.equal = TRUE)

  # B: two measurements on the SAME college; tuition minus living
  colleges <- as.data.frame(ISLR2::College)
  college_costs <- subset(colleges, !is.na(Outstate) & !is.na(Room.Board) &
                            Outstate > 0 & Room.Board > 0)
  college_costs$log_tuition <- log(college_costs$Outstate)
  college_costs$log_living <- log(college_costs$Room.Board)
  difference <- college_costs$log_tuition - college_costs$log_living

  # Assess the distribution of within-college differences.
  shapiro_B_diff <- shapiro.test(difference)
  result_B <- t.test(college_costs$log_tuition, college_costs$log_living,
                     paired = TRUE)

  # Compare the fraction of positive differences with 0.5. Exclude ties.
  cost_difference <- college_costs$Outstate - college_costs$Room.Board
  non_ties <- cost_difference[cost_difference != 0]
  successes <- sum(non_ties > 0)
  result_C <- prop.test(successes, length(non_ties), p = 0.5)

  # D: independent American vs Japanese cars; compare mpg distributions
  cars_two <- subset(as.data.frame(ISLR2::Auto), origin %in% c(1, 3))
  cars_two$origin_group <- factor(cars_two$origin, levels = c(1, 3),
                                   labels = c('American', 'Japanese'))
  d_x <- cars_two$mpg[cars_two$origin_group == 'American']
  d_y <- cars_two$mpg[cars_two$origin_group == 'Japanese']
  stopifnot(!anyNA(d_x), !anyNA(d_y))

  # Check each group before the independent rank-sum comparison.
  shapiro_D_us <- shapiro.test(d_x)
  shapiro_D_jp <- shapiro.test(d_y)

  # The tied mpg values lead R to use the normal approximation.
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
  cat('Geometric mean ratio 95% CI:', exp(result_B$conf.int), '\n')
  cat('\nC positive:', successes, 'negative:', sum(non_ties < 0),
      'ties:', sum(cost_difference == 0), '\n'); print(result_C)
  cat('\nD retained:', nrow(cars_two), '\n')
  print(shapiro_D_us); print(shapiro_D_jp)
  print(summary_D); print(result_D)
  print(sessionInfo())
  sink()
  print(result_A); print(result_B); print(result_C); print(result_D)
  cat('\nFigures in:', normalizePath(fig_dir), '\nResults in:', normalizePath(res_dir), '\n')
})

# ---- Member C | Q3 Studies E-G ----
local({

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
})

# ---- Member C | Q4 Data preparation ----
qq_work <- local({

  # ===== 1. 读取原始数据 =====
  input_file <- "data/raw/QQ_Music.csv"

  if (!file.exists(input_file)) {
    # Find the input when launched through RStudio Source or Rscript.
    script_files <- c(
      unlist(lapply(rev(sys.frames()), function(frame) frame$ofile), use.names = FALSE),
      sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
    )
    script_dirs <- unique(dirname(script_files[file.exists(script_files)]))
    candidates <- c(
      "QQ_Music.csv",
      file.path(script_dirs, "data", "raw", "QQ_Music.csv"),
      file.path(script_dirs, "QQ_Music.csv")
    )
    found <- candidates[file.exists(candidates)]
    if (length(found)) input_file <- found[[1L]]
  }

  if (!file.exists(input_file)) {
    stop("Put the original QQ_Music.csv beside this .R file or at data/raw/QQ_Music.csv in the project root.")
  }

  qq_raw <- read.csv(
    input_file,
    fileEncoding = "UTF-8-BOM",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  # ===== 2. 查看数据结构与摘要 =====
  str(qq_raw)
  head(qq_raw)
  base::summary(qq_raw)

  # ===== 3. 统计原始数据的NA与空字符串 =====
  raw_na_counts <- colSums(is.na(qq_raw))
  raw_empty_counts <- colSums(qq_raw == "", na.rm = TRUE)
  print(raw_na_counts)
  print(raw_empty_counts)

  # ===== 4. 检查播放量能否转换成数值 =====
  streams_check <- suppressWarnings(as.numeric(qq_raw$streams))
  invalid_streams_rows <- which(
    !is.na(qq_raw$streams) & is.na(streams_check)
  )

  invalid_streams <- data.frame(
    source_row = invalid_streams_rows,
    track_name = qq_raw$track_name[invalid_streams_rows],
    original_streams = qq_raw$streams[invalid_streams_rows],
    stringsAsFactors = FALSE
  )
  print(invalid_streams)

  # ===== 5. 建立工作副本并处理streams =====
  qq_work <- qq_raw
  qq_work$streams <- streams_check
  # Record invalid streams as NA. Keep all 844 rows and blank keys.

  # ===== 6. 核对处理结果 =====
  str(qq_work$streams)
  print(sum(is.na(qq_work$streams)))
  print(nrow(qq_work))

  stopifnot(
    is.numeric(qq_work$streams),
    nrow(qq_work) == nrow(qq_raw),
    identical(names(qq_work), names(qq_raw)),
    sum(is.na(qq_work$streams)) ==
      sum(is.na(qq_raw$streams)) + length(invalid_streams_rows)
  )

  # ===== 7. 供组员引用的当前处理摘要 =====
  preparation_summary <- data.frame(
    raw_rows = nrow(qq_raw),
    working_rows = nrow(qq_work),
    excluded_rows = nrow(qq_raw) - nrow(qq_work),
    invalid_streams_cells = length(invalid_streams_rows),
    streams_NA_after = sum(is.na(qq_work$streams)),
    key_empty_retained = sum(qq_work$key == "", na.rm = TRUE)
  )
  print(preparation_summary)


  # Export the working data and quality checks.
  dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
  dir.create("results/data_quality", recursive = TRUE, showWarnings = FALSE)
  write.csv(qq_work, "data/processed/QQ_Music_trial_v1.csv",
            row.names = FALSE, fileEncoding = "UTF-8", na = "NA")
  saveRDS(qq_work, "data/processed/QQ_Music_trial_v1.rds")
  write.csv(invalid_streams, "results/data_quality/invalid_streams.csv",
            row.names = FALSE, fileEncoding = "UTF-8")
  write.csv(preparation_summary, "results/data_quality/preparation_summary.csv",
            row.names = FALSE, fileEncoding = "UTF-8")
  column_audit <- data.frame(
    variable = names(qq_raw),
    raw_NA = unname(raw_na_counts),
    raw_empty_string = unname(raw_empty_counts),
    work_NA = unname(colSums(is.na(qq_work)))
  )
  write.csv(column_audit, "results/data_quality/column_audit.csv",
            row.names = FALSE, fileEncoding = "UTF-8")
  # Check exact duplicates separately from repeated song/artist labels.
  exact_duplicate_count <- sum(duplicated(qq_raw))
  identity <- qq_raw[, c("track_name", "artist(s)_name")]
  repeated <- duplicated(identity) | duplicated(identity, fromLast = TRUE)
  duplicate_label_groups <- nrow(unique(identity[repeated, , drop = FALSE]))
  duplicate_audit <- data.frame(exact_duplicate_rows = exact_duplicate_count,
                                repeated_label_groups = duplicate_label_groups,
                                repeated_label_rows = sum(repeated))
  print(duplicate_audit)
  write.csv(duplicate_audit, "results/data_quality/duplicate_audit.csv", row.names = FALSE)
  write.csv(data.frame(source_row = which(repeated), qq_raw[repeated, ], check.names = FALSE),
            "results/data_quality/repeated_song_artist_labels.csv", row.names = FALSE)
  capture.output(sessionInfo(), file = "results/data_quality/sessionInfo.txt")
  qq_work
})

# ---- Member D | Q4 EDA, predictor reasoning and VIF ----
local({
  dir.create("figures/Q4_D", recursive = TRUE, showWarnings = FALSE)
  png("figures/Q4_D/Q4_D_Figure_%02d.png", width = 2400, height = 1710,
      res = 300, family = "serif", pointsize = 12)
  par(mar = c(6, 5, 4, 2))

  # 1. Load the shared data and select a consistent analysis sample
  variables_d <- c("streams", "in_QQ_playlists", "artist_count", "released_year",
                   "danceability_%", "energy_%", "acousticness_%")
  # Only these seven variables determine completeness; key is not used.
  qq_d <- qq_work[, variables_d]
  qq_d <- qq_d[complete.cases(qq_d), ]
  # trial_v1: 843 records; the one missing streams record is not analysed.

  # 2. Summary statistics on the original scales
  print(summary(qq_d))
  print(table(qq_d$artist_count))

  # Five EDA plots.
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
  # The 0-100 audio features are scores, not percentages of time or songs.

  # 4. Correlations among numerical predictors only
  x_d <- qq_d[, variables_d[-1]]
  x_d$in_QQ_playlists <- log(x_d$in_QQ_playlists)
  # The first column below represents log(in_QQ_playlists), not raw counts.
  print(cor(x_d))
  print(summary(x_d))

  # 5. VIF for the specified candidate model
  library(car)
  model_d <- lm(log(streams) ~ log(in_QQ_playlists) +
                  artist_count + released_year +
                  `danceability_%` + `energy_%` + `acousticness_%`,
                data = qq_d)
  print(vif(model_d))
  invisible(dev.off())
  dir.create("results/Q4/D_tables", recursive = TRUE, showWarnings = FALSE)
  # Raw streams are displayed in millions; the two transformed variables use ln.
  table_data_d <- data.frame(
    "Streams (million)" = qq_d$streams / 1e6,
    "ln(streams)" = log(qq_d$streams),
    "QQ playlist inclusions" = qq_d$in_QQ_playlists,
    "ln(QQ playlist inclusions)" = log(qq_d$in_QQ_playlists),
    "Artist count" = qq_d$artist_count,
    "Release year" = qq_d$released_year,
    "Danceability (0-100)" = qq_d[["danceability_%"]],
    "Energy (0-100)" = qq_d[["energy_%"]],
    "Acousticness (0-100)" = qq_d[["acousticness_%"]],
    check.names = FALSE)
  summary_d <- data.frame(
    Variable = names(table_data_d), N = nrow(qq_d),
    Mean = sapply(table_data_d, mean),
    SD = sapply(table_data_d, sd),
    Min = sapply(table_data_d, min),
    Q1 = sapply(table_data_d, quantile, probs = 0.25),
    Median = sapply(table_data_d, median),
    Q3 = sapply(table_data_d, quantile, probs = 0.75),
    Max = sapply(table_data_d, max), row.names = NULL)
  cor_d <- cor(x_d)
  dimnames(cor_d) <- list(c("ln(QQ playlists)", "Artist count", "Release year",
                          "Danceability", "Energy", "Acousticness"),
                        c("ln(QQ playlists)", "Artist count", "Release year",
                          "Danceability", "Energy", "Acousticness"))
  vif_d <- data.frame(Variable = rownames(cor_d), VIF = unname(car::vif(model_d)))
  write.csv(summary_d, "results/Q4/D_tables/Q4_D_Table_01_descriptive.csv", row.names = FALSE)
  write.csv(cor_d, "results/Q4/D_tables/Q4_D_Table_02_correlations.csv")
  write.csv(vif_d, "results/Q4/D_tables/Q4_D_Table_03_VIF.csv", row.names = FALSE)
  print(summary_d)
  print(cor_d)
  print(vif_d)
})

# ---- Member E | Q4 Model selection, diagnostics and prediction ----
local({

  # Select complete records from the prepared data.

  model_vars <- c("streams", "in_QQ_playlists", "artist_count", "released_year",
                  "danceability_%", "energy_%", "acousticness_%")
  cc <- complete.cases(qq_work[, model_vars])
  qq <- qq_work[cc, ]
  qq$source_row <- which(cc)  # 原始CSV的数据行号，不含表头
  cat("E 分析样本：", nrow(qq_work), "→", nrow(qq),
      "（排除 streams/预测变量不完整", sum(!cc), "行）\n")
  stopifnot(nrow(qq) == 843, all(qq$streams > 0), all(qq$in_QQ_playlists > 0))

  # ===== 2. 响应与主预测变量 =====
  qq$log_streams    <- log(qq$streams)
  qq$log_playlists  <- log(qq$in_QQ_playlists)
  year_reference <- 2022
  qq$released_year_c <- qq$released_year - year_reference

  # ===== 3. 比较三个嵌套模型=====
  f1 <- log_streams ~ log_playlists
  f2 <- update(f1, . ~ . + artist_count + released_year_c)
  f3 <- update(f2, . ~ . + `danceability_%` + `energy_%` + `acousticness_%`)

  m1 <- lm(f1, data = qq)
  m2 <- lm(f2, data = qq)
  m3 <- lm(f3, data = qq)
  stopifnot(nobs(m1) == nobs(m2), nobs(m2) == nobs(m3))  # 样本口径一致

  # lm与Gaussian identity GLM具有相同的最小二乘系数和拟合值。
  # 中心化只改变截距，不改变拟合值、AIC或其他变量的系数。
  uncentred <- lm(log_streams ~ log_playlists + artist_count + released_year, data = qq)
  glm_check <- glm(f2, data = qq, family = gaussian(link = "identity"))
  stopifnot(max(abs(fitted(m2) - fitted(uncentred))) < 1e-8,
            max(abs(fitted(m2) - fitted(glm_check))) < 1e-8)

  # ===== 4. 模型比较：嵌套 F 检验 + AIC =====
  cat("\n── 嵌套模型检验（F）──\n"); print(anova(m1, m2, m3, test = "F"))
  cat("\n── AIC ──\n"); print(AIC(m1, m2, m3))

  cmp <- AIC(m1, m2, m3); cmp$df <- NULL
  cmp$model <- c("m1: log_playlists",
                 "m2: + artist_count + released_year_c",
                 "m3: + danceability + energy + acousticness")

  # 核心稳健性：log_playlists 系数在三模型间的变动
  stab <- data.frame(
    model = c("m1", "m2", "m3"),
    log_playlists_coef = round(c(coef(m1)["log_playlists"],
                                 coef(m2)["log_playlists"],
                                 coef(m3)["log_playlists"]), 3),
    R_squared = round(c(summary(m1)$r.squared,
                        summary(m2)$r.squared,
                        summary(m3)$r.squared), 3)
  )

  dir.create("results/Q4/E_tables", recursive = TRUE, showWarnings = FALSE)
  dir.create("figures/Q4_E", recursive = TRUE, showWarnings = FALSE)
  write.csv(cmp, "results/Q4/E_tables/Q4_E_Table_01_model_comparison.csv",
            row.names = TRUE, fileEncoding = "UTF-8")
  write.csv(stab, "results/Q4/E_tables/Q4_E_Table_02_elasticity_stability.csv",
            row.names = FALSE, fileEncoding = "UTF-8")

  # ===== 5. 最终模型：m2 =====
  # m2 is the selected model. m3 adjusts for all five candidate controls.
  final <- m2

  cat("\n── 最终模型 summary ──\n"); print(summary(final))
  ci <- confint(final, level = 0.95)
  cat("\n── 系数 95% CI ──\n"); print(round(ci, 3))

  coefs <- summary(final)$coefficients
  out_coef <- data.frame(
    term = rownames(coefs),
    estimate = coefs[, 1], std_error = coefs[, 2],
    t_value = coefs[, 3], p_value = coefs[, 4],
    ci_2.5 = ci[, 1], ci_97.5 = ci[, 2],
    row.names = NULL
  )
  write.csv(out_coef, "results/Q4/E_tables/Q4_E_Table_03_coefficients_CI.csv",
            row.names = FALSE, fileEncoding = "UTF-8")

  # VIF for the final model; use the same car function as the candidate-model check.
  vif_final <- round(car::vif(final), 3)
  cat("\n── VIF（最终模型 m2）──\n"); print(vif_final)
  write.csv(data.frame(term = names(vif_final), VIF = vif_final),
            "results/Q4/E_tables/Q4_E_Table_04_VIF_final_model.csv",
            row.names = FALSE, fileEncoding = "UTF-8")

  # ===== 6. 诊断（Figure Q4-E1：残差四图；Figure Q4-E2：残差 vs 主预测变量）=====
  png("figures/Q4_E/Q4_E_Figure_01_diagnostics.png",
      width = 1600, height = 1200, res = 160)
  par(mfrow = c(2, 2), mar = c(4.2, 4.2, 2.8, 1.5), family = "sans")
  plot(final, which = c(1, 2, 3, 5)); invisible(dev.off())

  png("figures/Q4_E/Q4_E_Figure_02_residual_vs_log_playlists.png",
      width = 1400, height = 800, res = 160)
  par(mar = c(4.5, 4.5, 2.8, 1.5), family = "sans")
  plot(qq$log_playlists, residuals(final),
       xlab = "log(in_QQ_playlists)", ylab = "Residuals",
       main = "Residuals vs log playlist inclusions")
  abline(h = 0, lty = 2)
  # LOWESS is a descriptive trend, not an additional significance test.
  lines(lowess(qq$log_playlists, residuals(final)), col = "firebrick", lwd = 2)
  invisible(dev.off())

  # 逐条导出诊断，便于核查原记录；阈值仅用于筛查，不自动删值。
  ck <- cooks.distance(final)
  influence <- data.frame(
    source_row = qq$source_row, track = qq$track_name, streams = qq$streams,
    residual = residuals(final), standardized_residual = rstandard(final),
    studentized_residual = rstudent(final), leverage = hatvalues(final), cooks_D = ck,
    cook_above_4_over_n = ck > 4 / nrow(qq),
    stringsAsFactors = FALSE
  )
  write.csv(influence[order(-influence$cooks_D), ],
            "results/Q4/E_tables/Q4_E_Table_06_influence.csv", row.names = FALSE)
  cat("\nCook筛查阈值4/n =", 4 / nrow(qq),
      "；超过阈值的记录数：", sum(influence$cook_above_4_over_n), "\n")
  print(head(influence[order(-ck), ], 3))

  # Refit after temporary exclusions. The main model retains all 843 records.
  extreme <- which.max(abs(rstandard(final)))
  top_ck <- order(-ck)[1:3]
  sensitivity_models <- list(
    all_records = final,
    omit_largest_absolute_residual = lm(f2, data = qq[-extreme, ]),
    omit_top_three_cook = lm(f2, data = qq[-top_ck, ])
  )
  excluded <- c("none", as.character(qq$source_row[extreme]),
                paste(qq$source_row[top_ck], collapse = ";"))
  sensitivity <- do.call(rbind, lapply(seq_along(sensitivity_models), function(i) {
    fit <- sensitivity_models[[i]]
    cfit <- confint(fit)
    data.frame(analysis = names(sensitivity_models)[i], n = nobs(fit),
               excluded_source_rows = excluded[i], term = names(coef(fit)),
               estimate = unname(coef(fit)), ci_lower = cfit[, 1], ci_upper = cfit[, 2],
               row.names = NULL)
  }))
  write.csv(sensitivity, "results/Q4/E_tables/Q4_E_Table_07_sensitivity.csv",
            row.names = FALSE)
  cat("\n敏感性检查中的歌单系数：\n")
  print(sensitivity[sensitivity$term == "log_playlists", ])

  # 完整调整模型：歌单系数在同时控制五项预设变量后的估计。
  full_coef <- summary(m3)$coefficients
  full_ci <- confint(m3)
  write.csv(data.frame(term = rownames(full_coef), estimate = full_coef[, 1],
                      std_error = full_coef[, 2], t_value = full_coef[, 3],
                      p_value = full_coef[, 4], ci_lower = full_ci[, 1],
                      ci_upper = full_ci[, 2], row.names = NULL),
            "results/Q4/E_tables/Q4_E_Table_08_full_adjustment.csv", row.names = FALSE)

  # ===== 7. 预测情境与95%区间 =====
  # Use unrounded coefficients and t-based intervals from lm().
  # Back-transform the geometric mean CI and the single-song prediction interval.
  newdat <- data.frame(
    log_playlists = log(median(qq$in_QQ_playlists)),
    artist_count = median(qq$artist_count),
    released_year_c = median(qq$released_year) - year_reference
  )
  stopifnot(newdat$log_playlists >= min(qq$log_playlists),
            newdat$log_playlists <= max(qq$log_playlists),
            newdat$artist_count >= min(qq$artist_count),
            newdat$artist_count <= max(qq$artist_count),
            newdat$released_year_c >= min(qq$released_year_c),
            newdat$released_year_c <= max(qq$released_year_c))
  ci_log <- predict(final, newdata = newdat, interval = "confidence", level = 0.95)
  pi_log <- predict(final, newdata = newdat, interval = "prediction", level = 0.95)
  pred_tab <- data.frame(
    playlists = exp(newdat$log_playlists), artist_count = newdat$artist_count,
    released_year = newdat$released_year_c + year_reference,
    quantity = c("conditional_geometric_mean_CI", "single_new_song_PI"),
    point_log_streams = rep(unname(ci_log[1, "fit"]), 2),
    point_streams = rep(exp(unname(ci_log[1, "fit"])), 2),
    point_streams_million = rep(exp(unname(ci_log[1, "fit"])) / 1e6, 2),
    log_scale_lower = c(ci_log[1, "lwr"], pi_log[1, "lwr"]),
    log_scale_upper = c(ci_log[1, "upr"], pi_log[1, "upr"]),
    streams_lower = exp(c(ci_log[1, "lwr"], pi_log[1, "lwr"])),
    streams_upper = exp(c(ci_log[1, "upr"], pi_log[1, "upr"])),
    million_streams_lower = exp(c(ci_log[1, "lwr"], pi_log[1, "lwr"])) / 1e6,
    million_streams_upper = exp(c(ci_log[1, "upr"], pi_log[1, "upr"])) / 1e6,
    interval_method = paste0("Student t, ", df.residual(final),
                             " residual df; normal homoscedastic log errors")
  )
  write.csv(pred_tab, "results/Q4/E_tables/Q4_E_Table_05_prediction.csv",
            row.names = FALSE, fileEncoding = "UTF-8")
  cat("\n预测值和区间（百万次）：\n")
  print(pred_tab[, c("quantity", "point_streams_million",
                    "million_streams_lower", "million_streams_upper")])
  cat("\n残差偏离和异方差可能影响区间覆盖率。\n")

  # 保存参数化对照和运行信息，便于报告更新。
  parameterisation <- data.frame(
    term = names(coef(final)), centred_estimate = unname(coef(final)),
    uncentred_term = names(coef(uncentred)),
    uncentred_estimate = unname(coef(uncentred)),
    year_reference = year_reference
  )
  write.csv(parameterisation, "results/Q4/E_tables/Q4_E_Table_09_year_centring.csv",
            row.names = FALSE)
  writeLines(trimws(capture.output(sessionInfo()), which = "right"),
             "results/Q4/E_tables/Q4_E_sessionInfo.txt")
})
