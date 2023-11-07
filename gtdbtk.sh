#!/bin/bash
function gtdbtk_run() {
  source /data1/software/gtdb/GTDB-Tk/gtdbtk-2.1.1/env/bin/activate
  path=$1 #change it to get the path from the main script
  files_number=$(ls "$path/MAGs" | wc -l )
  groups_number=$((files_number / 1000 + 1))
  if [ "$files_number" -gt 1000 ]; then
    for i in $(seq 1 $groups_number) ; do
            mkdir $path/"gtdbtk"/"gtdbtk".$i
            # shellcheck disable=SC2231
            for genomic in $path/MAGs/*/*_genomic.fna ; do
                    mag=$(echo "$genomic" | awk -F "/" '{print $NF}' | awk -F "." '{print $1}')
                    echo -e "$genomic\t$mag"
            done > $path/gtdbtk/"gtdbtk".$i/"genomes.list"
            gtdbtk classify_wf --batchfile $path/gtdbtk/"gtdbtk".$i/genomes.list --out_dir $path/gtdbtk/"gtdbtk".$i --cpus 50 > $path/gtdbtk/"gtdbtk".$i/gtdbtk.$i.stdout 2> $path/gtdbtk/"gtdbtk".$i/gtdbtk.$i.stderr
            rm -r $path/gtdbtk/"gtdbtk".$i/identify
    done
  else
    mkdir "$path"/"gtdbtk"
    for genomic in "$path"/MAGs/*/*_genomic.fna ; do
      mag=$(echo "$genomic" | awk -F "/" '{print $NF}' | awk -F "." '{print $1}')
      echo -e "$genomic\t$mag"
    done > $path/gtdbtk/"genomes.list"
    echo $path/gtdbtk/"genomes.list"
    gtdbtk classify_wf --batchfile "$path"/gtdbtk/"genomes.list" --out_dir "$path"/"gtdbtk" --cpus 30 > $path/gtdbtk/gtdbtk.stdout 2> $path/gtdbtk/gtdbtk.stderr
    rm -r $path/gtdbtk/identify
  fi
  deactivate
  version=$(gtdbtk -h | grep "GTDB-Tk v")
  echo "$version"  > $path/"gtdbtk"/version.txt
}
