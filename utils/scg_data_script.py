# Import the SeqIO module from Biopython
import os
import sys
import subprocess

# from multiprocessing import Pool
# num_processes = 10
from Bio.SeqRecord import SeqRecord
from Bio import SeqIO

path = sys.argv[1]

def creating_files_dir():
    execution_path = "/home/noyd/scripts/scg/scg_creating_file_dir.sh"
    subprocess.run(execution_path, shell=True)

def files_extraction():
    genome_list = os.system(f"ls {path}")
    for genome in genome_list:
        print(genome)
    prodigal_script = f"prodigal -i {path}/{genome}/{genome}_genomic.fna -d {path}/{genome}/{genome}_genes.fna -a {path}/{genome}/{genome}_proteins.faa -o {path}/{genome}/{genome}_genomic.gff -f gff"
    subprocess.run(prodigal_script, shell=True)
    os.system(f"cd {path}/{genome}")
    scg_script = f"scg.pl -o {genome} {path}/{genome}/{genome}_proteins.faa"
    subprocess.run(scg_script, shell=True)

def fetching_genes(path):
    gene2scg = {}
    scg2protein = {}
    scg2gene = {}
    groups_list = os.listdir(path)
    groups = [s for s in groups_list if "group" in s]
    counter = 0

    for group in groups:
        root_dir = f"{path}/{group}"
        # print(group)

        for mag in os.listdir(root_dir):
            print(mag)

            scg_records = SeqIO.parse(f"{root_dir}/{mag}/{mag}.scg.faa", "fasta")
            for scg_record in scg_records:
                gene_protein_id = scg_record.id
                scg_name = scg_record.description.split()[1].split("NAME=")[1]
                update_gene2scg = {gene_protein_id: scg_name}
                gene2scg.update(update_gene2scg)
            # print(gene2scg)

            protein_records = SeqIO.parse(f"{root_dir}/{mag}/{mag}_proteins.faa", "fasta")
            for protein_record in protein_records:
                protein_id = protein_record.id  # k99_40984_47
                if protein_id in gene2scg:
                    protein_name = gene2scg[protein_id]  # ribosomal_protein_L11
                    fasta_record = SeqRecord(protein_record.seq, id=f"{mag}...{protein_id}{counter}")
                    if protein_name in scg2protein:
                        scg2protein[protein_name].append(fasta_record)
                    else:
                        update_scg2protein = {protein_name: [fasta_record]}
                        scg2protein.update(update_scg2protein)

            gene_records = SeqIO.parse(f"{root_dir}/{mag}/{mag}_genes.fna", "fasta")
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
                    f"/data1/GBCP/marker-genes-mining/data/WIS/protein.scg/{protein_name}.proteins.faa", "fasta")

    for gene_name in scg2gene.keys():
        SeqIO.write(scg2gene[gene_name], f"/data1/GBCP/marker-genes-mining/data/WIS/genome.scg/{gene_name}.genes.faa",
                    "fasta")

# if __name__ == '__main__':
#     with Pool(num_processes) as p:
#         result = p.map(my_function, range(10))
