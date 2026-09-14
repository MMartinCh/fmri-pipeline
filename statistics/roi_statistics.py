from pathlib import Path
import numpy as np
import pandas as pd

# Get files and build df
BASE_PATH = Path(__file__).parent.parent

brain_region = "right_FFA"
exclude_vp = ()

roi_path = BASE_PATH / "outputs" / "roi_analysis" / brain_region
fir_files = [f for f in roi_path.glob(f"*{brain_region}_fir.txt")]

print(roi_path)
print(len(fir_files))

# Build df and sort values to conditions
df = pd.DataFrame(columns= ["subject", "condition", "time_point"])

for subj_i, file in enumerate(fir_files):
    subj_id = file.stem.split("_")[0]
    
    rows = []

    if not subj_id in exclude_vp:
        print(f"Extract time points for {subj_id}")

        with open(file, 'r') as f:
            lines = f.readlines()

            row5 = [float(x) for x in lines[4].split()]
            row6 = [float(x) for x in lines[5].split()]

            peak = [np.mean([v5, v6]) for v5, v6 in zip(row5, row6)]
            rows.append(peak)

        for row in rows:
            for i, v in enumerate(row):
                if i == 0:
                    df.loc[len(df)] = {"subject": subj_i + 1, "condition": "congruent", "time_point": v}
                elif i == 1:
                    df.loc[len(df)] = {"subject": subj_i + 1, "condition": "incongruent", "time_point": v}
                elif i == 2:
                    df.loc[len(df)] = {"subject": subj_i + 1, "condition": "neutral", "time_point": v}

    else:
        print(f"Subject {subj_id} excluded.")

# Collapse time_points to condition averages for subject and safe to csv
df = df.groupby(["subject", "condition"], as_index=False).mean()

# Check df
print(df.head(12))
print("...")

# ======================================================================
import pingouin as pg

# Repeated-measures ANOVA using Pingouin
anova = pg.rm_anova(
    data=df,
    dv="time_point",
    within="condition",
    subject="subject",
    detailed=True,
    correction="auto"
)

print("=== REPEATED MEASURES ANOVA RESULTS ===")
print(anova)
print("\n" + "="*40 + "\n")

posthoc = None
if (anova["p_unc"] <= .05).any():
    posthoc = pg.pairwise_tests(
        data=df,
        dv="time_point",
        within="condition",
        subject="subject",
        padjust="holm"
    )

print("=== POST-HOC PAIRWISE TESTS ===")
print(posthoc if posthoc else "No post-hoc test conducted.")