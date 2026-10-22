# Climate and Health Epidemiology

## Project status and data disclaimer

**This is a methodological training project using entirely synthetic data.**
The dataset does not represent real patients, actual regions, or observed
population health events. Results must not be interpreted as real-world
scientific evidence or used to guide clinical or public-health decisions.

## Research question

How are daily mean temperature and simulated cardiovascular and respiratory
case counts associated in this fictional dataset?

## Dataset

- Region-day records: 15000
- Fictional regions: 5
- Study period: 2018-01-01 to 2026-03-19
- Mean temperature: 28.875 °C

## Methods

Exploratory analysis used descriptive statistics and plots.
Separate Poisson regression models were fitted for cardiovascular and
respiratory counts. Models included mean temperature, humidity, rainfall,
region, month, and a log-population offset.

Rate ratios are reported per 1°C increase in mean temperature, with
Wald 95% confidence intervals. Pearson dispersion statistics were
calculated as a preliminary diagnostic.

## Results

- Total simulated cardiovascular cases: 420402
- Total simulated respiratory cases: 419629

| Outcome | Rate ratio | 95% CI lower–upper | p-value |
|---|---:|---:|---:|
| Cardiovascular cases | 1.012 | 1.011–1.013 | <2e-16 |
| Respiratory cases | 1.008 | 1.007–1.009 | <2e-16 |

### Preliminary model diagnostics

- Cardiovascular cases: Pearson dispersion = 0.984
- Respiratory cases: Pearson dispersion = 0.995

Dispersion values near 1 are broadly consistent with the Poisson variance
assumption, but do not alone establish model adequacy. Residual patterns,
sensitivity analyses, temporal structure, and alternative count models
should be examined before drawing methodological conclusions.

## Interpretation

The estimated associations describe the behavior of a simulated dataset
whose outcomes were generated using predefined rules. They do not establish
that temperature causes changes in cardiovascular or respiratory health.
Small p-values in synthetic data are not evidence of a real health effect.

## Limitations

- All data are synthetic and do not represent real populations.
- The outcome-generating process includes predefined temperature effects.
- The models do not address all potential temporal dependencies or delayed
  effects of temperature.
- Model diagnostics and sensitivity analyses are preliminary.
- Real-world inference requires validated data and a prespecified study design.

## Reproducibility

Run `06_final_report.R` from the project root in RStudio.
Tables are saved in `outputs/tables/` and figures in `outputs/figures/`.

## Next steps

1. Validate the modeling strategy and diagnostics.
2. Conduct sensitivity analyses and consider nonlinear or lagged effects.
3. If feasible, replace synthetic data with ethically and legally usable
   real data from documented, trustworthy sources.
4. Update this report before presenting any real-world conclusions.
