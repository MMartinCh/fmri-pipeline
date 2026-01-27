setwd("D:/thesis-matlab-pipeline/analysis/roi_analysis")
df <- read.csv("roi_pc.csv")

View(df)

t.test(df[, "congruent"])
t.test(df[, "incongruent"])
t.test(df[, "neutral"])
