from pathlib import Path
import pandas as pd

# Get files and build df
base_path = Path(__file__).parent.parent.parent.resolve()

brain_region = "right_FFA"

roi_path = base_path / "analysis" / "roi_analysis"/ brain_region
fir_files = [f for f in roi_path.glob(f"*{brain_region}_fir.txt")]

# Build df and sort values to conditions
df = pd.DataFrame(columns= ["row_i", "values"])

for file in fir_files:

    rows = []
    with open(file, 'r') as f:
        for line in f:
            row = [float(x) for x in line.split()]
            rows.append(row)

    # Average all lines for all participants per condition

    for i, row in enumerate(rows):
        df["row_i"] = i
        df["values"] = row

print(df.head())