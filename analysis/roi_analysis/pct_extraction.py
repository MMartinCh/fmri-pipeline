from pathlib import Path
import csv
import pandas as pd

def mean(vector):
    return sum(vector) / len(vector)

base_path = Path(__file__).parent.resolve()

pct_files = [f for f in base_path.glob("*_pc.txt")]

exp_condition_values = {
        "congruent": [],
        "incongruent": [],
        "neutral": [],
    }

for file in pct_files:
    
    subj_condition_values = {
        "congruent": [],
        "incongruent": [],
        "neutral": [],
    }

    with open(file, 'r') as f:
        values = f.read().split()
        values = [float(v) for v in values]

    for i, value in enumerate(values):
        idx = i % 5

        if idx == 0:
            subj_condition_values["congruent"].append(value)
        elif idx in (1, 2):
            subj_condition_values["incongruent"].append(value)
        elif idx == 3:
            subj_condition_values["neutral"].append(value)

    for condition, value_list in subj_condition_values.items():
        exp_condition_values[condition].append(mean(value_list))

output_file = base_path / "roi_pc.csv"
pd.DataFrame(exp_condition_values).to_csv(output_file, index= False)
print(f"File saved to {output_file}")