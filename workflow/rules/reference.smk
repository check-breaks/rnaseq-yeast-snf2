rule download_reference:
    """Download the pinned Ensembl transcriptome and genome; check sizes."""
    output:
        cdna="resources/cdna.fa.gz",
        genome="resources/genome.fa.gz",
    params:
        cdna_url=config["reference"]["base_url"] + "/" + config["reference"]["cdna"],
        genome_url=config["reference"]["base_url"] + "/" + config["reference"]["genome"],
        cdna_bytes=config["reference"]["cdna_bytes"],
        genome_bytes=config["reference"]["genome_bytes"],
    log:
        "logs/download_reference.log"
    conda:
        "../envs/download.yaml"
    shell:
        """
        curl -fsS --retry 3 -o {output.cdna} {params.cdna_url} 2> {log}
        curl -fsS --retry 3 -o {output.genome} {params.genome_url} 2>> {log}
        test "$(stat -c %s {output.cdna})" -eq {params.cdna_bytes}
        test "$(stat -c %s {output.genome})" -eq {params.genome_bytes}
        """

rule make_gentrome:
    """Join transcripts + genome; list genome sequence names as decoys."""
    input:
        cdna="resources/cdna.fa.gz",
        genome="resources/genome.fa.gz",
    output:
        gentrome="resources/gentrome.fa.gz",
        decoys="resources/decoys.txt",
    shell:
        """
        zcat {input.genome} | grep '^>' | cut -d' ' -f1 | sed 's/^>//' > {output.decoys}
        cat {input.cdna} {input.genome} > {output.gentrome}
        """

rule salmon_index:
    """Decoy-aware Salmon index (transcripts first, then genome decoys)."""
    input:
        gentrome="resources/gentrome.fa.gz",
        decoys="resources/decoys.txt",
    output:
        directory("resources/salmon_index")
    threads: 2
    log:
        "logs/salmon_index.log"
    conda:
        "../envs/salmon.yaml"
    shell:
        "salmon index -t {input.gentrome} -d {input.decoys} -p {threads} -i {output} > {log} 2>&1"
