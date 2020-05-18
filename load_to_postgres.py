"""
Takes a path to csv or a url with a csv and loads it in to
postgres table. Assumes header row with column names.
 
Input: filepath or url, table name, db connection string 
Output: table created in postgres database

Uses: usual things plus ohio
pip install ohio


"""

import pandas as pd
import requests
import ohio.ext.pandas
from sqlalchemy import create_engine
import io
import logging
import sys

# source can be csv file or url
source=sys.argv[1] 
table_name=sys.argv[2]
# example string: postgres://username:password@localhost:5432/postgres
db_string = sys.argv[3]

if source.startswith('http'):
	try:
	    downloaded_file=requests.get(source).content
	except requests.exceptions.RequestException as e:
	    raise SystemExit(e)
	df=pd.read_csv(io.StringIO(downloaded_file.decode('utf-8')))
else:
	df=pd.read_csv(source)

engine = create_engine(db_string)
df.pg_copy_to(table_name, engine, if_exists='replace', index=False)
