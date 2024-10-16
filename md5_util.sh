#!/bin/bash

function verify_checksums() {
  gz_file_location=$1
  md_txt_location=$2
  gz_file_hush=$(md5sum "$gz_file_location" | tr -s ' ' | cut -d' ' -f1)
  md_txt_hush=$(cat "$md_txt_location" | grep genomic.fna.gz | tr -s ' ' | cut -d' ' -f1)
  if [[ "$gz_file_hush" == "$md_txt_hush" ]]; then
    return 0 #true
  else
    return 1 #false
  fi
}
