rule download_fastq:
    """Download one FASTQ from ENA and check the file size against ENA's metadata."""
    output:
        "data/raw/{sample}.fastq.gz"
    params:
        url=lambda w: SAMPLES[w.sample]["url"],
        nbytes=lambda w: SAMPLES[w.sample]["bytes"],
    log:
        "logs/download_{sample}.log"
    conda:
        "../envs/download.yaml"
    shell:
        """
        curl -fsS --retry 3 -o {output} {params.url} 2> {log}
        test "$(stat -c %s {output})" -eq {params.nbytes}
        """
