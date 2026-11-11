# Statistics-GP

LU — CDS533 Assignment 3 小组项目

## 当前状态

本地工作目录由远程仓库克隆后建立。数据准备为trial_v1：844行保留，streams数值化并将一格无效值记NA，key的89个空字符串暂留。研究问题和最终分析样本待D/E确认。其他分析脚本为明确标记的空骨架，不是已完成结果。

这是小组协作目录的初始版本。C的数据准备为试用版，其他题目脚本仍待各成员填写。

## 打开和运行

1. 用RStudio打开 Statistics-GP.Rproj，项目根目录即工作目录。
2. 运行 source("scripts/01_C_data_preparation.R")。
3. 当前会话得到qq_raw、qq_work和检查表；脚本同时生成试用CSV/RDS和质量记录。
4. D/E先运行数据准备，再在各自脚本分析qq_work。完整范围、日期及语义核查仍待完成。

## 文件职责

| 文件 | 维护人和用途 |
| --- | --- |
| scripts/01_C_data_preparation.R | C：QQ读取、初检、试用数据生成 |
| scripts/02_A_Q1_Q2.R | A：Q1/Q2，待编写 |
| scripts/03_B_Q3_ABCD.R | B：Q3 A-D，待编写 |
| scripts/04_C_Q3_EFG.R | C：Q3 E-G，待编写 |
| scripts/05_D_Q4_EDA.R | D：Q4 EDA与变量依据，待编写 |
| scripts/06_E_Q4_models.R | E：Q4模型、诊断与预测，待编写 |
| data/raw/QQ_Music.csv | 原始副本，不手工覆盖 |
| data/processed/ | 有明确trial标识的数据，可由脚本重建 |
| results/data_quality/ | 数据问题、缺失/空白与行数摘要、运行环境 |
| results/Q1–Q4/、figures/ | 后续各题结果及图表 |
| docs/ | 清洗规则、变量分类与报告小节 |
| report/ | B维护整合报告 |
| submission/ | 最终可提交PDF与单一R脚本，当前为空 |

每人维护自己的脚本；改变清洗规则需共同确认并重跑结果。Q1–Q3也用R，它们不依赖QQ数据；Q3中的研究可共享College等源数据，但回答不同问题。

读取导出的CSV时应使用check.names=FALSE、stringsAsFactors=FALSE、fileEncoding="UTF-8"、na.strings="NA"；或用readRDS("data/processed/QQ_Music_trial_v1.rds")保留类型。

组内目标11/20 14:30，教师截止11/25 14:30（香港时间）。最终按要求提交一份PDF和一个可复现.R，当前分文件是协作方式。外部代码与获准AI辅助按课程规则注明。

## 辅助与复核

目录、代码注释及数据准备脚本在AI辅助下整理，并经原CSV副本运行核对；需由组员复核理解，正式报告按课程政策披露获准的AI辅助。骨架文件不代表成员已经完成对应任务。
