#!/bin/bash
source scg_creating_file_dir.sh
source prodigal_scg_extraction.sh
source gtdbtk.sh
source checkm.sh

path=$1
creating_file_dir "$path"
#creating_mags_dir_with_fna_zip "$path"
prodigal_scg_extraction "$path"
gtdbtk_run "$path"
python3 /home/noyd/scripts/scg/fetch_genes_scg.py "$path"
checkm_running "$path"
python3 /home/noyd/scripts/scg/summary.py "$path"