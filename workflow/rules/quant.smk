rule salmon_quant:
    """Quantify one sample against the decoy-aware index (single-end reads)."""
    input:
        fq="data/raw/{sample}.fastq.gz",
        index="resources/salmon_index",
    output:
        "results/salmon/{sample}/quant.sf"
    params:
        outdir="results/salmon/{sample}"
    threads: 2
    log:
        "logs/salmon_quant_{sample}.log"
    conda:
        "../envs/salmon.yaml"
    shell:
        "salmon quant -i {input.index} -l A -r {input.fq} -p {threads} -o {params.outdir} > {log} 2>&1"
