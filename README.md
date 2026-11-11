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

## 文件夹用途与负责人

| 文件夹 | 负责人 | 用途与当前状态 |
| --- | --- | --- |
| [data/](data/README.md) | C 维护统一数据版本；D、E 使用同一版本。 | 区分 raw 原始数据与 processed 处理数据。数据版本应与生成脚本对应。 |
| [data/raw/](data/raw/README.md) | C 维护。 | 保留 QQ_Music.csv 原文件，不直接覆盖或手工改值。更正与处理写入脚本，在工作副本中执行。 |
| [data/processed/](data/processed/README.md) | 由 C 的数据准备脚本生成。 | 当前 trial_v1 是试用版，保留844行，streams有1个NA，key的89个空字符串暂留；尚未锁定最终分析样本。CSV便于查看，RDS保留R数据类型。 |
| [scripts/](scripts/README.md) | 各成员维护各自脚本，C 维护数据准备并负责最终合并。 | 以项目根目录为工作目录。01_C_data_preparation.R 是已实现的 C 数据准备试用脚本；02–06 当前为待填写任务骨架，不能视作已完成分析。D/E先运行数据准备，再使用qq_work。 |
| [results/](results/README.md) | 各题负责人维护对应子目录。 | data_quality保存数据初检记录；Q1–Q4保存按题号命名的结果表。请由R代码生成，勿仅交控制台截图。 |
| [results/data_quality/](results/data_quality/README.md) | C 维护。 | 保存缺失、空白、无效值和处理前后行数记录，以及运行环境信息。这些是检查证据，不代表完整清洗已经完成。 |
| [results/Q1/](results/Q1/README.md) | A 负责。 | 保存广告评分分析的结果表，文件名注明Q1和具体内容。 |
| [results/Q2/](results/Q2/README.md) | A 负责。 | 保存小鸡饲料ANOVA、假设评估等结果表，文件名注明Q2和具体内容。 |
| [results/Q3/](results/Q3/README.md) | B 负责研究A–D；C负责研究E–G。 | 保存各项研究的检验结果，文件名注明研究编号，例如Q3_E。不同研究分别回答原题，避免混淆分析对象。 |
| [results/Q4/](results/Q4/README.md) | D、E 维护。 | 保存探索分析、模型比较、诊断和预测结果，注明数据版本与所用样本。C的数据准备记录位于results/data_quality。 |
| [figures/](figures/README.md) | 各题负责人维护。 | 保存由代码生成的图表，文件名注明题号和内容，轴、单位与图例应清楚；报告引用对应版本。 |
| [docs/](docs/README.md) | C维护清洗规则和本人小节；各成员补充自己的决策与解释。 | 保存清洗规则、决策记录、变量分类和报告文字。模板须明确标为待完成；已有占位内容不能作为完成答案。 |
| [report/](report/README.md) | B负责整合及版本管理。 | 报告工具由B决定。本次不创建Overleaf或LaTeX框架。各成员提交对应小节文字、表格和图，整合时核对数值与脚本一致。 |
| [submission/](submission/README.md) | B打包，A按分工终检，C提供合并脚本，全员复核。 | 仅放最终核对通过的PDF和单一可复现.R脚本。试用数据、模板和开发文件不放这里。当前尚未放置最终提交件。 |

**代码或文件存在不代表任务完成。数据规则变更须通知相关成员，重跑受影响分析并更新报告数字。**
