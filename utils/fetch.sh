scg_list=$(cat /data1/GBCP/marker-genes-mining/marker-genes/scg.list)
mkdir -p $(date "+%Y.%m.%d-%H:%M:%S")
for scg in "${scg_list[@]}"; do
  ldir=$(date "+%Y.%m.%d-%H:%M:%S")"/"$scg
  mkdir $ldir

  python3 fetch.py $scg $ldir/$scg.genes.fna fna
  python3 fetch.py $scg $ldir/$scg.proteins.faa faa
done

for f in $(find ../data -name "*.proteins.faa.scg.faa") ; do
	# ../data/soil/GCA_013697515.1/GCA_013697515.1.proteins.faa.scg.faa
	environment=$(echo $f | cut -f3 -d"/")
	sample=$(echo $f | sed 's/.*\///; s/.proteins.faa.scg.faa//')
	fn=$(echo $f | sed 's/.proteins.faa.scg.faa/.genes.fna.scg.fna/')
	grep "$scg" $f | cut -b2- | cut -f1 -d" " > $ldir/list
	getseq -i $ldir/list -f $f | sed "s/>/>__/; s/>/>$sample/; s/>\([^ ]*\).*/>\1 $environment/" >> $ldir/$scg.proteins.faa
	getseq -i $ldir/list -f $fn | sed "s/>/>__/; s/>/>$sample/; s/>\([^ ]*\).*/>\1 $environment/" >> $ldir/$scg.genes.fna
done
rm -f $ldir/list
