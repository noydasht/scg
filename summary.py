import subprocess
import os

path = "/data2/MAGs-data/06.3.1.MIMAG_copy"
mag_list = subprocess.check_output(f"ls -l {path}/MAGs | awk '{{print $9}}'", shell=True).decode("utf-8").split('\n')

for mag in mag_list:
    mag_name = mag
    mag_dir = f"{path}/MAGs/{mag_name}"
    print(mag_name)
    print(mag_dir)
