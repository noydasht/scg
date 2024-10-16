#!/bin/bash

export PATH=${HOME}/edirect:${PATH}
source md5_util.sh

function download_mags() {
  path=$1
  i=1
  for gca in $(awk 'NR > 2 {print $1}' "$path"/*_AssemblyDetails.txt); do
    echo "$i. $gca"
    i=$((i + 1))
    ftp=$(esearch -db assembly -query "$gca" | efetch -format docsum | xtract -pattern DocumentSummary -element FtpPath_GenBank)
    #the output format is ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/020/063/845/GCA_020063845.1_ASM2006384v1
    full_name=$(echo "$ftp" | sed 's/.*\///')
    #GCA_020063845.1_ASM2006384v1
    output_dir="$path/$gca"
    mkdir -p "$output_dir"
    gz_file_location="$output_dir/${gca}_genomic.fna.gz"
    md_txt_location="$output_dir/md5checksums.txt"
    wget -O "$md_txt_location" "$ftp/md5checksums.txt"
    wget -O "$gz_file_location" "$ftp/${full_name}_genomic.fna.gz"
    verify_checksums "$gz_file_location" "$md_txt_location"
    if [[ $? -eq 1 ]]; then
      max_retries=2
      attempt=0
      while [ $attempt -le $max_retries ]; do
        echo "checksums are not equal, retry attempt $attempt / 3"
        rm $gz_file_location
        wget -O "$gz_file_location" "$ftp/${full_name}_genomic.fna.gz"
        verify_checksums "$gz_file_location" "$md_txt_location"
        if [[ $? -eq 1 && attempt -eq 2 ]]; then
          echo "checksums are not equal after 3 attempts, exit."
          exit 1
        elif [[ $? -eq 1 ]]; then
            ((attempt++))
        else
          echo "checksums are  equal, $attempt"
         attempt=3
        fi
      done
    fi
  done
}