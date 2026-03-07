from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd

# Get files and build df
base_path = Path(__file__).parent.parent.parent.resolve()

brain_region = "right_OFA"
exclude_vp = ()

roi_path = base_path / "analysis" / "roi_analysis"/ brain_region / "cue_split"
fir_files = [f for f in roi_path.glob(f"*{brain_region}_fir_CS.txt")]

data_array = []

for subj in fir_files:
    subj_id = subj.stem.split("_")[0]

    if not subj_id in exclude_vp:
        with open(subj, "rb") as f:
            for i, line in enumerate(f):
                con, incon_real, incon_fake, neut_real, neut_fake = map(float, line.split())

                data_array.append({
                    "subject": subj_id,
                    "tp_i": i + 1,
                    "Congruent": con,
                    "Incongruent_Real": incon_real,
                    "Incongruent_Fake": incon_fake,
                    "Neutral_Real": neut_real,
                    "Neutral_Fake": neut_fake,
                })

    else:
        print(f"Subject {subj_id} excluded.")

df = pd.DataFrame(data_array)
df = df.groupby("tp_i", as_index=False)[["Congruent", "Incongruent_Real", "Incongruent_Fake", "Neutral_Real", "Neutral_Fake"]].mean()
print(df)

plt.plot(df["tp_i"], df["Congruent"], label="Congruent")
plt.plot(df["tp_i"], df["Incongruent_Real"], label="Incongruent_Real")
plt.plot(df["tp_i"], df["Incongruent_Fake"], label="Incongruent_Fake")
plt.plot(df["tp_i"], df["Neutral_Real"], label="Neutral_Real")
plt.plot(df["tp_i"], df["Neutral_Fake"], label="Neutral_Fake")

plt.xlabel("Timepoint")
plt.ylabel("Beta")
plt.legend()
plt.show()
