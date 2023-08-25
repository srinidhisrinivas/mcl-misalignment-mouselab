import numpy as np
import statsmodels.formula.api as smf
import json
import pandas as pd
import warnings
import time
from pathlib import Path
import sys
from statsmodels.tools.sm_exceptions import ConvergenceWarning
warnings.simplefilter('ignore', ConvergenceWarning)
# warnings.simplefilter('ignore', UserWarning)

num_samples = int(sys.argv[1])

current_folder = Path(__file__).parent.resolve()
parent_folder = current_folder.parent.resolve()

# Number of simulations per sample size
num_sims = 10

# Number of samples to try
Ns = [num_samples]

# Significance threshold
alpha = 0.05

# Fixed slope + interaction
fs = -0.052376
fs_int = 0.026293

# Random slope
rs_var = 0.0050375

# Fixed Intercept + interaction
fi = 2.117712
fi_int = -0.030976

# Random intercept
ri_var = 0.3086228

rsxri_cov = 0.0192782

# Defining experiment
output_var_name = "expectedScores_scaled"
conditions = [0, 1]
num_trials = 9

# Model Formula
formula = f"{output_var_name} ~ trialNumbers + C(condition) + trialNumbers:C(condition)"
fixed_effects = ["trialNumbers", "C(condition)[T.1]", "trialNumbers:C(condition)[T.1]"]

power_dict = {N: {} for N in Ns}

print_every_sims = 1000

# Generating a dataset:
for N in Ns:
    print(f"Starting for N={N}")
    # For each sample size, simulate num_sims number of experiments
    significance_counts = {e: 0 for e in fixed_effects}
    significance_counts["converged"] = 0
    start = time.time()
    for sim in range(num_sims):
        worker_id = 0
        df_dict = {
            "workerId": [],
            "condition": [],
            output_var_name: [],
            "trialNumbers": []
        }
        # Regressors - condition
        for cond in conditions:
            # Generate N datasets
            for i in range(N):
                worker_id += 1
                # Regressors - trial number - centered
                trialNums = np.array(list(range(1, num_trials + 1)))
                trialNums = trialNums - trialNums.mean()

                res = np.random.multivariate_normal(
                    np.array([fs + cond * fs_int, fi + cond * fi_int]),
                    np.array([[rs_var, rsxri_cov],
                              [rsxri_cov, ri_var]]),
                    num_trials
                )

                # Generate data for response variables with fixed slope and random intercept
                outcomes = np.array(trialNums) * res[:,0] + res[:,1]
                df_dict["workerId"] += [worker_id] * num_trials
                df_dict["condition"] += [cond] * num_trials
                df_dict[output_var_name] += list(outcomes.flatten().astype(float))
                df_dict["trialNumbers"] += list(trialNums)

        gen_df = pd.DataFrame.from_dict(df_dict)

        # Run model on artificial dataset
        glm = smf.mixedlm(formula=formula, data=gen_df, groups=gen_df['workerId'])
        results = glm.fit()

        # See significance of each fixed effect
        for e in fixed_effects:
            pval = results.pvalues[e]
            significance_counts[e] += int(pval < alpha)
        significance_counts["converged"] += int(results.converged)
        if (sim+1) % print_every_sims == 0:
            current_time = time.time()
            print("Finished {0} simulations, time elapsed = {1:0.3f}s".format(sim+1, (current_time-start)))
    power_dict[N] = {k: v/num_sims for (k,v) in significance_counts.items()}

with open(f"{parent_folder}/results/power_analysis/results_{num_sims}_{num_samples}.txt", 'w') as f:
    f.write(json.dumps(power_dict, indent=4))


