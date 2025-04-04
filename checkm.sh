#!/bin/bash

function checkm_running() {
  source /data1/software/checkm/CheckM-1.2.2/env/bin/activate

  path=$1
  mkdir $path/"checkm_list"
  # shellcheck disable=SC2067
  find "$path"/MAGs/ -name '*_proteins.faa' -exec ln -s {} $path/"checkm_list" \; # creating a soft link for large lists
  checkm.lineage_wf.sh $path/checkm_list $path --ncpus=30 --tab_table
  mv $path/"checkm_list" $path/checkm
  mv $path/"checkm.stdout" $path/checkm
  mv $path/log $path/checkm
  rm -r $path/checkm/bins
  deactivate
}
