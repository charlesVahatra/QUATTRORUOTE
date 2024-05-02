BEGIN {nb_annonce=0}
/<span class="text-blue h2">/ {
    getline
        gsub("[^0-9]", "", $0)
        nb_annonce=$0
}
END{
        print "nb_annonce="nb_annonce";"
}