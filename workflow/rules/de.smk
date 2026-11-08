rule tximport:
    """Summarise Salmon transcript estimates to gene level."""
    input:
        quant=expand("results/salmon/{sample}/quant.sf", sample=SAMPLES),
        tx2gene="resources/tx2gene.tsv",
        samples=config["samples"],
    output:
        rds="results/tximport/txi.rds",
        counts="results/tximport/gene_counts.tsv",
    log:
        "logs/tximport.log"
    conda:
        "../envs/r_de.yaml"
    shell:
        "Rscript workflow/scripts/tximport.R {input.samples} {input.tx2gene} {output.rds} {output.counts} > {log} 2>&1"

rule deseq2:
    """Differential expression (mutant vs wild type), PCA and volcano plot."""
    input:
        txi="results/tximport/txi.rds",
        samples=config["samples"],
    output:
        res="results/deseq2/de_results.tsv",
        pca="results/deseq2/pca.png",
        volcano="results/deseq2/volcano.png",
    log:
        "logs/deseq2.log"
    conda:
        "../envs/r_de.yaml"
    shell:
        "Rscript workflow/scripts/deseq2.R {input.samples} {input.txi} {output.res} {output.pca} {output.volcano} > {log} 2>&1"
