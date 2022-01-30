#!/bin/bash


if ! [ -x "$(command -v pdftk)" ]; then
  echo 'Error: pdftk is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v pdfjam)" ]; then
  echo 'Error: texlive-extra-utils is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi


#URL_PREFIX="https://www.sia.aviation-civile.gouv.fr/dvd/eAIP_30_DEC_2021/Atlas-VAC/"
URL_PREFIX=`curl -qs https://www.sia.aviation-civile.gouv.fr/documents/htmlshow\?f\=dvd/eAIP_27_JAN_2022/Atlas-VAC/home.htm |grep www.sia.aviation-civile.gouv.fr/dvd | sed -e "s/.*https/https/" | sed -e s"%FR/home.htm.*%%"`



function from_url () {
    #  PARAM:
    #   - OACI code
    #   - output filename
    base64 -d <<BASE | gunzip > /tmp/blank.pdf 
H4sICNKNz2AAA2JsYW5rLnBkZgC1VF1vmzAU3bN/xX2p1D6stgGDqaI8NDRbtXXNmkqbFPXBgElo
E5yBM7V72k+fTUiD5mzqVA3JCI7P/Tr32keTZPyWngaAKBBQ6T0aDBCeiLlswDPIDcK3T2sJeCS0
WKo5Gg6RrHJL9HoGW05rhvCHMm9gBr41hzuER2pTaaA9U/+gqY1bS0PtAt/IRm3qzGRieV+v03uZ
afMN+HJFgLfujU88qVU2lRrCZ+RK5qU4V48wIwZjMQMeeDaTWq0PwarSJm4DQVfxYrNKgdL2b591
0Mv6o6zmegFsR2l0LcUKfWtlJLB9ZyvUppoo9BlZLx2r88c6f160Q8IOmRlBkjHgW/mobbVGnJFR
smNF+zz2yXFH0k4whKebVLdI6wjhT2LV/hCEx+VSy9o0C99sqm1NicxULm3fvpS5KZEi/F6W84Xt
oFFqqerpWmQSKNmKdV7qZiLrkVqtVWW7x03EK9E8AN2qs9Mq/k2rN29+uprEXRn+DmjD2A+cyO9l
Jt/V4ul5rz+z/6mULnnqvSR76jnp+4eaRQOHx/61f1fidf3r6/nXysMXVR46FUX9ikq9lDAgJPTM
GplFzbow65yYZ2iPphS6VFUitITj5MwjHrVsyoOYBSfmTKv8j3vmBsg3mRHieKH1ujnDuLRSmVVm
D6eqnp/0xH+sZYHMEeWIPD8QMuYzKOAZszPR7lR7jMUORil3MJ+4tj4/gMWubeCHLsYiBwuZywsj
38EiQh2MB64tDwMX4y4vJg6PktjhUUp7PF2LcinrdhKm5Q9ptceXVaGgHRJ71SulYXvf4ssEZgNR
MBaRggnKKUkjUUQ8E0WQZhERYUgKkheMysBLRRHTPMglSz3f47kkkvt5kQ3h9S7utkMvat2ODPXC
CB0dXVyP0S+pys1xNgcAAA==
BASE

        FILENAME="$2"

        if [ -z "${FILENAME}" ]
        then
            FILENAME="$1.pdf"
        fi

        VAC="PDF_AIPparSSection/VAC/AD/AD-2.$1.pdf"

        printf "${FILENAME} => "
        if [ "${VAC}" == "null" ]
        then
            printf "[X]"
        else
            curl -qs -o "${FILENAME}" "${URL_PREFIX}${VAC}"
        fi
        
        PAGES=$(pdftk ${FILENAME} dump_data | grep NumberOfPages | sed -e 's/NumberOfPages: //')
        printf "${PAGES} pages : "

        PAGE1=1
        PAGE2=3
        PAGE3=4
        PAGE4=2
        SEQUENCES=$((PAGES/4))
        if [ "$((${PAGES} % 4))" -ne "0" ]
        then
            SEQUENCES=$((${SEQUENCES}+1))
        fi
        CURRENT=1
        FILE_LIST=

        for seg in $(seq ${SEQUENCES})
        do
            BLANK3=
            BLANK4=

            if [ "${PAGE1}" -le "${PAGES}" ]
            then
                pdftk "${FILENAME}" cat ${PAGE1} output "/tmp/${CURRENT}_.pdf"
                pdfjam --quiet --outfile "/tmp/${CURRENT}.pdf" --paper a5paper "/tmp/${CURRENT}_.pdf"
            else
                cp /tmp/blank.pdf  "/tmp/${CURRENT}.pdf"
            fi
            FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
            CURRENT=$((${CURRENT}+1))
            PAGE1=$((${PAGE1}+4))

            if [ "${PAGE2}" -le "${PAGES}" ]
            then
                pdftk "${FILENAME}" cat ${PAGE2} output "/tmp/${CURRENT}_.pdf"
                pdfjam --quiet --outfile "/tmp/${CURRENT}.pdf" --paper a5paper "/tmp/${CURRENT}_.pdf"
            else
                cp /tmp/blank.pdf  "/tmp/${CURRENT}.pdf"
            fi
            FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
            CURRENT=$((${CURRENT}+1))
            PAGE2=$((${PAGE2}+4))

            if [ "${PAGE3}" -le "${PAGES}" ]
            then
                pdftk "${FILENAME}" cat ${PAGE3} output "/tmp/${CURRENT}_.pdf"
                pdfjam --quiet --outfile "/tmp/${CURRENT}.pdf" --paper a5paper "/tmp/${CURRENT}_.pdf"
            else
                cp /tmp/blank.pdf  "/tmp/${CURRENT}.pdf"
                BLANK3=t
            fi
            FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
            CURRENT=$((${CURRENT}+1))
            PAGE3=$((${PAGE3}+4))

            if [ "${PAGE4}" -le "${PAGES}" ]
            then
                pdftk "${FILENAME}" cat ${PAGE4} output "/tmp/${CURRENT}_.pdf"
                pdfjam --quiet --outfile "/tmp/${CURRENT}.pdf" --paper a5paper "/tmp/${CURRENT}_.pdf"
            else
                cp /tmp/blank.pdf  "/tmp/${CURRENT}.pdf"
                BLANK4=t
            fi
            FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
            CURRENT=$((${CURRENT}+1))
            PAGE4=$((${PAGE4}+4))
        done

        TMP_A5_FILENAME="/tmp/${FILENAME}_a5.pdf"
        A5_FILENAME="${FILENAME%.*}_a5.pdf"

        pdftk ${FILE_LIST} cat output /tmp/${FILENAME}.pdf
        pdfjam /tmp/${FILENAME}.pdf --nup 2x1 --landscape --quiet --outfile ${TMP_A5_FILENAME}

        if [ "${BLANK3}${BLANK4}" == "tt" ]
        then
            pdftk ${TMP_A5_FILENAME} cat 1-r2 output ${A5_FILENAME}
        else
            cp ${TMP_A5_FILENAME} ${A5_FILENAME}
        fi

        rm ${FILE_LIST}
        rm /tmp/*_.pdf
        rm /tmp/blank.pdf
        rm /tmp/${FILENAME}.pdf
        rm ${TMP_A5_FILENAME}
        echo "OK"
}


function from_json() {
    #  PARAM:
    #   - json filename
    JSON=$1

    COUNT=`cat ${JSON} | jq length`

    for i in $(seq 1 $COUNT)
    do  
        FILENAME=`cat ${JSON}| jq .[$((${i}-1))].filename | sed -e 's/"//g'`
        VAC=`cat ${JSON}| jq .[$((${i}-1))].oaci | sed -e 's/"//g'`

        printf "${i}/${COUNT} - "

        from_url ${VAC} ${FILENAME}
    done
}

function help () {
    echo "vac-a5.sh [--json ./list.json]  [--oaci LFRN]"
    echo "JSON format: [{\"filename\": \"toto.pdf\", \"oaci\": \"LFRN\"}]"
}


while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --json)
        from_json "$2"
        shift
        ;;
        --oaci)
        echo "extracting $2 ..."
        from_url "$2"
        shift
        ;;
        -h|--help)
        help
        shift
        ;;
        *)
        shift
        ;;
    esac
done