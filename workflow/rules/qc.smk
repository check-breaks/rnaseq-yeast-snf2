rule fastqc:
    """Per-sample read quality report."""
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        html="results/fastqc/{sample}_fastqc.html",
        zip="results/fastqc/{sample}_fastqc.zip",
    log:
        "logs/fastqc_{sample}.log"
    conda:
        "../envs/fastqc.yaml"
    shell:
        "fastqc -q --outdir results/fastqc {input} > {log} 2>&1"

rule multiqc:
    """Combine all FastQC reports into one page."""
    input:
        expand("results/fastqc/{sample}_fastqc.zip", sample=SAMPLES)
    output:
        "results/multiqc/multiqc_report.html"
    log:
        "logs/multiqc.log"
    conda:
        "../envs/multiqc.yaml"
    shell:
        "multiqc -f -o results/multiqc -n multiqc_report.html results/fastqc > {log} 2>&1"
