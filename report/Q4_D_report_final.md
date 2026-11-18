# Q4 D Exploratory analysis and predictor reasoning

## Q4 1a Data and exploratory analysis

The supplied dataset contains 844 song records. We used C's trial_v1 working data. One invalid text value in streams was recorded as missing. We selected six candidate predictors and one response variable, retaining 843 records with complete values for these variables. Records with a blank key were retained because key was not included in this analysis. All the figures, summary statistics, correlations and variance inflation factors below are based on the same 843 records.

Table Q4-D1 shows that the mean total streams is 536.062 million and the median is 301.052 million. Figure Q4-D1 shows that the distribution is strongly right-skewed, with a small number of songs having very high stream counts. After applying a natural logarithm transformation, the long upper tail is compressed and most observations form a more compact cluster (see Figure Q4-D2). However, a few very low values remain in the left tail. These records were retained. The histogram alone does not indicate whether the regression assumptions are met.

Figure Q4-D3 shows a positive but curved association between QQ playlist inclusions and log streams. The pattern is steeper at lower playlist counts and flatter at higher ones. When playlist inclusions are also transformed using the natural logarithm, the main pattern resembles a positive straight line more closely (see Figure Q4-D4). This suggests that log playlist inclusions should be considered in the candidate model. However, it does not establish the adjusted association, so model comparison and residual diagnostics are still needed.

Figure Q4-D5 shows a negative association between energy and acousticness. Their Pearson correlation is -0.595. Table Q4-D1 shows that the median values are 68.000 for danceability, 65.000 for energy and 17.000 for acousticness. These features are recorded on 0–100 scales. While these results describe the sample, they do not demonstrate that any feature causes higher streams.

## Q4 1b Research question and relevance

Our research question is: How is QQ Music playlist inclusion associated with the natural logarithm of cumulative song streams, after accounting for artist count, release year, danceability, energy and acousticness?

The response variable is log(streams). QQ playlist inclusion is the main predictor, with its log transformation supported by the exploratory plots. The other candidate predictors are artist count, release year, danceability, energy, and acousticness. Playlist inclusion is important to the QQ Music team as a source of exposure. Studying its association with streams while accounting for selected song characteristics can inform the evaluation of playlist promotion. However, popular songs may also be more likely to be included in playlists. Therefore, the observed association cannot be interpreted as the effect of adding a song to a playlist.

## Q4 3a Candidate predictor selection

We included playlist inclusions as they are the main variable of interest. The log transformation reduces the curvature seen in Figure Q4-D3, making it a reasonable candidate for the model. As all observed playlist counts and non-missing stream counts are positive, no constant was added before taking logarithms.

We included artist count to account for differences between solo songs and collaborations. This variable ranges from 1 to 8, with a median of 1.000. Records involving many artists are sparse, so conclusions about these small groups require caution. The release year was included because earlier releases may have had more time to accumulate streams and playlist inclusions. Its median is 2022, with a range of 1942–2023. However, release year is not a direct measure of time spent on the platform.

Danceability describes suitability for dancing, energy describes perceived intensity, and acousticness describes acoustic character. Their observed ranges are 23–96, 9–97, and 0–97, respectively. We included these three features to account for selected differences in the songs themselves. The correlation and VIF checks do not indicate a need to remove them because of serious multicollinearity. Song and artist names are identifiers. We excluded key and other platform indicators to focus the analysis on the agreed question regarding QQ playlist inclusion. This is a scope decision and does not imply that those variables are unrelated to popularity.

## Q4 3b Correlation and multicollinearity

We calculated the Pearson correlations between the six numerical predictors, excluding the response variable (see Table Q4-D2). In this table, playlist inclusions are on the natural logarithm scale. The largest absolute pairwise correlation is between energy and acousticness, at -0.595. The correlation between log playlist inclusions and release year is -0.397. However, these results alone cannot rule out multicollinearity because a predictor can be related to several other predictors simultaneously.

We therefore calculated the variance inflation factors for the candidate linear model containing the six predictors (see Table Q4-D3). The VIFs range from 1.058 to 1.627. The regression lecture identifies values around or above 5 as indicating the need to examine collinearity. All of our values are below 2, so these diagnostics do not indicate serious multicollinearity in this candidate model. We will not remove any of the six predictors solely because of multicollinearity. This does not establish that the model is optimal or that its other assumptions are satisfied.
