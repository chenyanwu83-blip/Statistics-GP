# ============================================================
# CDS533 Assignment 3 - Member C
# 数据初检与播放量处理：交接试用版 v1
# 日期：2026-11-11
# 本脚本整理本人已经完成的步骤，非逐字复制课件代码。
# 交接对象：qq_work；原始对象：qq_raw。
# 状态：未完成全部清洗，不删除任何行；key 空白仍待共同确认。
# ============================================================

# ===== 1. 读取原始数据 =====
# 小组建议：以仓库根目录为工作目录，原CSV放在data/raw/。
input_file <- "data/raw/QQ_Music.csv"

# 本地练习尚未建立项目目录时，允许手动选择CSV。
# 非交互运行（如Rscript）则必须事先按上述目录放好文件。
if (!file.exists(input_file)) {
  if (interactive()) {
    input_file <- file.choose()
  } else {
    stop("未找到 data/raw/QQ_Music.csv，请先将工作目录设为项目根目录。")
  }
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
# base::summary明确使用基础R摘要，显示格式可能与先前环境不同。

# ===== 3. 统计原始数据的NA与空字符串 =====
raw_na_counts <- colSums(is.na(qq_raw))
raw_empty_counts <- colSums(qq_raw == "", na.rm = TRUE)
print(raw_na_counts)
print(raw_empty_counts)
# 本人已核对：原始NA均为0；key有89个空字符串。
# 此检查不包括只含空格的字符串，也不等于已完成全部质量检查。

# ===== 4. 检查播放量能否转换成数值 =====
# 仅存入临时对象；转换警告被暂时隐藏，失败项必须明确查看。
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
# 本人已核对：第509行 Love Grows (Where My Rosemary Goes)。
# 该格为音频特征文字串，不是有效播放量；不猜测填补。

# ===== 5. 建立工作副本并处理streams =====
qq_work <- qq_raw
qq_work$streams <- streams_check
# 无效播放量记为NA，其他列保留原样，不删行。
# key的89个空字符串仍保留，含义及是否入模须与D/E确认。

# ===== 6. 核对处理结果 =====
str(qq_work$streams)
print(sum(is.na(qq_work$streams)))
print(nrow(qq_work))
# 当前文件本人已核对：num、1个NA、844行。

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

# ===== 8. 交接说明 =====
# D/E在自己的脚本开头运行：
# source("scripts/01_C_data_preparation.R")
# 然后使用qq_work继续EDA或模型试跑。
# 大小写和列名保留原样，百分号/括号列可用qq_work[["energy_%"]]引用。
#
# 待办：完整范围/日期/重复检查、研究问题、变量角色与最终样本规则。
# 本脚本不含Q3 E-G检验，不是整组最终提交脚本。
# 下方额外导出试用版及质量记录；未覆盖原始CSV，未上传GitHub。

# ===== 9. 导出试用数据与检查记录（协作目录适配） =====
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
capture.output(sessionInfo(), file = "results/data_quality/sessionInfo.txt")
message("试用版数据已导出；清洗未全部完成，最终分析样本待与D/E确认。")
