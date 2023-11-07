#!/bin/bash

# 1. Download info about bacterial genomes from GenBank
domains=( bacteria archaea )
# shellcheck disable=SC2068
for g in ${domains[@]} ; do
        if [[ ! -f assembly_summary."$g".txt ]] ; then
                wget ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/"$g"/assembly_summary.txt
                mv assembly_summary.txt assembly_summary."$g".txt
        fi
done

i=1
# shellcheck disable=SC2013
for gca in $(awk 'NR > 2  {print $1}' *_AssemblyDetails.txt) ; do       #the awk takes the mag name as accessions.list
        echo "$i. $gca"
        i=$((i+1))
        ftp=$(grep $gca assembly_summary.*.txt | cut -f20)       # https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/913/775/275/GCA_913775275.1_S1C17122_SP350
        full_name=$(echo $ftp | sed 's/.*\///')
        mkdir $gca
        wget -O $gca/$gca"_genomic.fna.gz" $ftp/$full_name"_genomic.fna.gz"
done