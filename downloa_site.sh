function download_site(){	
	curl "${url}" > ${output}
}
dir=`pwd`
mkdir -p ${dir}/DONNEE

url_base='https://www.quattroruote.it/auto-usate/annunci/'
# type_3 - km-0 =>    https://www.quattroruote.it/auto-usate/annunci/tipologia-km-0
	   # - nuovo =>	https://www.quattroruote.it/auto-usate/annunci/tipologia-nuovo
	   # - usato =>   https://www.quattroruote.it/auto-usate/annunci/tipologia-usato
for type in "km-0" "nuovo" "usato"
do
	mkdir -p ${dir}/DONNEE/${type}
	cd ${dir}/DONNEE/${type}
	url=${url_base}tipologia-${type}
	output=${dir}/DONNEE/${type}/page-1.html
	download_site
	 nb_pages=${dir}/DONNEE/[nb_annonce] / 24 
done
	