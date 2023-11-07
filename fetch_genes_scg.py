# Import the SeqIO module from Biopython
import os
import sys
import subprocess
from Bio.SeqRecord import SeqRecord
from Bio import SeqIO

gene2scg = {}
scg2protein = {}
scg2gene = {}
root_dir = sys.argv[1]  # "/data2/ESCO/WIS
mag_dir = root_dir + "/MAGs"
protein_dir = os.path.join(root_dir, "scg/protein.scg/")
genome_dir = os.path.join(root_dir, "scg/genome.scg/")
os.makedirs(protein_dir, exist_ok=True)
os.makedirs(genome_dir, exist_ok=True)
gtdbtk_dir = root_dir + "/gtdbtk"  # "/data2/ESCO/WIS/MAGs/group1_copy/group1_gtdbtk_copy"
counter = 0
for mag in os.listdir(mag_dir):
    print(mag)
    try:
        gtdbtk_tax = subprocess.check_output(f"awk 'NR>1 && $1==\"{mag}\" {{print $2}}' {gtdbtk_dir}/*/gtdbtk.*.summary.tsv",
                                             shell=True, stderr=subprocess.STDOUT, text=True)
        print(gtdbtk_tax)
    except subprocess.CalledProcessError as e:
        print(f"Command failed with error: {e}")
    # gtdbtk_tax = os.system(f"awk '{{if ($1==\"{mag}\") print $2;}}' {gtdbtk_dir}/gtdbtk.*.summary.tsv")
    # can use regex: awk '{print $2;}' ./group*/gtdbtk.group*.ar53.summary.tsv
    scg_records = SeqIO.parse(f"{root_dir}/MAGs/{mag}/{mag}.scg.faa", "fasta")
    for scg_record in scg_records:
        gene_protein_id = scg_record.id
        scg_name = scg_record.description.split()[1].split("NAME=")[1]
        update_gene2scg = {gene_protein_id: scg_name}
        gene2scg.update(update_gene2scg)
    # print(gene2scg)

    protein_records = SeqIO.parse(f"{root_dir}/MAGs/{mag}/{mag}_proteins.faa", "fasta")
    for protein_record in protein_records:
        protein_id = protein_record.id  # k99_40984_47
        if protein_id in gene2scg:
            protein_name = gene2scg[protein_id]  # ribosomal_protein_L11
            fasta_record = SeqRecord(protein_record.seq,
                                     id=f"{protein_id}...{mag}{counter}", description=f"{gtdbtk_tax}")
            #  id = f"{protein_id}...{mag}{counter}", description = f"{gtdbtk_tax}")
            if protein_name in scg2protein:
                scg2protein[protein_name].append(fasta_record)
            else:
                update_scg2protein = {protein_name: [fasta_record]}
                scg2protein.update(update_scg2protein)

    gene_records = SeqIO.parse(f"{root_dir}/MAGs/{mag}/{mag}_genes.fna", "fasta")
    for gene_record in gene_records:
        gene_id = gene_record.id  # k99_40984_47
        if gene_id in gene2scg:
            gene_name = gene2scg[gene_id]  # ribosomal_protein_L11
            fasta_record = SeqRecord(gene_record.seq, id=f"{mag}...{gene_id}{counter}")
            if gene_name in scg2gene:
                scg2gene[gene_name].append(fasta_record)
            else:
                update_scg2gene = {gene_name: [fasta_record]}
                scg2gene.update(update_scg2gene)
    counter = counter + 1

for protein_name in scg2protein.keys():
    SeqIO.write(scg2protein[protein_name],
                f"{protein_dir}/{protein_name}.proteins.faa", "fasta")

for gene_name in scg2gene.keys():
    SeqIO.write(scg2gene[gene_name], f"{genome_dir}/{gene_name}.genes.faa",
                "fasta")
