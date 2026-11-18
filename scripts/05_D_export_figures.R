# File export only; no additional statistical analysis.
# Run from the Statistics-GP project root. Requires car installed once.
# png()/dev.off() are R file-output commands, not a new statistical method.
dir.create("figures/Q4_D", recursive = TRUE, showWarnings = FALSE)
png("figures/Q4_D/Q4_D_Figure_%02d.png", width = 2400, height = 1710,
    res = 300, type = "quartz", family = "Times New Roman", pointsize = 12)
quartzFonts(TNR = quartzFont(c("Times New Roman", "Times New Roman Bold",
                              "Times New Roman Italic", "Times New Roman Bold Italic")))
par(family = "TNR", mar = c(6, 5, 4, 2))
source("scripts/05_D_Q4_EDA.R")
dev.off()
