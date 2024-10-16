#!/bin/bash

export PATH=${HOME}/edirect:${PATH}

function download_mags() {
  path=$1
  i=1
  for gca in $(awk 'NR > 2 {print $1}' "$path"/*_AssemblyDetails.txt); do
    echo "$i. $gca"
    i=$((i + 1))
    ftp=$(esearch -db assembly -query "$gca" | efetch -format docsum | xtract -pattern DocumentSummary -element FtpPath_GenBank)
    full_name=$(echo "$ftp" | sed 's/.*\///')
    output_dir="$path/$gca"
    mkdir -p "$output_dir"

    # Download genomic.fna.gz file using curl
    curl -o "$output_dir/${gca}_genomic.fna.gz" "$ftp/${full_name}_genomic.fna.gz"

    # Optional: Check the file size to ensure it's not an empty or incomplete download
    file_size=$(stat -c%s "$output_dir/${gca}_genomic.fna.gz")

    if [ "$file_size" -eq 0 ]; then
      echo "Error: Empty or incomplete download for ${gca}_genomic.fna.gz. Retrying download..."
      rm "$output_dir/${gca}_genomic.fna.gz"
      curl -o "$output_dir/${gca}_genomic.fna.gz" "$ftp/${full_name}_genomic.fna.gz"
      file_size=$(stat -c%s "$output_dir/${gca}_genomic.fna.gz")

      if [ "$file_size" -eq 0 ]; then
        echo "Error: Unable to download ${gca}_genomic.fna.gz."
        # Handle error as needed (e.g., report the issue, skip the problematic file, etc.)
      fi
    fi

  done
}

# Usage
download_mags "/data2/MAGs-data/test_dir/root_temp"
