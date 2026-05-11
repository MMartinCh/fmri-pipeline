# fMRI Preprocessing and Analysis Pipeline

## Fully functional Python and MATLAB workflow used to convert experiment logs, preprocess fMRI data, statistical analysis and visualize results
This workflow was developed to process and analyze the data collected from an experiment on Predictive Processing in the Face-Selective Cortex, conducted for my Master's thesis. It is planned to be restructured and unified, for improved clarity and simplification. 
It handles all steps from log conversion, preprocessing and whole-brain analysis, to ROI extraction and statistical analysis of extracted time-courses.

It contains:
  * /mcf_conversion: Jupyter Notebooks for conversion of csv to SPM-compatable MCF-files
  * /pipeline: MATLAB pipeline handling a standardized SPM workflow of Realignment, Slice-Timing Correction, Co-registration, and Normalization.
  * /analysis: Jupyter Notebooks for statistical analysis and visualization. 

## How to use
The pipeline is used in the following order:
  1. Clone this project.
  2. Setup folder structure in /config/paths.m OR Setup logs.csv and fMRI_images.dcm files to fit the current folder structure.
  3. Run desired MCF-conversion from /mcf_conversion
  4. Run MATLAB workflow from /pipeline/spm_pipeline.m. Specify target data (participant AND runs) and desired output (preprocessing/ analysis/ both).
  5. Run /pipeline/second_level_roi/roi_analysis.m to extract time-courses.
  6. Run /analysis/fir_anova.ipynb for statistical ROI analysis (rm-ANOVA AND posthoc) and visualization.

