# ============================================================
# CDS533 Assignment 3 - Member E
# Q4 模型比较、诊断、预测与结论（对应作业 3c/3d/3e 小问）
# 更新：2026-11-23。数据：C 的 trial_v1（source 后使用 qq_work）。
# 本次修改：年份中心化；普通残差诊断；影响点敏感性分析；区分几何均值 CI 与单曲 PI。
# 设定与 D 对齐：Y = log(streams)，主 X = log(in_QQ_playlists)，
# 候选控制 artist_count、released_year、danceability_%、energy_%、
# acousticness_%；key 不入模。分析样本 = 上述变量完整的 843 条。
# 以项目根目录为工作目录：source("scripts/06_E_Q4_models.R")
# 依赖：base R和car；绘图导出用png()。
# ============================================================

# ===== 1. 数据准备（复用 C 的脚本，得到 qq_work）=====
source("scripts/01_C_data_preparation.R")
if (!requireNamespace("car", quietly = TRUE)) stop("Install car before running this script.")

model_vars <- c("streams", "in_QQ_playlists", "artist_count", "released_year",
                "danceability_%", "energy_%", "acousticness_%")
cc <- complete.cases(qq_work[, model_vars])
qq <- qq_work[cc, ]
qq$source_row <- which(cc)  # 原始CSV的数据行号，不含表头
cat("E 分析样本：", nrow(qq_work), "→", nrow(qq),
    "（排除 streams/预测变量不完整", sum(!cc), "行）\n")
stopifnot(nrow(qq) == 843, all(qq$streams > 0), all(qq$in_QQ_playlists > 0))

# ===== 2. 响应与主预测变量 =====
# log(streams)：右偏计数的常用变换（D 图 Q4-D1/D2 已示）。
# log(in_QQ_playlists)：D 图 Q4-D3/D4 显示原始尺度下弯曲、对数后近线性。
# 两变量观测值均正，取对数前无需加常数。log-log 系数为弹性。
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
# 选择理由：m1→m2 显著（F 检验），m2→m3 不显著且 AIC(m2) 最小；
# m2只调整艺人数和年份；原问题要求的五项调整用m3回答，并单独导出。
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

# 敏感性检查：分别暂时排除绝对标准化残差最大的一条、Cook距离最大的三条。
# 这些模型不替代保留全部843条记录的主模型；排除情况须在报告中明示。
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
# lm的t区间替代旧脚本的正态近似；所有计算均使用未舍入系数。
# exp(E[log(streams)|X])是条件几何均值，在正态对数误差假设下也是条件中位数；
# 不把它写成原始播放量的条件算术均值。PI针对一首新歌曲。
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
message("E模型分析完成：主模型保留全部样本；表和诊断图已更新。")
