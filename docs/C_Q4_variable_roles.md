# Q4(2): Variable Types and Analytical Roles

Our research question is whether QQ Music playlist inclusion is associated with song streams after accounting for artist count, release year, danceability, energy and acousticness. Each observation is one song record. We use `log(streams)` as the response and `log(in_QQ_playlists)` as the main predictor. In R, `log()` denotes the natural logarithm.

| Variable | Data type and measurement scale | Independent / dependent | Predictor / response |
| --- | --- | --- | --- |
| `streams` | Quantitative, discrete count; ratio scale | Dependent | Response, entered as `log(streams)` |
| `in_QQ_playlists` | Quantitative, discrete count; ratio scale | Independent | Main predictor, entered as `log(in_QQ_playlists)` |
| `artist_count` | Quantitative, discrete count; ratio scale | Independent | Candidate predictor |
| `released_year` | Quantitative; interval scale | Independent | Candidate predictor |
| `danceability_%` | Quantitative score from 0 to 100; treated as approximately interval | Independent | Candidate predictor |
| `energy_%` | Quantitative score from 0 to 100; treated as approximately interval | Independent | Candidate predictor |
| `acousticness_%` | Quantitative score from 0 to 100; treated as approximately interval | Independent | Candidate predictor |

The original stream and playlist counts have meaningful zeros. Release year is interval-scaled because differences between years are meaningful, whereas ratios are not. The data dictionary defines the three audio features as scores, so we treat them as approximately interval rather than assuming that a score of 80 represents twice as much as 40. The log-transformed counts are analysed as continuous numerical variables; the table describes their original measurement scales.

The current analysis uses 843 complete records from `QQ_Music_trial_v1.csv`. The working dataset retains all 844 rows, with the invalid `streams` entry in source data row 509 recorded as `NA`. Records with blank `key` values are retained because `key` is not included. The four candidate duplicate pairs are also retained pending further review.

`track_name` and `artist(s)_name` are nominal labels used for checking record identity; neither is a predictor nor a response in this analysis. Independent and dependent refer to model roles and do not imply a causal relationship.
