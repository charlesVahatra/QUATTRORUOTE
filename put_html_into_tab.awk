BEGIN { c=1}
/<span class="font-weight-bold mx-2">/{
		getline
        val["PRIX", c]=$0
		c++
	}
/ <figure class="col-12 col-md-5 mb-0 px-0 position-relative">/{
	getline
	split($0, ar, /<a href="/)
	split(ar[2], ar1, /" class="box-annuncio">/)
	val["ANNONCE_LINK", c]=ar1[1]
	gsub(".*[^0-9]-", "", ar1[1])
	val["ID_CLIENT", c]=ar1[1]
}	

END {
	max_c=c
	for(c=1;c<max_c; c++) {	
		for(i=1; i<max_i; i++) {
			gsub("\r|\t", "", val[title[i], c])
			gsub("\"", "", val[title[i], c])
			printf("%s\t", trim(val[title[i], c])) 					
		}
		printf("\n")
	}
}

function ltrim(s) {
	gsub("^[ \t]+", "", s);
	return s
}

function rtrim(s) {
	gsub("[ \t]+$", "", s);
	return s
}

function trim(s) {
	return rtrim(ltrim(s));
}

