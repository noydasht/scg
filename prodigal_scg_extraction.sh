#!/bin/bash

function prodigal_scg_extraction() {
path=$1
mag_list=$(ls "$path"/MAGs | grep -v scg)
    for mag in $mag_list; do
      taskset -c 0-15 prodigal -i "$path"/MAGs/"$mag"/"${mag}"_genomic.fna -d "$path"/MAGs/"$mag"/"${mag}"_genes.fna -a "$path"/MAGs/"$mag"/"${mag}"_proteins.faa -o "$path"/MAGs/"$mag"/"${mag}"_genomic.gff -f gff
      # shellcheck disable=SC2164
      cd "$path"/MAGs/"$mag"
      taskset -c 0-15 scg.pl -o "$mag" "$path"/MAGs/"$mag"/"${mag}"_proteins.faa
    done
#    mv $path/MAGs/scg $path
}