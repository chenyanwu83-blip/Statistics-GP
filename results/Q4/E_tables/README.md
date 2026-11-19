# E 模型结果表

数据版本 trial_v1，843 条完整记录，与 D 的表同一样本口径。
从仓库根目录运行 `source("scripts/06_E_Q4_models.R")` 可重新生成全部 CSV。

| 文件 | 内容 |
|---|---|
| Q4_E_Table_01_model_comparison.csv | 三候选模型 AIC（选择依据之一） |
| Q4_E_Table_02_elasticity_stability.csv | log_playlists 系数在 m1/m2/m3 的稳健性 |
| Q4_E_Table_03_coefficients_CI.csv | 最终模型系数、标准误、t、p 与 95% CI |
| Q4_E_Table_04_VIF_final_model.csv | 最终模型 VIF（与 D 的六变量候选集 VIF 互查） |
| Q4_E_Table_05_prediction.csv | 预测情境的均值 CI 与新观测 PI（log 与 streams 尺度） |

报告文字见 `report/Q4_E_report_final.md`（对应作业 3c/3d/3e 小问）。
数据规则若变更，重跑脚本并同步更新报告数字。
