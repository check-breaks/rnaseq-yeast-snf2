# Differential expression (mutant vs wild type) with DESeq2, plus PCA and volcano plot.
suppressPackageStartupMessages({library(DESeq2); library(readr); library(ggplot2); library(ggrepel)})

args <- commandArgs(trailingOnly = TRUE)
samples_file <- args[1]; txi_rds <- args[2]
out_res <- args[3]; out_pca <- args[4]; out_volcano <- args[5]

samples <- read_tsv(samples_file, show_col_types = FALSE)
txi <- readRDS(txi_rds)

coldata <- data.frame(condition = factor(samples$condition, levels = c("wt", "mu")),
                      row.names = samples$sample)
stopifnot(identical(rownames(coldata), colnames(txi$counts)))

dds <- DESeqDataSetFromTximport(txi, colData = coldata, design = ~ condition)
dds <- dds[rowSums(counts(dds)) >= 10, ]
cat("genes kept after filtering:", nrow(dds), "\n")
dds <- DESeq(dds)

res <- results(dds, contrast = c("condition", "mu", "wt"))
resdf <- data.frame(gene_id = rownames(res), as.data.frame(res))
resdf <- resdf[order(resdf$padj), ]
write_tsv(resdf, out_res)

sig <- !is.na(resdf$padj) & resdf$padj < 0.05
cat("padj < 0.05:", sum(sig), " up in mutant:", sum(sig & resdf$log2FoldChange > 0),
    " down in mutant:", sum(sig & resdf$log2FoldChange < 0), "\n")

# PCA on variance-stabilised counts
vsd <- vst(dds, blind = TRUE)
pca <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
pv <- round(100 * attr(pca, "percentVar"))
p1 <- ggplot(pca, aes(PC1, PC2, colour = condition, label = name)) +
  geom_point(size = 3) + geom_text_repel(show.legend = FALSE) +
  xlab(paste0("PC1: ", pv[1], "% variance")) + ylab(paste0("PC2: ", pv[2], "% variance")) +
  theme_bw()
ggsave(out_pca, p1, width = 6, height = 4.5, dpi = 150)

# Volcano plot
plotdf <- resdf[!is.na(resdf$padj), ]
plotdf$status <- ifelse(plotdf$padj < 0.05 & abs(plotdf$log2FoldChange) > 1, "significant", "not significant")
top <- head(plotdf[plotdf$status == "significant", ], 10)
p2 <- ggplot(plotdf, aes(log2FoldChange, -log10(padj), colour = status)) +
  geom_point(size = 0.8, alpha = 0.6) +
  geom_text_repel(data = top, aes(label = gene_id), size = 3, show.legend = FALSE) +
  scale_colour_manual(values = c("not significant" = "grey60", "significant" = "firebrick")) +
  xlab("log2 fold change (mutant / wild type)") + ylab("-log10 adjusted p-value") +
  theme_bw()
ggsave(out_volcano, p2, width = 6, height = 4.5, dpi = 150)
