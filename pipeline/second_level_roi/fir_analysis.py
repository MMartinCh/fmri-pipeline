from pathlib import Path
import pandas as pd

# Get files and build df
base_path = Path(__file__).parent.parent.parent.resolve()
roi_path = base_path / "analysis" / "roi_analysis"/ "roi_outputs"

brain_region = "left_OFA"
fir_files = [f for f in roi_path.glob(f"*{brain_region}_fir.txt")]

# Build df and sort values to conditions
df = pd.DataFrame(columns= ["subject", "condition", "time_point"])

for subj_i, file in enumerate(fir_files):
    print(f"Extract time points for vp{subj_i + 1}")

    rows = []
    with open(file, 'r') as f:
        for line in f:
            row = [float(x) for x in line.split()]
            rows.append(row)

    for row in rows:
        for i, v in enumerate(row):
            if i == 0:
                df.loc[len(df)] = {"subject": subj_i + 1, "condition": "congruent", "time_point": v}
            elif i == 1:
                df.loc[len(df)] = {"subject": subj_i + 1, "condition": "incongruent", "time_point": v}
            elif i == 2:
                df.loc[len(df)] = {"subject": subj_i + 1, "condition": "neutral", "time_point": v}

# Collapse time_points to condition averages for subject and safe to csv
df = df.groupby(["subject", "condition"], as_index=False).mean()
df.to_csv(roi_path / f"{brain_region}.csv", index= False)

# Check df
df.info()
print(df.head(12))
print("...")

# =================
# Estimate repeated-measures ANOVA time_points ~ condition (per subject)
from statsmodels.stats.anova import AnovaRM

anova = AnovaRM(data = df, 
                depvar= "time_point",
                subject= "subject",
                within= ["condition"])

print(anova.fit())
