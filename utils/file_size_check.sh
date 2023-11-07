#!/bin/bash

 path="/data2/MAGs-data/test_dir"
 dir_size=$(du -sk "$path" | awk '{print $1}')
    if [ "$dir_size" -ge 10000 ]; then
      num_subdirs=$(($dir_size + 9999 / 10000 ))
      for i in $(seq 1 $num_subdirs); do
        mkdir -p "$path/group$i"
      done
      find . -maxdepth 1 -type f -exec du -k {} + | sort -n | awk -v num_subdirs="$num_subdirs" '
      {sum+=$1}
      {if (sum > (num_subdirs-1)*10000) exit 1}
      {print $2}' | xargs -I{} mv {} $path/group$(($num_subdirs-1))

      groups=$(ls $path | grep group | sed -r 's/(.*)\..*/\1/')
      for group in $groups; do
        genome_list=$(ls "$path"/"$group")
        for genome in $genome_list; do
          genome_dir=$(echo "$genome" | sed -r 's/(.*)\..*/\1/')
#         echo $genome_dir
          prodigal -i $path/$group/$genome_dir/${genome_dir}_genomic.fna -d $path/$group/$genome_dir/${genome_dir}_genes.fna -a $path/$group/$genome_dir/${genome_dir}_proteins.faa -o $path/$group/$genome_dir/${genome_dir}_genomic.gff -f gff
          cd $path/$group/$genome_dir
          scg.pl -o $genome_dir $path/$group/$genome_dir/${genome_dir}_proteins.faa
        done
      done
    fi