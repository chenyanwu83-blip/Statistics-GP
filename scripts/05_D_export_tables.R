# Table calculations and export only. Run from the Statistics-GP project root.
# The source script defines qq_d, x_d and model_d on a common complete-case sample.
pdf(tempfile(fileext = ".pdf"))
source("scripts/05_D_Q4_EDA.R")
dev.off()
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
# sapply only arranges already-taught summary statistics into export tables.
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
# Change labels only; the first column was transformed in the analysis script.
dimnames(cor_d) <- list(c("ln(QQ playlists)", "Artist count", "Release year",
                        "Danceability", "Energy", "Acousticness"),
                      c("ln(QQ playlists)", "Artist count", "Release year",
                        "Danceability", "Energy", "Acousticness"))
vif_d <- data.frame(Variable = rownames(cor_d), VIF = unname(car::vif(model_d)))
# These CSVs preserve unrounded numeric results; display formatting is separate.
write.csv(summary_d, "results/Q4/D_tables/Q4_D_Table_01_descriptive.csv", row.names = FALSE)
write.csv(cor_d, "results/Q4/D_tables/Q4_D_Table_02_correlations.csv")
write.csv(vif_d, "results/Q4/D_tables/Q4_D_Table_03_VIF.csv", row.names = FALSE)
print(summary_d)
print(cor_d)
print(vif_d)
