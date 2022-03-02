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

TS=`date +"%s"`
PAGE_SEARCH=`curl -qs "https://www.sia.aviation-civile.gouv.fr/customer/section/load/?sections=custom_menu&_=${TS}" -H 'Referer: https://www.sia.aviation-civile.gouv.fr/' | jq .custom_menu.menu | awk -F'<li>' '{$1=$1}1' OFS='\n' |grep -i "atlas vac france" | sed -e "s/.*https/https/" | sed -e s"%/home.htm.*%/home.htm%"`
URL_PREFIX=`curl -qs ${PAGE_SEARCH} |grep www.sia.aviation-civile.gouv.fr/dvd | sed -e "s/.*https/https/" | sed -e s"%FR/home.htm.*%%"`


function toA5() {
    # toA5 from to
    pdfjam --quiet --outfile "$1" --paper a5paper "$2"
}

function landscapeTwoPerPage() {
    pdfjam $1 --nup 2x1 --landscape --quiet --outfile $2
}

function from_url () {
    #  PARAM:
    #   - OACI code
    #   - output filename
        EXECUTED=true
    
        FILENAME="$2"

        if [ -z "${FILENAME}" ]
        then
            FILENAME="$1.pdf"
        fi

        VAC="PDF_AIPparSSection/VAC/AD/AD-2.$1.pdf"

        printf "${FILENAME} [GET ${URL_PREFIX}${VAC}] => "
        if [ "${VAC}" == "null" ]
        then
            printf "[X]"
        else
            curl -qs -o "${FILENAME}" "${URL_PREFIX}${VAC}"
        fi

        if [ ! -z ${A5+x} ]
        then

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
            TMP_A5_FILENAME="/tmp/${FILENAME}_a5.pdf"
            A5_FILENAME="${FILENAME%.*}_a5.pdf"

            PAGES=$(pdftk ${FILENAME} dump_data | grep NumberOfPages | sed -e 's/NumberOfPages: //')
            printf "${PAGES} pages : "

            CURRENT=1
            FILE_LIST=

            if [ ! -z ${VERSO+x} ]
            then
                PAGE1=1
                PAGE2=3
                PAGE3=4
                PAGE4=2
                SEQUENCES=$((PAGES/4))
                if [ "$((${PAGES} % 4))" -ne "0" ]
                then
                    SEQUENCES=$((${SEQUENCES}+1))
                fi
                
                for seg in $(seq ${SEQUENCES})
                do
                    BLANK3=
                    BLANK4=

                    if [ "${PAGE1}" -le "${PAGES}" ]
                    then
                        pdftk "${FILENAME}" cat ${PAGE1} output "/tmp/${CURRENT}_.pdf"
                        toA5 "/tmp/${CURRENT}.pdf" "/tmp/${CURRENT}_.pdf"
                    else
                        cp /tmp/blank.pdf  "/tmp/${CURRENT}.pdf"
                    fi
                    FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
                    CURRENT=$((${CURRENT}+1))
                    PAGE1=$((${PAGE1}+4))

                    if [ "${PAGE2}" -le "${PAGES}" ]
                    then
                        pdftk "${FILENAME}" cat ${PAGE2} output "/tmp/${CURRENT}_.pdf"
                        toA5 "/tmp/${CURRENT}.pdf" "/tmp/${CURRENT}_.pdf"
                    else
                        cp /tmp/blank.pdf  "/tmp/${CURRENT}.pdf"
                    fi
                    FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
                    CURRENT=$((${CURRENT}+1))
                    PAGE2=$((${PAGE2}+4))

                    if [ "${PAGE3}" -le "${PAGES}" ]
                    then
                        pdftk "${FILENAME}" cat ${PAGE3} output "/tmp/${CURRENT}_.pdf"
                        toA5 "/tmp/${CURRENT}.pdf" "/tmp/${CURRENT}_.pdf"
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
                        toA5 "/tmp/${CURRENT}.pdf" "/tmp/${CURRENT}_.pdf"
                    else
                        cp /tmp/blank.pdf  "/tmp/${CURRENT}.pdf"
                        BLANK4=t
                    fi
                    FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
                    CURRENT=$((${CURRENT}+1))
                    PAGE4=$((${PAGE4}+4))
                done

                pdftk ${FILE_LIST} cat output "/tmp/${FILENAME}.pdf"
                landscapeTwoPerPage "/tmp/${FILENAME}.pdf" "${TMP_A5_FILENAME}"

                if [ "${BLANK3}${BLANK4}" == "tt" ]
                then
                    pdftk ${TMP_A5_FILENAME} cat 1-r2 output ${A5_FILENAME}
                else
                    cp ${TMP_A5_FILENAME} ${A5_FILENAME}
                fi

            else
                for PAGE in $(seq ${PAGES})
                do
                    pdftk "${FILENAME}" cat ${PAGE} output "/tmp/${CURRENT}_.pdf"
                    toA5 "/tmp/${CURRENT}.pdf" "/tmp/${CURRENT}_.pdf"

                    FILE_LIST="${FILE_LIST} /tmp/${CURRENT}.pdf"
                    CURRENT=$((${CURRENT}+1))
                done

                pdftk ${FILE_LIST} cat output "/tmp/${FILENAME}.pdf"
                landscapeTwoPerPage "/tmp/${FILENAME}.pdf" "${TMP_A5_FILENAME}"
                cp ${TMP_A5_FILENAME} ${A5_FILENAME}
            fi

            rm /tmp/blank.pdf
            rm ${FILE_LIST}
            rm /tmp/*_.pdf
            rm /tmp/${FILENAME}.pdf
            rm ${TMP_A5_FILENAME}

            if [ -z ${KEEP_ORIGINAL+x} ]
            then
                rm ${FILENAME}
            fi
        fi

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
    echo "vac-a5.sh [--json ./list.json]  [--oaci LFRN] [--a5] [--a5-verso] [--keep-original]"
    echo "JSON format: [{\"filename\": \"toto.pdf\", \"oaci\": \"LFRN\"}]"
}


while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --json)
        JSON="$2"
        shift
        ;;
        --oaci)
        echo "extracting $2 ..."
        OACI="${OACI} $2"
        shift
        ;;
        --a5-verso)
        A5=true
        VERSO=true
        shift
        ;;
        --keep-original)
        KEEP_ORIGINAL=true
        shift
        ;;
        --a5)
        A5=true
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

if [ ! -z ${JSON+x} ]; then from_json ${JSON}; fi

if [ ! -z ${OACI+x} ]
then
    for code in ${OACI}
    do
        from_url ${code}
    done 
fi

if [ -z ${EXECUTED+x} ]; then help; fi
