#!/bin/bash
# takes a csv and copies it to a postgres table
# drop existing table 
# creates new table

usage() { echo "Usage: " 1>&2; exit 1; }


while getopts ":h:d:s:t:u:p:f:" o; do
    case "${o}" in
        h)
            h=${OPTARG}
            ;;
        d)
            d=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;          
        u)
            u=${OPTARG}
           ;;
        p)
            p=${OPTARG}
            ;;
        f)
            f=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

export PGPASSWORD=${p};

echo ${p}
# generate create table statement for postgres
csvsql -i postgresql --tables ${t} --db-schema ${s} -d ',' "${f}" > "temp.sql"

# drop table if it already exists
psql -h ${h} -U ${u} -d ${d} -c "DROP TABLE IF EXISTS ${t};"  

# create postgres table
psql -h ${h} -U ${u} -d ${d} < "temp.sql" 

# copy file to postgres table
cat "${f}" | psql -h ${h} -U ${u} -d ${d} -c "\COPY ${s}.${t} FROM STDIN WITH CSV HEADER DELIMITER ',';"
