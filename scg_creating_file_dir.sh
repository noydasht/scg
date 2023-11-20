#!/bin/bash
function creating_file_dir() {
  path=$1
#  gunzip "$path"/*
  mag_list=$(ls "$path"/MAGs)
#  mkdir "$path"/MAGs
  for mag in $mag_list; do
    mag_dir_name=$(basename "$mag" .fa)
    echo "$mag_dir_name"
    mkdir "$path"/MAGs/"${mag_dir_name}"
    mv "$path"/MAGs/"${mag}" "$path"/MAGs/"${mag_dir_name}"/"${mag_dir_name}"_genomic.fna
      done

  }

function creating_mags_dir_with_fna_zip() {
  path=$1
  mag_list=$(ls -I "*txt" "$path")
  mkdir "$path"/MAGs
  for mag in $mag_list; do
    mv "$path"/"$mag" "$path"/"MAGs"
    echo "$mag_dir_name"
  done
  gunzip "$path"/MAGs/*/*

}