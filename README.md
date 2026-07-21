#El Salvador's "estado de excepción" and its economic effects
Independent research project, summer 2026 -MSc Economics, ISEG Lisbon

#What this is about
In March 2022, El Salvador declared a state of emergency and started mass-arresting alleged gang members under Bukele's security crackdown. I wanted to know whether this had any measurable effect on the economy, pecifically on GDP growth and FDI inflows, using the synthetic control method.
The idea behind synthetic control: since El Salvador didn't have a real "twin" that didn't get the policy, you build one artificially by combining other Latin American countries that, before 2022, looked similar to El Salvador on the relevant macro and institutional variables. Then you compare what actually happened to El Salvador after 2022 against what the synthetic version would have predicted.

#Data
World Bank WDI for GDP growth and FDI, UNODC for homicide rates (used as a predictor since it's directly tied to the policy's stated goal). Panel of 12 Latin American countries, 2010–2024.

#What I found
GDP growth: nothing. No meaningful deviation between El Salvador and its synthetic counterfactual across any specification I tried.
FDI: there's a hint of something: a positive gap opening up in 2023–2024, but it's not statistically significant (p around 0.2 with tidysynth, 0.159 with augsynth in the specifications where it looks strongest).
I ran this two ways: tidysynth for the standard synthetic control estimation, and augsynth (the ridge-regularized version) as a cross-check,plus placebo tests and a few robustness checks (dropping outlier countries, adding GDP per capita as a predictor, extending the time window).

#Scripts
•	el_salvador.R - building the panel from raw WDI/UNODC data
•	02_eda.R - exploratory plots before running anything
•	03_synthetic_control.R - main tidysynth estimation, placebos, robustness
•	04_augsynth.R - augsynth cross-check

#Main references
Abadie (2021) on synthetic control methodology; Pinotti (2015) on the economic costs of organized crime in Southern Italy as a related identification strategy.


Full paper still in progress.

Edoardo Gentilini — LinkedIn — gentilini.edoardo02@gmail.com

