# Import Salmon transcript-level quantification and summarise to gene level.
suppressPackageStartupMessages({library(tximport); library(readr)})

args <- commandArgs(trailingOnly = TRUE)
samples_file <- args[1]; tx2gene_file <- args[2]
out_rds <- args[3];      out_counts <- args[4]

samples <- read_tsv(samples_file, show_col_types = FALSE)
tx2gene <- read_tsv(tx2gene_file, show_col_types = FALSE)

files <- file.path("results/salmon", samples$sample, "quant.sf")
names(files) <- samples$sample
stopifnot(all(file.exists(files)))

txi <- tximport(files, type = "salmon", tx2gene = tx2gene, dropInfReps = TRUE)
saveRDS(txi, out_rds)

counts <- data.frame(gene_id = rownames(txi$counts), round(txi$counts, 2), check.names = FALSE)
write_tsv(counts, out_counts)
cat("genes:", nrow(txi$counts), " samples:", ncol(txi$counts), "\n")
