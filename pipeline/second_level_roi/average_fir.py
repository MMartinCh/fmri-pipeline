from pathlib import Path
import pandas as pd

# Get files and build df
base_path = Path(__file__).parent.parent.parent.resolve()

brain_region = "right_FFA"

roi_path = base_path / "analysis" / "roi_analysis"/ brain_region
fir_files = [f for f in roi_path.glob(f"*{brain_region}_fir.txt")]

data_array = []

for subj in fir_files:
    subj_id = (subj.stem).split("_")[0]

    with open(subj, "rb") as f:
        for i, line in enumerate(f):
            con, incon, neut = map(float, line.split())

            data_array.append({
                "subject": subj_id,
                "tp_i": i + 1,
                "Congruent": con,
                "Incongruent": incon,
                "Neutral": neut,
            })

df = pd.DataFrame(data_array)
print(df.head(10))

out_path_csv = roi_path.parent / "df_outputs" / f"{brain_region}_all_tc.csv"
out_path_xlsx = roi_path.parent / "df_outputs" / f"{brain_region}_all_tc.xlsx"
df.to_csv(out_path_csv, index= False)
df.to_excel(out_path_xlsx, index= False)
