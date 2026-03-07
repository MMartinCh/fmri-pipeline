from pathlib import Path
import pandas as pd

# Get files and build df
base_path = Path(__file__).parent.parent.parent.resolve()

brain_region = "right_FFA"
exclude_vp = ("vp13", "vp14", "vp16", "vp09", "vp07", "vp17", "vp12", "vp03", "vp02")

roi_path = base_path / "analysis" / "roi_analysis"/ brain_region
fir_files = [f for f in roi_path.glob(f"*{brain_region}_fir.txt")]

# Build df and sort values to conditions
df = pd.DataFrame(columns= ["subject", "condition", "time_point"])

for subj_i, file in enumerate(fir_files):
    subj_id = file.stem.split("_")[0]
    
    rows = []

    if not subj_id in exclude_vp:
        print(f"Extract time points for {subj_id}")

        with open(file, 'r') as f:
            lines = f.readlines()

            row4 = [float(x) for x in lines[3].split()]
            row5 = [float(x) for x in lines[4].split()]
            row6 = [float(x) for x in lines[5].split()]

            peak = [max(v4, v5, v6) for v4, v5, v6 in zip(row4, row5, row6)]
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
df.to_csv(roi_path.parent / "df_outputs" / f"{brain_region}.csv", index= False)

# Check df
df.info()
print(df.head(12))
print("...")

# ======================================================================
from statsmodels.stats.anova import AnovaRM
import pingouin as pg

# Repeated-measures ANOVA for time_points ~ condition (per subject)
anova = AnovaRM(data = df, 
                depvar= "time_point",
                subject= "subject",
                within= ["condition"]
                )

print(anova.fit())

# Post-hoc Pairwise t-Tests
posthoc = pg.pairwise_tests(
    data=df,
    dv="time_point",
    within="condition",
    subject="subject",
    padjust="holm"
)

print(posthoc)