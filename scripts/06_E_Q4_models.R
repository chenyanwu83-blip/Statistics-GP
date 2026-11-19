# ============================================================
# CDS533 Assignment 3 - Member E
# Q4 模型比较、诊断、预测与结论（对应作业 3c/3d/3e 小问）
# 日期：2026-11-19。数据：C 的 trial_v1（source 后使用 qq_work）。
# 设定与 D 对齐：Y = log(streams)，主 X = log(in_QQ_playlists)，
# 候选控制 artist_count、released_year、danceability_%、energy_%、
# acousticness_%；key 不入模。分析样本 = 上述变量完整的 843 条。
# 以项目根目录为工作目录：source("scripts/06_E_Q4_models.R")
# 依赖：base R；绘图导出用 png()。
# ============================================================

# ===== 1. 数据准备（复用 C 的脚本，得到 qq_work）=====
source("scripts/01_C_data_preparation.R")

model_vars <- c("streams", "in_QQ_playlists", "artist_count", "released_year",
                "danceability_%", "energy_%", "acousticness_%")
cc <- complete.cases(qq_work[, model_vars])
qq <- qq_work[cc, ]
cat("E 分析样本：", nrow(qq_work), "→", nrow(qq),
    "（排除 streams/预测变量不完整", sum(!cc), "行）\n")
stopifnot(nrow(qq) == 843, all(qq$streams > 0), all(qq$in_QQ_playlists > 0))

# ===== 2. 响应与主预测变量 =====
# log(streams)：右偏计数的常用变换（D 图 Q4-D1/D2 已示）。
# log(in_QQ_playlists)：D 图 Q4-D3/D4 显示原始尺度下弯曲、对数后近线性。
# 两变量观测值均正，取对数前无需加常数。log-log 系数为弹性。
qq$log_streams    <- log(qq$streams)
qq$log_playlists  <- log(qq$in_QQ_playlists)

# ===== 3. 候选模型（嵌套，镜像研究问题）=====
f1 <- log_streams ~ log_playlists
f2 <- update(f1, . ~ . + artist_count + released_year)
f3 <- update(f2, . ~ . + `danceability_%` + `energy_%` + `acousticness_%`)

m1 <- glm(f1, data = qq, family = gaussian(link = "identity"))
m2 <- glm(f2, data = qq, family = gaussian(link = "identity"))
m3 <- glm(f3, data = qq, family = gaussian(link = "identity"))
stopifnot(nobs(m1) == nobs(m2), nobs(m2) == nobs(m3))  # 样本口径一致

# ===== 4. 模型比较：嵌套 F 检验 + AIC =====
cat("\n── 嵌套偏差检验（F）──\n"); print(anova(m1, m2, m3, test = "F"))
cat("\n── AIC ──\n"); print(AIC(m1, m2, m3))

cmp <- AIC(m1, m2, m3); cmp$df <- NULL
cmp$model <- c("m1: log_playlists",
               "m2: + artist_count + released_year",
               "m3: + danceability + energy + acousticness")

# 核心稳健性：log_playlists 系数在三模型间的变动
stab <- data.frame(
  model = c("m1", "m2", "m3"),
  log_playlists_coef = round(c(coef(m1)["log_playlists"],
                               coef(m2)["log_playlists"],
                               coef(m3)["log_playlists"]), 3),
  R_squared = round(c(1 - m1$deviance / m1$null.deviance,
                      1 - m2$deviance / m2$null.deviance,
                      1 - m3$deviance / m3$null.deviance), 3)
)

dir.create("results/Q4/E_tables", recursive = TRUE, showWarnings = FALSE)
dir.create("figures/Q4_E", recursive = TRUE, showWarnings = FALSE)
write.csv(cmp, "results/Q4/E_tables/Q4_E_Table_01_model_comparison.csv",
          row.names = TRUE, fileEncoding = "UTF-8")
write.csv(stab, "results/Q4/E_tables/Q4_E_Table_02_elasticity_stability.csv",
          row.names = FALSE, fileEncoding = "UTF-8")

# ===== 5. 最终模型：m2 =====
# 选择理由：m1→m2 显著（F 检验），m2→m3 不显著且 AIC(m2) 最小；
# 音频特征不改变 log_playlists 系数（稳健性表），研究问题仍以 m2 回答。
final <- m2

cat("\n── 最终模型 summary ──\n"); print(summary(final))
ci <- confint(final, level = 0.95)
cat("\n── 系数 95% CI ──\n"); print(round(ci, 3))

coefs <- summary(final)$coefficients
out_coef <- data.frame(
  term = rownames(coefs),
  estimate = round(coefs[, 1], 3), std_error = round(coefs[, 2], 3),
  t_value = round(coefs[, 3], 3), p_value = coefs[, 4],
  ci_2.5 = round(ci[, 1], 3), ci_97.5 = round(ci[, 2], 3),
  row.names = NULL
)
write.csv(out_coef, "results/Q4/E_tables/Q4_E_Table_03_coefficients_CI.csv",
          row.names = FALSE, fileEncoding = "UTF-8")

# VIF（最终模型，base R 手写，与 D 的六预测变量 VIF 互查不冲突）
vif_manual <- function(fit) {
  X <- model.matrix(fit)[, -1, drop = FALSE]
  v <- sapply(seq_len(ncol(X)), function(j)
    1 / (1 - summary(lm(X[, j] ~ X[, -j, drop = FALSE]))$r.squared))
  round(setNames(v, colnames(X)), 3)
}
vif_final <- vif_manual(final)
cat("\n── VIF（最终模型 m2）──\n"); print(vif_final)
write.csv(data.frame(term = names(vif_final), VIF = vif_final),
          "results/Q4/E_tables/Q4_E_Table_04_VIF_final_model.csv",
          row.names = FALSE, fileEncoding = "UTF-8")

# ===== 6. 诊断（Figure Q4-E1：残差四图；Figure Q4-E2：残差 vs 主预测变量）=====
png("figures/Q4_E/Q4_E_Figure_01_diagnostics.png",
    width = 1600, height = 1200, res = 160)
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 2.8, 1.5), family = "sans")
plot(final); invisible(dev.off())

png("figures/Q4_E/Q4_E_Figure_02_residual_vs_log_playlists.png",
    width = 1400, height = 800, res = 160)
par(mar = c(4.5, 4.5, 2.8, 1.5), family = "sans")
plot(qq$log_playlists, residuals(final),
     xlab = "log(in_QQ_playlists)", ylab = "Residuals",
     main = "Residuals vs log playlist inclusions")
abline(h = 0, lty = 2); invisible(dev.off())

# Cook 距离最大的观测（诊断叙述用，不删观测）
ck <- cooks.distance(final)
top_ck <- order(-ck)[1:3]
cat("\n── Cook 距离前三的观测 ──\n")
print(data.frame(row = top_ck, track = qq$track_name[top_ck],
                 cooks_D = round(ck[top_ck], 3)))

# ===== 7. 预测情境与 95% 区间（均值 CI 与新观测 PI 分开）=====
# 情境：各变量取中位数（artist_count 中位数为 1），均在观测范围内。
newdat <- data.frame(
  log_playlists    = log(median(qq$in_QQ_playlists)),
  artist_count     = median(qq$artist_count),
  released_year    = median(qq$released_year),
  check.names = FALSE
)
pr <- predict(final, newdata = newdat, se.fit = TRUE)
z <- qnorm(0.975)
ci_log <- c(pr$fit - z * pr$se.fit, pr$fit + z * pr$se.fit)
pi_log <- c(pr$fit - z * sqrt(pr$se.fit^2 + pr$residual.scale^2),
            pr$fit + z * sqrt(pr$se.fit^2 + pr$residual.scale^2))

pred_tab <- data.frame(
  scenario = "median playlist inclusions (2313), artist_count = 1, release year 2022",
  quantity = c("mean_response_CI", "new_observation_PI"),
  log_scale_lower = round(c(ci_log[1], pi_log[1]), 3),
  log_scale_upper = round(c(ci_log[2], pi_log[2]), 3),
  streams_lower = round(exp(c(ci_log[1], pi_log[1])), 0),
  streams_upper = round(exp(c(ci_log[2], pi_log[2])), 0)
)
write.csv(pred_tab, "results/Q4/E_tables/Q4_E_Table_05_prediction.csv",
          row.names = FALSE, fileEncoding = "UTF-8")
cat("\n── 预测（streams 尺度）──\n"); print(pred_tab[, 4:5])

message("E 模型脚本运行完成：表在 results/Q4/E_tables/，图在 figures/Q4_E/。")
