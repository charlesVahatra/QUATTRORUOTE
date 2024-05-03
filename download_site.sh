#! /bin/bash

nb_retrieve_per_page=20
get_list_ind=1
get_detail_mod=1

function download_pages () {
	
	curl "${url}" > ${output}
}

########MAIN##########
dir=`pwd`
mkdir -p ${dir}/DONNEE  ${dir}/DONNEE/ANNONCE ${dir}/DONNEE/RESULT_PARS

url_base='https://www.quattroruote.it/auto-usate/annunci/'
# type_3 - km-0 =>    https://www.quattroruote.it/auto-usate/annunci/tipologia-km-0
	   # - nuovo =>	https://www.quattroruote.it/auto-usate/annunci/tipologia-nuovo
	   # - usato =>   https://www.quattroruote.it/auto-usate/annunci/tipologia-usato
	   
if [ $get_list_ind -eq 1 ]; then 
		  
		for type in "km-0" "nuovo" "usato"
		do
			mkdir -p ${dir}/DONNEE/${type}
			# https://www.quattroruote.it/auto-usate/annunci/tipologia-km-0 
			url=${url_base}tipologia-${type}
			output=${dir}/DONNEE/${type}/page-1.html
			download_pages
			nb_site=$(awk -f ${dir}/nb_annonce.awk ${dir}/DONNEE/${type}/page-1.html)
			
			# nb_site=20
			echo "${nb_site}"
			
			let "max_page=$nb_site/$nb_retrieve_per_page"
			echo "${max_page}"
			max_page=1
			
			# Crawl page list
			for (( page=1; page <=${max_page}; page++ ))
			# https://www.quattroruote.it/auto-usate/annunci/tipologia-[TYPE]?page=2
			do 
				url=${url_base}tipologia-${type}?page=${page}
				output=${dir}/DONNEE/${type}/page-${page}.html
				download_pages 			
			done
			wait
			
			# Parsing page liste
			for (( page=1; page <=${max_page}; page++ ))
			do 
				echo "PARSING_LISTES"
				awk -f ${dir}/liste_tab.awk -f ${dir}/put_html_into_tab.awk ${dir}/DONNEE/${type}/page-${page}.html > ${dir}/DONNEE/${type}/${type}.$$
				echo "parsing effectué"
			done
			
			cat  ${dir}/DONNEE/${type}/${type}.$$ | sort -u -k1,1 >  ${dir}/DONNEE/${type}/${type}.tab
			nb_observe=`wc -l  ${dir}/DONNEE/${type}/${type}.tab | awk '{print $1; }'`
			cat ${dir}/DONNEE/${type}/${type}.tab  >> ${dir}/DONNEE/extract.$$
			echo -e "${type}\t${nb_site}\t${nb_observe}\tLOG"	
		done
		wait 
		
		cat ${dir}/DONNEE/extract.$$ | sort -u -k1,1 >  ${dir}/DONNEE/extract.tab 
		
fi 

if [ ${get_detail_mod} -eq 1 ]; then 
	max_i=`cat ${dir}/DONNEE/extract.tab | wc -l` 
	for (( i=1; i <=${max_i} ; i++ ))
	do
		# $ cat extract.tab | awk "NR == 1" | awk '{print $3}'
		url=`cat ${dir}/DONNEE/extract.tab | awk "NR==$i" | awk '{print $2}'`
		id_client=`cat ${dir}/DONNEE/extract.tab | awk "NR==$i" | awk '{print $3}'`
		output=${dir}/DONNEE/ANNONCE/annonce-${id_client}.html
		download_pages
		
		awk -f ${dir}/all_html.awk ${dir}/DONNEE/ANNONCE/annonce-${id_client}.html >> ${dir}/DONNEE/RESULT_PARS/resultat.sql 
	done		
fi 

echo -e "FIN DOWNLOAD"