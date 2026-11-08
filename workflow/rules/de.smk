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
