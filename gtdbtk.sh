#!/bin/bash
function gtdbtk_run() {
  source /data1/software/gtdb/GTDB-Tk/gtdbtk-2.3.2/.venv/bin/activate
  path=$1 # Change it to get the path from the main script
  files_number=$(ls "$path/MAGs" | wc -l)

  if [ "$files_number" -gt 15000 ]; then
    # Calculate the number of groups needed
    groups_number=$(( (files_number + 14999) / 15000 ))
    for i in $(seq 1 $groups_number); do
      start_idx=$(( (i - 1) * 15000 + 1 ))
      end_idx=$(( i * 15000 ))
      mkdir -p $path/"gtdbtk"/"gtdbtk".$i
      # Use 'awk' to slice the MAGs list for the current group
      find "$path"/MAGs -name "*_genomic.fna" | awk "NR >= $start_idx && NR <= $end_idx" | while read -r genomic; do
        mag=$(echo "$genomic" | awk -F "/" '{print $NF}' | sed 's/_genomic\.fna$//')
        conflict_mag=$(grep "$mag" /data1/software/gtdb/GTDB-Tk/archive/release*/taxonomy/gtdb_taxonomy.tsv)
        if [ -n "$conflict_mag" ] ; then
            echo "$conflict_mag" >> "$path"/gtdbtk/"gtdbtk.conflict.summary.tsv"
        else
        echo -e "$genomic\t$mag"
        fi
      done >$path/gtdbtk/"gtdbtk".$i/"genomes.list"
      # Run gtdbtk for the current group
      gtdbtk classify_wf --batchfile $path/gtdbtk/"gtdbtk".$i/genomes.list --out_dir $path/gtdbtk/"gtdbtk".$i --skip_ani_screen --cpus 50 >$path/gtdbtk/"gtdbtk".$i/gtdbtk.$i.stdout 2>$path/gtdbtk/"gtdbtk".$i/gtdbtk.$i.stderr
      # Remove 'identify' directory if it exists
      rm -r $path/gtdbtk/"gtdbtk".$i/identify
    done

  else
    mkdir "$path"/"gtdbtk"
    for genomic in "$path"/MAGs/*/*_genomic.fna ; do
      mag=$(echo "$genomic" | awk -F "/" '{print $NF}' | sed 's/_genomic\.fna$//')
      conflict_mag=$(grep "$mag" /data1/software/gtdb/GTDB-Tk/archive/release*/taxonomy/gtdb_taxonomy.tsv)
      if [ -n "$conflict_mag" ] ; then
          echo "$conflict_mag" >> "$path"/gtdbtk/"gtdbtk.conflict.summary.tsv"
      else
      echo -e "$genomic\t$mag"
      fi
    done > $path/gtdbtk/"genomes.list"
    echo $path/gtdbtk/"genomes.list"
    gtdbtk classify_wf --batchfile "$path"/gtdbtk/"genomes.list" --out_dir "$path"/"gtdbtk" --skip_ani_screen --cpus 30 > $path/gtdbtk/gtdbtk.stdout 2> $path/gtdbtk/gtdbtk.stderr
    rm -r $path/gtdbtk/identify
  fi
  deactivate
  version=$(gtdbtk -h | grep "GTDB-Tk v")
  echo "$version"  > $path/"gtdbtk"/version.txt
}
