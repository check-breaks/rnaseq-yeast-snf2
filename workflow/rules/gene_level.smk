rule tx2gene:
    """Transcript-to-gene table, taken from the 'gene:' field in the Ensembl cDNA FASTA headers."""
    input:
        "resources/cdna.fa.gz"
    output:
        "resources/tx2gene.tsv"
    shell:
        r"""
        (printf 'transcript_id\tgene_id\n'
         zcat {input} | awk '/^>/{{tx=substr($1,2); for(i=2;i<=NF;i++) if($i ~ /^gene:/){{print tx "\t" substr($i,6); break}}}}') > {output}
        """
