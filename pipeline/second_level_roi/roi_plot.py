from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd

# Get files and build df
base_path = Path(__file__).parent.parent.parent.resolve()

brain_region = "left_OFA"

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
df = df.groupby("tp_i", as_index=False)[["Congruent", "Incongruent", "Neutral"]].mean()
print(df.head(10))

plt.plot(df["tp_i"], df["Congruent"], label="Congruent")
plt.plot(df["tp_i"], df["Incongruent"], label="Incongruent")
plt.plot(df["tp_i"], df["Neutral"], label="Neutral")

plt.xlabel("Timepoint")
plt.ylabel("Beta")
plt.legend()
plt.show()
