# Q4 E Model specification, selection, diagnostics and prediction

Reproducibility: run from the project root with `source("scripts/06_E_Q4_models.R")`. The script uses C's trial_v1 working data (`qq_work`) and the same 843 complete records as D's exploratory analysis. Tables Q4-E1 to Q4-E5 are in `results/Q4/E_tables/`; Figures Q4-E1 and Q4-E2 are in `figures/Q4_E/`.

## Q4 3c Model specification and selection

The response log(streams) is continuous and approximately symmetric after the log transformation shown in Figure Q4-D2, so we fitted generalized linear models with the Gaussian family and identity link using `glm()`; this is equivalent to ordinary linear regression on the log scale. Following the research question, we compared three nested candidate models:

- m1: log(streams) ~ log(in_QQ_playlists)
- m2: log(streams) ~ log(in_QQ_playlists) + artist_count + released_year
- m3: log(streams) ~ log(in_QQ_playlists) + artist_count + released_year + danceability_% + energy_% + acousticness_%

Adding artist count and release year improves fit significantly (nested F test: F = 9.288, p < 0.001), whereas adding the three audio features does not (F = 0.842, p = 0.471). The AIC agrees: 1876.172, 1861.700 and 1865.156 for m1, m2 and m3 respectively, so m2 is preferred by both criteria. The final model is therefore

log(streams) = 3.157 + 0.689 · log(in_QQ_playlists) − 0.114 · artist_count + 0.006 · released_year,

fitted on n = 843 songs with residual deviance 443.92 on 839 degrees of freedom (R-squared = 0.614). Variance inflation factors for the final model are at most 1.192, consistent with D's candidate-set check of 1.058 to 1.627, so multicollinearity is not a concern.

Two coefficients in context. First, the elasticity of playlist inclusion is 0.689 (95% CI [0.649, 0.729], t = 33.790, p < 0.001): each 1% increase in the number of QQ Music playlists including a song is associated with an approximately 0.689% higher geometric-mean stream count, holding artist count and release year fixed; doubling playlist inclusions corresponds to a multiplicative factor of 2^0.689 ≈ 1.616, i.e. about 61.6% higher streams. Second, each additional contributing artist is associated with a multiplicative factor of e^(−0.114) ≈ 0.892 (95% CI for the coefficient [−0.173, −0.055], p < 0.001), that is, about 10.8% lower streams for collaborations of a given playlist exposure and release year. The release-year coefficient is small and positive (0.006, 95% CI [0.001, 0.010], p = 0.025); we interpret it cautiously because release year is an imperfect proxy for time available to accumulate streams. The elasticity estimate is essentially unchanged across m1, m2 and m3 (0.678, 0.689 and 0.692; Table Q4-E2), so the adjusted association between playlist inclusion and streams is robust to which controls enter the model.

## Q4 3d Diagnostics and prediction

Figure Q4-E1 shows the four standard residual plots for the final model. Residuals against fitted values show no remaining systematic curvature, supporting the linearity of the log-log specification. The normal Q-Q plot is close to linear in the centre with somewhat heavier tails, which is common for large observational datasets; the residual-vs-log-playlists plot (Figure Q4-E2) shows no trend in location or spread across the observed range of playlist inclusions. The scale-location plot shows mildly increasing spread at high fitted values, indicating mild heteroscedasticity rather than a structural failure. The largest Cook's distance is 0.184 ("Dream On"), with all values far below levels that would indicate a single influential observation, so no records were removed.

For prediction we defined a plausible scenario within the observed predictor ranges: a song included in the median number of playlists (2,313), with the median artist count (1) and median release year (2022). The predicted mean log streams is 19.606. The 95% confidence interval for the mean response is [306.753, 346.730] million streams: with 95% confidence, the average log streams of songs with these characteristics lies in this range on the original scale. The 95% prediction interval for a single new song with these characteristics is much wider, [78.281, 1358.702] million streams, because it additionally accounts for song-to-song variability; the width of this interval reflects the large residual variation in individual streaming outcomes.

## Q4 3e Conclusion and model justification

We answered the research question with a Gaussian GLM on log(streams), selecting the final model by nested F tests and AIC among three candidates that progressively added artist count and release year, then the three audio features. Both criteria preferred the model with playlist inclusion, artist count and release year (AIC = 1861.700); the audio features added no significant improvement (p = 0.471) and did not change the substantive conclusion.

The central finding is a strong, robust positive adjusted association between playlist inclusion and streams: the elasticity is 0.689 (95% CI [0.649, 0.729]), stable at 0.678–0.692 across all candidate models, so songs included in more QQ Music playlists have substantially higher stream counts even after accounting for artist count, release year and audio characteristics. Collaborations are associated with about 10.8% lower streams at equal playlist exposure. For the QQ Music team, this quantifies how strongly playlist reach tracks streaming performance and supports treating playlist placement as a key visibility lever, although reverse causality is plausible: popular songs are also more likely to be added to playlists.

Limitations: the data are observational, so coefficients describe associations rather than causal effects of playlist placement; unmeasured factors such as label promotion and artist fame may drive both inclusion and streams; release year imperfectly measures accumulation time; diagnostics indicate mildly heavy-tailed residuals and mild heteroscedasticity; and the wide prediction interval shows that individual song outcomes remain highly variable. (approx. 250 words)
