import subprocess
import os
import sys
from Bio import SeqIO

path = sys.argv[1]
mag_list = [item.strip() for item in subprocess.check_output(f"ls -l {path}/MAGs | awk '{{print $9}}'", shell=True).decode("utf-8").split('\n') if item.strip()]
total_bps = 0

output_file = f"/{path}/summary_file.txt"
with open(output_file, "w") as file:
    file.write("MAG\tMag_Dir\tContigs_Num\tTotal_BPs\tGenes_Num\tCompleteness\tContamination\tCheckM_Version\tGTDBTK_Taxonomy\tGTDBTK_Version\n")

for mag in mag_list:
    mag_name = mag
    mag_dir = f"{path}/MAGs/{mag_name}"
    contigs_num = subprocess.check_output(f"grep -c '^>' {mag_dir}/{mag_name}_genomic.fna", shell=True, text=True).strip()
    for record in SeqIO.parse(f"{mag_dir}/{mag_name}_genomic.fna", "fasta"):
        total_bps += len(record.seq)
    try:
        genes_num = subprocess.check_output(f"grep -c '^>' {mag_dir}/{mag_name}_genes.fna", shell=True, text=True, encoding="utf-8").strip()
    except subprocess.CalledProcessError as e:
        print(f"Ignoring error for {mag_name} - Genes_Num: {e}")
        genes_num = "N/A"
    completeness = subprocess.check_output(f"awk -F'\t' '$1 == /{mag}/_proteins {{print $12}}' {path}/checkm/checkm.stdout", shell=True, text=True).strip()
    contamination = subprocess.check_output(f"awk -F'\t' '$1 == /{mag}/_proteins {{print $13}}' {path}/checkm/checkm.stdout", shell=True, text=True).strip()
    checkm_version = subprocess.check_output(f"awk 'NR == 1 {{print $5}}' {path}/checkm/checkm.log", shell=True, text=True).strip()
    gtdbtk_tax = subprocess.check_output(f"grep -w {mag} {path}/gtdbtk/gtdbtk.*.summary.tsv | awk -F'\t' '{{print $2}}'", shell=True, text=True).strip()
    # gtdbtk_tax = subprocess.check_output(f"grep -w {mag}_genomic {path}/gtdbtk/gtdbtk.*.summary.tsv | awk -F'\t' '{{print $2}}'", shell=True, text=True).strip()
    gtdbtk_version = subprocess.check_output(f"awk 'NR == 1 {{print $5}}' {path}/gtdbtk/gtdbtk.log", shell=True, text=True).strip()
    with open(output_file, "a") as file:
        file.write(f"{mag_name}\t{mag_dir}\t{contigs_num}\t{total_bps}\t{genes_num}\t{completeness}\t{contamination}\t{checkm_version}\t{gtdbtk_tax}\t{gtdbtk_version}\n")

    # print(mag_name)
    # print(mag_dir)
    # print(contigs_num)
    # print(total_bps)
    # print(genes_num)
    # print(completeness)
    # print(contamination)
    # print(checkm_version)
    # print(gtdbtk_tax)
    # print(gtdbtk_version)