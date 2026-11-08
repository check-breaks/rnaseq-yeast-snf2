#!/usr/bin/env bash
# Rebuild the run table and the seeded 3 vs 3 sample selection from ENA metadata.
# Usage: bash workflow/scripts/select_samples.sh OUTDIR
# Inputs (committed): metadata/ena_PRJEB5348.tsv, metadata/ena_PRJEB5348_alias.tsv
set -euo pipefail
OUT=${1:?usage: select_samples.sh OUTDIR}
LANE=3
SEED=42
mkdir -p "$OUT"

# 1. run table: run, condition, alias, library ID (from file name), lane (from file name)
awk -F'\t' 'NR>1{n=split($6,a,"/"); split(a[n],p,"_"); lib=p[5]; sub(/\..*/,"",lib); split($2,c,"_"); print $1"\t"c[1]"\t"$2"\t"lib"\t"p[4]}' \
  metadata/ena_PRJEB5348_alias.tsv > "$OUT/run_table.tsv"

# 2. pick 3 wild type + 3 mutant: fixed lane, excluding library SA-PE-039 (mislabelled run), fixed seed
: > "$OUT/picked.tsv"
for cond in wt mu; do
  awk -F'\t' -v c=$cond -v l=$LANE '$2==c && $5==l && $4!="SA-PE-039"' "$OUT/run_table.tsv" \
    | shuf --random-source=<(yes $SEED) -n 3 >> "$OUT/picked.tsv"
done

# 3. sample table used by the workflow
awk -F'\t' 'BEGIN{OFS="\t"} NR==FNR{c[$1]=$2; l[$1]=$4; next} ($1 in c){print c[$1]"_"l[$1], c[$1], $1, $5, "https://"$6}' \
  "$OUT/picked.tsv" metadata/ena_PRJEB5348.tsv | sort -k2,2 -k1,1 > "$OUT/samples.body"
(printf 'sample\tcondition\trun\tbytes\turl\n'; cat "$OUT/samples.body") > "$OUT/samples.tsv"
rm "$OUT/samples.body"
