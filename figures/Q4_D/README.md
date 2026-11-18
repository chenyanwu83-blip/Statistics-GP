# D 正式图表索引

数据版本：C trial_v1。样本：所选七个变量完整的843条记录。
字体：Times New Roman。图片：2400 × 1710像素，300 dpi。

| 编号 | 文件 | 内容 |
| --- | --- | --- |
| Q4-D1 | Q4_D_Figure_01.png | 原始播放量分布 |
| Q4-D2 | Q4_D_Figure_02.png | 自然对数播放量分布 |
| Q4-D3 | Q4_D_Figure_03.png | 原始歌单数量与对数播放量 |
| Q4-D4 | Q4_D_Figure_04.png | 对数歌单数量与对数播放量 |
| Q4-D5 | Q4_D_Figure_05.png | 能量与原声程度 |

复现：在Statistics-GP项目根目录运行 source("scripts/05_D_export_figures.R")。
分析方法保留在scripts/05_D_Q4_EDA.R；导出脚本只控制文件与字体，未新增统计方法。当前导出器使用macOS原生quartz设备，不需要额外安装XQuartz。

R Lab 3 第7页：hist、plot；10.29回归课件第34页：xlab、ylab、pch等绘图标签参数。png、dev.off、字体设置是辅助文件导出命令，不声称课件已逐项讲授。

图中关系为未调整关联，不表示因果。原始播放量用十亿次为单位显示，未改变统计样本。保留了低播放量记录，没有为图形美观删点。候选模型的正式选择和残差诊断仍待与E衔接。D报告文字及DeepL润色已完成，见report/Q4_D_report_final.docx。本文件是图表索引。
