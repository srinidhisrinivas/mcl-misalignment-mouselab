This folder contains the MATLAB scripts to perform individual and family level Bayesian Model Selection. This step is performed after the MCRL models are fit to the individual participants' data, and a CSV file is created from the notebook `analysis/Model Analysis.ipynb`.

Firstly, spm12 needs to be installed (see instructions https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)

The spm12 folder and its subdirectories must be present in the MATLAB path before running the scripts.

Then, in the files `spm12/spm_BMS.m` and `spm12/spm_compare_families.m`, the following line must be added following the preamble of the function:

`lme = -0.5 * lme`

Generate a single BIC dataset using the notebook `analysis/Model Analysis.ipynb`. The file must have the name <code><condition>_bicall.csv</code>. And must be stored in the folder `misalignment_bic_frames_run2`.

where `<condition>` is `control` or `misaligned`.

The script `misalignment_model_selection.m` performs Bayesian model selection for both a single dataset from each condition. Run this script without arguments.

All results are available as objects in the run environment of the MATLAB script.

