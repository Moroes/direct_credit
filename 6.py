r"""
2)	Загрузчик файлов 
Реализовать загрузчик данных из файла csv, разделитель «;»,
 который максимально быстро по времени загрузит файл в таблицу БД.
   например, вот этот файл https://s3.amazonaws.com/capitalbikeshare-data/2011-capitalbikeshare-tripdata.zip. 

NOTE: Разделитель указан в переменной CSV_DELIMITER, в предложенном csv это ','

TODO:
1. Вынести переменные в config file
2. Сделать загрузку файла с облака
"""

import os
import psycopg2
import pandas as pd
from sqlalchemy import create_engine

TABLE_NAME = "table_from_csv"
CSV_FILENAME = os.environ.get("CSV_FILENAME", "data.csv")
CSV_DELIMITER = os.environ.get("CSV_DELIMITER", ',')

USER = os.environ.get("USER", "postgres")
PASSWORD = os.environ.get("PASSWORD", "")
DB = os.environ.get("DB", "postgres")
HOST = os.environ.get("HOST", "localhost")
PORT = os.environ.get("PORT", "5432")


# Быстрый метод массивной загрузки полного csv
def cussor_method():
    with psycopg2.connect(dbname=DB, host=HOST, user=USER, password=PASSWORD, port=PORT) as conn:
        with conn.cursor() as cur, open(CSV_FILENAME, 'r') as f:
            headers = f.readline().replace('\"', '').replace(' ', '_')[:-1].split(CSV_DELIMITER)
            create_table_query = f"""CREATE TABLE IF NOT EXISTS {TABLE_NAME}_cursor ({" TEXT,".join(headers)} TEXT);"""
            cur.execute(create_table_query)
            cur.copy_from(f, TABLE_NAME + "_cursor", sep=CSV_DELIMITER)


# Тяжелый метод с помощью pandas
def pandas_method():
    df = pd.read_csv(CSV_FILENAME)
    # df = df[:1000]
    engine = create_engine(f'postgresql+psycopg2://{USER}:{PASSWORD}@{HOST}/{DB}')

    df.to_sql(TABLE_NAME + "_pandas", engine, method='multi',index=False, if_exists='replace')

# pandas_method()
cussor_method()