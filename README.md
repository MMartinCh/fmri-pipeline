# Reusable fMRI Statistical Parametric Mapping and Inference Testing Software
This repo contains alls software developed for data processing and analysis that was conducted for my [Master's thesis fMRI experiment](https://github.com/MMartinCh/cue-face-experiment). 
It serves purposes of version control, transparency and reproducability.

## Usage
To recreate the data analysis conducted for my experiment, run the modules in the following order:
  1. [MCF conversion](https://github.com/MMartinCh/fmri-pipeline/blob/main/mcf_conversion/mcf_conversion.ipynb) (requires the file format produced in the [experiments software](https://github.com/MMartinCh/cue-face-experiment))
  2. [Full SPM Pipeline](https://github.com/MMartinCh/fmri-pipeline/blob/main/pipeline/spm/full_spm_pipeline.m) (includes preprocessing and first-level estimation for all subjects)
  3. [ROI analysis](https://github.com/MMartinCh/fmri-pipeline/blob/main/pipeline/roi/roi_analysis.m) (second-level ROI FIR-extraction)
  4. [Inference tests](https://github.com/MMartinCh/fmri-pipeline/blob/main/statistics/roi_statistics.py) (group-level inference statistics: rm-ANOVA and conditional posthoc pairwise t-Tests)

## Technology used
First- / Second-Level fMRI Data Analysis:
 - MATLAB (2024)
 - SPM12
 - MarsBaR

MCF Conversion and Statistical Inference:
 - Python 3.13
 - Pandas
 - Numpy
 - Pingouin
